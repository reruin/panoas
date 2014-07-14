package {
	
	import flash.display.*;
	import flash.text.*;
	import flash.events.Event;
	import flash.system.*;
	import pano.ExtraInterface;
	import pano.utils.TweenNano;
	public class Loading extends Sprite {
		
		
		private var EIF:ExtraInterface;
		private var ui:TextField;
		private var DefaultTextFormat:TextFormat;
		
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
			ui = new TextField();
			ui.autoSize = TextFieldAutoSize.LEFT;
            ui.selectable = false;
			ui.wordWrap = true;
            ui.defaultTextFormat = new TextFormat("Calibri",160);
			ui.textColor = 0xffffff;
			this.alpha = 0;
			this.visible = false;
			this.addChild(ui);
			
		}
		
		public function showLoad(v:String):void
		{
			this.visible = true;
			
			TweenNano.to(this,0.5,{autoAlpha : 1 , onComplete: hideLoad});
			//TweenNano.to(ui.round,1200,{rotationZ : 150 * 360});
			//EIF.trace(v);
			ui.text = v;
			ui.width = (v.length) * 160;
			//ui.height = Number(DefaultTextFormat.size) - 4 ;
			resize();
			
		}
		
		public function hideLoad():void
		{
			TweenNano.killTweensOf(this);
			TweenNano.to(this,0.5,{autoAlpha :0 });

		}

		public function resize(e:* = null)
		{
			ui.x = (this.stage.stageWidth - ui.textWidth - 6) ;
			ui.y = (this.stage.stageHeight - ui.height);
		}
		
	}
	
}
