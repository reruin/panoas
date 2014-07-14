package {

	import flash.display.*;
	import flash.events.*;
	import flash.filters.GlowFilter;
	import flash.net.*;
	import pano.extra.*;
	import pano.utils.TweenNano;
	import flash.text.*;
	import fl.controls.DataGrid;
	import fl.controls.ScrollPolicy;
	import fl.data.DataProvider;
	import fl.events.DataGridEvent 
	import pano.data.*;

	//import com.tiny.ui.utils.applyAlpha;
	
	public class admin extends Sprite{
		//#869CA7
		
		private var EIF:ExtraInterface;
		private var getOverlays:Function;
		private var getNodes:Function;
		private var setEditer:Function;
		private var setPath:Function;
		private var getPath:Function;
		private var setOverlays:Function;
		private var saveXML:Function;
		private var viewToPath:Function;
		private var getNav:Function;
		private var setNodes:Function;
		
		private var layer:Sprite;
		//protected var _backAlpha:Number;
		public function admin(){
			
			if (stage == null)
            {
                this.addEventListener(Event.ADDED_TO_STAGE, this.startPlugin);
                this.addEventListener(Event.REMOVED_FROM_STAGE, this.stopPlugin);
            }else
				this.startPlugin();
		}
		
		private function startPlugin(e:Event = null):void
		{
			stage.showDefaultContextMenu = false;
			EIF = ExtraInterface.getInstance();
			trace((new Date).toLocaleTimeString()+" : Loading admin Plugin ... ");
			if(EIF.ready) 
			{
				//layer = EIF.get("layer")();
				//layer.addChild(this);
				EIF.addPluginEventListener(ExtraInterface.PLUGINEVENT_REGISTER, this.registerEvent);
			}
			
			this.visible = false ; this.alpha = 0;
			panel.mask = panel.panelMask;
			
			this.removeEventListener(Event.ADDED_TO_STAGE, startPlugin);
		}
		
		private function stopPlugin(e):void
		{
			
			EIF.removePluginEventListener(ExtraInterface.PLUGINEVENT_REGISTER, this.registerEvent);
			unregListeners();
			reset();
			trace((new Date).toLocaleTimeString()+" : UnLoad admin Plugin ... ");
		}
		
		private function registerEvent(e)
		{
			getOverlays = EIF.get("getOverlays");
			getNodes = EIF.get("getNodes");
			layer =  EIF.get("layer")();
			setEditer = EIF.get("setEditer");
			setPath = EIF.get("setPath");
			getPath = EIF.get("getPath");
			saveXML = EIF.get("saveXML");
			viewToPath = EIF.get("viewToPath");
			setOverlays = EIF.get("setOverlays");
			
			setNodes = EIF.get("setNodes");
			getNav = EIF.get("getNav");
			
			EIF.get("CustomContextMenu")("Admin Login" , start)
			
			init();
			trace("THIS IS admin2")
		}
		
				
		private var nodes:Array;
		protected function init():void
		{
			nodes = getNodes();
			loadTable()
			regListeners();
		}
		
		public function start(e){
			if(this.visible)
			{
				TweenNano.to(this,0.6,{autoAlpha:0});
				setEditer(false);
				reset();
				loadTable()
			}else
				TweenNano.to(this,0.6,{autoAlpha:1})
		}
		
		private var dpp:DataProvider = new DataProvider();
		private var dph:DataProvider = new DataProvider();
		private function loadTable():void
		{
			
			
			var list = getOverlays();
			
			for (var i in nodes)
			{ 
   				
				dpp.addItem({"id":nodes[i].id ,"名称":nodes[i].title, "URL":nodes[i].url, "旋转":nodes[i].rotation, "Position":nodes[i].rotation});
			} 
			
			
			var dgp:DataGrid = panel.panelList.panoGrid;
			var dgh:DataGrid = panel.panelList.pathGrid;
			
			dgp.columns = ["名称", "URL", "旋转","Position"];
			dgp.dataProvider = dpp;
			
			dgh.columns = ["名称", "热点坐标", "详细信息","添加时间"];
			dgh.dataProvider = dph;
			dgp.editable = true;
			
			dgp.addEventListener("itemClick" , dgpSelectHandler);
			dgh.addEventListener("itemClick" , dghSelectHandler)
			
		}
		
		private function dgpSelectHandler(e:* = null):void
		{
			if(e) dgpIndex = e.rowIndex;
			TweenNano.to(panel.panelList,0.6,{x:-332});
			TweenNano.to(panel.panelMask,0.6,{width:300});
			
			EIF.get("go")(nodes[dgpIndex].id);
			dph.removeAll();
			var list = nodes[dgpIndex].overlays;
			var dgh:DataGrid = panel.panelList.pathGrid;
			for(var i:int = 0; i<list.length ; i++)
			{
				dph.addItem({"名称":list[i].title, "热点坐标":list[i].path, "详细信息":list[i].content, "添加时间":"2013-02-27"});
			}
			
			
		}
		
		private var dgpIndex:int = 0;
		private var dghIndex:int = 0;
		private var addMode:Boolean = false;
		private function dghSelectHandler(e:* = null):void
		{
			if(e) dghIndex = e.rowIndex;
			TweenNano.to(panel.panelMask,0.6,{width:600});
			var h = nodes[dgpIndex].overlays[dghIndex];
			panel.panelList.title.text = h.title;
			
			panel.panelList.path.text = h.path;
			panel.panelList.content.htmlText = h.content;
			if(h.path!="") viewToPath(h.path);
		}
		

		
		private function regListeners():void
		{
			
			stage.addEventListener(Event.RESIZE, resizeHandler,false,0,true);
			panel.backBtn.addEventListener(MouseEvent.CLICK,backBtnhandler);
			panel.panelList.modPanoBtn.addEventListener(MouseEvent.CLICK,modPanoBtnhandler);
			panel.panelList.addPBtn.addEventListener(MouseEvent.CLICK,addPBtnhandler);
			panel.panelList.addHBtn.addEventListener(MouseEvent.CLICK,addHBtnhandler);
			panel.panelList.okBtn.addEventListener(MouseEvent.CLICK,okBtnhandler);
			panel.panelList.fnCancelBtn.addEventListener(MouseEvent.CLICK,fnCancelBtnHandler);
			panel.panelList.fnGetPathBtn.addEventListener(MouseEvent.CLICK,fnGetPathBtnHandler);
			panel.fnSaveXMLBtn.addEventListener(MouseEvent.CLICK,fnSaveXMLBtnHandler);
			EIF.addPluginEventListener("render",renderHandler);

		}
		
		private function unregListeners():void
		{
			stage.removeEventListener(Event.RESIZE, resizeHandler);
			panel.backBtn.removeEventListener(MouseEvent.CLICK,backBtnhandler);
			panel.panelList.modPanoBtn.removeEventListener(MouseEvent.CLICK,modPanoBtnhandler);
			panel.panelList.addPBtn.removeEventListener(MouseEvent.CLICK,addPBtnhandler);
			panel.panelList.addHBtn.removeEventListener(MouseEvent.CLICK,addHBtnhandler);
			panel.panelList.okBtn.removeEventListener(MouseEvent.CLICK,okBtnhandler);
			panel.panelList.fnCancelBtn.removeEventListener(MouseEvent.CLICK,fnCancelBtnHandler);
			panel.panelList.fnGetPathBtn.removeEventListener(MouseEvent.CLICK,fnGetPathBtnHandler);
			panel.fnSaveXMLBtn.removeEventListener(MouseEvent.CLICK,fnSaveXMLBtnHandler);

		}
		
		private function updaterot(e){
			trace(  EIF.get("navRot") );
			trace( EIF.get("navRot")() );
		}
		
		private var basePath = "res/photo/pano/";
		private function modPanoBtnhandler(e):void
		{
			trace(EIF.get("setNavDragable"))
			EIF.get("setNavDragable")(true); //设置 nav 可拖动
			
			EIF.get("navToggle")(); // 显示 nav
			
			EIF.get("setNodeDragable")(true) //设置 nav node 可拖动
		}
		
		private function renderHandler(e)
		{ 
			var cur:int = EIF.get("getCurIndex")(); 
			nodes[cur].rotation = EIF.get("getPanoRotY")();
			nodes[cur].position = EIF.get("getManPosition")();
			//trace(EIF.get("getPanoRotY")())
			panel.panelList.panoGrid.editField(cur , "旋转" , EIF.get("getPanoRotY")());
			panel.panelList.panoGrid.editField(cur , "Position" , nodes[cur].position.x+","+nodes[cur].position.y);
			//panel.panelList.panoGrid.createItemEditor(1 , 1);
		}
		
		private function addPBtnhandler(e):void
		{
			var k = new FileReferenceList(); var sl : Array = [];
			k.browse([new FileFilter("Images (*.jpg)", "*.jpg;*.*")])
			k.addEventListener(Event.SELECT, selectHandler);
			function selectHandler(e)
			{
				   // pendingFiles = new Array();
					var file:FileReference;
					for (var i:uint = 0; i < k.fileList.length; i++) {
						if(hasNode(k.fileList[i].name) == false) {trace("add");setNodes([k.fileList[i].name.split(".")[0] , basePath + k.fileList[i].name]);}
					}
					trace(stack.nodes.length);
					reset();
					loadTable();

			}
		}
		
		private function fnSaveXMLBtnHandler(e):void
		{
			trace("SAVE XML ... ");
			trace(saveXML)
			saveXML(true);
		}
		
		private function fnGetPathBtnHandler(e):void
		{
			if(panel.panelList.fnGetPathBtn.label != "完成编辑")
			{
				panel.panelMask.width = panel.panelMask.height = panel.panelList.fnGetPathBtn.width = panel.panelList.fnGetPathBtn.height = 100;
				panel.panelList.fnGetPathBtn.x = 0;panel.panelList.fnGetPathBtn.y = -40;
				panel.panelList.x = 0; panel.fnSaveXMLBtn.visible = false;
				panel.panelList.fnGetPathBtn.label = "完成编辑";
				trace("GG :: ="+panel.panelList.path.text+"=")
				setPath(panel.panelList.path.text);
				setEditer();
			}else
			{
				panel.panelMask.width = 600; panel.panelMask.height = 375;panel.panelList.x = -332;
				panel.panelList.fnGetPathBtn.width = 100; panel.panelList.fnGetPathBtn.height = 22;
				panel.panelList.fnGetPathBtn.x = 780;panel.panelList.fnGetPathBtn.y = 87;
				panel.fnSaveXMLBtn.visible = true;
				panel.panelList.fnGetPathBtn.label = "编辑路径";
				panel.panelList.path.text = getPath();
				setEditer(false);
			}
		}
		
		private function fnCancelBtnHandler(e):void
		{
			if(addMode){
				addMode = false;
				nodes[dgpIndex].overlays.splice(-1,1);
				dgpSelectHandler();
			}
			
			TweenNano.to(panel.panelMask,0.6,{width:300});
		}
		
		private function okBtnhandler(e:MouseEvent):void
		{
			//dph.addItem({"名称":list[i].title, "热点坐标":list[i].path, "详细信息":list[i].content, "添加时间":"2013-02-27"});
			TweenNano.to(panel.panelMask,0.6,{width:300});
			nodes[dgpIndex].overlays[dghIndex].title =  panel.panelList.title.text;
			nodes[dgpIndex].overlays[dghIndex].path =  panel.panelList.path.text;
			nodes[dgpIndex].overlays[dghIndex].content =  panel.panelList.content.htmlText;
			dgpSelectHandler();
		}
		
		private function addHBtnhandler(e:MouseEvent):void
		{
			addMode = true;
			var l = nodes[dgpIndex].overlays.length;
			nodes[dgpIndex].overlays[l] = {type:"polygon",image:""}
			nodes[dgpIndex].overlays[l].title =  "";//panel.panelList.title.text;
			nodes[dgpIndex].overlays[l].path =  ""//panel.panelList.path.text;
			nodes[dgpIndex].overlays[l].content =  ""//panel.panelList.content.htmlText;
			dghIndex = l
			dgpSelectHandler();
			dghSelectHandler();
			TweenNano.to(panel.panelMask,0.6,{width:600});
			
			
		}
		private function backBtnhandler(e:MouseEvent):void
		{
			TweenNano.to(panel.panelList,0.6,{x:panel.panelList.x + 332});
		}
		
		
		
		private function resizeHandler(e):void
		{
			resize();
		}
		
		private function reset():void
		{
			dgpIndex = dghIndex = 0;  addMode = false;
			//nodes = null;
			panel.panelList.title.text = "";
			panel.panelList.path.text = "";
			panel.panelList.content.htmlText = "";
			dpp.removeAll();
			dph.removeAll();
			panel.panelList.panoGrid.removeAllColumns();
			panel.panelList.pathGrid.removeAllColumns();
		
		}
		
		public function resize():void
		{
			var w = this.stage.stageWidth;
			var h = this.stage.stageHeight;
			//tf.x = (550 - w) + 20 ;
			//tf.y = (400 - h) + 20;
		}
		
		
		
		/*
		utils
		*/
		public function hasNode(u:String):Boolean
		{
			//var has:Boolean = false;
			for each(var k in nodes){ trace(k.url +" compare with " + u)
				if(k.url.indexOf(u) != -1 ) return true
			}
			return false;
		}
		
	}
}