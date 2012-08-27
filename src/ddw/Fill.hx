package ddw;

import HTML5Dom;

class Fill 
{
	public var isGradient:Bool;
	public var canvasFill:Dynamic;
	
	public var color:Color;
	private var gradient:CanvasGradient;
	
	public function new() 
	{		
	}
	
	public static function parseVexFill(fill:Dynamic, g:CanvasRenderingContext2D):Fill
	{		
		var result:Fill = new Fill();
		
		if(Std.is(fill, Array))
		{
			// gradient
			// ["L",[-17.98,82.54,-79.42,-77.04],[4280796160,0,4291297159,0.39]],
			
			result.isGradient = true;
			
			var gradKind:String = fill[0]; // "L" or "R"
			var tlbr:Array<Float> = fill[1];
			var gradStops:Array<Int> = fill[2];
			
			result.gradient = g.createLinearGradient(tlbr[0], tlbr[1], tlbr[2], tlbr[3]);
			var gs:Int = 0;
			while(gs < gradStops.length)
			{
				var col:String = Color.getColorString(gradStops[gs]);
				result.gradient.addColorStop(gradStops[gs + 1], col);
				gs += 2;
			}    
			result.canvasFill = result.gradient;
		}
		else
		{
			// solid fill
			result.isGradient = false;
			result.color = new Color(fill);
			result.canvasFill = result.color.colorString;
		}
		
		return result;
	}
	
}