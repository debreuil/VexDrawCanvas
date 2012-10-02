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
	
	public function parseJson(data:Dynamic, vo:VexObject, onParseComplete:Dynamic = null)
	{		
		// definition name table is <string, int>
		var dDefNames:Array<Dynamic> = cast data.definitionNameTable;
		for(def in dDefNames)
		{			
			vo.definitionNameTable.set(def[1], def[0]);	
		}
		
		// instance name table is <int, string>
		var dInstNames:Array<Dynamic> = cast data.instanceNameTable;
		for(inst in dInstNames)
		{
			vo.instanceNameLookupTable.set(inst[0], inst[1]);
		}
		
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
			var f:Fill = parseFill(dFill, g);
			vo.fills.push(f);
			if (!f.isGradient)
			{
				vo.gradientStart = i + 1;				
			}
		}
		
		// images	
		var dImages:Array<Dynamic> = cast data.images;
		for(dImage in dImages)
		{			
			var img:Image = parseImage(dImage);			
			vo.definitions.set(img.id, img);	
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
				vo.definitionNameTable.set(tl.name, tl.id);	
			}	
		}
		
		if (onParseComplete != null)
		{
			onParseComplete();	
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
	
	public function parseImage(dimg:Dynamic):Image
	{		
		var img:Image = new Image();
		img.id = dimg.id;
		img.bounds = new Rectangle(dimg.sourceRectangle[0], dimg.sourceRectangle[1], dimg.sourceRectangle[2], dimg.sourceRectangle[3]);
		img.setPath(dimg.path);
		return img;
	}		
	
	public function parseSymbol(dsym:Dynamic):Symbol
	{		
		var symbol:Symbol = new Symbol();
		
		symbol.id = dsym.id;
		symbol.bounds = new Rectangle(dsym.bounds[0], dsym.bounds[1], dsym.bounds[2], dsym.bounds[3]);
			
		var dPaths:Array<Dynamic> = cast dsym.paths;
		for(dPath in dPaths)
		{
			var path:Path = new Path();	
			var segs:Array<String> = dPath.split(" ");
			for(seg in segs)
			{
				var segment:Segment = parseSegment(seg);
				path.segments.push(segment);
			}			
			symbol.paths.push(path);
		}
		
		var dShapes:Array<Dynamic> = cast dsym.shapes;
		for(dShape in dShapes)
		{
			var shape:Shape = new Shape(dShape[0], dShape[1], dShape[2]);			
			symbol.shapes.push(shape);
		}			
		
		return symbol;
	}
	
	public static function parseInstance(dinst:Dynamic):Instance
	{
		// [id,[x,y],[scaleX, scaleY, rotation*, skew*], "name"]
		var result:Instance = new Instance(dinst[0],dinst[1]);				
		
		result.x = dinst[2][0];
		result.y = dinst[2][1];
		
		if(dinst.length > 3 && !Std.is(dinst[3], String))
		{
			var mxComp:Array<Float> = dinst[3];
			
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

		if(dinst.length > 4)
		{
			result.name = dinst[4];
		}
		else if(dinst.length > 3 && Std.is(dinst[3], String))
		{
			result.name = dinst[3];
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
				result.segmentType = SegmentType.MoveTo;
				result.points = [Std.parseFloat(nums[0]), Std.parseFloat(nums[1])]; 
				
			case 'L':
				result.segmentType = SegmentType.LineTo;
				result.points = [Std.parseFloat(nums[0]), Std.parseFloat(nums[1])]; 
				
			case 'Q':
				result.segmentType = SegmentType.QuadraticCurveTo;
				result.points = [Std.parseFloat(nums[0]), Std.parseFloat(nums[1]), Std.parseFloat(nums[2]), Std.parseFloat(nums[3])]; 
				
			case 'C':
				result.segmentType = SegmentType.BezierCurveTo;
				result.points = [Std.parseFloat(nums[0]), Std.parseFloat(nums[1]), Std.parseFloat(nums[2]), Std.parseFloat(nums[3]), Std.parseFloat(nums[4]), Std.parseFloat(nums[5])]; 
				
		}
		return result;
	}
			
	public function parseFill(fill:Dynamic, g:CanvasRenderingContext2D):Fill
	{		
		var result:Fill;
		
		if(Std.is(fill, Array))
		{
			// gradient
			// ["L",[-17.98,82.54,-79.42,-77.04],[4280796160,0,4291297159,0.39]],
						
			var gradKind:String = fill[0]; // "L" or "R"			
			var tlbr:Array<Float> = fill[1];
			var gradStops:Array<Int> = fill[2];
			
			var gradient:CanvasGradient;
			if (gradKind == "L")
			{
				gradient = g.createLinearGradient(tlbr[0], tlbr[1], tlbr[2], tlbr[3]);
			}
			else
			{
				var difX:Float = tlbr[2] - tlbr[0];
				var difY:Float = tlbr[3] - tlbr[1];
				var r2:Float = Math.sqrt(difX * difX + difY * difY);
				gradient = g.createRadialGradient(tlbr[0], tlbr[1], 0, tlbr[0], tlbr[1], r2);				
			}
			var gs:Int = 0;
			while(gs < gradStops.length)
			{
				var col:Color = Color.fromAFlipRGB(gradStops[gs]);
				var colString:String = col.colorString;
				gradient.addColorStop(gradStops[gs + 1], colString);
				gs += 2;
			}    
			result = new GradientFill(gradient);
		}
		else
		{
			// solid fill
			result = new SolidFill(Color.fromAFlipRGB(fill));
		}
		
		return result;
	}
}