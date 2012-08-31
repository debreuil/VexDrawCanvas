package ddw;

import HTML5Dom;
import js.Dom;
import js.Lib;

	
class VexDrawBinaryReader 
{
	private var data:Uint8Array;
	private var index:Int;
	private var bit:Int;
	
	private var fillIndexNBits:Int;
	private var strokeIndexNBits:Int;
	
	private var twips:Int = 32;
	private var maskArray:Array<Int>;
		
	public function new(path:String, vo:VexObject, onParseComplete:Dynamic)
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
				index = 0;
				bit = 8;
				parseTag(vo);
				onParseComplete();
			}
		}
		xhr.send();
	}
	
	private function parseTag(vo:VexObject) : Void
	{
		while (index < data.length)
		{
			var tag:Int = readByte();		
			
			switch(tag)
			{
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
					
				case VexDrawTag.End:		
					break;					
			}
		}	
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
				var mxNBits:Int = readNBitValue();
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
	
	private function parseSymbol(vo:VexObject):Symbol
	{	
		var result:Symbol = new Symbol();
		result.id = readNBits(32);
		
		// todo: name
				
		result.bounds = readNBitRect();
		
		var shapesCount:Int = readNBits(11);	
		for (i in 0...shapesCount)
		{
			var strokeIndex:Int = readNBits(strokeIndexNBits);	
			var fillIndex:Int = readNBits(fillIndexNBits);		
			var shape:Shape = new Shape(strokeIndex, fillIndex);
			
			var nBits:Int = readNBitValue();
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
						seg.segmentType = SegmentType.moveTo;
					case 1:
						seg.segmentType = SegmentType.lineTo;
					case 2:
						seg.segmentType = SegmentType.quadraticCurveTo;
						seg.points.push(readNBitInt(nBits) / twips);		
						seg.points.push(readNBitInt(nBits) / twips);
					case 3:
						seg.segmentType = SegmentType.bezierCurveTo;
						seg.points.push(readNBitInt(nBits) / twips);		
						seg.points.push(readNBitInt(nBits) / twips);
						seg.points.push(readNBitInt(nBits) / twips);		
						seg.points.push(readNBitInt(nBits) / twips);
				}
				shape.segments.push(seg);
			}
			result.shapes.push(shape);
		}
		
		flushBits();
		return result;
	}
	
	private function parseGradientFills(vo:VexObject):Void
	{	
		var cv:HTMLCanvasElement = cast Lib.document.createElement('canvas');
		var g:CanvasRenderingContext2D = cv.getContext("2d");	
		
		var padding:Int = readNBitValue();
		var gradientCount:Int = readNBits(11);		
		for (gc in 0...gradientCount)
		{
			// type:i byte, stopColors[...]<Int>, stopRatios[...]<Int>, matrix[6]<Int>
			
			var type:Int = readNBits(3);
			
			var lineNBits:Int = readNBitValue();
			var tlX:Float = readNBitInt(lineNBits) / twips;
			var tlY:Float = readNBitInt(lineNBits) / twips;
			var trX:Float = readNBitInt(lineNBits) / twips;
			var trY:Float = readNBitInt(lineNBits) / twips;
			var gradient:CanvasGradient = g.createLinearGradient(tlX, tlY,trX, trY);
			
			// stop colors
			var colorNBits:Int = readNBitValue();
			var ratioNBits:Int = readNBitValue();
			var count:Int = readNBits(11);				
			for (stops in 0...count)
			{
				var color:Color = Color.fromRGBFlipA(readNBits(colorNBits));
				var ratio:Float = readNBits(ratioNBits) / 255;
				
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
		var nBits:Int = readNBitValue();
		var count:Int = readNBits(11);		
		for (i in 0...count)
		{
			var color : Color = Color.fromRGBFlipA(readNBits(nBits));
			var fill:SolidFill = new SolidFill(color);
			vo.fills.push(fill);
		}	
		flushBits();
	}
	private function parseStrokes(vo:VexObject):Void
	{		
		strokeIndexNBits = readNBits(8);
		// stroke colors
		var colorNBits:Int = readNBitValue();
		var lineWidthNBits = readNBitValue();
		var count:Int = readNBits(11);		
		for (i in 0...count)
		{
			var col:Color = Color.fromRGBFlipA(readNBits(colorNBits));
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
	
	private function readNBitValue() : Int
	{
		var result:Int = readNBits(5);
		result = (result == 0) ? 0 : result + 2;	
		return result;
	}
	private function readNBitRect() : Rectangle
	{
		var nBits:Int = readNBitValue();
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