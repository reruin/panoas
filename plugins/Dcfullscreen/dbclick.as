package 
{
    import flash.display.*;
    import flash.events.*;
    import flash.text.*;
	import pano.ExtraInterface;
	
    public class dbclick extends Sprite
    {
      	private var EIF:ExtraInterface;
		private var layer:Sprite;
		private var fullscreenFn : Function;
		
        public function dbclick()
        {
            if (stage == null)
            {
                this.addEventListener(Event.ADDED_TO_STAGE, this.startPlugin);
            }else
				this.startPlugin();
        }

        private function startPlugin(e:Event = null) : void
        {
        	stage.showDefaultContextMenu = false;
			EIF = ExtraInterface.getInstance();
			if(EIF.ready) 
			{
				EIF.addPluginEventListener(ExtraInterface.PLUGINEVENT_REGISTER, this.registerEvent);
			}
			
			this.removeEventListener(Event.ADDED_TO_STAGE, startPlugin);
        }

     	private function registerEvent(e)
		{
			layer = EIF.get("layer");
			init();
		}
		
        private function init() : void
        {
      		if(EIF.ready) layer.stage.addEventListener(MouseEvent.DOUBLE_CLICK, this.dbClickHandler);
        }

        private function dbClickHandler(event:MouseEvent) : void
        {
            EIF.call("fullscreen");
        }


    }
}
