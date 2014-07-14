package  {
	import flash.system.Security;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.filters.GlowFilter;
	import pano.ExtraInterface;
	import pano.utils.TweenNano;
	import flash.net.FileReference;
	import com.adobe.images.PNGEncoder;
	import flash.net.*;
	
	public class Soulbar extends Sprite {
		
		private static const DOWN:String = "mousedown";
        private static const OVER:String = "mouseover";
        private static const UP:String = "mouseup";
		private static const OUT:String = "mouseout";
		private static const CLICK:String = "click";
		
		private var _shutterSound:shutterSound;
		
		private var EIF:ExtraInterface;
		private var back:Shape
		private var backInfo:Object;
		private var skin:BitmapData;
		private var actions:Object;;
		private var gather:Object;
		private var _width:Number = 0;
		private var _height:Number = 0;
		
		private var weiboUrl:String = "http://service.weibo.com/share/share.php?url={url}&title={title}&source=&sourceUrl=&content=utf-8&pic={image}";
		/*
		0 1 2
		3 4 5
		6 7 8
		*/
	
		private var defaultConfig:String = '<controlbar usehead="false" name="skin_control_bar" crop="2|0|60|12" keep="true" type="container" bgcolor="0x000000" bgalpha="0.5" align="6" width="100%" height="40" x="0" y="20" y_opened="20" y_closed="-42" zorder="3">'
		//+'<layer name="btmborder" crop="2|52|60|12"   align="0" width="100%" height="12" x="0" y="0" enabled="false" />'
		//+'<layer name="topborder" crop="2|0|60|12" align="6" width="100%" height="12" x="0" y="0" enabled="false" />'
		//+'<layer name="prev" crop="0|64|64|64"   align="0"      x="5"    y="4"   scale="0.5" alpha="0.5" onclick="skin_nextscene(-1);" ondown="skin_buttonglow(get(name));" onup="skin_buttonglow(null);" />'
		//+'<layer name="weibo" crop="64|0|64|64"   align="0"   tips="分享"   x="5"    y="4"   scale="0.5" alpha="0.5" onclick="skin_nextscene(-1);" ondown="skin_buttonglow(get(name));" onup="skin_buttonglow(null);" />'
		+'<layer name="quit" crop="64|832|64|64"   align="0"   tips="退出"   x="5"    y="4"   scale="0.5" onclick="quit" />'
		//+'<layer name="nav" crop="0|128|64|64"  align="0"  	 tips="导航图"  x="5"   y="4"   scale="0.5" ondown="glow(get(name)); skin_showmap(false); skin_showthumbs();" onup="skin_buttonglow(null);" />'
		+'<layer name="camera" crop="0|896|64|64"  align="0"  	 tips="拍照"  x="50"   y="4"   scale="0.5" onclick="snapshot" />'
		
		//+'<layer name="map"  crop="64|128|64|64" align="0"  	  x="90"   y="4"   scale="0.5" ondown="glow(get(name)); skin_showthumbs(false); skin_showmap();" onup="skin_buttonglow(null);" visible="true" />'
		+'<layer name="left"   crop="0|192|64|64"  align="1"   tips="向左"   x="-100" y="4"   scale="0.5" onmousedown="setPano,toLeft" onmouseup="killpanoanimat" />'
		+'<layer name="right"   crop="64|192|64|64" align="1"  tips="向右"    x="-60"  y="4"   scale="0.5" onmousedown="setPano,toRight" onmouseup="killpanoanimat" />'
		+'<layer name="up"   crop="0|256|64|64"  align="1"    tips="向上"  x="-20"  y="4"   scale="0.5" onmousedown="setPano,toUp" onmouseup="killpanoanimat" />'
		+'<layer name="down"   crop="64|256|64|64" align="1"   tips="向下"   x="+20"  y="4"   scale="0.5" onmousedown="setPano,toDown" onmouseup="killpanoanimat" />'
		+'<layer name="in"   crop="0|320|64|64"  align="1"    tips="放大"  x="+60"  y="4"   scale="0.5" onmousedown="setPano,zoomIn" onmouseup="killpanoanimat" />'
		+'<layer name="out"   crop="64|320|64|64" align="1"   tips="缩小"   x="+100" y="4"   scale="0.5" onmousedown="setPano,zoomOut" onmouseup="killpanoanimat" />'
		//+'<layer name="skin_btn_gyro" crop="0|384|64|64"  align="1"  tips=""    x="140"  y="4"   scale="0.5" ondown="skin_buttonglow(get(name)); skin_showmap(false);" onclick="switch(plugin[skin_gyro].enabled);" onup="skin_buttonglow(null);" visible="false" devices="HTML5" />'
		//+'<layer name="full"   crop="0|576|64|64"  align="1"      x="140"  y="4"   scale="0.5" ondown="skin_buttonglow(get(name));" onup="skin_buttonglow(null);" onclick="switch(fullscreen);" devices="fullscreensupport" />'
		+'<layer name="full"   crop="0|576|64|64"  align="2"   tips="全屏"    x="5"  y="4"   scale="0.5" onclick="fullscreen" />'
		//+'<layer name="next" crop="64|64|64|64"  align="2"       x="5"    y="4"   scale="0.5" alpha="0.5" onclick="skin_nextscene(+1);" ondown="skin_buttonglow(get(name));" onup="skin_buttonglow(null);" />'
		+'<layer name="hide" crop="0|448|64|64"  align="2"  tips="隐藏工具栏"     x="50"   y="4"   scale="0.5" onclick="soulbarToggle" />'
		+'<layer name="show" crop="64|448|64|64" align="2"  tips="显示工具栏"     x="5"    y="-36" scale="0.5" visible="false" onclick="soulbarToggle" />'
	+'</controlbar>';
		//public var 
		
		private var config:XML
		public function Soulbar() {
			
			Security.allowDomain("*");

			if (stage == null)
			{
				this.addEventListener(Event.ADDED_TO_STAGE, this.startPlugin);
				this.addEventListener(Event.REMOVED_FROM_STAGE, this.stopPlugin);
			}else
			{
				startPlugin();
			}
		}
		
		private function startPlugin(e:Event = null):void
		{
			
			stage.showDefaultContextMenu = false;
			EIF = ExtraInterface.getInstance();
			if(EIF.ready) 
			{
				var k:String = (new Date).toLocaleTimeString()+" : Loading SoulBar(Ver 1.20140508) Plugin Success ... ";
				init();
				EIF.addPluginEventListener(ExtraInterface.PLUGINEVENT_REGISTER, this.registerEvent);
				EIF.set("setHead",setHead);
				EIF.set("infoToggle",infoToggle);
				EIF.set("infoShow",infoShow);
				EIF.set("soulbarToggle",toggle);
				EIF.set("quit",quit);
				EIF.set("snapshot",getPhoto);
				EIF.set("weibo",getWeibo);
			}
			
			this.removeEventListener(Event.ADDED_TO_STAGE, this.startPlugin);
		}

		private function stopPlugin(e):void { }
		
		private function registerEvent(e):void {
			
		}
		
		private var _head:Head;
		private var useHead:Boolean = false;
		public function setHead(h:String,c:String):void
		{
			
			if(_head) {_head.setContent(h,c);}
		}
		
		public function infoToggle():void
		{
			if(_head) {
				if(_head.visible) TweenNano.to(_head,0.6 , {autoAlpha:0})
				else TweenNano.to(_head,0.6 , {autoAlpha:1})
			}
		}
		
		private function init():void{
			
			var b:String = EIF.call("getPluginsConfig" , "soulbar").value;
			if(b=="" || b==null) b = defaultConfig;
			config = new XML(b);
			
			
			skin = new bar(); gather = new Object(); _shutterSound = new shutterSound();
			
			back = new Shape();addChild(back);
			back.filters = [new GlowFilter(0xfafafa,0.4,2,2)]
			
			parseXML(); //this.filters = [new GlowFilter(0x000000,0.5,32,32,2,1)];
			regListeners();
			resize();
			
			if(useHead){
				_head = new Head();
				addChild(_head);
			}
			resize();
		}
		
		private function parseXML():void{
			backInfo = {crop: (config.@crop).toString().split("|"), color : uint(config.@bgcolor.toString()) , alpha : Number(config.@bgalpha.toString()) , align:config.@align.toString() , width : config.@width , height:config.@height, x: config.@x , y:config.@y}
			useHead = (config.@usehead).toString() == "true" ? true : false
			for(var i:int = 0 , l=config.layer.length() ;i<l ; i++)
			{
				var title:String = config.layer[i].@name;
				var crop:Array = (config.layer[i].@crop).toString().split("|");
				//var isshape = config.layer[i].@enable.toString() != "false";
				//for(var i:int =0;i<4;i++) crop[i] = int(crop[i]);
				
				gather[title] = {
					obj : creat(crop) ,
					offset : new Point(parseInt(config.layer[i].@x) , parseInt(config.layer[i].@y) ), 
					width : config.layer[i].@width ,
					scale : config.layer[i].@scale ,
					align: config.layer[i].@align.toString() ,
					visible : config.layer[i].@visible.toString() != "false",
					action : title,
					tips : config.layer[i].@tips.toString(),
					ident : "",
					events:{"click":config.layer[i].@onclick.toString() , "mousedown":config.layer[i].@onmousedown.toString() , "mouseup":config.layer[i].@onmouseup.toString(),"mouseover":config.layer[i].@onmouseover.toString(),"mouseout":config.layer[i].@onmouseout.toString()}
				}
				gather[title].obj.scaleX = gather[title].obj.scaleY = Number(config.layer[i].@scale);
				gather[title].obj.name = title;
				
				addChild(gather[title].obj);
				
			}
			
		}
		
		private function creat(c , isshape:Boolean = false):Sprite{
			var bmp = new Bitmap(new BitmapData(c[2],c[3],true,0));
			//bmp.bitmapData.copyPixels(skin , new Rectangle(0,0,int(c[2]),int(c[3])) , new Point(int(c[0]),int(c[1])))
			//bmp.bitmapData.draw(skin as BitmapData,new Matrix(1,0,0,1,c[0],c[1]),null,null,new Rectangle(0,0,c[2],c[3]),true);
			bmp.bitmapData.draw(skin,new Matrix(1,0,0,1,0-int(c[0]),0-int(c[1])),null,null,new Rectangle(0,0,c[2],c[3]),true);
			var k = new Sprite();
			k.addChild(bmp)
			return k;
		}
		
		private function regListeners():void{
			addEventListener(MouseEvent.MOUSE_OVER, handleMouseOver, false, 0, true);
            addEventListener(MouseEvent.MOUSE_OUT, handleMouseOut, false, 0, true);
            addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown, false, 0, true);
            addEventListener(MouseEvent.MOUSE_UP, handleMouseUp, false, 0, true);
			addEventListener(MouseEvent.CLICK , handleMouseClick , false , 0 , true)
			this.addEventListener(Event.ADDED_TO_STAGE, this.startPlugin);
            stage.addEventListener(Event.RESIZE, resize,false,0,true);
		}
		
		private function handleMouseClick(event:MouseEvent):void
		{
			 setState(event.target,CLICK);
		}
		
		private function handleMouseOver(event:MouseEvent) : void
        {
            setState(event.target,OVER);
        }

        private function handleMouseOut(event:MouseEvent) : void
        {
            setState(event.target,OUT);
        }

        private function handleMouseUp(event:MouseEvent) : void
        {
            setState(event.target,UP);
        }

		private function handleMouseDown(event:MouseEvent) : void
        {
            setState(event.target,DOWN);
        }
		
		
		public function setState(target,v:String)
		{
           if(target == this) return;
		   switch(v)
		   {
				case OVER : 
					hover(target , true);break;
				case DOWN :
			   		hover(target , true);break;
				case OUT : 
					hover(target , false);break;
				case UP :
					hover(target , false);break;
				default : 
					break;
		   }
		   
		  // EIF.get("showload")(target.name)
		   var events:String = gather[target.name].events[v];
		   if(events.length>0) EIF.call.apply(EIF,gather[target.name].events[v].split(","));
		}
		
		public function infoShow():void
		{
			var area = EIF.call("getcurrentarea");
			if(area)
				EIF.call("openWindow" , { title : area.title , text : area.content,media:area.media});
		}
		
		public function getWeibo():void
		{
			var id : String = EIF.call("getcurrentsvid");
			var url:String = weiboUrl.replace("{url}","http://www.tbpark.com/").replace("{title}","太白山虚拟漫游，全新体验，身临其境！").replace("{image}","http://soullab.sinaapp.com/taibai/{id}_thumb.jpg").replace("{id}",id);
			navigateToURL(new URLRequest(url));
			EIF.trace("navigateToURL:"+url)
		}
		
		public function getPhoto():void
		{
			_shutterSound.play();

			var file:FileReference = new FileReference();
			var image:BitmapData;
			if(EIF){
				image = EIF.call("print",true);
			}else
			{
				image = new BitmapData(stage.width,stage.height);
				image.draw(this.stage);
			}
			
			file.save(PNGEncoder.encode(image),"image.png");
		}
		
		private function quit():void
		{
			EIF.dispatchEvent(new Event("notice_shutdown"));
		}
		
		private var ishide:Boolean = false;
		public function toggle():void
		{
			ishide = !ishide;
			if(ishide)
			{
				TweenNano.to(this,0.5 , {y:this.stage.stageHeight})
				gather["show"].obj.visible = true;
				gather["hide"].obj.visible = false;
				EIF.dispatchEvent(new Event("notice_controlbar_show"));
			}else{
				TweenNano.to(this,0.5 , {y:this.stage.stageHeight - _height - backInfo.y})
				gather["show"].obj.visible = false;
				gather["hide"].obj.visible = true;
				EIF.dispatchEvent(new Event("notice_controlbar_hide"));
			}
			_head.toggle();
			
		}
		private function gw(v):Number
		{
			return(String(v).indexOf("%")!=-1) ? (this.stage.stageWidth  * parseFloat(v)  / 100 ): parseInt(v);
			
		}
		
		public function hover(obj , v:Boolean):void
		{
			if(obj.name){
				if(v){
					gather[obj.name] && gather[obj.name].tips!="" && EIF.call("show" , obj,gather[obj.name].tips);
					obj.filters = [new GlowFilter(0xffffff,0.8,16,16,3,2)];
				}else
				{
					EIF.call("hide");
					obj.filters = []
				}
			}
		}
		
		private function redrawBack():void{
			var w = (backInfo.width.indexOf("%")!=-1) ? (this.stage.stageWidth  * parseFloat(backInfo.width)  / 100 ): parseInt(backInfo.width );
			var h = (backInfo.height.indexOf("%")!=-1) ? (this.stage.stageHeight * parseFloat(backInfo.height) / 100 ): parseInt(backInfo.height);
			
			back.graphics.clear();
			this.graphics.clear()
			
			this.graphics.beginFill(backInfo.color, backInfo.alpha);
			this.graphics.drawRect(0,0,w,h);
			this.graphics.endFill();
			
			back.graphics.lineStyle(1,0xffffff);
			back.graphics.lineTo(w,0);
			back.graphics.moveTo(0,h);
			back.graphics.lineTo(w,h);
			
			
			
			if(backInfo.align == "6") {
				this.y = this.stage.stageHeight - h - backInfo.y
				this.x = backInfo.x
				
			}
			
			_width = w; _height = h;
			
		}
		
		
		public function redraw():void{
			
			redrawBack();
			
			var w = this._width;
			var h = this._height;
			
			for(var i in gather)
			{
				var k = gather[i];
				if(k.width.toString()!=""){
					k.obj.width = gw(k.width)
				}
				
				switch(k.align)
				{
					case "0" : 
						k.obj.x = k.offset.x;k.obj.y = k.offset.y;break;
					case "1" :
						k.obj.x = w*.5 - k.obj.width*0.5 + k.offset.x; k.obj.y = k.offset.y;break;
					case "2" :
						k.obj.x = w - k.obj.width - k.offset.x; k.obj.y = k.offset.y;break;
					case "3" :
						k.obj.x = k.offset.x; k.obj.y = (h - k.obj.height)*0.5 + k.offset.y;break;
					default :
						break;
				}
				k.obj.visible = k.visible;
				
				//if(k.title == "btmborder") trace()
			}
			
			if(ishide)
			{
				this.y = this.stage.stageHeight;
				gather["show"].obj.visible = true;
				gather["hide"].obj.visible = false;
				//EIF.dispatchEvent(new Event("notice_controlbar_show"));
			}
		}
		
		public function resize(e:* = null):void
		{
			redraw();
			if(_head) {_head.y = 0 - this.y; _head.draw();}
		}
		
	}
	
}
	
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.geom.Point;
	import flash.filters.GlowFilter;
	import flash.display.GradientType
	import pano.utils.TweenNano;
	import flash.geom.Matrix;
	
	internal class Head extends Sprite
	{
		private var txt_h:TextField;
		private var txt_c:TextField;
		private var _width:Number;
		private var _height:Number = 100;
		private var _container:Sprite = new Sprite();
		public function Head()
		{
			txt_h = new TextField();
			txt_c = new TextField();
			
			_container.addChild(txt_h);
			_container.addChild(txt_c);
			txt_h.autoSize = txt_c.autoSize =  TextFieldAutoSize.LEFT;
			txt_h.textColor = txt_c.textColor = 0xffffff;
			txt_h.x = 10;
			txt_h.defaultTextFormat = new TextFormat("黑体",20)
			txt_h.multiline = txt_c.multiline = true;
			//txt_h.width = 150;
			
			var tf:TextFormat = new TextFormat();
			tf.leading = 0;
			tf.font = "黑体";
			tf.size = 12;
			tf.leading = 7;
			txt_c.defaultTextFormat = tf;
			txt_c.antiAliasType = AntiAliasType.ADVANCED;
			txt_c.wordWrap = true;
			txt_c.height = _height;
			addChild(_container);
			
		}
		
		public function draw():void
		{
			_width = this.stage.stageWidth - this.height - txt_h.textWidth;
			_height = txt_c.textHeight + 32 + 5
			if(_width<=0) _width = 200;
			
			var matix:Matrix = new Matrix();//矩阵
				matix.createGradientBox(this.stage.stageWidth, _height, Math.PI*0.5, 0, 0);

			_container.graphics.clear()
			_container.graphics.beginGradientFill(GradientType.LINEAR,[0, 0],[0.6,0],[0,255],matix);
			//_container.graphics.beginFill(0, 0.55)
			_container.graphics.drawRect(0,0,this.stage.stageWidth,_height);
			_container.graphics.endFill();
			/*
			txt_h.y = (_height-txt_h.textHeight)*0.5;
			txt_c.width = _width;
			
			txt_c.y = txt_c.textHeight > _height ? 0 : (_height - txt_c.textHeight)*0.5;
			*/
			txt_h.x = txt_h.y = 5;
			txt_c.x = 5;
			txt_c.width = this.stage.stageWidth - 10;
			txt_c.y = 32;
		}
		
		public function setContent(h:String="",c:String = ""):void
		{
			
			txt_h.htmlText = h;
			//txt_h.setTextFormat(new TextFormat("黑体",24));
			
			txt_c.htmlText = c;
			
			//txt_c.setTextFormat(new TextFormat("黑体",12));
			//txt_c.x = txt_h.width + txt_h.x + 10;
			
			//txt_c.y = txt_c.textHeight > _height ? 0 : (txt_c.textHeight - _height)*0.5;
			draw();
		}
		
		private var ishide:Boolean = false;
		public function toggle():void
		{
			ishide = !ishide;
			if(ishide) TweenNano.to(_container,0.5 , {y:-60-_height})
			else TweenNano.to(_container,0.5 , {y:0})
		}
	}
