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
	import components.SkinnedComponents.SmallEyeButton;
	
	import events.CustomEventDispatcher;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import interfaces.IClickable;
	
	import mx.collections.ArrayList;
	import mx.core.IVisualElement;

	/**
	 * A simple queue implementation for creating a chronoligical order of elements to become visible after initial interaction. One an element becomes visible, the internal counter is incremented by one.
	 */
	public class VisibleList
	{
		
		//---------------------------------------
		//
		//	VARIABLES
		//
		//---------------------------------------
		
		
		/**
		 * A tween or list search is going on.
		 */
		public static const IS_BUSY:String="isBusy";
		
		/**
		 * List is available for action
		 */
		public static const IS_FREE:String="isFree";
		
		/**
		 * @private
		 */
		protected static var dispatcher:CustomEventDispatcher = new CustomEventDispatcher();
		
		/**
		 * @private
		 */
		protected static var list:ArrayList;
		
		/**
		 * @private
		 */
		protected static var debug:Boolean = false;
		
		/**
		 * @private
		 */
		protected static var count:int = 0;

		//---------------------------------------
		//
		//	PUBLIC API
		//
		//---------------------------------------
		
		/**
		 * Initialise List
		 */
		public static function init():void
		{
			list = new ArrayList();
			count=0;
		}
		
		/**
		 * Sets the class to debug mode
		 */
		public static function setDebug(value:Boolean):void
		{
			debug=value==true?true:false;
		}
		
		/**
		 * Adds a visual element to the list.
		 */
		public static function addToList(i:IVisualElement):void
		{
			if(debug)trace("try add to list: "+i);
			if(i is IClickable)
			{
				i.addEventListener(MouseEvent.CLICK, onMouseClick);
				if(IClickable(i).referringTo is MP3Audio)
				{
					
					IClickable(i).referringTo.addEventListener(MP3Audio.START_PLAYING, onStartPlaying);
					IClickable(i).referringTo.addEventListener(MP3Audio.FINISHED_PLAYING, onFinishedPlaying);
				}
			}
			i.visible = false;
			i.alpha = 0;
			if(debug)trace("add to list: "+i);
			list.addItem(i);
		}

		/**
		 * Starts the queue and makes the first element visible.
		 */
		public static function start():void
		{
			visible();
		}
		
		/**
		 * Removes all elements from the list and resets the list size and counter.
		 */
		public static function flush():void
		{
			list.removeAll();
			init();
		}
		
		/**
		 * Tweens the current pointed element to a visible state (alpha = 1.0).
		 */
		public static function visible():void
		{
			if(count<0 || count >= list.length)return;
			var next:Object = list.getItemAt(count);
				next.visible = true;
			
			ExtendedTweener.tween(next, 0.5,{alpha:1});
				
		}
		
		/**
		 * Increments the list pointer. 
		 */
		public static function next(current:int=-1):void
		{
			if(current!=-1)count=current;
			count++;
			if(debug)trace("count is "+count +" of "+ list.length+" (current is "+current+")");
		}
		
		/**
		 * Adds listener to a static event dispatcher instance.
		 */
		static public function addEventListener(type:String,listener:Function,useCapture:Boolean = false,priority:int=0,useWeakReference:Boolean = false):void
		{
			dispatcher.addEventListener(type,listener,useCapture,priority,useWeakReference);
		}
		
		/**
		 * Removes listener from a static event dispatcher instance.
		 */
		static public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			dispatcher.removeEventListener(type,listener,useCapture);
		}
		
		/**
		 * Removes all listeners from a static event dispatcher instance.
		 */
		static public function removeAllEventListeners(type:String = ''):void 
		{
			dispatcher.removeAllEventListeners(type);
		}
		
		
		//---------------------------------------
		//
		//	EVENTS
		//
		//---------------------------------------
		
		/**
		 * Removes the event listener from the targetetd list-element, dispatches IS_FREE, increments and makes the next item visible.
		 */
		protected static function onFinishedPlaying(event:Event):void
		{
			dispatcher.dispatchEvent(new Event(IS_FREE));
			event.target.removeEventListener(MP3Audio.FINISHED_PLAYING, onFinishedPlaying);
			next(list.getItemIndex(MP3Audio(event.target).parent));
			visible();
		}
		
		/**
		 * Locks the list by IS_BUSY until sound has finished playing.
		 */
		protected static function onStartPlaying(event:Event):void
		{
			dispatcher.dispatchEvent(new Event(IS_BUSY));
			event.target.removeEventListener(MP3Audio.START_PLAYING, onStartPlaying);
		}
		
		/**
		 * Invokes visibility on object by clicking. Avoids the visible() function and has its own decision.
		 */
		protected static function onMouseClick(event:Event):void
		{
			var i:IClickable = event.target as IClickable;
			if(	i.hasEventListener(MouseEvent.CLICK))
				i.removeEventListener(MouseEvent.CLICK, onMouseClick);
			
			//make ref visible on click
			if( i.visibleReference!=null)
			{
				ExtendedTweener.tween( i.visibleReference, 0.5 ,{alpha:1});
			}
			if( i is SmallEyeButton)
			{
				next(list.getItemIndex(event.target));
				visible();
			}
		}

		

	}
}