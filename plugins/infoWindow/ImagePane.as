
////////////////////////////////////////////////////////////////
//
//ImgSprite 类
//作用：允许导入jpg 或者 swf
//方法: new ImgSprite(url，width，height),Load(url，width，height);
//参数：url，width，height，new中所有参数非必须，Load 中 url 必须，width 和 height 可以指定或者 指定一项，
//这一项将赋予实际width 和 height 中较大的一方，另一方则根据长宽比自动调整。
//
///////////////////////////////////////////////////////////////

package {
		 
	import flash.display.Sprite;
	import flash.display.Loader;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.events.*;
    import flash.net.URLRequest;
	import flash.net.URLVariables;
		
	import flash.filters.BitmapFilter;
    import flash.filters.BitmapFilterQuality;
    import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
		
	public class ImagePane extends Sprite {
		
		//private var maxWidth:int = this.width||29;
		//private var maxHeight:int = this.height||29;
		private var _url:String;
		private var _width:Number = 1;
		private var _height:Number = 1;
		private var _content:Bitmap;
		
		private var _oriwidth:Number = 1;
		private var _oriheight:Number = 1;
		
		public function ImagePane(u:String = "",w:Number = 1,h:Number = 1):void
		{
			_width = w; _height = h ; _url = u;
			if(u!="") load(u);
		}


		private function eventInit(e:Event)
		{
			_content = e.target.content;
			_content.smoothing = true;
			_oriwidth = _content.width ;
			_oriheight = _content.height;
			addChild(_content);
			render()
		}
		
		private function eventError(e:Event){
			trace("error")
		}
		
		private function eventComplete(e:Event):void{

			e.target.removeEventListener(Event.INIT,eventInit);
			e.target.removeEventListener(IOErrorEvent.IO_ERROR, eventError);
			e.target.removeEventListener(Event.COMPLETE,eventComplete);
		}
		
		public function load(u:String):void
		{
			if(_content) this.removeChild(_content);
			_url = u;
			var picLoader:Loader = new Loader();
			picLoader.load(new URLRequest(_url));
				//var param:Object = picLoader.loaderInfo.parameters;
			picLoader.contentLoaderInfo.addEventListener(Event.INIT,eventInit);
			picLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, eventError);
			picLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,eventComplete);
		}
		
		override public function set width(v:Number):void
		{
			_width = v; render()
		}
		
		override public function set height(v:Number):void
		{
			_height = v;render()
		}
		
		override public function get height():Number{return _height;}
		
		override public function get width():Number{return _width;}
		
		public function destroy():void
		{
			
		}
		
		private function render():void
		{
			var r:Number = Math.min(_width / _oriwidth,_height /_oriheight);
			if(r>1) r= 1;
			trace("set scale : "+ r)
			if(_content)
			{
			_content.width = _oriwidth*r;
			_content.height = _oriheight*r;
			_content.x = 0.5*(_width - _content.width)
			_content.y = 0.5*(_height - _content.height)
			
			}
		}
		

 		
	}
}


