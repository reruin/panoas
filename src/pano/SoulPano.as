package  pano{
	
	import flash.system.Security;
	import flash.display.*;
	import flash.events.*;
	import pano.events.*;
	import pano.core.*;
	import pano.utils.*;
	import pano.controls.*
	import pano.extras.*
	
	public class SoulPano extends Sprite{
		
		public static var NAME     :String = 'SoulPano';

		public static var VERSION  :String = '1.0.1';
	
		public static var DATE     :String = 'March 6th, 2014';

		public static var AUTHOR   :String = '(c) 2010-2014 Copyright by SOULLAB';
		
		private var _pano:Pano;
		
		private var EM:ExtraManager;
				
		public function SoulPano()
		{
			Security.allowDomain("*");
			stage.scaleMode = StageScaleMode.NO_SCALE
			stage.quality = "HIGH";
			Stack.init();
			var cfg:Config = new Config(loaderInfo.parameters);
			cfg.addEventListener("config_complete",configCompleteHandler);
			Config["url"] = String(loaderInfo.url);
			Config.init();
		}
		

		private function configCompleteHandler(e):void
		{
			new Logger(this.stage,Config.debug);
			Logger.trace(1,"Loaded Config Finished.");
			start();
		}


		private function start():void
		{

			//addChild(new Stats());return;
			_pano = new Pano();
			
			this.addChild(_pano);
			
			EM = new ExtraManager(_pano , this); 
			
			//load core plugins
			EM.activate([MouseControl,TipsBox,ExternalCom,Overlay,MouseTips,StreetView]);
			
			if(!Config.LockKeyBoard) EM.activate(KeyboardManager);
			
			if(Stack.plugins.length)
			{
				for(var i in Stack.plugins)
				{
					Logger.trace(1,"load plugins - "+Stack.plugins[i].path)
					EM.activate(Stack.plugins[i].path);
				}
				
			}
			else
				EM.finish();
						
			Config.pluginsReady = true;
			
			//if(Stack.face) EM.call("panTo",Stack.face);
			
			regListeners();
			resize();

		}	
		
		private function regListeners():void
		{
			stage.addEventListener(Event.RESIZE, resize,false,0,true);
			EM.addEventListener(ExtraInterface.PLUGINEVENT_REGISTER ,allLoaded )
			_pano.addEventListener("render",render);
		}
		
		private function render(e:*):void
		{
			
			EM.resize();
			EM.dispatchEvent(new Event("render"));
			JavaScript.dispatchEvent("notice_povchange" , Config.ComID , String(_pano.getHeading()))
		}
		
		private function allLoaded(e:NoticeEvent):void
		{
			JavaScript.dispatchEvent("notice_loaded",Config.ComID);
		}
		
		private function resize(e:Event = null):void
		{
			_pano.render();
		}

	}
	
}
