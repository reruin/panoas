package pano.extras
{
    import flash.display.Sprite;
    import flash.display.Stage;
	import flash.system.Security;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.ui.ContextMenu;
    import flash.ui.ContextMenuItem;
    import flash.ui.ContextMenuBuiltInItems;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import pano.core.Pano;
	import pano.events.*;
	import pano.controls.*;
	import pano.ExtraInterface;
	import flash.utils.*
	
    final public class CustomContextMenu extends EventDispatcher implements IExtra
    {
        public static const VER:Number = 1.1;
		private var _list:Dictionary = new Dictionary();
		private var _helpMenuItem:ContextMenuItem;
        private var _fullScreenMenuItem:ContextMenuItem;
		private var _3dmode:ContextMenuItem;
		private var _contextMenu:ContextMenu;
		
		public var EIF:ExtraInterface;
		private var container:Sprite;  
		private var _counter:int = 0;

        public function CustomContextMenu(p,v:Array) : void
        {
			EIF = ExtraInterface.getInstance();
			container = EIF.get("viewport");
			_contextMenu = new ContextMenu();
			_contextMenu.hideBuiltInItems();
			
            container.contextMenu = _contextMenu;

		    startPlugin();
        }
		private function startPlugin(e:Event = null):void
		{
			trace((new Date).toLocaleTimeString()+" : Loading CustomContextMenu(Core Ver 1.1) Plugin ... ");
			EIF = ExtraInterface.getInstance();
			if(EIF.ready) 
			{
				EIF.set("CustomContextMenu",add);
				EIF.addPluginEventListener(ExtraInterface.PLUGINEVENT_REGISTER, this.registerEvent);
			}
		}
		
		private function registerEvent(e:* = null):void
		{
			
			var b:String = EIF.call("getGlobalConfig" , "custom_context_menu");
			if(b=="" || b==null) b = "";
			parse(b);
		}
		
		private function parse(v:String):void
		{
			var xml:XML = new XML(v);
			var separator:Boolean = false;
			for(var i:int = 0 , l=xml.item.length() ;i<l ; i++)
			{
				if(xml.item[i].toString() == "-")
					separator = true;
				else
				{
					add(xml.item[i].toString() , null ,separator);
					separator = false;
				}
			}
			xml = null;
		}
		
		public function add(v:String , fn:Function = null, sp:Boolean = false , enable:Boolean = true):void
		{
			
			var t:ContextMenuItem = new ContextMenuItem(v,sp,enable);
			_list[t] = fn;
			_contextMenu.customItems.push(t);
			t.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,menuHandler,false,0,true);
		}
		
		private function menuHandler(e:ContextMenuEvent):void
		{
			_list[e.currentTarget].call(this,e.currentTarget);
		}
		
		public function resize():void{}

    }
}

