package ddw;

import HTML5Dom;
import js.Dom;
import js.Lib;
import js.Storage;

	
class VexDrawBinaryReader 
{
	private var data:Uint8Array;
	private var index:Int;
	private var bit:Int;
	
	private var fillIndexNBits:Int;
	private var strokeIndexNBits:Int;
	
	private var twips:Int = 32;
	private var maskArray:Array<Int>;
		
	public function new(path:String, vo:VexObject, onParseComplete:Dynamic = null)
	{		
		maskArray = [0x00, 0x01, 0x03, 0x07, 0x0F, 0x1F, 0x3F, 0x7F, 0xFF, 
					0x01FF, 0x03FF, 0x07FF, 0x0FFF, 0x1FFF, 0x3FFF, 0x7FFF, 0xFFFF,
					0x01FFFF, 0x03FFFF, 0x07FFFF, 0x0FFFFF, 0x1FFFFF, 0x3FFFFF, 0x7FFFFF, 0xFFFFFF,
					0x01FFFFFF, 0x03FFFFFF, 0x07FFFFFF, 0x0FFFFFFF, 0x1FFFFFFF, 0x3FFFFFFF, 0x7FFFFFFF, 0xFFFFFFFF];
		
		var xhr:XMLHttpRequest = untyped __new__("XMLHttpRequest");
		xhr.open('GET', path, true);
		xhr.responseType = 'arraybuffer';

		xhr.onload = function(e:Dynamic):Void
		{
			if (xhr.readyState == 4)
			{
				data = new Uint8Array(xhr.response);
				parseTags(vo);
				if (onParseComplete != null)
				{
					onParseComplete();	
				}
			}
		}
		xhr.send();
	}
	
	private function parseTags(vo:VexObject) : Void
	{
		index = 0;
		bit = 8;
		while (index < data.length)
		{
			var tag:Int = readByte();
			var len:Int = readNBitInt(24);
			var startLoc:Int = index;

			switch(tag)
			{
				case VexDrawTag.DefinitionNameTable:
					parseNameTable(vo.definitionNameTable);
					
				case VexDrawTag.InstanceNameTable:
					parseNameTable(vo.instanceNameTable);
					
				case VexDrawTag.PathNameTable:
					parseStringTable(vo.pathTable);
					
				case VexDrawTag.StrokeList:
					parseStrokes(vo);
					
				case VexDrawTag.SolidFillList:		
					parseSolidFills(vo);
					
				case VexDrawTag.GradientFillList:		
					parseGradientFills(vo);
					
				case VexDrawTag.SymbolDefinition:
					var symbol:Symbol = parseSymbol(vo);
					vo.definitions.set(symbol.id, symbol);	
					
				case VexDrawTag.TimelineDefinition:
					var tl:Timeline = parseTimeline(vo);
					vo.definitions.set(tl.id, tl);	
					
				case VexDrawTag.ImageDefinition:
					var img:ddw.Image = parseImage(vo);
					vo.definitions.set(img.id, img);	
					
				case VexDrawTag.End:
					index += 0;	// not sure how to have a do nothing without fall through?
					
				default:
					index += len;
			}
			
			if (index - startLoc != len)
			{
				Lib.alert("Parse error. tagStart:" + startLoc + " tagEnd:" + index + " len:" + len + " tagType: " + tag);
				index = startLoc + len;
			}
		}	
	}
	
	private function parseNameTable(table:IntHash<String>):Void
	{	
		var idNBits:Int = readNBitCount();
		var nameNBits:Int = readNBitCount();
		var stringCount:Int = readNBits(16);
		
		for (i in 0...stringCount)
		{
			var id:Int = readNBitInt(idNBits);
			var charCount:Int = readNBits(16);
			var s:String = "";
			for (j in 0...charCount)
			{
				var charVal:Int = readNBits(nameNBits);
				s += String.fromCharCode(charVal);
			}
			
			table.set(id, s);
		}		
		
		flushBits();		
	}
	private function parseStringTable(table:Array<String>):Void
	{	
		var nameNBits:Int = readNBitCount();
		var stringCount:Int = readNBits(16);
		
		for (i in 0...stringCount)
		{
			var charCount:Int = readNBits(16);
			var s:String = "";
			for (j in 0...charCount)
			{
				var charVal:Int = readNBits(nameNBits);
				s += String.fromCharCode(charVal);
			}
			
			table.push(s);
		}		
		
		flushBits();		
	}
	private function parseTimeline(vo:VexObject):Timeline
	{	
		var result:Timeline = new Timeline();
		result.id = readNBits(32);
				
		result.bounds = readNBitRect();
		
		var instancesCount:Int = readNBits(11);	
		for (i in 0...instancesCount)
		{
			// defid32,hasVals[7:bool], x?,y?,scaleX?, scaleY?, rotation?, shear?, "name"?
			var defId:Int = readNBits(32);
			var inst:Instance = new Instance(defId);
			
			var hasX:Bool = readBit();
			var hasY:Bool = readBit();
			var hasScaleX:Bool = readBit();
			var hasScaleY:Bool = readBit();
			var hasRotation:Bool = readBit();
			var hasShear:Bool = readBit();
			var hasName:Bool = readBit();
			
			if (hasX || hasY || hasScaleX || hasScaleY || hasRotation || hasShear)
			{				
				var mxNBits:Int = readNBitCount();
				if (hasX)
				{
					inst.x = readNBitInt(mxNBits) / twips;
				}
				if (hasY)
				{
					inst.y = readNBitInt(mxNBits) / twips;
				}
				if (hasScaleX)
				{
					inst.scaleX = readNBitInt(mxNBits) / twips;
					inst.hasScale = true;
				}
				if (hasScaleY)
				{
					inst.scaleY = readNBitInt(mxNBits) / twips;
					inst.hasScale = true;
				}
				if (hasRotation)
				{
					inst.rotation = readNBitInt(mxNBits) / twips;
					inst.hasRotation = true;
				}
				if (hasShear)
				{
					inst.shear = readNBitInt(mxNBits) / twips;
					inst.hasShear = true;
				}
			}
			
			if (hasName)
			{
				// todo: read name
			}
			
			result.instances.push(inst);
		}
		
		flushBits();
		
		return result;
	}
	
	private function parseImage(vo:VexObject):ddw.Image
	{	
		var result:ddw.Image = new ddw.Image();
		result.id = readNBits(32);				
		result.bounds = readNBitRect();
		result.pathId = readNBits(11);	
		result.setPath(vo.pathTable[result.pathId]);
		
		flushBits();
		
		return result;
	}
	
	private function parseSymbol(vo:VexObject):Symbol
	{	
		var result:Symbol = new Symbol();
		result.id = readNBits(32);
				
		result.bounds = readNBitRect();
		
		// parse paths
		var pathsCount:Int = readNBits(11);
		var pathIndexNBits:Int = readNBitCount();
		for (i in 0...pathsCount)
		{						
			var path:Path = new Path();
			var nBits:Int = readNBitCount();
			var segmentCount:Int = readNBits(11);			
			for (j in 0...segmentCount)
			{
				var seg:Segment = new Segment();
				var segType:Int = readNBits(2);		
				seg.points.push(readNBitInt(nBits) / twips);		
				seg.points.push(readNBitInt(nBits) / twips);	
				
				switch(segType)
				{
					case 0:
						seg.segmentType = SegmentType.MoveTo;
					case 1:
						seg.segmentType = SegmentType.LineTo;
					case 2:
						seg.segmentType = SegmentType.QuadraticCurveTo;
						seg.points.push(readNBitInt(nBits) / twips);		
						seg.points.push(readNBitInt(nBits) / twips);
					case 3:
						seg.segmentType = SegmentType.BezierCurveTo;
						seg.points.push(readNBitInt(nBits) / twips);		
						seg.points.push(readNBitInt(nBits) / twips);
						seg.points.push(readNBitInt(nBits) / twips);		
						seg.points.push(readNBitInt(nBits) / twips);
				}
				path.segments.push(seg);
			}
			result.paths.push(path);
		}
		
		// parse shapes
		var shapesCount:Int = readNBits(11);	
		for (i in 0...shapesCount)
		{
			var strokeIndex:Int = readNBits(strokeIndexNBits);	
			var fillIndex:Int = readNBits(fillIndexNBits);	
			var pathIndex:Int = readNBits(pathIndexNBits);
			
			var shape:Shape = new Shape(strokeIndex, fillIndex, pathIndex);
			result.shapes.push(shape);
		}
		
		flushBits();
		return result;
	}
	
	private function parseGradientFills(vo:VexObject):Void
	{	
		var cv:HTMLCanvasElement = cast Lib.document.createElement('canvas');
		var g:CanvasRenderingContext2D = cv.getContext("2d");	
		
		var padding:Int = readNBitCount();
		var gradientCount:Int = readNBits(11);		
		for (gc in 0...gradientCount)
		{
			// type:i byte, stopColors[...]<Int>, stopRatios[...]<Int>, matrix[6]<Int>
			
			var type:Int = readNBits(3);
			
			var lineNBits:Int = readNBitCount();
			var tlX:Float = readNBitInt(lineNBits) / twips;
			var tlY:Float = readNBitInt(lineNBits) / twips;
			var trX:Float = readNBitInt(lineNBits) / twips;
			var trY:Float = readNBitInt(lineNBits) / twips;			

			var gradient:CanvasGradient;			
			if (type == 0)
			{
				gradient = g.createLinearGradient(tlX, tlY, trX, trY);
			}
			else // radial, line is center to rightCenter 
			{
				//var difX:Float = trX - tlX;
				//var difY:Float = trY - tlY;
				//var r2:Float = Math.sqrt(difX * difX + difY * difY);
				var r2:Float = trX - tlX;
				gradient = g.createRadialGradient(tlX, tlY, 0, tlX, tlY, r2);	
				//Lib.alert(tlX +" " + tlY);
			}
			
			// stop colors
			var colorNBits:Int = readNBitCount();
			var ratioNBits:Int = readNBitCount();
			var count:Int = readNBits(11);				
			for (stops in 0...count)
			{
				var color:Color = Color.fromAFlipRGB(readNBits(colorNBits));
				var ratio:Float = readNBits(ratioNBits) / 255;
				if (stops == 0 && ratio > 0)
				{
					gradient.addColorStop(0, color.colorString);					
				}
				gradient.addColorStop(ratio, color.colorString);
			}	
			
			var fill:Fill = new GradientFill(gradient);
			vo.fills.push(fill);
		}	
		flushBits();
	}
	private function parseSolidFills(vo:VexObject):Void
	{	
		fillIndexNBits = readNBits(8);
		var nBits:Int = readNBitCount();
		var count:Int = readNBits(11);		
		for (i in 0...count)
		{
			var color : Color = Color.fromAFlipRGB(readNBits(nBits));
			var fill:SolidFill = new SolidFill(color);
			vo.fills.push(fill);
		}	
		flushBits();
	}
	private function parseStrokes(vo:VexObject):Void
	{		
		strokeIndexNBits = readNBits(8);
		// stroke colors
		var colorNBits:Int = readNBitCount();
		var lineWidthNBits = readNBitCount();
		var count:Int = readNBits(11);		
		for (i in 0...count)
		{
			var col:Color = Color.fromAFlipRGB(readNBits(colorNBits));
			var lw:Float = readNBits(lineWidthNBits) / twips;
			var stroke:Stroke = new Stroke(col, lw);
			vo.strokes.push(stroke);
		}		
		
		flushBits();
	}
	private function flushBits() : Void
	{
		if (bit != 8)
		{
			bit = 8;
			index++;
		}
		
		if ((index % 4) != 0)
		{
			index += 4 - (index % 4);
		}
	}
	private inline function readByte() : Int
	{
		return cast data[index++];
	}
	private inline function readBit() : Bool
	{
		return readNBits(1) == 1 ? true : false;
	}
	
	private function readNBitCount() : Int
	{
		var result:Int = readNBits(5);
		return result + 2;
	}
	private function readNBitRect() : Rectangle
	{
		var nBits:Int = readNBitCount();
		var result = new Rectangle
		(
			readNBitInt(nBits) / twips,
			readNBitInt(nBits) / twips,
			readNBitInt(nBits) / twips,
			readNBitInt(nBits) / twips
		);
		return result;
	}
	private function readNBitInt(nBits:Int) : Int
	{
		var result:Int;
		var bitMask:Int = Std.int(Math.pow(2, bit - 1));
		if (data[index] & bitMask != 0)
		{
			result = readNBits(nBits, -1);			
		}
		else
		{
			result = readNBits(nBits);
		}	
		return result;
	}
	
	private function readNBits(nBits:Int, ?result:Int = 0) : Int
	{
		var addingVal:Int;
		var dif:Int;
		var mask:Int;
		
		while (nBits > 0)
		{
			if (bit > nBits)
			{
				dif = bit - nBits;
				mask = maskArray[nBits] << dif;
				addingVal = (data[index] & mask) >>> dif;
				result = (result << nBits) + addingVal;
				bit -= nBits;
				nBits = 0;
			}
			else
			{
				mask = maskArray[bit];				
				addingVal = (data[index++] & mask);
				result = (result << bit) + addingVal;
				nBits -= bit;	
				bit = 8;
			}
		}
		return result;
	}
   
      
   
}