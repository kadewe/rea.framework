/*

"Rich E-Assesment (REA) Framework"
A software framework for the use within the domain of e-assessment.

Copyright (C) 2014  University of Bremen, 
Working Group education media | media education 

Prof. Dr. Karsten Wolf, wolf@uni-bremen.de
Dipl.-Päd. Ilka Koppel, ikoppel@uni-bremen.de
Dipl.-Math. Kai Schwedes, kais@zait.uni-bremen.de
B.Sc. Jan Küster, jank87@tzi.de

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
package utils
{
	import components.ReaImage;
	
	import events.CustomEventDispatcher;
	
	import flash.events.TimerEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.utils.Timer;
	
	import mx.events.FlexEvent;

	/**
	 * Collection of global static functions for visual effects.
	 */
	public class ReaVisualUtils extends CustomEventDispatcher
	{
		//------------------------------------------//------------------------------------------//
		//
		//	 							  STATIC DISPATCHER CONSTANTS
		//
		//------------------------------------------//------------------------------------------//
		/**
		 * @private Allows a static class to dispatch Events dynamically.
		 */
		protected static const staticDispatcher:CustomEventDispatcher = new CustomEventDispatcher();

		
		
		//------------------------------------------//------------------------------------------//
		//
		//	 									 RESIZE EFFECTS
		//
		//------------------------------------------//------------------------------------------//	

		
		
		public static function resizeImages(i:ReaImage,boundx:Number,boundy:Number):void
		{			
			i.addEventListener(FlexEvent.UPDATE_COMPLETE, onImageUpdate);
			var a:Array = scaledResize(i.width,i.height,boundx,boundy);
			
			i.width = a[0];
			i.height = a[1];
			
		}
		
		protected static function onImageUpdate(event:FlexEvent):void
		{
			var i:ReaImage = event.currentTarget as ReaImage;
			i.removeEventListener(FlexEvent.UPDATE_COMPLETE, onImageUpdate);
			try
			{
				i.removeEventListener(FlexEvent.UPDATE_COMPLETE, onImageUpdate);
				i.invalidateProperties();
				i.invalidateSize();
				i.invalidateDisplayList();
				i.validateNow();	
			}catch(e:Error){
				//trace("[VisualUtil]: *ERROR* in image-validation functions");
				//trace(e.getStackTrace());
			}
			
		}
		
		
		/**
		 * Returns an array of x and y values for resizing an image withihn given bounds by keeping the ratio scaled.
		 * @param w the current width of the image
		 * @param h the current height of the image
		 * @param boundx the current bound width of the container
		 * @param boundy the current bound height of the container
		 * @returns an array with x and y values of the resized image.  
		 */
		public static function scaledResize(w:Number, h:Number, boundx:Number, boundy:Number):Array
		{
			var a:Array = new Array();
			//trace("[VisualUtil]: old width:"+ w+ " old height:"+ h);
			//trace("[VisualUtil]: boundx:"+ boundx+ " boundy:"+ boundy);
			var neww:Number = w;
			var newh:Number = h;
			
			var resized:Boolean = false;
			try
			{
				while(!resized)
				{
					if(neww <= boundx && newh <= boundy)
					{
						resized = true;
						break;
					}
					if(w > h)
					{
						neww--;
						var percentw:Number = neww/w * 100;
						newh = Math.round(percentw*h / 100);
					}else{
						newh--;
						var percenth:Number = newh/h * 100;
						neww = Math.round(percenth*w / 100);
					}
				}	
			}catch(e:Error){
				//trace("[VisualUtil]: *ERROR* could not resize - "+e.getStackTrace());
				neww = w;
				newh = h;
			}
			//trace("[VisualUtil]: new width: "+ neww);
			//trace("[VisualUtil]: new height: "+ newh);
			a.push(neww);
			a.push(newh);
			return a;
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
	
		
		public static function getBlurFilter(x:Number=0.3,y:Number=0.3):BlurFilter
		{
			return new BlurFilter(x,y);
		}
		
		//------------------------------------------//------------------------------------------//
		//
		//
		//	 									PULSE FOCUS
		//
		//
		//------------------------------------------//------------------------------------------//
		
		public static var target:Object=new Object();

		private static var t:Timer=new Timer(20);
		private static var pulse:Timer = new Timer(20);
		
		private static var counter:Number=0;
		private static var countSwitch:Boolean=false;
		
		private static var pulseOn:Boolean=true;
		
		
		public static function setPulseOnOff(value:Boolean):void
		{
			pulseOn=value;
		}
		
		/**
		 * Takes a referred object and adds some filters with random values to implement a smooth looking pulse effect.
		 * 
		 * @param obj the reffered Object which shall be displayed with a pulse
		 */
		public static function pulseFocus(obj:Object,delay:uint=0):void
		{
			if(!pulseOn)return;
			stopPulse();
			counter=0;
			target = obj;
			pulse = new Timer(1+Math.random()*100);
			pulse.delay = delay;
			pulse.start();
			pulse.addEventListener(TimerEvent.TIMER, onPulse);
			
		}
		
		private static function onPulse(event:TimerEvent):void
		{
			
			var arr:Array = new Array();
			var f:GlowFilter = getGloFil(0x716159);
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
		//
		//	 									TWEEN ELEMENTS
		//
		//
		//------------------------------------------//------------------------------------------//
		
		

		
		
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