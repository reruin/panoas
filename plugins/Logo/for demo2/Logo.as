package  {
	
	import flash.system.Security;
	import flash.display.*;
	import flash.events.*;
	import pano.extra.ExtraInterface;
	
	public class Logo extends Sprite{
		
		private var EIF:ExtraInterface;
		private var logo:logoSprite;
		
		public function Logo()
		{
			Security.allowDomain("*");
			EIF = ExtraInterface.getInstance();
			//stage.scaleMode = StageScaleMode.NO_SCALE
			if (stage == null)
			{
				this.addEventListener(Event.ADDED_TO_STAGE, this.startPlugin);
			//this.addEventListener(Event.REMOVED_FROM_STAGE, this.stopPlugin);
			}else
			{
				init();
			}
		}
		
		private function startPlugin(e:Event):void
		{
			//this.alpha = 0;this.visible = false;
			stage.showDefaultContextMenu = false;
			
			//trace("run me")
			if(EIF.ready) 
			{
				//layer = EIF.get("layer")();
				//layer.addChild(this);
				/*EIF.set("wall3Dstart",start);
				EIF.set("wall3Dstop",stop);
				EIF.set("wall3Dnext",next);
				EIF.set("wall3Dback",back);
				
				hideFn = EIF.get("hideMenu")
				*/
			}
			
			init();
			
		}
		
		private function init():void
		{
			logo = new logoSprite();
			addChild(logo);
			resize();
			stage.addEventListener(Event.RESIZE, resizeHandler,false,0,true);
		}
		
		private function resizeHandler(e):void
		{
			resize()
		}
		
		public function resize():void
		{
			var w = this.stage.stageWidth;
			var h = this.stage.stageHeight;
			
			this.x = (550 + w)/2 - logo.width - 20
			this.y = (400 - h)/2 + 20;
			trace("LOGO RESIZE :: "+this.x + ":"+this.y)
			//_pano.height = h - 125;
			//_pano.x = (550  - w)/2 + 345;
			//_pano.y = (400  -  h)/2;
			//thumb.x = w - thumb.width - 10;
			//thumb.y = h - thumb.height - 10;
		}

	}
	
}
