package ddw;

import HTML5Dom;
import js.Dom;

class Instance 
{
	public var definitionId:Int;
	public var name:String;
	public var instanceId:Int;
	
	public var x:Float = 0;
	public var y:Float = 0;
	public var scaleX:Float = 1;
	public var scaleY:Float = 1;
	public var rotation:Float = 0;
	public var shear:Float = 0;
 
	public var hasScale:Bool = false;
	public var hasRotation:Bool = false;
	public var hasShear:Bool = false; 
		
	public static var instanceCounter:Int = 0;

	
	public function new(defId:Int, ?instId:Int) 
	{	
		this.definitionId = defId;
		
		if (instId == null)
		{
			instanceId = instanceCounter++;			
		}
		else
		{
			instanceId = instId;
			if (instanceCounter <= instId)
			{
				instanceCounter = instId + 1;
			}		
		}
	}
		
	public static function drawInstance(inst:Instance, vo:VexObject)
	{				
		var divId:String = (inst.name == null || inst.name == "") ? "inst_" + inst.instanceId : inst.name;
		var div:HTMLDivElement = vo.pushDiv(divId);	
		var offsetX:Float = 0;
		var offsetY:Float = 0;
				
		var def:Definition = vo.definitions.get(inst.definitionId);
		
		if (def != null)
		{
			if(def.isTimeline)
			{
				var tl:Timeline = cast(def, Timeline);
				if (tl.instances.length > 1 || (tl.instances.length == 1 && Std.is(tl.instances[0], Timeline) ))
				{
					Timeline.drawTimeline(cast(def, Timeline), vo);
				}
				else
				{
					var symbol:Symbol = cast(vo.definitions.get(tl.instances[0].definitionId), Symbol);
					var bnds:Rectangle = symbol.bounds;
					offsetX = -bnds.x * inst.scaleX;
					offsetY = -bnds.y * inst.scaleY;
					
					Symbol.drawSymbol(symbol, inst, vo);
				}
			}
			else if(Std.is(def, ddw.Image))
			{
				var img:ddw.Image = cast(vo.definitions.get(def.id), ddw.Image);
				var bnds:Rectangle = img.bounds;
				offsetX = -bnds.x * inst.scaleX;
				offsetY = -bnds.y * inst.scaleY;
				
				ddw.Image.drawImage(img, inst, vo);
			}
			else
			{
				// shouldn't normally happen, symbols are wraped in single element timelines
				Symbol.drawSymbol(cast(def, Symbol), inst, vo);
			}
		}
		
		vo.transformObject(div, inst, offsetX, offsetY);
		
		vo.popDiv();
	}
	
}