package pano.extras
{
	import pano.core.*
	import pano.controls.ExtraManager;
	import flash.display.Sprite;
    import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.Event;

    final public class KeyboardManager extends EventDispatcher implements IExtra
    {
		public static const VER:Number = 1.0;
		
        private var _pano:Pano;
		private var EIF:ExtraManager;
		private var _disable:Boolean = false;
		
        public function KeyboardManager(p:ExtraManager,v:Array):void
        {
            _pano = v[0]; EIF = p;
			EIF.set("disableKeyBoard",disable)
			regListeners();

        }
		
		private var keyDown:Boolean = false;
        private function regListeners():void
        {
			_pano.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
            _pano.stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler, false, 0, true);
			//trace(_pano.stage);
        }

        private function keyUpHandler(e:KeyboardEvent):void
        {
  			if(_disable) return ;
			keyDown = false; _pano.killTween();
			_pano.render();
        }

        private function keyDownHandler(e:KeyboardEvent):void
        {
			if(_pano.tweening) return;
			if(_disable) return ;
			if(keyDown) return;
			keyDown = true;
			switch(e.keyCode)
			{
				//up
				case 38:
					EIF.get("toforward")();
					break;
				//down
				case 40:
					EIF.get("toback")();
					break;
				//left
				case 37:
					_pano.toLeft();
					break;
				case 39:
					_pano.toRight();
					break;
				case 107:
					_pano.zoomTo(true);
					break;
				case 109:
					_pano.zoomTo(false);
					break;
				default:
					break;
				
				
			}
			
			trace("code"+e.keyCode);
			
		
        }
		public function disable(v:Boolean = false):void
		{
			_disable = v;
		}
		
		public function resize():void{}

       
    }
}
