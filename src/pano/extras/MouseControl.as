package pano.extras
{

	import flash.geom.Point;
	import flash.events.MouseEvent;
	import flash.events.EventDispatcher;
	import flash.display.Sprite;
	import flash.events.Event;
	import pano.core.Pano;
	import pano.extras.IExtra;
	import pano.controls.*;
	
	//C + V
	public class MouseControl extends EventDispatcher implements IExtra{
		
		public static const VER:Number = 1.0;
		private var _pano:Pano;
		private var _mouseMove:Boolean = false;
		private var par:EventDispatcher;
		private var active:Boolean = true;
		private var kinetic:Kinetic;
		public function MouseControl(_p:EventDispatcher,v:Array){
			_pano = v[0]; par = _p; init();
		}
		
		private function init():void{
			_offset = new Point();
			kinetic = new Kinetic();
			regListeners();
		}
		
		private function regListeners():void{
			_pano.doubleClickEnabled = true;
			_pano.addEventListener(MouseEvent.MOUSE_WHEEL,mouseWheelHandler,false,0,true);
			_pano.addEventListener(MouseEvent.MOUSE_DOWN,mouseDownHandler);
			//_panoContainer.stage.addEventListener(MouseEvent.MOUSE_OUT,mouseOutHandler);
			
		}
		
		private function unregListeners():void{
			_pano.viewport.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			_pano.viewport.removeEventListener(MouseEvent.MOUSE_WHEEL,mouseWheelHandler);
			
		}
		
		private function mouseWheelHandler(e:MouseEvent)
		{
			if(e.delta > 0)  _pano.zoomIn();
			else _pano.zoomOut();
		}
		
		private var _offset:Point;
		private var _ori:Point;
		private function mouseDownHandler(e:MouseEvent)
		{
			_pano.killTween();
			_pano.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler,false,0,true);
			_pano.stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler,false,0,true);
			_offset = _pano.getMousePosition();
			kinetic.begin();
			var t = _pano.getPov(true);
			_ori = new Point(t.heading , t.pitch);
			_pano.setHand(false);
			//_pano.dispatchEvent(new MapMouseEvent(MapMouseEvent.MOUSE_DOWN,_pano.fromPointToMap(new Point2D(_panoContainer.mouseX,_panoContainer.mouseY)) ));
		}

		
		private function mouseMoveHandler(e:MouseEvent)
		{
			var nowPosition:Point = _pano.getMousePosition();
			var dx:Number = (nowPosition.x - _offset.x) / (_pano.zoom*10);
			var dy:Number = (nowPosition.y - _offset.y) / (_pano.zoom*10);
			
			//_offset = new Point(nowPosition.x,nowPosition.y);
			//_pano.panBy(new Point(dx,dy) , false);
			
			// use sub mode
			_pano.setPov({heading:_ori.x-dx, pitch:_ori.y+dy});
			var t = _pano.getPov(true);
			kinetic.update(new Point(t.heading , t.pitch));
		}
		
		private function mouseUpHandler(e:MouseEvent)
		{
			_pano.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			_pano.stage.removeEventListener(MouseEvent.MOUSE_UP,mouseUpHandler);
			//var p:Point = _pano.getMousePosition();
			
			if(_offset.equals(_pano.getMousePosition()) == false)
			{
				var t = _pano.getPov(true);
				kinetic.end( new Point(t.heading , t.pitch), doKinect);
			}
			
						
			//_pano.dispatchEvent(new MapMoveEvent(MapMoveEvent.MOVE_END,_pano.getCenter()));
			//if(!_mouseMove) _pano.dispatchEvent(new MapMouseEvent(MapMouseEvent.CLICK,_pano.fromPointToMap(new Point2D(_panoContainer.mouseX,_panoContainer.mouseY)) ));
			//_mouseMove = false;
		}
		
		public function doKinect(ix:Number , iy:Number , end:Boolean = false):void
		{
			_pano.setPov({heading : ix%360 , pitch : iy});
			if(end){
				_pano.render(true);
				_pano.setHand(true);
			}
		}
		
		private function mouseClickHandlerFun(e:MouseEvent)
		{
			//_pano.panTo(new Point2D(0,0));
			//_pano.dispatchEvent(new MapMouseEvent(MapMouseEvent.CLICK,_pano.fromPointToMap(new Point2D(_panoContainer.mouseX,_panoContainer.mouseY)) ));
		}
		
		private function mouseDCHandlerFun(e:MouseEvent){
			//_pano.dispatchEvent(new MapMouseEvent(MapMouseEvent.DOUBLE_CLICK,_pano.fromPointToMap(new Point2D(_panoContainer.mouseX,_panoContainer.mouseY)) ));
		}

		public function enable(b:Boolean):void
		{ 
			b ? 
			(!active ? regListeners() : null) : 
			( active ? unregListeners() : null)
			
		}
		
		public function resize():void{}
		
	}
}