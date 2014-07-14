package {
	
	import flash.display.*;
	import flash.geom.*;
	import flash.events.*;
    import flash.net.URLRequest;
	import flash.filters.GlowFilter;
	import pano.utils.TweenNano;
	import pano.utils.Geometry;
	import pano.ExtraInterface;
	

	import org.openscales.core.Map;
	import org.openscales.core.basetypes.Resolution;
	import org.openscales.core.utils.Trace;
	import org.openscales.core.control.LayerManager;
	import org.openscales.core.control.MousePosition;
	import org.openscales.core.control.OverviewMap;
	import org.openscales.core.control.PanZoomBar;
	import org.openscales.core.handler.feature.SelectFeaturesHandler;
	import org.openscales.core.handler.mouse.DragHandler;
	import org.openscales.core.handler.mouse.WheelHandler;
	import org.openscales.core.style.Style;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.geometry.basetypes.Size;
	

	import org.openscales.core.feature.*;
	import org.openscales.core.layer.*;
	import org.openscales.core.style.Style;
	import org.openscales.geometry.Point;
	import org.openscales.proj4as.ProjProjection;
	
	public class NavMap extends Sprite
	{
		private var _viewport:Shape;
		private var _border:Shape;
		private var _close:Sprite;
		private var _max:Sprite
		private var _contentContainer:Sprite = new Sprite();;
		private var _content:DisplayObject;
		private var _man:Man;
		private var _focus:Focus;
		public var _width:Number= 550;
		public var _height:Number = 250;
		private var _padding:Number = 10;
		private var _ready:Boolean = false;
		private var _lastOp:flash.geom.Point;
		
		private var _rot:Number = 0;
		private var _map:Map;
		private var _markerLayer:VectorLayer;
		
		private var EIF:ExtraInterface;
		
		public function NavMap(){
			
			
			if (stage == null)
			{
				this.addEventListener(Event.ADDED_TO_STAGE, this.startPlugin);
				this.addEventListener(Event.REMOVED_FROM_STAGE, this.stopPlugin);
			}else
			{
				registerEvent();
			}
		}
		
		
		private function startPlugin(e:Event = null):void
		{
			
			stage.showDefaultContextMenu = false;
			EIF = ExtraInterface.getInstance();
			if(EIF.ready) 
			{
				EIF.trace((new Date).toLocaleTimeString()+" : Loading NavMap(User Ver 1.0) Plugin Success ... ");
				EIF.set("navToggle",toggle);
				EIF.set("setNavRot" , setNavRot);
				EIF.set("setNavDragable",setDragable);
				EIF.set("navRot",getNavRot);
				EIF.set("getManPosition",getManPosition)//getManPosition
				//EIF.set("hide")
				EIF.addPluginEventListener(ExtraInterface.PLUGINEVENT_REGISTER, this.registerEvent);
				EIF.addPluginEventListener("notice_switcharea",switchHandler);
			}
			
			this.removeEventListener(Event.ADDED_TO_STAGE, this.startPlugin);
		}
		
		private function stopPlugin(e):void
		{
			unregListeners();
			
			EIF.removePluginEventListener(ExtraInterface.PLUGINEVENT_REGISTER, this.registerEvent);
			EIF.removePluginEventListener("notice_switchpano",switchHandler);
			
			
			for(var i:int = _contentContainer.numChildren-1 ; i>=0 ; i--)
			{
				_contentContainer.removeChildAt(i);
			}
			_content = null;
			//_contentContainer.removeChild(_man);
			this.removeChild(_contentContainer);
			
			trace((new Date).toLocaleTimeString()+" : UnLoad NavMap Plugin Success ! ");
				
		}
		
		private function registerEvent(e:* = null)
		{
			var center =  (EIF.call("getPluginsConfig" , "navmap").center || "0,0").split(",");
			var layers =  (EIF.call("getPluginsConfig" , "navmap").layers || "").split(",");
			var zoom   =  3;//"GOOGLE_SATELITE,TDT_MERC_TRAN"parseInt( (EIF.call("getPluginsConfig" , "navmap").zoom   || "10") );
			var nav:String = EIF.call("getPluginsConfig" , "navmap").image || "nav.jpg";
			_map = new Map(_width,_height,"EPSG:900913");

			_map.center = new Location(parseFloat(center[1]),parseFloat(center[0]),"EPSG:4326");
			
			_map.resolution = new Resolution(SoulMap.resolutionsArray[zoom],"EPSG:900913");
			_map.maxResolution = new Resolution(SoulMap.resolutionsArray[3],"EPSG:900913");
			_map.minResolution = new Resolution(SoulMap.resolutionsArray[2],"EPSG:900913");
			_map.defaultZoomInFactor = 0.5;
			_map.defaultZoomOutFactor = 1;
			//_map.backTileColor = 0x00ffffff;
			//_map.restrictedExtent = new Bounds(-20037508, -20037508,20037508, 20037508.34,new ProjProjection("EPSG:900913"));
			for(var i:int = 0 ; i<layers.length ; i++)
			{
				//SoulMap[layers[i]] && _map.addLayer( new SoulMap(layers[i] , SoulMap[layers[i]] ))
			}
			
			_map.addLayer(new ImageLayer("navmap",nav , new Bounds(-20037508, -20037508,20037508, 20037508.34,new ProjProjection("EPSG:900913"))));
			//ImageLayer

			//_map.addControl(new WheelHandler());
			_map.addControl(new DragHandler());
			
			this.addChild(_map);
			
			_markerLayer = new VectorLayer("featureLayer");
			//var marker:Marker = new Marker(new org.openscales.geometry.Point(108,34 ) );
			//marker.image = Focus;
			var k = EIF.call("getRoads");
			
			for(var key:String in k)
			{
				var p = k[key].position;
				_markerLayer.addFeature( SoulMarker.createDisplayObjectMarker(new Focus(k[key].start , p) ,  new Location(p.y, p.x , "EPSG:4326")) );
				//allpic.push( [ k[i].start ,k[i].thumb , k[i].title] );
			}
			_man = new Man();
			_manMarker = SoulMarker.createDisplayObjectMarker(_man,  new Location(30, 30 , "EPSG:4326")) ;
			_markerLayer.addFeature(_manMarker );
			
			_map.addLayer(_markerLayer)
			
			if(prepoint) _manMarker.setPosition( prepoint );
			
			init();
		}
		
		
		private var _manMarker : SoulMarker;
		private var prepoint;
		
		private function init():void{
			
			_viewport = new Shape();
			_viewport.visible = false;
			this.mask = _viewport;
			_border = new Shape();
			
			this.addChild(_viewport);
			//this.addChild(_contentContainer);
			this.addChild(_border);
		

			//_contentContainer.addChild(_focus);
			//_contentContainer.addChild(_man);
			drawStyle();
			
			regListeners();
			resize();
			
		}
		
		
		
		public function dispose():void
		{
			(_content as Bitmap).bitmapData.dispose(); _content = null;
		}
		
		private function regListeners():void
		{
			
			//_max.addEventListener(MouseEvent.CLICK,max_mouseClickHandler,false,0,true);
			
			_man.arrow.addEventListener(MouseEvent.MOUSE_DOWN,panSprite_mouseDownHandler,false,0,true);
			_man.man.addEventListener(MouseEvent.MOUSE_DOWN,dragSprite_mouseDownHandler);
			//_contentContainer.addEventListener(MouseEvent.CLICK,nodeClickHandler,false,0,true);
			stage.addEventListener(Event.RESIZE, resize,false,0,true);
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN, this.keyDownHandler);
			_map.addEventListener(MouseEvent.CLICK , onMap);
			
			EIF.addPluginEventListener("render",renderHandler);
		}	
		
		private function onMap(e)
		{
			
			if(e.target is Focus)
			{
				EIF.call("viewTo",(e.target as Focus).id )
			}else
			{
				var k = _map.getLocationFromMapPx(new Pixel(_map.mouseX,_map.mouseY) , _map.resolution).reprojectTo("EPSG:4326");
				EIF.trace(k.toString());
			}
			
			//EIF.trace(e.target);
		}
		
		private function unregListeners():void
		{
			
			stage.removeEventListener(Event.RESIZE, resize);
			//_contentContainer.addEventListener(MouseEvent.CLICK,testHandler,false,0,true);
			/*
			_max.removeEventListener(MouseEvent.CLICK,max_mouseClickHandler);
			_man.arrow.removeEventListener(MouseEvent.MOUSE_DOWN,panSprite_mouseDownHandler);
			*/
			_man.man.removeEventListener(MouseEvent.MOUSE_DOWN,dragSprite_mouseDownHandler);
			
			this.stage.removeEventListener(KeyboardEvent.KEY_DOWN, this.keyDownHandler);
			
			EIF.removePluginEventListener("render",renderHandler);
		}
		
		private function keyDownHandler(event):void
		{
			  var code:int = event.keyCode;
			 
			  if(code==87) EIF.trace("rot : [" + int(_rot+3600)%360+"]")
			  
		}
		
		private function drawStyle():void
		{
			_viewport.graphics.clear()
			_viewport.graphics.beginFill(0);
			_viewport.graphics.drawRect(0, 0, _width, _height);
			_viewport.graphics.endFill();
			
			_border.graphics.clear();
			
			_border.graphics.beginFill(0xffffff,0);
			_border.graphics.drawRect(0, 0, _width, _height);
			_border.graphics.endFill();
			
			_border.graphics.lineStyle(2,0xffffff);
			_border.graphics.lineTo(_width,0);
			_border.graphics.lineTo(_width,_height-1);
			/*_border.graphics.moveTo(0,0);
			_border.graphics.lineTo(0,_height);*/
			
			
			//_tips.y = _height + 5; //_tips.x = _width - _tips.width; 
			//this.filters = [new GlowFilter(0xfafafa,0.4,2,2)];
			if(ishide) _viewport.height = 0;
			else _viewport.height = _height;
			
		}
		
		
		private function switchHandler(e):void{ setPosition( e.feature.position );}
		
		private function renderHandler(e):void{ if(!dragState) {setNavRot(EIF.call("getheading"));} }
		
		
				
		private var nextNode:String;
		private var dragState = false;
		
		private function dragSprite_mouseDownHandler(e):void
		{
			dragState = true;
			_man.startDrag(false,this.getBounds(this));
			_man.stage.addEventListener(MouseEvent.MOUSE_MOVE,dragSprite_mouseMoveHandler);
			_man.stage.addEventListener(MouseEvent.MOUSE_UP,dragSprite_mouseUpHandler);
		}
		
		
		private function dragSprite_mouseMoveHandler(e):void
		{
			//nextNode = EIF.call("getpano",fromViewToNormalise( new Point(this.mouseX , this.mouseY)) )
			//EIF.trace(fromViewToNormalise( new Point(this.mouseX , this.mouseY)).toString())
			if(nextNode!= "") 
			{
				_focus.position = EIF.call("getposition",nextNode);
				_focus.visible = true;
				refresh(_focus);
			}
			
		}
		
		private function dragSprite_mouseUpHandler(e):void
		{
			_man.stage.removeEventListener(MouseEvent.MOUSE_MOVE,dragSprite_mouseMoveHandler);
			_man.stage.removeEventListener(MouseEvent.MOUSE_UP,dragSprite_mouseUpHandler);
			_man.stopDrag();
			_focus.visible = false;
			_man.position = _focus.position;
			dragState = false;
			refresh();
			if(nextNode!="") EIF.call("viewTo",nextNode);
		}
		
		
		private function panSprite_mouseDownHandler(e):void
		{
			//if(e.target)
			dragState = true;
			_man.stage.addEventListener(MouseEvent.MOUSE_MOVE,panSprite_mouseMoveHandler,false,0,true);
			_man.stage.addEventListener(MouseEvent.MOUSE_UP,panSprite_mouseUpHandler,false,0,true);
			
			setNavRot(Math.atan2(_man.mouseY , _man.mouseX)*180/Math.PI ,true);
		}
		
		private function panSprite_mouseMoveHandler(e):void
		{
			setNavRot(Math.atan2(_man.mouseY , _man.mouseX)*180/Math.PI ,true);
		}
		
		private function panSprite_mouseUpHandler(e):void
		{
			dragState = false;
			_man.stage.removeEventListener(MouseEvent.MOUSE_MOVE,panSprite_mouseMoveHandler);
			_man.stage.removeEventListener(MouseEvent.MOUSE_UP,panSprite_mouseUpHandler);
			EIF.call("render");
		}
		
		
		public function setPosition(t:flash.geom.Point = null):void
		{
			
			if(t==null) t = EIF.call("getposition") ;
			
			//EIF.trace(t);
			if(_manMarker) _manMarker.setPosition(t);
			else prepoint = t;
			
			
		}
		
		
		
		private var offset:flash.geom.Point;

		private var ishide:Boolean = true;
		public function toggle(exit:int = -1):void
		{
			if(exit > -1) ishide = Boolean(exit);
			if(ishide)
			{
				
				TweenNano.to(this,0.5 , {y:this.stage.stageHeight-_height - 60 + 1});
				TweenNano.to(_viewport,0.5 , {height:_height});
				
			}
			else
			{
				TweenNano.to(this,0.5 , {y:this.stage.stageHeight - 60 +1});
				TweenNano.to(_viewport,0.5 , {height:0});
			}
			ishide = !ishide;
		}
		
		private var dragable:Boolean = false;
		
		public function setDragable(v:Boolean):void{ dragable = v;}
		
		private function render(save:Boolean = true):void
		{
			
			
		}
		
		
		
		public function refresh(tar:* = null):void
		{
			

		}
		
		private var mini:Boolean = true;
		
		
		public function resize(e:* = null):void
		{
			
			this.x = 0;
			_height = this.stage.stageHeight - 150; // bottom 60 + top 60;
			if(_height < 150) _height = this.stage.stageHeight - 60;
			if(ishide)
				this.y = this.stage.stageHeight - 60 + 1
			else
				this.y = this.stage.stageHeight - _height - 60 + 1; 
			
			_map.height = _height;
			if(_width != this.stage.stageWidth){
				_width = this.stage.stageWidth;
				drawStyle();
				_map.width = _width;
			};
			render();

		}
		
		public function setNavRot(v:Number , fromDrag:Boolean = false):void
		{
			
			if(fromDrag){
				
				//初始化到 [0 , 360]
				if(v>=-90) v = 90 + v;
				else v = 360 + 90 + v;
				
				var dv:Number = 0;
				
				//越界，或者直接点击 ， 用减
				
				
				if(v >= _rot) //顺时针
				{
					if(v - _rot >270){ //逆时针跨界 rot - > v : 10 - > 300
						dv = v - 360 - _rot;  // 负值
					}else{
						//顺时针正常 rot - > v : 10 - > 30
						dv = v - _rot;
					}
				}else //逆时针
				{
					if( _rot - v > 270){ // 顺时针跨界 rot - > v : 300 - > 10 
						dv = 360 - _rot + v;
					}else
					{ //正常逆时针 rot - > v : 30 - > 10 
						dv = v - _rot ; // 负值
					}
				}
				//trace("deta V : " +dv);
				EIF.call("setHeading" , dv)
				//rotateY( dv , false);

			}
			_man.rot = v;
			
			_rot = v;
			
		}
		
		public function getNavRot():Number { return _man.rot; }
		
		private function getCenter():flash.geom.Point{ return new flash.geom.Point( 0 , 0) }
		
		public function getManPosition():flash.geom.Point { return _man.position ;}
		
		private var _nodeDragable:Boolean = false;
		

		public function reset():void { _rot = 0; }
		
		
	}
}

	import flash.display.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.filters.GlowFilter;
	import pano.utils.TweenNano;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import org.openscales.core.style.Style;
	import org.openscales.geometry.Point;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.core.feature.*;
	import org.openscales.proj4as.ProjProjection;
	
	internal class SoulMarker extends PointFeature
	{
		private var _clip:DisplayObject;
		private var _xOffset:Number;
		private var _yOffset:Number;
		
		public function setPosition(p):void
		{
			var k = new Location(p.y,p.x,"EPSG:4326").reprojectTo("EPSG:900913")
			this.geometry = new org.openscales.geometry.Point(k.x,k.y,k.projection);
			this.draw();
			//trace("point x:"+point.x)
		}
		
		public function SoulMarker()
		{
			super(null,null,null);
		}
		
		public static function createDisplayObjectMarker(dispObj:DisplayObject,
														 point:Location,
														 data:Object=null,
														 xOffset:Number=NaN,
														 yOffset:Number=NaN):SoulMarker {
			var ret:SoulMarker = new SoulMarker();
			ret.geometry = new org.openscales.geometry.Point(point.x,point.y,point.projection);
			ret.data = data;
			ret.xOffset = xOffset;
			ret.yOffset = yOffset;
			ret.loadDisplayObject(dispObj);
			return ret;
		}
		
		
		
		
		/**
		 * To obtain feature clone
		 * */
		 /**
		override public function clone():Feature {
			var ret:CustomMarker = new CustomMarker();
			ret.geometry = this.point.clone();
			ret._originGeometry = this._originGeometry;
			ret.data = this.data;
			ret.xOffset = this._xOffset;
			ret.yOffset = this._yOffset;
			var bitmap:Bitmap = new Bitmap();
			bitmap.bitmapData = new BitmapData(this._clip.width, this._clip.height, false, 0x000000);
			bitmap.bitmapData.draw(this._clip, null, null, null, null);
			ret.loadDisplayObject(bitmap);
			ret.layer = this.layer;
			return ret;
		}
*/
	
		public function loadDisplayObject(clip:DisplayObject):void {
			if(this._clip)
				this.removeChild(this._clip);
			this._clip = clip;
			this.addChild(this._clip);
			
			if(this.layer)
				this.draw();
		}
		
		override public function draw():void {
			if(!this._clip)
				return;
			
			var x:Number;
			var y:Number;
			var resolution:Number = this.layer.map.resolution.value;
			
			var dX:int = -int(this.layer.map.x) + this.left;
			var dY:int = -int(this.layer.map.y) + this.top;
			
			x = dX - (this._clip.width/2) + point.x / resolution;
			if(_xOffset)
				x+= _xOffset;
			y = dY - (this._clip.height/2)- point.y / resolution;
			if(_yOffset)
				y+=_yOffset;
			
			_clip.x = x;
			_clip.y = y;
			
			
			
		}
		public function set xOffset(value:Number):void {
			this._xOffset = value;
			if(this.layer)
				this.draw();
		}
		
		public function get xOffset():Number {
			return this._xOffset;
		}
		
		public function set yOffset(value:Number):void {
			this._yOffset = value;
			if(this.layer)
				this.draw();
		}
		
		public function get yOffset():Number {
			return this._yOffset;
		}
		
		public function get clip():DisplayObject
		{
			return this._clip;
		}
		
		public function set clip(value:DisplayObject):void
		{
			this._clip = value;
		}
	}
	
	// 默认对齐 0.5 0.5
	internal class Focus extends Sprite
	{
		public var position:flash.geom.Point = new flash.geom.Point(0.5,0.5);
		public var id:String;
		public function Focus( id :String , p:flash.geom.Point){
			this.id = id;
			this.position = p;
			var n = new Bitmap(new Node())
			addChild(n)
			//n.x = -10;
			n.y = -16;
		}
		
	}
	
	internal class Man extends Sprite
	{
		public var arrow:Sprite = new Sprite();
		public var man:Sprite = new Sprite();
		public var position:flash.geom.Point = new flash.geom.Point(0.5,0.5);
		
		public function Man(){
			//this.graphics.lineStyle(1,0x985122,0.6);
			//addChild(arrow);
			addChild(man)
			//arrow.rotationX = -30;
			arrow.graphics.beginFill(0xffffff,0.6);
			arrow.graphics.moveTo(0,0)
			arrow.graphics.lineTo(-28,-40);
			arrow.graphics.curveTo(0,-60,28,-40);
			arrow.graphics.lineTo(0,0);
			
			arrow.graphics.endFill();
			draw();
			
			man.x = 10;
			man.y = man.height*0.5 - 10;
			
		}
		
		private function draw():void{
			var path:Array = [[-3,0],[-3,-8],[-5,-8],[-5,-18],[5,-18],[5,-8],[3,-8],[3,0]];
			
			man.graphics.beginFill(0xffffff,0.6);
			man.graphics.drawEllipse(-10, -8, 20,16);
			man.graphics.endFill();
			
			man.graphics.lineStyle(1,0x985122,0.6);
			man.graphics.beginFill(0xf1ab00);
			man.graphics.moveTo(0,0)
			for(var i:int = 0; i<path.length ; i++)
			{
				man.graphics.lineTo(path[i][0],path[i][1])
			}
			//this.graphics.moveTo(0,-22);
			
			//this.graphics.beginFill(0x00893434);
			man.graphics.drawCircle(0,-22, 3);
			man.graphics.endFill();
			man.graphics.lineStyle(1,0xd38c0c);
			
			man.graphics.moveTo(-3,-8);
			man.graphics.lineTo(-3,-18);
			man.graphics.moveTo(3,-8);
			man.graphics.lineTo(3,-18);
			
			this.filters = [new GlowFilter(0x000000,0.7,8,8,1)];
		}
		
		public function set rot(v:Number):void
		{
			arrow.rotationZ = v;
		}
		
		public function get rot():Number{ return arrow.rotationZ; }
		
		//public function set position(v:Point):void { this.x = v.x;this.y = v.y;}
		
		//public function get position():Point { return _position ; }
	}