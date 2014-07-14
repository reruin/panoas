//用于缩放显示大小

package pano.extras
{

	import flash.display.Sprite;
    import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.system.Capabilities;
	import flash.system.Security;
	import flash.display.Stage;
	import flash.geom.Point;
	
	import pano.controls.ExtraManager;
	
    final public class AutoScaleToStage extends EventDispatcher  implements IExtra
    {
		public static const VER:Number = 1.0;
		
        private var _ext:ExtraManager;
		private var old = new Point(Capabilities.screenResolutionX,Capabilities.screenResolutionY);
		private var useAutoScaleToStage:Boolean = true;
		private var oriFocus:Number = 1000;
		private var _stage:Stage;
        public function AutoScaleToStage(_e:ExtraManager , v:Array):void
        {
            _ext = _e; oriFocus = v[1]; _stage = _ext.stage;
            //useAutoScaleToStage = (Capabilities.screenResolutionX/Capabilities.screenResolutionY)>1.77;
        }
		
		public function active(b:Boolean):void
		{
			useAutoScaleToStage = b;
		}
		
		public function resize():void
		{
			//trace("useAutoScaleToStage:"+useAutoScaleToStage)
			if(useAutoScaleToStage) {
				
				var dix =  (_stage.stageWidth)/old.x;
				var diy =  (_stage.stageHeight)/old.y;
				if(Math.abs(dix) >0.01 && Math.abs(diy) >0.01)
					_ext.exec("setfocus" , Math.floor(oriFocus *(Math.abs(dix)>Math.abs(diy)?dix:diy)) );
			}
		}
		
    }
}
