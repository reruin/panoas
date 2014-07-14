package pano.events {
	import flash.events.Event;
	public class PanoEvent extends Event {
		public static const SWITCH:String = "switch";
		
		private var _id:String;
		
		public function PanoEvent(type:String,u:String = null,bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type,bubbles, cancelable);
			if(u!=null) _id = u;
		}
		
		public function get id():Object{ return _id; }
	} 
}
