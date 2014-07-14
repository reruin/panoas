package {
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;
	import flash.geom.Point;
	import flash.filters.*;
	import pano.ui.*;
	import pano.extra.*;
	import pano.utils.LoaderQueue;
	import pano.core.config;
	
	public class UILeft extends Component
	{
		private var skin:BitmapData;
		private var _leftTopSprite:leftTopSprite;
		private var _leftButtomSprite:leftBottomSprite;		
		private var _background:Shape;
		private var _back:Sprite;
		private var _leftText:TextArea;
		//private var leftmenu:Sprite = new Sprite()
		
		public var data:Object = new Object();
		public var panoPhotos:Object = new Object();
		private var _xml:XML;
		
		private var _UISpot:UISpot;
		private var _overMap:OverMap;
		
		private var setPanoBmd:Function = null;
		private var setPanoSize:Function;
		private var setPanoPos:Function;
		private var loadButtom:Function;
		private var render:Function;
		private var setArrowHide:Function;
		
		private var EIF:ExtraInterface;
		
		public function UILeft()
		{
			//Security.allowDomain("*");
			//stage.scaleMode = StageScaleMode.NO_SCALE
			skin = new shade();//leftShader();
			if (stage == null)
			{
				this.addEventListener(Event.ADDED_TO_STAGE, this.startPlugin);
			}
			else
			{
				this.startPlugin();
				//start();
			}
			super(350,125);
		}
		
		private function startPlugin(e:Event = null):void
		{
			//stage.showDefaultContextMenu = false;
			stage.showDefaultContextMenu = false;
			EIF = ExtraInterface.getInstance();
			
			if(EIF.ready) 
			{
				EIF.set("loadpano",loadPano)
				EIF.addPluginEventListener(ExtraInterface.PLUGINEVENT_REGISTER, this.registerEvent);
			}

		}
		private function registerEvent(e)
		{
			trace("register Event ")
			setPanoBmd = EIF.get("setpanobmd");
			setPanoSize = EIF.get("setpanosize");
			setPanoPos = EIF.get("setpanopos");
			loadButtom = EIF.get("loadbuttom");
			render = EIF.get("render");
			setArrowHide = EIF.get("hideArrow");
			start();
		}
		

		private function start():void
		{
			
			_leftTopSprite = new leftTopSprite();
			_leftButtomSprite = new leftBottomSprite();		
			_leftButtomSprite.filters = [new GlowFilter(0xffffff,0.75,4,4)];
			_background = new Shape();
			_background.filters = [new GlowFilter(0,0.75,16,16)];
			
			setArrowHide(true);
			
			addChild(_background); 
			
			addChild(_leftTopSprite); addChild(_leftButtomSprite);
			
			
			_overMap = new OverMap(350,320,"景区地图");
			
			_UISpot = new UISpot(350,320,"所有景区",this,120);
			//_UISpot.addChild(_back);
			_UISpot.y = _overMap.y + _overMap.height + 1;
			
			var _Accordion = new Accordion(350,320);
			_Accordion.add(_overMap);
			_Accordion.add(_UISpot);
			this.addChild(_Accordion)
			
			_leftText = new TextArea(350,300,"景区介绍")
			_leftText.color = 0xffffff;
			_leftText.setMargin([8,15,0,15]);
			
			this.addChild(_leftText);
			_leftText.y = _UISpot.y + _UISpot.height + 1;

			stage.addEventListener(Event.RESIZE, resizeHandler,false,0,true);

			var datalLoader:URLLoader = new URLLoader();
				datalLoader.addEventListener(Event.COMPLETE, datalLoaderCompletehandler);
				datalLoader.load(new URLRequest( config.viewStreetPath ));

			if(stage) resize();
		}
		
		private function datalLoaderCompletehandler(e:Event):void {
			_xml = new XML((e.target as URLLoader).data);
			initData();
		}
		
		private var thumbMap:String;
		private function initData():void
		{
			var l:int = _xml.spot.length();
			var initL = [];

			for( var i:int = 0; i<l; i++ )
			{
				
				//var id:String = i;//_xml.spot[i].@id; //可用 attribute("id")
				var title:String = _xml.spot[i].@title;
				var position:Point = creatPointFromString(_xml.spot[i].@position);
				var summary:String = _xml.spot[i].summary;
				var preview:String = "";
				var overmap:String = _xml.spot[i].@overmap;
				var edges = new Array() , overlays = new Array();
				var nodes = new Array();
				
				
				for(var j:int = 0; j< _xml.spot[i].nodes.node.length(); j++)
				{
					if(_xml.spot[i].nodes.node[j].@position)
					nodes.push({
						type:"node" ,
						thumb : _xml.spot[i].nodes.node[j].@thumb ,
						url : _xml.spot[i].nodes.node[j].@url ,
						title : _xml.spot[i].nodes.node[j].@title ,
						id:i+"_"+j,
						position : _xml.spot[i].nodes.node[j].@position
						
					})
					
				}
				
				preview = nodes[0].thumb;
				
				data[i] = {
					title:title,
					summary:summary,
					position:position,
					preview : preview ,
					nodes : nodes,
					overmap : overmap
				}
				
				initL.push({
						type : "list" , 
						thumb : preview , 
						title : title , 
						id : i
				})
						
				//trace([title,preview])
				
				
			}

			loadPano(data[0].nodes[0].url);

			_UISpot.loadList(data[0].nodes);
			_UISpot.loadType(initL);
			trace("overMap load : " +data[0].overmap)
			_overMap.load(data[0])
			resize();
		}
		
		/*
		public function getPanoUrl(v:String)
		{
			
		}
		*/
		
		private var _imgLoader:imgLoader = new imgLoader();
		public function loadPano(v):void
		{
			var url = (v is Array) ? (data[int(v[0])].nodes[int(v[1])].url) : v;
			trace("Load : "+url)
			_imgLoader.load(url , switchMap)
		}
		
		public function loadList(v):void
		{
			trace("loadClass:"+data[int(v)].summary)
			_leftText.text = data[int(v)].summary;
		}
		
		public function switchMap(v):void { if(EIF.ready) setPanoBmd(v as BitmapData);	}
		
		private function creatPointFromString(v:String):Point { var t = v.split(","); return new Point(t[0],t[1]); }
		
		private function resizeHandler(e):void { resize(); }
		
		private function drawBack()
		{
			
			if(skin)
			{
				_background.graphics.clear();
				_background.graphics.beginBitmapFill(skin);
				_background.graphics.drawRect(0,0,width, height)
				_background.graphics.endFill();
				
			}

		}
		
		public function resize():void
		{
			var w = stage.stageWidth;
			var h = stage.stageHeight;
			
			height = h;// - 125;
			trace("here is ok")
			trace(setPanoSize);trace(setPanoPos);
			trace("=========")
			if(EIF.ready)
			{trace("here2 is ok")
				setPanoSize(w - 350 , h);
				setPanoPos((550  - w)/2 + 350 , (400  -  h)/2);
				trace("here3 is ok")
				render();
				trace("here4 is ok")
			}
			
			//_leftButtomSprite.visible = false;
			this.x = (550 - w)/2;
			this.y = (400 - h)/2;
			_leftButtomSprite.y = height - _leftButtomSprite.height;
			_leftText.height = h - _leftButtomSprite.height;
			drawBack()
			//_buttom.render();
		}
	}
	
}


	import flash.display.*;
	import flash.events.*;
    import flash.net.*;
	import flash.utils.ByteArray;
	internal class imgLoader extends Sprite
	{
		private var _Loader:Loader;
		private var _completeFn:Function;
		private var bitmapData:BitmapData;
		
		public function imgLoader()
		{
			_Loader = new Loader();
		}
		
		public function load(url:String , completeFn:Function):void
		{
			_completeFn = completeFn;
			_Loader.load(new URLRequest(url)); 
			_Loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,loadProgressHandler,false,0,true);  
			_Loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loadCompleteHandler,false,0,true); 
		}
		
		private function loadProgressHandler(e:ProgressEvent)
		{
			trace("Loading ... "+Math.round(100 * e.bytesLoaded / e.bytesTotal) + "%");
			//_ext.dispatchEvent(new NoticeEvent("loadingmap",(Math.round(100 * e.bytesLoaded / e.bytesTotal) + "%")));
		}
		
		private var flag:Boolean = false;
		private var byteData:ByteArray = new ByteArray();
		private function loadCompleteHandler(e:Event)
		{
			
			try{
 				if(_Loader.content){
				 	 bitmapData = (_Loader.content as Bitmap).bitmapData.clone();
				 	(_Loader.content as Bitmap).bitmapData.dispose();
					unload();
				 	_completeFn(bitmapData)
				 }
				
             }catch (e)
             {
				
				if(flag)
				{
				 	bitmapData = new BitmapData(_Loader.content.width,_Loader.content.height);
				  	bitmapData.draw(_Loader.content,null,null,null,null,true);
					flag = false;
					byteData.clear();unload();
					_completeFn(bitmapData)
				 }else{
					  byteData = _Loader.contentLoaderInfo.bytes;
					  _Loader.unloadAndStop(true);
					  _Loader.loadBytes(byteData);
					  flag = true;
				 }  
             } 
			 
		}
		
		private function unload():void
		{
			_Loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS,loadProgressHandler);  
			_Loader.unloadAndStop(true);
		}
	}