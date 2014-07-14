package pano.utils{
	import flash.geom.*;
	
	public class Geometry{
		static public function distanceLatlng(p:Point , p1:Point):Number
		{
			//标准球体 计算
			var EARTH_RADIUS = 6378137.0 , PI = Math.PI
			 , toRad = Math.PI/180.0;
			
			var lat1:Number = p1.y , lng1:Number = p1.x , lat2:Number = p.y , lng2:Number = p.x;
			lat1 = lat1 * toRad;
			lat2 = lat2 * toRad;
			
			var a = lat1 - lat2;
			var b = lng1 * toRad - lng2 * toRad;
			
			var s = 2*Math.asin(Math.sqrt(Math.pow(Math.sin(a/2),2) + Math.cos(lat1)*Math.cos(lat2)*Math.pow(Math.sin(b/2),2)));
			s = s*EARTH_RADIUS;
			s = Math.round(s*10000)/10000.0;
			return s;
		}
		
		static public function distance(p:Point , p1:Point):Number
		{
			return Math.sqrt((p.x-p1.x)*(p.x-p1.x) + (p.y-p1.y)*(p.y-p1.y))			
		}
		
		// 方位角 t 相对于 o :
		static public function azimuth(o,t:* = null , fors:Boolean = false):Number
		{
			if(t==null) t = new Point(0,0);
			var v:Number;
			if(fors)
			{
				v = Math.atan2(o.y - t.y , o.x - t.x )*180/Math.PI;
				v = (180 + v);
			}else
			{
				v = Math.atan2(o.y - t.y , t.x - o.x )*180/Math.PI;
				if(v>=-90) v = 90 + v;
				else v = 360 + 90 + v;
			}
			
			return v;
		}
		
		// 左下角原点 
		static public function calcRot(o,t , fors:Boolean = false):Number
		{
			if(fors){
				var k =  Geometry.azimuth(o,t);
				k = (90 - k + 360)%360;
				return k;
				
			}
			var v:Number = Math.atan2(o.y - t.y , t.x - o.x )*180/Math.PI;
			if(v>=-90) v = 90 + v;
			else v = 360 + 90 + v;
			return v;
		}
		
		static public function cog(p:Array):Point
		{
			var pCen:Point = new Point() , pSum :Point = new Point() ;
			var area:Number = 0,sumArea:Number = 0;
			
			for(var i:int = 0;i < p.length-2;i++)
			{
				pCen.x = p[0].x + p[i+1].x + p[i+2].x;
				pCen.y = p[0].y + p[i+1].y + p[i+2].y; 
				area = TriangleArea(p[0], p[i+1], p[i+2]);
				sumArea += area;
				pSum.x += pCen.x * area;
				pSum.y += pCen.y * area; 
			}
			pSum.x = pSum.x/(sumArea*3);pSum.y = pSum.y/(sumArea*3);
			return pSum;
		}
		
		static public function TriangleArea(p0:Point,p1:Point,p2:Point):Number
		{
			return Math.abs((p0.x * p1.y + p1.x * p2.y + p2.x * p0.y - p1.x * p0.y - p2.x * p1.y - p0.x * p2.y)/3);
		}
		

	

	}
	
}