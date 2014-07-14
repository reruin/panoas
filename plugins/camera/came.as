package  {
	
	import flash.display.*;
	import flash.media.*;
	import flash.events.*;
	import flash.system.Security;
	import flash.net.FileReference;
	import com.adobe.images.PNGEncoder;
	import pano.ExtraInterface;
	import pano.utils.TweenNano;
	public class came extends Sprite{

		private var _cameraBtn:cameraBtn;
		private var _shutterSound:shutterSound;
		private var EIF:ExtraInterface;
		
		public function came() {
			
			Security.allowDomain("*");
			
			//stage.scaleMode = StageScaleMode.NO_SCALE
			if (stage == null)
			{
				this.addEventListener(Event.ADDED_TO_STAGE, this.startPlugin);
			//this.addEventListener(Event.REMOVED_FROM_STAGE, this.stopPlugin);
			}else
			{
				init();
			}
			// constructor code
		}
		
		private function startPlugin(e:Event):void
		{
			
			stage.showDefaultContextMenu = false;
			EIF = ExtraInterface.getInstance();
			//trace("run me")
			if(EIF.ready) 
			{
				
			}
			
			init();
			
		}
		
		public function init():void
		{
			_cameraBtn = new cameraBtn();
		
			_shutterSound = new shutterSound();
			this.addChild(_cameraBtn)
			
			_cameraBtn.x = this.stage.stageWidth - _cameraBtn.width - 10;
			_cameraBtn.y = 10;
			this.x = this.y = 2
			regListeners();
			resize();
		}
		
		private function regListeners():void
		{
			_cameraBtn.addEventListener(MouseEvent.CLICK , cameraClickHandler);
			
			this.addEventListener(MouseEvent.MOUSE_OVER,overHandler);
			this.addEventListener(MouseEvent.MOUSE_OUT,outHandler);
			stage.addEventListener(Event.RESIZE, resizeHandler,false,0,true);
			
		}
		
		private function overHandler(e:MouseEvent):void {
			var v = e.target;
			if(v.numChildren <2 )
				TweenNano.to(v,0.4,{alpha:1});
		}
		
		private function outHandler(e:MouseEvent):void {
			var v = e.target;
	  		if(v.numChildren <2 )
				TweenNano.to(v,0.4,{alpha:0.6});
		}
		
		private function cameraClickHandler(e:MouseEvent):void
		{
			getPhoto();
		}
		
		
		private function resizeHandler(e):void
		{
			resize()
		}
		
		
		public function download()
		{
		
		}
		
		
		public function getPhoto()
		{
			_shutterSound.play();

			var file:FileReference = new FileReference();
			var image:BitmapData;
			if(EIF){
				image = EIF.get("print")(true);
			}else
			{
				image = new BitmapData(stage.width,stage.height);
				image.draw(this.stage);
			}
			
			file.save(PNGEncoder.encode(image),"image.png");
		}
		
		public function resize():void
		{
			var viewportWidth = this.stage.stageWidth;
			var viewportHeight = this.stage.stageHeight;
			//this.x = viewportWidth - width - 2;
			//this.y = 2;
			_cameraBtn.y = 10;
			_cameraBtn.x = 10;//viewportWidth - _cameraBtn.width - 10;
		}

	}
	
}
