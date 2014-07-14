
package pano.utils 
{

	public class MathUtil 
	{
		/**
		 * Math constant pi&#42;2.
		 */
		public static function get TWO_PI():Number { return __TWO_PI; }
		private static var __TWO_PI:Number = 2 * Math.PI;
		
		/**
		 * Math constant pi.
		 */
		public static function get PI():Number { return __PI; }
		private static var __PI:Number = Math.PI;	
		
		/**
		 * Math constant pi/2.
		 */
		public static function get HALF_PI():Number { return __HALF_PI; }
		private static var __HALF_PI:Number = 0.5 * Math.PI;	
		
		/**
		 * Constant used to convert angle from radians to degrees.
		 */
		public static function get TO_DEGREE():Number { return __TO_DREGREE; }
		private static var __TO_DREGREE:Number = 180 /  Math.PI;
		
		/**
		 * Constant used to convert degrees to radians.
		 */
		public static function get TO_RADIAN():Number { return __TO_RADIAN; }
		private static var __TO_RADIAN:Number = Math.PI / 180;
		
		
		public static function toDegree ( p_nRad:Number ):Number
		{
			return p_nRad * TO_DEGREE;
		}
		
		/**
		 * Converts an angle from degrees to radians.
		 * 
		 * @param p_nDeg 	A number representing the angle in dregrees.
		 * @return 		The angle in radians.
		 */
		public static function toRadian ( p_nDeg:Number ):Number
		{
			return p_nDeg * TO_RADIAN;
		}
			
		// 取中间
		public static function constrain( p_nN:Number, p_nMin:Number, p_nMax:Number ):Number
		{
			return Math.max( Math.min( p_nN, p_nMax ) , p_nMin );
		}
		 
		
		public static function roundTo (p_nN:Number, p_nRoundToInterval:Number = 0):Number 
		{
			if (p_nRoundToInterval == 0) 
			{
				p_nRoundToInterval = 1;
			}
			//you can guess 282*0.0001 = ?
			//trace(282*0.0001+":"+282/10000);
			//return Math.round(p_nN/p_nRoundToInterval) * p_nRoundToInterval
			return Math.round(p_nN/p_nRoundToInterval) /Math.round(1 / p_nRoundToInterval);
			
		}
		
		public static function mins(a:Array = null,o:Number = 0):int
		{
			var _min:Number = 180;
			var _minPos = 0;
			var _minT:Number = 0; 
			for(var i = 0 ; i<a.length ; i++ ){
				_minT = Math.min(Math.abs(o-Number(a[i])),Math.abs(o-360-Number(a[i])));
				if(_minT < _min) {
					_minPos = i;
					_min = _minT;
				}
			}
			return _minPos;
		}
		
	}
}