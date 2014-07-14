package
{
	import org.openscales.core.basetypes.Resolution;
	import org.openscales.core.layer.TMS;
	import org.openscales.core.layer.originator.ConstraintOriginator;
	import org.openscales.core.layer.originator.DataOriginator;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;


	public class SoulMap extends TMS
	{
		public static const resolutionsArray:Array = new Array(156543.03390625,
			78271.516953125,
			39135.7584765625,
			19567.87923828125,
			9783.939619140625,
			4891.9698095703125,
			2445.9849047851562,
			1222.9924523925781,
			611.4962261962891,
			305.74811309814453,
			152.87405654907226,
			76.43702827453613,
			38.218514137268066,
			19.109257068634033,
			9.554628534317017,
			4.777314267158508,
			2.388657133579254,
			1.194328566789627,
			0.5971642833948135,
			0.29858214169740677,
			0.14929107084870338,
			0.07464553542435169);
		
		public static const SOSO_SATELLITE = "http://p{random0-3}.map.gtimg.com/sateTiles/{z}/{rx}/{ry}/{x}_{y}.jpg";
		public static const SOSO_SATELLITE_TRAN = "http://p{random0-3}.map.gtimg.com/sateTranTiles/{z}/{rx}/{ry}/{x}_{y}.png";
		public static const SOSO_ROADMAP = "http://p{random0-3}.map.qq.com/maptilesv2/{z}/{rx}/{ry}/{x}_{y}.jpg";
		
		public static const TDT_SN_WGS84 = "http://210.74.129.78:8399/arcgis/rest/services/Cache/tdtsximgmap/MapServer/tile/{z}/{y}/{x}"
		
		public static const TDT_MERC_SATELLITE = "http://t{random0-7}.tianditu.cn/img_w/wmts?service=wmts&request=GetTile&version=1.0.0&LAYER=img&tileMatrixSet=w&TileMatrix={z}&TileRow={y}&TileCol={x}&style=default&format=tiles";
		public static const TDT_MERC_ROAD = "http://t{random0-7}.tianditu.cn/DataServer?T=vec_w&X={x}&Y={y}&L={z}";
		/* WATERlevel : 1 - 11 */
		public static const TDT_MERC_WATER = "http://t{random0-7}.tianditu.cn/wat_w/wmts?service=wmts&request=GetTile&version=1.0.0&LAYER=wat&tileMatrixSet=w&TileMatrix={z}&TileRow={y}&TileCol={x}&style=default&format=tiles";
		public static const TDT_MERC_TRAN = "http://t{random0-7}.tianditu.cn/DataServer?T=cia_w&X={x}&Y={y}&L={z}"

		public static const GOOGLE_SATELITE = "http://khm{random0-3}.googleapis.com/kh?v=147&hl=zh-CN&x={x}&y={y}&z={z}&s=Galile";
		public static const GOOGLE_TRAN = "http://mts{random0-3}.google.com/vt/lyrs=h@239000000&hl=zh-cn&src=app&x={x}&y={y}&z={z}&s=Ga";
		public static const GOOGLE_TERRAIN = "http://mt{random0-3}.google.com/vt/lyrs=t@131&hl=zh-CN&src=app&x={x}&y={y}&z={z}";
		
		//public static const GOOGLE_SATELITE = "http://khm{random0-3}.googleapis.com/kh?v=147&hl=zh-CN&x={x}&y={y}&z={z}";
		
		/*
			google,TDT_SATELLITE_MERC 左上角原点 90N 0E
			qq  左下角原点 90S 0E
			TDT_wgs 中心原点 0 0,
		*/
		public static const DEFAULT_MAX_RESOLUTION:Number = 156543.0339;
		
		//private static const SOULMAP:DataOriginator = new DataOriginator("SOULLAB_MAP", "", "http://wiki.april.org/skins/common/images/icons/cc-by-sa.png");

		private var _imagerySet:String = "Road";
		
		public function SoulMap(id:String ,urls : String = null ,imagerySet:String=null)
		{
			if(urls == null) urls = SoulMap.SOSO_SATELLITE;
			
			
			super(id, urls,"") //displayedNam;
			
			
			if(imagerySet) this._imagerySet = imagerySet;
			

			this.projection = "EPSG:900913";
			this.generateResolutions(18, 156543.0339);
			this.minResolution = new Resolution(this.resolutions[this.resolutions.length -1], this.projection);
			this.maxResolution = new Resolution(this.resolutions[0], this.projection);
			// Use the projection to access to the unit
			/* this.units = Unit.METER; */
			this.maxExtent = new Bounds(-20037508.34,-20037508.34,20037508.34,20037508.34,this.projection);
			var constraint:ConstraintOriginator = new ConstraintOriginator(this.maxExtent, this.minResolution, this.maxResolution);
			//OSM_ORIGINATOR.constraints.push(constraint);
			//CREATIVE_BY_CA.constraints.push(constraint);
			//this.originators.push(OSM_ORIGINATOR);
			//this.originators.push(CREATIVE_BY_CA);
			//this._tileOrigin = new Location(this.maxExtent.left,this.maxExtent.top,this.maxExtent.projection);
			
		}
		
		public static function parser(k:String , b:Array)
		{
			//qq map
			if(/gtimg/.test(k)){
				var iy:Number = 1 << (b[2]-1);
				b[1] = iy - b[1] - 1;
			}
			
			
			if(/tdtsximgmap/.test(k))
			{
				var iy:Number = 1 << (b[2]-1);
				//经纬度直投
				//天地图的 z 比 其他要 高一级
				//b[1] = iy - b[1]*2 - 1;
				//b[2] = b[2] + 1;
				
				
			}
			
			b[3] = Math.floor(b[0] / 16) ; b[4] = Math.floor(b[1] / 16);
			
			if((/{random(\d+)-(\d+)}/gi).test(k))
			{
				var t = k.match(/random(\d+)-(\d+)/ig)[0].replace("random","").split("-")
				var min = int(t[0]) , max = int(t[1])
				k = k.replace( /{random(\d+)-(\d+)}/ig ,min + Math.round(Math.random() * (max - min)) )
				
			}
			
			var p = ["x","y","z","rx","ry"];
			for(var i:int = 0 ; i<p.length ; i++)
			{
				var r:RegExp = new RegExp("{"+p[i]+"}", "ig");
				k = k.replace(r , b[i])
			}
			
			return k;
			
		}
		
		override public function getURL(bounds:Bounds):String
		{
			var res:Resolution = this.getSupportedResolution(this.map.resolution.reprojectTo(this.projection));
			var x:Number = Math.round((bounds.left - this.maxExtent.left) / (res.value * this.tileWidth));
			var y:Number = Math.round((this.maxExtent.top - bounds.top) / (res.value * this.tileHeight));
			var z:Number = this.getZoomForResolution(res.reprojectTo(this.projection).value);
			var limit:Number = Math.pow(2, z);
			
			if (y < 0 || y >= limit ||x < 0 || x >= limit) {
				return "";
			} else {
				
				
				/*
				x = ((x % limit) + limit) % limit;
				y = ((y % limit) + limit) % limit;
				*/
				return SoulMap.parser(this.url,[x , y , z])
				
			}
		}

		
		
		
	}
}