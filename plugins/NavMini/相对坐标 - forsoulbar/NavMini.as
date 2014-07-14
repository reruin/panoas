package {
	
	import flash.display.*;
	import flash.geom.*;
	import flash.events.*;
    import flash.net.URLRequest;
	import flash.filters.GlowFilter;
	import pano.utils.TweenNano;
	import pano.utils.Geometry;
	import pano.ExtraInterface;
	
	public class NavMini extends Sprite
	{
		private var _viewport:Shape;
		private var _border:Shape;
		private var _close:Sprite;
		private var _max:Sprite
		private var _contentContainer:Sprite = new Sprite();;
		private var _content:DisplayObject;
		private var _eyeLayer:Bitmap;
		private var _man:Man;
		private var _focus:Focus;
		public var _width:Number= 250;
		public var _height:Number = 250;
		private var _padding:Number = 10;
		private var _ready:Boolean = false;
		private var _lastOp:Point;
		private var rotateY:Function;
		private var _rot:Number = 0;
		
		//private var _bound = []
		public var iz:Number = 1;
		public var ix:Number = _width/2;
		public var iy:Number = _height/2;
		
		private var minZ:Number = 1;
		private var maxZ:Number = 10;
		private var stepZ:Number = 0.2;
		
		private var EIF:ExtraInterface;
		
		public function NavMini(){
			
			
			if (stage == null)
			{
				this.addEventListener(Event.ADDED_TO_STAGE, this.startPlugin);
				this.addEventListener(Event.REMOVED_FROM_STAGE, this.stopPlugin);
			}else
			{
				startPlugin()
			}
		}
		
		
		private function startPlugin(e:Event = null):void
		{
			
			
			stage.showDefaultContextMenu = false;
			EIF = ExtraInterface.getInstance();
			if(EIF.ready) 
			{
				EIF.trace((new Date).toLocaleTimeString()+" : Loading NavMini(User Ver 1.0) Plugin Success ... ");
				EIF.set("navToggle",toggle);
				EIF.set("setNavRot" , setNavRot);
				EIF.set("setNavDragable",setDragable);
				EIF.set("navRot",getNavRot);
				EIF.set("getManPosition",getManPosition)//getManPosition
				//EIF.set("hide")
				EIF.addPluginEventListener(ExtraInterface.PLUGINEVENT_REGISTER, this.registerEvent);
				EIF.addPluginEventListener("notice_switchpano",switchHandler);
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
			_eyeLayer = null;
			_content = null;
			//_contentContainer.removeChild(_man);
			this.removeChild(_contentContainer);
			
			trace((new Date).toLocaleTimeString()+" : UnLoad NavMini Plugin Success ! ");
				
		}
		
		private function registerEvent(e)
		{
			rotateY = EIF.get("rotateY");
			init();
		}
		
		private function init():void{
			
			
			load(EIF.call("getPluginsConfig","navMini").image);
			
			_viewport = new Shape();
			_viewport.visible = false;
			this.mask = _viewport;
			
			_border = new Shape();
			_focus = new Focus();
			_man = new Man();
			
			
			this.addChild(_viewport);
			this.addChild(_contentContainer);
			this.addChild(_border);
		

			_eyeLayer = new Bitmap(null);
			_contentContainer.addChildAt(_eyeLayer , 0);
			_contentContainer.addChild(_focus);
			_contentContainer.addChild(_man);
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
			this.addEventListener(MouseEvent.MOUSE_DOWN,mouseDownHandler,false,0,true);
			this.addEventListener(MouseEvent.MOUSE_UP,mouseUpHandler,false,0,true);
			this.addEventListener(MouseEvent.MOUSE_WHEEL,mouseWheelHandler,false,0,true);

			//_max.addEventListener(MouseEvent.CLICK,max_mouseClickHandler,false,0,true);
			
			_man.arrow.addEventListener(MouseEvent.MOUSE_DOWN,panSprite_mouseDownHandler,false,0,true);
			_man.man.addEventListener(MouseEvent.MOUSE_DOWN,dragSprite_mouseDownHandler);
			//_contentContainer.addEventListener(MouseEvent.CLICK,nodeClickHandler,false,0,true);
			stage.addEventListener(Event.RESIZE, resize,false,0,true);
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN, this.keyDownHandler);
			
			EIF.addPluginEventListener("render",renderHandler);
		}	
		
		private function unregListeners():void
		{
			this.removeEventListener(MouseEvent.MOUSE_DOWN,mouseDownHandler);
			this.removeEventListener(MouseEvent.MOUSE_UP,mouseUpHandler);
			this.removeEventListener(MouseEvent.MOUSE_WHEEL,mouseWheelHandler);
			stage.removeEventListener(Event.RESIZE, resize);
			//_contentContainer.addEventListener(MouseEvent.CLICK,testHandler,false,0,true);

			_max.removeEventListener(MouseEvent.CLICK,max_mouseClickHandler);

			_man.arrow.removeEventListener(MouseEvent.MOUSE_DOWN,panSprite_mouseDownHandler);
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

			_border.graphics.beginFill(0xffffff,0.3);
			_border.graphics.drawRect(0, 0, _width, _height);
			_border.graphics.endFill();
			
			_border.graphics.lineStyle(2,0xffffff);
			_border.graphics.lineTo(_width,0);
			_border.graphics.lineTo(_width,_height-1);
			/*_border.graphics.moveTo(0,0);
			_border.graphics.lineTo(0,_height);*/
			
			
			_eyeLayer.bitmapData = new BitmapData(_width ,_height);
			
			//_tips.y = _height + 5; //_tips.x = _width - _tips.width; 
			this.filters = [new GlowFilter(0xfafafa,0.4,2,2)];
			_viewport.height = 0;
			
		}
		
		
		private function switchHandler(e):void{ setPosition( e.feature.position );}
		
		private function renderHandler(e):void{ if(!dragState) {setNavRot(EIF.call("gethead"));} }
		
		
				
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
			nextNode = EIF.call("getpano",fromViewToNormalise( new Point(this.mouseX , this.mouseY)) )
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
		
		
		public function setPosition(t:Point = null):void
		{
			
			if(t==null) t = EIF.call("getposition") ;
			
			if(_content)
			{
				//TweenNano.to(_man.position,0.6,{x:t.x,y:t.y,onUpdate:focus,onUpdateParams:[_man],onComplete:focus,onCompleteParams:[_man]})
				TweenNano.to(_man.position,0.6,{x:t.x,y:t.y,onUpdate:refresh,onComplete:refresh})
			
			}
			
		}
		
		private function mouseWheelHandler(e:MouseEvent):void{ (e.delta > 0)  ? zoomIn() :  zoomOut();}
		
		private var offset:Point;

		private function max_mouseClickHandler(e:MouseEvent):void
		{
			
			mini = !mini;
			if(mini)
			{
				TweenNano.to(this,0.6,{_width:250,_height:250,onUpdate:update,onComplete:update});

			}else
			{
				TweenNano.to(this,0.6,{_width:Math.min(this.stage.stageWidth*0.6 , _content.width),_height:Math.min(this.stage.stageHeight*0.6 , _content.height),onUpdate:update,onComplete:update});

			}
		}
		
		
		private function mouseDownHandler(e:MouseEvent):void{
			this.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler,false,0,true);
			_offset = new Point(this.mouseX,this.mouseY);
			EIF.trace(fromViewToNormalise(_offset.clone()).toString());
			
		}
		
		private function mouseUpHandler(e:MouseEvent):void{
			_offset = new Point(this.mouseX,this.mouseY);
			this.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		}
		
		private var _offset:Point;
		private function mouseMoveHandler(e:MouseEvent):void{
			if(dragState || _offset == null) return;
			
			var dx:Number = ( _offset.x - this.mouseX );
			var dy:Number = ( _offset.y - this.mouseY);
			_offset = new Point(this.mouseX,this.mouseY);
			panBy(new Point(dx,dy));
		}
		
		private function fromViewToMap(p:Point):Point{ return new Point(p.x*iz , p.y*iz);}
		
		private function fromNormaliseToMap(p:Point):Point{ return new Point(p.x*_content.width , p.y*_content.height); }
		
		public var info:Object = {x:_width/2 , y:_height/2 , z:1 }
		private function panBy(p:Point):void
		{
			
			p = fromViewToMap(p);
			
			var tx = ix + p.x; //等效移动
			var ty = iy + p.y;
			
			panTo(new Point(tx , ty) , -1 , false)
			
			
		}  
		
		
		public function panTo(p:Point = null, v:Number = -1 , doContinuous:Boolean = true):void{
			if(v==-1) v = iz;
			if(p==null){ p = getCenter();}
			if(doContinuous)
				TweenNano.to(info,0.5,{x:p.x,y:p.y,z:v,onUpdate:render,onComplete:render,onUpdateParams:[false]});
			else
			{
				info.x = p.x ; info.y = p.y; info.z = v; render();
			}
		}
		
		 
		public function zoomIn():void{ zoomTo(iz-stepZ)}
		
		public function zoomOut():void{ zoomTo(iz+stepZ) }
		
		public function zoomTo(v , doContinuous:Boolean = true):void{ panTo(null , v , doContinuous); }
		
		private var ishide:Boolean = true;
		public function toggle():void
		{
			
			if(ishide)
			{
				
				TweenNano.to(this,0.5 , {y:this.stage.stageHeight-_height - 60 + 1});
				TweenNano.to(_viewport,0.5 , {height:_height});
				
			}
			else
			{
				EIF.trace(this.stage.stageHeight - 60 +1)
				TweenNano.to(this,0.5 , {y:this.stage.stageHeight - 60 +1});
				TweenNano.to(_viewport,0.5 , {height:0});
			}
			ishide = !ishide;
		}
		
		private var dragable:Boolean = false;
		
		public function setDragable(v:Boolean):void{ dragable = v;}
		
		private function render(save:Boolean = true):void
		{
			//trace("moveTo:"+new Point(lastInfo[1]+detaInfo[1]*TweenProcess, lastInfo[2]+detaInfo[2]*TweenProcess));
			if(_content == null) return;
			
			var ox = info.x ;var oy = info.y;
			var oz = (info.z>maxZ)?maxZ:(info.z<minZ?minZ:info.z);
			
			var b:Rectangle = new Rectangle(info.x - _width*.5*oz , info.y - _height*.5*oz , _width*oz , _height*oz)
			
			
			if(b.left < 0 ) ox = 0.5 * b.width;
			if(b.top < 0 ) oy  = 0.5 * b.height;
			if(b.right > _content.width) ox = _content.width - 0.5 * b.width;
			if(b.bottom > _content.height) oy = _content.height - 0.5 * b.height;
			
			ix = ox; iy = oy ; iz = oz;
			if(save)
			{
				
				info.x = ix; info.y = iy ; info.z = iz;
			}
			
			ox = ox - 0.5 * b.width;
			oy = oy - 0.5 * b.height;
			oz = 1 / oz;
			var bmd = new BitmapData(_width,_height);
			var mat:Matrix = new Matrix(oz , 0,0,oz,0-ox*oz,0-oy*oz);
			var clip:Rectangle = new Rectangle(0,0,_width,_height);//_width*scale+100,_height*scale+100
			//trace("clip:"+clip)
			//trace(mat)
			_eyeLayer.bitmapData.draw(_content,mat,null,null,clip,true);
			
			refresh();
			
		}
		
		private function fromViewToNormalise(p:Point):Point
		{
			var detaX:Number = ix - _width*.5*iz;
			var detaY:Number = iy - _height*.5*iz;
			p.x = p.x * iz + detaX;
			p.y = p.y * iz + detaY;
			return new Point(p.x / _content.width , p.y / _content.height)
			
		}
		
		public function refresh(tar:* = null):void
		{
			if(tar == undefined) tar = _man;
			
			var detaX:Number = ix - _width*.5*iz;
			var detaY:Number = iy - _height*.5*iz;
			
			var r:Rectangle = new Rectangle(0,0,_width,_height);
			
			var t = fromNormaliseToMap(tar.position);
			t.x = (t.x - detaX)/iz;
			t.y = (t.y - detaY)/iz;
				
			if(r.contains(t.x,t.y))
			{
				if(tar != _focus)
					TweenNano.to(tar,0.5,{autoAlpha:1})
				else
					TweenNano.to(tar,0.5,{alpha:1})
				tar.x =  t.x;
				tar.y =  t.y;
				
			}
			else
			{
				TweenNano.to(tar,0.5,{autoAlpha:0})
			}

		}
		
		private var mini:Boolean = true;
		
		// width/height 变化需要调用update() 进行界面重绘
		private function update():void
		{
			if(_content == null) { EIF.warn("Miss Map @ NavMini.update()"); }
			else{
				var oz = maxZ;
				maxZ = Math.min(_content.width/_width , _content.height/_height);
				stepZ = (maxZ - minZ)/3;
				info.z = (maxZ-minZ) * info.z / (oz - minZ);
			}
			
			drawStyle();
			render();
		}
		
		public function resize(e:* = null):void
		{
			this.x = 0;
			if(ishide)
				this.y = this.stage.stageHeight - 60 + 1
			else
				this.y = this.stage.stageHeight - _height - 60 + 1; 
		
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
				rotateY( dv , false);

			}
			_man.rot = v;
			
			_rot = v;
			
		}
		
		public function getNavRot():Number { return _man.rot; }
		
		// 中心在 _contentContainer 的位置
		private function getCenter():Point{ return new Point( ix , iy) }
		
		public function getManPosition():Point { return _man.position ;}
		
		private var _nodeDragable:Boolean = false;
		
		public function get content(){ return _content;			}
		
		public function load(u:String):void
		{
			var picLoader:Loader = new Loader();
				picLoader.load(new URLRequest(u));
				picLoader.contentLoaderInfo.addEventListener(Event.INIT,eventInit,false,0,true);
				picLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, eventError,false,0,true);
				picLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,eventComplete,false,0,true);
		}
		
		private function eventInit(e:Event)
		{
			var _bitmap = (e.target.content) as Bitmap; // this is a bitmap
			_bitmap.smoothing = true;
			_content = _bitmap;
		}
		
		private function eventError(e:Event) {  }
		
		private function eventComplete(e:Event):void
		{
			e.target.removeEventListener(Event.INIT,eventInit);
			e.target.removeEventListener(IOErrorEvent.IO_ERROR, eventError);
			e.target.removeEventListener(Event.COMPLETE,eventComplete);
			update();setPosition();
			zoomTo(maxZ , false);
			
		}
		
		public function reset():void { _rot = 0; }
		
		
	}
}

	import flash.display.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.filters.GlowFilter;
	import pano.utils.TweenNano;
	
	internal class Focus extends Shape
	{
		public var position:Point = new Point(0.5,0.5);
		public function Focus(){
			this.graphics.lineStyle(2,0x0000f1);
			this.graphics.drawCircle(0,0,5);
			this.visible = false;
		}
		
	}
	
	internal class Man extends Sprite
	{
		public var arrow:Sprite = new Sprite();
		public var man:Sprite = new Sprite();
		public var position:Point = new Point(0.5,0.5);
		
		public function Man(){
			//this.graphics.lineStyle(1,0x985122,0.6);
			addChild(arrow);
			addChild(man)
			//arrow.rotationX = -30;
			arrow.graphics.beginFill(0xffffff,0.6);
			arrow.graphics.moveTo(0,0)
			arrow.graphics.lineTo(-28,-40);
			arrow.graphics.curveTo(0,-60,28,-40);
			arrow.graphics.lineTo(0,0);
			
			arrow.graphics.endFill();
			draw();
			
			
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