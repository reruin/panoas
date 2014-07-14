package {
	
	import flash.display.*;
	import flash.events.*;
	import pano.utils.TweenNano;
	import flash.geom.*;
	import pano.ExtraInterface;
	
	//import pano.core.Pano;
	//import pano.extra.MouseTips;
	public class Tray extends Sprite
	{
		private var _width:Number = 870;
		private var _height:Number = 58;
		private var _edge:Array;
		private var _back:Shape;
		private var _layer:Sprite;
		private var _debug:Boolean = true;
		private var EIF:ExtraInterface;
		//private var _mousetips = new MouseTips()
		public function Tray() { //
			
			
			if (stage == null)
            {
                this.addEventListener(Event.ADDED_TO_STAGE, this.startPlugin);
               //this.addEventListener(Event.REMOVED_FROM_STAGE, this.stopPlugin);
            }else
				this.startPlugin();
		}
		
		private function startPlugin(e:Event = null):void
		{
			stage.showDefaultContextMenu = false;
			EIF = ExtraInterface.getInstance();
			if(EIF.ready) 
			{
				EIF.trace((new Date).toLocaleTimeString()+" : Loading Tray Plugin(Ver 1.0) Success ... ");
				EIF.addPluginEventListener(ExtraInterface.PLUGINEVENT_REGISTER, this.registerEvent);
			}
			
			this.removeEventListener(Event.ADDED_TO_STAGE, startPlugin);
		}
		
		private function registerEvent(e)
		{
			
			_layer =  EIF.get("layer"); // _layer.addChild(this);
			init();
		}
		
		private function init():void
		{
			_back = new Shape();
			_edge = [[0,0],[0,-5],[20,-58],[850,-58],[870,-5],[870,0]];
			this.addChild(_back);
			draw(); setNodes();
			resize();
			this.addEventListener(MouseEvent.CLICK,clickHandler)
			this.addEventListener(MouseEvent.MOUSE_OVER,overHandler)
			this.addEventListener(MouseEvent.MOUSE_OUT,outHandler)
			stage.addEventListener(Event.RESIZE, resizeHandler,false,0,true);
		}
		
		private function draw():void
		{
			_back.graphics.clear();
			_back.graphics.beginFill(0xcbb8a4,0.35);
			_back.graphics.moveTo(_edge[0][0] , _edge[0][1]);
			for(var i:int=1 ; i<_edge.length ; i++)
				_back.graphics.lineTo(_edge[i][0] , _edge[i][1]);
			_back.graphics.lineTo(_edge[0][0] , _edge[0][1]);
			_back.graphics.endFill();
			_back.graphics.lineStyle(1,0xcbb8a4,0.35)
			_back.graphics.moveTo(_edge[1][0] , _edge[1][1]);
			_back.graphics.lineTo(_edge[_edge.length-2][0] , _edge[_edge.length-2][1]);
			
		}
		
		private function resizeHandler(e:Event):void
		{
			resize();
		}
		
		private function clickHandler(e:MouseEvent):void
		{
			if(e.target.hasOwnProperty("id"))
			{
				EIF.call("viewTo",(e.target as Node).svid)
			}
		}

		private function overHandler(e:MouseEvent):void
		{
			if(e.target.hasOwnProperty("id"))
			{
				TweenNano.to((e.target as Node).halo,0.75,{scaleX:1,scaleY:1,alpha:1});//trace(e.target["halo"]())
				EIF.call("show",e.target , e.target["id"])
			}
		}

		private function outHandler(e:MouseEvent):void
		{
			if(e.target.hasOwnProperty("id")){
				TweenNano.to((e.target as Node).halo,0.75,{scaleX:0.2,scaleY:0.2,alpha:0});
				EIF.call("hide");
			}
		}
		
		private var list:Array = [];
		private function setNodes():void
		{
			var o:Object = EIF.call("getRoads");
			var t = [];
			for(var k:String in o)
			{
				t.push([o[k].thumb,o[k].title,o[k].start]);
			}
			//var t = [["res/step/01.png","历史文化馆"],["res/step/02.png","陶瓷艺术馆"],["res/step/03.png","书画艺术馆"],["res/step/04.png","妇女文化馆"]];
			
			var padding = (_width - 80) / t.length;
			for(var i:int = 0 ; i<t.length ; i++)
			{
				list[i] = new Node(t[i]);
				list[i].x = 40 + padding*.5 + i*padding;
				list[i].y = -25;
				addChild(list[i]);
			}
		}
		
		public function resize():void
		{
			var viewportWidth = this.stage.stageWidth;
        	var viewportHeight = this.stage.stageHeight;
			this.x = (viewportWidth - _width) * 0.5;
			this.y = viewportHeight;
			trace(this.x+":"+this.y+":"+this.width+":"+this.height);
			
		}
		
		public static function createRef(_source:DisplayObject , l:int = 30):Bitmap
		{
		   //对源显示对象做上下反转处理
		   	var w:int=_source.width;
			var h:int=_source.height;
			if(l==-1) l = h;
			var bd:BitmapData=new BitmapData(w,h,true,0);
			var mtx:Matrix=new Matrix();
			mtx.d=-1;mtx.ty=bd.height;
			bd.draw(_source,mtx,null,null,new Rectangle(0,0,w,l));
			
			//生成一个渐变遮罩
			
			mtx=new Matrix();
			mtx.createGradientBox(w,l,0.5 * Math.PI);
			var shape:Shape = new Shape();
			shape.graphics.beginGradientFill("linear",[0,0],[0.6,0],[0,250],mtx)
			shape.graphics.drawRect(0,0,w,l);
			shape.graphics.endFill();
			
			bd.draw(shape, null, null, "alpha",new Rectangle(0,0,w,l));
			
			return new Bitmap(bd,"auto",true);
		}
	}
	
}

	import flash.display.*;
	import flash.events.*;
    import flash.net.URLRequest;
	import flash.geom.*;
	internal class Node extends Sprite
	{
		public var id:String;
		public var _url:String;
		private var _width:Number;
		private var _height:Number;
		private var _bitmap:Bitmap;
		private var _halo:Shape
		public var svid:String;
		private var _color:uint = 0xaab0bf;
		public function Node(v:Array){
			load(v[0]); id = v[1]; svid = v[2] ; _halo = new Shape()
			draw();addChild(_halo)
		}	
		
		private function regListeners():void
		{
			//this.addEventListener(MouseEvent.MOUSE_OVER,overHandler)
			//this.addEventListener(MouseEvent.MOUSE_OUT,downHandler)
		}
		
		public function load(u:String):void
		{
			
			var picLoader:Loader = new Loader();
				picLoader.load(new URLRequest(u));
				picLoader.contentLoaderInfo.addEventListener(Event.INIT,eventInit,false,0,true);
				picLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, eventError,false,0,true);
				picLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,eventComplete,false,0,true);
		}
		
		private function draw():void
		{
			/*
			this.graphics.clear();
			this.graphics.beginGradientFill("radial",[0xaab0bf,0xaab0bf],[1,0],[127,255]);
			this.graphics.drawEllipse(-60,-20,120,40);
			this.graphics.endFill();
			*/
			var mat = new Matrix(0.0732421875,0,0,0.0244140625)
			//mat.createGradientBox(120,40);
			_halo.graphics.clear();
			_halo.graphics.beginGradientFill("radial",[_color,_color],[1,0],[127,255],mat);
			_halo.graphics.drawEllipse(-60,-20,120,40);
			//_halo.x = -60;_halo.y = -20;
			_halo.scaleX = _halo.scaleY = 0.2; _halo.alpha = 0;
			
		}
		private function eventComplete(e:Event):void
		{
			e.target.removeEventListener(Event.INIT,eventInit);
			e.target.removeEventListener(IOErrorEvent.IO_ERROR, eventError);
			e.target.removeEventListener(Event.COMPLETE,eventComplete);
		}
		
		private function eventError(e:Event) { trace("url is Error!") }
		
		private function eventInit(e:Event)
		{
			_bitmap = (e.target.content) as Bitmap; // this is a bitmap
			_bitmap.smoothing = true;
			//_height = _bitmap.height; _width = _bitmap.width;
			//var scale = Math.min(70/_bitmap.width, 70/_bitmap.height);
			_height = _bitmap.height //= _bitmap.height*scale;
			_width = _bitmap.width //= _bitmap.width*scale;
			//_bitmap.bitmapData.draw();
			addChild(_bitmap);
			setPosition(-0.5,-1);
			var ref = Tray.createRef(_bitmap);
			addChild(ref);
			setPosition(-0.5,0,ref)

		}
		
		/*private function overHandler(e:MouseEvent):void
		{
			if(e.target.hasOwnProperty("id"))
				trace(e.target["id"])
		}
		
		private function outHandler(e:MouseEvent):void
		{
			if(e.target.hasOwnProperty("id"))
				trace(e.target["id"])
		}
		*/
		public function get halo():Shape{ return _halo; }
		
		//public function set halo(v:Number){ _halo}
		public function setPosition(ox:Number,oy:Number,d:DisplayObject = null):void
		{
			if(d==null) d = _bitmap;
			d.x = _width*ox;
			d.y = _height*oy;
		}
	}
