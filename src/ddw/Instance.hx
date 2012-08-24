package ddw;

class Instance 
{
	public var defId:Int;
	public var name:String;
	
	public var x:Float = 0;
	public var y:Float = 0;
	public var scaleX:Float = 1;
	public var scaleY:Float = 1;
	public var rotation:Float = 0;
	public var shear:Float = 0;
 
	public var hasScale:Bool = false;
	public var hasRotation:Bool = false;
	public var hasShear:Bool = false; 
	
	public function new(defId:Int) 
	{	
		this.defId = defId;
	}
	
	public static function parseVexData(dinst:Dynamic):Instance
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
			result.name = "";
		}
		
		return result;
	}
	
}