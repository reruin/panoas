package pano.extras
{

    import flash.events.*;
    import flash.external.*;
	import pano.core.*;
	import pano.extras.*;
	import pano.controls.ExtraManager;
	import pano.ExtraInterface;
	
    final public class ExternalCom extends EventDispatcher implements IExtra
    {
		public static const VER:Number = 1.1;
		
        private var callbacks:Array;
        public var canUseExternalInterface:Boolean;
        private var _IController:IPano;
		private var EIF:ExtraInterface;
        public function ExternalCom(p,v:Array) : void
        {
			//ExternalInterface.call("alert","ok")
		   	var callbackAssignment:Array;
			_IController = v[0] as IPano;
			
			EIF = ExtraInterface.getInstance();

			EIF.addPluginEventListener("notice_shutdown" , shutdownHandler);
			EIF.addPluginEventListener("notice_streetview_loadinfo" ,loadinfoHandler )
			EIF.addPluginEventListener("notice_switchpano" ,switchpanoHandler )
			
            if (ExternalInterface.available)
            {
          		try
               {
                    callbacks = [];
                 
					callbacks.push(["toUp", toUp]);
					callbacks.push(["toDown", toDown]);
					callbacks.push(["toLeft", toLeft]);
					callbacks.push(["toRight", toRight]);
					callbacks.push(["zoomIn", zoomIn]);
					callbacks.push(["zoomOut", zoomOut]);
					callbacks.push(["zoomTo", zoomTo]);
					
					callbacks.push(["setComID",setComID]);
					callbacks.push(["bind", bind]);
					callbacks.push(["setPanoXML", setPanoXML]);
					callbacks.push(["setPano", setPano]);
					callbacks.push(["bind", bind]);
					//callbacks.push(["test", test]);
					
					/*callbacks.push(["unbind", unbind]);
					callbacks.push(["clearbind", clearbind]);
					*/

                    for(var i:int=0; i<callbacks.length; i++)
                    {
                        callbackAssignment = callbacks[i];
						ExternalInterface.addCallback(callbackAssignment[0], callbackAssignment[1]);
                    }
					
					trace((new Date).toLocaleTimeString()+" : Loading ExternalCom(Ver 1.1) Plugin Success ... ");
					
					canUseExternalInterface = true;
					//ExternalInterface.call("alert", "ok");
                }
                catch (error:Error)
                {
					//ExternalInterface.call("alert", "ExternalCom Error");
					//canUseExternalInterface = false;
					
                }
				
            }
        }
		
		/*
		private function bind(e:String,callbackhandle:String):void { _IController.bind(e,callbackhandle);}
		private function unbind(e:String):void{ _IController.unbind(e); }
		private function clearbind():void{ _IController.clearbind(); }
		
		*/
		private function toUp():void { _IController.toUp();}
		private function toDown():void { _IController.toDown();}
		private function toLeft():void { _IController.toLeft();}
		private function toRight():void { _IController.toRight();}
		private function zoomIn():void { _IController.zoomIn();}
		private function zoomOut():void { _IController.zoomOut();};
		private function zoomTo(v:Boolean = true):void { _IController.zoomTo(v);}
		private function bind(e:String,fn:String):void{ JavaScript.addEventListener(e , fn); }
		private function setComID(v:String):void{ Config.ComID = v; }
		private function setPanoXML(v:String):void{

			if(EIF.get("setPanoXML")) {EIF.get("setPanoXML")(v);}
			else ExternalInterface.call("alert", "Miss EIF OR Error in Function");
		}
		
		private function setPano(v:String):void
		{

			if(EIF.get("setPanoXML")) EIF.get("setPanoXML")(v , true);
		}
		
		private function shutdownHandler(e:*):void
		{
			JavaScript.dispatchEvent("notice_shutdown",Config.ComID, "true");
		}
		
		private function switchpanoHandler(e):void
		{
			JavaScript.dispatchEvent("notice_switch" ,Config.ComID,e.feature.svid ) //, e.svid as String
		}
		
		
		private function loadinfoHandler(e:DataEvent):void
		{
			JavaScript.dispatchEvent("notice_streetviewinfo" , e.data[1] , e.data[2]);
		}
		
		
		//private function test():void{}
		public function resize():void{}
   
	}
}
