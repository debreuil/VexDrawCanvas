package ddw;

class SolidFill extends Fill
{
	public var color:Color;
	
	public function new(color:Color) 
	{
		this.color = color;
		this.isGradient = false;
		this.canvasFill = color.colorString;
	}
	
	function toString():String
	{
		return color.getColorHex();
	}
}