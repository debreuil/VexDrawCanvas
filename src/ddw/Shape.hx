package ddw;

class Shape 
{
	public var strokeIndex:Int;
	public var fillIndex:Int;
	public var pathIndex:Int;
	
	public function new(strokeIndex:Int, fillIndex:Int, pathIndex:Int) 
	{
		this.strokeIndex = strokeIndex;
		this.fillIndex = fillIndex;
		this.pathIndex = pathIndex;
	}
	
}