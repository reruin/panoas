/*
1.3 ~ 1.5 m 内存泄漏
*/

package {

	import flash.display.*;
	import flash.events.*;
	import flash.filters.GlowFilter;
	import flash.net.*;
	import pano.ExtraInterface;
	import pano.utils.TweenNano;
	import flash.text.*;
	//import com.tiny.ui.utils.applyAlpha;
	
	public class Help extends Sprite{
		//#869CA7
		protected var _width:Number = 650;
		protected var _height:Number = 370;
		protected var _padding:Number = 10;
		protected var _scale:Number;
		protected var _background:Shape;
		protected var _borderWidth:Number;
		protected var _cunstomFilters:Array;
		protected var _backColor:uint;
		protected var _close:Sprite;
		protected var _mask:Shape;
		private var _content:Sprite;
		private var _border:Shape;
		private var _helpSprite:Sprite;
		private var EIF:ExtraInterface;
		private var _ready:Boolean = false;
		//protected var _backAlpha:Number;
		public function Help(){
			
			
			if (stage == null)
            {
                this.addEventListener(Event.ADDED_TO_STAGE, this.startPlugin);
               this.addEventListener(Event.REMOVED_FROM_STAGE, this.stopPlugin);
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
				EIF.set("helpToggle",toggle);
				EIF.addPluginEventListener(ExtraInterface.PLUGINEVENT_REGISTER, this.registerEvent);
			}
			
			this.removeEventListener(Event.ADDED_TO_STAGE, startPlugin);
		}
		
		
		private function stopPlugin(e:Event):void
		{
			unregListeners(); picLoader = null;
			bmp = null;
			for(var i:int = _content.numChildren-1 ; i>=0 ; i--) _content.removeChildAt(i);
			
		}
		
		private function registerEvent(e)
		{
			init();
		}
		
		protected function init():void
		{
			addChildren(); drawMask(); drawStyle();drawContent(); resize();
			this.alpha = 0;this.visible = false;
			regListeners();
			if(EIF.ready) load( EIF.call("getPluginsConfig" , "help").image );
		}
		
		private function regListeners():void
		{
			_content.addEventListener(MouseEvent.MOUSE_OVER,mouseOverHandler,false,0,true);
			_content.addEventListener(MouseEvent.MOUSE_OUT,mouseOutHandler,false,0,true);
			_close.addEventListener(MouseEvent.CLICK,close_mouseClickHandler,false,0,true);
			stage.addEventListener(Event.RESIZE, resizeHandler,false,0,true);
		}
		
		private function unregListeners():void
		{
			_content.removeEventListener(MouseEvent.MOUSE_OVER,mouseOverHandler);
			_content.removeEventListener(MouseEvent.MOUSE_OUT,mouseOutHandler);
			_close.removeEventListener(MouseEvent.CLICK,close_mouseClickHandler);
			stage.removeEventListener(Event.RESIZE, resizeHandler);
		}
		
		protected function addChildren():void
		{
			_mask = new Shape(); 
			_content = new Sprite();
			_background = new Shape();
			_border = new Shape();
			_close = getCloseBtn();
			_helpSprite = new Sprite();
			_content.addChild(_background);
			_content.addChild(_border);
			
			_content.addChild(_helpSprite);
			_content.addChild(_close);
			this.addChild(_mask);
			this.addChild(_content);
			
		}
		
		private function drawMask():void
		{
			_mask.graphics.clear()
			_mask.graphics.beginFill(0,0.85);
			_mask.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			_mask.graphics.endFill();
		}
		
		protected function drawStyle():void
		{	
			_background.graphics.clear()
			_background.graphics.beginFill(0x333333);
			_background.graphics.drawRect(0, 0, _width, _height);
			_background.graphics.endFill();
			
			_border.graphics.clear();
			_border.graphics.lineStyle(1,0);
			_border.graphics.beginFill(0xffffff,0);
			_border.graphics.drawRect(0, 0, _width, _height);
			_border.graphics.endFill();
			
			/*
			_tips.graphics.clear();
			_tips.graphics.lineStyle(1,0xffe69c,0.6);
			_tips.graphics.beginFill(0xffe69c,0.6);
			_tips.graphics.moveTo(20,-15);
			_tips.graphics.lineTo(40,-15);
			_tips.graphics.lineTo(-5,42);
			_tips.graphics.lineTo(-20,30);
			_tips.graphics.lineTo(20,-15);
			
			_tips.graphics.endFill();
			*/
			_close.x = _width; _close.alpha = 0.9;
			_close.scaleX = _close.scaleY = 0.9;
			_border.filters = [new GlowFilter(0xffffff,0.75,8,8,1)];
			
			//fixPosition();
		}
		
		private function drawContent():void
		{
			if(_ready)
				_helpSprite.x = _helpSprite.y = _padding;
			
			//_pic.y = 10;
			
		}
		
		private function mouseOverHandler(e:MouseEvent):void{
			TweenNano.to(_close,0.4,{scaleX:1,scaleY:1,alpha:1,ease:TweenNano.BackOut})
			//TweenNano.to(_max,0.4,{scaleX:1,scaleY:1,ease:TweenNano.BackOut})
			
		}

		private function mouseOutHandler(e:MouseEvent):void{
			TweenNano.to(_close,0.4,{scaleX:0.9,scaleY:0.9,alpha:1,ease:TweenNano.BackOut})
			//TweenNano.to(_max,0.4,{scaleX:0.01,scaleY:0.01,ease:TweenNano.BackOut})
			
		}
		
		private function resizeHandler(e:Event):void
		{
			resize();
		}
		
		private function close_mouseClickHandler(e:MouseEvent):void
		{
			toggle();
		}

		private function getCloseBtn():Sprite
		{
			var cbtn = new Sprite();
			cbtn.buttonMode = true;
			cbtn.graphics.beginFill(0x161101);
			cbtn.graphics.lineStyle(1,0);
			//cbtn.graphics.drawCircle(-5,-5,10, 10);
			cbtn.graphics.drawCircle(0, 0, 10);
			cbtn.graphics.endFill();
			cbtn.graphics.lineStyle(2,0xbab2a5);
			cbtn.graphics.moveTo(3,3);
			cbtn.graphics.lineTo(-3,-3);
			cbtn.graphics.moveTo(3,-3);
			cbtn.graphics.lineTo(-3,3);
			
			return cbtn;
		}
		
		
		protected function invalidate():void
		{
			addEventListener(Event.ENTER_FRAME, onInvalidate);
		}
		
		private function onInvalidate(event:Event):void
		{
			resize();
			removeEventListener(Event.ENTER_FRAME, onInvalidate);
			//draw();
		}

		private var isopen:Boolean = false;
		
		public function toggle():void
		{
			isopen = !isopen;
			TweenNano.to(this,0.5,{autoAlpha:isopen?1:0});
		}
		
		
		public function resize():void
		{
			var w = stage.stageWidth;
        	var h = stage.stageHeight;
			
			drawMask();drawStyle()
			//trace(width)
			//this.x = (550 - w) / 2;
			//this.y = (400 - h) / 2;
			_content.x = (w - _content.width) / 2;
			_content.y = (h - _content.height) / 2;
		}
		
		private var picLoader:Loader = new Loader();
		public function load(u:String):void
		{
			
				picLoader.load(new URLRequest(u));
				picLoader.contentLoaderInfo.addEventListener(Event.INIT,eventInit,false,0,true);
				picLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, eventError,false,0,true);
				picLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,eventComplete,false,0,true);
		}
		
		private var bmp:Bitmap;
		private function eventInit(e:Event)
		{
			bmp = (e.target.content) as Bitmap; // this is a bitmap
			bmp.smoothing = true;
			e.target.loader.unload();
			
			_width = bmp.width;
			_height = bmp.height;
			_helpSprite.addChild(bmp);
			invalidate();
			//resize();
		}
		
		private function eventError(e:Event) {  }
		
		private function eventComplete(e:Event):void
		{
			e.target.removeEventListener(Event.INIT,eventInit);
			e.target.removeEventListener(IOErrorEvent.IO_ERROR, eventError);
			e.target.removeEventListener(Event.COMPLETE,eventComplete);
			//e.target = null;
			picLoader.unload();
			_ready = true;
			
			
			
		}
		
	}
}