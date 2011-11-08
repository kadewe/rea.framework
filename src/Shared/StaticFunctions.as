package Shared
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.utils.Timer;

	/**
	 * Collection of global static functions, often required and optimized.
	 */
	public class StaticFunctions extends EventDispatcher
	{
		//------------------------------------------//------------------------------------------//
		//
		//	 							  STATIC DISPATCHER CONSTANTS
		//
		//------------------------------------------//------------------------------------------//
		/**
		 * Allows a static class to dispatch Events dynamically.
		 */
		public static const staticDispatcher:EventDispatcher = new EventDispatcher();
		public static const OBJECT_RESIZED:String = "objectResized";
		public static const OBJECT_FADE_OUT:String = "objectFadeOut";
		public static const OBJECT_FADE_IN:String = "objectFadeIn";
		
		
		//------------------------------------------//------------------------------------------//
		//
		//	 									  VARIABLES
		//
		//------------------------------------------//------------------------------------------//
		
		public var alpha:Number=0;
		
		/**
		 * for resizeX method
		 */
		public static var sizeX:Number=0;
		
		/**
		 * Pointer on multiple Object to use within a method of this class. 
		 */
		public static var targets:Array=new Array();
		
		/**
		 * Pointer on a single Object to use within multple methods (especially event driven methods).
		 */
		public static var target:Object=new Object();
		
		
		public static var tweenObj:Object = new Object();
		
		private static var t:Timer=new Timer(20);
		private static var pulse:Timer = new Timer(20);
		
		private static var counter:Number=0;
		private static var countSwitch:Boolean=false;
		
		
		
		
		//------------------------------------------//------------------------------------------//
		//
		//	 									 RESIZE EFFECTS
		//
		//------------------------------------------//------------------------------------------//	
		
		/**
		 * Provides a tween animation for resizing Display Objects.
		 * 
		 * @param obj The object which needs to be resized. (important: obj must be a view component)
		 * @param targetWidth The desired width of the object
		 * @param type Describes in which way the object will be resized. Options: smaller bigger mirror smallerToZero
		 */
		public static function resize(arr:Array,targetWidth:Number,type:String="smaller"):void
		{
			sizeX=targetWidth;
			targets=arr;
			t.start();
			switch(type)
			{
				case("smaller"):
					t.addEventListener(TimerEvent.TIMER,onCountSmaller);
					break;
				case("bigger"):
					t.addEventListener(TimerEvent.TIMER,onCountBigger);
					break;
				case("mirror"):
					break;
				case("smallerToZero"):
					break;
				default:
					break;
			}
		}
		
		
		
		private static function onCountSmaller(event:TimerEvent):void
		{
			trace("onCountSmaller");
			var flag:Boolean;
			for(var i:uint=0;i<targets.length;i++)
			{
				if(targets[i].scaleX>=0.35||targets[i].scaleY>=0.35)
				{
					trace("scale  "+targets[i].scaleX+"  "+targets[i].scaleY);
					targets[i].scaleX-=0.01;
					targets[i].scaleY-=0.01;
				}else{
					targets[i].scaleX=0.35;
					targets[i].scaleY=0.35;
					trace("stop  "+targets[i].scaleX+"  "+targets[i].scaleY);
					flag=true;
				}		
			}
			if(flag)
			{					
				var tmr:Timer=event.target as Timer;
				tmr.stop();
				tmr.removeEventListener(TimerEvent.TIMER,onCountSmaller);
				staticDispatcher.dispatchEvent(new Event("objectResizedSmall"));
			}
		}
		
		
		private static function onCountBigger(event:TimerEvent):void
		{
			trace("onCountBigger");
			var flag:Boolean;
			for(var i:uint=0;i<targets.length;i++)
			{
				if(targets[i].scaleX<=1||targets[i].scaleY<=1)
				{
					trace("scale  "+targets[i].scaleX+"  "+targets[i].scaleY);
					targets[i].scaleX+=0.01;
					targets[i].scaleY+=0.01;
				}else{
					targets[i].scaleX=1;
					targets[i].scaleY=1;
					trace("stop  "+targets[i].scaleX+"  "+targets[i].scaleY);
					flag=true;
				}		
			}
			if(flag)
			{					
				var tmr:Timer=event.target as Timer;
				tmr.stop();
				tmr.removeEventListener(TimerEvent.TIMER,onCountBigger);
				staticDispatcher.dispatchEvent(new Event("objectResizedBig"));
			}
		}
		

		//------------------------------------------//------------------------------------------//
		//
		//	 								FADING OBJECT EFFECTS
		//
		//------------------------------------------//------------------------------------------//		
		
		
		/**
		 * This animation tween is used to fade in and out but will only work on components wihtout children whose alpha value is used between 0 and 1.
		 * This would cause that those values will be manipulated as well! The components will loose their smooth gradient fashioned look. So be careful if you use this method.
		 * 
		 * @param obj The Object which will be faded. Important is, that you only use Display Objects ().
		 * @param type the type of the tween animation 
		 */
		public static function tweenAlpha(obj:Object,type:String="out"):void
		{
			tweenObj=obj;
			t.start();
			if(tweenObj.alpha<1)
			{
				t.addEventListener(TimerEvent.TIMER,fadeIn);	
			}else{
				t.addEventListener(TimerEvent.TIMER,fadeOut);
			}
		}
		
		
		private static function fadeOut(event:TimerEvent):void
		{
			if(tweenObj.alpha>=0)
			{
				tweenObj.alpha-=0.01;
				tweenObj.alpha-=0.01;
			}else{
				target.alpha=0;
				target.alpha=0;
				var tmr:Timer=event.target as Timer;
				tmr.stop();
				tmr.removeEventListener(TimerEvent.TIMER,fadeOut);
				//tmr=null;
				staticDispatcher.dispatchEvent(new Event(OBJECT_FADE_OUT));
			}		
		}
		
		private static function fadeIn(event:TimerEvent):void
		{

			//trace("check  "+target.alpha);
			if(tweenObj.alpha<=1)
			{
				//trace("FadeINT  "+target.alpha);
				tweenObj.alpha+=0.01;
				tweenObj.alpha+=0.01;
			}else{
				tweenObj.alpha=1;
				tweenObj.alpha=1;
				//trace("stop  "+target.alpha);
				var tmr:Timer=event.target as Timer;
				tmr.stop();
				tmr.removeEventListener(TimerEvent.TIMER,fadeIn);
				//tmr=null;

				staticDispatcher.dispatchEvent(new Event(OBJECT_FADE_IN));
			}		
		}
		



		
		//------------------------------------------//------------------------------------------//
		//
		//	 									  FILTERS
		//
		//------------------------------------------//------------------------------------------//
		
		/**
		 * returns a new glowfilter with optmized pre settings
		 * 
		 * @param gfColor the color of the glow
		 * @param radius will be mapped to blurX and blurY
		 * 
		 * @returns GlowFilter Object
		 */
		public static function getGloFil(gfColor:uint=0xFFD799,radius:Number=10):GlowFilter
		{
			var color:Number = gfColor;
			var alpha:Number = 0.5;
			var blurX:Number = radius;
			var blurY:Number = radius;
			var strength:Number = 4;
			var inner:Boolean = false;
			var knockout:Boolean = false;
			var quality:Number = 5;
			
			return new GlowFilter(color,
				alpha,
				blurX,
				blurY,
				strength,
				quality,
				inner,
				knockout);
		}
		
		
		/**
		 * returns a new Dropshadow with optmized pre settings
		 * 
		 * @param dsColor the color of the shadow
		 * @param radius will be mapped to blurX and blurY
		 * 
		 * @returns DropShadowFilter Object
		 */
		public static function getDropSh(dsColor:uint=0x716159,radius:Number=5):DropShadowFilter
		{
			var color:uint = dsColor;
			var alpha:Number = 0.6;
			var blurX:Number = radius;
			var blurY:Number = radius;
			var strength:Number = 10;
			var inner:Boolean = false;
			var knockout:Boolean = false;
			var quality:Number = BitmapFilterQuality.HIGH;
			
			return new DropShadowFilter(5,0,color,alpha,blurX,blurY,strength,quality,inner,knockout);
		}
	
		
		
		//------------------------------------------//------------------------------------------//
		//
		//	 									PULSE FOCUS
		//
		//------------------------------------------//------------------------------------------//
		
		
		/**
		 * Takes a referred object and adds some filters with random values to implement a smooth looking pulse effect.
		 * 
		 * @param obj the reffered Object which shall be displayed with a pulse
		 */
		public static function pulseFocus(obj:Object):void
		{
			stopPulse();
			counter=0;
			target = obj;
			pulse = new Timer(1+Math.random()*100);
			pulse.start();
			pulse.addEventListener(TimerEvent.TIMER, onPulse);
		}
		
		private static function onPulse(event:TimerEvent):void
		{
			var arr:Array = new Array();
			var f:GlowFilter = getGloFil();
			f.quality=counter;
			arr.push(f);
			target.filters=arr;
			if(counter==15)
			{
				countSwitch=true;
			}
			if(counter==0)
			{
				countSwitch=false;
			}
			if(countSwitch)
			{
				counter--;
			}else{
				counter++;
			}
			pulse.removeEventListener(TimerEvent.TIMER,onPulse);
			pulse.stop();
			pulse = new Timer(10+Math.random()*120);
			pulse.start();
			pulse.addEventListener(TimerEvent.TIMER, onPulse);
		}
		
		
		/**
		 * stops the actual pulse of an object
		 */
		public static function stopPulse():void
		{
			pulse.stop();
			try
			{
				pulse.removeEventListener(TimerEvent.TIMER, onPulse);
			}catch(e:Error){
				trace(e);
			}
			target.filters = null;
			target=null;
			target=new Object();
		}
		

		
		//------------------------------------------//------------------------------------------//
		//
		//	 									    MISC
		//
		//------------------------------------------//------------------------------------------//
		
		
		
		/**
		 * Provides a smooth fade out for all now-running sound files. Be aware, that ALL running sound will be faded!
		 */
		public static function fadeOutSound():void
		{			
			var tr:SoundTransform = new SoundTransform();
			while(tr.volume>0)
			{
				tr.volume -=0.00002;
				SoundMixer.soundTransform = tr;
			}
			tr.volume=1;
			SoundMixer.stopAll();
			SoundMixer.soundTransform = tr;
		}
		
		
		/**
		 * Tries to convert an object to a string value
		 */
		public static function convertToString(obj:Object):String
		{
				var s:String;
				try
				{
					s=obj.toString();
				}catch(e:Error){
					trace(e.message);
					s="";
				}
				return s;
		}
	}
}