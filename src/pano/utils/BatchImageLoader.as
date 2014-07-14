
package pano.core.utils{

	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	public class BatchImageLoader extends EventDispatcher {

		public static const COMPLETE : String = "oneComplete";
		public var bitmap:Bitmap;
		public var name:String;
		
		private var _contents : Dictionary = new Dictionary(true);
		private var _WaitLoadList:Array = [];
		private var _LoaderQueue :Array = [];//下载队列 Controller
		private var _CurrentQueueIndex:int = 0;
		private var _thread:int;
		private var _retryTime:int;
		private var _state:int;
		
		public function BatchImageLoader(name:String,_t:int = 1, _r:int = 0 ):void
		{
			_thread = _t;
			_retryTime = _r;
			InitLoaderQueue();//初始化引擎队列
		}
		
		private function InitLoaderQueue():void
		{
			for( var i:int = 0; i < _thread; i++ )
				_LoaderQueue[i] = {loader:new Loader(),free:true}
		}
		
		public function add(url:String,id:String,_culling:Boolean = false){
			
			
			if(_contents[id] == undefined) 
				_contents[id] = new Dictionary(true);

			if( _contents[id].url== undefined || _contents[id].url != url) //new Dictionary 时 url = undefined
			{
				_contents[id].url = url;
				_contents[id].isLoad = false;
				_contents[id].culling = _culling;
				_contents[id].content = null;
				_contents[id].retryTime = 0;
				_contents[id].LoaderQueueIndex = 0;
				if(!_culling)
					_WaitLoadList.push(id);
			}
		}

		public function start()
		{
			if( _WaitLoadList.length != 0 )
				for(var i = 0 ; i< _thread; i++) next(0);
			//并发数量 _thread 项
		}
		
		private function next(i:int = 0){
			if(_WaitLoadList[i] != undefined && _WaitLoadList.length>0 )
			{
				if(!_contents[_WaitLoadList[i]].culling && _contents[_WaitLoadList[i]].retryTime<=_retryTime ){ //如果不是剔除的项目 且重试次数小于要求
					load(getFreeLoaderFromQueue(),i);//从下载队列中 获得 空闲的通道进行下载
				}else{
					_WaitLoadList.splice(i,1);
					next();
				}
				_state = 1;
			}else{
				_state = 0;
			}
		}
		
		private function getFreeLoaderFromQueue():int
		{
			for( var i:int = 0; i < _LoaderQueue.length; i++ ){
				if(_LoaderQueue[i].free) 
				{
					_LoaderQueue[i].free = false;
					return i;
				}
			}
			return -1;
		}
		
		public function remove(id:String){
			var removeIndex : int = _WaitLoadList.indexOf(id) ;
			if(removeIndex > -1)
               _WaitLoadList.splice(removeIndex,1);
			_contents[id] = null;
			delete _contents[id];
		}
				
		public function removeAll()
		{
			_contents = new Dictionary(true);
			_WaitLoadList = [];
		
		}

		public function pauseAll()
		{	
			for (var key:String in _contents)
			{
				_contents[key].culling = true;
			}
			 _WaitLoadList = [];//清空等待 和 正在 下载队列
			_state=0;
		}
		
		public function startByName(id:String)
		{
			if(_contents[id] != undefined) 
			{
				if(!_contents[id].culling)
				{
					//未被剔除，则一定在 _WaitLoadList 内，等待自然下载
					/*if(!_contents[id].isLoad) //如果没有下载完毕
					if(_WaitLoadList.indexOf(id)!=-1) //若存在于 等待列表中，即未load()
					_WaitLoadList.unshift(id);
					*/
					
				}
				else//被剔除，则添加，并修改剔除属性
				{
					_contents[id].culling = false;
					_WaitLoadList.unshift(id);
				}
				if(_state==0) start();
			}
		}
		
		//该操作对已经 load 完毕的项目 无效。所有load 完毕的项目的 culling 属性为 true，除非对 id 重新 add 操作
		public function pauseByName(id:String)
		{
			if(_contents[id] != undefined) 
			{
				if(!_contents[id].culling) //若未被剔除
				{
					_contents[id].culling = true;
					//其中 loadInit  loadComplete 之间 _WaitLoadList.indexOf(id) = -1.但 culling = false
					if( _WaitLoadList.indexOf(id) == -1 )
						_WaitLoadList.splice(_WaitLoadList.indexOf(id),1);
					//else 已经在 loading 当中了，因为设置了culling，所以即使 loading error 也不会被 next
				}
				//else 已被剔除，不做操作
			}
		}
		


		
		private function load(l,p)
		{
				if(l==-1) return;
				_contents[_WaitLoadList[p]].LoaderQueueIndex = l;//记录队列通道号
				_LoaderQueue[l].loader.name = _WaitLoadList[p];
				_LoaderQueue[l].loader.load(new URLRequest(_contents[_WaitLoadList[p]].url));
				//_loadObject.addEventListener(ProgressEvent.PROGRESS, progressHandler);
				_LoaderQueue[l].loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
				_LoaderQueue[l].loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				//_loadObject.addEventListener(Event.OPEN, openHandler);
				_WaitLoadList.splice(p,1);
		}
		
		private function completeHandler(e:Event)
		{
			name = e.target.loader.name;
			_contents[name].content = bitmap = e.target.content as Bitmap;
			_contents[name].isLoad = true;
			_contents[name].culling = true;
			_LoaderQueue[_contents[name].LoaderQueueIndex].free = true;//释放 下载通道
			
			e.target.removeEventListener(Event.COMPLETE, completeHandler)
			dispatchEvent(new Event("EveryComplete")); //发送单个下载事件
			next(0);
		}
		
		private function ioErrorHandler(e:IOErrorEvent)
		{
			_LoaderQueue[_contents[name].LoaderQueueIndex].free = true;//释放 下载通道
			//如果失败，将其追加回等待下载列表的首项，并修改其 重试次数
			_WaitLoadList.unshift(e.target.loader.name);
			//_contents[_WaitLoadList[_WaitLoadList.indexOf(e.target.loader.name)]].retryTime++;
			_contents[_WaitLoadList[0]].retryTime++;
			next(0);
		}
		
	}
}