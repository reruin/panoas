package pano.controls   {
	
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.display.Shape;
	import flash.geom.Point;
	
	import flash.utils.*;
	public class Kinetic extends EventDispatcher{
		
		private var threshold:Number = 0;
    	private var deceleration:Number =  0.001;
    	private var nbPoints:int = 100;
    	private var delay:int = 200;
    	private var points:Array;
		
		protected static var _shape:Shape = new Shape(); 
		
		public function Kinetic() {
			// constructor code
			this.points = [];
		}
		
		public function begin(){
			//soul.Animation.stop(this.timerId);
        	//this.timerId = undefined;
        	this.points = [];
			 _shape.removeEventListener(Event.ENTER_FRAME, loop);
		}
		
		public function update(xy:Point){
			this.points.unshift({xy: xy, tick: getTimer()});
        	if (this.points.length > this.nbPoints) {
  				this.points.pop();
        	}
			
		}
		
				
		private var v0:Number;
		private var initialTime:Number;
		private var lastX:Number;
		private var lastY:Number;
		private var oud:Function
		private var fx:Number;
		private var fy:Number;
		
		public function end(xy:Point , fn:Function){
			var last, now:Number = getTimer();
        	for (var i:int = 0, l:int = this.points.length, point; i < l; i++)
			{
           		point = this.points[i];
            	if (now - point.tick > this.delay) {
                	break;
            	}
            	last = point;
       	 	}
			
        	if (!last)  return;
			
        	var time:Number = getTimer() - last.tick
        	,dist = Math.sqrt(Math.pow(xy.x - last.xy.x, 2) +  Math.pow(xy.y - last.xy.y, 2));
        	var speed:Number = dist / time;
        	if (speed == 0 || speed < this.threshold) { return; }
			
        	var theta:Number = Math.asin((xy.y - last.xy.y) / dist);
			//trace( 1+":"+theta )
        	if (last.xy.x > xy.x) theta = Math.PI - theta;
        	//trace(  1+":"+theta )
			//trace(speed); 
			
			this.deceleration = 0.4 * speed / time;
			
			v0 = speed ;  fx = Math.cos(theta) ; fy = Math.sin(theta);

			initialTime = getTimer() ;
			lastX = xy.x;
			lastY = xy.y;
			oud = fn;
			
			_shape.addEventListener(Event.ENTER_FRAME, loop, false, 0, true);
		}

		
		private function loop(e:Event = null)
		{
				var t:Number = getTimer() - initialTime;
				
				//v*t + a*t^2/2
				var p:Number = (-this.deceleration * t * t) / 2.0 + v0 * t;
				//trace(p)
				var dx = p * fx;
				var dy = p * fy;

				var args = {end : false};

				var v = -this.deceleration * t + v0;
				
				if (v <= 0) {
				   _shape.removeEventListener(Event.ENTER_FRAME, loop);
					//this.timerId = null;
					args.end = true;
				}

				args.x = dx + lastX;
				args.y = dy + lastY;
				//lastX = dx;
				//lastY = dy;
				
				oud.apply(null, [args.x, args.y, args.end]);
		}

		
	}
	
}
