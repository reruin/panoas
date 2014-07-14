package pano.extras {
	import flash.geom.Point;
	import flash.display.* ;
	import flash.events.*;
	//import pano.data.stack;
	//import pano.core.*;
	import pano.events.*;
	import pano.utils.TweenNano;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import pano.core.Pano;
	import pano.utils.PolyS;
	import pano.controls.ExtraManager;
	import pano.core.Config;
	//import pl.bmnet.gpcas.geometry.*;
	//import pl.bmnet.gpcas.util.*;
	
	public class Overlay extends Sprite implements IExtra{
		public static const VER:Number = 1.0;
		
		private var _OverList = new Array();//仅提供页面交互读取 A-Z
		private var _overlayInfo:Dictionary = new Dictionary();
		private var EM:ExtraManager;
		private var _pano:Pano;
		private var _poly:PolyS;
		
		public function Overlay(p:ExtraManager,v:Array)
		{
			this.addEventListener(Event.ADDED_TO_STAGE, this.startPlugin);
			this.addEventListener(Event.REMOVED_FROM_STAGE, this.stopPlugin);
			EM = p; _pano = v[0];//EM.get("layer")(); 
			_pano.addChild(this);_poly = new PolyS();
			init();
		}
		
		private function startPlugin(e){
			trace((new Date).toLocaleTimeString()+" : Loading Overlay Plugin ... ");
			
			EM.set("addOverlay",addOverlay);
			EM.set("clearOverlay",clearOverlay);
			
			this.removeEventListener(Event.ADDED_TO_STAGE, this.startPlugin);
		}
		
		private function stopPlugin(e){
			_overlayInfo = null;
			_poly = null;
			
			trace((new Date).toLocaleTimeString()+" : UnLoad Overlay Plugin Success ! ");
		}
		
		private function init(){
			EM.addEventListener("render",refresh,false,0,true);
			EM.addEventListener("overlay_add",addHandler);
			EM.addEventListener("overlay_addpolygon",addPolygonHandler);
			//EM.addEventListener("overlay_all",addOverlaysHandler);
			
			this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
			this.addEventListener(MouseEvent.CLICK,clickHandler);
			this.addEventListener(MouseEvent.MOUSE_OVER,overHandler);
			this.addEventListener(MouseEvent.MOUSE_OUT,outHandler);
			
			EM.dispatchEvent(new NoticeEvent("overlay_init_ready"));
		}
		
		private function addOverlaysHandler(e:*):void
		{
			var tar = EM.get("getOverlays")();
			//var tar = e.feature;
			
			for(var i:int = 0; i<tar.length ; i++)
			{
				//addOverlay( Polygon.fromString(tar[i].path) , tar[i].image , tar[i].content );
			}
		}
		
		private function addHandler(e:*):void
		{
			var tar = e.feature;
			
			addOverlay( new Marker(tar.p , tar.e , tar.f) );			
		}
		
		private function addPolygonHandler(e:*):void
		{
			var tar = e.feature; 
			addOverlay( Polygon.fromString(tar.p) );
		}
		
		private function mouseDownHandler(e:MouseEvent):void{
			//EM.dispatchEvent( new NoticeEvent(e.target.event , {url:e.target.feature , obj : e.target} , e.target.position) );
		}
		
		private function clickHandler(e:MouseEvent):void
		{
			
			if(e.target.hasOwnProperty("type")){
				var type : String = e.target["type"];
				if(type == "button") { _pano.dispatchEvent(new NoticeEvent("switch",e.target["data"])); }
				else EM.call("openWindow" , e.target["data"])
			}
				
		}
		
		private function overHandler(e:*):void
		{
			
			if(e.target.hasOwnProperty("type"))
			{
				if(e.target["type"] == "polygon") TweenNano.to(e.target,0.5,{alpha:0.35});
				
				if(Config["poi_tip"] && e.target["data"])
					if(e.target["data"]["title"]) EM.call("show",e.target , e.target["data"]["title"])
			}
				
		}
		
		private function outHandler(e:*):void
		{
			if(e.target.hasOwnProperty("type"))
			{
				
				if(e.target["type"] == "polygon")  TweenNano.to(e.target,0.6,{alpha:0})
				
				if(Config["poi_tip"] && e.target["data"]) EM.call("hide");
			}
				
		}
		
		
		
		//========================================
		
		
		public function addOverlay(s):void
		{ 
			_OverList.push(s);
			this.addChild(s); 
			//_overlayInfo[s] = [img , info];
		
		}
		
		public function removeOverlay(s):void{ this.removeChild(s); }
		
		public function clearOverlay():void
		{
			var oNum = _OverList.length;
			for (var j=0;j<oNum;j++)
			{
				this.removeChild(_OverList[j]);
				delete _overlayInfo[_OverList[j]]
			}
			_OverList.splice(0,_OverList.length);
		}
		
		public function removeByName(v:String){
			var oNum = _OverList.length;

			for (var j=oNum-1;j>=0;j--)
    		{
				
				if(_OverList[j].name==v)
				{
					this.removeChild(_OverList[j]);
					_OverList.splice(j,1);
					break;
				}
			}
		}
		
		
		// 对node 做边界处理
		public function refresh(e:* = null):void
		{
			
			_poly.set( EM.call("getViewBound") );
			//trace(EM.exec("getViewBound"))
			var oNum = _OverList.length;
			for (var i=0;i<oNum;i++)
    		{
				_OverList[i].update( panoToScreen(_OverList[i].position) ); 
    		} 
		}
		
		private function panoToScreen(p)
		{
			
			if(p is Point)
				return _poly.containsPoint(p)?EM.call("panoToScreen",p):new Point(-1,-1); //return _poly.containsPoint(p)?_pano.panoToScreen(p):new Point(-1,-1);
			else
			{ 
				//trace("transPoly")
				var t = [];
				p = _poly.intersection(p);
				//trace("transPoly _ END")
				for(var i:int = 0 ; i<p.length ; i++)
				{
					//trace("P"+p)
					for(var j:int = 0; j<p[i].length ; j++)
					{
						p[i][j] = EM.call("panoToScreen",p[i][j]);
					}
					
				}
				// p 是多边形组
				
				return p;
			}
		}
		
		public function get OverList():Array { return _OverList; }

		
		public function resize():void{ refresh();}
		
	}
	
}