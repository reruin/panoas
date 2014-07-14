package pano.extras{
	
	import flash.utils.Dictionary;
	import flash.utils.ByteArray;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.display.Loader;
	import flash.events.*;  
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.geom.Point;
	import pano.core.*;
	import pano.extras.*;
	import pano.controls.*;
	import pano.events.NoticeEvent;
	import pano.utils.*;
	
	import pano.ExtraInterface;
	
	import flash.net.FileReference;
	
	public class StreetView extends EventDispatcher implements IExtra{
		
		public static var VER:Number = 1.0;
		
		private var voice:String; 
		private var _edges: Object = new Object();
		private var _overlays : Object = new Object();
		private var _xml:XML;
		
		private var svid:String;
		//private var areaid:String;
		public var link:Array;
		public var linkRotation:Array;
		public var dir:Number; //图片 偏航
		public var bitmapData:BitmapData;
		private var panTo:Function;
		
		private var normaliseToSphericalCoord:Function;
		private var addOverlay:Function;
		private var clearOverlay:Function;
		private var setPanobmd:Function;
		private var getRotationY:Function;
		private var setPanoData:Function;
		private var bgsound:String;
		
		// 0 未加载 1 加载thumb 2 加载 full
		private var loadingState:int = 0;
		private var firstLoad:Boolean = true;
		
		private var EIF:ExtraInterface;
		
		public function destroy():void
		{
			_xml = null ; bitmapData.dispose(); 
			_edges = new Object();_overlays = new Object();
			link = [];linkRotation = [];
		}
		
		public function StreetView(_e, v:Array)
		{
			startPlugin();
		}
		
		private function startPlugin(e:Event = null):void
		{
			
			trace((new Date).toLocaleTimeString()+" : Loading StreetView(Core) Plugin ... ");
			EIF = ExtraInterface.getInstance();
			if(EIF.ready) 
			{
				EIF.set("getOverlays",getOverlays);
				EIF.set("getNodes",getNodes);
				EIF.set("getRoads",getRoads);
				EIF.set("viewTo",viewTo);
				EIF.set("viewToPath",viewToPath);
				EIF.set("getsvid",getPano);
				EIF.set("getsvidPosition",getPosition);
				EIF.set("getareaPosition",getareaPosition);
				EIF.set("go",go);
				
				//API for v1.5
				EIF.set("getpano",getPano);
				EIF.set("getposition",getPosition);
				
				// 操控附加
				EIF.set("toforward" , toForward);
				EIF.set("toback" , toBack);
				EIF.addPluginEventListener(ExtraInterface.PLUGINEVENT_REGISTER, this.registerEvent);
			}
			
		}
		
		private function registerEvent(e:* = null):void
		{
			//trace("registerEvent From : StreetView")
			if(EIF.ready)
			{
				panTo = EIF.get("panTo");
				setPanobmd = EIF.get("setpanobmd");
				setPanoData = EIF.get("setpanodata");
				getRotationY = EIF.get("getheading");
				normaliseToSphericalCoord = EIF.get("normaliseToSphericalCoord");
				addOverlay = EIF.get("addOverlay");
				clearOverlay = EIF.get("clearOverlay");
			}
			EIF.addPluginEventListener("switch", switchHandler);
			EIF.addPluginEventListener("switchend",switchEndHandler);
			EIF.addPluginEventListener("svloaded_complete",startHandler);
			
			startHandler();
		}
		
		private function startHandler(e:* = null):void
		{
			var bg:String = EIF.call("getGlobalConfig","bgsound");
			if(bg) EIF.call("playSound" , bg , -1);
			
			for(var i in Stack.nodes) EIF.trace(i+"==>");
			if(Stack.svid!="==>"){
				svid = Stack.svid;
				EIF.dispatchEvent(new NoticeEvent("switch",Stack.svid));
			}
			EIF.trace("faceto : "+Stack.face)
			if(Stack.face) EIF.call("setpov" , {heading:Stack.face.y , pitch:Stack.face.x});
		}
		
		private function switchHandler(e:* = null):void
		{
			
			loadingState = 0;
			try{_loader.close();_loader.unloadAndStop(true);}catch(e){};
			go(e.feature as String);
			
		}
		
		private var _loader:Loader = new Loader();
		private function imgLoader(u:String)
		{
			if(Config["usethumb"])
			{
				if(loadingState == 0)
				{
					u = getThumb(Stack.nodes[svid].url);
					//EIF.trace("Loading Thumb Panorama - "+svid)
					loadingState = 1;
				}else if(loadingState == 1)
				{
					loadingState = 2;
					EIF.trace("Loading Full Panorama "+svid + "...");
					trace("Loading Full Panorama "+svid + "...");
				}
				
			}
			_loader.load(new URLRequest(u)); 
			_loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,loadProgressHandler,false,0,true);  
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loadCompleteHandler,false,0,true); 
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,loadErrorHandler,false,0,true); 
		}
		
		private function loadErrorHandler(e):void
		{
			if(Config["usethumb"] && loadingState == 1)
			{
				EIF.warn("Load Thumb Panorama["+svid+"] Error : url("+Stack.nodes[svid].url+")")
				//加载完全图
				imgLoader(Stack.nodes[svid].url)
				//loadingState = 0;
			}
		}
		
		private function loadProgressHandler(e:ProgressEvent)
		{
			if(EIF.get("showload") && loadingState == 2) EIF.call("showload" , Math.round(100 * e.bytesLoaded / e.bytesTotal) + "%" )
		}
		
		private function loadCompleteHandler(e:Event){
			if(EIF.get("hideload") && loadingState == 2) EIF.call("hideload");
 			if(_loader.content)
			{
				bitmapData = (_loader.content as Bitmap).bitmapData.clone();
				(_loader.content as Bitmap).bitmapData.dispose();
				dispatchLoadedEnd();
				
			}
		}
		
		private function dispatchLoadedEnd():void
		{
			_loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS,loadProgressHandler);  
			_loader.unloadAndStop(true);
			switchMap();
			
			if(Config["usethumb"] && loadingState == 1)
			{
				//加载完全图
				imgLoader(Stack.nodes[svid].url)
				//loadingState = 0;
			}
		}
		
		
		public var _focus:Number = 100;
		private function switchMap():void
		{
			//若是完全图 则直接替换 bmd
			if(Config["usethumb"] && loadingState == 2){
				setPanobmd(bitmapData as BitmapData);
				loadingState = 0; //标记为加载完毕
				return;
			}
			
			setPanoData(bitmapData as BitmapData );
			/*
			if(firstLoad)
			{
				EIF.get("setfocus")(100);
				firstLoad = false;
				if(Config["autoplay"]) EIF.get("toround");
				TweenNano.to(this ,0.6 , {ease:TweenNano.CircEaseIn,_focus:450,onUpdate : function(){
							 	EIF.get("setfocus")(_focus);
							 },onComplete:function(){
								EIF.get("render")(true);
							}})
			}
			*/
			EIF.dispatchEvent(new NoticeEvent("StreetView_loadendmap"));
			
		}
		
		
		private function goHandler(e:* = null):void { go(e.feature as String); }
		
		public function toForward():void { EIF.dispatchEvent(new NoticeEvent("switch",getClosedRoad(1))); }
		
		public function toBack():void { EIF.dispatchEvent(new NoticeEvent("switch",getClosedRoad(0))); }
		
		public function viewToPath(v:String):void
		{
			var p:Point = Geometry.cog(stringToPolygon(v));
			p = normaliseToSphericalCoord(p);
			//panTo( new Point(p.y , p.x) );
		}
		
		public function viewTo(id:String = "" , p:* = null):void
		{
			
			//Stack.nodes[svid].overlays[0].path;
			//trace("Geometry.cog( stringToPolygon( Stack.nodes[svid].overlays[0].path ) ) : "+Geometry.cog( stringToPolygon( Stack.nodes[svid].overlays[0].path ) ));
			var gp:Point;
			if(Stack.nodes[id])
			{
				if((p is String) && p!="")
				{
					if(Stack.pois[p].position is Point) gp = Stack.pois[p].position.clone();
					else gp = Geometry.cog( Stack.pois[p].position );
					if(gp) EIF.call("setpov",{heading:gp.x,pitch:gp.y});
				}
				
				//Stack.face = p;
				
				if(svid != id) EIF.dispatchEvent(new NoticeEvent("switch",id));
			}
			
		}
		
		private function stringToPolygon(v):Array
		{
			var t = v.split(";");
			for(var i=0; i<t.length ; i++)
			{
				var k = t[i].split(",");
				t[i] = new Point(Number(k[0]) , Number(k[1]) );
			}
			return t;
		}
		
		private function getThumb(v:String):String
		{
			var p:Array = v.split(".");p[p.length-2] = p[p.length-2] +"_thumb"
			return p.join(".")
		}
		
		public function go(id:String , reset:Boolean = false):void
		{
			if(Stack.nodes[id] == undefined){
				EIF.warn("invalid panorama id : " + id);
				return;
			};
			
			var e:Array = Stack.nodes[svid].edges;
			//trace(e);
			
			// 设置 下一个位置 的信息，包括距离 和 角度
			for(var i:int = 0 ; i<e.length ; i++)
			{
				if(e[i].id==id) Stack.fromrot = e[i].rot;
				
			}
			
			Stack.fromDistance = (Stack.nodes[svid].position && Stack.nodes[id].position) ? Geometry.distanceLatlng( Stack.nodes[svid].position , Stack.nodes[id].position ) : 300;
			if(Stack.fromDistance ==0 ) Stack.fromDistance = 200;
			Stack.svid = svid = id; 
			//url = Stack.nodes[svid].url; 
			link = Stack.nodes[svid].edges;
			dir = reset ? 0 : Stack.nodes[svid].dir;
			
			
			linkRotation = [];
			
			for(var i=0; i<link.length ; i++)
			{
				linkRotation.push(link[i].rot);
			}
			
			EIF.trace((new Date).toLocaleTimeString()+" :Switch Pano Scene "+ svid + ". Has "+Stack.nodes[svid].pois.length+" poi(s)");
			
			EIF.dispatchEvent(new NoticeEvent("streetview_beforeloadingmap",{position : Stack.nodes[svid].position,link : Stack.nodes[svid].edges,dir:Stack.nodes[svid]["dir"],fromrot:Stack.fromrot,fromDistance:Stack.fromDistance}));
			
			imgLoader( Stack.nodes[svid].url );
			
			EIF.dispatchEvent(new NoticeEvent("startloadmap"));
			EIF.dispatchEvent(new NoticeEvent("notice_switchpano" , {svid:svid , position : Stack.nodes[svid].position})); //feature
			EIF.dispatchEvent(new NoticeEvent("overlay_all"));
			
			clearOverlay();
			
			//检查是否切换区域
			
			for(var id in Stack.roads)
			{
				
				if(Stack.roads[id].start == svid)
				{
					Stack.areaid = id;
					
					// 发送更换road事件
					EIF.dispatchEvent(new NoticeEvent("notice_switcharea",{position:Stack.roads[id].position}));
					
					//更新 head
					EIF.call("setHead" , Stack.roads[id].title,Stack.roads[id].content);
					//更新背景音乐
					
					if(Stack.roads[id].audio)
					{
						
						if(bgsound){
							if(bgsound != EIF.call("getSound" , Stack.roads[id].audio))
							{
								EIF.call("stopSound" , bgsound);
								bgsound = EIF.call("playSound" ,Stack.roads[id].audio )
							}
							
						}else
							bgsound = EIF.call("playSound" , Stack.roads[id].audio )
					}
					return;
				}
			}
			
		}
		
		private function switchEndHandler(e):void{ reloadPOI();EIF.get("render")(); }
		
		private function getClosedRoad(code:int = 0):String
		{
			//var rotY = 360 - (0-getRotationY()+36000)%360 ;
			
			var rotY = (getRotationY()+36000)%360 ;
			if(code == 0) rotY = (rotY + 180)%360; //0为反向，1正向
			//EIF.trace("linkRotation :: "+rotY+"向"+["后","前"][code])
			
			code = MathUtil.mins(linkRotation,rotY);
			
			return link[code].id;
			
		}
		
		
		// usage : 在指定位置和半径范围内查找最近的全景, 返回全景的Id；无参数 则返回当前全景点
		public function getPano(position:Point = null,radius:Number = -1):String 
		{
			if(position == null) return svid;
			
			var min:Number = radius == -1 ? 999999999 : radius , id:String = "";
			
			for(var i in Stack.nodes)
			{
				if(Stack.nodes[i].position)
				{
					var d:Number = Geometry.distance(Stack.nodes[i].position , position);

					if( d < min)
					{
						min = d; id = i;
					}
				}
				
			}
			
			return id;
		}
		
		
		// usage : 返回对应全景点的坐标
		public function getPosition(id:String = ""):Point
		{
			if(id == "") id = svid;
			return (Stack.nodes[id].position) ? Stack.nodes[id].position.clone() : new Point();
			
		}
		
		
		public function getareaPosition(v:String = ""):Point {
			if(v!="") { return Stack.roads[id].position.clone() ;} 
			for(var id in Stack.roads)
			{
				if(Stack.roads[id].start == svid)
				{
					return Stack.roads[id].position;
				}
			}
			return new Point(0,0)
		}
		
		public function getOverlays():Array{ return Stack.nodes[svid].overlays ;}
		
		public function getNodes():Array{ return Stack.nodes;}
		
		public function getRoads():Array{ return Stack.roads;}
		
		private function p2s(p:Point):String{ return p.x+","+p.y; }
		
		private function s2p(v:String):Point{ var k = v.split(","); return new Point(parseFloat(k[1]) , parseFloat(k[0])) }
		
		public function resize():void{}
		
		
		
		private function reloadPOI()
		{
			clearOverlay();
			// pois
			
			var k = Stack.nodes[svid]["pois"];
			
			for(var i=0;i<k.length;i++)
			{
				var type = Stack.nodes[svid]["pois"][i].type;
				var icon = Stack.nodes[svid]["pois"][i].icon;
				var title = Stack.nodes[svid]["pois"][i].title;
				var content = Stack.nodes[svid]["pois"][i].content;

				if(icon == "") icon = "spot";
				
				var span;

				if(type == "Marker")
				{
					var position:Point , distance:int , ix = 0 , iy = 0 , iz = 0;
					//相对位置 优先与 经纬度
					if(Stack.nodes[svid].latlng != null && Stack.nodes[svid]["pois"][i].latlng!="")
					{
						ix = Geometry.azimuth(Stack.nodes[svid]["pois"][i].latlng , Stack.nodes[svid].latlng , true);
						iy = (90 - Stack.nodes[svid]["pois"][i].h );// / 180;
						iz = Geometry.distanceLatlng(Stack.nodes[svid].latlng , Stack.nodes[svid]["pois"][i].latlng)
						position = new Point(ix,iy);
						distance = int(iz);
					}
					
					if(Stack.nodes[svid]["pois"][i].position!="")
					{
						position = Stack.nodes[svid]["pois"][i].position;
						distance = -1;
					}
					
					if(Stack.nodes[svid]["pois"][i].z!="") distance = parseInt(Stack.nodes[svid]["pois"][i].z);
					if(icon == "spot")
						span = new Spot({
										 title : title,
										 text : content,
										 media : Stack.nodes[svid]["pois"][i].media,
										 type : "marker",
										 position : position
										 });
					else if(icon == "hover")
						span = new Hover({
										 goto : Stack.nodes[svid]["pois"][i].data,
										 position : position
										 })
					else{
						
						
						span = new Photo({
										 url : content,
										 title : title,
										 text : content,
										 media : Stack.nodes[svid]["pois"][i].media,
										 type : icon,
										 distance : distance,
										 position : position
										 });
							
					}
				}
				else if(type == "Polygon"){
					//trace("poly")
					
					var span = new Polygon({
										   title : title , 
										   path : Stack.nodes[svid]["pois"][i].position,
										   media : Stack.nodes[svid]["pois"][i].media,
										   text :  content
										   });
										  
				}
				
				//EIF.trace("add POI : type="+type+" , icon="+icon+" , title="+title + ", distance : " + distance + " , position:"+position);
				addOverlay(span);
			}
			
			//overlays
		}
		
		private function creatPolygon()
		{
			
		}
	}
}


		 
    import flash.display.*;
	
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.text.*;
	import flash.filters.DropShadowFilter;
	
	//import pano.utils.TweenNano;
	
	internal class Span extends Sprite {

		private var _labelSpan:TextField;
		private var _labelDistance:TextField;
		private var _target:DisplayObjectContainer;
		private var _width:Number;
		private var _height:Number;
		private var _textSpan:String;
		private var _textDistance:String;
		public var position:Point;
		public var type:String = "marker";
		public var data:Object;
		public function Span(d:Object):void
		{
			_textSpan = d.title; _textDistance = d.distance; position = d.position;
			data = d;
			init();
		}
		
		public function init()
		{
			initObject();
			
			//this.alpha = 0;
			//this.visible = false;
			//mouseEnabled = false;
			this.cacheAsBitmap = true;
			this.filters = [new DropShadowFilter(2,45,0,1,8,8,0.5,2)];
			this.mouseChildren = false;
			this.mouseEnabled = true;
			drawStyle();
			this.addEventListener(MouseEvent.MOUSE_OVER,overHandler);
			this.addEventListener(MouseEvent.MOUSE_OUT,outHandler);
		}
		
		private function initObject():void
		{
			_labelSpan = new TextField(); _labelDistance = new TextField();
			_labelSpan.defaultTextFormat = _labelDistance.defaultTextFormat = new TextFormat("宋体",12);
			_labelSpan.autoSize = _labelDistance.autoSize = TextFieldAutoSize.LEFT;
			_labelSpan.textColor = 0xffffff;
			_labelDistance.textColor = 0x5ad941;
			//_labelSpan.background = true
			//_labelSpan.backgroundColor = 0x80000000;
			
			//_labelSpan.border = true;
			//_labelSpan.borderColor = 0xcccccc;
			_labelSpan.htmlText = _textSpan ; _labelDistance.htmlText = _textDistance ; 
            _labelSpan.selectable = _labelDistance.selectable = false;
			//trace(_labelSpan.x +":"+_labelSpan.y);
			_labelSpan.x += 3;_labelSpan.y = _labelDistance.y = 4;
			_labelDistance.x = _labelSpan.x + _labelSpan.textWidth + 6;
			addChild(_labelSpan);addChild(_labelDistance);
		}
		
		private function drawStyle():void
		{
			this.graphics.clear();
			this.graphics.beginFill(0,0.618);
			this.graphics.lineStyle(1,0x454545)
			this.graphics.drawRect(0,0,width+6,height+8);
			this.graphics.endFill();
		}
		
		
		public function update(p:Point):void{

			if(p.x<=0 || p.y <= 0 || p.x >= this.stage.stageWidth || p.y >= this.stage.stageHeight) this.visible = false;
			else 
			{
				
				this.x = p.x ; this.y = p.y ;
				this.visible = true;
			}
			
		}
		
		public function resize():void{}
 		
		private function overHandler(e):void
		{
			this.graphics.lineStyle(1,0x389525)
			this.graphics.lineTo(width-1,0)
			this.graphics.lineTo(width-1,height-1)
			this.graphics.lineTo(0,height-1)
			this.graphics.lineTo(0,0)
		}
		
		private function outHandler(e):void
		{
			this.graphics.lineStyle(1,0x454545)
			this.graphics.lineTo(width-1,0)
			this.graphics.lineTo(width-1,height-1)
			this.graphics.lineTo(0,height-1)
			this.graphics.lineTo(0,0)
		}
		
	}
	
	internal class Spot extends Sprite{
		public var type:String = "marker";
		public var data:Object;
		public var position:Point;
		public function Spot(d:Object){
			position = d.position; data = d;

			addChild( new MarkerButton());
			this.buttonMode = true;
			this.mouseChildren = false;
		}
		
		public function update(p:Point):void{

			if(p.x<=0 || p.y <= 0 || p.x >= this.stage.stageWidth || p.y >= this.stage.stageHeight) this.visible = false;
			else 
			{
				
				this.x = p.x ; this.y = p.y ;
				this.visible = true;
			}
			
		}
		public function resize():void{}
	}
	
	
	internal class Hover extends Sprite{
		public var type:String = "button";
		public var data:String;
		public var position:Point;
		public function Hover(d:Object){
			position = d.position; data = d.goto;

			addChild( new HoverButton());
			this.buttonMode = true;
			this.mouseChildren = false;
		}
		
		public function update(p:Point):void{

			if(p.x<=0 || p.y <= 0 || p.x >= this.stage.stageWidth || p.y >= this.stage.stageHeight) this.visible = false;
			else 
			{
				
				this.x = p.x ; this.y = p.y ;
				this.visible = true;
			}
			
		}
		public function resize():void{}
	}
	
	internal class Photo extends Sprite {
		public var type:String = "marker";
		private var content:Bitmap;
		public var data:Object;
		public var position:Point;
		private var _labelSpan:TextField;
		private var _labelDistance:TextField;
		private var _spanWidth:Number = 54;
		public function Photo(d:Object){
			position = d.position; data = d;
			
			var s = 1 - d.distance / 200;
			if(s > 1) s = 1
			if(s < 0.5) s = 0.5
			this.scaleX = this.scaleY = s
			this.alpha = 0.85;
			
			init();
			//_labelDistance.scaleX = _labelDistance.scaleY = 1 / s;
		}
		
		public function init():void{
			initObject();
			drawStyle()
		}
		
		private function initObject():void
		{
			if(data.type == "tree") content = new Bitmap(new Tree())
			else if(data.type=="parking") content = new Bitmap(new Parking())
			else if(data.type=="food") content = new Bitmap(new Food())
			else if(data.type=="shop") content = new Bitmap(new Shop())
			else if(data.type=="hotel") content = new Bitmap(new Hotel())
			else if(data.type=="building") content = new Bitmap(new Building())
			else if(data.type=="info") content = new Bitmap(new Info())
			else if(data.type=="aid") content = new Bitmap(new Aid())
			else if(data.type=="animal") content = new Bitmap(new Animal())
			else if(data.type=="toilet") content = new Bitmap(new Toilet())
			//else if(data.type=="drink") content = new Bitmap(new Coffee())
			//else if(data.type=="read") content = new Bitmap(new Book())
			//else if(data.type=="office") content = new Bitmap(new office())
			if(content) addChild(content);
			
			
			_labelSpan = new TextField();
			_labelSpan.defaultTextFormat =  new TextFormat("黑体",18);
			_labelDistance = new TextField();
			
			//var k = 12 / this.scaleX;
			//if(k < 8) k = 8;
			_labelDistance.defaultTextFormat =  new TextFormat("黑体",16);
			_labelDistance.autoSize = _labelSpan.autoSize =  TextFieldAutoSize.LEFT;
			_labelSpan.textColor = 0xdddddd;
			_labelDistance.textColor = 0x5ad90f
			_labelDistance.mouseEnabled = _labelSpan.mouseEnabled = false;
			//_labelSpan.background = true
			//_labelSpan.backgroundColor = 0x80000000;
			
			//_labelSpan.border = true;
			//_labelSpan.borderColor = 0xcccccc;
			_labelSpan.htmlText = data.title ; 
            _labelDistance.selectable = _labelSpan.selectable = false;
			if(data.distance>0) _labelDistance.htmlText = data.distance + "米"
			//trace(_labelSpan.x +":"+_labelSpan.y);
			_labelSpan.x += 54 + 6;
			//_labelDistance.x = 54 + _labelSpan.width + 6 - _labelDistance.width;
			_labelDistance.x = _labelSpan.width + _labelSpan.x + 6
			
			
			_labelSpan.y = (54 - _labelSpan.textHeight)*0.5;
			
			_labelDistance.y = (54 - _labelDistance.textHeight)*0.5;
			
			addChild(_labelSpan);
			addChild(_labelDistance)
		}
		
		private function drawStyle():void
		{
			this.graphics.clear();
			this.graphics.beginFill(0,0.9);
			this.graphics.drawRect(0,0,54 + _labelSpan.width+ _labelDistance.width + 12 + 6,54);
			this.graphics.endFill();
			
			content.x = 0//(54 - content.width)/2
			content.y = 0//(54 - content.height)/2
		}
		public function update(p:Point):void{

			if(p.x<=0 || p.y <= 0 || p.x >= this.stage.stageWidth || p.y >= this.stage.stageHeight) this.visible = false;
			else 
			{
				
				this.x = p.x ; this.y = p.y ;
				this.visible = true;
			}
			
		}
		public function resize():void{}
	}
