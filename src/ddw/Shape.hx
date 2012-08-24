package ddw;

class Shape 
{
	public var strokeIndex:Int;
	public var fillIndex:Int;
	public var segments:Array<Segment>;
	
	public function new(strokeIndex:Int, fillIndex:Int) 
	{
		this.strokeIndex = strokeIndex;
		this.fillIndex = fillIndex;
		segments = new Array<Segment>();
	}
	
}