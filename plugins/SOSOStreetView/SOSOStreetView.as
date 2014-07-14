package  {
	import flash.system.Security;
	import pano.extra.*;
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	import flash.geom.Point;
	import pano.utils.LoaderQueue;
	
	public class SOSOStreetView extends Sprite{
		
		private static var THUMB = "http://sv1.map.soso.com/thumb?svid={svid}&x=0&y=0&from=web&level=0&size=0"; 
		private static var template = "http://sv{x}.map.soso.com/tile?svid={svid}&x={x}&y={y}&from=web&level={z}&v=2";
		private static var SVIDxml = "http://sv.map.soso.com/sv?pf=web&svid={svid}";
		private static var POIsxml = "http://sv.map.soso.com/poi3d?x={x}&y={y}&source=soso&type=street&output=xml"
		
		/*
		private static var THUMB = "http://202.117.156.228/nwpu/plugins/outside/pano/{svid}/0-0-99.jpg"; 
		private static var template = "http://202.117.156.228/nwpu/plugins/outside/pano/{svid}/{x}-{y}-{z}.jpg";
		private static var SVIDxml = "http://202.117.156.228/nwpu/plugins/outside/svid/{svid}.xml";
		private static var POIsxml = "http://202.117.156.228/nwpu/plugins/outside/poi3d/{x}-{y}.xml"
		*/
		
		private var EIF:ExtraInterface;
		public var svid:String;
		private var lsvid:String;
		private var loader:URLLoader;
		private var poiLoader:URLLoader;
		private var setPanobmd:Function;
		private var setArrow:Function;
		private var getRotationY:Function
		private var setPanoTile:Function;
		private var addOverlay:Function;
		private var clearOverlay:Function;
		
		private var rot:Number;
		private var bitmapData:BitmapData;
		private var idown:LoaderQueue;

		public function SOSOStreetView()
		{
			Security.allowDomain("*");
			Security.loadPolicyFile("http://202.117.156.228/crossdomain.xml");
			if (stage == null)
			{
				this.addEventListener(Event.ADDED_TO_STAGE, this.startPlugin);
				this.addEventListener(Event.REMOVED_FROM_STAGE, this.stopPlugin);
			}else
			{
				startPlugin();
			}
		}

		private function startPlugin(e:Event = null):void
		{
			
			
			trace((new Date).toLocaleTimeString()+" : Loading SOSOStreetView Plugin ... ");
			//JavaScript.call("alert","load SOSOStreetView Plugin")
			stage.showDefaultContextMenu = false;
			EIF = ExtraInterface.getInstance();
			if(EIF.ready) 
			{
				EIF.set("sosoLoad",goto);
				//在当前视角 前进 和 后退
				EIF.set("toback",toBack);
				EIF.set("toforward",toForward);
				EIF.addPluginEventListener(ExtraInterface.PLUGINEVENT_REGISTER, this.registerEvent);
			}
			
			//init();
			
			this.removeEventListener(Event.ADDED_TO_STAGE, this.startPlugin);
		}

		private function stopPlugin(e):void { }
		
		private function registerEvent(e):void {
			EIF.addPluginEventListener("switch", switchHandler);
			setPanobmd = EIF.get("setpanobmd");
			setArrow = EIF.get("setarrow");
			getRotationY = EIF.get("getPanoRotY");
			setPanoTile = EIF.get("setpanotile");
			addOverlay = EIF.get("addOverlay");
			clearOverlay = EIF.get("clearOverlay");
			init(); 
		}
		
		private function init():void{
			idown = new LoaderQueue("streetview_tiledown",false);
			loader = new URLLoader(); poiLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, loaderCompleteHander);
			loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			poiLoader.addEventListener(Event.COMPLETE, poiLoaderCompleteHander);
			
			idown.addEventListener("EveryComplete",onceLoadHandler);
			idown.addEventListener("AllComplete",allLoadHandler);
			//lsvid = svid = "10161003120613120744400";
			goto("10161003120613155944700");//10161003120722135052300 //10161003120722135052300
			// snnu 10161320120824151925400
		}
		
		// this allow latlng or svid
		public function goto(...r):void
		{
			var id = 0;
			if(r.length == 1) id = r[0];
			svid = id;
			var u = SVIDxml.replace("{svid}",id);
			loader.load(new URLRequest(u));
			
			
			//links = calcLinks(svid);
			EIF.dispatchEvent(new DataEvent("notice_switchpano" , svid)); //feature
			
			trace((new Date).toLocaleTimeString()+" :Switch SOSOStreetView Scene (svid:"+svid+") ... ");
			
			EIF.dispatchEvent(new DataEvent("startloadmap"));
			EIF.dispatchEvent(new DataEvent("notice_switchpano" , svid)); //feature
			EIF.dispatchEvent(new DataEvent("overlay_all"));
			
			
		}
		
		private function loadPOIs(ix , iy){
			var u:String = POIsxml.replace("{x}" , ix).replace("{y}", iy);
			poiLoader.load(new URLRequest(u));
		}
		
		private var nodes:Object = new Object();
		private var roads:Object = new Object();
		private var edges:Object = new Object();
		
		private function poiLoaderCompleteHander(e):void
		{
			var v = new XML((e.target as URLLoader).data);
			var l = v.pois.poi.length();
			
			for(var i:int = 0; i<l ; i++)
			{
				if(v.pois.poi[i].@level == "0") nodes[svid]["pois"].push( [v.pois.poi[i].@catalog , parseFloat(v.pois.poi[i].@x) ,parseFloat(v.pois.poi[i].@y) ,  parseFloat(v.pois.poi[i].@h) , v.pois.poi[i].@name , v.pois.poi[i].@id] );
			}
			trace("\n==>"+l+"pois and "+nodes[svid]["pois"].length+"vailed \n")
			creatSpan();
		}
		
		private function loaderCompleteHander(e):void
		{

			var _xml = new XML((e.target as URLLoader).data);
			if(_xml.error.length()>0) trace("load error")
			else{
				parserXML(_xml);
				//trace("dispatch:"+nodes[svid].x+","+nodes[svid].y)
				EIF.dispatchEvent(new DataEvent("notice_streetview_loadinfo" , false , false,nodes[svid].x+","+nodes[svid].y));//
				imgLoader(THUMB.replace(/{svid}/ig , svid));
				loadPOIs(nodes[svid].x , nodes[svid].y)
			}
			
			
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void {
           JavaScript.call("alert", event.toString());
        }


		private function onceLoadHandler(e):void
		{
			var s:BitmapData = (e.target.target as Bitmap).bitmapData;
			var key:String = e.target.name;
			var l = key.split("||"); //[ix , iy , iz ,svid]
			//trace((new Date).toLocaleTimeString()+" : Loading SOSOStreetView  " + key);
			setPanoTile(s , parseInt(l[0])*512 , parseInt(l[1])*512)
		}
		
		private function allLoadHandler(e):void
		{
			
		}
		
		private var firstRun:Boolean = true;
		
		
		private function parserXML(v):void
		{
			nodes = new Object();
			
			
			//保存道路信息、节点信息、道路内路径信息
			for(var i:int = 0,l = v.roads.road.length(); i<l ; i++)
			{
				//保存道路信息
				roads[v.roads.road[i].@id] = {name : v.roads.road[i].@name}
				
				//保存节点信息 和 道路内 路径信息
				for(var j:int = 0 , r = v.roads.road[i].points.point.length(); j<r ; j++)
				{
					
					var cvid = v.roads.road[i].points.point[j].@svid ;
					
					if(nodes[cvid]==undefined)
					{
						nodes[cvid] = {
							svid : v.roads.road[i].points.point[j].@svid,
							x : parseFloat(v.roads.road[i].points.point[j].@x) , 
							y : parseFloat(v.roads.road[i].points.point[j].@y) , 
							edges : [] ,//路径 ,
							pois : [] ,//兴趣点
							dir : -1 , //pitch
							road : v.roads.road[i].@id //所属道路id
						
						}
					}
					
					//道路内 路径
					if(j<r-1) nodes[v.roads.road[i].points.point[j].@svid].edges.push(v.roads.road[i].points.point[j+1].@svid);
					if(j>0)   nodes[v.roads.road[i].points.point[j].@svid].edges.push(v.roads.road[i].points.point[j-1].@svid);
				}
				
			}
			
			//道路分支 路径
			l = v.vpoints.vpoint.length();
			for(var i:int = 0; i<l ; i++)
			{
				for(var j:int = 0 , r = v.vpoints.vpoint[i].link.length(); j<r ; j++)
				{
					nodes[ v.vpoints.vpoint[i].@svid ].edges.push(  v.vpoints.vpoint[i].link[j].@svid );
					nodes[ v.vpoints.vpoint[i].link[j].@svid ].edges.push( v.vpoints.vpoint[i].@svid );
				}
			}
			
			//偏航(heading or yaw*-1)
			nodes[svid]["dir"] = parseInt(v.basic.@dir)
			
			
			//保存poi信息 ,未操作
			l = v.pois.poi.length();
			
			/*
			for(var i:int = 0; i<l ; i++)
			{
				nodes[svid]["pois"].push( [v.pois.poi[i].@catalog , parseFloat(v.pois.poi[i].@x) ,parseFloat(v.pois.poi[i].@y) ,  parseFloat(v.pois.poi[i].@h) , v.pois.poi[i].@name , v.pois.poi[i].@id] );
			}
			*/
			
			//saveXML()
			
		}
		
		//保存新链表
		public function saveXML(from:Boolean = true):void
		{
			var file:FileReference = new FileReference();
			if(from)
			{
				var aXML = [];
				for(var i in nodes)
				{
					var nXML = "\t" + '<node svid = "'+ nodes[i].svid +'" x="'+nodes[i].x+'" y="'+nodes[i].y+'">\n'
					var oXML = [];
					for(var j:int = 0 ; j<nodes[i].edges.length ; j++)
					{
						oXML[j] = "\t\t\t" + '<edge id="'+nodes[i].edges[j] +'" />' ;
					}
					nXML = nXML + "\t\t<edges>\n" + oXML.join("\n") + "\n\t\t</edges>\n";
					
					aXML.push(nXML + "\t</node>");
				}
				file.save( "<map>\n" + aXML.join("\n") + "\n</map>" ,"list.xml");
				
			}else{
				//file.save(_xml,"list.xml");
			}
		}
		
		
		//采集车的heading为图片中央 180
		private function calcLinks(id):Array
		{
			
			if(nodes[id])
			{
				var k = nodes[id].edges;
				var o = [];
				for(var i:int = 0; i<k.length ; i++)
				{
				//方位角, 正北为0
					var m = nodes[k[i]];
				
					var v = calcRot(nodes[id] , m)
				
					o[i] ={id: k[i], rot: Math.round(v)};
				}
				return o;
			}
			else return [];
		}
		
		// 左下角原点 
		private function calcRot(o,t):Number
		{
			var v = Math.atan2(o.y - t.y , t.x - o.x )*180/Math.PI
			if(v>=-90) v = 90 + v;
			else v = 360 + 90 + v;
			return v;
		}
		
		
		//莫卡托平面坐标 与 EPSG:4362 转换
		private var k = {
			lngFrom4326ToProjection : function(c){c=parseFloat(c);return c*111319.49077777778} ,
			latFrom4326ToProjection : function(c){c=parseFloat(c);c=Math.log(Math.tan((90+c)*0.008726646259971648))/0.017453292519943295;c*=111319.49077777778;return c},
			lngFromProjectionTo4326 : function(c){return c/111319.49077777778},
			latFromProjectionTo4326 : function(c){c=c/111319.49077777778;return c=Math.atan(Math.exp(c*0.017453292519943295))*114.59155902616465-90}
		};
		
		private function switchHandler(e:* = null):void
		{
			goto(e.data as String);
		}
		
		public var links = [];
		private function switchMap():void
		{
			links = calcLinks(svid);
			setArrow(links , nodes[svid]["dir"] );//调整 道路
			setPanobmd(bitmapData as BitmapData);
			EIF.dispatchEvent(new DataEvent("StreetView_loadendmap" , false , false,svid));//bitmapData as BitmapData
			
			idown.clear();
			//不是所有区域都有超高分辨率 8000*4000
			for(var i:int=0 ; i<=7 ; i++)
			{
				for(var j:int=0 ; j<=3 ; j++)
				{
					idown.add(tileParser(template , [i,j,0,svid]) , [i,j,0,svid].join("||"))
				}
			}
			idown.start();
			
		}
		
		
		// loading
		private var _Loader:Loader = new Loader();
		
		private function imgLoader(u:String)
		{
			//u = "map.jpg";
			_Loader.load(new URLRequest(u)); 
			_Loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,loadProgressHandler,false,0,true);  
			_Loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loadCompleteHandler,false,0,true); 
		}
		
		private function loadProgressHandler(e:ProgressEvent)
		{
			trace("Loading ... "+Math.round(100 * e.bytesLoaded / e.bytesTotal) + "%");
			//EIF.dispatchEvent(new NoticeEvent("loadingmap",(Math.round(100 * e.bytesLoaded / e.bytesTotal) + "%")));
		}
		
		private var flag:Boolean = false;
		private var byteData:ByteArray = new ByteArray();
		private function loadCompleteHandler(e:Event){
			
			//JavaScript.call("alert","this is ok")
 			if(_Loader.content)
			{
				  bitmapData = (_Loader.content as Bitmap).bitmapData.clone();
				 (_Loader.content as Bitmap).bitmapData.dispose();
				 dispatchLoadedEnd();
			}
				
			
		}
		
		private function dispatchLoadedEnd():void
		{
			_Loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS,loadProgressHandler); 
			_Loader.unloadAndStop(true);
			switchMap();
		}
		
		private function mins(v:Array = null,o:Number = 0):int
		{
			var a:Number = 9999 , b:Number = 0 , k:int = 0; 
			for(var i = 0 ; i<v.length ; i++ ){
				b = Math.min(Math.abs(o-Number(v[i].rot)),Math.abs(o-360-Number(v[i].rot)));
				if( b < a) {
					a = b;
					k = i;
				}
			}
			return k;
		}
		
		private function getClosedRoad(v:int = 0):String
		{
			//getRotationY() 为全景Y旋转 ;
			var rotY = (getRotationY()+36000)%360 ;
			if(v == 0) rotY = (rotY + 180)%360;
			
			v = mins(links,rotY);
			return links[v].id;
		}
		
		private function tileParser(k:String , b:Array):String
		{
			
			var p = ["x","y","z","svid"];
			for(var i:int = 0 ; i<p.length ; i++)
			{
				var r:RegExp = new RegExp("{"+p[i]+"}", "ig");
				k = k.replace(r , b[i])
			}
			//trace(k)
			return k;
		}
		
		public function toForward():void { goto(getClosedRoad(1)); }
		
		public function toBack():void { goto(getClosedRoad(0)) }
		
		private function creatSpan()
		{
			clearOverlay();
			var k = nodes[svid]["pois"];
			for(var i=0;i<k.length;i++)
			{
				var ix = calcRot(nodes[svid] , {x:nodes[svid]["pois"][i][1],y:nodes[svid]["pois"][i][2]});
				var iy = (90 - nodes[svid]["pois"][i][3] );// / 180;
				var iz = getDistance(parseFloat(nodes[svid].x) , nodes[svid]["pois"][i][1] , parseFloat(nodes[svid].y) ,  nodes[svid]["pois"][i][2] )
				var it = nodes[svid]["pois"][i][4];
				
				var span = new Span(it , String(iz)+"米" , new Point(ix,iy));

				addOverlay(span);
			}
			
		}
		
		private function getDistance(x1,x2,y1,y2):int
		{
			return int( Math.sqrt( (y1-y2)*(y1-y2) + (x1-x2)*(x1-x2) ) );
		}
		
	}
	
}
