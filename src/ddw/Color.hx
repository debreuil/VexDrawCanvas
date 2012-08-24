package ddw;

class Color 
{
	public var argb:Int;
	public var colorString:String;
	
	public function new(argb:Int) 
	{
		this.argb = argb;
		colorString = getColorString(argb);
	}
	
	//public function getColorString():String
	//{
		//return getColorString(argb);
	//}
	
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