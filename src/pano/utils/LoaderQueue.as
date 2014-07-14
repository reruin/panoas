
package pano.utils{

	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	
	public class LoaderQueue extends EventDispatcher {

		public static const COMPLETE : String = "EveryComplete";
		public var target:DisplayObject ;
		public var name:String;
		public var applicationDomain;
		private var _LoadList:Array;
		//private var _loader:Loader;
		private var _state:int;
		private var _autostart:Boolean = true;
		
		public function LoaderQueue(name:String = "" ,autostart:Boolean = true):void
		{
			_autostart = autostart;
			init();//初始化引擎
		}
		
		private function init():void
		{
			_LoadList = new Array();
			//_loader = new Loader();
			_state = 0;
		}
		
		public function get count():int{ return _LoadList.length;}
		
		private function exist(id:String):int {
			
			for (var k in _LoadList)
			{
				if(String(_LoadList[k].id) == id) return k;
			}
			return -1;
			
		}
		
		public function add(url:String,id:String,_override:Boolean = false){
			
			var existIndex:int = exist(id);
			if(existIndex!=-1)
			{
				if(_override)
				{
					_LoadList[existIndex].url = url;
					_LoadList[existIndex].culling = true;
				}
			}
			else
			{
				_LoadList.push({
							   id:id,
							   url:url,
							   culling:true
							   });
			}
			if(_autostart) start();
		}

		public function start():void
		{
			if( _LoadList.length != 0 && _state == 0)  {next(0);
			//trace("Starting... and "+ _LoadList.length + " Tile(s) will be Loaded . ")
			}
		}
		

		public function remove(id:String):void{
			var removeIndex : int = exist(id);
			if(removeIndex > -1)
			{
				delete _LoadList[removeIndex];
				_LoadList.splice(removeIndex,1);
			}
		}
				
		public function clear():void
		{
			target = null; name = null;
			for (var k in _LoadList)
			{
				if(_LoadList[k].culling == true) {
					delete _LoadList[k];
					_LoadList.splice(k,1);
				}
			}
			_state = 0;

		}

		private function next(i:int = 0):void{
			
			if(_LoadList[i] != undefined && _LoadList.length>0 )
			{
				if(_LoadList[i].culling == true) //并未下载
					load(i);
				_state = 1;
			}else{
				dispatchEvent(new Event("AllComplete")); //发送下载完毕事件
				_state = 0;
			}
		}
		
		private function load(index:int):void
		{
			var _loader:Loader = new Loader();
				_loader.name = _LoadList[index].id;
				_LoadList[index].culling = false;
				_loader.load(new URLRequest(_LoadList[index].url));
				//_loadObject.addEventListener(ProgressEvent.PROGRESS, progressHandler);
				_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
				_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				//_LoadList.splice(p,1);
				//trace("load:"+_LoadList[index].url)
		}
		
		private function completeHandler(e:Event)
		{
			name = e.target.loader.name;
			target = e.target.content;
			applicationDomain = e.target.applicationDomain;
			
			dispatchEvent(new Event(COMPLETE)); //发送单个下载事件
			
			_LoadList[exist(name)].culling = true;
			
			e.target.removeEventListener(Event.COMPLETE, completeHandler);
			e.target.loader.unload();
			remove(name);
			next(0);
		}
		
		private function ioErrorHandler(e:IOErrorEvent)
		{
			//如果失败
			trace("IO Error...");
			name = e.target.loader.name;
			_LoadList[exist(name)].culling = true;
			remove(name);
			next(0);
		}
		
		public function getByID(id:String):Bitmap{
			var existIndex:int = exist(id);
			if(existIndex!=-1) return (_LoadList[existIndex].content as Bitmap);
			else return null;
		}
		
	}
}


