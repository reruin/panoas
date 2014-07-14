
package pano.utils{

	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	import org.tiny.utils.*;
	public class ImageLoader extends EventDispatcher {

		public static const COMPLETE : String = "oneComplete";
		public var bitmap:Bitmap;
		public var name:String;
		
		private var _contents : Dictionary = new Dictionary(true);
		private var _WaitLoadList:Array = [];
		private var _LoaderQueue :Array = [];//下载队列 Controller
		private var _CurrentQueueIndex:int = 0;
		private var _thread:int;
		private var _delay:int;
		private var _state:int;
		
		public function ImageLoader(u:String = "", ProgressCallback,CompleteCallback,d:int = 0):void
		{
			var imgLoader:Loader = new Loader();
			WaitCtrl.add(750,function(){
				if(!HaveLoad)
					{
						TipsBox.ShowHide(true);
						imgLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,loadProgressHandler,false,0,true);  
					}
					HaveLoad = false;
			},"loadPro");
			imgLoader.load(new URLRequest(u)); 
			imgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,loadCompleteHandler,false,0,true); 
		}
		
		private function loadProgressHandler(e:ProgressEvent)
		{
				trace("----------------->Loading "+Math.round(100 * e.bytesLoaded / e.bytesTotal) + "%");
				TipsBox.show("Loading ... "+Math.round(100 * e.bytesLoaded / e.bytesTotal) + "%");
		}
		
		private function loadCompleteHandler(e:Event){
			WaitCtrl.remove("loadPro");
			HaveLoad = true;
			TipsBox.ShowHide(false);

			var nW = (e.target.content as Bitmap).width;
			var nH = (e.target.content as Bitmap).height;
			//_sphere.material.bitmap.draw(e.target.content as Bitmap,new Matrix(5120/nW,0,0,2560/nH,0,0),null,null,null,true);
			_ObjectContainer.mat = (e.target.content as Bitmap)
			BitmapMaterialTools.mirrorBitmapX(_ObjectContainer.mat);
			
			if(config.mode3D) panoControl("mode3D",true);
			(e.target.content as Bitmap).bitmapData.dispose();
			e.target.removeEventListener (Event.COMPLETE,loadCompleteHandler);
			e.target.removeEventListener (ProgressEvent.PROGRESS,loadProgressHandler); 
			renderOnce();
			Buff();
		}
		
		
	}
}