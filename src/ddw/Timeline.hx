package ddw;

import js.Dom;

class Timeline extends Definition
{
	public var name:String;	
	public var instances:Array<Instance>;
	
	public function new() 
	{	
		super();
		isTimeline = true;
		instances = new Array<Instance>();
	}	
		
	public static function drawTimeline(tl:Timeline, vo:VexObject)
	{				
		for(inst in tl.instances)
		{
			Instance.drawInstance(inst, vo);
		}
	}
}