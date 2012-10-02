package ddw;

import HTML5Dom;

class Symbol extends Definition
{
	public var paths:Array<Path>;
	public var shapes:Array<Shape>;
		
	public function new() 
	{		
		super();
		isTimeline = false;
		paths = new Array<Path>();
		shapes = new Array<Shape>();
	}	
		
	public static function drawSymbol(symbol:Symbol, metrics:Instance, vo:VexObject)
	{				
		var bnds:Rectangle = symbol.bounds;
		var offsetX:Float = -bnds.x * metrics.scaleX;
		var offsetY:Float = -bnds.y * metrics.scaleY;
		
		var divId:String = (metrics.name == null || metrics.name == "") ? "cv_" + metrics.instanceId : "cv_" + metrics.name;
		var cv:HTMLCanvasElement = vo.createCanvas(divId, cast (bnds.width * metrics.scaleX), cast (bnds.height * metrics.scaleY));
		//vo.transformObject(cv, metrics, offsetX, offsetY);			
		var g:CanvasRenderingContext2D = cv.getContext("2d");	
		
		g.translate(offsetX, offsetY);
		
		if(metrics.hasScale)
		{
			g.scale(metrics.scaleX, metrics.scaleY);
		}
		
		for (shape in symbol.shapes)
		{		
			g.fillStyle = vo.fills[shape.fillIndex].canvasFill;
			g.lineWidth = vo.strokes[shape.strokeIndex].lineWidth;
			g.strokeStyle = vo.strokes[shape.strokeIndex].color.colorString;
			
			var path:Path = symbol.paths[shape.pathIndex];
			
			g.beginPath();
			for(seg in path.segments)
			{
				switch(seg.segmentType)
				{
					case SegmentType.MoveTo:	
						g.moveTo(seg.points[0], seg.points[1]);
						
					case SegmentType.LineTo:	
						g.lineTo(seg.points[0], seg.points[1]);	
						
					case SegmentType.QuadraticCurveTo:	
						g.quadraticCurveTo(seg.points[0], seg.points[1], seg.points[2], seg.points[3]);
						
					case SegmentType.BezierCurveTo:	
						g.bezierCurveTo(seg.points[0], seg.points[1], seg.points[2], seg.points[3], seg.points[4], seg.points[5]);
				}
			}
			//g.closePath();
			
			if(shape.fillIndex > 0)
			{
				g.fill();
			}
			
			if(shape.strokeIndex > 0)
			{
				g.stroke();
			}
			
		}
			
	}

}