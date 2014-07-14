package  {

	import pano.ExtraInterface;
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;

	
	public class Border extends Sprite{

		private var viewportWidth:Number;
		private var viewportHeight:Number;
		private var EIF:ExtraInterface;
		public static const VER:Number = 1.0;
		private var container:Sprite;
        private var borderColor:uint;
        private var borderAlpha:Number;
        private var closeButton:ClickButton;
		
        public const BUTTON_SIDE:int = 16;
        private static const INACTIVE_BORDER_COLOR:uint = 0;
        private static const BORDER_WIDTH:int = 4;
        private static const HIGHLIGHTED_BORDER_ALPHA:Number = 1;
        private static const HIGHLIGHTED_BORDER_COLOR:uint = 6784199;
        private static const INACTIVE_BORDER_ALPHA:Number = 0.2;
        
		public function Border()
		{
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
			trace((new Date).toLocaleTimeString()+" : Loading Border(Ver 1.0) UI ... ");
			
			stage.showDefaultContextMenu = false;
			EIF = ExtraInterface.getInstance();
			if(EIF.ready) 
			{
				EIF.set("shutdown",shutDown);
				EIF.addPluginEventListener(ExtraInterface.PLUGINEVENT_REGISTER, this.registerEvent);
			}
			
			
			this.removeEventListener(Event.ADDED_TO_STAGE, this.startPlugin);
		}

		private function stopPlugin(e):void { }
		
		private function registerEvent(e):void {
			container = EIF.get("layer")();
			//jscall = EIF.get("jscall");
			init(); 
		}
		
		private function init():void{
			
			borderColor = INACTIVE_BORDER_COLOR;
            borderAlpha = INACTIVE_BORDER_ALPHA;
            viewportWidth = container.stage.stageWidth;
            viewportHeight = container.stage.stageHeight;
            createButtons(); 
            draw();
			resize();
			container.stage.addEventListener(Event.RESIZE, resizeHandler,false,0,true);
			this.closeButton.addEventListener(MouseEvent.CLICK, handleCloseClick, false, 0, true);
		}
		
		
		public function shutDown():void
		{
			//trace(jscall)
			//jscall("shutdown");
			EIF.dispatchEvent(new Event("notice_shutdown"));
		}
		
		private function getCrossTexture(linecolor:int, c:Number, param3:int, al:Number = 1) : BitmapData
        {
            var _loc_5:Sprite = new Sprite();
            var _loc_6:Graphics = _loc_5.graphics;
           	_loc_6.lineStyle();
            _loc_6.beginFill(c,param3);
            _loc_6.drawRect(0, 0, this.BUTTON_SIDE, this.BUTTON_SIDE);
            _loc_6.endFill();
            _loc_6.lineStyle(1, linecolor, 1);
            _loc_6.moveTo(6, 6);
            _loc_6.lineTo(12, 12);
            _loc_6.moveTo(12, 6);
            _loc_6.lineTo(6, 12);
            var _bmd = new BitmapData(this.BUTTON_SIDE, this.BUTTON_SIDE, true, 0);
            _bmd.draw(_loc_5);
            return _bmd;
        }

        public function setState(sS:Boolean) : void
        {
            borderColor = sS ? (HIGHLIGHTED_BORDER_COLOR) : (INACTIVE_BORDER_COLOR);
            borderAlpha = sS ? (HIGHLIGHTED_BORDER_ALPHA) : (INACTIVE_BORDER_ALPHA);
            draw();
        }

		//绘制边框
        private function draw() : void
        {
            var t_SIZE:Number = BUTTON_SIDE + BORDER_WIDTH;

               
               closeButton.x = viewportWidth - t_SIZE;
               closeButton.y = BORDER_WIDTH;
           
                container.graphics.clear();
                container.graphics.lineStyle(2 * BORDER_WIDTH, borderColor, borderAlpha);
                container.graphics.drawRect(0, 0, viewportWidth, viewportHeight);
                container.graphics.lineStyle();
                container.graphics.beginFill(borderColor, borderAlpha);
                container.graphics.drawRect(viewportWidth - t_SIZE - BORDER_WIDTH, BORDER_WIDTH, t_SIZE, BUTTON_SIDE + BORDER_WIDTH);
                container.graphics.endFill();
           
        }


        private function createButtons() : void
        {
           
      		closeButton = new ClickButton(container, this, getCrossTexture(16777215, 0, 0), getCrossTexture(6784199, 14015987, 1), getCrossTexture(16777215, 6784199, 1));
			container.addChild(closeButton);
           
        }

        private function handleCloseClick(event:MouseEvent) : void
        {
            event.stopImmediatePropagation();
            shutDown();
        }
		
		private function resizeHandler(e:Event):void
		{
			resize();
		}
		
		public function resize():void
		{
			viewportWidth = container.stage.stageWidth;
            viewportHeight = container.stage.stageHeight;
			draw();
		}

	}
	
}


	import flash.display.*;
    import flash.events.*;

    internal class ClickButton extends Sprite
    {
        private var upTexture:BitmapData;
        private var borderManager:*;
        private var tooltipMessage:String;
        private var _container:Sprite;
        private var state:int;
        private var overTexture:BitmapData;
        private var downTexture:BitmapData;
        private static const DOWN:int = 2;
        private static const OVER:int = 1;
        private static const UP:int = 0;

        public function ClickButton(param1:Sprite, param2:*, param3:BitmapData, param4:BitmapData, param5:BitmapData)
        {
            _container = param1;
            borderManager = param2;
            buttonMode = true;
            useHandCursor = true;
            regListeners();
            state = UP;
            setBitmapsAndDraw(param3, param4, param5);
            return;
        }// end function

      
		//设置按钮的 位图数据，共三种状态
        public function setBitmapsAndDraw(param1:BitmapData, param2:BitmapData, param3:BitmapData) : void
        {
            upTexture = param1;
            overTexture = param2;
            downTexture = param3;
            draw();
            return;
        }


		//配置侦听 以变换 按钮的样式
        private function regListeners() : void
        {
            addEventListener(MouseEvent.MOUSE_OVER, handleRollOver, false, 0, true);
            addEventListener(MouseEvent.MOUSE_OUT, handleRollOut, false, 0, true);
            addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown, false, 0, true);
            addEventListener(MouseEvent.MOUSE_UP, handleMouseUp, false, 0, true);
            return;
        }
		
        private function draw() : void
        {
		   var _loc_1:BitmapData = null;
            graphics.clear();
            switch(state)
            {
                case DOWN:
                {
                    _loc_1 = downTexture;
                    break;
                }
                case OVER:
                {
                    _loc_1 = overTexture;
                    break;
                }
                case UP:
                {
                    _loc_1 = upTexture;
                }
                default:
                {
                    break;
                }
            }
            graphics.beginBitmapFill(_loc_1);
            graphics.drawRect(0, 0, _loc_1.width, _loc_1.height);
            graphics.endFill();
            return;
        }// end function

		//设置状态并重绘
        private function setStateAndDraw(p:int) : void
        {
            if (p < 0 || p > 2)
            {
                return;
            }
            state = p;
            draw();
            return;
        }

        private function handleRollOver(event:MouseEvent) : void
        {
            borderManager.setState(true);
            setStateAndDraw(OVER);
            return;
        }

        private function handleRollOut(event:MouseEvent) : void
        {
            borderManager.setState(false);
            setStateAndDraw(UP);
            return;
        }

        private function handleMouseUp(event:MouseEvent) : void
        {
            setStateAndDraw(OVER);
            return;
        }



        private function handleMouseDown(event:MouseEvent) : void
        {
            event.stopImmediatePropagation();
            setStateAndDraw(DOWN);
            return;
        }
		
		

    }
