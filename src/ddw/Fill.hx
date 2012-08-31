package ddw;

import HTML5Dom;

class Fill 
{
	public var isGradient:Bool;
	public var canvasFill:Dynamic;	
			
	public static function parseVexFill(fill:Dynamic, g:CanvasRenderingContext2D):Fill
	{		
		var result:Fill;
		
		if(Std.is(fill, Array))
		{
			// gradient
			// ["L",[-17.98,82.54,-79.42,-77.04],[4280796160,0,4291297159,0.39]],
						
			var gradKind:String = fill[0]; // "L" or "R"
			var tlbr:Array<Float> = fill[1];
			var gradStops:Array<Int> = fill[2];
			
			var gradient:CanvasGradient = g.createLinearGradient(tlbr[0], tlbr[1], tlbr[2], tlbr[3]);
			var gs:Int = 0;
			while(gs < gradStops.length)
			{
				var col:Color = Color.fromRGBFlipA(gradStops[gs]);
				var colString:String = col.colorString;
				gradient.addColorStop(gradStops[gs + 1], colString);
				gs += 2;
			}    
			result = new GradientFill(gradient);
		}
		else
		{
			// solid fill
			result = new SolidFill(Color.fromRGBFlipA(fill));
		}
		
		return result;
	}
	
	
}