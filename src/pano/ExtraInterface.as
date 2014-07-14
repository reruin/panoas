package pano
{
    import pano.utils.Logger;
	public class ExtraInterface extends Object
    {
        public var set:Function = null;
        public var get:Function = null;
        public var call:Function = null;
        public var addPluginEventListener:Function = null;
        public var removePluginEventListener:Function = null;
		public var dispatchEvent:Function = null;
        public var ready:Boolean = false;
        public static var instance:ExtraInterface = null;
        public static const STARTDEBUGMODE:int = 255;
        public static const DEBUG:int = 0;
        public static const INFO:int = 1;
        public static const WARNING:int = 2;
        public static const ERROR:int = 3;
        public static const PLUGINEVENT_REGISTER:String = "registerplugin";
        public static const PLUGINEVENT_RESIZE:String = "resizeplugin";
        public static const PLUGINEVENT_UPDATE:String = "updateplugin";

        public function ExtraInterface()
        {
            
        }
		
		public function warn(v):void
		{
			Logger.trace(2,v);
		}
		
		public function trace(v):void
		{
			Logger.trace(1,v);
		}
		
        public static function getInstance() : ExtraInterface
        {
            if (instance == null)
            {
                instance = new ExtraInterface();
            }
            return instance;
        }

    }
}
