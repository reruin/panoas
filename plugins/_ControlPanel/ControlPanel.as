package {
	
	import flash.display.*;
	import flash.geom.*;
	import flash.events.*;
    import flash.net.URLRequest;
	import flash.filters.GlowFilter;
	import pano.utils.TweenNano;
	//import pano.core.Pano;
	import pano.extra.ExtraInterface;
	
	public class ControlPanel extends Sprite
	{

		private var EIF:ExtraInterface;
		
		public function ControlPanel(){
			
			if (stage == null)
			{
				this.addEventListener(Event.ADDED_TO_STAGE, this.startPlugin);
				this.addEventListener(Event.REMOVED_FROM_STAGE, this.stopPlugin);
			}else
			{
				startPlugin()
			}
		}
		
		private function startPlugin(e:Event = null):void
		{
			trace((new Date).toLocaleTimeString()+" : Loading ControlPanel Plugin ... ");
			
			stage.showDefaultContextMenu = false;
			EIF = ExtraInterface.getInstance();
			if(EIF.ready) 
			{
				EIF.addPluginEventListener(ExtraInterface.PLUGINEVENT_REGISTER, this.registerEvent);
			}
			resize();
			
			this.removeEventListener(Event.ADDED_TO_STAGE, this.startPlugin);
		}
		
		private function stopPlugin(e):void
		{
			unregListeners();
			
			EIF.removePluginEventListener(ExtraInterface.PLUGINEVENT_REGISTER, this.registerEvent);
			
			trace((new Date).toLocaleTimeString()+" : UnLoad [ControlPanel] Plugin Success ! ");
				
		}
		
		private function registerEvent(e = null)
		{
			regListeners();
		}
		
		
		private function regListeners():void
		{
			this.addEventListener(MouseEvent.MOUSE_DOWN,mouseDownHandler,false,0,true);
			stage.addEventListener(Event.RESIZE, resizeHandler,false,0,true);
		}
		
		private function resizeHandler(e):void
		{
			resize()
		}
		
		private function unregListeners():void
		{
			this.removeEventListener(MouseEvent.MOUSE_DOWN,mouseDownHandler);
			stage.removeEventListener(Event.RESIZE, resizeHandler);
		}
		
		private function mouseDownHandler(e:MouseEvent):void
		{
			this.addEventListener(MouseEvent.MOUSE_UP,mouseUpHandler,false,0,true);
			switch(e.target)
			{
				case toround : 
					EIF.get("setPano")("toRound");break;
				case toleft : 
					EIF.get("setPano")("toX" , true);break;
				case toright : 
					EIF.get("setPano")("toX" , false);break;
				case toup : 
					EIF.get("setPano")("toY" , true);break
				case todown : 
					EIF.get("setPano")("toY" , false);break ; 
				case zoomin : 
					EIF.get("setPano")("zoomTo" , true);break
				case zoomout : 
					EIF.get("setPano")("zoomTo" , false);break
				case fullscreen : 
					EIF.get("fullscreen")();break;
				default : 
					break;
			}
		}
		
		private function mouseUpHandler(e:MouseEvent):void
		{
			this.addEventListener(MouseEvent.MOUSE_UP,mouseUpHandler);
			EIF.get("killpanoanimat")();
			EIF.get("render")()
		}
		
		
		public function resize():void
		{
			var w = this.stage.stageWidth;
        	var h = this.stage.stageHeight;
			
			this.x = 8;
			this.y = h - this.height - 8;
			
		}
		
	}
}
