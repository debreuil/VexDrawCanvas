package js;
import js.Dom;
import js.CanvasContex;

// this is from the excellent Plotex proejct http://code.google.com/p/plotex/
typedef HtmlCanvas = {> HtmlDom,

	var width : Int;
	var height : Int;
	
	function getContext(contextId:String):CanvasContex;
}