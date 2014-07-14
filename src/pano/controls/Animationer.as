package  pano.controls{
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Matrix;


	import flash.events.EventDispatcher;
	import pano.core.Pano;
	import pano.core.Stack;

	import pano.utils.TweenNano;
	/**
	 * ...
	 * @author ... tiny
	 */
	 
	
	
	public class Animationer extends EventDispatcher
	{
		public var _displayObject:Bitmap;
		private var _rect:Rectangle;
		private var _pano:Pano;
		private var _lastrot:Number = 0;
		private var _currot:Number = 0;
		
		private var dz:Number = 0;
		private var dx:Number = 0;
		
		public var endAnimate:Boolean = false;
		public function Animationer(d:Bitmap , pano)
		{
			_displayObject = d; _pano = pano;
		}
		
		private var bitmap:Bitmap;
		
		//第一次动画
		public function play(o:Object):void
		{
			endAnimate = false ;
			_displayObject.stage.quality = "LOW";
			_currot = o.fromrot * 3.1415926 / 180;
			var d = o.fromDistance * 80;
			if(d > 1000) d = 1000;
			if(d < -1000) d = 1000;
			dx = 0 - d * Math.sin(_currot)
			dz = 0 - d * Math.cos(_currot);
			
			TweenNano.to(_pano,1,{sz:dz,sx:dx,delay:0,onComplete:complete1Handle,ease:TweenNano.QuintEaseOut});
			
		}
		
		//第二次动画
		public function playToggle():void
		{
			//trace(_displayObject.width + ","+_displayObject.height+", alpha:"+_displayObject.alpha + ",vis:"+_displayObject.visible + ",x="+_displayObject.x+",y="+_displayObject.y)
			//TweenNano.to(_pano,2,{sz:0,sx:0,delay:0.2,onComplete:function(){trace("over")},ease:TweenNano.QuintEaseOut});
			invalidate();
		}
		
		public function render():void{
			// lock bitapdata
			
		}
		
		private function complete1Handle():void
		{
			dispatchEvent(new Event("AnimationToggle"));
			endAnimate = true;
		}
		
		private function complete2Handle():void
		{
			dispatchEvent(new Event("AnimationEnd"));
			//if(stack.face) _pano.faceTo(Stack.face);
		}
		

		public function reset():void{
			//_displayObject.stage.quality = "HIGH";
			_pano.render(true)
			TweenNano.killTweensOf(_displayObject);
		}
		
		protected function invalidate():void
		{
			_displayObject.addEventListener(Event.ENTER_FRAME, onInvalidate);
		}
		
		private function onInvalidate(event:Event):void
		{
			
			_displayObject.removeEventListener(Event.ENTER_FRAME, onInvalidate);
			TweenNano.to(_displayObject,0.4,{alpha:0,onComplete:complete2Handle,ease:TweenNano.MOVE});
			
		}
		
	}
	
}