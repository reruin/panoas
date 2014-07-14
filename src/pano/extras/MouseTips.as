package pano.extras{
		 
    import flash.display.Sprite;
	import flash.display.DisplayObjectContainer
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.text.*;
	import flash.filters.DropShadowFilter;
	
	import pano.extras.IExtra;
	import pano.controls.ExtraManager;
	import pano.utils.TweenNano;
	
	public class MouseTips extends Sprite implements IExtra{

		public static var VER:Number = 1.0;
		private var EIF:ExtraManager;
		protected var _labelTextField:TextField;
		private var _target:DisplayObjectContainer;
		private var _width:Number;
		private var _height:Number;
		private var container:DisplayObjectContainer;
		private var _font:String = "黑体";
		public function MouseTips(_e:ExtraManager = null, v:Array = null):void
		{
			if(_e != null && v !==null){
				EIF = _e;
				container = EIF.get("layer");
				
				_font = EIF.get("styles").font;
				
				container.addChild(this);
				container.addEventListener(Event.ADDED , this.switchLayer);
				//EIF.content.addChild(this);
				EIF.set("show",show);
				EIF.set("hide",hide);
			}
			
			init();
		}
		
		private function switchLayer(e):void
		{
			container.setChildIndex(this,container.numChildren-1);
		}
		
		public function init()
		{
			initObject();
			this.alpha = 0; this.visible = false; this.cacheAsBitmap = true;
			this.filters = [new DropShadowFilter(8,45,0,1,8,8,0.5,2)];
			//this.mouseChildren = false;
			this.mouseEnabled = true;
		}
		
		private function initObject():void
		{
			_labelTextField = new TextField();
			_labelTextField.defaultTextFormat = new TextFormat(_font,14);
			_labelTextField.autoSize = TextFieldAutoSize.LEFT;
			_labelTextField.textColor = 0xffffff;
            _labelTextField.selectable = false;
			_labelTextField.x += 3;_labelTextField.y = 2;
			addChild(_labelTextField);
		}
		
		private function drawStyle():void
		{
			this.graphics.clear();
			this.graphics.beginFill(0,0.375);
			//this.graphics.lineStyle(1,0xdcdcdc)
			this.graphics.drawRect(0,0,width+4,height+4);
			this.graphics.endFill();
		}
		
		private function movehandler(e:MouseEvent):void
		{
			update();
		}
		
		public function update():void
		{
			var w:Number = stage.stageWidth,
				h:Number = stage.stageHeight,
				mx:Number = this.parent.mouseX,
				my:Number = this.parent.mouseY;
			my += (my<h/2)?(height*0.3):(height*-1.3)
			mx = mx - width*.5;
			if(mx<0) mx = 0;
			if(mx>w-width) mx = w - width;
			//if(my<0) my = 0;
			//if(my>h-height) my = h - height;
			//mx += (mx<w/2)?(this.width*2):(this.height*-2)
			
			if(_target)
			{
				this.x = Math.round(mx);
				this.y = Math.round(my);
			}
			
		}
		
		public function show(tar:DisplayObjectContainer,v:String = "" , autoToggle:Boolean = true):void
		{
			_target = tar;
			_labelTextField.htmlText = v;
			TweenNano.to(this,0.6,{autoAlpha:1});
			_target.addEventListener(MouseEvent.MOUSE_MOVE, movehandler);
			this.addEventListener(MouseEvent.MOUSE_MOVE, movehandler);
			drawStyle();
			//_width = 
		}
		
		public function hide():void
		{
			TweenNano.to(this,0.6,{autoAlpha:0});
			if(_target){
				_target.removeEventListener(MouseEvent.MOUSE_MOVE, movehandler);
				this.removeEventListener(MouseEvent.MOUSE_MOVE, movehandler);
				_target = null;
			}
		
		}
		
		public function set label(v:String):void { }
		
		public function resize():void{}
 		
	}
}


