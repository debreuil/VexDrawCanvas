package ddw;
import haxe.Stack;
import js.Lib;
import HTML5Dom;

class VexObject 
{
	public var fills:Array<Fill>;
	public var strokes:Array<Stroke>;
	
	public var namedTimelines:Hash<Timeline>;
	public var definitions:IntHash<Definition>;
	
	var gradientStart:Int = 0;
	var boxSize:Int = 25;
	private var timelineStack:Array<Dynamic>;

	public function new() 
	{	
		this.fills = new Array<Fill>();
		this.strokes = new Array<Stroke>();
		this.namedTimelines = new Hash<Timeline>();
		this.definitions = new IntHash<Definition>();
		
		this.timelineStack = new Array<Dynamic>();
		this.timelineStack.push(untyped document.body);
	}	
	
	
	public function loadBinaryFile(path:String)
	{		
		var xhr:XMLHttpRequest = untyped __new__("XMLHttpRequest");
		xhr.open('GET', path, true);
		xhr.responseType = 'arraybuffer';

		xhr.onload = function(e:Dynamic):Void
		{
			if (xhr.readyState == 4)
			{
				var u8Array = new Uint8Array(xhr.response);
				Lib.alert(u8Array[1]);
			}
		}
		xhr.send();
	}
	
	public function pushDiv(id:String):HTMLDivElement
	{
		var div:HTMLDivElement = cast Lib.document.createElement('div');
		div.id = id;	
		
		untyped timelineStack[0].appendChild(div);
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
		var cv:HTMLCanvasElement = cast Lib.document.createElement('canvas');
		var g:CanvasRenderingContext2D = cv.getContext("2d");		
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
			var id:String = fill.isGradient ? "grad_" + gradCount : "sf_" + fill.color.getColorHex();
			inst.x = fill.isGradient ? (boxSize + 2) * gradCount++ : (boxSize + 2) * solidCount++;
			inst.y = fill.isGradient ? 100 : 70;
			
			var cv:HTMLCanvasElement = createCanvas(id, boxSize, boxSize);				
			transformObject(cv, inst, 0, 0);	
			var g:CanvasRenderingContext2D = cv.getContext("2d");
			g.fillStyle = fill.canvasFill;
			g.fillRect(0, 0, boxSize, boxSize);				
		}
		//for(var i = 0; i < fills.length; i++)
		//{
			//if(i < gradientStart)
			//{
				//var cv = createContext(boxSize, boxSize);
				//var g = cv.getContext("2d");			
				//g.fillStyle = fills[i];
				//g.fillRect(0, 0, boxSize, boxSize);			
				//transformObject(cv,{x:(boxSize + 2) * i, y:70}, 0, 0);
			//}
			//else
			//{
				//var cv = createContext(boxSize, boxSize);
				//var g = cv.getContext("2d");
				//g.fillStyle = fills[i];
				//g.fillRect(0, 0, boxSize, boxSize);
				//transformObject(cv, {x:(boxSize + 2) * (i - gradientStart + 1), y:100}, 0, 0);
			//}
		//}
	}
	
}