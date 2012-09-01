package ddw;

import HTML5Dom;

class Symbol extends Definition
{
	public var shapes:Array<Shape>;
		
	public function new() 
	{		
		super();
		isTimeline = false;
		shapes = new Array<Shape>();
	}	
		
	public static function drawSymbol(symbol:Symbol, metrics:Instance, vo:VexObject)
	{				
		var bnds:Rectangle = symbol.bounds;
		var offsetX:Float = -bnds.x * metrics.scaleX;
		var offsetY:Float = -bnds.y * metrics.scaleY;
		
		var cv:HTMLCanvasElement = vo.createCanvas(metrics.name, cast (bnds.width * metrics.scaleX), cast (bnds.height * metrics.scaleY));
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
			
			g.beginPath();
			for(seg in shape.segments)
			{
				switch(seg.segmentType)
				{
					case SegmentType.moveTo:	
						g.moveTo(seg.points[0], seg.points[1]);
						
					case SegmentType.lineTo:	
						g.lineTo(seg.points[0], seg.points[1]);	
						
					case SegmentType.quadraticCurveTo:	
						g.quadraticCurveTo(seg.points[0], seg.points[1], seg.points[2], seg.points[3]);
						
					case SegmentType.bezierCurveTo:	
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