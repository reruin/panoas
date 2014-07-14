package pano.extras{
	
	import flash.display.*;
	import flash.text.*;
	import flash.events.*;
	import flash.geom.Point;
	import pano.utils.StringUtil;
	import pano.controls.ExtraManager;
	import pano.utils.TweenNano;

	public class TipsBox extends TextField implements IExtra{

		public static var VER:Number = 1.0;
		private var container:Sprite;
		private var DefaultTextFormat:TextFormat;
		private var _mouseMode:Boolean;//Msg 的形式，指定是否跟随鼠标(ture 时)，一次有效
		private var EM:EventDispatcher;
		public function TipsBox(p:EventDispatcher,v:Array) 
		{
			EM = p; container = v[0]; init();
		}
		
		//接受 显示的内容 和 位置、偏移量 。位置使用舞台坐标。
		public function show(msg:String = "")
		{
			this.visible = true;
			TweenNano.to(this,0.5,{autoAlpha:0.5});
			
			this.text = msg;
			this.width = (msg.length)*Number(DefaultTextFormat.size)/2;
			this.height = Number(DefaultTextFormat.size) - 4 ;
			
			hide(5);
			
			resize();
			
		}
		
		private function init():void
		{
			_mouseMode = false;
			this.autoSize = TextFieldAutoSize.CENTER;
            this.selectable = false;
			this.wordWrap = true;
			//this.width = 150;
			DefaultTextFormat = new TextFormat();
			DefaultTextFormat.font = "Calibri";
			DefaultTextFormat.bold = true;
            DefaultTextFormat.color = 0xffffff;
            DefaultTextFormat.size = 172;
			
            this.defaultTextFormat = DefaultTextFormat;
			this.alpha = 0.3;
			
			container.addChild(this);
			EM.addEventListener("tipsbox_show",showHandler);
						
		}
		
		private function showHandler(e:*):void
		{
			show(e.feature as String)
		}
		
		public function hide(v:Number = 0):void
		{
			TweenNano.to(this,0.5,{autoAlpha:0 , delay:v});
		}
		
		
		public function setStyle(oFarmat:TextFormat,...rest)
		{
			this.defaultTextFormat = oFarmat;
			if(rest.length) StringUtil.paramToVar(rest[0],this);
		}
		
		public function clearStyle()
		{
			this.background = false;
			this.defaultTextFormat = DefaultTextFormat;
		}
		
		
		public function resize():void
		{
			this.x = (container.stage.stageWidth - this.width) ;
			this.y = (container.stage.stageHeight - this.height);
		}
		
		
	}
}