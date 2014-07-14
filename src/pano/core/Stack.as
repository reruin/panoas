package pano.core
{
	import flash.text.TextFormat;
	import flash.geom.Point;
	import flash.display.BitmapData;
	import flash.display.Sprite;
    import pano.utils.BitmapTools;
	
    final public class Stack extends Object
    {
		public static const style = new TextFormat("Times New Roman",13,0xeeeeee,false);
		public static const TextFieldStyle = {
							//background	:	true,
							//border		:	true,
							//borderColor 	: 	"0xcccccc",
							//backgroundColor : "0xeeeeee",
							//alpha:0.5
							};
							
		public static const X_ARROW_DATA:Array = [108, 90, 54, 18, 0,54];
       	public static const Y_ARROW_DATA:Array = [54, 72, 36, 72, 54,0];
		/*public static const ARROW_DATA:Array = [ new Point(108,54)	,
												 new Point(90,72)	,
												 new Point(54,36)	,
												 new Point(18,72)	,
												 new Point(0,54)	,
												 new Point(54,0)	];*/
		public static const ARROW_DATA:Array = [ new Point(81,40)	,
												 new Point(67.5,54)	,
												 new Point(40,27)	,
												 new Point(13.5,54)	,
												 new Point(0,40)	,
												 new Point(40,0)	];
												 
		public static const VIDEO_DATA:Array = [ new Point(0,0) ,
												 new Point(0,20) ,
												 new Point(20,20) ,
												 new Point(20,0)];
		
		//默认颜色 16777215，HOVER_COLOR:uint = 14015987，ACTIVE_COLOR:uint = 6784199;
		public static const ARROW_SHADOW:uint = 2147483648; // 0x000000 alpha = 0.5
		public static const ARROW:uint = 4294967295; //0xffffff alpha = 1
		public static const ARROW_HOVER:uint = 4292206067; // 0xFFD5DDF3 alpha = 1
		
		public static var arrowBMD:BitmapData = BitmapTools.fill(ARROW_DATA,ARROW);
		public static var arrowShadowBMD:BitmapData = BitmapTools.fill(ARROW_DATA,ARROW_SHADOW);
		public static var arrowHoverBMD:BitmapData = BitmapTools.fill(ARROW_DATA,ARROW_HOVER);
		public static var VideoBMD:BitmapData;// = BitmapTools.fill(VIDEO_DATA,4294967295);
		public static var VideoHoverBMD:BitmapData;// = BitmapTools.fill(VIDEO_DATA,4294967295);
		
		public static function init():void{
			nodes = [];
			VideoBMD = updateImgShape(2164260863);
			VideoHoverBMD = updateImgShape(2161499635);
			//graphics.beginBitmapFill
		}
		
		private static function updateImgShape(f:uint):BitmapData
		{
			var a = f/0xFFFFFFFF; f = f%0xFF000000;
			var shape:Sprite = new Sprite();
			var _size = 32 , padding = 8;
			
			var outHeight:Number = _size; //_container.height + 6;
			var outWidth:Number =  _size; //_container.width + 6;
			var inHeight:Number = _size;//_container.height;
			var inWidth:Number = _size;//_container.width;
			
			shape.graphics.clear();
			shape.graphics.beginFill(0xffffff,1);
			
			// 绘制 外侧圆角矩形
			shape.graphics.lineStyle(6,0x9aaedb,1);
			shape.graphics.drawRect(0,0,_size,_size);
			shape.graphics.endFill();
			shape.graphics.lineStyle(0,0x9aaedb,1);
			shape.graphics.beginFill(0x9aaedb,1);
			shape.graphics.moveTo(0,_size);
			shape.graphics.lineTo(0,_size*0.6);
			shape.graphics.lineTo(_size*0.1,_size*0.75);
			shape.graphics.lineTo(_size*0.2,_size*0.5);
			shape.graphics.lineTo(_size*0.3,_size*0.6);
			shape.graphics.lineTo(_size*0.5,_size*0.6);
			shape.graphics.lineTo(_size*0.7,_size*0.2);
			shape.graphics.lineTo(_size*0.9,_size*0.5);
			shape.graphics.lineTo(_size,_size*0.5);
			shape.graphics.lineTo(_size,_size);
			shape.graphics.lineTo(0,_size);
			shape.graphics.endFill();
			var t = new BitmapData(outWidth,outHeight,true,0x00234567);
			t.draw(shape);
			return t;
		}
		
		private static function updateVideoShape(f:uint):BitmapData
		{
			var a = f/0xFFFFFFFF; f = f%0xFF000000;
			var shape:Sprite = new Sprite();
			var _size = 32 , padding = 8;
			
			var outHeight:Number = _size; //_container.height + 6;
			var outWidth:Number =  _size; //_container.width + 6;
			var inHeight:Number = _size;//_container.height;
			var inWidth:Number = _size;//_container.width;
			
			shape.graphics.clear();
			shape.graphics.beginFill(0xffffff,1);
			
			// 绘制 外侧圆角矩形
			shape.graphics.lineStyle(6,0x9aaedb,1);
			shape.graphics.drawRect(0,0,_size,_size);
			shape.graphics.endFill();
			shape.graphics.lineStyle(0,0x9aaedb,1);
			shape.graphics.beginFill(0x9aaedb,1);
			shape.graphics.moveTo(0,_size);
			shape.graphics.lineTo(0,_size*0.6);
			shape.graphics.lineTo(_size*0.1,_size*0.75);
			shape.graphics.lineTo(_size*0.2,_size*0.5);
			shape.graphics.lineTo(_size*0.3,_size*0.6);
			shape.graphics.lineTo(_size*0.5,_size*0.6);
			shape.graphics.lineTo(_size*0.7,_size*0.2);
			shape.graphics.lineTo(_size*0.9,_size*0.5);
			shape.graphics.lineTo(_size,_size*0.5);
			shape.graphics.lineTo(_size,_size);
			shape.graphics.lineTo(0,_size);
			shape.graphics.endFill();
			var t = new BitmapData(outWidth,outHeight,true,0x00234567);
			t.draw(shape);
			return t;
		}
		
		public static var nodes:Array  = [];
		
		public static var roads:Array = [];
		
		public static var pois:Array = [];
		
		public static var fromrot:Number = 0;
		
		public static var fromDistance : Number = 0;
		
		public static var svid:String;
		
		public static var areaid:String;
		
		public static var face:Point;
		
		public static function extend(src:* , sour:Object):Object
		{
			var o:Object = new Object() , i:String;
			
			for(i in src) o[i] = src[i];
			
			for(i in sour) o[i] = sour[i];
			
			return o;
		}
		
		public static var plugins:Array = [];
		
		public static function xmlValue(xml , key)
		{
			xml.hasOwnProperty(key) ? xml.@[key]: null;
		}
		
    }
}
