package  {
	
	import flash.system.Security;
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.geom.*;
	import flash.text.*;
	import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.media.SoundTransform;
	
	import pano.utils.*;
	
	import pano.ExtraInterface;
	
	public class Sounder extends Sprite {
		
		private var EIF:ExtraInterface;
		public static var fadeVol:Number = 0.05;
		private var list:Object = new Object();
		private var counter:int = 0;
		private var firstSound:String = "";
		private var lastSound:String = "";
		public function Sounder() {
			
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
				EIF.set("toggleSound",toggle);
				EIF.set("pauseSound",pause)
				EIF.set("resumeSound",resume);
				EIF.set("playSound",play);

				EIF.set("removeSound",remove);
				EIF.set("getSound",getIdByUrl);
				EIF.set("fadeSound",fade);
				EIF.addPluginEventListener(ExtraInterface.PLUGINEVENT_REGISTER, this.registerEvent);
				EIF.trace((new Date).toLocaleTimeString()+" : Loading Sounder(Ver 1.20140516) Plugin Success... ");
			}
			
			this.removeEventListener(Event.ADDED_TO_STAGE, this.startPlugin);
		}
		
		private function stopPlugin(e):void { }
		
		private function registerEvent(e):void {
			var bgvol = EIF.call("getPluginsConfig","bgsound").fade_volume;
			if(bgvol!= undefined) Sounder.fadeVol = parseFloat(bgvol);
			init(); 
		}
		
		private function init():void
		{
			//list = new Object();
		}
		
		public function play(url:String , repeat:int = 0 ,over : Boolean = true , fade:Boolean = true):String
		{
			var id:String = "audioId_" + getTimer() + "_" + int(Math.random() * 100);
			
			if(over)
			{
				if(hasInstance(url)) return getIdByUrl(url);
			}
			if(fade) fadeOut(id);
			list[id] = {id : id , fade:fade , "sounder" : new URLSound(url,repeat , id ) , "url" : url};
			list[id].sounder.addEventListener("data",soundCompleteHandler);
			EIF.trace("playSound("+id+") : "+url);
			if(firstSound == "") firstSound = id;
			lastSound = id;
			counter++;
			return id;
			
		}
		
		public function resume()
		{
			for(var i in list) list[i].sounder.resume();
		}
		
		public function pause()
		{
			for(var i in list) list[i].sounder.pause();
		}
		
		private function soundCompleteHandler(e):void
		{
			//var auto:Boolean = Boolean(e.data.auto);
			var d:String = String(e.data);
			if(list[d].fade) list[firstSound].sounder.unmute() 
			//EIF.trace(String(e.data)+" STOP")
			//fadeIn();
		}
		
		public function toggle(id : String = ""):void
		{
			if(id == "")
			{
				for(var i in list) list[i].sounder.toggle()
			}else
			{
				if(list[id])
				{
					list[id].sounder.toggle()
				}
			}
		}
		
		public function remove(id : String):void
		{
			if(list[id]){
				list[id].sounder.stop()
				list[id].sounder = null;
				if(list[id].fade) fadeIn();
				delete list[id];
				counter--;
				if(counter==0) firstSound = "";
				
			}
		}
		
		private function fade(v:Boolean , exp:String = "" ):void
		{
			v ? fadeOut(exp) : fadeIn(exp);
			
		}
		
		private function fadeOut(exp:String = ""):void
		{
			for(var i:String in list)
			{
				if(i!=exp)
				{
					list[i].sounder.mute();
				}
			}
		}
		
		private function fadeIn(exp:String = ""):void
		{
			//if(counter > 1) exp = firstSound;
			var c:int = 0;
			for(var i:String in list)
			{
				if(list[i].sounder.status != 0) c++;
				if(i!=exp)
				{
					list[i].sounder.unmute();
				}
			}
			
			if(c==1) list[firstSound].sounder.unmute();
		}
		
		private function getSoundById(v:String){
			
		}
		
		public function getIdByUrl(v:String):String
		{
			for(var i:String in list)
				if(list[i].url == v) return i;
			return "";
		}
		
		private function hasInstance(v:String):Boolean
		{
			for(var i:String in list)
			{
				if(list[i].url == v) return true;
			}
			return false;
		}
		
		
		
	}
	
}

import flash.net.*;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import flash.events.DataEvent;
import pano.utils.TweenNano;	
internal class URLSound extends Sound
{
	
	public var soundChannel:SoundChannel;
	private var soundTransform:SoundTransform
	public var _repeat:int = 0;
	public var volume:Number = 1;
	private var position:Number = 0;
	public var status:int = 0;
	private var id:String;
	private var vol:Number;
	private var auto:Boolean;
   	public function URLSound(url:String , repeat , id )
    {
    	this.id = id; this.auto = auto;
		_repeat = repeat;
		load(new URLRequest(url)); 
		this.soundChannel = play(0,_repeat==-1 ? 99999 : _repeat);
		soundTransform = this.soundChannel.soundTransform;
		status = 1;
		this.soundChannel.addEventListener("soundComplete",soundCompleteHandler)
		//this.soundChannel.addEventListener("soundComplete",playEnd)
		//this.add
		
    }
	
	private function soundCompleteHandler(e):void
	{
		status = 0;
		this.dispatchEvent(new DataEvent("data" , false ,false , this.id ));
	}
	public function mute():void
	{	
		TweenNano.to(this,1,{volume : Sounder.fadeVol,onUpdate:function(){
					 	soundTransform.volume = volume
					 	soundChannel.soundTransform = soundTransform;
					 }});
	}
	
	public function unmute():void
	{
		trace("unmute : " +",url:"+this.url)
		TweenNano.to(this,1,{volume : 1,onUpdate:function(){
					 	soundTransform.volume = volume;
					 	soundChannel.soundTransform = soundTransform;
					 }});
	}
	
	private function playEnd(e)
	{
		//if(_repeat==-1) 
	};
	/*
	override public function play(startTime:Number = 0, loops:int = 0, sndTransform:SoundTransform = null):SoundTransform
	{
		this.soundChannel = super.play(startTime , loops , sndTransform)
		return this.soundTransform;
	}
	*/
	public function toggle():void
	{
		status ? pause(): resume()
	}
	
	public function resume():void
	{
		status = 1;
		soundChannel = play(position,_repeat==-1 ? 99999 : _repeat);
		soundChannel.addEventListener("soundComplete",soundCompleteHandler);
		soundTransform.volume = vol;
		soundChannel.soundTransform = soundTransform;
		trace("resume : " + soundChannel.soundTransform.volume+",url:"+this.url)
	}
	
	public function pause():void
	{
		status = 0;
		position = this.soundChannel.position;
		vol = this.soundChannel.soundTransform.volume;
		this.soundChannel.stop();
		this.soundChannel.removeEventListener("soundComplete",soundCompleteHandler);
		trace("pause : " + vol+",url:"+this.url)
	}
	
	public function stop():void
	{
		this.soundChannel.stop();
		try{close();}catch(e){}
	}
}
