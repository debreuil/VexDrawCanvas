package ddw;

class VexDrawTag 
{
	public inline static var None:Int = 0x00;
		
	public inline static var Header:Int							= 0x01;
	
	public inline static var StrokeList:Int						= 0x05;
	public inline static var SolidFillList:Int					= 0x06;
	public inline static var GradientFillList:Int				= 0x07;
	
	public inline static var ReplacementSolidFillList:Int		= 0x09;
	public inline static var ReplacementGradientFillList:Int	= 0x0A;
	public inline static var ReplacementStrokeList:Int			= 0x0B;
	
	public inline static var SymbolDefinition:Int				= 0x10;
	public inline static var TimelineDefinition:Int				= 0x11;
	
    public inline static var DefinitionNameTable:Int            = 0x20;
    public inline static var InstanceNameTable:Int              = 0x21;
    public inline static var ColorNameTable:Int                 = 0x22;
    public inline static var PathNameTable:Int                  = 0x23;
	
	public inline static var End:Int							= 0xFF;
	
}