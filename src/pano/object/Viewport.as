package pano.object{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Matrix;
	
	import org.papervision3d.core.render.data.RenderSessionData;
	import org.papervision3d.core.view.IViewport3D;
	import org.papervision3d.view.Viewport3D;
	
	/**
	 * @Author Ralph Hauwert
	 */
	public class Viewport extends Viewport3D implements IViewport3D
	{
		
		public var _bitmapData		:BitmapData;
		
		public var _containerBitmap	:Bitmap;
		protected var _fillBeforeRender:Boolean = true;
		protected var bgColor			:int;
		protected var bitmapTransparent:Boolean;

		public function Viewport(viewportWidth:Number=640, viewportHeight:Number=480, autoScaleToStage:Boolean = false,bitmapTransparent:Boolean=false, bgColor:int=0x000000,  interactive:Boolean=false, autoCulling:Boolean=true)
		{
			super(viewportWidth, viewportHeight, autoScaleToStage, interactive, true, autoCulling);
			this.bgColor = bgColor;
			_containerBitmap = new Bitmap();
			
			_bitmapData = _containerBitmap.bitmapData = new BitmapData(Math.round(viewportWidth), Math.round(viewportHeight), bitmapTransparent, bgColor);
			scrollRect = null;
			//addChild(_containerBitmap);
			//without interactable
			//removeChild(_containerSprite);
		}
		
		
		
		public function get bitmapData():BitmapData
		{
			if(_bitmapData.width != Math.round(viewportWidth) || _bitmapData.height != Math.round(viewportHeight))
			{
				_bitmapData = new BitmapData(Math.round(viewportWidth), Math.round(viewportHeight), bitmapTransparent, bgColor);
			}
			
			var mat:Matrix = new Matrix();
			mat.translate(_hWidth, _hHeight);
			_bitmapData.draw(_containerSprite, mat ,null, null, _bitmapData.rect, false);
			return _bitmapData
		}
		
		override public function destroy():void
		{
			
			_containerBitmap = null;
			_bitmapData.dispose();
			super.destroy();
		}
		
		override public function updateAfterRender(renderSessionData:RenderSessionData):void
		{
			super.updateAfterRender(renderSessionData);
			
		}
		

	}
}