package ddw;

using StringTools;

class Color 
{
	public var argb:Int;
	public var colorString:String;
	
	public function new(argb:Int) 
	{
		this.argb = argb;
		colorString = getColorString(argb);
	}
	
	public static function fromRGBFlipA(rgbfa:Int):Color
	{
		var a:Int = (0xFF - ((rgbfa & 0xFF000000) >>> 24)) << 24;
		var rgb = rgbfa & 0xFFFFFF;
		return new Color(a + rgb);
	}
	
	public function getColorHex():String
	{
		var result:String;
		var a:Int = (argb & 0xFF000000) >>> 24;
		var r:Int = (argb & 0xFF0000) >>> 16;
		var g:Int = (argb & 0x00FF00) >>> 8;
		var b:Int = (argb & 0x0000FF);
		
		result = a.hex() + "" + r.hex() + "" + g.hex() + "" + b.hex();
		
		return result;		
	}
	public static function getColorString(value):String
	{
		var result:String;
		var a:Int = (value & 0xFF000000) >>> 24;
		var r:Int = (value & 0xFF0000) >>> 16;
		var g:Int = (value & 0x00FF00) >>> 8;
		var b:Int = (value & 0x0000FF);
		var vals:String = r + "," + g + "," + b;
		
		if(a < 255)
		{
			result = "rgba(" + vals + "," + a + ")";
		}
		else
		{
			result = "rgb(" + vals + ")";
		}
		return result;
	}
}