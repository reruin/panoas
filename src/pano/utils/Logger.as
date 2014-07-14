package pano.utils
{
    import flash.display.*;
    import flash.events.*;
    import flash.filters.*;
    import flash.system.*;
    import flash.text.*;

    public class Logger extends Sprite
    {
        private var hi_dpi:Boolean = false;
        private var output_bg:Shape = null;
        private var output_txt:TextField = null;
        private var output_X:Sprite = null;
        private var fatal_bg:Shape = null;
        private var fatal_txt:TextField = null;
        private var mainStage:Stage;
        private var _gm_:Boolean = false;
        private var cheatcodes:int = 0;
        public static var debugmode:Boolean = false;
        public static var keyb:Boolean = true;
        public static var showerrors:Boolean = true;
        private static var output_h:int = 148;
        private static var instance:Logger;
        private static var maxChars:int = 8000;
		
		private static var disable:Boolean = true;
		
		public static var t:Function = trace;
        public function Logger(s:Stage = null , d:Boolean = true)
        {
            Logger.disable =  !d;
			if (instance && instance.parent)
            {
                instance.parent.removeChild(instance);
            }
			
            var _loc_2:* = Capabilities.screenDPI;
            var _loc_3:* = Capabilities.screenResolutionX / _loc_2;
            var _loc_4:* = Capabilities.screenResolutionY / _loc_2;
            var _loc_5:* = Math.pow(_loc_3 * _loc_3 + _loc_4 * _loc_4, 0.5);
            if (Capabilities.screenDPI > 200 && _loc_5 > 6)
            {
                this.hi_dpi = true;
                Logger.output_h = 230;
            }
            instance = this;
            visible = false;
			
            this.mainStage = s ? s : stage;
			this.mainStage.addChild(this)
            if (debugmode)
            {
                maxChars = 16384 * 4;
            }
            this.buildgui();
           
        }

        private function buildgui() : void
        {
            var _oh:Number = output_h;
            this.output_bg = new Shape();
            this.output_bg.graphics.beginFill(0);
            this.output_bg.graphics.drawRect(0, 0, 100, _oh);
            this.output_bg.alpha = 0.667;
            this.output_bg.filters = [new GlowFilter(16777215, 1, 8, 8, 1)];
            addChild(this.output_bg);
            this.output_txt = new TextField();
            this.output_txt.type = TextFieldType.DYNAMIC;
            this.output_txt.borderColor = 16777215;
            this.output_txt.textColor = 16777215;
            var _loc_5:Boolean = false;
            this.output_txt.background = false;
            this.output_txt.border = false;
            this.output_txt.backgroundColor = 0;
            this.output_txt.height = _oh;

            this.output_txt.wordWrap = true;
            this.output_txt.multiline = true;
            var tformat:* = this.output_txt.getTextFormat();
            tformat.font = "_typewriter";
            tformat.size = this.hi_dpi ? (17) : (11);
            this.output_txt.setTextFormat(tformat);
            this.output_txt.defaultTextFormat = tformat;
            addChild(this.output_txt);
            this.output_X = new Sprite();
            this.output_X.useHandCursor = true;
            this.output_X.buttonMode = true;
            this.output_X.tabEnabled = false;
            this.output_X.mouseChildren = false;
            var cTxt:* = new TextField();
            cTxt.type = TextFieldType.DYNAMIC;
            cTxt.textColor = 16777215;
            cTxt.selectable = false;
            cTxt.wordWrap = false;
            cTxt.multiline = false;
            cTxt.background = false;
            cTxt.border = false;
            cTxt.getTextFormat().font = "_typewriter";
			var _loc_4:* = cTxt.getTextFormat();
            _loc_4.size = this.hi_dpi ? (16) : (10);
            cTxt.defaultTextFormat = _loc_4;
            cTxt.text = "CLOSE";
            cTxt.autoSize = TextFieldAutoSize.LEFT;
            this.output_X.addChild(cTxt);
            addChild(this.output_X);
            this.output_X.addEventListener(MouseEvent.CLICK, toggleOff);
            this.mainStage.addEventListener(Event.RESIZE, this.recalcLayout);
            this.mainStage.addEventListener(KeyboardEvent.KEY_DOWN, this.keyDownHandler);
            this.recalcLayout();
            return;
        }

        public function fatalerror(param1:String) : void
        {
            var _loc_2:TextFormat = null;
            if (this.fatal_bg == null)
            {
                this.fatal_bg = new Shape();
                this.fatal_bg.filters = [new GlowFilter(16777215, 1, 8, 8, 1)];
                this.mainStage.addChild(this.fatal_bg);
            }
            if (this.fatal_txt == null)
            {
                this.fatal_txt = new TextField();
                this.fatal_txt.textColor = 16777215;
                this.fatal_txt.border = false;
                this.fatal_txt.background = false;
                this.fatal_txt.selectable = false;
                this.fatal_txt.height = 50;
                this.fatal_txt.multiline = true;
                this.fatal_txt.wordWrap = true;
                this.fatal_txt.autoSize = TextFieldAutoSize.CENTER;
                _loc_2 = this.fatal_txt.getTextFormat();
                _loc_2.font = "_typewriter";
                _loc_2.size = 15;
                this.fatal_txt.setTextFormat(_loc_2);
                this.fatal_txt.defaultTextFormat = _loc_2;
                this.mainStage.addChild(this.fatal_txt);
                this.fatal_txt.text = String(param1).split("[br]").join(String.fromCharCode(13));
            }
            this.mainStage.mouseChildren = false;
            this.redrawfatalerror();
            return;
        }

        private function redrawfatalerror() : void
        {
            var _loc_3:Graphics = null;
            var _loc_4:int = 0;
            var _loc_1:* = this.mainStage.stageWidth;
            var _loc_2:* = this.mainStage.stageHeight;
            if (this.fatal_txt != null)
            {
                this.fatal_txt.width = _loc_1;
                this.fatal_txt.y = _loc_2 / 2 - this.fatal_txt.textHeight / 2 * 1.1;
                this.fatal_txt.x = _loc_1 / 2 - this.fatal_txt.textWidth / 2;
                this.fatal_txt.autoSize = TextFieldAutoSize.CENTER;
            }
            if (this.fatal_bg != null)
            {
                _loc_3 = this.fatal_bg.graphics;
                _loc_4 = Math.max(50, this.fatal_txt.textHeight * 1.1);
                _loc_3.clear();
                _loc_3.lineStyle(0, 0, 0);
                _loc_3.beginFill(0);
                _loc_3.drawRect(0, _loc_2 / 2 - _loc_4 / 2, _loc_1, _loc_4);
            }
            return;
        }

        public function recalcLayout(event:Event = null) : void
        {
            var w:Number = this.mainStage.stageWidth;
            var h:Number = this.mainStage.stageHeight;
            this.output_txt.height = Logger.output_h;
            this.output_bg.height = Logger.output_h;
            this.output_txt.x = int(-1);
            this.output_txt.width = int(w + 2);
            this.output_bg.width = int(w);
            var ty:int = int(h - this.output_txt.height);
            this.output_txt.y = int(h - this.output_txt.height);
            this.output_bg.y = ty;
            if (this.output_X != null)
            {
                this.output_X.x = int(w - this.output_X.width * 1.1);
                this.output_X.y = int(this.output_bg.y - this.output_X.height * 0);
            }
			//this.x = (550 - w)/2;
			//this.y = (400-h)/2;
            this.redrawfatalerror();
           
        }

        private function keyDownHandler(event:KeyboardEvent) : void
        {
            if (!instance || !Logger || disable)  return;

            var code:int = event.keyCode;
			
			//[O] for toggle self
            if (Logger.keyb && code == 79)  Logger.toggle();
			
			//[C] for clear text
			if (Logger.keyb && code == 67) output_txt.text = "";

            if (this.cheatcodes == 0 && code == 83)
            {
				this.cheatcodes++;
            }
            else if (this.cheatcodes == 1 && code == 79)
            {
               this.cheatcodes++;
            }
            else if (this.cheatcodes == 2 && code == 85)
            {
                 this.cheatcodes++;
            }
            else if (this.cheatcodes == 3 && code == 76)
            {
                 this.cheatcodes++;
            }
            else if (this.cheatcodes == 4 && code == 76)
            {
                this.cheatcodes++;
            }
			else if (this.cheatcodes == 5 && code == 65)
            {
                this.cheatcodes++;
            }
            else if (this.cheatcodes == 6 && code == 66)
            {
                this._gm_ = true;
                Logger.keyb = true;
                Logger.debugmode = true;
            }
            else
            {
                this.cheatcodes = 0;
            }
        }

		public static function trace(param1:int, ... args) : void
        {

			if (!instance || Logger.disable)  return;
			         
            if(param1 == 0 && Logger.debugmode == false)  return;
			

          
			var infos:String = args.toString();
            var isdebug:Boolean = true;
            var hasshow:Boolean = false;
            var mode:String = "";
            var _loc_7:Boolean = false;
            switch(param1)
            {
                case 0:
                {
                    mode = "DEBUG";
                    isdebug = Logger.debugmode;
                    hasshow = false;
                    break;
                }
                case -101:
                {
                    _loc_7 = true;
                }
                case 1:
                {
                    mode = "INFO"; hasshow = false;
                    break;
                }
                case 2:
                {
                    mode = "WARNING"; hasshow = false;
                    break;
                }
                case 3:
                {
                    mode = "ERROR"; hasshow = true;
                    break;
                }
                case 4:
                {
                    mode = "FATAL"; hasshow = false;
                    break;
                }
                case 5:
                {
                    mode = null;
                    param1 = 4;
                    hasshow = false;
                    break;
                }
                case 65281:
                {
                    Logger.keyb = true;
                }
                case 65282:
                {
                    Logger.keyb = false;

                }
                default:
                {
                    break;
                }
            }
			
            if (!isdebug)  return;

            if (instance.mainStage)  instance.mainStage.setChildIndex(instance, (instance.mainStage.numChildren - 1));
           
            if (hasshow && showerrors)  instance.visible = true;
			
            if (mode)  infos = mode + ": " + infos + "\n";
				
            if (_loc_7)
            {
                infos = infos + instance.output_txt.text;
                instance.output_txt.text = infos;
            }
            else
            {
                instance.output_txt.appendText(infos);
                if (instance.output_txt.text.length > maxChars)
                {
                    instance.output_txt.text = instance.output_txt.text.slice(-maxChars);
                }
            }
            instance.output_txt.scrollV = instance.output_txt.maxScrollV;
            if (param1 == 4)
            {
                instance.fatalerror(infos);
            }
           
        }

        public static function show(v:Boolean) : void
        {

			instance && (instance.visible = v);
           
        }

        public static function isOpen() : Boolean
        {
            if (!instance)
            {
                return false;
            }
            return instance.visible;
        }

        public static function toggle() : void
        {
            if (!instance)
            {
                return;
            }
            instance.visible = !instance.visible;
            instance.mainStage.setChildIndex(instance, (instance.mainStage.numChildren - 1));
        }

        public static function toggleOff(event:Event = null) : void
        {
            if (!instance)
            {
                return;
            }
            instance.visible = false;

        }

    }
}
