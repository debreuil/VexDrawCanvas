package ddw;

import HTML5Dom;

class GradientFill extends Fill
{
	private var gradient:CanvasGradient;
	
	public function new(gradient:CanvasGradient) 
	{
		this.gradient = gradient;
		this.isGradient = true;
		this.canvasFill = gradient;
	}
	
	function toString():String
	{
		return "gradient";
	}
}