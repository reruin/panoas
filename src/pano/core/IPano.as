package pano.core {
	import flash.events.IEventDispatcher;
	import flash.display.DisplayObject;
	public interface IPano extends IEventDispatcher {
		//function get map () : DisplayObject;
		function toRight () : void;
		function toLeft () : void;
		function toUp () : void;
		function toDown () : void;
		function toRound () : void;
		function getHeading(v:Boolean = false):Number;
		function getPitch():Number;
		/*function toForward():void;
		function toBack():void;*/
		function zoomOut () : void;
		function zoomIn () : void;
		function zoomTo(toMax:Boolean = true):void;
		function fullScreen():void;
		function killTween():void;
		
	}
}
