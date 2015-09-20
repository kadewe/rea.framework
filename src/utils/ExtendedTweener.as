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
	import events.CustomEventDispatcher;
	
	import mx.collections.ArrayList;
	import mx.events.EffectEvent;
	
	import spark.effects.Animate;
	import spark.effects.Fade;
	import spark.effects.Resize;
	
	/**
	 * A wrapper for different Animate based classes. Properties are passed within an object and tried to tween on the target.
	 */
	public class ExtendedTweener extends CustomEventDispatcher
	{		
		
		/**
		 * Tweens a target's properties (if existent) in a given time towards a given value. Startvalues are target's current values.
		 * 
		 * @param target The target to be tweened
		 * @param duration The duration in seconds. If a half second is desired, then this value would be 0.5
		 * @param properties An arbitrary object containing properties, which are intended to be tweened on the target. Note, that property names have to be the exact name (watch cases!) of the target's property.
		 * @param onCompleteFunc A function to be called, once the tween has been completed.
		 * @param delay optional predelay in seconds.
		 */
		public static  function tween(target:Object,duration:Number, properties:Object, onCompleteFunc:Function=null, delay:Number = 0):void
		{
			if(!target || !properties)return;
			
			clearList();
			if(onCompleteFunc!=null)onComplete(onCompleteFunc);
			
			
			for (var property:String in properties)
			{
				if(!target.hasOwnProperty(property))continue;
				
				var width:Number=-1;
				var height:Number = -1;
				
				switch(property)
				{
					case "alpha":
						tweenAlpha(target, duration, Number(properties[property]),delay);
						break;
					
					case "width":
						width = Number(properties[property]) || -1;
						break;
					
					case "height":
						height = Number(properties[property]) || -1;
						break;
					
					default:
						target[property] = properties[property];
						break;
					
				}
				
				tweenSize(target, duration, width, height);
			}
		}
		
		/**
		 * @private
		 */
		protected static var _list:ArrayList=new ArrayList();

		/**
		 * @private
		 */
		protected static function clearList():void
		{
			for (var i:int = 0; i < _list.length; i++) 
			{
				Animate(_list.getItemAt(i)).pause();
			}
			
		}
		
		/**
		 * @private
		 */
		protected  static var funcRef:Function;
		
		/**
		 * @private
		 */
		public static function onComplete(f:Function):void
		{
			funcRef = f;
		}
		
		/**
		 * @private
		 */
		protected  static function tweenSize(target:Object, seconds:Number, width:Number, height:Number):void
		{
			if(width<0 && height < 0 )return;
			var r:Resize = new Resize(target);
				r.addEventListener(EffectEvent.EFFECT_END, onEffectEnd);
				if(height>=0)
				{
					r.heightFrom = target.height;
					r.heightTo = height;
				}
				if(width>=0)
				{				
					r.widthFrom = target.width;
					r.widthTo = width;
				}

				r.duration = seconds*1000;
				r.end();
				r.play();
				_list.addItem(r);
		}
		
		/**
		 * @private
		 */
		protected   static function tweenAlpha(target:Object, seconds:Number,alphaTo:Number = 1.0, delay:Number = 0):void
		{
			
			var f:Fade = new Fade(target);
				f.addEventListener(EffectEvent.EFFECT_END, onEffectEnd);
				f.duration = int(seconds*1000);
				f.alphaFrom = target.alpha;
				f.alphaTo = alphaTo;
				f.startDelay = delay*1000;
				f.end();
				f.play();
			
		}
		
		/**
		 * @private
		 */
		protected  static function applyFunc():void
		{
			if(funcRef!=null)
			{
				funcRef.call();
				funcRef = null;
			}
		}
		
		/**
		 * @private
		 */
		protected  static  function onEffectEnd(event:EffectEvent):void
		{
			var f:Animate = Animate(event.currentTarget);
				f.removeEventListener(EffectEvent.EFFECT_END, onEffectEnd);
				f = null;
			applyFunc();
			_list.removeItem(f);
		}
	}
}