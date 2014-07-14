package {
    import flash.display.*;
    import flash.events.*;
    import flash.media.Video;
    import flash.media.SoundMixer
    import flash.utils.ByteArray; 

    import flash.net.NetConnection;
    import flash.net.NetStream;
	import flash.media.SoundTransform;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.filters.GlowFilter;
	import pano.events.*;
	import pano.utils.TweenNano;
	
    public class VideoPane extends Sprite{
		
		public static const VER:Number = 1.0;
		 
		 
		private var _url:String;
		private var _width:Number = 1;
		private var _height:Number = 1;
		private var _oriwidth:Number = 320;
		private var _oriheight:Number = 240;
		
		private const DEFAULTMAXDISTANCE:Number = 1024; // pix
		private const DEFAULTMINDISTANCE:Number = 128;//pix 
        private var _videoURL:String = "";
		private var _video:Video;
		private var _container:Sprite;
		private var _ext:EventDispatcher;
		
		private var _videoContainer:Sprite = new Sprite();
		private var _playerWidth:Number = 320;
		private var _playerHeight:Number = 265;
		private var _videoWidth:Number = 320;
		private var _videoHeight:Number = 240;
		private var _netStream:NetStream;
		private var _netConnetction:NetConnection;
		private var _soundTransform:SoundTransform;
		private var _back:Sprite;
		private var _menu:controlbar;
		private var _closeBtn:Sprite;
		private var _timer:Timer = new Timer(40, 0);
		private var _client:Object = new Object();
		private var _info:Object = new Object();
		private var _processTick:Number = 10;
		
        public function VideoPane()
		{
			//_netStream.client.onMetaData = function(obj){trace(obj)};
			//_client.onCuePoint = onCuePoint;
			//_client.onPlayStatus = onPlayStatus;
			_back = new Sprite();
			_video = new Video();
			/*
			_menu = new controlbar(this , _playerWidth-6,_playerHeight-_videoHeight-3);
			
			_menu.y = _videoHeight;
			_menu.x = 3;
			*/
			//drawback();
			_back.filters = [new GlowFilter(0x000000,0.75,8,8,1)];
			this.addChild(_back);
			this.addChild(_videoContainer);
			_videoContainer.addChild(_video);
			//this.addChild(_menu);
			this.alpha = 0;
			
			//unkonw :: there is a bug for init Stream that ocear when  StreetView Loaded ... 
			
			init();
        }
		
		
	
		
		private function draw():void{
		
		}
		
		private function init():void
		{
			connectStream();
			_netStream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			_netStream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			_timer.addEventListener(TimerEvent.TIMER, onTimer, false, 0, true);
			this.addEventListener(MouseEvent.CLICK , clickHandler)
			//render();
			//resize();
		}
		
		private function clickHandler(e):void
		{
			toggle();
		}
		private function closeHandler(e:*):void
		{
			stop();
		}
		
		private function connectStream():void{
			//_client.onPlayStatus = onPlayStatus;
			_netConnetction = new NetConnection();
			_soundTransform = new SoundTransform();
            _netConnetction.connect(null);			
			_netStream = new NetStream(_netConnetction);
			
			var clientObject:Object = new Object();
			clientObject.onMetaData = function(obj:Object) {
				this.totalTime = obj.duration;
				this.size = obj.datasize;
				this.hasVideo = obj.hasVideo;
				/*
				for (var key in obj) 
					trace(key + ": " + obj[key]);
				*/
				waveInit(false); //!obj.hasVideo
				videoInit();
			};
			
			_netStream.client = clientObject;
			//return;
			//
		}
		
		private function netStatusHandler(event:NetStatusEvent):void{
			
			trace(event.info.code)
			switch(event.info.code)
			{
				case "NetStream.Play.Stop" : 
					repeat();
					break;
				case "NetStream.Pause.Notify" : 
					_menu.playSwitch(0);
					break;
				case "NetStream.Unpause.Notify" : 
					_menu.playSwitch(1);
					break;
				default : 
					break;
			}
			
		}
		
		//自适应视频大小
		private function onTimer(e:TimerEvent):void 
		{
			if (_netStream.client.totalTime) {
				//trace(_netStream.time +":"+ _netStream.client.totalTime);
				var scale = _netStream.time / _netStream.client.totalTime;
				//_menu.processTo(scale);
			}

			drawWave();
			
		}
		
		private var useWave:Boolean = false;
		private var step:int = 1;
		private function waveInit(v:Boolean){
			useWave = v;
			step = Math.floor(256 / (_videoWidth-64));
			//trace(step)
		}
		
		private function videoInit():void
		{
			_oriwidth = _video.videoWidth;
			_oriheight = _video.videoHeight;
			render();
			this.visible = true;
			
			//trace(_netStream.client.onMetaData)
		}
		
		private var ba:ByteArray = new ByteArray();
		private function drawWave()
		{ 
			if(!useWave) return;
			_videoContainer.graphics.clear(); 
			_videoContainer.graphics.lineStyle(1,0xccff00); 
			//获取波形信息 ，数值在 -1, 1
			SoundMixer.computeSpectrum(ba,false); 
			
			//trace(step)
			//绘制声波曲线 
			for (var i = 0; i < _width - 64; i++) 
			{ 
				ba.position = 4*i*step; ///转到左声道
				//trace("step"+ba.position)
				var s = ba.readFloat()  ; 
				ba.position = 1024 +  4*i*step;//转到右声道
				s = (s + ba.readFloat()) * _videoHeight * 0.4 * 0.5; //取平均 并量化
				//if(s == -96) s = 0;//高音抑制
				//s = s * _videoHeight * 0.4 ;
				if (i > 0) 
					_videoContainer.graphics.lineTo(32 + i,_height / 2 + s ); 
				else
					_videoContainer.graphics.moveTo(32,_height  / 2 + s); 
			} 
			
			
		}


		private function drawback():void
		{
			
			_back.graphics.clear();
			_back.graphics.beginFill(0xff000000,0.6);
			_back.graphics.lineStyle(6,0xeeeeee);
			_back.graphics.drawRect(-3, -3, _width, _height);
			//_back.graphics.endFill();
			
		}

		public function load(v:String):void
		{
			_video.attachNetStream(_netStream);
			
			if(_videoURL == v && v) return;
			else 
				_videoURL = v ; 
			play();
		}
		
		
		public function play():void 
		{
			TweenNano.to(this,1,{alpha:1});
			_timer.reset(); _timer.start();_netStream.play(_videoURL);
			//_menu.playSwitch(1); 
		}
		

		
		private function move(v:Point):void{
			this.x = v.x ; this.y = v.y;
		}
		
		
		public function videoResize(w:Number,h:Number):void 
		{
			_playerWidth = w; _playerHeight = h;
			drawback(); videoInit();
		}
		
		
		public function setVol(a:Number,b:Number):void
		{
			_soundTransform =  _netStream.soundTransform;
			var _v  = _soundTransform.volume;
			var _vs = Math.sqrt(a*a + b*b);
			if(a>=-0.75&&a<=0.75){ //衰减 --> 1/r*r，
				_soundTransform.pan = Math.sin(a*Math.PI/2);//Math.max(_soundTransform.pan - 0.1,-1);
			}
			
			if(_vs<=4&&_vs>0.5){ //right 0.5 - 2 -- > 0.75
				_soundTransform.volume = 0.5/_vs;

			}
			_netStream.soundTransform = _soundTransform;
			
		}
		
		private function asyncErrorHandler(event:AsyncErrorEvent):void {
            // ignore AsyncErrorEvent events.
        }
		
		public function repeat():void { _netStream.seek(0); }
		
		public function pause(){ _netStream.pause(); _menu.playSwitch(0); }
		
		public function stop(){ _netStream.close(); _timer.reset();  _videoURL = ""; useWave = false;}
		
		public function toggle():void{ _netStream.togglePause(); _menu.playSwitch(); }
		
		public function seek(v:Number):void { trace(v);_netStream.seek(v);}
		
		public function seekBy(v:Number):void { trace(v); seek (_netStream.client.totalTime * v);}
		
		public function fullScreen():void{}
		
		public function destroy():void
		{
			stop();
		}
		
		override public function set width(v:Number):void
		{
			 _width = v; render()
		}
		
		override public function set height(v:Number):void
		{
			_height = v;render()
		}
		
		override public function get height():Number{return _height;}
		
		override public function get width():Number{return _width;}
		
		
		private function render():void
		{
			var r:Number = Math.min(_width / _oriwidth,_height /_oriheight);
			if(r>1) r= 1;
			
			_video.width = _oriwidth*r;
			_video.height = _oriheight*r;
			
			_video.x = Math.round((_width -_video.width) / 2);
			_video.y = Math.round((_height -_video.height) / 2);
			
		}
		
		
    }
}
	import flash.display.*;
    import flash.events.*;

    internal class controlbar extends Sprite
	{
		public var playbar:Sprite = new Sprite();
		public var menubar:Sprite = new Sprite();
		public var processbar:Sprite = new Sprite();
		public var isplay:Boolean = false;
		private var timebar:Shape = new Shape();
		private var playBtn:SimpleButton;
		private var pauseBtn:SimpleButton;
		private var fullBtn:SimpleButton;
		private var menuwidth:Number;
		private var menuheight:Number;
		private var main;
		
		public function controlbar(m , w,h){
			graphics.beginFill(0);
			graphics.drawRect(0, 0, w,h);
			
			menuwidth = w; menuheight = h; main = m;
			init();
			
		}
		
		private function init():void
		{
			addChild(playbar);
			addChild(processbar);
			addChild(menubar);
			initPlaybar();
			initprocess();
			initMenuBar();
			regListeners();
		}
		
		
		private function initprocess():void{
			
			
			var processBarMask:Shape = new Shape();
			processBarMask.graphics.beginFill(0xffffff,0.5)
			processBarMask.graphics.drawRect(0,0,menuwidth,3);
			processBarMask.graphics.endFill();
			
			
			
			
			timebar.graphics.beginFill(0x6b9b14);
			timebar.graphics.drawRect(0,0,menuwidth,3);
			timebar.graphics.endFill();
			timebar.scaleX = 0.1;
			
			processbar.addChild(processBarMask);
			processbar.addChild(timebar)
		}
		
		private function initMenuBar():void{
			fullBtn = new SimpleButton(getFullBtn(0xdddddd),getFullBtn(),getFullBtn(0x6b9b14),getFullBtn());
			fullBtn.x = 5;fullBtn.y = menuwidth - fullBtn.width - 3;
			menubar.addChild(fullBtn);
		}
		
		private function initPlaybar():void
		{
			
			playBtn = new SimpleButton(getPlayBtn(0xdddddd),getPlayBtn(),getPlayBtn(0x6b9b14),getPlayBtn());
			pauseBtn = new SimpleButton(getPauseBtn(0xdddddd),getPauseBtn(),getPauseBtn(0x6b9b14),getPauseBtn());
			
			playBtn.visible = false;
			playbar.x = playbar.y = 5;
			
			playbar.addChild(playBtn);
			playbar.addChild(pauseBtn);
			
		}
		
		private function regListeners()
		{
			playbar.addEventListener(MouseEvent.CLICK,playswitchHandler);
			menubar.addEventListener(MouseEvent.CLICK,fullHandler);
			processbar.addEventListener(MouseEvent.MOUSE_DOWN ,processHandler);
		}
		
		private function fullHandler(e:*):void
		{
			main.fullScreen();
		}
		
		private function processHandler(e:*):void
		{
			main.seekBy(processbar.mouseX / processbar.width);
		}
		
		private function playswitchHandler(e:*):void
		{
			main.toggle();
		}
		
		public function playSwitch(v:int = -1):void
		{
			isplay = (v==-1 ? !isplay : (v && true));
			pauseBtn.visible = isplay;
			playBtn.visible = !isplay;
		}
		
		private function getFullBtn(c:uint = 0xffffff):Shape{
			var btn = new Shape();
			btn.graphics.beginFill(c);
			btn.graphics.drawRect(0,1,16,10)
			btn.graphics.endFill();
			return btn;
		}
		private function getPlayBtn(c:uint = 0xffffff):Shape
		{
			var btn = new Shape();
			btn.graphics.beginFill(c);
			btn.graphics.moveTo(0,0);
			btn.graphics.lineTo(0,12);
			btn.graphics.lineTo(9,6);
			btn.graphics.lineTo(0,0);
			btn.graphics.endFill();
			return btn;
			
		}
		
		private function getPauseBtn(c:uint = 0xffffff):Shape{
			var btn = new Shape();
			//btn.graphics.lineStyle(3,c);
			btn.graphics.beginFill(c);
			btn.graphics.drawRect(0,1,4,10)
			btn.graphics.drawRect(6,1,4,10)
			/*btn.graphics.moveTo(2,0);
			btn.graphics.lineTo(2,10);
			btn.graphics.moveTo(8,0);
			btn.graphics.lineTo(8,10);*/
			btn.graphics.endFill();
			return btn;
		}
		
		public function processTo(v:Number):void{
			timebar.scaleX = v;
		}
		
		
		
		
	}
