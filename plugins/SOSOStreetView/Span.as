package {
		 
    import flash.display.Sprite;
	import flash.display.DisplayObjectContainer
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.text.*;
	import flash.filters.DropShadowFilter;
	
	//import pano.utils.TweenNano;
	
	public class Span extends Sprite {

		private var _labelSpan:TextField;
		private var _labelDistance:TextField;
		private var _target:DisplayObjectContainer;
		private var _width:Number;
		private var _height:Number;
		private var _textSpan:String;
		private var _textDistance:String;
		public var position:Point;
		public var type:String = "marker";
		public function Span(s:String , sd:String , p:Point):void
		{
			_textSpan = s; _textDistance = sd; position = p;
			init();
		}
		
		public function init()
		{
			initObject();
			
			//this.alpha = 0;
			//this.visible = false;
			this.cacheAsBitmap = true;
			this.filters = [new DropShadowFilter(2,45,0,1,8,8,0.5,2)];
			//this.mouseChildren = false;
			this.mouseEnabled = true;
			drawStyle();
			this.addEventListener(MouseEvent.MOUSE_OVER,overHandler);
			this.addEventListener(MouseEvent.MOUSE_OUT,outHandler);
		}
		
		private function initObject():void
		{
			_labelSpan = new TextField(); _labelDistance = new TextField();
			_labelSpan.defaultTextFormat = _labelDistance.defaultTextFormat = new TextFormat("宋体",12);
			_labelSpan.autoSize = _labelDistance.autoSize = TextFieldAutoSize.LEFT;
			_labelSpan.textColor = 0xffffff;
			_labelDistance.textColor = 0x5ad941;
			//_labelSpan.background = true
			//_labelSpan.backgroundColor = 0x80000000;
			
			//_labelSpan.border = true;
			//_labelSpan.borderColor = 0xcccccc;
			_labelSpan.htmlText = _textSpan ; _labelDistance.htmlText = _textDistance ; 
            _labelSpan.selectable = _labelDistance.selectable = false;
			//trace(_labelSpan.x +":"+_labelSpan.y);
			_labelSpan.x += 3;_labelSpan.y = _labelDistance.y = 4;
			_labelDistance.x = _labelSpan.x + _labelSpan.textWidth + 6;
			addChild(_labelSpan);addChild(_labelDistance);
		}
		
		private function drawStyle():void
		{
			this.graphics.clear();
			this.graphics.beginFill(0,0.618);
			this.graphics.lineStyle(1,0x454545)
			this.graphics.drawRect(0,0,width+6,height+8);
			this.graphics.endFill();
		}
		
		
		public function update(p:Point):void{

			if(p.x<=0 || p.y <= 0 || p.x >= this.stage.stageWidth || p.y >= this.stage.stageHeight) this.visible = false;
			else 
			{
				
				this.x = p.x ; this.y = p.y ;
				this.visible = true;
			}
			
		}
		
		public function resize():void{}
 		
		private function overHandler(e):void
		{
			this.graphics.lineStyle(1,0x389525)
			this.graphics.lineTo(width-1,0)
			this.graphics.lineTo(width-1,height-1)
			this.graphics.lineTo(0,height-1)
			this.graphics.lineTo(0,0)
		}
		
		private function outHandler(e):void
		{
			this.graphics.lineStyle(1,0x454545)
			this.graphics.lineTo(width-1,0)
			this.graphics.lineTo(width-1,height-1)
			this.graphics.lineTo(0,height-1)
			this.graphics.lineTo(0,0)
		}
		
	}
}


