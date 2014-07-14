package {
	
	import flash.display.DisplayObject;
	import flash.display.StageAlign;
	import flash.display.Sprite;
	import flash.text.*;
	import flash.geom.Point;
	import pano.utils.StringUtil;
	//import org.tiny.utils.*;
	import pano.utils.TweenNano;

	public class Loading{

		private static var AlertText:TextField;
		private static var container:Sprite;
		private static var DefaultTextFormat:TextFormat;
		private static var _mouseMode:Boolean;//Msg 的形式，指定是否跟随鼠标(ture 时)，一次有效
		public function TipsBox() 
		{
			return;//init(s);
		}
		
		//接受 显示的内容 和 位置、偏移量 。位置使用舞台坐标。
		public static function show(msg:String = "")
		{
			AlertText.visible = true;
			Tweener.to(AlertText,0.5,{alpha:0.3});
			
			AlertText.text = msg;
			AlertText.width = (msg.length)*Number(DefaultTextFormat.size)/2;
			AlertText.height = Number(DefaultTextFormat.size) - 4 ;
			
			resize();
			
		}
		
		public static function init(s:Sprite):void
		{
			_mouseMode = false;
			container = s;
			AlertText = new TextField();
			AlertText.autoSize = TextFieldAutoSize.CENTER;
            AlertText.selectable = false;
			AlertText.wordWrap = true;
			//AlertText.width = 150;
			
			DefaultTextFormat = new TextFormat();
			DefaultTextFormat.font = "Calibri";
			DefaultTextFormat.bold = true;
            DefaultTextFormat.color = 0xffffff;
            DefaultTextFormat.size = 172;

			
            AlertText.defaultTextFormat = DefaultTextFormat;
			AlertText.alpha = 0.3;
			container.addChild(AlertText);
						
		}
		
		public static function hide():void{
			Tweener.to(AlertText,0.5,{alpha:0,onComplete:function(){
					AlertText.visible = false;
					clearStyle();
					resize();
			}});
		}
		
		
		public static function setStyle(oFarmat:TextFormat,...rest)
		{
			AlertText.defaultTextFormat = oFarmat;
			if(rest.length) StringUtil.paramToVar(rest[0],AlertText);
		}
		
		public static function clearStyle()
		{
			AlertText.background = false;
			AlertText.defaultTextFormat = DefaultTextFormat;
		}
		
		
		
		public static function resize()
		{
			AlertText.x = (container.stage.stageWidth - AlertText.width) ;
			AlertText.y = (container.stage.stageHeight - AlertText.height);
		}
		
		
	}
}