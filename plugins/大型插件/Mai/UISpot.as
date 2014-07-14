package  {
	import pano.ui.*;
	import flash.display.Sprite;
	import flash.events.*;
	import pano.extra.ExtraInterface;
	import pano.utils.TweenNano;
	
	import flash.geom.*;
	
	public class UISpot extends Panel{
		
		private var s1:UILoaderPro;
		private var s2:UILoaderPro;
		
		private var padding:Number;
		private var size:Number;
		private var sizeHeight:Number = 80;
		private var EIF:ExtraInterface;
		private var _back:Sprite;
		
		public var ma : UILeft;
		
		public function UISpot(w:Number , h:Number , t:String,  e:UILeft , s : int = 120 , p:Number = 10) {
			padding = p; size = s;  ma = e ; EIF = ExtraInterface.getInstance();
			super(w , h ,t);
			
		}
		
		
		private function regListeners():void{
			//_contentContainer.addEventListener(MouseEvent.MOUSE_DOWN, MouseDownFun);
			//_head.addEventListener(MouseEvent.MOUSE_DOWN,MouseDownFun,false,0,true)
		}
		
		
		override protected function addChildren():void
		{
			s1 = new UILoaderPro(width,height-headHeight,"",true,size , padding);
			s2 = new UILoaderPro(width,height-headHeight,"",true,size , padding);
			setScaleCenter(s1)

			
			s2.alpha = 0; s2.visible = false;
			trace(s1.height+"<----------------------")
			super.addChildren();
			var t = new Sprite();
			t.addChild(s1) ; t.addChild(s2);
			
			_back = drawBtn();
			_back.x = 0; _back.y = _back.height/2 - 4;
			addChild(_back); _back.visible = false ; _back.alpha = 0;
			
			setContent(t);
			
			s1.addEventListener(DataEvent.DATA,s1Handler,false,0,true);
			s2.addEventListener(DataEvent.DATA,s2Handler,false,0,true);
			_back.addEventListener(MouseEvent.CLICK,backBtnHandler,false,0,true);
			
		}
		
		private function setScaleCenter(v)
		{
			v.transform.matrix3D = null
			var p = new PerspectiveProjection()
			p.projectionCenter = new Point(v.width*0.5,v.height*0.5)
			v.transform.perspectiveProjection = p;
		}
		
		private function drawBtn(v:Boolean = true):Sprite
		{
			var t = new Sprite();
			t.buttonMode = true;
			t.graphics.beginFill(0xffffff,0);
			//t.graphics.lineStyle(2,0xffffff);
			t.graphics.drawCircle(0,0,20);
			t.graphics.endFill();
			
			var isleft = v?-1:1;
			var path = [[-9,-16],[-1,-16],[13,0],[-1,16],[-9,16],[4,0],[-9,-16]];
			t.graphics.lineStyle(0,0,0);
			for(var k:int = 1 ; k>=0; k--)
			{
				var p = k*-6*isleft;
				if(k){
					//t.graphics.lineStyle(2,0,0.2);
					t.graphics.beginFill(0,0.2);
				}else
				{
					//t.graphics.lineStyle(2,0xffffff);
					t.graphics.beginFill(0xffffff);
				}
				
				t.graphics.moveTo(path[0][0]*isleft + p,path[0][1]*isleft);
				for(var i:int = 1 ; i<path.length ; i++)
					t.graphics.lineTo(path[i][0]*isleft + p,path[i][1]*isleft);
				t.graphics.endFill();
			}
			
			
			return t
		}
		
		private function backBtnHandler(e:MouseEvent):void
		{
			TweenNano.to(_back ,0.6 , {autoAlpha : 0 , x : 0});
			TweenNano.to(s1,0.5,{autoAlpha:1 ,z:0 , onComplete:returnToList});
			TweenNano.to(s2,0.6,{autoAlpha:0})
			
		}
		
		private function s1Handler(e:DataEvent):void
		{
			trace(s1.z);
			loadList(ma.data[e.data].nodes);
			TweenNano.to(s1,0.5,{autoAlpha:0 , z : -200});
			TweenNano.to(s2,0.6,{autoAlpha:1})

		}
		
		private function returnToList():void
		{
			 setScaleCenter(s1);
			 s2.clear();
		}
		
		private function s2Handler(e:DataEvent):void
		{
			ma.loadPano(e.data.split("_"))
			//if(EIF.ready) trace("")
		}
		
		
		public function loadType(v):void
		{
			s1.load(v);
		}
		
		public function loadList(v):void
		{
			s2.load(v); ma.loadList(v);
			TweenNano.to(_back ,0.6 , {autoAlpha : 1 , x : width - _back.width/2});
			
		}
		
		public function get id():String
		{
			return s1.id;
		}
		
		override public function set height(v:Number):void
		{
			super.height = v;
			s1.height = v - headHeight;
			s2.height = v - headHeight;
		}
	}
	
}
