package pano.core{
	
	import pano.utils.*;
	import pano.events.*;
	import pano.controls.*;
	import pano.object.*;
	import pano.utils.*;

	import flash.system.Capabilities;
	import flash.system.Security;
	import flash.display.MovieClip;  
	import flash.display.Bitmap; 

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display.StageDisplayState;
	import flash.display.StageQuality;
	import flash.text.*;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.filters.BlurFilter;
	//****************
	import flash.filters.*;
	import flash.geom.Point;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;;
	
	import flash.display.BitmapData;
	import flash.net.LocalConnection;
	import flash.events.DataEvent;
	
	import pano.utils.TweenNano;
	import pano.ExtraInterface;
	//import flash.system.System;
	


	public class Pano extends Sprite implements IPano{
		
		private var VER:Number = 1.1;
		private var _scene:Scene;
		private var _road:Arrow3D;
		private var EIF:ExtraInterface;
		private var _animationer:Animationer;
		private var _animationLayer:Bitmap = new Bitmap(new BitmapData(1,1,true) , "auto" , true);
		public var tweening:Boolean = false;

		// wei fangbian 计算最近方向
		//public function istweening():Boolean { }
		public function getViewBound():Array { return _scene.viewBound; }
		
		public function get sz(){ return _scene._Sphere3D._sphere.z;}
		
		public function set sz(v){ _scene._Sphere3D._sphere.z = v ; render()}
		
		public function get sx(){ return _scene._Sphere3D._sphere.x;}
		
		public function set sx(v){ _scene._Sphere3D._sphere.x = v ; render()}
		
		
		public function get rot():Number { return _scene.rotationY ; }
		
		public function setfocus(v:Number):void { _scene.focus = v ; render();}
		
		public function getfocus():Number { return _scene.focus;}
		
		public function get focus():Number{ return _scene.focus; }
		
		public function set focus(v:Number){ _scene.focus = v ; render(); }
		
		private function get animationLayer():Bitmap{ return _animationLayer; }
		
		public function get viewport():Sprite{ return _scene.viewport;}
		
		public function hideArrow(v:Boolean):void { }
		
		public function setWidth(v:Number):void { width = v }
		
		public function setHeight(v:Number):void { height = v;}
		
		public function setSize(w:Number , h:Number):void { width = w; height = h;}
		
		public function move(xpos:Number , ypos:Number):void { this.x = xpos ; this.y = ypos; }
		

		public function normaliseToSphericalCoord(p:Point):Point
		{
			return _scene.normaliseToSphericalCoord(p);
		}
		
		/*
		public function panTo(p:Point):void{
			_scene.rotationX = p.y ; //上下
			_scene.rotationY = p.x ; //左右
		}
		*/
		override public function set width(v:Number):void{ _scene.viewportWidth = v; }
		
		override public function set height(v:Number):void{ _scene.viewportHeight = v;}
		
		override public function get width():Number { return _scene.viewportWidth; }
		
		override public function get height():Number { return _scene.viewportHeight; }
		//public function get 
		
		//交互操作 会侦听鼠标移动，在某些状态 造成较高CPU 负担，可用此函数进入 节约模式
		public function sleep(v:Boolean = false):void
		{
			if(v) maskScreen();
			else _animationLayer.visible = false;
			_scene.sleep(v); 
		}
		
		public function setHand(v:Boolean):void
		{
			_road.setHand(v);
		}
		
		public function Pano(_autoScaleToStage:Boolean = true) { 
			
			_scene = new Scene(this , _autoScaleToStage); //  + 1m ram
			_road = new Arrow3D(Config.getGlobalConfig("useground"));
			EIF = ExtraInterface.getInstance();
			addChild(_road);
			addChild(_animationLayer);
			_animationer = new Animationer(_animationLayer , this);
			_animationer.addEventListener("AnimationToggle",animationToggle);
			_animationer.addEventListener("AnimationEnd",animationEnd);
			//StreetView_beforeloadingmap事件 早于 加载 panomap
		}
		
		public function init():void
		{
			EIF.addPluginEventListener("streetview_beforeloadingmap",animationBefore);
		}
		public function setArrow(link:Array,dir:Number):void
		{
			_road.setArrows(link);//调整 道路
			_scene.dir = dir;//调整 朝向
			for(var i:int=0;i<link.length;i++)  Logger.trace(1,link[i].rot)
			
		}
		
		private var _tmpbmd:BitmapData;
		private var _bmdReady:Boolean = false;
		
		public function setPanoData(v : BitmapData , firstLoad:Boolean = false):void
		{
			//v.scroll(5000*rot/360,0);
			_tmpbmd = v;
			_bmdReady = true; //标识 bmd 已经准备完毕
			
			//首次加载不执行任何动画
			if(firstLoad)
			{
				switchmat();
				firstLoad = false;
				animationEnd();
				return;
			}
			//若镜头拉伸动画已结束 ,则直接替换材质
			if(_animationer.endAnimate) switchmat();

		}
		
		public function setBitmapData(v:BitmapData):void
		{
			//_tmpbmd = v;
			//trace("switch pano")
			//若不是动画过程 则直接切换
			if(_animationer.endAnimate)
			{
				_scene.mat = v;
				BitmapTools.mirrorBitmapX(_scene.mat);
				//Logger.trace(1,"switch full bmd ");
				render(); 
			}else
			{
				_tmpbmd = v;
				_bmdReady = true; //标识 bmd 已经准备完毕
			}
		}
		
		public function switchmat():void
		{
			setArrow(data.link,data.dir);
			_scene.mat = _tmpbmd;
			Logger.trace(1,"Loading Roads");
			
			BitmapTools.mirrorBitmapX(_scene.mat);
			//调整道路
			
			_bmdReady = false;
			//执行一次render 使得 切换材质和道路 生效
			render(); 
			//执行第二部分动画
			_animationer.playToggle();
			
			
		}
		
		public function setBitmapDataTile(v:BitmapData , ix:int , iy:int):void
		{
			BitmapTools.swapTile(_scene.mat , v , ix , iy);
			render(); 
		}
		
		//public function print():
		public function maskScreen():void
		{
			//if(animationLayer.visible) return; //已经执行
			//TweenNano.killTweensOf(animationLayer);
			_animationLayer.bitmapData = printScreen();
			//animationLayer.bitmapData.applyFilter(animationLayer.bitmapData,animationLayer.bitmapData.rect , new Point(0,0), new BlurFilter(4,4,1));
			_animationLayer.alpha = 1;
			_animationLayer.visible  = true;
			
		}
		
		public function printScreen(b:Boolean = false):BitmapData
		{			
			_road.visible = false;
			var bmd:BitmapData = new BitmapData(this.width , this.height , true)//_scene.getPrintableBitmap(); //new Bitmap(_viewport.bitmapData);
				bmd.draw(this,null,null,null,bmd.rect,true);
			_road.visible = true;
			return bmd;
		}
		
		
		private var data:Object;
		//第一部分动画
		private function animationBefore(e:* = null):void
		{
			//当前svid 的位置信息、道路方向、动画方向信息
			data  = e.feature as Object;
			_road.visible = false; tweening = true;
			_animationer.play(data);
		}
		
		//第一部分动画 结束后执行 复制场景
		private function animationToggle(e:* = null):void
		{
			// 复制当前场景 做动画效果
			maskScreen(); sx = 0; sz = 0;
			//如果bmd已经加载，目前正在等待动画，则切换材质
			if(_bmdReady) switchmat();
		}
		
		//第二部分动画
		private function animationEnd(e:* = null):void
		{
			_animationLayer.visible = false;
			_animationLayer.bitmapData = new BitmapData(1,1,true);
			EIF.dispatchEvent(new Event("switchend"));
			_bmdReady = false;
			_road.visible = true;
			//_preLink = null; _preRot = null;
			tweening = false;
			//EIF.get("disableKeyBoard",disable)
		}
		
		private function doClearance() : void 
		{
			try {
				new LocalConnection().connect('foo');
				new LocalConnection().connect('foo');
			} catch (e:Error) { }
		}
		
		
		public function getMousePosition():Point
		{
			return _scene.mousePosition;
		}
		
		
		public function render(end:Boolean = true , mode:int = 0) {
			//if(mode==0) stage.quality = "BETTER";
			if(mode==0) stage.quality = "medium"
			_scene.rendering();
			if(end) 
			{
				stage.quality = "BETTER";
				doClearance();
				//_rotationData.y = (_rotationData.y + 36000)%360;
			}
			_road.rotateX(90 - _scene.rotationX);
			_road.rotateY(_scene.rotationY);
			dispatchEvent(new Event("render"));
		}
		
		public function rendering():void
		{
			//this.addEventListener(Event.ENTER_FRAME , );
		}
		
		private var _rotationData:Point = new Point(0,0);
		
		public function killTween():void 
		{
			TweenNano.killTweensOf(_scene);
			_rotationData.x = _scene.rotationX%360; 
			_rotationData.y = _scene.rotationY; 
		}

				
		public function toUp():void		{ panBy(new Point(-90 , 0) , true , Config.playTimeY); }
		
		public function toDown():void	{ panBy(new Point( 90 , 0) , true , Config.playTimeY); }
		
		public function toLeft():void	{ panBy(new Point(0 , 36000) , true , Config.playTimeX*100);}
		
		public function toRight():void	{ panBy(new Point(0 , -36000) , true , Config.playTimeX*100); }
		
		
		
		
		public function rotate(v , repeat:Boolean = true):void
		{
			panBy(new Point( v.y * 36000 , v.x * 36000) , true , Config.playTimeY*100);
		}
		
				
		//相对惯性坐标系(与世界坐标系平行，原地位于物体坐标系原点) 旋转
		public function getHeading(noWrap:Boolean = false):Number { return noWrap ? -_scene.rotationY : ((0 - _scene.rotationY+360000)%360); }
		public function setHeading(v:Number) { _scene.rotationY = -v; }
		
		//即将撤销的用法 使用 setHeading代替
		public function rotateY(v:Number , a:Boolean = true):void{ panBy(new Point(0 , 0 - v) , a);}
		
		
		//相对惯性坐标系 旋转
		public function getPitch():Number{ return _scene.rotationX; }
		public function setPitch(v:Number) { _scene.rotationX = v; }
		//即将撤销的用法 使用 setPitch代替
		public function rotateX(v:Number) : void { setPitch(v);}
		
		public function setPov(obj:Object , sub:Boolean = false):void{
			
			var h:Number , p:Number;
			if(obj.heading != undefined)
				h = sub ? (getHeading() + obj.heading) : obj.heading;
			if(obj.pitch != undefined)
				p = sub ? (getPitch() + obj.pitch) : obj.pitch;
				
			p = p > Config.maxRotationX ? Config.maxPitch : (p < Config.minPitch ? Config.minPitch : p)
			//trace(h+":"+p);
			if(h) setHeading(h); if(p) setPitch(p);
			render(false);
		}
		
		public function getPov(noWrap:Boolean = false):Object{
			return {heading : getHeading(noWrap) , pitch : getPitch() };
		}
		
		public function setZoom(v:Number , sub:Boolean = false , animate:Boolean = true):void
		{
			v = sub ? (this.getZoom() + v) : v;
			var time = Math.abs(v - zoom) * Config.zoomTime;
			if( v>Config.maxZoomLevel ) v = Config.maxZoomLevel;
			if( v<Config.minZoomLevel ) v = Config.minZoomLevel;
			if(animate){
				TweenNano.to(_scene,time,{zoom:v,onUpdate:render,onUpdateParams:[false],onComplete:render , ease:TweenNano.LinerEase});
			}
			else
			{
				_scene.zoom = v;
				render();
			}
		}
		
		public function getZoom():Number { return _scene.zoom;}
		
		public function toRound():void{ panBy(new Point(0 , Config.playRot*-360) , true , Config.playTimeX); }
		
		public function setPano(v:String , p = null) : void
		{
			if(this.hasOwnProperty(v)){
				if(p==null) this[v]();
				else this[v](p);
			}
		}
		/*
		public function faceTo(p:Point , noWarp:Boolean = false):void
		{
			var h:Number = (180 + p.x)%360 , pitch:Number = 90 - p.y;
			setHeading(h); setPitch(pitch);
			Stack.face = null;
		}
		*/
		public function panBy(p:Point , animate:Boolean = false , time:Number = 0.2):void
		{
			var dx = _rotationData.x + p.x; 
			var dy = _rotationData.y + p.y;
			if( dx > 89.999 || dx > Config.maxPitch) dx = Math.min(89.999,Config.maxPitch);
			if( dx < -89.999 || dx < Config.minPitch) dx = Math.max(-89.999,Config.minPitch);
			
			_rotationData = new Point(dx,dy);

			if(animate){
				TweenNano.to(_scene,time,{rotationX:dx,rotationY:dy ,onUpdate:invalidate,onComplete:render})//onUpdateParams:[false],
			}
			else
			{
				_scene.rotationX = dx;
				_scene.rotationY = dy;
				render(false); // 降低画质刷新，请完毕后 调用 一次 render(true) 恢复画质
			}
		}
		
		public function get zoom():Number { return _scene.zoom;}
		
		public function zoomIn() :void{ setZoom(0.5 , true , true); }
		
		public function zoomOut():void{ setZoom(-0.5 , true , true); }
		
		public function zoomTo(toMax:Boolean = true):void{ setZoom(toMax?Config.maxZoomLevel:Config.minZoomLevel , false ,true ); }
		
		public function panoToScreen(p:Point):Point{
			return _scene.panoToScreen(p);
		}
		
		public function screenToPano(p:Point = null):Point{
			return _scene.screenToPano(p);
		}
		
		public function mode3D(b:Boolean):void 
		{
			if(b) BitmapTools.set3dOn(_scene.mat);
			else BitmapTools.set3dOff(_scene.mat);
			render();
		}
		
		public function fullScreen():void
		{

			if (stage.displayState == StageDisplayState.NORMAL)
				stage.displayState = StageDisplayState.FULL_SCREEN;
			else
				stage.displayState = StageDisplayState.NORMAL;
			
			render();
		}
		
		public function destroy():void
		{
			
			removeChild(_animationLayer);
			
			_animationLayer.bitmapData.dispose();
			
			_animationLayer = null;
			//_animationer._displayObject.bitmapData.dispose();
			//trace(_animationer._displayObject.bitmapData)
			_animationer = null;
			
			_scene.destroy();

			_scene = null;
			
			
		}
		
		protected function invalidate():void
		{
			addEventListener(Event.ENTER_FRAME, onInvalidate);
		}
		
		private function onInvalidate(event:Event):void
		{
			render(false);
			removeEventListener(Event.ENTER_FRAME, onInvalidate);
			
		}
		
		
		/*
		private var old = new Point(Capabilities.screenResolutionX,Capabilities.screenResolutionY);
		private var useAutoScaleToStage:Boolean = Config.autoScaleToStage==0?((Capabilities.screenResolutionX/Capabilities.screenResolutionY)>1.77):(Config.autoScaleToStage==1);
		*/
		/*
		public function resize(){
			if(Config.autoScaleToStage) {
				var dix =  (stage.stageWidth)/old.x;
				var diy =  (stage.stageHeight)/old.y;
				if(Math.abs(dix) >0.01 && Math.abs(diy) >0.01)
					_scene.focus = Math.floor(Config.focus *(Math.abs(dix)>Math.abs(diy)?dix:diy));
			}
			render();
		}
		*/
		
	}
}