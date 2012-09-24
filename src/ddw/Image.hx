package ddw;

import HTML5Dom;
import js.Dom;
import js.Lib;

typedef ImageDrawData =
{ 
    var g:CanvasRenderingContext2D; 
    var metrics:Instance; 
} 

class Image extends Definition
{
    private var path:String;
    public var pathId:Int;
	
	private var img:HTMLImageElement;	
	private var isLoaded:Bool;
	private var pendingDraws:Array<ImageDrawData>;
	
	public function new() 
	{		
		super();
		isTimeline = false;
		pendingDraws = new Array();
	}
	
	public function setPath(p:String)
	{
		this.isLoaded = false;
		this.path = p;
		
		var doc : HTMLDocument = cast js.Lib.document;
		img = cast doc.createElement('img');
		img.onload = function (_)
		{
			this.isLoaded = true;
			drawPending();
		};
		img.src = p;
	}
	
	public function draw(g:CanvasRenderingContext2D, metrics:Instance)
	{
		if (isLoaded)
		{
			g.drawImage(img, 0, 0, metrics.scaleX * bounds.width, metrics.scaleY * bounds.height);
		}
		else
		{
			var idd:ImageDrawData = {g:g, metrics:metrics};
			pendingDraws.push(idd);
		}
	}
	public function drawPending()
	{
		if (isLoaded)
		{
			for(idd in pendingDraws)
			{
				draw(idd.g, idd.metrics);
			}
		}
		pendingDraws = new Array();
	}
	
	public static function drawImage(img:Image, metrics:Instance, vo:VexObject)
	{		
		var bnds:Rectangle = img.bounds;
		var offsetX:Float = -bnds.x * metrics.scaleX;
		var offsetY:Float = -bnds.y * metrics.scaleY;
		
		var cv:HTMLCanvasElement = vo.createCanvas(metrics.name, cast (bnds.width * metrics.scaleX), cast (bnds.height * metrics.scaleY));
		//vo.transformObject(cv, metrics, offsetX, offsetY);			
		var g:CanvasRenderingContext2D = cv.getContext("2d");	
		
		img.draw(g, metrics);
	}
	
}