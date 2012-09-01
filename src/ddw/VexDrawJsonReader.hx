package ddw;

import HTML5Dom;
import js.Lib;

class VexDrawJsonReader 
{	
	public function new(json:Dynamic, vo:VexObject, onParseComplete:Dynamic = null)
	{			
		parseJson(json, vo);
		
		if (onParseComplete != null)
		{
			onParseComplete();	
		}
	}
	
	public function parseJson(data:Dynamic, vo:VexObject)
	{		
		// strokes
		var i:Int = 0;
		while(i < data.strokes.length)
		{
			var col:Color = Color.fromAFlipRGB(cast data.strokes[i + 1]);
			var stroke:Stroke = new Stroke(col, data.strokes[i]);
			vo.strokes.push(stroke);
			i += 2;
		}
		
		// fills
		var cv:HTMLCanvasElement = cast Lib.document.createElement('canvas');
		var g:CanvasRenderingContext2D = cv.getContext("2d");		
		var dFills:Array<Dynamic> = cast data.fills;
		for(dFill in dFills)
		{
			var f:Fill = Fill.parseVexFill(dFill, g);
			vo.fills.push(f);
			if (!f.isGradient)
			{
				vo.gradientStart = i + 1;				
			}
		}
		
		// symbols	
		var dSymbols:Array<Dynamic> = cast data.symbols;
		for(dSymbol in dSymbols)
		{
			// "id":2,"name":"","bounds":[-66,-45.95,73,95.2],"shapes":[[][]]	
			// [2,0,"M-49.05,-7.85 C-51.2..."]
			
			var symbol:Symbol = parseSymbol(dSymbol);			
			vo.definitions.set(symbol.id, symbol);	
		}
		
		// timelines			
		var dTimelines:Array<Dynamic> = cast data.timelines;
		for(dtl in dTimelines)
		{			
			var tl:Timeline = parseTimeline(dtl);						
			vo.definitions.set(tl.id, tl);	
			
			if(tl.name != null)
			{
				vo.namedTimelines.set(tl.name, tl);
			}	
		}
	}

	
	public function parseTimeline(dtl:Dynamic):Timeline
	{
		var result:Timeline = new Timeline();
		
		// "id":10,"name":"tripod","bounds":[95,31,120,117],
		// "instances":[...]	
				
		result.isTimeline = true;
		
		result.id = dtl.id;
		result.name = dtl.name;
		result.bounds = new Rectangle(dtl.bounds[0], dtl.bounds[1], dtl.bounds[2], dtl.bounds[3]);
		
		var dInstances:Array<Dynamic> = cast dtl.instances;
		for(dInst in dInstances)
		{
			var inst:Instance = parseInstance(dInst);			
			result.instances.push(inst);
		}
		
		
		return result;
	}
	
	public function parseSymbol(dsym:Dynamic):Symbol
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
				var segment:Segment = parseSegment(seg);
				shape.segments.push(segment);
			}
			symbol.shapes.push(shape);
		}			
		
		return symbol;
	}
	
	public static function parseInstance(dinst:Dynamic):Instance
	{
		// [id,[x,y],[scaleX, scaleY, rotation*, skew*], "name"]
		var result:Instance = new Instance(dinst[0]);				
		
		result.x = dinst[1][0];
		result.y = dinst[1][1];
		
		if(dinst.length > 2 && !Std.is(dinst[2], String))
		{
			var mxComp:Array<Float> = dinst[2];
			
			result.scaleX = mxComp[0];
			result.scaleY = mxComp[1];
			result.hasScale = true;
			
			if(mxComp.length > 2)
			{
				result.rotation = mxComp[2];
				result.hasRotation = true;
			}
			
			if(mxComp.length > 3)
			{
				result.shear = mxComp[3];
				result.hasShear = true;
			}
		}			

		if(dinst.length > 3)
		{
			result.name = dinst[3];
		}
		else if(dinst.length > 2 && Std.is(dinst[2], String))
		{
			result.name = dinst[2];
		}
		else
		{
			result.name = "inst_" + result.instanceId;
		}
		
		return result;
	}
	
	public static function parseSegment(seg:String):Segment
	{		
		var result:Segment = new Segment();
		
		var nums:Array<String> = seg.substring(1).split(",");
		switch(seg.charAt(0))
		{
			case 'M':
				result.segmentType = SegmentType.moveTo;
				result.points = [Std.parseFloat(nums[0]), Std.parseFloat(nums[1])]; 
				
			case 'L':
				result.segmentType = SegmentType.lineTo;
				result.points = [Std.parseFloat(nums[0]), Std.parseFloat(nums[1])]; 
				
			case 'Q':
				result.segmentType = SegmentType.quadraticCurveTo;
				result.points = [Std.parseFloat(nums[0]), Std.parseFloat(nums[1]), Std.parseFloat(nums[2]), Std.parseFloat(nums[3])]; 
				
			case 'C':
				result.segmentType = SegmentType.bezierCurveTo;
				result.points = [Std.parseFloat(nums[0]), Std.parseFloat(nums[1]), Std.parseFloat(nums[2]), Std.parseFloat(nums[3]), Std.parseFloat(nums[4]), Std.parseFloat(nums[5])]; 
				
		}
		return result;
	}
		
}