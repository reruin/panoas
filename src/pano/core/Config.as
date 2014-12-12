package pano.core{
	
	import flash.net.LocalConnection;
	import pano.utils.StringUtil;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import pano.core.Stack;
	import flash.geom.Point;
	import pano.utils.Logger;
	import pano.ExtraInterface;
	
	import flash.net.FileReference;
	
	public dynamic class Config extends EventDispatcher{
		
		//////////////////////////////
		// 配置载入
		//////////////////////////////
		public static var xml:String = "map.xml";
		public static var dataXml:XML;

		public static var MAX_FOCUS:int = 1000;
		public static var MIN_FOCUS:int = 200;
		public static var maxRotationX:int = 90;
		public static var minRotationX:int = -90;
		
		public static var maxPitch:int = 90;
		public static var minPitch:int = -90;
		
		public static var WIDTH:int = 550;
		public static var HEIGHT:int = 400;
		public static var focusR:Number = 1;
		public static var maxArrow:int = 5;
		
		public static var useground:Boolean = false;
		public static var usefoot:Boolean = false;
		public static var usethumb:Boolean = true;
		public static var ComID:String = "";
		public static var pano:String = "";
		public static var bg:String = "";
		public static var panoXML:String = "";//list.xml
		public static var plugins:String = "";
		public static var _opposite:Boolean = false;
		public static var _poi_opposite:Boolean = false;
		public static var useLatlng:String;
		public static var px:String;
		public static var latlng:Boolean = false
		public static var latlngs:Array;
		public static var pxs:Array;

		///////////////////////////////
		// UI 图片或者 swf::skin
		//////////////////////////////
		//public static var iconsPath:String = "Arrow.blue/";
		public static var viewStreetPath:String = "";	//list.xml
		public static var extras:String = "";
		public static var extraList:Array = [];
		
		/*public static var bgSoundUrl = "music.mp3";
		public static var birdMap = "res/snnu.png";
		public static var wall3DPath = "res/photo/wall3d/";
		public static var helpPath = "res/help.png";
		public static var wallPath = "res/wall.xml";*/
		//public static var help
		
		///////////////////////////////
		//  全景参数
		//////////////////////////////

		public static var url:String = "map.jpg";
		public static var focus:uint = 450;
		//图标大小
		public static var IconPix:Number = 36;
		
		//锁定键盘
		public static var LockKeyBoard:Boolean  = false;
		public static var LockViewX:Boolean = false;
		
		//缩放舞台
		public static var autoScaleToStage:int = 0;
		
		public static var playTime:int = 30;
		public static var playRot:int = 1;
		public static var playTimeX:int = 20;
		public static var playTimeY:int = 10;
		
		public static var zoomTime:Number = 1;
		public static var maxZoomLevel:Number = 2.5;
		public static var minZoomLevel:Number = 0.75;
		
		public static var mode3D:Boolean = false;
		//////////////////////////////
		// 路径信息
		/////////////////////////////
		public static var panoMap = "map.jpg";
		public static var configFile = "res/Config.xml";
		
		public static var restart:Function;
		
		public static var debug:Boolean = false;
		
		public static var styles:Object = {font:"黑体"};
		
		private static var instance:Config;
		
		public static var svid:String;
		
		public static var pluginsReady:Boolean = false;
		
		private var EIF:ExtraInterface;
		
		public function Config(o:Object)
		{
			if(instance)
            {
               throw new Error("error");
            }
			
			instance = this;
			StringUtil.paramToVar(o,Config);

			EIF = ExtraInterface.getInstance();
			
		}
		
		private function parseNum(v):Array
		{
			
			var p:Array = v.split(",");
			return [parseFloat(p[0]),parseFloat(p[1])];
		}
		
		public static function init():void
		{
			
			
			if(Config.pano!="") Config.viewStreetPath = '<SoulPano>'+
														'<panoramas>' + 
														'<panorama id="1" audio="'+Config.bg+'" title="1" url="'+Config.pano+'" dir="0" position="0.5,0.5">' + 
															'<edges></edges>' + 
															'<pois></pois>' + 
														'</panorama>' + 
														'</panoramas>' +
													'</SoulPano>';
			else if(Config.panoXML != "") Config.viewStreetPath = Config.panoXML;
			//if(Config.slicn)
			var p:Array = Config["url"].split("/");
			Config["path"] = p.slice(0,p.length-1).join("/") + "/"
			
			//加载 Url 中的插件
			if(Config.plugins!="")
			{
				var plugins:Array = Config.plugins.split(";");
				if(Config["path"])
				{
					for(var i in plugins){
						Stack.plugins.push({
								   title : "plugins[i]",
								   path: Config["path"] + "res/"+plugins[i]+".swf",
								   value:""
								   })
					}
				}
				
			}
			
			//degug
			if(Config.viewStreetPath=="") Config.viewStreetPath = "list.xml"
			Config.parseUrl(Config.viewStreetPath);
		}
		
		
		public static function parseUrl(u:String , single:Boolean = false):void
		{
			//if (!instance || u=="") return;
			
			if(single) {
				u = '<SoulPano>' + 
						'<panoramas>'+
							'<panorama id="1" title="1" url="'+u+'" dir="0" position="0.5,0.5">' + 
								'<edges></edges>' + 
								'<pois></pois>' + 
							'</panorama>' + 
						'</panoramas>'+
					'</SoulPano>'; 
			}
			
			(u.charAt(0)=="<") ? instance.parse(u) : instance.loadXML(u);
			
			
		}
		
		public function loadXML(v):void
		{
			var configUrlLoader:URLLoader = new URLLoader();
				configUrlLoader.addEventListener(Event.COMPLETE, configUrlLoaderComplete);
				configUrlLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				configUrlLoader.load(new URLRequest(v));
		}
		
		private function ioErrorHandler(e:IOErrorEvent):void
		{
			this.dispatchEvent(new Event("config_complete"));
		}
		
		private function configUrlLoaderComplete(e:Event):void {
			parse((e.target as URLLoader).data)
		}
		
		public static function getRoads():Object
		{
			return Stack.roads;
		}
		
		public static function getNodes():Object
		{
			return Stack.nodes;
		}
		
		
		
		public static function getPluginsConfig(v):Object
		{ 
			for(var i in Stack.plugins)
			{
				if(Stack.plugins[i]["title"] == v) return Stack.plugins[i];
			}
			return {};
		}
		
		public static function getGlobalConfig(v:String){
			
			return Config[v];
		}
		
		public static function readXML(u):void
		{
			instance.parseMain(u);
		}
		
		private function parseMain(u):void
		{
			EIF.trace("Load panos");
			
			var _xml:XML =  (u is String) ?  new XML(u) : u;
			var l:int;
			if(_xml.pois)
			{
				l = _xml.pois.poi.length();
				for( var i:int = 0; i<l; i++ )
				{
					var id = _xml.pois.poi[i].@id;
					var ll:int = _xml.pois.poi[i].rel.length();
					
					Stack.pois[id] = {
						type : _xml.pois[0].poi[i].@type.toString(),
						position :  creatPointFromString(_xml.pois[0].poi[i].@position , true),
						latlng : creatPointFromString(_xml.pois[0].poi[i].@latlng.toString()),
						h : parseInt(_xml.pois[0].poi[i].@h.toString()),
						title: _xml.pois[0].poi[i].@name,
						media : parseMedia((_xml.pois[0].poi[i].@media).toString()),
						content : ll==0?_xml.pois[0].poi[i]:_xml.pois[0].poi[i].@content.toString(),
						data : _xml.pois[0].poi[i].@data.toString(),
						icon : _xml.pois[0].poi[i].@icon.toString(),
						z : _xml.pois[0].poi[i].@z.toString()
					};
					
					
					for(var j:int = 0;j<ll;j++)
					{
						var rid:String = _xml.pois.poi[i].rel[j].@id.toString(),
						dz:String = _xml.pois.poi[i].rel[j].@z.toString(),
						po = creatPointFromString(_xml.pois.poi[i].rel[j].@position.toString());
						_setPanoramaPoi(rid , Stack.extend(Stack.pois[id] , {z:dz , position:po}) );
						
					}
					
				}
			}
						
			
			// parse panoramas
			if(_xml.panoramas)
			{
				var path:String = (_xml.panoramas.@path).toString(),
				l  = _xml.panoramas.panorama.length();
				
				for( var i:int = 0; i<l; i++ )
				{
					var id:String = _xml.panoramas.panorama[i].@id; //可用 attribute("id")
					var title:String = _xml.panoramas.panorama[i].@title;
					var url:String = (_xml.panoramas.panorama[i].@url).toString();
					if(url=="") url = path.replace("{id}",id);
					var dir:Number = _getPanoramaDir(_xml.panoramas.panorama[i].@dir , id);
					var edges = new Array() , overlays = new Array() , pois = [];
					var p:Point = new Point();
					var latlng:Point;
					
					if(_xml.panoramas.panorama[i].@position.toString() !="") p = creatPointFromString(_xml.panoramas.panorama[i].@position.toString());
					if(Config.latlng) latlng = new Point(Config.latlngs[1] + p.y * Config.pxs[1],Config.latlngs[0] + p.x * Config.pxs[0]*-1);
					//latlng = 
					if(_xml.panoramas.panorama[i].edges.length())
					{
						for(var j:int = 0; j< _xml.panoramas.panorama[i].edges[0].edge.length(); j++)
						{
							var edgeid:String = _xml.panoramas.panorama[i].edges[0].edge[j].@id;
							var r:int = int(_xml.panoramas.panorama[i].edges[0].edge[j].@rot);
							
							edges.push({ id:edgeid, rot: r });
						}
						//trace("LENGTH Edges ::"+_xml.panoramas.panorama[i].edges.length())
					}
					//trace("LENGTH Overlays ::"+_xml.panoramas.panorama[i].overlays.length())
					
					if(_xml.panoramas.panorama[i].pois.length())
					{
						for(var j:int = 0; j< _xml.panoramas.panorama[i].pois[0].poi.length(); j++)
						{
							var obj:Object = {};
							//Config.
							if(_xml.panoramas.panorama[i].pois[0].poi[j].@type != undefined ) obj["type"] = _xml.panoramas.panorama[i].pois[0].poi[j].@type.toString();
							if(_xml.panoramas.panorama[i].pois[0].poi[j].@position != undefined ) obj["position"] = creatPointFromString(_xml.panoramas.panorama[i].pois[0].poi[j].@position);
							if(_xml.panoramas.panorama[i].pois[0].poi[j].@h != undefined) obj["h"] = int(_xml.panoramas.panorama[i].pois[0].poi[j].@h.toString());
							if(_xml.panoramas.panorama[i].pois[0].poi[j].@title != undefined) obj["title"] = _xml.panoramas.panorama[i].pois[0].poi[j].@title.toString();
							if(_xml.panoramas.panorama[i].pois[0].poi[j].@media != undefined) obj["media"] = parseMedia(_xml.panoramas.panorama[i].pois[0].poi[j].@media.toString());
							if(_xml.panoramas.panorama[i].pois[0].poi[j].@content != undefined) obj["content"] = _xml.panoramas.panorama[i].pois[0].poi[j].@content.toString();
							if(_xml.panoramas.panorama[i].pois[0].poi[j].@data != undefined) obj["data"] = _xml.panoramas.panorama[i].pois[0].poi[j].@data.toString();
							if(_xml.panoramas.panorama[i].pois[0].poi[j].@id != undefined) obj["id"] = _xml.panoramas.panorama[i].pois[0].poi[j].@id.toString();
							if(_xml.panoramas.panorama[i].pois[0].poi[j].@latlng != undefined) obj["id"] = creatPointFromString(_xml.panoramas.panorama[i].pois[0].poi[j].@latlng.toString());
							if(_xml.panoramas.panorama[i].pois[0].poi[j].@z != undefined) obj["z"] = _xml.panoramas.panorama[i].pois[0].poi[j].@z.toString();
							
							
							//if(Stack.pois[id])
							//extend poi
							var rel:String = _xml.panoramas.panorama[i].pois[0].poi[j].@rel.toString();
							if(rel!="" && Stack.pois[rel])
							{
								obj = Stack.extend(Stack.pois[rel] , obj);
							}
							//trace("position==>"+obj["position"])
							_setPanoramaPoi(id , obj);
							//pois.push(obj);
						}
					}
					
					
					
					Stack.nodes[id] = Stack.extend(Stack.nodes[id],{
						id:id,
						title:title,
						sound:bg,
						url:url,
						dir: dir,
						edges:edges,
						overlays : overlays,
						//pois : pois,
						position:p,
						latlng : latlng
					});
					
					//如果pois & panorama 都没有关联 poi 的话，需要置空 
					if(Stack.nodes[id].pois == undefined) Stack.nodes[id].pois = [];
					
					if(Stack.svid==null) Stack.svid = id; 
					
				}
			}
			
			
			
			// parse Roads
			if(_xml.roads)
			{
				l = _xml.roads.road.length();
				var path:String = (_xml.panoramas.@path).toString();
				for(var i:int = 0; i<l;i++)
				{
					
					var id = _xml.roads.road[i].@id;
					var routes = _xml.roads.road[i].@route.toString().split(";");
					
					for(var j:int = 0;j<routes.length ; j++)
					{
						var route = routes[j].split(",");
						for(var k:int = 0 ; k<route.length ; k++) _setPanoramaObject(route[k] , path);
						if(route.length>1)
						{
							for(var k:int = 0 ; k<route.length-1;k++)
							{
								
								var cp:String = route[k],
								np:String = route[k+1],
								cp_r:Number = Stack.nodes[cp].dir;
								if(cp.length>15){
									cp_r = Number(cp.substring(15,18));
									cp = cp.substring(0,15);
								}
								
								_setPanoramaEdge(cp , {id:np, rot: cp_r} );
								_setPanoramaEdge(np , {id:cp, rot: cp_r - 180} );
							}
						}
					}
					
					Stack.roads[id] = {
						id : id,
						title : _xml.roads.road[i].@title,
						start : _xml.roads.road[i].@start,
						position : creatPointFromString(_xml.roads.road[i].@position.toString()),
						audio : _xml.roads.road[i].@audio.toString(),
						thumb : _xml.roads.road[i].@thumb.toString(),
						content : _xml.roads.road[i],
						media : parseMedia(_xml.roads.road[i].@media.toString())
					}
				}
			}
			
			if(_xml.config)
			{
				if(_xml.config.start!=undefined) Stack.svid = _xml.config.start ;
				if(_xml.config.face!=undefined) Stack.face = creatPointFromString(_xml.config.face);
				
				// old config
				if(_xml.@face.toString()!="") Stack.face = creatPointFromString(_xml.@face.toString());
			}
			
			
			_xml = null;
			
			
			//发送加载配置文件 事件
			if(EIF.ready) EIF.dispatchEvent(new Event("svloaded_complete"));
		}
		
		
		private function _setPanoramaObject(id:String , path:String = ""):void
		{
			//<panorama>对象优先
			Stack.nodes[id] = Stack.extend({
				id : id ,
				url: path.replace("{id}" , id),
				dir: _getPanoramaDir("",id),
				edges:[],
				overlays : [],
				pois : [],
				position: null,
				latlng : null
			},Stack.nodes[id]);
		}
		
		//private function _setPanoramaObject
		private function _getPanoramaUrl(id:String):void{
			
		}
		
		private function _setPanoramaPoi(id:String , o:Object):void
		{
			if(Stack.nodes[id] == undefined){
				Stack.nodes[id] = {};
				Stack.nodes[id].pois = [];
			}
			Stack.nodes[id].pois.push( o );
		}
		
		private function _setPanoramaEdge(id:String , o:Object):void
		{
			if(Stack.nodes[id] == undefined){
				Stack.nodes[id] = {};
				Stack.nodes[id].edges = [];
			}
			
			var rid:String = o.id;
			
			for(var i:int=0,l=Stack.nodes[id].edges.length;i<l;i++)
			{
				if(Stack.nodes[id].edges[i].id == rid)
				{
					//Stack.nodes[id].edges[i] = o;
					return;
				}
			}
			
			Stack.nodes[id].edges.push(o);
		}
		
		
		
		private function _getPanoramaDir(dir:String , id:String):Number
		{
			var d:Number = 0;
			if(dir == "")
			{
				if(id.length ==15 ){
					var k = id.substring(12,15);
					d = Number(k);
				}
			}else
			{
				d = Number(dir)
			}
			return d;
		}
		
		public function parse(v):void
		{
			var _xml = new XML(v);
			//voice = _xml.@sound;
			var l:int;
			
			if(_xml.plugins && _xml.plugins.plugin.length())
			{
			
				var path:String = (_xml.plugins.@path).toString(),
				l =  _xml.plugins.plugin.length();
				
				for( var i:int = 0; i<l; i++ )
				{
					var title:String = (_xml.plugins.plugin[i].@title).toString();
					var k:int = Stack.plugins.length;
					Stack.plugins[k] = StringUtil.xmlToVar(_xml.plugins.plugin[i]);
					Stack.plugins[k]["title"] = title;
					Stack.plugins[k]["path"] = path + title + ".swf";
					Stack.plugins[k]["value"] = _xml.plugins.plugin[i].toString();
				}
			}
			
			if(_xml.config)
			{
				StringUtil.xmlToVar(_xml.config[0] , Config);
				if(_xml.config.styles != "" && _xml.config.styles!=undefined)
				{
					Config.styles = StringUtil.xmlToVar(_xml.config[0].styles[0]);
					//StringUtil.xmlToVar(_xml.config.styles[0] , Config.styles);
				}
			}

			
			if(Config.useLatlng!=undefined){
				Config.latlng = true;
				Config.latlngs = parseNum(Config.useLatlng);
				Config.pxs = parseNum(Config.px);
			}
			
			if(Config["usefoot"])
			{
				Stack.arrowBMD = new ArrowBMD();
				Stack.arrowShadowBMD  =  new ArrowShadowBMD();
				Stack.arrowHoverBMD  =  new ArrowHoverBMD();
			}
			parseMain(_xml);
			//发送事件config 加载完毕事件
			this.dispatchEvent(new Event("config_complete"));
			
			//EIF.dispatchEvent(new Event("StreetView_ready"));
			
			//if(voice && EIF.get("playSound")) EIF.get("playSound")(voice);
		}
		
		// lat , lng => y , x
		private function creatPointFromString(v:String , checkoppo:Boolean = false)
		{
			var oppo:Boolean = _poi_opposite;
			if(v=="") return null;
			if(v.indexOf(";")!=-1)
			{
				return stringToPolygon(v);
			}else
			{
				var t = v.split(",");
				//if(geog == false) t[0] = 0.5 - parseFloat(t[0]);
				if(checkoppo && oppo) t[1] = _fixPoiOpposite(Number(t[1]));
				return new Point(t[1],t[0]);
			}
		}
		
		private function stringToPolygon(v):Array
		{
			var oppo:Boolean = _poi_opposite;
			var t = v.split(";");
			for(var i=0; i<t.length ; i++)
			{
				var k = t[i].split(",");
				
				if(oppo) k[0] = _fixPoiOpposite(Number(k[0]) , true);
				
				t[i] = new Point(Number(k[0]) , Number(k[1]) );
				
			}
			return t;
		}
		
		private function _fixPoiOpposite(v:Number , p:Boolean = false):Number
		{
			var k : Number = (v + 180+360)%360;
			if(p)
			{
				if(v>720 && k<180) k = k + 360;
			}
			
			return k;
		}
		
		private function parseMedia(v:String):Array
		{
			if(v.length==0) return [];
			var a:Array = v.split(";");
			for(var i:int=0;i<a.length;i++) a[i] = a[i].split(":");
			return a;
		}
		
		public static function xmlValue(xml , key)
		{
			return xml.hasOwnProperty(key) ? xml.@[key]: null;
		}
		/*
		public static function saveXML(from:Boolean = false):void{
			
			var file:FileReference = new FileReference();
			if(from)
			{
				var aXML = [];
				for(var i:int=0; i<Stack.nodes.length; i++)
				{
					var nXML = "\t" + '<node id = "'+ Stack.nodes[i].id +'" title="'+Stack.nodes[i].title+'" url="'+Stack.nodes[i].url+'" dir="'+Stack.nodes[i].dir+'" position="'+p2s(Stack.nodes[i].position)+'">\n'
					var oXML = [];
					for(var j:int = 0 ; j<Stack.nodes[i].edges.length ; j++)
					{
						oXML[j] = "\t\t\t" + '<edge id="'+Stack.nodes[i].edges[j].id +'" rotation="'+Stack.nodes[i].edges[j].rot+'" />' ;
					}
					nXML = nXML + "\t\t<edges>\n" + oXML.join("\n") + "\n\t\t</edges>\n";
					oXML = [];
					for(var j:int = 0 ; j<Stack.nodes[i].overlays.length ; j++)
					{
						oXML[j] = "\t\t\t" + '<overlay type="polygon" path="'+Stack.nodes[i].overlays[j].path+'" title="'+Stack.nodes[i].overlays[j].title+'" image="">'+Stack.nodes[i].overlays[j].content+'</overlay>' ;
					}
					aXML[i] = nXML + "\t\t<overlays>\n" + oXML.join("\n") + "\n\t\t</overlays>\n\t</node>";
					
				}
				file.save( "<map>\n" + aXML.join("\n") + "\n</map>" ,"list.xml");
				
			}else
				file.save(_xml,"list.xml");
		}
		*/
		public static function doClearance() : void 
		{
			try {
				new LocalConnection().connect('foo');
				new LocalConnection().connect('foo');
			} catch (e:Error) { }
		}

	}	
}