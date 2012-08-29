package ddw;

class VexDrawTag 
{
	public inline static var None:Int = 0x00;
		
	public inline static var LineTo:Int				= 0x10;
	public inline static var LineToRelative:Int		= 0x11;
	public inline static var CurveTo:Int			= 0x14;
	public inline static var CurveToRelative:Int	= 0x15;
	public inline static var MoveTo:Int				= 0x18;
	public inline static var MoveToRelative:Int		= 0x19;

	public inline static var SolidFill:Int			= 0x20;
	public inline static var GradientFill:Int		= 0x21;
	public inline static var reserved:Int			= 0x22;
	public inline static var Stroke:Int				= 0x23;
	public inline static var EndFill:Int			= 0x28;

	public inline static var BeginFill:Int			= 0x30;
	public inline static var BeginStroke:Int		= 0x31;
	public inline static var InsertPath:Int			= 0x32;
	public inline static var InsertSymbol:Int		= 0x33;
	public inline static var InsertControl:Int		= 0x34;
	public inline static var AttachMovie:Int		= 0x38;

	public inline static var ArgbDefinitions:Int	= 0x40;
	public inline static var StrokeDefinitions:Int	= 0x41;
	public inline static var PathDefinition:Int		= 0x42;
	public inline static var SymbolDefinition:Int	= 0x43;
	public inline static var ControlDefinition:Int	= 0x44;
	public inline static var RGBColorDefs:Int		= 0x48;
	public inline static var RGBStrokeDefs:Int		= 0x49;
	public inline static var RGBAColorDefs:Int		= 0x4A;
	public inline static var RGBAStrokeDefs:Int		= 0x4B;
	public inline static var GradientDefs:Int		= 0x4C;

	public inline static var BeginSprite:Int		= 0x50;
	public inline static var EndSprite:Int			= 0x51;

	public inline static var FillFilter:Int			= 0x60;
	public inline static var StrokeFilter:Int		= 0x61;
	public inline static var PathFilter:Int			= 0x62;
	public inline static var ColorFilter:Int 		= 0x63;
	public inline static var FullFilter:Int 		= 0x64;
	public inline static var CallFunction:Int		= 0x68;
	public inline static var DefineFunction:Int		= 0x69;

	public inline static var Rectangle:Int			= 0xC0;
	public inline static var Ellipse:Int			= 0xC1;
	public inline static var Polygon:Int			= 0xC2;
	public inline static var Arrow:Int				= 0xC3;
}