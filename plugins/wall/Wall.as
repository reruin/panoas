package {
	import flash.system.Security;
	import flash.display.*;
	import flash.events.*;
	import flash.net.URLRequest;
	import flash.geom.*;
	import com.greensock.TweenMax;
	import fl.motion.easing.*;
	import flash.text.TextField;
	import pano.utils.LoaderQueue;
	import pano.ExtraInterface;

	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	
	public class Wall extends Sprite
	{
		private var allpic = [];
		private var msprite:Sprite;
		private var mload:Loader;
		
		private var index:int = 0;
		private var tile_width:int;
		private var tile_height:int;
		private var container:Sprite;
		private var pic:Sprite;
		private var page_size:int;
		private var page_num:int;
		private var _nx:int;
		private var _ny:int;
		private var padding : int;
		private var _width:Number = 1;
		private var _height:Number = 1;
		private var istween:Boolean = false;
		private var EIF:ExtraInterface;
		private var lq:LoaderQueue;
		private var layer:Sprite;
		private var background:Shape;
		
		private var leftBtn:Sprite;
		private var rightBtn:Sprite;
		private var backBtn:Sprite;
		
		
		private var path:String = "";
		
		public function Wall()
		{
			Security.allowDomain("*");
			
			
			if (stage == null)
			{
				this.addEventListener(Event.ADDED_TO_STAGE, this.startPlugin);
				this.addEventListener(Event.REMOVED_FROM_STAGE, this.stopPlugin);
			}else
			{
				startPlugin();
				//start();
			}
		}
	
		private function startPlugin(e:Event = null):void
		{
			this.alpha = 0;this.visible = false; stage.showDefaultContextMenu = false;
			
			EIF = ExtraInterface.getInstance();
			EIF.trace((new Date).toLocaleTimeString()+" : Loading Wall(mini) Plugin(Ver 1.20140508) Success ... ");
			
			if(EIF.ready) 
			{
				//layer = EIF.get("layer")();
				//layer.addChild(this);
				EIF.set("wallstart",start);
				EIF.set("wallstop",stop);
				EIF.set("wallnext",next);
				EIF.set("wallback",back);
				EIF.addPluginEventListener(ExtraInterface.PLUGINEVENT_REGISTER, this.registerEvent);
				
			}
			
		}
		
		private function stopPlugin(e):void
		{
			lq.clear();
			for(var i:int = container.numChildren - 1 ; i>=0 ; i-- )
			{
				container.removeChildAt(i);
			}
		}
		
		private function registerEvent(e)
		{
			loadConfig();
		}
		

		private function loadConfig():void
		{
			
			var k:Object = EIF.call("getRoads");
			
			for(var i in k)
			{
				allpic.push( [ k[i].start ,k[i].thumb , k[i].title] );
			}
			
			tile_width  = EIF.call("getPluginsConfig" , "wall")["tile_width"] || 250;
			tile_height = EIF.call("getPluginsConfig" , "wall")["tile_height"] || 180;
			_nx = EIF.call("getPluginsConfig" , "wall")["tile_num_x"] || 3;
			_ny = EIF.call("getPluginsConfig" , "wall")["tile_num_y"] || 3;
			padding = EIF.call("getPluginsConfig" , "wall")["padding"] || 30;
			_width  = (tile_width+padding)*_nx - padding;
			_height = (tile_height+padding)*_ny - padding;
			page_size = _nx * _ny;
			page_num = Math.ceil(allpic.length/page_size);
			init();
		}
		
		
		private var all:Array = [];
		
		
		private function init():void
		{
			container = new Sprite();
			pic = new Sprite();
			background = new Shape();
			leftBtn = drawBtn()
			rightBtn = drawBtn(false);
			backBtn = drawBackBtn();
			leftBtn.visible = false;
			leftBtn.alpha = rightBtn.alpha = backBtn.alpha = 0.5;
			leftBtn.cacheAsBitmap = rightBtn.cacheAsBitmap = true;
			
			pic.addChild(container);
			
			lq = new LoaderQueue();
			lq.addEventListener("EveryComplete",loadHandler,false,0,true);
			
			addChild(background);
			addChild(pic);
			addChild(backBtn);
			addChild(leftBtn);
			addChild(rightBtn);
			
			//大容器居中
			pic.x = 275;pic.y = 200;
			
			draw();
			
			regListeners()
			
			//processData()
			
			//trace(row)
			for(var i:int = 0; i<page_num ; i++)
			{	
				all[i] = []
				for(var j:int = 0 ; j<page_size; j++)
				{
					if(i*page_size+j < allpic.length)
					{
						var id:String = allpic[i*page_size+j][0]
						var t:Node = new Node(id,allpic[i*page_size+j][2] ,tile_width , tile_height );
						//t.x= size*0.5 + (j%_nx)*(size+padding) ;
						//t.y= size*0.5 + Math.floor(j/5)*(size + padding);
						t.x= _width*-0.5  + (j%_nx)*(tile_width+padding) ;
						t.y= _height*-0.5 + Math.floor(j/_nx)*(tile_height + padding);
						t.z = -400;
						t.alpha = 0; t.visible = false;
						t.buttonMode = true;
						t.name = i+"_"+j;
					
						t.rotationY = Math.floor(360*Math.random());
						t.rotationX = Math.floor(360*Math.random())
					
						all[i][j] = (t.name);
					//trace("add:"+allpic[i*15+j][1])
					
						lq.add(allpic[i*page_size+j][1],t.name);
						container.addChild(t);
					}
					
					
				}
			}
			
			lq.start();
			
			if(!EIF.ready) start();
			//trace("ok")
		}
		
					
		private function loadHandler(e:*):void
		{
			
			var name = e.target.name;
			var bmp = new Bitmap((e.target.target as Bitmap).bitmapData);
			bmp.width = tile_width; bmp.height = tile_height;
			(container.getChildByName(name) as Sprite).addChildAt(bmp,0)
		}
		
		
		private function regListeners():void
		{
			container.addEventListener(MouseEvent.MOUSE_OVER,over);
			container.addEventListener(MouseEvent.MOUSE_OUT,out);
			
			container.addEventListener(MouseEvent.CLICK,clickHandler);
			stage.addEventListener(Event.RESIZE, resizeHandler,false,0,true);

			leftBtn.addEventListener(MouseEvent.MOUSE_OVER,overBtnHandler);
			rightBtn.addEventListener(MouseEvent.MOUSE_OVER,overBtnHandler);
			backBtn.addEventListener(MouseEvent.MOUSE_OVER,overBtnHandler);
			
			leftBtn.addEventListener(MouseEvent.MOUSE_OUT,outBtnHandler);
			rightBtn.addEventListener(MouseEvent.MOUSE_OUT,outBtnHandler);
			backBtn.addEventListener(MouseEvent.MOUSE_OUT,outBtnHandler);
			
			leftBtn.addEventListener(MouseEvent.CLICK,clickLeftBtnHandler);
			rightBtn.addEventListener(MouseEvent.CLICK,clickRightBtnHandler);
			backBtn.addEventListener(MouseEvent.CLICK,clickBackBtnHandler);
		}
		
		private function draw():void
		{
			background.graphics.clear();
			background.graphics.beginFill(0,0.9);
			//background.graphics.lineStyle(10,0xff0000);
			background.graphics.drawRect(0,0,stage.stageWidth,stage.stageHeight);
			//stage.stageWidth*-0.5,stage.stageHeight*-0.5
			
		}
		private function drawBackBtn():Sprite
		{
			var t = new Sprite();
			t.buttonMode = true;
			t.graphics.beginFill(0xffffff,0);
			t.graphics.lineStyle(2,0xffffff);
			//t.graphics.drawCircle(0,0,30);
			t.graphics.endFill();
			var path = [[9,-16],[1,-16],[-15,0],[1,16],[9,16],[-3,3],[25,3],[25,-3],[-3,-3],[9,-16]];
			t.graphics.lineStyle(0,0,0);
			for(var k:int = 1 ; k>=0; k--)
			{
				var p = k*6;
				if(k){
					
					t.graphics.beginFill(0,0.2);
				}else
				{
					
					t.graphics.beginFill(0xffffff);
				}
				t.graphics.moveTo(path[0][0] + p,path[0][1]);
				for(var i:int = 1 ; i<path.length ; i++)
					t.graphics.lineTo(path[i][0] + p,path[i][1]);
				t.graphics.endFill();
			}
			
			return t;
		}
		
		private function drawBtn(v:Boolean = true):Sprite
		{
			var t = new Sprite();
			t.buttonMode = true;
			t.graphics.beginFill(0xffffff,0);
			t.graphics.lineStyle(2,0xffffff);
			t.graphics.drawCircle(0,0,30);
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
				
		private function clickLeftBtnHandler(e):void
		{
			back();
		}
		
		private function clickRightBtnHandler(e):void
		{
			next();
		}
		
		private function clickBackBtnHandler(e):void
		{
			stop();
		}
		
		private function over(e:MouseEvent):void {
			if(istween) return;
			var v = e.target;
			if(v is Node) {TweenMax.to(v,0.4,{z:-60,alpha:1});(v as Node).hover(true)}
		}
		
		private function out(e:MouseEvent):void {
			if(istween) return;
			var v = e.target;
	  		if(v is Node){
				TweenMax.to(v,0.4,{z:0,alpha:0.55});
				(v as Node).hover(false)
			}
		}
	  
		private function clickHandler(e):void
		{
			//trace(e.target);
			var tar:Node = e.target as Node;
			
			//if(viewTo) viewTo(tar.id , "");
			EIF.call("viewTo",tar.id , "")
			stop();
		}
		
		private function overBtnHandler(e:MouseEvent):void
		{
			TweenMax.to(e.target,0.5,{alpha:1})
		}

		private function outBtnHandler(e:MouseEvent):void
		{
			TweenMax.to(e.target,0.5,{alpha:0.5})
		}
		
		private function loop(e:Event)
		{
			if(this.visible = true)
				TweenMax.to(container,0.1,{rotationY:( pic.mouseX / stage.stageWidth )*-20,rotationX:( pic.mouseY / stage.stageHeight)*20 })
			// rotationX 变化（z） 会引起 container.mouseX  异常
			
		}
		
		private function resizeHandler(e):void
		{
			resize()
		}
		

		
		public function start():void
		{
			//stage.frameRate = 60;
			//stage.quality = "MEDIUM";
			stage.frameRate = 60;
			EIF.call("sleep",true);
			
			setFixed(fixmode);
			//stage.addEventListener(MouseEvent.MOUSE_MOVE,loop);
			
			//resize();
			var b = all[index];
			for(var i:int = 0 ; i<b.length ; i++)
			{
				TweenMax.to(container.getChildByName(b[i]),1,{rotationX:0, rotationY:0 , z:0 , autoAlpha:0.5 ,onComplete:function(){istween = false}})
			}
			TweenMax.to(this,1,{autoAlpha:1});
			
			//if(rendererFn) rendererFn();
			resize();
		}
		
		public function stop():void{
			
			stage.frameRate = 45;
			stage.removeEventListener(MouseEvent.MOUSE_MOVE,loop);
			var a = all[index]
			for(var i:int = 0; i<a.length ; i++)
			{
				TweenMax.to(container.getChildByName(a[i]),1,{rotationX:Math.floor(360*Math.random()) , rotationY:Math.floor(360*Math.random()) , z:-400 , autoAlpha:0 })
			}
			TweenMax.to(this,1,{autoAlpha:0});
			if(EIF.ready)
			{
				EIF.call("sleep",false);
			}
		}
		
		public function back():void
		{
			switchWall(true);
		}
		
		public function next():void
		{
			switchWall();
		}
		
		private function clear():void
		{
			for(var i:int = 0 ; i<all.length ; i++)
				container.removeChild(all[i]);
			all = [];
		}

		
		private function switchWall(back:Boolean = false , init:Boolean = false):void
		{
			//clear();
			istween = true;
			
			//trace("rightBtn.visible:"+rightBtn.visible)
			if( (index==0 && back) || (index == page_num-1 && !back)) return;
			var a = all[index] , b = all[(back?--index:++index)] , c = back?-400:800 , d = back?800:-400 ;
			
			leftBtn.visible = (index>0); rightBtn.visible = (index<page_num-1);
			EIF.trace((page_num-1)+":"+index)
			//if(init) {a = [] ; b = all[0]; index = 0}
			for(var i:int = 0; i<a.length ; i++)
			{
				TweenMax.to(container.getChildByName(a[i]),1,{rotationX:Math.floor(360*Math.random()) , rotationY:Math.floor(360*Math.random()) , z:c , autoAlpha:0 })
			}
			
			for(var i:int = 0 ; i<b.length ; i++)
			{
				TweenMax.to(container.getChildByName(b[i]),1,{rotationX:0, rotationY:0 , z:0 , autoAlpha:0.5 ,onComplete:function(){istween = false}})
			}
			
		}
		
		private var fixmode = false;
		public function setFixed(v:Boolean = false):void
		{
			fixmode = v;
			if(fixmode)
				stage.removeEventListener(MouseEvent.MOUSE_MOVE,loop);
			else
				stage.addEventListener(MouseEvent.MOUSE_MOVE,loop);
			
		}
		
		public function resize():void
		{
			
			draw();
			var viewportWidth = this.stage.stageWidth;
			var viewportHeight = this.stage.stageHeight;
			
			
			var p = new PerspectiveProjection()
			p.projectionCenter = new Point((viewportWidth)*0.5,(viewportHeight)*0.5)
			this.transform.perspectiveProjection = p;

			pic.x = (viewportWidth)*0.5;
			pic.y = (viewportHeight)*0.5
			
			leftBtn.x = leftBtn.width * 0.5;
			rightBtn.x = viewportWidth - rightBtn.width;
			leftBtn.y = rightBtn.y  = viewportHeight/2;
			backBtn.y = backBtn.height;
			backBtn.x = rightBtn.x// 4 + backBtn.height;
			
		}
	}
}


	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.*;
	import pano.utils.TweenNano;
	internal class Node extends Sprite
	{
		public var id:String = "";
		public var title:String = "";
		private var _head:Sprite;
		private var _borderColor:uint = 0xffffff;
		private var _headHeight:int = 24;
		private var _headTitleSize:int = 16;
		private var _headTitleColor:uint = 0xfafafa;
		private var _width:int = 1;
		private var _height:int = 1;
		private var _headTitle:TextField;
		public function Node(v:String,v1:String,w:int , h:int){
			_width = w;_height = h;;
			id = v; title = v1;
			drawHead();
			drawTitle();
			addChild(_head);
			_head.alpha = 0;
			_head.addChild(_headTitle);
			
			_headTitle.y = (_height - _headTitle.textHeight)/2;
			_headTitle.x = (_width - _headTitle.textWidth) / 2;
			this.mouseChildren = false;
		}
		
		
		private function drawHead(){
			_head = new Sprite();
			_head.graphics.clear()
			_head.graphics.beginFill(0,0.6);
			_head.graphics.lineStyle(2,0xffffff);
			_head.graphics.drawRect(0, 0, _width, _height);
			_head.graphics.endFill();
			
			
			//_head.buttonMode = true;
		}
		
		private function drawTitle():void
		{
			_headTitle  = new TextField();
			_headTitle.autoSize = TextFieldAutoSize.LEFT;
			_headTitle.multiline = false;
			_headTitle.wordWrap = false;
			_headTitle.defaultTextFormat = new TextFormat("simhei", _headTitleSize,  _headTitleColor);
			_headTitle.text = title;
		}
		
		public function hover(v:Boolean){
			if(v)
			{
				TweenNano.to(_head,0.6,{alpha:1});
				
			}else
				TweenNano.to(_head,0.6,{alpha:0});
		}
		
	}