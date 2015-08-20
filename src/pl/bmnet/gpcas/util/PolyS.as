

package pl.bmnet.gpcas.util {
	import flash.geom.Point;
	
	import pl.bmnet.gpcas.util.*;
	import pl.bmnet.gpcas.geometry.*;

	public class PolyS
	{
   
   		private var b:Array;
		private var r:Array;
		private var target:PolyDefault
		
		public function PolyS()
		{
			b = [ new PolySimple() , new PolySimple()];	
			target = new PolyDefault();
		}
		
		public function set(p:Array):void
		{
			for(var i:int = 0;i<2;i++)
			{
				b[i].clear();
				for(var j:int = 0;j<p[i].length;j++) b[i].addPoint(p[i][j]);
			}
		}
		
		public function intersection(p:Array):Array
		{
      		target.clear();
			for(var i:int = 0;i<p.length;i++)
			{
				target.addPoint(p[i]);
			}
			
			//var t1 = process( target.intersection(v[0]) );
			//var t2 = process( target.intersection(v[1]) );
			
			return process( target.intersection(b[0]) ).concat( process( target.intersection(b[1]) ) )
			
   		}
		
		private function process(v:Poly):Array
		{
			var res :Array = [];
			for( var i:int= 0 , l:int = v.getNumInnerPoly(); i < l ; i++ )
			{
				var p:Poly= v.getInnerPoly(i);

				var points : Array = [];
				for( var j:int= 0; j < p.getNumPoints() ; j++ )
				{
					points.push(new Point(p.getX(j),p.getY(j)));
				}
				points = ArrayHelper.sortPointsClockwise(points) as Array;
				res.push(points)
			}
			return res;
		}
		
		public function containsPoint(v:Point):Boolean
		{
			 return b[0].isPointInside(v) || b[1].isPointInside(v);
		}
   
	}
}
