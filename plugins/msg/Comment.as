package  {
	import flash.display.*;
	import flash.events.*;
	import pano.ExtraInterface;
	import flash.filters.GlowFilter;
	import pano.utils.TweenNano;
	import flash.net.*;
	public class Comment extends Sprite{
		
		private var EIF:ExtraInterface;
		private var config:XML;
		private var container:Sprite = new Sprite();
		private var _height:Number = 1;
		private var _width:Number = 1;
		private var _url:String = "";
		public function Comment() {
			
			if (stage == null)
			{
				this.addEventListener(Event.ADDED_TO_STAGE, this.startPlugin);
				this.addEventListener(Event.REMOVED_FROM_STAGE, this.stopPlugin);
			}else
			{
				startPlugin();
			}
		}
		
		private function startPlugin(e:* = null):void
		{
			stage.showDefaultContextMenu = false;
			EIF = ExtraInterface.getInstance();
			if(EIF.ready) 
			{
				var k:String = (new Date).toLocaleTimeString()+" : Loading Comment(Ver 20140901) Plugin Success ... ";
				EIF.addPluginEventListener(ExtraInterface.PLUGINEVENT_REGISTER, this.registerEvent);
			}
			
			this.removeEventListener(Event.ADDED_TO_STAGE, this.startPlugin);
		}
		
		private function stopPlugin(e):void { }
		
		private function registerEvent(e):void {
			stage.addEventListener(Event.RESIZE, resize,false,0,true);
			this.btn.addEventListener(MouseEvent.CLICK, clickHandler,false,0,true);
			
			
			var b:String = EIF.call("getPluginsConfig" , "comment").url;
			if(b=="" || b==null) b = "";
			
			init()
		}
		

		private function init():void
		{
			
			this.addEventListener(MouseEvent.CLICK, clickHandler,false,0,true);
			resize();
		}
		
		private function clickHandler(e):void
		{
			navigateToURL(new URLRequest( this._url ),"_blank");
		}
		
		private var status:int = 0;
		
		
		private function resize(e:* = null):void
		{
			var w = this.stage.stageWidth;
        	var h = this.stage.stageHeight;
			if(status==1){
				this.x = w - _width-10;
				this.y = h - _height-10;
			}else{
				this.x = w - 26;
				this.y = h - 26;
			}
			
		}
		
	}
	
}
