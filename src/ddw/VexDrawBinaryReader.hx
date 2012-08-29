package ddw;

import HTML5Dom;
import js.Dom;
import js.Lib;

	
class VexDrawBinaryReader 
{
	private var data:Uint8Array;
	private var index:Int;
	private var bit:Int;
	
	private var maskArray:Array<Int>;
		
	public function new(path:String, vo:VexObject)
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
			}
		}
		xhr.send();
	}
	
	private function parseTag(vo:VexObject) : Void
	{
		var tag:Int = readByte();		
		parseStrokes(vo);
		
		var fillTag:Int = readByte();			
		parseSolidFills(vo);
		
		var gradientTag:Int = readByte();			
		parseGradientFills(vo);
		
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
			
			var type:Int = readNBits(8);
			
			var tlX:Float = readNBitInt(24) / 20;
			var tlY:Float = readNBitInt(24) / 20;
			var trX:Float = readNBitInt(24) / 20;
			var trY:Float = readNBitInt(24) / 20;
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
		Lib.alert(vo.fills);
	}
	private function parseSolidFills(vo:VexObject):Void
	{	
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
		// stroke colors
		var nBits:Int = readNBitValue();
		var count:Int = readNBits(11);		
		var strokeColors:Array<Int> = new Array<Int>();
		for (i in 0...count)
		{
			strokeColors.push(readNBits(nBits));
		}		
		
		// stroke widths
		nBits = readNBitValue();
		count = readNBits(11);		
		var strokeWidths:Array<Float> = new Array<Float>();
		for (i in 0...count)
		{
			strokeWidths.push(readNBits(nBits) / 20);
		}
		
		for(i in 0...count) 
		{
			var col:Color = Color.fromRGBFlipA(strokeColors[i]);
			var stroke:Stroke = new Stroke(col, strokeWidths[i]);
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
		index += 4 - (index % 4);
	}
	private inline function readByte() : Int
	{
		return cast data[index++];
	}
	
	private function readNBitValue() : Int
	{
		var result:Int = readNBits(5);
		result = (result == 0) ? 0 : result + 2;	
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
   
   
	private function ParseTagX():Array<Int>
	{
		var result = new Array<Int>();
		var calc:Int = bit > 15 ? 
			(data[index] >> (bit - 16)) & 0xFFFF :		
			((data[index] << (16 - bit)) | (data[++index] >>> (bit - 16 + 32))) & 0xFFFF;
		
		var nBits:Int = (calc >> 11) + 2;
		var count:Int = calc & 0x7FF;
		
		if (bit < 16)
		{
			bit+=32;
		}
		bit -= (16 + nBits);
		
		var mask:Int = cast Math.pow(2, nBits) - 1;
		while(count-- >= 0)
		{
			if(bit < 0) 
			{
				bit += 32; 
				result.push( ( (data[index] << (32 - bit)) | (data[++index] >>> bit) ) & mask    );
			}
			else
			{
				result.push( (data[index] >>> bit) & mask );
			}
			bit -= nBits;
		}
		
		bit += nBits;
		
		return result;
   }
   
   
   
   
//prot.ParseBitpacked = function()
//{
	//var count:Int = 0;
	//var nBits:Int = 0; 
	//var df:Int = 0;
//
	//while(df < this.data.length) 
	//{
		//var cm = this._packed[df++];
		//var tp = cm[0] >>> 24; 
		//switch(tp)
		//{
			//case 0x42: 
			//var ptCount = (cm[0] >>>13) & 0x7FF
			//this._nByte = 0;
			//this._nDif = 13;
//
			//while(ptCount--)
			//{
				//var tps = this._gBits(cm);
				//this._paths.push( [tps, this._gBitsN(cm)] );
			//}
			//break;
//
		//case 0x40:
		//var cols = this._gBits(cm, 0, 24);
		//for(var i = 0; i < cols.length; i++)
		//{
		//this._colors.push( cols[i]&0xFF000000 ? 
		//[cols[i]&0xFFFFFF, ((~cols[i])>>>24)/2.55]:[cols[i],100]);
		//}
		//break;
//
		//case 0x41: 
		//var cols = this._gBits(cm, 0, 24);
		//var ws = this._gBits(cm);
		//for(var i = 0; i < ws.length; i++)
		//{
		//this._strokes.push([ws[i]/20, cols[i]&0xFFFFFF, 
		//cols[i]&0xFF000000 ? ((~cols[i])>>>24)/2.55:100] );
		//}
		//break;
//
		//case 0x4C: 
		//var gfCount = (cm[0] >>>13) & 0x7FF
		//this._nByte = 0;
		//this._nDif = 13;
		//while(gfCount--)
		//{
		//if(this._nDif <= 0){this._nDif += 32; this._nByte++;}
		//var grtype = 
		//(cm[this._nByte]&Math.pow(2, --this._nDif))?"radial":"linear";
		//var cols = this._gBits(cm); 
		//var rats = this._gBits(cm); 
		//var ms = this._gBitsN(cm);
		//var rgbs = [];
		//var as = [];
		//for(var i = 0; i < cols.length; i++)
		//{
		//rgbs.push(cols[i]&0xFFFFFF);
		//as.push(cols[i]&0xFF000000 ? ((~cols[i])>>>24)/2.55 : 100);
		//}
		//var mx = {a:ms[0],b:ms[1],c:0,d:ms[2],e:ms[3],f:0,g:ms[4],h:ms[5],i:1};
		//this._colors.push([grtype, rgbs, as, rats, mx]);
		//}
		//break;
//
		//case 0x32:
		//this._uses.push(this._gBits(cm, 0, 24));
		//break;
		//} 
		//} 
		//this._colors[0] = [0,0];
		//this._strokes[0] = [0,0,0];
		//trace( "=== Time to Parse === " );
		//trace( new Date().getTime()-t0 );
		//this._packed = null;
		//this._parsed = true;
	//}
}