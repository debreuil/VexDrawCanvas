package ddw;

class Timeline extends Definition
{
	public var name:String;
	
	public var x:Int;
	public var y:Int;
	public var rotation:Float;
	public var shear:Float;
	
	public var hasRotation:Bool;
	public var hasShear:Bool;
	public var instances:Array<Instance>;
	
	public function new() 
	{	
		super();
		instances = new Array<Instance>();
	}	
	
	public static function parseVexData(dtl:Dynamic):Timeline
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
			var inst:Instance = Instance.parseVexData(dInst);			
			result.instances.push(inst);
		}
		
		
		return result;
	}
	
	public static function drawTimeline(tl:Timeline, parent:Instance, vo:VexObject)
	{	
		var bnds:Rectangle = tl.bounds;
		var offsetX:Float = -bnds.x;
		var offsetY:Float = -bnds.y;
		
		for(inst in tl.instances)
		{
			var def:Definition = vo.definitions.get(inst.defId);
			if(def.isTimeline)
			{
				drawTimeline(cast def, inst, vo);
			}
			else
			{
				Symbol.drawSymbol(cast def, parent, vo);
			}
		}
	}
}