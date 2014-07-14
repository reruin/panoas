package pano.object{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;;
	
	import org.papervision3d.objects.primitives.Sphere;
	import org.papervision3d.objects.primitives.Cylinder;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.materials.utils.BitmapMaterialTools;
	import org.papervision3d.core.math.Number3D;

	public class Sphere3D extends DisplayObject3D
	{
		private var sW:Number = 1;
		
		private var bmdW:Number;
		
		private var bmdH:Number;
		
		private var TileW:Number;
		
		private var TileH:Number;
		
		public var autoMirrorX:Boolean = true;
		
		public var radius:Number = 4096;
		
		private var des:int;
		
		public var _sphere:Sphere;
		
		public function Sphere3D(r:Number = 4096 , w:int = 1,h:int = 1,_des:int = 24) //Use for Tile
		{
			bmdW = r; des = _des;
			bmdH = r/2;
			TileW = bmdW/w;
			TileH = bmdH/h;
			build();
		}
	
		public function destroy():void
		{
			_sphere.material.bitmap.dispose();
			_sphere.material.destroy();
			this.removeChild(_sphere)
			
		}
		private function build()
		{
			var _bmd:BitmapData  = new BitmapData(bmdW,bmdH,false,0x000000);
			var _material = new BitmapMaterial(_bmd);
				_material.smooth = true;
				_material.opposite = true;
			
			_sphere = new Sphere(_material,radius, des*2, des);
			//_sphere = new Cylinder(_material,5000,12800,24,24,-1,false,false);
			this.addChild(_sphere);
		}
		
		public function set mat(bmd:BitmapData)
		{

			var nW = bmd.width;
			var nH = bmd.height;
			
			_sphere.material.bitmap.draw(bmd,new Matrix(bmdW/nW,0,0,bmdH/nH,0,0),null,null,null,true);
			bmd.dispose();
			bmd = null;
		}
		
		public function get mat()
		{
			return (_sphere.material.bitmap) as BitmapData;
		}
		
		public function set sphereRot(r:Number)
		{
			_sphere.rotationY = r;
		}
		
		public function get sphereRot()
		{
			return _sphere.rotationY;
		}
		
		
		
		public function swapTile(bmd:BitmapData,ix,iy)
		{
			var rectFrom:Rectangle = new Rectangle(0, 0, TileW, TileH);
			
			//use in  mirrorX 
			var PointTo:Point = new Point((sW-ix-1)*TileW, iy*TileH);
			
			// copyPixels isn't draw，set correct Tile's width and height
			_sphere.material.bitmap.copyPixels(bmd, rectFrom, PointTo);
		}
		
		public function crossTo(p1:Number3D,p2:Number3D):Number3D
		{
			var pc1:Number3D;
			var pc2:Number3D;
			var r:Number = radius;
			
			var ps:Number3D = this.position;
			
			var i:Number = p2.x - p1.x;
			var j:Number = p2.y - p1.y;
			var k:Number = p2.z - p1.z;

			var a:Number = i * i + j * j + k * k;

			var b:Number = 2.0 * ( i * ( p1.x - ps.x ) + j * ( p1.y - ps.y ) + k * ( p1.z - ps.z) );

			var c:Number = ps.x * ps.x + ps.y * ps.y + ps.z * ps.z + p1.x * p1.x + p1.y * p1.y + p1.z * p1.z - 2.0 * ( ps.x * p1.x + ps.y * p1.y + ps.z * p1.z ) - r * r;

			var d:Number = b * b - 4 * a * c;


			var t0:Number = ( (a > -0.0000001 && a < 0.0000001 ) ? 0.0 : (-b + Math.sqrt(d)) / (2.0 * a) );
			var t1:Number = ( (a > -0.0000001 && a < 0.0000001 ) ? 0.0 : (-b - Math.sqrt(d)) / (2.0 * a) );

			pc1 = new Number3D(p1.x + t0 * i , p1.y + t0 * j , p1.z + t0 * k);
			pc2 = new Number3D(p1.x + t1 * i , p1.y + t1 * j , p1.z + t1 * k);
			
			if(Number3D.sub(pc1,p1).modulo > Number3D.sub(pc2,p1).modulo)
				return pc1;
			else
				return pc2;
		}
		
		public function init()
		{
			this.rotationX = this.rotationY = 0;
			_sphere.rotationX = _sphere.rotationY = 0;
		}

	}
}