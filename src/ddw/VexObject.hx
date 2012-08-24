package ddw;
import js.CanvasContex;
import js.Dom;
import js.HtmlCanvas;
import js.Lib;

class VexObject 
{
	public var fills:Array<Fill>;
	public var strokes:Array<Stroke>;
	
	public var namedTimelines:Hash<Timeline>;
	public var definitions:IntHash<Definition>;
	
	var gradientStart:Int = 0;
	var boxSize:Int = 25;

	public function new() 
	{	
		this.fills = new Array<Fill>();
		this.strokes = new Array<Stroke>();
		this.namedTimelines = new Hash<Timeline>();
		this.definitions = new IntHash<Definition>();
	}	
	
	public function createCanvas(width, height):HtmlCanvas
	{
		var canvas:HtmlCanvas = untyped document.createElement('canvas');
		canvas.width = width;
		canvas.height = height;	
		untyped document.body.appendChild(canvas);		
		return canvas;
	}
	
	public function transformObject(obj:HtmlCanvas, instance:Instance, offsetX:Float, offsetY:Float) 
	{	
		var orgTxt:String = offsetX + "px " + offsetY + "px";
		untyped obj.style["WebkitTransformOrigin"] = orgTxt;
		untyped obj.style["msTransformOrigin"] = orgTxt;
		untyped obj.style["OTransformOrigin"] = orgTxt;
		untyped obj.style["MozTransformOrigin"] = orgTxt;
			
		var trans:String = "";			
		var orgX:Float = instance.x - offsetX;
		var orgY:Float = instance.y - offsetY;
		trans += "translate(" + orgX + "px," + orgY + "px)";
		
		if(instance.hasShear)
		{
			trans += "skewX(" + instance.shear + ") ";
		}	
		if(instance.hasRotation)
		{
			trans += "rotate(" + instance.rotation + "deg) ";
		}	
		//if(instance.hasScale)
		//{
		//	trans += "scale(" + instance.scaleX + "," + instance.scaleY + ") ";
		//}	

		untyped obj.style["WebkitTransform"] = trans;
		untyped obj.style["msTransform"] = trans;
		untyped obj.style["OTransform"] = trans;	
		untyped obj.style['MozTransform'] = trans;
	}
	
	public function parseVex(data:Dynamic)
	{
		// strokes
		var i:Int = 0;
		while(i < data.strokes.length)
		{
			var col:Color = new Color(cast data.strokes[i + 1]);
			var stroke:Stroke = new Stroke(col, data.strokes[i]);
			strokes.push(stroke);
			i += 2;
		}
		
		// fills
		var dom:Document = Lib.document;
		var cv:HtmlCanvas = cast dom.createElement('canvas');
		var g:CanvasContex = cv.getContext("2d");		
		var dFills:Array<Dynamic> = cast data.fills;
		for(dFill in dFills)
		{
			var f:Fill = Fill.parseVexFill(dFill, g);
			fills.push(f);
			if (!f.isGradient)
			{
				gradientStart = i + 1;				
			}
		}
		
		// symbols	
		var dSymbols:Array<Dynamic> = cast data.symbols;
		for(dSymbol in dSymbols)
		{
			// "id":2,"name":"","bounds":[-66,-45.95,73,95.2],"shapes":[[][]]	
			// [2,0,"M-49.05,-7.85 C-51.2..."]
			
			var symbol:Symbol = Symbol.parseVex(dSymbol);			
			definitions.set(symbol.id, symbol);	
		}
		
		// timelines			
		var dTimelines:Array<Dynamic> = cast data.timelines;
		for(dtl in dTimelines)
		{			
			var tl:Timeline = Timeline.parseVexData(dtl);						
			definitions.set(tl.id, tl);	
			
			if(tl.name != null)
			{
				namedTimelines.set(tl.name, tl);
			}	
		}
	}

	public function drawTimeline(index:Int, parent:Instance)
	{	
		//Timeline: id,name,bounds,instances
		//		instance:defId,x,y,scaleX,scaleY,rotation,shear,name
		var tlDef:Definition = definitions.get(index);
		if(tlDef != null && Std.is(tlDef, Timeline))
		{
			var tl:Timeline = cast tlDef;
			Timeline.drawTimeline(tl, null, this);
		}
	}
	
}