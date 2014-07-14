package pano.extras {
	import flash.display.*;
	import flash.geom.Point;
	import pano.core.Stack;
	import pano.events.*;
	public class Marker extends Sprite{

		public var position:Point;
		public var ident:int = 1;
		public var event:String ; 
		public var feature:Object;
		
		public function Marker(p:Point , e:String , f:*)
		{
			position = p; event = e; feature = f;
			var bmp = new Bitmap(Stack.VideoBMD,"auto",true);
			bmp.x = bmp.y = -10;
			addChild(bmp);
			
		}
		
		
		public function update(p:Point):void{
			
			if(p.x<=0 || p.y <= 0 || p.x >= this.stage.stageWidth || p.y >= this.stage.stageHeight) this.visible = false;
			else 
			{
				this.x = p.x ; this.y = p.y ;
				this.visible = true;
			}
			
		}

	}
	
}
