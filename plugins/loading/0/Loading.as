package {
	
	import flash.display.*;
	import flash.events.Event;
	import flash.system.*;
	import pano.extra.ExtraInterface;
	import pano.utils.TweenNano;
	public class Loading extends Sprite {
		
		
		private var EIF:ExtraInterface;
		private var ui:loadui;
		public function Loading() {
			
			Security.allowDomain("*");
			if (stage == null)
			{
				this.addEventListener(Event.ADDED_TO_STAGE, this.startPlugin);
				this.addEventListener(Event.REMOVED_FROM_STAGE, this.stopPlugin);
			}else
			{
				startPlugin();
			}
		}

		private function startPlugin(e:Event = null):void
		{
			
			trace((new Date).toLocaleTimeString()+" : Loading Loading(User) Plugin ... ");
			stage.showDefaultContextMenu = false;
			EIF = ExtraInterface.getInstance();
			if(EIF.ready) 
			{
				EIF.set("showload",showLoad);
				EIF.set("hideload",hideLoad);
				EIF.addPluginEventListener(ExtraInterface.PLUGINEVENT_REGISTER, this.registerEvent);
			}
			
			this.removeEventListener(Event.ADDED_TO_STAGE, this.startPlugin);
		}
		
		private function stopPlugin(e):void { }
		
		private function registerEvent(e):void {
			init(); 
			stage.addEventListener(Event.RESIZE, resize,false,0,true);
			resize();
		}
		
		private function init():void
		{
			//this.visible = false;
			
			ui = new loadui();
			addChild(ui);
		}
		
		public function showLoad(v:String):void
		{
			this.visible = true;
			
			TweenNano.to(this,0.8,{autoAlpha : 1 , onComplete: hideLoad});
			TweenNano.to(ui.round,1200,{rotationZ : 150 * 360});
			trace(ui.label.htmlText);
			ui.label.htmlText = v;
		}
		
		public function hideLoad():void
		{
			TweenNano.to(this,0.5,{autoAlpha :0 });
			
			TweenNano.killTweensOf(ui);
			ui.rotationX = 0;
			
			
		}
		
		public function resize(e:* = null):void
		{
			this.x = stage.stageWidth / 2;
			this.y = stage.stageHeight / 2;
		}
		
		
		
	}
	
}
