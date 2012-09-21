package ddw;
import haxe.Stack;
import js.Lib;
import HTML5Dom;

class VexObject 
{
	public var fills:Array<Fill>;
	public var strokes:Array<Stroke>;
	
	public var definitionNameTable:IntHash<String>;
	public var instanceNameTable:IntHash<String>;
	
	public var definitions:IntHash<Definition>;
	
	public var timelineStack:Array<Dynamic>;
	
	public var gradientStart:Int = 0;
	
	var boxSize:Int = 25;
	
	public function new() 
	{	
		this.fills = new Array<Fill>();
		this.strokes = new Array<Stroke>();
		this.definitionNameTable = new IntHash<String>();
		this.instanceNameTable = new IntHash<String>();
		
		this.definitions = new IntHash<Definition>();
		
		timelineStack = new Array<Dynamic>();
		timelineStack.push(untyped document.body);
	}	
	
	public function parseJson(json:Dynamic, onParseComplete:Dynamic = null):Void
	{
		var vdbr = new VexDrawJsonReader(json, this, onParseComplete);
	}
	
	public function parseBinaryFile(path:String, onParseComplete:Dynamic):Void
	{
		var vdbr = new VexDrawBinaryReader(path, this, onParseComplete);
	}
		
	
	public function pushDiv(id:String):HTMLDivElement
	{
		var div:HTMLDivElement = cast Lib.document.createElement('div');
		div.id = id;	
		
		timelineStack[0].appendChild(div);
		timelineStack.unshift(div);
		
		return div;
	}
	public function popDiv():Void
	{
		timelineStack.shift();
	}
	
	public function createCanvas(id:String, width:Int, height:Int):HTMLCanvasElement
	{
		var canvas:HTMLCanvasElement = untyped document.createElement('canvas');
		canvas.id = id;
		canvas.width = width;
		canvas.height = height;	
		
		untyped timelineStack[0].appendChild(canvas);		
		return canvas;
	}
	
	public function transformObject(obj:Element, instance:Instance, offsetX:Float, offsetY:Float) 
	{	
		if (instance.x != 0 || instance.y != 0 || offsetX != 0 || offsetY != 0)
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
	}
	
	public function drawTimeline(index:Int)
	{	
		//Timeline: id,name,bounds,instances
		//		instance:defId,x,y,scaleX,scaleY,rotation,shear,name
		var tlDef:Definition = definitions.get(index);
		if(tlDef != null && Std.is(tlDef, Timeline))
		{
			var tl:Timeline = cast tlDef;
			Timeline.drawTimeline(tl, this);
		}
	}
	
	
	public function drawColorTables()
	{	
		var inst:Instance = new Instance(0);
		inst.y = 40;
		
		var i:Int = 0;
		for(stroke in strokes)
		{
			var cv:HTMLCanvasElement = createCanvas("st_" + stroke.lineWidth + "_" + stroke.color.getColorHex(), boxSize, boxSize);
			inst.x = (boxSize + 2) * i++;
			transformObject(cv, inst, 0, 0);	
			var g:CanvasRenderingContext2D = cv.getContext("2d");
			
			g.fillStyle =  fills[0];
			g.lineWidth = stroke.lineWidth;
			g.strokeStyle =  stroke.color.colorString;
			g.strokeRect(0, 0, boxSize, boxSize);	
		}
		
		i = 0;
		var solidCount = 0;
		var gradCount = 0;
		for(fill in fills)
		{
			var id:String = fill.isGradient ? "grad_" + gradCount : "sf_" + cast(fill, SolidFill).color.getColorHex();
			inst.x = fill.isGradient ? (boxSize + 2) * gradCount++ : (boxSize + 2) * solidCount++;
			inst.y = fill.isGradient ? 100 : 70;
			
			var cv:HTMLCanvasElement = createCanvas(id, boxSize, boxSize);				
			transformObject(cv, inst, 0, 0);	
			var g:CanvasRenderingContext2D = cv.getContext("2d");
			g.fillStyle = fill.canvasFill;
			g.fillRect(0, 0, boxSize, boxSize);				
		}
	}
	
}