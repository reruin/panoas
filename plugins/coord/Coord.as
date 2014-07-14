package {

	import flash.display.*;
	import flash.events.*;
	import flash.filters.GlowFilter;
	import flash.net.*;
	import pano.ExtraInterface;
	import pano.utils.TweenNano;
	import flash.text.*;

	//import com.tiny.ui.utils.applyAlpha;
	
	public class Coord extends Sprite{
		//#869CA7
		
		private var EIF:ExtraInterface;
		private var _ready:Boolean = false;
		private var getCoord:Function;
		private var layer:Sprite;
		//protected var _backAlpha:Number;
		public function Coord(){
			
			if (stage == null)
            {
                this.addEventListener(Event.ADDED_TO_STAGE, this.startPlugin);
               //this.addEventListener(Event.REMOVED_FROM_STAGE, this.stopPlugin);
            }else
				this.startPlugin();
		}
		
		private function startPlugin(e:Event = null):void
		{
			stage.showDefaultContextMenu = false;
			EIF = ExtraInterface.getInstance();
			if(EIF.ready) 
			{
				//layer = EIF.get("layer")();
				//layer.addChild(this);
				EIF.addPluginEventListener(ExtraInterface.PLUGINEVENT_REGISTER, this.registerEvent);
			}
			
			this.removeEventListener(Event.ADDED_TO_STAGE, startPlugin);
		}
		
		private function registerEvent(e)
		{
			getCoord = EIF.get("screenToPano");
			layer =  EIF.get("viewport");
			init();
		}
		
		protected function init():void
		{
			regListeners();
		}
		
		private var hasm:Boolean = false;
		private function regListeners():void
		{
			layer.addEventListener(MouseEvent.MOUSE_DOWN,mouseDownHandler);
			layer.stage.addEventListener(MouseEvent.MOUSE_MOVE,mouseMoveHandler);
			layer.addEventListener(MouseEvent.CLICK,mouseClickHandler);
			stage.addEventListener(Event.RESIZE, resizeHandler,false,0,true);
		}
		
		private function mouseDownHandler(e):void
		{
			hasm = false;
			
			
		}
		
		private function mouseMoveHandler(e):void
		{
			hasm = true;
		}
		
		private function mouseClickHandler(e):void
		{
			if(hasm == false){
					var p = getCoord();
					EIF.trace("Position : "+ int(p.y)+","+int(p.x));
					//trace(getCoord().toString());
			}
		}
		
		private function resizeHandler(e):void
		{
			resize();
		}
		
		public function resize():void
		{
			var w = this.stage.stageWidth;
			var h = this.stage.stageHeight;
		}
		
		
		
	}
}