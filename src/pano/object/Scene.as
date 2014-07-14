package pano.object{

	import org.papervision3d.cameras.Camera3D;
	import org.papervision3d.render.BasicRenderEngine;
	import org.papervision3d.core.render.filter.FogFilter;
	import org.papervision3d.core.math.Number3D;
	import org.papervision3d.core.math.Plane3D;
	import org.papervision3d.scenes.Scene3D;
	import org.papervision3d.view.Viewport3D;
	//import org.papervision3d.view.BitmapViewport3D;
 	
  	
	import org.papervision3d.view.layer.ViewportLayer;
	import org.papervision3d.view.layer.util.ViewportLayerSortMode;
	
	//import org.papervision3d.materials.MovieMaterial;
	import org.papervision3d.materials.BitmapMaterial;
	//import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.objects.primitives.Sphere;
	import org.papervision3d.events.InteractiveScene3DEvent;
	
	import org.papervision3d.materials.utils.BitmapMaterialTools;
	
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.view.stats.StatsView
	import org.papervision3d.events.*;

	import flash.events.EventDispatcher;
	import flash.events.Event;  
	import flash.events.MouseEvent;  
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.*;
	import pano.object.Sphere3D;
	import pano.object.Viewport;
	import pano.events.NoticeEvent;
	

		
	public class Scene extends EventDispatcher{
		
		private var _container:Sprite;
		public var _Sphere3D:Sphere3D;
		//public var _Arrow:Arrow3D;
		
		private var _viewport:Viewport;
		private var _render:BasicRenderEngine;
		private var _scene:Scene3D;
		public var _camera:Camera3D;
		
		static private const PREY:Number = 270; //模型默认显示中心位于 (0.75,0.6)
		
		private var _autoScaleToStage:Boolean;
		public function Scene(container:Sprite , autoScaleToStage:Boolean = true) 
		{
			_container = container;_autoScaleToStage = autoScaleToStage;
			init();
			initObject();
		}
		
		
		private var rotMatrix:Matrix3D = new Matrix3D();
		public function init(){
			_render		= new BasicRenderEngine();
			_scene		= new Scene3D();
			_camera		= new Camera3D();
			_viewport 	= new Viewport(550,400,_autoScaleToStage);
			//_viewport.interactive = true;//允许交互
			_viewport.containerSprite.sortMode = ViewportLayerSortMode.Z_SORT;
			_container.addChild(_viewport);
			//var stats:StatsView = new StatsView(_render);
			//_container.addChild(stats)
			_camera.z = 0;//-1000;
			_camera.zoom = 1;//摄象机的缩放参数，
			_camera.focus = 550;//摄象机的焦距
			
			updateRotMatrix();
			//_camera.useCulling = true;
		}
		
		private function initObject():void
		{
			_Sphere3D = new Sphere3D();
			//_Sphere3D.addChild(_Arrow);
			_scene.addChild(_Sphere3D);

		}
		
		
		
		public function rendering()
		{
			_render.renderScene(_scene,_camera,_viewport);
		}
		
		public function getPrintableBitmap():Bitmap 
		{
			return new Bitmap(_viewport.bitmapData);
		}
		
		
		public function sleep(v:Boolean = false):void
		{
			_viewport.visible = !v; 
		}
		
		public function normaliseToSphericalCoord(p:Point):Point
		{
			p.x *=360; p.y *= 180;
			p.y = 90 - p.y ; 
			p.x = 270 - (p.x + _Sphere3D.sphereRot); //初始位置在  270 °
			return p;
		}
		
		
		
		public var heading:Number = 0;
		
		public var pitch:Number = 0;
		
		// 调整图片 heading，此处v值 = 指定方向（正北）与 图片中心（拍摄方向） 的顺时针夹角  ,使所有图片对齐至 指定方向
		// pv3d 初始化后的位置位于 lng =  270° 处
		public function set dir(v:Number) :void { _Sphere3D.sphereRot = v - PREY ;}
		
		public function get dir():Number { return (_Sphere3D.sphereRot + PREY)%360 } 
		
		public function get zoom():Number { return _camera.zoom ; }
		
		public function set zoom(v:Number):void { _camera.zoom = v ;}
		
		
		
		private var rotX:Number = 0;
		private var rotY:Number = 0;
		public function set rotationX(v:Number):void { 
		
			//if( v > 89.999 || v > config.maxRotationX) dx = Math.min(89.999,config.maxRotationX);
			//if( dx < -89.999 || dx < 0-config.maxRotationX) dx = Math.max(-89.999,0-config.maxRotationX);
			pitch = v;
			rotX = v; v = 0 - v;
			_camera.rotationX = v;
			//_camera.orbit(90 - v, -90); //图片偏转 的角度;
			updateRotMatrix()
			//_camera.rotationX = v;
		}
		
		public function get rotationX():Number { return rotX ;}
		
		public function get rotationY():Number { return _Sphere3D.rotationY ;}
		
		public function set rotationY(v:Number):void { 	_Sphere3D.rotationY = v ; heading = v;}
		
		private function updateRotMatrix():void{
			rotMatrix = new Matrix3D();
			rotMatrix.appendRotation(rotX, new Vector3D(1,0,0));
			rotMatrix.appendScale(1,-1,1);//y为反向;
			rotMatrix.appendTranslation(0,0,0);
		}
		
		
		
		public function set hideArrow(b:Boolean):void {}
		
		public function get mousePosition():Point { return new Point(_viewport.mouseX , _viewport.mouseY)}
		
		public function get mat():BitmapData { return _Sphere3D.mat; }
		
		public function set mat(bmd:BitmapData):void  { _Sphere3D.mat = bmd ;}
		
		public function get focus():Number { return _camera.focus; }
		
		public function set focus(v:Number) { _camera.focus = v;}
		
		// 来自 pv3d 显示中心 、 heading 、 以及手工转动 的偏移
		private function get offset():Number { return _Sphere3D.rotationY; }
		

		
		public function get viewBound():Array
		{
			//增加0.1 的边界
			var lt = screenToPano(new Point(-0.6*_viewport.width,-0.6*_viewport.height)) ,
				rb = screenToPano(new Point( 0.6*_viewport.width, 0.6*_viewport.height)) ;
			if(lt.x>180 && rb.x<180)  lt.x -= 360;
			// 返回标准边界  和 滚动到下一次的边界
			return  [[  // [-0.5 , 0.5]
					  	lt	,	new Point(rb.x,lt.y) ,
						rb	, 	new Point(lt.x,rb.y) ,
					],
					[	// [0.5 , 1.5]
					 	new Point(lt.x+360,lt.y) , new Point(rb.x+360,lt.y) , 
						new Point(rb.x+360,rb.y) , new Point(lt.x+360,rb.y) 
					]]
		}
		
		public function screenToPano(p:* = null):Point
		{
			
			if(p == null) { p = new Point(_viewport.containerSprite.mouseX , _viewport.containerSprite.mouseY);}
			var p1:Number3D = _camera.position;
			var p2:Number3D = Number3D.add( _camera.unproject(p.x , p.y), p1 );
			
			var crossPoint:Number3D = _Sphere3D.crossTo(p1,p2);
			crossPoint.rotateY(PREY - _Sphere3D.rotationY);
			var u = Math.atan2(crossPoint.z , crossPoint.x); // -pi ~  pi
			var v = Math.acos( crossPoint.y / _Sphere3D.radius); // y ais
			u = u/PI2; v = v/PI;
			u = 0 - u ;//+ 0.5;
			if(u<0) u = u+1;
			u = Math.round(u*10000)/10000;
			v = Math.round(v*10000)/10000;
			u *= 360 ; v*= 180;
			
			return new Point(u,v)
		}
		
		//_Sphere3D.sphereRot 使得 坐标始终和 屏幕显示一致
		// p 为球面经纬坐标 0-360 0-180
		private var PI_2 = Math.PI / 180;
		private var PI2:Number = Math.PI * 2;
		private var PI :Number = Math.PI;
		
		public function panoToScreen(p:Point):Point{
			
			var r = _Sphere3D.radius;
			//等效转换 此处 p.x =>  rotationY
			var u = (PREY - p.x - _Sphere3D.rotationY) * PI_2; ;//(0 - p.x - (_Sphere3D.rotationY + _Sphere3D.sphereRot)) * PI_H;
			//var v = (p.y - rotX/180) * Math.PI; //这个等效转换 不正确
			var v = p.y * PI_2;
			//trace(p.x+":"+p.y)
			//球面坐标转换为 空间坐标,
			var ix = r*Math.sin(v)*Math.cos(u);
			var iy = r*Math.cos(v);
			var iz = r*Math.sin(v)*Math.sin(u);
			var nx = Utils3D.projectVector(rotMatrix,new Vector3D(ix,iy,iz))
			var scale = focus * zoom / nx.z ;
			ix = nx.x * scale ; iy = nx.y * scale; 
			
			ix += _viewport.viewportWidth*0.5;
			iy += _viewport.viewportHeight*0.5;
			
			
			return new Point(ix , iy);
			
		}

		
		public function get viewport():Sprite{ return _viewport;}
		
		public function set viewportWidth(v:Number){ _viewport.viewportWidth = v;}
		
		public function set viewportHeight(v:Number){ _viewport.viewportHeight = v ;}
		
		public function get viewportWidth():Number{ return _viewport.viewportWidth ;}
		
		public function get viewportHeight():Number{ return _viewport.viewportHeight ;}
		
		//public function get sphereZ(){ return _sphere.z }
		
		//public function set sphereZ(v){ return _sphere.z = v; }
		
		public function destroy():void
		{
			_Sphere3D.destroy();
			//_Arrow.destroy();
			_viewport.destroy();
			_render.destroy();
			_container.removeChild(_viewport);
			_scene.removeChild(_Sphere3D);
			//_scene.removeChild(_Arrow);
			_render = null;
			_scene = null;
			_camera = null;
			rotMatrix = null;
		}
		
		static public const PI :Number = Math.PI;
		static public const PI2:Number = Math.PI * 2;
		static public var toRADIANS :Number = Math.PI/180;
	}
	
}

/*
focus：摄像机到viewport
zoom：是viewport的放大倍数
h：假设为viewport高度的一半
a：半个FOV

他们满足下面的公式
tan α = h / (zoom * focus).


*/