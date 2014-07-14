package pano.events {
	import flash.events.Event;
	import flash.geom.Point;
	
	public class NoticeEvent extends Event {
		public static const SWITCH:String = "switch";
		
		private var _feature:Object;
		private var _position:Point;
		public function NoticeEvent(type:String,f:Object = null,p:Point = null,bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type,bubbles, cancelable);
			if(f!=null) _feature = f;
			if(p!=null) _position = p;
		}
		
		public function get feature():Object{ return _feature; }
		
		public function get position():Point{ return _position; }
	} 
}
