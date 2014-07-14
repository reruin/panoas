package pano.extras {
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	public class Polygon extends Sprite{
		
		public var _pointList:Array;
		private var _drawPointList:Array; // 可绘画点，依据当前视口截取 用于draw 的范围，
		public var type:String = "polygon";
		public var title:String;
		public var data:Object;
		//public var 
		
		public function get position():Array { return _pointList.concat(); }
		
		public function Polygon(o:Object){
			
			_pointList = o.path; this.alpha = 0;
			data = o;
			//if(_pointList.length>0) init();
		}
		
		//重绘
		public function update(p:Array):void
		{
			
			var g = this.graphics;
			g.clear();
			g.beginFill(0xffffff,1);
			for(var i:int = 0; i<p.length ; i++)
			{
				var v:Array = p[i];
				if(v.length>0)
				{
					g.moveTo(v[0].x,v[0].y);
					//g.lineStyle(_style.strokeStyle.thickness,_style.strokeStyle.color,_style.strokeStyle.alpha,_style.strokeStyle.pixelHinting);
					for(var i=1; i<v.length; i++) g.lineTo(v[i].x,v[i].y);
					g.moveTo(0,0);
				}
			}
			
		}
		

		override public function toString():String{
			return "Polygon Object"
		}
		
		static public function fromString(s:String):Polygon{
			var a:Array = s.split(";");
			var b:Array = new Array();
			for(var i:int = 0; i<a.length; i++)
			{
				b[i] = pointFromString(a[i]);
			}
			return new Polygon(b);
		}
		
		static public function pointFromString(v:String):Point
		{
			var t = v.split(",");
			return new Point(t[0],t[1]);
		}
		
		public function destory():void
		{
			
		}
		
		
	}
}