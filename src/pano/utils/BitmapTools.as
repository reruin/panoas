package pano.utils
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.geom.ColorTransform;
	import flash.display.Sprite;
	public class BitmapTools
	{
		
		/**
		 * Mirrors the bitmap over its X axis
		 * 
		 * @param	bitmap The bitmap to mirror.
		 */ 
		public static function mirrorBitmapX(bitmap:BitmapData):void
		{
			var tmp:Bitmap = new Bitmap(bitmap.clone());
			tmp.scaleX = -1;
			tmp.x = bitmap.width;
			bitmap.draw(tmp, tmp.transform.matrix);
			tmp.bitmapData.dispose();
			tmp = null;
		}
				
		/**
		 * Mirrors the bitmap over its Y axis
		 * 
		 * @param	bitmap The bitmap to mirror.
		 */ 
		public static function mirrorBitmapY(bitmap:BitmapData):void
		{
			var tmp:Bitmap = new Bitmap(bitmap.clone());
			tmp.scaleY = -1;
			tmp.y = bitmap.height;
			bitmap.draw(tmp, tmp.transform.matrix);
			tmp.bitmapData.dispose();
		}
		
		// swap foot and head area
		public static function swapInvalid(bitmap:BitmapData)
		{
			var offset = 570;
			var tmp:Bitmap =  new Bitmap(bitmap.clone());
			var rectTo:Rectangle = new Rectangle(0, 0, tmp.width ,offset);
			
			//tmp.bitmapData.threshold(bitmap, rectTo, new Point(0,0), "<", 0xff222222, rgb,0xff0000);
			
			//var rgb:Object = getRGB(bitmap.getPixel(50,offset));
			tmp.bitmapData.fillRect(rectTo, 0xffffff);
			/*
			var tmp:Bitmap =  new Bitmap(new BitmapData(bitmap.width,bitmap.height-2*offset,false));
			var rectTo:Rectangle = new Rectangle(0, offset, tmp.width ,bitmap.height-offset);
			tmp.bitmapData.copyPixels(bitmap, rectTo, new Point(0,0));
			bitmap.draw(tmp,new Matrix(1,0,0,bitmap.height/tmp.height,0,0),null,null,null,true);
			*/
			bitmap.draw(tmp);
			tmp.bitmapData.dispose();

		}
		
		public static function swapTile(bmd:BitmapData , tilebmd:BitmapData , ix:int , iy:int):void
		{
			BitmapTools.mirrorBitmapX(tilebmd);
			var rectFrom:Rectangle = new Rectangle(0, 0, tilebmd.width, tilebmd.height);
			
			//use in  mirrorX 
			var PointTo:Point = new Point(bmd.width-ix-tilebmd.width, iy);
			
			// copyPixels isn't draw，set correct Tile's width and height
			bmd.copyPixels(tilebmd, rectFrom, PointTo);
		}
		
		// set3dOn / Off 实质是镜像操作，如果 位图被mirrorBitmapX 处理，只要交换使用 On / Off 即可。
		public static function set3dOn(bitmap:BitmapData):void
		{
			var offset = 25;
			var tmp:Bitmap =  new Bitmap(bitmap.clone())
			var rectTo:Rectangle = new Rectangle(0, 0, tmp.width, tmp.height);
			tmp.bitmapData.colorTransform(rectTo, new ColorTransform (0,1,1,1,0,0,0,0));//除去 R 通道。
			//复制 原图 R 通道至 offset 位置
			tmp.bitmapData.copyChannel(bitmap, new Rectangle(0, 0, tmp.width-offset, tmp.height), new Point(offset,0), BitmapDataChannel.RED, BitmapDataChannel.RED);
			//复制 原图 R 通道至 最后 offset 位置
			tmp.bitmapData.copyChannel(bitmap, new Rectangle(tmp.width-offset, 0, offset, tmp.height), new Point(0,0), BitmapDataChannel.RED, BitmapDataChannel.RED);
			
			bitmap.draw(tmp);
			tmp.bitmapData.dispose();
			 
		}
		
		public static function set3dOff(bitmap:BitmapData):void
		{
			var offset = 25;
			var tmp:Bitmap =  new Bitmap(bitmap.clone())
			var rectTo:Rectangle = new Rectangle(0, 0, tmp.width, tmp.height);
			tmp.bitmapData.colorTransform(rectTo, new ColorTransform (0,1,1,1,0,0,0,0));
			tmp.bitmapData.copyChannel(bitmap, new Rectangle(0, 0, offset, tmp.height), new Point(tmp.width-offset,0), BitmapDataChannel.RED, BitmapDataChannel.RED);
			tmp.bitmapData.copyChannel(bitmap, new Rectangle(offset, 0, tmp.width-offset, tmp.height), new Point(0,0), BitmapDataChannel.RED, BitmapDataChannel.RED);
			
			bitmap.draw(tmp);
			tmp.bitmapData.dispose();
			 
		}
		
		
		public static function draw(c:* = null, path:Array = null,f:uint = 0,s:Number = 1)
		{
			var a = f/0xFFFFFFFF; f = f%0xFF000000;
			var Graphic = c.graphics;
			
			Graphic.clear();Graphic.beginFill(f,a);
			Graphic.moveTo(path[0].x,path[0].y);
			for (var i:int = 1; i < path.length; i++ ) 
				Graphic.lineTo(path[i].x*s,path[i].y*s)
			Graphic.lineTo(path[0].x,path[0].y)
			Graphic.endFill();
		}
		
		public static function fill(path:Array = null,f:uint = 0,s:Number = 1):BitmapData
		{
			//var a = (f >> 24) /255
			
			var _btn:Sprite = new Sprite();
			var _btnBitmapData:BitmapData = null;
			draw(_btn,path,f)
			_btnBitmapData = new BitmapData(_btn.width,_btn.height, true, 0);
			_btnBitmapData.draw(_btn);//将 btn 绘制成 bitmapdata
			_btn = null;
            return _btnBitmapData;
			
		}
		public static function ARGB(color:String):Object
		{
			color = color.toString();
			var argb :Object= {a : parseInt(color.substr(2,2),16)/256 ,r : parseInt(color.substr(4,2),16)/256 ,g : parseInt(color.substr(6,2),16)/256,b : parseInt(color.substr(8,2),16)/256};
			return (argb)
		}
			
			
		public static function Rgb2String(a:uint,b:uint,c:uint):String
		{
			var _r:String = a<16?"0"+a.toString(16):a.toString(16);
			var _g:String = b<16?"0"+b.toString(16):b.toString(16);
			var _b:String = c<16?"0"+c.toString(16):c.toString(16);
			return String( "0x"+ _r + _g + _b);
		}
			
		public static function getRGB ($rgb:uint):Object
		{
   			 return {r:($rgb >> 16 & 0xFF), g:($rgb >> 8 & 0xFF), b:($rgb & 0xFF)}
		}
			
	
	}
}