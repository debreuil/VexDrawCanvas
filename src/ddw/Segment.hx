package ddw;

class Segment 
{
	public var segmentType:SegmentType;
	public var points:Array<Float>;
	
	public function new() 
	{		
		points = [];
	}	
	
	public static function parseVexSegment(seg:String):Segment
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