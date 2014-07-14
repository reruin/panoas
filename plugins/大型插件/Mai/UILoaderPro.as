package  {
	import flash.display.Sprite;
	import flash.events.*;
	import pano.ui.*;
	
	public class UILoaderPro extends ScrollPane{

		private var unitw:int ; 
		private var unith:int ;
		private var fitWidth:Boolean;
		private var padding:Number;
		private var size:Number;
		private var sizeHeight:Number = 80;
		
		
		public function UILoaderPro(w:Number , h:Number , t:String = "",  f:Boolean = true , s : int = 120 , p:Number = 10)
		{
			padding = p; size = s; fitWidth = f;
			super(w , h ,t);
			trace("UILOADer  :"+h)
			// constructor code
		}
		
		override protected function addChildren():void
		{
			_headHeight = 0;
			if(fitWidth)
			{
				unitw = Math.floor( (width-padding) / (size + padding));
				padding = (width - unitw * size) / (unitw+1)
				
			}else
			{
				unitw = 1000000;
				
			}
			super.addChildren();
			
			setContent(new Component());
			
			
		}
		
		public var list : Array = [];
		public function load(v):void
		{
			if(v is Array)
			{
				var l = v.length ; 
				for(var i=0; i<l ; i++)
				{
					add(v[i].thumb,v[i].title, v[i].id)
				}
			}
		}
		
		public function clear():void
		{
			for(var i=list.length-1; i>=0 ; i-- )
			{
				(content as Sprite).removeChild(list[i]);
				list[i] = null;
			}
			list = [];
		}
		
		public function getElementByChild():void
		{
		
		}
		
		public function add(url :String , title :String ,id:String):void
		{
			
			var u:UILoader = new UILoader(160,80,url,title);
			u.name = id;
			(content as Sprite).addChild(u);
			u.addEventListener(MouseEvent.CLICK , clickHandler)
			//trace(unitw)
			u.x = padding + (size + padding) * ( list.length%unitw) ; 
			u.y = padding + (sizeHeight + padding) * Math.floor(list.length/unitw);
			
			
			
			list.push(u);
			
			
			content.height = padding + u.y + sizeHeight;
			render();
			
		}
		
		public var id:String;
		private function clickHandler(e:MouseEvent):void
		{
			id = e.currentTarget.name;
			dispatchEvent(new DataEvent(DataEvent.DATA , false , false,id));
		}
		 
		//public function

	}
	
}
