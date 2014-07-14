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
	
	public class Wall3D extends Sprite
	{
		private var par:String = "wall.xml";
		private var allpic = [];
		private var msprite:Sprite;
		private var mload:Loader;
		private var ci:Number=0;

		private var index:int = 0;
		private var size:Number = 110;
		private var container:Sprite;
		private var pic:Sprite;
		private var page:int = 3;
		private var _nx:int = 5;
		private var _ny:int = 3;
		private var padding : int = 25;
		private var _width:Number = (size+padding)*_nx - padding;
		private var _height:Number = (size+padding)*_ny - padding;
		private var istween:Boolean = false;
		private var EIF:ExtraInterface;
		private var lq:LoaderQueue;
		private var layer:Sprite;
		private var background:Shape;
		
		private var hideFn:Function = null;
		private var sleep:Function = null;
		private var leftBtn:Sprite;
		private var rightBtn:Sprite;
		private var backBtn:Sprite;
		
		private var getConfig:Function;
		private var viewTo:Function;
		
		private var path:String = "";
		
		public function Wall3D()
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
			EIF.trace((new Date).toLocaleTimeString()+" : Loading Wall3D Plugin(Ver 1.0) Success ... ");
			
			if(EIF.ready) 
			{
				//layer = EIF.get("layer")();
				//layer.addChild(this);
				EIF.set("wall3Dstart",start);
				EIF.set("wall3Dstop",stop);
				EIF.set("wall3Dnext",next);
				EIF.set("wall3Dback",back);
				EIF.addPluginEventListener(ExtraInterface.PLUGINEVENT_REGISTER, this.registerEvent);
				
			}else
				loadConfig();
			
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
			hideFn = EIF.get("hideMenu");
			sleep = EIF.get("sleep");
			getConfig = EIF.get("getConfig");
			viewTo = EIF.get("viewTo");
			loadConfig();
		}
		
		private function processData():void
		{
			lq = new LoaderQueue();
			lq.addEventListener("EveryComplete",loadHandler,false,0,true);
			
			//if(EIF.ready) path = getConfig("wall3DPath")
			/*
			for(var k=0;k<1;k++)
				for(var i:int = 0; i<3; i++)
				{
					allpic[k*3+i] = [];
					for(var j=0;j<15;j++)
						allpic[k*3+i][j] = path +mypic[i*15 + j]+".jpg"
				};
				*/
		}
		
		private function loadConfig():void
		{
			if(EIF.ready) par = EIF.call("getPluginsConfig" , "wall3d").configpath;
			EIF.trace("load wall3d config XML : " + par) 
			var configUrlLoader:URLLoader = new URLLoader();
				configUrlLoader.addEventListener(Event.COMPLETE, configUrlLoaderComplete);
				configUrlLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				configUrlLoader.load(new URLRequest(par));
		}
		
		private function configUrlLoaderComplete(e)
		{
			var dataXml = new XML((e.target as URLLoader).data);
			path = dataXml.config.path;
			//trace(dataXml.nodes.node.length());
			for(var i=0,l=dataXml.nodes.node.length() ; i<l ; i++)
			{
				allpic.push( [ dataXml.nodes.node[i].@id ,path + dataXml.nodes.node[i].@url , dataXml.nodes.node[i] , dataXml.nodes.node[i].@poi] );
			}
			
			init();
		}
		
		private function ioErrorHandler(e):void
		{
			EIF.warn("Load wall3d config file error ! ")
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
			
			addChild(background);
			addChild(pic);
			addChild(backBtn);
			addChild(leftBtn);
			addChild(rightBtn);
			
			
			pic.x = 275;pic.y = 200
			draw();
			
			regListeners()
			
			processData()
			
			var row = Math.ceil(allpic.length%15);
			//trace(row)
			for(var i:int = 0; i<row ; i++)
			{	
				all[i] = []
				for(var j:int = 0 ; j<15; j++)
				{
					if(i*15+j < allpic.length)
					{
						var id:String = allpic[i*15+j][0]
						var t:Node = new Node(id,allpic[i*15+j][3]);
						//t.x= size*0.5 + (j%_nx)*(size+padding) ;
						//t.y= size*0.5 + Math.floor(j/5)*(size + padding);
						t.x= _width*-0.5 + size*0.5 + (j%_nx)*(size+padding) ;
						t.y= _height*-0.5 + size*0.5 + Math.floor(j/5)*(size + padding);
						t.z = -400;
						t.alpha = 0; t.visible = false; t.buttonMode = true;
						t.name = i+"_"+j;
					
						t.rotationY = Math.floor(360*Math.random());
						t.rotationX = Math.floor(360*Math.random())
					
						all[i][j] = (t.name);
					//trace("add:"+allpic[i*15+j][1])
					
						lq.add(allpic[i*15+j][1],t.name);
						container.addChild(t);
					}
					
					
				}
			}
			
			lq.start();
			
			if(!EIF.ready) start();
			//trace("ok")
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
			if(v.numChildren <2 )
				TweenMax.to(v,0.4,{z:-30,alpha:1});
		}
		
		private function out(e:MouseEvent):void {
			if(istween) return;
			var v = e.target;
	  		if(v.numChildren <2 )
				TweenMax.to(v,0.4,{z:0,alpha:0.35});
		}
	  
		private function clickHandler(e):void
		{
			//trace(e.target);
			var tar:Node = e.target as Node;
			
			if(viewTo) viewTo(tar.id , tar.poi);
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
				TweenMax.to(container,0.1,{rotationY:( pic.mouseX / stage.stageWidth )*-40,rotationX:( pic.mouseY / stage.stageHeight)*40 })
			// rotationX 变化（z） 会引起 container.mouseX  异常
			
		}
		
		private function resizeHandler(e):void
		{
			resize()
		}
		
			
		private function loadHandler(e:*):void
		{
			
			var name = e.target.name;
			var bmp = new Bitmap((e.target.target as Bitmap).bitmapData);
			bmp.x = bmp.y= size*-0.5;
			(container.getChildByName(name) as Sprite).addChild(bmp)
		}
		
		
		public function start():void
		{
			//stage.frameRate = 60;
			//stage.quality = "MEDIUM";
			stage.frameRate = 60;
			if(sleep) sleep(true);
			
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
				
				//hideFn(false);
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
			if( (index==0 && back) || (index == page-1 && !back)) return;
			var a = all[index] , b = all[(back?--index:++index)] , c = back?-400:800 , d = back?800:-400 ;
			
			leftBtn.visible = (index>0); rightBtn.visible = (index<page-1);
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
	
	internal class Node extends Sprite
	{
		public var id:String = "";
		public var poi:String = "";
		public function Node(v:String,v1:String){
			//this.graphics.lineStyle(1,0x985122,0.6);
			id = v; poi = v1;
		}
		
	}