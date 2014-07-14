package  {
	
	import flash.display.*
	import flash.events.*;
	import flash.filters.*;
	import pano.ui.*;
	import pano.utils.LoaderQueue;
	import pano.extra.ExtraInterface;
	
	public class UIButtom extends Component{
		
		private var skin:BitmapData;
		private var _noticeSprite:noticeSprite;
		private var _leftSprite:leftSprite;
		private var _thumbContainer:Sprite;
		private var _scrollPane:ScrollPane;
		private var lq:LoaderQueue;
		private var loadPano:Function;
		private var EIF:ExtraInterface;
		private var _background:Shape;
		//private var 
		public function UIButtom() {
			
			//Security.allowDomain("*");
			//stage.scaleMode = StageScaleMode.NO_SCALE
			skin = new buttomShade();trace("BEGIN" + skin)
			if (stage == null)
			{
				this.addEventListener(Event.ADDED_TO_STAGE, this.startPlugin);
			//this.addEventListener(Event.REMOVED_FROM_STAGE, this.stopPlugin);
			}else
			{
				start();
			}
			super(1,125)
			
		}
		
		private function startPlugin(e:Event):void
		{
			//this.alpha = 0;this.visible = false;
			stage.showDefaultContextMenu = false;
			EIF = ExtraInterface.getInstance();
			
			if(EIF.ready) 
			{
				EIF.set("loadbuttom",load);
				EIF.addPluginEventListener(ExtraInterface.PLUGINEVENT_REGISTER, this.registerEvent);
			}

		}
		
		private function registerEvent(e)
		{
			loadPano = EIF.get("loadpano");
			start(); resize();
		}
		
		private function start():void
		{
			
			lq = new LoaderQueue();
			lq.addEventListener("EveryComplete",loadQueueHandler,false,0,true);
			this.stage.addEventListener(Event.RESIZE, resizeHandler,false,0,true);
			
		}
		
		
		override protected function addChildren():void
		{
			_scrollPane = new ScrollPane(100,115);
			_thumbContainer = new Sprite();
			_noticeSprite = new noticeSprite();
			_leftSprite = new leftSprite();
			_background = new Shape();
			
			addChild(_background);
			addChild(_noticeSprite);
			addChild(_scrollPane);
			addChild(_leftSprite);
			
			//width = this.stage.stageWidth;
			
			_scrollPane.setContent(_thumbContainer);
			_scrollPane.headHeight = 0;
			
			//trace(stage+"----->")
			
			addEventListener(MouseEvent.CLICK , thumbClickHandler);
			if(stage) resize();
			
		}
		
		//override protected function draw():void {	autofill();  }
		
		public function load(u:Array):void
		{
			remove();
			var w = 160 , h = 80 , padding = 15;
			for(var i=0;i<u.length ; i++)
			{
				var n = "1"+"_"+i;
				var t:Sprite = new Sprite();
				t.x = padding + i*(w+padding); t.y = padding;
				t.name = n; t.buttonMode = true;
				lq.add(u[i].thumb,n);
				_thumbContainer.addChild(t);
				drawBorder(t);
			}
			
			lq.start();
		}
		
		private function remove():void
		{
			while(_thumbContainer.numChildren > 0){
				_thumbContainer.removeChildAt(0)
			}
		}
		
		private function drawBorder(v:Sprite):void
		{
			v.filters = [new GlowFilter(0x334456,0.75,8,8)];
		}
		
		private function autofill()
		{
			trace("fill")
			if(skin)
			{
				_background.graphics.clear();
				_background.graphics.beginBitmapFill(skin);
				_background.graphics.drawRect(0,0,width, height)
				_background.graphics.endFill();
				
			}

		}
		
		private function loadQueueHandler(e):void
		{
			var name = e.target.name;
			var bmp = new Bitmap((e.target.target as Bitmap).bitmapData);
			bmp.width = 160; bmp.height = 80;
			(_thumbContainer.getChildByName(name) as Sprite).addChild(bmp);
			_scrollPane.render();
		}
		
		private function thumbClickHandler(e):void
		{
			//trace(e.target.name);
			if(e.target.name.indexOf("_")!=-1)
			{
				var v = e.target.name.split("_");
				trace(v); trace(loadPano)
				if(EIF.ready) loadPano(v)
				
			}
			
		}
		
		private function resizeHandler(e):void
		{
			resize()
		}
		
		public function resize():void
		{
			var w = this.stage.stageWidth;
			var h = this.stage.stageHeight;
			//trace("RES:"+this.stage.stageWidth)
			this.x = (550 - w)/2 + 350;
			this.y = (400 + h)/2 - this.height;
			width = w - 350;
			_noticeSprite.x = w - _noticeSprite.width;
			_noticeSprite.y = this.height - _noticeSprite.height;
			
			_scrollPane.x = _leftSprite.width;
			_scrollPane.y = 125 - _scrollPane.height
			_scrollPane.width = w - _noticeSprite.width - _leftSprite.width;
			
			_leftSprite.x = 0;
			_leftSprite.y = _leftSprite.height * -0.5;
			autofill();
		}
		
	}
	
}
