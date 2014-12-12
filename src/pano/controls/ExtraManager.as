	
// Extra Factory

package pano.controls {
	import flash.events.EventDispatcher;
	import flash.display.*;
	import flash.utils.*;
	import flash.net.LocalConnection;
	import flash.events.*;
	import pano.core.*;
	import pano.extras.*;
	import pano.events.*;
	import pano.utils.LoaderQueue;
	import pano.ExtraInterface;
	
	public class ExtraManager extends EventDispatcher{
		
		public static const EXTRA_EVENT_FINISH:String = "extra_event_finish";
		
		private var extras:Object = new Object();
		private var fn:Object = new Object();
		private var counter:int = 0;
		private var tar:Pano;
		public var EIF:ExtraInterface;
		private var lq:LoaderQueue;
		private var screen:Sprite;
		public function ExtraManager(v:Pano , c:Sprite):void
		{
			tar = v;  
			this.screen = new Sprite();
			c.addChild(screen)
			init();
		}
		
		private function init():void
		{
			EIF = ExtraInterface.getInstance();
			EIF.set = this.set; 
			EIF.get = this.get;
			EIF.call = this.call;
			EIF.addPluginEventListener = this.addEventListener;
			EIF.removePluginEventListener = this.removeEventListener;
			EIF.dispatchEvent = this.dispatchEvent;
			EIF.ready = true;
			
			// core
			this.set("getViewBound",tar.getViewBound)
			this.set("killpanoanimat",tar.killTween);
			this.set("render",tar.render);
			this.set("sleep",sleep);
			this.set("clear",clearance);
			this.set("print",tar.printScreen);
			this.set("setarrow",tar.setArrow);
			this.set("setpanobmd",tar.setBitmapData)
			this.set("setpanodata",tar.setPanoData);
			this.set("setpanotile" , tar.setBitmapDataTile);
			this.set("setpanowidth",tar.setWidth);
			this.set("setpanoheight",tar.setHeight);
			this.set("setpanosize",tar.setSize);
			this.set("setpanopos",tar.move);
			this.set("fullscreen",fullScreenhandler);
			this.set("sethand",tar.setHand);
			
			//projection
			this.set("screenToPano" , tar.screenToPano);
			this.set("panoToScreen" , tar.panoToScreen);
			this.set("normaliseToSphericalCoord" , tar.normaliseToSphericalCoord)

			//actions
			this.set("hideArrow" , tar.hideArrow);
			this.set("setpov" , tar.setPov);
			this.set("getpov" , tar.getPov);
			this.set("getheading" , tar.getHeading);
			this.set("getpitch" , tar.getPitch);
			this.set("setPano",tar.setPano);
			
			this.set("toround",tar.toRound);
			this.set("setfocus",tar.setfocus);
			this.set("panBy" , tar.panBy);
			
			// io
			this.set("setPanoXML" , Config.readXML);
			this.set("readXML" , Config.readXML);
			
			//data
			this.set("getPluginsConfig",Config.getPluginsConfig);
			this.set("getGlobalConfig",Config.getGlobalConfig);
			this.set("getRoads" , Config.getRoads);
			this.set("getNodes",Config.getNodes);
			this.set("styles",Config.styles);
			this.set("getcurrentsvid",getCurrentSvid);
			this.set("getcurrentarea",getCurrentArea);
			//debug
			this.set("debug", Config.debug);
			
			//prop
			this.set("layer",this.screen);
			this.set("stage",this.stage);
			this.set("viewport",tar);
			
			activate([CustomContextMenu]); //core plugins
			
			lq = new LoaderQueue();
			lq.addEventListener("EveryComplete",loadHandler,false,0,true);
			lq.addEventListener("AllComplete",loadAllHandler,false,0,true);
			this.addEventListener("fullscreen",fullScreenhandler);
			
		}
		
		public function getCurrentSvid():String{ return Stack.svid; }
		public function getCurrentArea():Object{ return Stack.roads[Stack.areaid]; }
		
		public function finish():void
		{
			tar.init();
			this.dispatchEvent(new NoticeEvent(ExtraInterface.PLUGINEVENT_REGISTER));
		}
		//private var tar_extra:DisplayObject;
		private function loadHandler(e:*):void
		{
			var t:Sprite = new Sprite();
			t.addChild(e.target.target);
			screen.addChild(t);
			
		}
		
		private function loadAllHandler(e:* = null):void
		{
			
			finish();
			//
		}
		
		private function fullScreenhandler(e:* = null):void
		{
			tar.fullScreen();
			this.dispatchEvent(new NoticeEvent("fullscreennotice"));
			
		}
		
		public function getConfig(v:String)
		{
			return Config[v];
		}
		/*
		public function act(c):void
		{
			var instance = new (c as Class)();
			counter++;
			screen.addChild(instance)
			
		}
		*/
		public function activate(c,v:Array = null)
		{
			if(c is String)
			{
				lq.add(c , c); return;
			}
			
			if(v==null) v = [];
			
			if(c.length!=undefined)
			{
				for each(var i in c)
					(i is String)?lq.add(i,i):join(i , v)
			}
			else
				return join(c , v)

			
		}
		
		
		private function join(c,v:Array = null)
		{
			if(c.hasOwnProperty("VER"))
			{
				var instance = new (c as Class)(this,[tar].concat(v));
				//trace("EIF init notice : "+getQualifiedClassName(instance))
				extras[getQualifiedClassName(instance).split("::")[1]] = instance;
				counter++
				return instance;
			}
		}
		
		public function resize():void
		{
			for each(var i in extras)
				(i as IExtra).resize();
			//screen.x = (550-stage.stageWidth)*0.5;
			//screen.y = (400-stage.stageHeight)*0.5;
		}
		
		//private var  exception:Array = [];
		
		
		
		public function addMenu(v:String , fn:Function , sp:Boolean = false , enable:Boolean = true):void
		{
			extras["CustomContextMenu"].add(v,fn,sp,enable);
		}
		
		public function clearance() : void 
		{
			try {
				new LocalConnection().connect('foo');
				new LocalConnection().connect('foo');
			} catch (e:Error) { }
		}
		public function trigger(e:String , f):void { this.dispatchEvent(new NoticeEvent(e,f)); }
		
		public function bind(e:String , f):void { this.dispatchEvent(new NoticeEvent(e,f)); }
		
		
		public function set(v,f:*):void{  
			if(fn[v]==undefined) fn[v] = f;
			//if(v=="openWindow") trace("reg :"+v)
		}
		
		public function get(v:String){ return fn[v]; }
		
		public function call(v:String,...rest)
		{
			if(fn[v]) {
				return fn[v].apply(EIF,rest)
			}
			else{
				EIF.warn("Miss Function At "+v + "()");
				return false;
			}
		}
		
		public function apply(v:Array)
		{
			if(v.length==0){
				EIF.warn("Miss Function At First Para");
				return false;
			}else
			{
				var c:String = v[0];
				if(fn[c]) {
					return fn[v].apply(EIF,v.slice(1));
				}
				else{
					EIF.warn("Miss Function At "+c + "()");
					return false;
				}
			}
		}
		
		public function get stage():Stage { return tar.stage; }
		
		public function get content():Sprite { return tar; }
		
		public function get target():Sprite { return tar; }
		
		public function getlayer():Sprite{ return screen;}
		
		public function getPano():Sprite { return tar }
		
		public function sleep(v:Boolean = false):void
		{
			tar.sleep(v);
			this.call("disableKeyBoard" ,v);
			
		}
		public function deactive():void
		{
			for (var i:int = screen.numChildren - 1;i>=0;i--)
			{
				screen.removeChildAt(i);
			}
		}
		
		public function destroy():void{
			lq.removeEventListener("EveryComplete",loadHandler);
			lq.removeEventListener("AllComplete",loadAllHandler);
			this.removeEventListener("fullscreen",fullScreenhandler);
			fn = null;
			lq = null;
			for (var i:int = screen.numChildren - 1;i>=0;i--)
			{
				screen.removeChildAt(i);
			}
			extras = null;
			screen = null;
		}
		
	}
	
}


	