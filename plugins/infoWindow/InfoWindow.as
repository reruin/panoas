package  {
	
	import flash.system.Security;
	import pano.ExtraInterface;
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	import flash.geom.*;
	import flash.text.*;
	import pano.utils.*;
	
	public class InfoWindow extends Sprite {
		
		private var EIF:ExtraInterface;
		private var _width:Number = 0;
		private var _height:Number = 0;
		private var _oriWidth :Number = 450;
		private var _scale:Number = 1;
		private var _useFull:Boolean = false;
		private var _value:Number = 0;
		private var _maxValue:Number = 1;
		private var _mediaHandler:String;
		
		private var _font:String = "黑体";
		private var _headFontsize:int = -1;
		
		private var _mediaPane;
		public function InfoWindow() {
			
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
			
			trace((new Date).toLocaleTimeString()+" : Loading InfoWindow(Ver 1.0) Plugin ... ");
			
			stage.showDefaultContextMenu = false;
			EIF = ExtraInterface.getInstance();
			if(EIF.ready) 
			{
				EIF.set("openWindow",open);
				EIF.set("closeWindow",close);
				EIF.addPluginEventListener(ExtraInterface.PLUGINEVENT_REGISTER, this.registerEvent);
			}
			
			this.removeEventListener(Event.ADDED_TO_STAGE, this.startPlugin);
		}

		private function stopPlugin(e):void { }
		
		private function registerEvent(e):void { init(); }
		
		protected function init():void
		{
			//addChildren(); drawMask(); drawStyle();drawContent(); 
			var f:Object = EIF.call("getPluginsConfig" , "infowindow");
			if(f && f.font) _font = f.font;
			
			_content.mouseWheelEnabled	= false;
			_content.mask = _mask;
			
			_title.mouseEnabled = false;
			_title.autoSize  = "center";
			
			this.x = 0 - _oriWidth;
			this.alpha = 0;
			this.visible = false;
			
			_vol.mute.visible = false;
			
			regListeners();
			resize();
		}
		
		private function regListeners():void
		{
			_close.addEventListener(MouseEvent.CLICK,close_mouseClickHandler,false,0,true);
			stage.addEventListener(Event.RESIZE, resize,false,0,true);
			_scrollBar.addEventListener(MouseEvent.MOUSE_DOWN, onDrag);
			_content.addEventListener(MouseEvent.MOUSE_WHEEL, mouseScroll);
			_vol.addEventListener(MouseEvent.CLICK, toggleVol);
			
			//_content.addEventListener(Event.SCROLL,textScrollHandler);
		}
		
		protected function addChildren():void
		{
			//_pic = new ImageLoader();
			/*
			_labelTextField = new TextField();
			var _textFormat = new TextFormat("宋体",12);
			_textFormat.indent = 24;
			_textFormat.leading = 6;
			_labelTextField.defaultTextFormat = _textFormat;
			_labelTextField.autoSize = TextFieldAutoSize.LEFT;
			_labelTextField.textColor = 0xffffff;
			_labelTextField.multiline = true;
			_labelTextField.wordWrap = true;
			_labelTextField.width = 200;
				
            _labelTextField.selectable = false;
			*/
			
			this.addChild(_close);
			this.addChild(_content);
			//this.addChild(_imagePane);
			
		}
		
		private function mouseScroll(e):void{
			if(_scrollBg.visible == false) return;
			var d:Number = 5 * (0 - e.delta) / (_content.height-_mask.height);
			_value += d;
			render();
			_scrollBar.y = _scrollBg.y + _value *  (_scrollBg.height - _scrollBar.height);
		}
				
		private function close_mouseClickHandler(e:MouseEvent):void { close(); }
		
		public function render():void
		{
			if(_value>1) _value = 1;
			if(_value<0) _value = 0;
			TweenNano.to(_content,0.5,{y: _mask.y + (_mask.height-_content.height)*_value});
		}

		
		protected function onDrag(event:MouseEvent):void
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, onDrop);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onSlide);
			_scrollBar.startDrag(false, new Rectangle(_scrollBg.x, _scrollBg.y, 0, _scrollBg.height - _scrollBar.height));
			
		}
		
		protected function onDrop(event:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, onDrop);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onSlide);
			_scrollBar.stopDrag();
		}
		protected function onSlide(event:MouseEvent):void
		{
			_value = (_scrollBar.y-_mask.y) / (_scrollBg.height - _scrollBar.height);
			//trace("drag to : "+_value)
			render();
			
		}
		
		
		protected function invalidate():void
		{
			addEventListener(Event.ENTER_FRAME, onInvalidate);
		}
		
		private function onInvalidate(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, onInvalidate);
			//draw();
		}

		
		public function open(v:Object)
		{
			if(v.media.length == 0 && v.text=="" ) return;
			var showVolume:Boolean = false;
			//stage.quality = "BETTER";
			
			_useFull = (v.media.length && v.media[i][0] != "audio") ? true : false;
			
			_title.htmlText = v.title;
			_content.htmlText = v.text;
			_content.setTextFormat(new TextFormat(_font,14));
			_content.height = _content.textHeight + 4;
			
			var fontsize : int = Math.min( int((325 - 20) / _title.text.length) , 32);
			if(fontsize<20) fontsize = 20;
			_title.setTextFormat(new TextFormat(_font,fontsize));
			_title.y = 20 + 0.5*(60 - _title.textHeight);
			
			resize();
			TweenNano.to(this,1,{x:0,autoAlpha:1});
			
			for(var i:int = 0;i<v.media.length ; i++)
			{
				if(v.media[i][0] == "image") {_mediaPane = new ImagePane(); addChild(_mediaPane);drawPane();_mediaPane.load( v.media[i][1] );}
				if(v.media[i][0] == "audio") {showVolume = true;resumeSound = true;EIF.call("pauseSound");_mediaHandler = EIF.call("playSound",v.media[i][1] , 0 , true , false);}
				if(v.media[i][0] == "video") {_mediaPane = new VideoPane();resumeSound = true;EIF.call("pauseSound"); addChild(_mediaPane);drawPane();_mediaPane.load( v.media[i][1] );}
			}
			
			if(showVolume) _vol.visible = true;
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			
			
		}
		
		private var resumeSound : Boolean = false;
		private function keyDownHandler(e):void
		{
			if(e.keyCode == 27) close();
			
		}
		
		private function toggleVol(v:* = -1):void
		{
			
			EIF.call("toggleSound",_mediaHandler);
			_vol.vol.visible = !_vol.vol.visible;
			_vol.mute.visible = !_vol.mute.visible;
			//if(v) obj.filters = [new GlowFilter(0xffffff,0.8,16,16,3,2)];
			//else obj.filters = [];//[new GlowFilter(0,0,16,16,1)];
			
		}
		
		public function close():void
		{
			if(_mediaHandler){
				//删除播放流
				EIF.call("removeSound" , _mediaHandler);
				
			}
			
			//回复背景音效
			if(resumeSound)
			{
				EIF.call("resumeSound");
			}
			_vol.visible = false;
			
			TweenNano.to(this,0.5,{autoAlpha:0 , x:0-_oriWidth});
			if(_mediaPane)
			{
				if(this.contains(_mediaPane)) {
					try{
						_mediaPane.destroy();
						removeChild(_mediaPane);
					}catch(e){}
				}
			}
			
			this.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			resumeSound = false;
				//EIF.call("fadeSound",false);
		}	

		private function drawBar():void{
			var l = _scrollBg.height * _mask.height / _content.height;
			if(l<30) l = 30;
			_scrollBar.height = l;
			if(_content.height<=_mask.height){
				_scrollBar.visible = _scrollBg.visible = false;
				_value = 0;
				
			}
			else
			{
				 _scrollBar.visible = _scrollBg.visible = true;
			}
			//_maxValue = _content.height - 
		}
		
		private function draw():void{
			_width = _bg.width = _useFull ? stage.stageWidth : _oriWidth;
			_height = _bg.height = stage.stageHeight;
			var l:Number = _height - _content.x - 115;
			if(l < 50) l = 50;
			_scrollBg.height = _mask.height =  l;
			_vol.y = _height - 45;
			//_content.height
		}
		private function drawPane():void
		{
			if(_mediaPane)
			{
				var w = stage.stageWidth;
				_mediaPane.x =  _oriWidth + 25;
				_mediaPane.width = w - _oriWidth - 50;
			
				_mediaPane.y = 25;
				_mediaPane.height = stage.stageHeight - 50;
			
			}
			
		}
		
		public function resize(e:* = null):void
		{
			draw(); drawBar(); drawPane();render();
			
		}
	}
	
}
