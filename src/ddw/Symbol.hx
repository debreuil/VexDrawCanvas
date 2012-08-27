package ddw;
import js.CanvasContex;
import js.HtmlCanvas;

class Symbol extends Definition
{
	public var shapes:Array<Shape>;
		
	public function new() 
	{		
		super();
		isTimeline = false;
		shapes = new Array<Shape>();
	}	
	
	public static function parseVex(dsym:Dynamic):Symbol
	{		
		var symbol:Symbol = new Symbol();
		
		symbol.id = dsym.id;
		symbol.bounds = new Rectangle(dsym.bounds[0], dsym.bounds[1], dsym.bounds[2], dsym.bounds[3]);
			
		var dShapes:Array<Dynamic> = cast dsym.shapes;
		for(dShape in dShapes)
		{
			var shape:Shape = new Shape(dShape[0], dShape[1]);
			
			var segs:Array<String> = dShape[2].split(" ");
			for(seg in segs)
			{
				var segment:Segment = Segment.parseVexSegment(seg);
				shape.segments.push(segment);
			}
			symbol.shapes.push(shape);
		}			
		
		return symbol;
	}
	
	public static function drawSymbol(symbol:Symbol, metrics:Instance, vo:VexObject)
	{				
		var bnds:Rectangle = symbol.bounds;
		var offsetX:Float = -bnds.x * metrics.scaleX;
		var offsetY:Float = -bnds.y * metrics.scaleY;
		
		var cv:HtmlCanvas = vo.createCanvas(metrics.name, cast (bnds.width * metrics.scaleX), cast (bnds.height * metrics.scaleY));
		//vo.transformObject(cv, metrics, offsetX, offsetY);			
		var g:CanvasContex = cv.getContext("2d");	
		
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