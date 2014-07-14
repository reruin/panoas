package pano.object{
	
	import flash.geom.*;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.*;
	import pano.core.Stack;
	import pano.events.NoticeEvent;
	import pano.ExtraInterface;
	import pano.utils.Geometry;
	
	public class Arrow3D extends Sprite
	{
		
		private static const DOWN:int = 2;
        private static const OVER:int = 1;
        private static const UP:int = 0;
        private var sZ = new Sprite();
        private var list : Array = [];
        private var EIF: ExtraInterface;
		private var ground:Sprite = new Sprite();
		private var hand:Sprite = new Sprite();
		private var useGround:Boolean = false;
		private var data:Array = [];
		private var useFoot:Boolean = false;
		public function Arrow3D(_useGround:Boolean = false)
		{
			useGround = _useGround;
			
			if(useGround)
			{
				ground = new Sprite();
				hand = new Sprite();
				addChild(ground);
				ground.addChild(hand);
				ground.z = -200;
				creathand();
				ground.rotationY = 180;
				ground.rotationX = 180;
			}


			addChild(sZ);
			regListeners();

			EIF = ExtraInterface.getInstance();
		}
	
		public function setArrows(v:Array):void
		{
			clear();
			data = v;
			for(var i:int = 0;i<v.length;i++)
			{
				var k = new Arrow(v[i]);
				list.push( k );
				sZ.addChild(k);
			}
		}
		
		private function clear():void
		{
			data = [];
			for(var i:int = 0;i<list.length;i++) sZ.removeChild(list[i]);
			list = [];
		}
		
		private function creathand():void
		{
			/*ground.graphics.beginFill(0xff0000,0.5);
			ground.graphics.drawRect(-400,-400,800,800);
			ground.graphics.endFill();*/
			hand.graphics.beginFill(0xffffff,0.5);
			hand.graphics.drawCircle(0,0,100);
			hand.graphics.endFill();
		}
		
		private var rotx:Number = 0;
		public function rotateX(v:Number)
		{
			rotx = v;
			if(v>120){
				this.rotationX = v;
			}
			else if(v<=120 )
			{
				this.rotationX = 120; 
				
			}
			resize()
			
			
		}
		
		private var roty:Number = 0;
		public function rotateY(v:Number)
		{
			roty = v;
			sZ.rotationZ = 0-v;
			if(useGround) ground.rotationZ = 0-v;
		}
		
		public function rotateZ(v:Number)
		{
			sZ.rotationZ = 0-v;
			//shadow.rotationZ = arrow.rotationZ = v;
		}
		
		private function regListeners():void
		{
			addEventListener(MouseEvent.MOUSE_OVER, handleRollOver, false, 0, true);
            addEventListener(MouseEvent.MOUSE_OUT, handleRollOut, false, 0, true);
            addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown, false, 0, true);
            addEventListener(MouseEvent.MOUSE_UP, handleMouseUp, false, 0, true);
			addEventListener(MouseEvent.CLICK , handleMouseClick , false , 0 , true);
			
            this.addEventListener(Event.ADDED_TO_STAGE, this.startPlugin);
           
		}
		
		private function startPlugin(e):void
		{
			stage.addEventListener(Event.RESIZE, resize,false,0,true);
			if(useGround)
			{
				stage.addEventListener(MouseEvent.MOUSE_DOWN , handleStageMD , false , 0 , true);
				stage.addEventListener(MouseEvent.MOUSE_UP , handleStageMU , false , 0 , true);
				stage.addEventListener(MouseEvent.MOUSE_MOVE , handleMouseMove , false , 0 , true);
			}
			resize();
		}
		
		private var isdown:Boolean = false;
		private var ishover:Boolean = false;
		private function handleStageMD(e):void
		{
			isdown = true;
			hand.visible = false;
		}
		
		private function handleStageMU(e):void
		{
			isdown = false;
		}
		
		private function handleMouseMove(event:MouseEvent):void
		{
			if(!isdown && !ishover && disableHand == false)
			{
				hand.visible = true;
				var r:Number = Geometry.azimuth(new Point(ground.mouseX,ground.mouseY))// - t;
				var d:Number = Point.distance(new Point(ground.mouseX,ground.mouseY),new Point(0,0));
				
				
				var cid:int = check(r);
				if(cid==-1 || d<500 || d>3000){
					hand.visible = false;
				}else
				{
					hand.visible = true;
					hand.x = ground.mouseX ; hand.y = ground.mouseY;
				}
			}
		}
		
		public var disableHand : Boolean = false;
		public function setHand(v:Boolean):void{
			if(this.useGround) disableHand = !v;
			//hand.visible = v;
		}
		
		private function handleMouseClick(event:MouseEvent):void
		{
			EIF.dispatchEvent(new NoticeEvent("switch",event.target.ident));
		}
		
		private function handleRollOver(event:MouseEvent) : void
        {
            setStateAndDraw(event.target,OVER);
        }

        private function handleRollOut(event:MouseEvent) : void
        {
            setStateAndDraw(event.target,UP);
        }

        private function handleMouseUp(event:MouseEvent) : void
        {
            setStateAndDraw(event.target,OVER);
        }

		private function check(r:Number):int
		{
			for(var i:int = 0 ; i<data.length ; i++)
			{
				if(Math.abs(data[i].rot - r)<25) return i;
			}
			return -1;
		}
		
		private function redraw():void
		{
			
		}
		
        private function handleMouseDown(event:MouseEvent) : void
        {
            //event.stopImmediatePropagation();
            setStateAndDraw(event.target,DOWN);
        }
		
		public function setStateAndDraw(target,v)
		{
           
			if(target is Arrow)
			{
            	target.graphics.clear();
				switch(v)
				{
					case DOWN:
					case OVER:
					{
					   target.hover(true);hand.visible = false;ishover = true;
					   break;
					}
					case UP:
					default:
					{
					   target.hover(false);hand.visible = false; ishover = false;
					   break;
					}

				}
			}
		}
		
		public function destroy():void
		{
			//removeChild(shadow);
		}
		

		
		public function set ident(v:String):void {  this.name = v; }
		
		public function get ident():String{ return this.name; }
		
		
		public function resize(e:* = null):void
		{
			
			
			var viewportWidth = this.stage.stageWidth;
			var viewportHeight = this.stage.stageHeight;
			

			this.x = (viewportWidth)*0.5;
			this.y = (viewportHeight)*0.5;
			
			if(rotx>=120 && rotx<=180)
			{
				this.y = viewportHeight*0.5 - 50*(180-rotx)/60
			}
			else if(rotx<120)
			{
				this.y = (viewportHeight*0.5 - 50) +  (viewportHeight*0.5 + 50)*(120 - rotx)/40 ;
			}
			var p = new PerspectiveProjection()
			p.projectionCenter = new Point(this.x,this.y)
			this.transform.perspectiveProjection = p;
			

		}

	}
}

	import flash.display.*
	import pano.core.Stack;
	import pano.core.Config;
	import flash.filters.GlowFilter;

	internal class Arrow extends Sprite
    {
		public static var arrowBMD:BitmapData = Stack.arrowBMD;
		public static var arrowShadowBMD:BitmapData = Stack.arrowShadowBMD;
		public static var arrowHoverBMD:BitmapData = Stack.arrowHoverBMD;
		
		public var data:Object;
		public var ident:String;
		private var shadow:Bitmap;
		private var arrow:Bitmap;
		private var direction:Number;
		
		public function Arrow(a:Object)
        {
			
			ident = a.id ; direction = a.rot; 
			direction = (direction)%360;
			init();  this.buttonMode = true; this.scaleX = this.scaleY = Config["arrow_scale"] || 1;
		}
		
		private function init():void{
			this.filters = [new GlowFilter(0x52a8ec,0,16,16,1)];
			
			
			shadow = new Bitmap(Arrow.arrowShadowBMD,"auto", true);
			arrow = new Bitmap(Arrow.arrowBMD, "auto", true);
			var d = 150 ; 
			var dir = direction;// * 3.1415926 / 180;
			addChild(shadow);
			addChild(arrow);
			//this.rotationX = 60;

			shadow.x = arrow.x = Arrow.arrowBMD.width *-0.5;
			//shadow.y = arrow.y = Arrow.arrowBMD.height *-0.5;
			shadow.z = -6;
			//dir 需要做一次x轴 镜像
			if(dir>=0 && dir < 180) dir = 180 - dir;
			else dir = 540 - dir;
			//parent.y = parent.y - d;
			var dirR =  dir * 3.1415926 / 180;
			//parent.transform.perspectiveProjection = p;
			var dx = d*Math.sin(dirR) , dy = d*Math.cos(dirR);
			this.x += dx ; this.y -= dy ;
			this.rotationZ = dir;
		}
		
		public function hover(v:Boolean):void
		{
			arrow.bitmapData = v ? Arrow.arrowHoverBMD : Arrow.arrowBMD;
			if(v) this.filters = [new GlowFilter(0x52a8ec,0.8,16,16,1)];
			else this.filters = [new GlowFilter(0x52a8ec,0,16,16,1)];
		}
		
	}