package pano.utils{
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.filters.DropShadowFilter;
	import flash.filters.DisplacementMapFilter;
	import flash.geom.*;

	import flash.text.*;

	import flash.utils.ByteArray;

	
	public class TextUtil{
		static public var toRADIANS :Number = Math.PI/180;
		static public var SIZE:Array = [16,12]

		
		static public function toBitmap(t:String, c:uint= 0xffffff , maxWidth:Number = 200 , fontSize:int = 16):Bitmap
		{
			var tf:TextField = new TextField();
				tf.autoSize = TextFieldAutoSize.RIGHT;
				tf.multiline = true;
				tf.wordWrap = true;
				tf.width = maxWidth;
				
				tf.defaultTextFormat = new TextFormat("simhei",fontSize,c);
				tf.text = t;
			var bmp:Bitmap = textFieldtoBitmap(tf);
			//if(maxWidth != -1 )
			//{
				//var scale:Number = maxWidth / Math.max(bmp.width,bmp.height) ;
				//if(scale < 1) { bmp.width = Math.round(bmp.width*scale); bmp.height = Math.round(bmp.height*scale) } 
			//}
			
			return bmp;
		}
		
		static public function textFieldtoBitmap(tf:TextField):Bitmap
		{
			
			var iy:Number = tf.getCharBoundaries(0).y;
			var ix:Number = tf.getCharBoundaries(0).x;
			try{
				for(var i = tf.length-1 ; i>=0 ; i--)
				{
					ix = Math.min(ix , tf.getCharBoundaries(i).x );
					iy = Math.min(iy , tf.getCharBoundaries(i).y );
				}
			} catch(e){ }
			
			var mat = new Matrix(1, 0, 0, 1, -ix, -iy);
			
			var bmd:BitmapData = new BitmapData(tf.textWidth,tf.textHeight,true,0x00ffffff);
				bmd.draw(tf,mat,null,null,null,true);
			
			return new Bitmap(bmd);
		}
		
		static public function len(str:String):Number
		{
			var ba:ByteArray = new ByteArray ();
				ba.writeMultiByte(str,"utf8");
			return ba.length;

		}
		
		
		
	}
}