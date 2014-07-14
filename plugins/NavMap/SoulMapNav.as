package {
	import flash.display.Sprite;
	import flash.events.Event;
	import org.openscales.core.Map;
	import org.openscales.core.utils.Trace;
	import org.openscales.core.control.LayerManager;
	import org.openscales.core.control.MousePosition;
	import org.openscales.core.control.OverviewMap;
	import org.openscales.core.control.PanZoomBar;
	import org.openscales.core.handler.feature.SelectFeaturesHandler;
	import org.openscales.core.handler.mouse.DragHandler;
	import org.openscales.core.handler.mouse.WheelHandler;
	import org.openscales.core.layer.Bing;
	import org.openscales.core.style.Style;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.geometry.basetypes.Size;
	import org.openscales.core.layer.osm.*;
	
	
	public class SoulMapNav extends Sprite {
		protected var _map:Map;
		
		public function SoulMapNav() {
			_map = new Map(500,400,"EPSG:900913");
			//_map.projection="";
			//_map.size = new Size(500, 400);
			_map.center = new Location(108,30,"EPSG:4326");
			
			var soso = new SoulMap("k");
			_map.addLayer(soso);
			var tran = new SoulMap("t",SoulMap.SOSO_SATELLITE_TRAN)
			_map.addLayer(tran)

			_map.addControl(new WheelHandler());
			_map.addControl(new DragHandler());
			
			this.addChild(_map);
			stage.addEventListener(Event.RESIZE, resize,false,0,true);
		}
		
		private function resize(e):void
		{
			_map.size = new Size(this.stage.stageWidth, this.stage.stageHeight);
			this.x = (500-this.stage.stageWidth)*.5;
			this.y = (400 - this.stage.stageHeight)*.5
		}
	}
}
