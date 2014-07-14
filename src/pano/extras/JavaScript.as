package pano.extras{
	
    import flash.external.*;
	//import flash.utils.Dictionary;
	
	final public class JavaScript{
		private static var all:Object = new Object();

		public static function addEventListener(e:String,callbackHandle:String){
			all[e] = callbackHandle;//if(all[e]==undefined)
			//call("alert","reg : "+e+"/"+callbackHandle+" is ok")
		}
		
 		public static function dispatchEvent(e:String,param1:String = "", param2 = null, param3 = null)
		{
			//trace("dispatchEvent JavaScript : "+ e + " / "+all[e]);
			//call("alert",e+ " / "+all[e]+" is ok")
			if(all[e]!= undefined){
				
				call(all[e],param1,param2,param3);
				//delete all[e];
			}/*else
				call("alert","异常：浏览器可能未注册该事件！");*/
			
		}
		
		public static function removeEventListener(e:String){
			if(all[e]!=undefined) delete all[e];
		}
		
		public static function clearEventListener():void{
			for(var e in all) delete all[e];
			all = new Object();
		}
		
		public static function call(callbackName:String,param1:String = "", param2 = null, param3 = null)
        {
            
			trace("callbackName is :" + callbackName+", Para is :" + param1);
			if(!ExternalInterface.available) trace("ExternalInterface NOT Ready")
			
			try{
			if (callbackName)
            {
                if (param2)
                {
                    if (param3) ExternalInterface.call(callbackName, param1, param2, param3);
                    else ExternalInterface.call(callbackName, param1, param2);
                }
                else
                {
                    ExternalInterface.call(callbackName, param1);
                }
            }
			}catch(e)
			{
				if(e) trace("JS does NOT ready!")
			}
        }

		public static function alert(v:String):void { call("alert",v);} 
		
		public static function getVar(jvar:String):Object
		{
			var funcName:String = "getJsVarByName" + jvar + new Date().getTime();
			ExternalInterface.call("eval", "function" + funcName + "(){return " + jvar +";}");
			return ExternalInterface.call(funcName);
		}
		
	}
}