package  {
	import flash.display.*;
	import flash.events.*;
	import pano.ExtraInterface;
	import flash.filters.GlowFilter;
	import pano.utils.TweenNano;
	import flash.net.*;
	public class Link extends Sprite{
		
		private var EIF:ExtraInterface;
		private var config:XML;
		private var container:Sprite = new Sprite();
		private var _height:Number = 1;
		private var _width:Number = 1;
		public function Link() {
			
			if (stage == null)
			{
				this.addEventListener(Event.ADDED_TO_STAGE, this.startPlugin);
				this.addEventListener(Event.REMOVED_FROM_STAGE, this.stopPlugin);
			}else
			{
				startPlugin();
			}
		}
		
		private function startPlugin(e:* = null):void
		{
			stage.showDefaultContextMenu = false;
			EIF = ExtraInterface.getInstance();
			if(EIF.ready) 
			{
				var k:String = (new Date).toLocaleTimeString()+" : Loading Link(Ver 1.0) Plugin Success ... ";
				EIF.addPluginEventListener(ExtraInterface.PLUGINEVENT_REGISTER, this.registerEvent);
			}
			
			this.removeEventListener(Event.ADDED_TO_STAGE, this.startPlugin);
		}
		
		private function stopPlugin(e):void { }
		
		private function registerEvent(e):void {
			stage.addEventListener(Event.RESIZE, resize,false,0,true);
			this.btn.addEventListener(MouseEvent.CLICK, clickHandler,false,0,true);
			
			var b:String = EIF.call("getPluginsConfig" , "link").value;
			if(b=="" || b==null) b = "";
			
			config = new XML(b);
			init()
		}
		
		private var list:Array = [];
		private function init():void
		{
			var l:int = config.item.length();
			
			var padding:int = 57;
			for(var i:int = 0;i<l;i++)
			{
				list[i] = new Node(config.item[i].@icon,config.item[i].@url,config.item[i].@title);
				list[i].x = 15;
				list[i].y = 15 + i*padding
				container.addChild(list[i]);
			}
			this.filters = [new GlowFilter(0,0.4,8,8,1)];
			
			//container.x = 20;
			addChildAt(container,0);
			container.visible = false;
			_height = l * padding + 15;
			_width = 200;
			
			container.graphics.beginFill(0xfafafa,0.8);
			container.graphics.drawRect(0,0,_width,_height);
			container.graphics.endFill();
			
			container.addEventListener(MouseEvent.CLICK, itemHandler,false,0,true);
			resize();
		}
		
		private function itemHandler(e):void
		{
			if(e.target is Node) navigateToURL(new URLRequest((e.target as Node).url),"_blank");
		}
		
		private var status:int = 0;
		private function clickHandler(e):void
		{
			if(status == 0)
			{
				status = 1
				TweenNano.to(this,0.6,{x:this.stage.stageWidth-_width-10,y:this.stage.stageHeight-_height-10})
				TweenNano.to(container,0.6,{autoAlpha:1});
				TweenNano.to(btn,0.4,{scaleX:0.75,scaleY:0.75,x:0,y:15})
			}else
			{
				status = 0;
				TweenNano.to(this,0.4,{x:this.stage.stageWidth -26,y:this.stage.stageHeight-26})
				TweenNano.to(container,0.4,{autoAlpha:0});
				TweenNano.to(btn,0.6,{scaleX:1,scaleY:1,x:0,y:0});
			}
			
		}
		
		
		
		private function resize(e:* = null):void
		{
			var w = this.stage.stageWidth;
        	var h = this.stage.stageHeight;
			if(status==1){
				this.x = w - _width-10;
				this.y = h - _height-10;
			}else{
				this.x = w - 26;
				this.y = h - 26;
			}
			
		}
		
	}
	
}

	import flash.display.*;
	import flash.events.*;
    import flash.net.URLRequest;
	import flash.geom.*;
	internal class Node extends Sprite
	{
		public var url:String;
		public var title:String;
		
		private var _width:Number;
		private var _height:Number;
		private var _bitmap:Bitmap;
		private var _icon:String
		
		private var _color:uint = 0xaab0bf;
		public function Node(v1:String,v2:String,v3:String){
			load(v1); title = v3; url = v2 ;
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
			
		}
		
		
	}

