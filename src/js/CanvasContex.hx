package js;
import js.Dom;
import js.HtmlCanvas;

// this is from the excellent Plotex project http://code.google.com/p/plotex/
extern class CanvasContex
{
	// back-reference to the canvas
	public var canvas(default,null):HtmlCanvas;

	// state
	public function save():Void; // push state on state stack
	public function restore():Void; // pop state stack and restore state

	// transformations (default transform is the identity matrix)
	public function scale(x:Float, y:Float):Void;
	public function rotate(angle:Float):Void;
	public function translate(x:Float, y:Float):Void;
	public function transform(m11:Float, m12:Float, m21:Float, m22:Float, dx:Float, dy:Float):Void;
	public function setTransform(m11:Float, m12:Float, m21:Float, m22:Float, dx:Float, dy:Float):Void;

	// compositing
	public var globalAlpha:Float;// (default 1.0)
	public var globalCompositeOperation:String; // (default source-over)

	// colors and styles
	public var strokeStyle:Dynamic; // (default black)
	public var fillStyle:Dynamic; // (default black)
	public function createLinearGradient(x0:Float, y0:Float, x1:Float, y1:Float):CanvasGradient;
	public function createRadialGradient(x0:Float, y0:Float, r0:Float, x1:Float, y1:Float, r1:Float):CanvasGradient;
	public function createPattern(image:HtmlCanvas, repetition:String):CanvasPattern;

	// line caps/joins
	public var lineWidth:Float; // (default 1)
	public var lineCap:String; // "butt", "round", "square" (default "butt")
	public var lineJoin:String; // "round", "bevel", "miter" (default "miter")
	public var miterLimit:Float; // (default 10)

	// shadows
	public var shadowOffsetX:Float; // (default 0)
	public var shadowOffsetY:Float; // (default 0)
	public var shadowBlur:Float; // (default 0)
	public var shadowColor:String; // (default transparent black)

	// rects
	public function clearRect(x:Float, y:Float, w:Float, h:Float):Void;
	public function fillRect(x:Float, y:Float, w:Float, h:Float):Void;
	public function strokeRect(x:Float, y:Float, w:Float, h:Float):Void;

	// path API
	public function beginPath():Void;
	public function closePath():Void;
	public function moveTo(x:Float, y:Float):Void;
	public function lineTo(x:Float, y:Float):Void;
	public function quadraticCurveTo(cpx:Float, cpy:Float, x:Float, y:Float):Void;
	public function bezierCurveTo(cp1x:Float, cp1y:Float, cp2x:Float, cp2y:Float, x:Float, y:Float):Void;
	public function arcTo(x1:Float, y1:Float, x2:Float, y2:Float, radius:Float):Void;
	public function rect(x:Float, y:Float, w:Float, h:Float):Void;
	public function arc(x:Float, y:Float, radius:Float, startAngle:Float, endAngle:Float, anticlockwise:Bool):Void;
	public function fill():Void;
	public function stroke():Void;
	public function clip():Void;
	public function isPointInPath(x:Float, y:Float):Bool;

	// drawing images
	public function drawImage(image:Dynamic, ?sx:Float, ?sy:Float, ?sw:Float, ?sh:Float, ?dx:Float, ?dy:Float, ?dw:Float, ?dh:Float):Void;

	// pixel manipulation
	public function getImageData(sx:Float, sy:Float, sw:Float, sh:Float):ImageData;
	public function putImageData(imagedata:ImageData, dx:Float, dy:Float):Void;

}

typedef CanvasPattern = {
}

typedef CanvasGradient = {
	function addColorStop(offset:Float, color:String):Void;
}

typedef ImageData ={
	var width(default,null):Int;
	var height(default,null):Int;
	var data(default,null):Array<Int>;
}
