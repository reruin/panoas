package air.utils{
	import flash.events.Event;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	public class LoaderQueueEvent extends Event
	{
		public var name:String;
		public var bitmap:Bitmap;
		public static const COMPLETE : String = "EveryComplete";
		public function LoaderQueueEvent(type:String,_name:String,_bmd:BitmapData,bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type,bubbles, cancelable);
			name = _name;
			bitmap = new Bitmap(_bmd,"auto",true);
		}
	}
}
