package  {

	import pano.ui.Panel
	import flash.display.*;
	import flash.events.*;
    import flash.net.*;
	import flash.utils.ByteArray;
	
	public class UILoader extends Panel{
		
		private var _source:String;
		private var _Loader:Loader;
		public var id:String;
		public function UILoader(w:Number , h:Number ,url:String , t:String = "", scaleContent:Boolean = true) {
			_source = url ;
			super(w , h ,t)
			// constructor code
		}
		
		override protected function addChildren():void
		{
			
			_headHeight = 18;
			_headTitleColor = 0x121212;
			_headTitleSize = 11;
			_headPosition = 4;
			floatHead = false;
			super.addChildren();
			load();
			
		}
		
		public function load():void
		{
			_Loader = new Loader();
			_Loader.load(new URLRequest(_source)); 
			_Loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,loadProgressHandler,false,0,true);  
			_Loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loadCompleteHandler,false,0,true); 
		}
		
		private function loadProgressHandler(e:ProgressEvent)
		{
			trace("Loading ... "+Math.round(100 * e.bytesLoaded / e.bytesTotal) + "%");
			//_ext.dispatchEvent(new NoticeEvent("loadingmap",(Math.round(100 * e.bytesLoaded / e.bytesTotal) + "%")));
		}
		private var flag:Boolean = false;
		private var byteData:ByteArray = new ByteArray();
		private function loadCompleteHandler(e:Event)
		{
			
			try{
 				if(_Loader.content){
				 	var  bitmapData = (_Loader.content as Bitmap).bitmapData.clone();
				 	(_Loader.content as Bitmap).bitmapData.dispose();
					unload();
				 	completeFn(bitmapData)
				 }
				
             }catch (e)
             {
				
				if(flag)
				{
				 	var bitmapData = new BitmapData(_Loader.content.width,_Loader.content.height);
				  	bitmapData.draw(_Loader.content,null,null,null,null,true);
					flag = false;
					byteData.clear();unload();
					completeFn(bitmapData)
				 }else{
					  byteData = _Loader.contentLoaderInfo.bytes;
					  _Loader.unloadAndStop(true);
					  _Loader.loadBytes(byteData);
					  flag = true;
				 }  
             } 
			 
		}
		
		private function unload():void
		{
			_Loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS,loadProgressHandler);  
			_Loader.unloadAndStop(true);
		}
		
		private function completeFn(bmd)
		{
			//if(scaleContent) bmd = bmd.draw
			setContent(new Bitmap(bmd));
			width = content.width; 
			height = content.height;
			
		}

	}
	
}
