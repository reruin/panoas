package {
	
	import flash.display.*;
	import flash.geom.*;
	import flash.events.*;
    import flash.net.URLRequest;
	import flash.filters.GlowFilter;
	import pano.utils.TweenNano;
	import pano.extra.ExtraInterface;
	
	public class NavMini extends Sprite
	{
		private var _viewport:Shape;
		private var _border:Shape;
		private var _tips:Sprite;
		private var _close:Sprite;
		private var _max:Sprite
		private var _contentContainer:Sprite = new Sprite();;
		private var _content:BitmapData;
		private var _eyeLayer:Bitmap;
		private var _man:Man;
		public var _width:Number= 250;
		public var _height:Number = 250;
		private var _padding:Number = 10;
		private var _ready:Boolean = false;
		private var _lastOp:Point;
		private var getConfig:Function;
		private var rotateY:Function;
		private var getPanoRotY:Function;
		private var _rot:Number = 0;
		
		//private var _bound = []
		public var iz:Number = 5;
		public var ix:Number = _width/2;
		public var iy:Number = _height/2;
		
		private var minZ:Number = 1;
		private var maxZ:Number = 4;
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
			trace((new Date).toLocaleTimeString()+" : Loading NavMini(User) Plugin ... ");
			
			init();
			
			stage.showDefaultContextMenu = false;
			EIF = ExtraInterface.getInstance();
			if(EIF.ready) 
			{
				
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
			_contentContainer.removeChild(_man);
			this.removeChild(_contentContainer);
			
			trace((new Date).toLocaleTimeString()+" : UnLoad NavMini Plugin Success ! ");
				
		}
		
		private function registerEvent(e)
		{
			getConfig = EIF.get("getConfig");
			rotateY = EIF.get("rotateY");
			getPanoRotY = EIF.get("getPanoRotY");
			
			regListeners();
			
			update();
			iz = maxZ;
			//panTo(null , maxZ , false)
			resize();
			//initNodes();
			EIF.addPluginEventListener("streetview_loaded",initNodes);
			EIF.addPluginEventListener("switchArea",switchAreaHandler);
		}
		
		private function switchAreaHandler(e):void
		{
			trace("sitch area : "+e.position);
			//trace(EIF.get("getareaPosition"));
			_man.position = e.position;//_nodeList[id].x; _man.y = _nodeList[id].y;
		}
		
		private var _nodes:Object;
		private var _nodeList:Array;
		private function initNodes(e:* = null):void
		{
			trace("init nodes .............")

			_nodes = EIF.get("getRoads")();
			if(_nodes.length == 0) return;
			_nodeList = new Array();
			
			for(var i in _nodes)
			{
				var n = new Node(_nodes[i].start , _nodes[i].position);
				//trace(_contentContainer)
				_contentContainer.addChild(n);
				_nodeList.push ( n )
			}
			
						
			//man = new Man();
			_contentContainer.addChild(_man);
			_nodeList.push(_man)
			
			//trace("position : "+_man.position );
		}
		
		private function init():void{
			
			
			_viewport = new Shape();
			_viewport.visible = false;
			_border = new Shape();
			_tips = new Sprite();
			_close = getCloseBtn();
			_max = getMaxBtn();
			_man = new Man();
			//_contentContainer.mask = _viewport;
			this.addChild(_border);
			this.addChild(_viewport);
			this.addChild(_contentContainer);
			this.addChild(_tips);
			this.addChild(_close);
			this.addChild(_max);
			
			this.alpha = 0; this.visible = false;
			
			_content = new NavBmd();
			
			_eyeLayer = new Bitmap(null);
			
			_contentContainer.addChildAt(_eyeLayer , 0);
			
			//_contentContainer.addChild(_man);
			
			drawStyle();
			
		}
		
		
		
		public function dispose():void
		{
			(_content as Bitmap).bitmapData.dispose(); _content = null;
		}
		
		private function regListeners():void
		{
			this.addEventListener(MouseEvent.MOUSE_DOWN,mouseDownHandler,false,0,true);
			this.addEventListener(MouseEvent.MOUSE_UP,mouseUpHandler,false,0,true);
			this.addEventListener(MouseEvent.MOUSE_OVER,mouseOverHandler,false,0,true);
			this.addEventListener(MouseEvent.MOUSE_OUT,mouseOutHandler,false,0,true);
			this.addEventListener(MouseEvent.MOUSE_WHEEL,mouseWheelHandler,false,0,true);
			
			
			//_contentContainer.addEventListener(MouseEvent.CLICK,testHandler,false,0,true);
			_close.addEventListener(MouseEvent.CLICK,close_mouseClickHandler,false,0,true);
			_max.addEventListener(MouseEvent.CLICK,max_mouseClickHandler,false,0,true);
			_tips.addEventListener(MouseEvent.MOUSE_DOWN,tips_mouseDownHandler,false,0,true);
			_man.addEventListener(MouseEvent.MOUSE_DOWN,panSprite_mouseDownHandler,false,0,true);
			_contentContainer.addEventListener(MouseEvent.CLICK,nodeClickHandler,false,0,true);
			stage.addEventListener(Event.RESIZE, resize,false,0,true);
			EIF.addPluginEventListener("render",renderHandler);
		}	
		
		private function unregListeners():void
		{
			this.removeEventListener(MouseEvent.MOUSE_DOWN,mouseDownHandler);
			this.removeEventListener(MouseEvent.MOUSE_UP,mouseUpHandler);
			this.removeEventListener(MouseEvent.MOUSE_OVER,mouseOverHandler);
			this.removeEventListener(MouseEvent.MOUSE_OUT,mouseOutHandler);
			this.removeEventListener(MouseEvent.MOUSE_WHEEL,mouseWheelHandler);
			stage.removeEventListener(Event.RESIZE, resize);
			//_contentContainer.addEventListener(MouseEvent.CLICK,testHandler,false,0,true);
			_close.removeEventListener(MouseEvent.CLICK,close_mouseClickHandler);
			_max.removeEventListener(MouseEvent.CLICK,max_mouseClickHandler);
			_tips.removeEventListener(MouseEvent.MOUSE_DOWN,tips_mouseDownHandler);
			_man.removeEventListener(MouseEvent.MOUSE_DOWN,panSprite_mouseDownHandler);
			_contentContainer.addEventListener(MouseEvent.CLICK,nodeClickHandler);
			
			EIF.removePluginEventListener("render",renderHandler);
		}
		
		
		private function nodeClickHandler(e):void
		{
			
			if(e.target is Node)
			{
				
				EIF.get("go")(e.target.id);
				_man.position = EIF.get("getsvidPosition")();//_nodeList[id].x; _man.y = _nodeList[id].y;
				trace(_man.position);
				panTo(fromNormaliseToMap(e.target.position));
			}
		}
		
		private function drawStyle():void
		{
			_viewport.graphics.clear()
			_viewport.graphics.beginFill(0xff0000);
			_viewport.graphics.drawRect(0, 0, _width, _height);
			_viewport.graphics.endFill();
			
			_border.graphics.clear();
			_border.graphics.lineStyle(10,0xffffff);
			_border.graphics.beginFill(0xffffff,0.3);
			_border.graphics.drawRect(0, 0, _width, _height);
			_border.graphics.endFill();
			
			_tips.graphics.clear();
			_tips.graphics.lineStyle(1,0xffe69c,0.6);
			_tips.graphics.beginFill(0xffe69c,0.6);
			_tips.graphics.moveTo(20,-15);
			_tips.graphics.lineTo(40,-15);
			_tips.graphics.lineTo(-5,42);
			_tips.graphics.lineTo(-20,30);
			_tips.graphics.lineTo(20,-15);
			
			_tips.graphics.endFill();
			
			_close.x = _width;
			_max.x = _width - 22;
			_max.scaleX = _max.scaleY = _close.scaleX = _close.scaleY = 0.001;
			
			_eyeLayer.bitmapData = new BitmapData(_width ,_height);
			
			//_tips.y = _height + 5; //_tips.x = _width - _tips.width; 
			this.filters = [new GlowFilter(0x000000,0.75,8,8,1)];
			
			//fixPosition();
		}
		
		private function getCloseBtn():Sprite
		{
			var cbtn = new Sprite();
			cbtn.graphics.beginFill(0xeeeeee);
			cbtn.graphics.drawCircle(0, 0, 10);
			cbtn.graphics.endFill();
			cbtn.graphics.lineStyle(2,0x6b9b14);
			cbtn.graphics.moveTo(3,3);
			cbtn.graphics.lineTo(-3,-3);
			cbtn.graphics.moveTo(3,-3);
			cbtn.graphics.lineTo(-3,3);
			
			return cbtn;
		}
		
		private function getMaxBtn():Sprite
		{
			var cbtn = new Sprite();
			cbtn.graphics.beginFill(0xeeeeee);
			cbtn.graphics.drawRoundRect(-10, -10, 20,20,8,8);
			cbtn.graphics.endFill();
			cbtn.graphics.lineStyle(2,0x6b9b14);
			cbtn.graphics.moveTo(-6,-5);
			cbtn.graphics.lineTo(6,-5);
			cbtn.graphics.lineTo(6,5);
			cbtn.graphics.lineTo(-6,5);
			cbtn.graphics.lineTo(-6,-5);
			
			return cbtn;
		}
		
		private function switchHandler(e):void{ focus( e.feature );}
		
		private function renderHandler(e):void{ if(!dragState) setNavRot(getPanoRotY()) }
		
		private function panSprite_mouseDownHandler(e):void
		{
			dragState = true;
			_man.stage.addEventListener(MouseEvent.MOUSE_MOVE,panSprite_mouseMoveHandler,false,0,true);
			_man.stage.addEventListener(MouseEvent.MOUSE_UP,panSprite_mouseUpHandler,false,0,true);
			
			setNavRot(Math.atan2(_man.mouseY , _man.mouseX)*180/Math.PI ,true);
		}
		
		private var dragState = false;
		private function panSprite_mouseMoveHandler(e):void
		{
			
			setNavRot(Math.atan2(_man.mouseY , _man.mouseX)*180/Math.PI ,true);
		}
		
		private function panSprite_mouseUpHandler(e):void
		{
			dragState = false;
			_man.stage.removeEventListener(MouseEvent.MOUSE_MOVE,panSprite_mouseMoveHandler);
			_man.stage.removeEventListener(MouseEvent.MOUSE_UP,panSprite_mouseUpHandler);
			EIF.get("render")();
		}
		
		
		private var firstLoad:Boolean = true;
		public function focus(o:* = null):void
		{
			if(firstLoad == false){
				return;
			}
			
			var t:Point = o.position;
			t.x = t.x / 360 ; 
			t.y = t.y / 180;
			_man.position = t;
			
			panTo( t );
			update();
			firstLoad = false;
		}
		
		private function mouseWheelHandler(e:MouseEvent):void{
			if(e.delta > 0)  zoomIn();
			else zoomOut();
		}
		
		private var offset:Point;
		private function tips_mouseDownHandler(e:MouseEvent):void{
			if(!dragable) return;
			offset = new Point(-this.mouseX, -this.mouseY);
			_tips.stage.addEventListener(MouseEvent.MOUSE_MOVE,tips_mouseMoveHandler,false,0,true);
			_tips.stage.addEventListener(MouseEvent.MOUSE_UP,tips_mouseUpHandler,false,0,true);
		}
		
		private function tips_mouseMoveHandler(e:MouseEvent):void
		{
			this.x = this.parent.mouseX + offset.x;
			this.y = this.parent.mouseY + offset.y;
		}
		
		private function tips_mouseUpHandler(e:MouseEvent):void
		{
			this.x = this.parent.mouseX + offset.x;
			this.y = this.parent.mouseY + offset.y;
			_tips.stage.removeEventListener(MouseEvent.MOUSE_MOVE,tips_mouseMoveHandler);
			_tips.stage.removeEventListener(MouseEvent.MOUSE_UP,tips_mouseUpHandler);
		}
		
		private function max_mouseClickHandler(e:MouseEvent):void
		{
			
			mini = !mini;
			if(mini)
			{
				//_width = _height = 250;
				TweenNano.to(this,0.6,{_width:250,_height:250,onUpdate:update,onComplete:update});

			}else
			{
				TweenNano.to(this,0.6,{_width:Math.min(this.stage.stageWidth*0.8 , _content.width),_height:Math.min(this.stage.stageHeight*0.8 , _content.height),onUpdate:update,onComplete:update});
				//_width = Math.min(this.stage.stageWidth , _content.width);
				//_height = Math.min(this.stage.stageHeight , _content.height);
			}
			
			//update();
		}
		
		private function close_mouseClickHandler(e:MouseEvent):void
		{
			toggle();
		}
		
		private function mouseOverHandler(e:MouseEvent):void{
			if(!isshow) return;
			TweenNano.to(_close,0.4,{scaleX:1,scaleY:1,ease:TweenNano.BackOut})
			TweenNano.to(this,0.4,{rotationY:0});
			TweenNano.to(_max,0.4,{scaleX:1,scaleY:1,ease:TweenNano.BackOut})
			
		}

		private function mouseOutHandler(e:MouseEvent):void{
			if(!isshow) return;
			TweenNano.to(_close,0.4,{scaleX:0.01,scaleY:0.01,ease:TweenNano.BackOut})
			TweenNano.to(this,0.4,{delay:1,rotationY:-80})
			TweenNano.to(_max,0.4,{scaleX:0.01,scaleY:0.01,ease:TweenNano.BackOut})
			
		}
		
		private function mouseDownHandler(e:MouseEvent):void{
			this.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler,false,0,true);
			_offset = new Point(this.mouseX,this.mouseY);
			trace(fromViewToNormalise(_offset.clone()));
		}
		
		private function mouseUpHandler(e:MouseEvent):void{
			this.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		}
		
		private var _offset:Point;
		private function mouseMoveHandler(e:MouseEvent):void{
			if(dragState) return;
			var dx:Number = ( _offset.x - this.mouseX );
			var dy:Number = ( _offset.y - this.mouseY);
			_offset = new Point(this.mouseX,this.mouseY);
			panBy(new Point(dx,dy));
		}
		
		private function fromViewToMap(p:Point):Point
		{
			return new Point(p.x*iz , p.y*iz);
		}
		
		private function fromNormaliseToMap(p:Point):Point
		{
			return new Point(p.x*_content.width , p.y*_content.height);
		}
		
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
				TweenNano.to(info,0.3,{x:p.x,y:p.y,z:v,onUpdate:render,onComplete:render,onUpdateParams:[false]});
			else
			{
				info.x = p.x ; info.y = p.y; info.z = v; render();
			}
		}
		
		 
		public function zoomIn():void{ zoomTo(iz-stepZ)}
		
		public function zoomOut():void{ zoomTo(iz+stepZ) }
		
		public function zoomTo(v , doContinuous:Boolean = true):void{ panTo(null , v , doContinuous); }
		
		private var isshow:Boolean = false;
		public function toggle():void
		{
			isshow = !isshow;
			if(isshow) TweenNano.to(this,0.1 , {autoAlpha : 1});
			if(!isshow) TweenNano.to(this,0.6 , {autoAlpha : 0});
		}
		
		private var dragable:Boolean = false;
		public function setDragable(v:Boolean):void
		{
			dragable = v;
		}
		
		private function render(save:Boolean = true):void
		{
			//trace("moveTo:"+new Point(lastInfo[1]+detaInfo[1]*TweenProcess, lastInfo[2]+detaInfo[2]*TweenProcess));
			
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
			_eyeLayer.bitmapData = new BitmapData(_width,_height);
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
		
		public function refresh():void
		{
			var detaX:Number = ix - _width*.5*iz;
			var detaY:Number = iy - _height*.5*iz;
			//trace(detaX+":"+detaY)
			var r:Rectangle = new Rectangle(0,0,_width,_height);
			
			for each(var obj in _nodeList)
			{
				
				var t = fromNormaliseToMap(obj.position);
				
				t.x = (t.x - detaX)/iz;
				t.y = (t.y - detaY)/iz;
				if(r.contains(t.x,t.y-obj.height*0.5))
				{
					TweenNano.to(obj,0.5,{autoAlpha:1})
					obj.x =  t.x;
					obj.y =  t.y;
				}
				else
					TweenNano.to(obj,0.5,{autoAlpha:0});
				
			}

		}
		
		private var mini:Boolean = true;
		private function update():void
		{
			var oz = maxZ;
			maxZ = 1.5;//Math.min(_content.width/_width , _content.height/_height);
			stepZ = (maxZ - minZ)/3;
			
			info.z = (maxZ-minZ) * info.z / (oz - minZ);
			
			drawStyle();
			//trace(_max.x+":"+_max.y+":"+_max.alpha + ":"+_max.visible)
			render();
		}
		
		public function resize(e:* = null):void
		{
			//if(!_ready) return;
			var w = this.stage.stageWidth;
        	var h = this.stage.stageHeight;
			
			this.x = _padding + 8;
			this.y = h - _height - _padding - 70; 
			
			var p = new PerspectiveProjection()
			//p.projectionCenter = new Point(this.x + _width, this.y +(_height ) )
			p.projectionCenter = new Point(this.x, this.y +(_height - _padding - 70 )/2 )
			this.transform.perspectiveProjection = p;
			
			render();
			/*this.x = w - _width - _padding / 2 - 4;
			this.y = _padding / 2 + 4;*/
			
		}
		
		private function fixPosition():void
		{
			this.x = _padding / 2 - 4;
			this.y = _padding / 2 + 32 + 4;
		}
		
		private var count:int = 0;
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
		
		public function get content(){ return _content;	}
				
		public function reset():void
		{
			_rot = 0;
		}
		
		
	}
}

	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.filters.GlowFilter;
	import pano.utils.TweenNano;
	
	
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
			this.buttonMode = true;
			
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
	
	internal class Node extends Sprite
	{
		public var position:Point;
		public var id:String;
		private var spot:Bitmap;
		
		public function Node(v:String,p:Point){
			
			this.id = v ; this.position = p.clone(); this.x = p.x ; this.y = p.y; this.id = id;
			this.buttonMode = true;
			draw();
		}
		

		private function draw():void{
			
			spot = new Bitmap(new Spot());
			addChild(spot);
			spot.x = 0 - spot.width / 2;
			spot.y = 0 - spot.height
			
			/*this.graphics.beginFill(0xff0000,0.6);
			this.graphics.drawCircle(0, 0, 10)
			this.graphics.endFill();*/
		}

	}
	
	