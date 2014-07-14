package {
	
	import flash.display.*;
	import flash.events.*;
	import flash.ui.Mouse;
	import flash.geom.*;

	import pano.utils.TweenNano;

	import pano.extra.ExtraInterface;
	
	public class MouseSprite extends Sprite
	{

		private var EIF:ExtraInterface;
		private var tar:Bitmap;
		private var _cursors:cursors;
		private var _layer:Sprite;
		public function MouseSprite(){
			
			if (stage == null)
			{
				this.addEventListener(Event.ADDED_TO_STAGE, this.startPlugin);
				this.addEventListener(Event.REMOVED_FROM_STAGE, this.stopPlugin);
			}else
			{
				startPlugin()
			}
		}
		
		private function startPlugin(e:Event = null):void
		{
			trace((new Date).toLocaleTimeString()+" : Loading MouseSprite Plugin ... ");
			
			stage.showDefaultContextMenu = false;
			EIF = ExtraInterface.getInstance();
			if(EIF.ready) 
			{
				EIF.addPluginEventListener(ExtraInterface.PLUGINEVENT_REGISTER, this.registerEvent);
			}
			//init();
			this.removeEventListener(Event.ADDED_TO_STAGE, this.startPlugin);
		}
		
		private function stopPlugin(e):void
		{
			unregListeners();
			
			EIF.removePluginEventListener(ExtraInterface.PLUGINEVENT_REGISTER, this.registerEvent);
			
			trace((new Date).toLocaleTimeString()+" : UnLoad [MouseSprite] Plugin Success ! ");
				
		}
		
		private function registerEvent(e = null)
		{
			_layer = EIF.get("viewport")();
			init();
		}
		
		var cursorList:Array = [];
		private function init():void
		{
			_cursors = new cursors();  //addChild( new Bitmap(_cursors));
			for(var i:int = 0; i<(_cursors.width / 16) ; i++)
			{
				//cursorList.push( (new BitmapData(160,16,true)).draw(_cursors,null,null,null, new Rectangle(i*16 , 0 ,16,16), true));
				var t:BitmapData = new BitmapData(16,16,true,0);
				t.draw(_cursors,new Matrix(1,0,0,1,-16*i,0),null,null, new Rectangle( 0, 0 ,16,16), true)
				cursorList.push(t);
			}
			
			Mouse.hide();
			tar = new Bitmap(cursorList[0]);
			
			addChild(tar);
			this.startDrag(true);
			regListeners();
		}
		
		
		private function update():void
		{
			
		}
		
		private function regListeners():void
		{
			//_layer.graphics.beginFill(0xFFCC00,0.7);
			//_layer.graphics.drawRect(0,0,stage.stageWidth , stage.stageHeight);

			_layer.addEventListener(MouseEvent.MOUSE_MOVE,mouseMoveHandler,false,0,true);
			_layer.addEventListener(MouseEvent.MOUSE_OUT,mouseOutHandler,false,0,true);
			_layer.addEventListener(MouseEvent.MOUSE_OVER,mouseOverHandler,false,0,true);
			this.stage.addEventListener(MouseEvent.MOUSE_DOWN,mouseDownHandler,false,0,true);
		}
		
		
		private function unregListeners():void
		{
			this.removeEventListener(MouseEvent.MOUSE_DOWN,mouseDownHandler);
			_layer.removeEventListener(MouseEvent.MOUSE_MOVE,mouseMoveHandler);
		}
		
		private var curPoint : Point = new Point();
		private var hasDown : Boolean = false;
		private function mouseDownHandler(e:MouseEvent):void
		{
			curPoint.x = stage.mouseX ; curPoint.y = stage.mouseY; hasDown = true;
			
			this.stage.addEventListener(MouseEvent.MOUSE_UP,mouseUpHandler,false,0,true);
			
			setCur("down");

		}
		
		private var speed : Point = new Point();
		private function mouseMoveHandler(e:MouseEvent):void
		{
			if(hasDown)
			{
			//Math.atan2(_man.mouseY , _man.mouseX)*180/Math.PI ,true
			
				speed.x = 0 - (stage.mouseX - curPoint.x)*2 / stage.stageWidth;
				speed.y = 0 - (stage.mouseY - curPoint.y)*2 / stage.stageHeight;
				//trace(speed)
				EIF.get("killpanoanimat")();
				EIF.get("setPano")("rotate" , speed);
				
				setCur( Math.atan2(stage.mouseY - curPoint.y, stage.mouseX - curPoint.x)*180/Math.PI );
				
			}
			//this.x = this.stage.mouseX ; this.y = this.stage.mouseY;
		}
		
		private function mouseOutHandler(e:MouseEvent):void
		{
			//trace(e.currentTarget)
			Mouse.show(); tar.visible = false;
		}
		
		private function mouseOverHandler(e:MouseEvent):void
		{
			Mouse.hide(); tar.visible = true;
		}
		
		private function mouseUpHandler(e:MouseEvent):void
		{
			setCur("up")
			hasDown = false;
			EIF.get("killpanoanimat")();

			this.stage.removeEventListener(MouseEvent.MOUSE_UP,mouseUpHandler);
		}
		
		private function setCur(v):void
		{
			var index : int = 0;
			if(v is Number)
			{
				if(v>=-90) v = 90 + v;
				else v = 360 + 90 + v;
				
				//v = v - 22.5;
				
				v = Math.round( v / 45 );
				if(v==8) v = 0
				// 2 - 9; 0--> 2  
				index = v + 2;
			}
			if(v is String)
			{
				switch(v)
				{
					case "down" : 
						index = 1;break;
					case "up" :
						index = 0;break;
					default : 
						break;
				}
			}
			
			tar.bitmapData = cursorList[index];
			
		}
		
	}
}



	import flash.display.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.filters.GlowFilter;
	
	import pano.utils.TweenNano;
	
	internal class Cursor extends Bitmap
	{
		public var position:Point = new Point();
		
		public function Cursor(){
			//this.graphics.lineStyle(1,0x985122,0.6);
			
			draw();
			
		}
		
		private function draw():void{
			
		}
		
	}
