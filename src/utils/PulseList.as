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
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import interfaces.IClickable;
	import interfaces.IWritable;
	
	import mx.collections.ArrayList;
	import mx.core.UIComponent;

	
	/**
	 * <p>Provides a static access to a list of pulsing objects.</p>
	 * 
	 * <p>Usage: Add objects to the list, the order of the adding distincts the order of the pulsing. 
	 * Then start the pulsing. When objects are clicked or their sounds are finishied playing, the pulsing stops and the
	 * next item in list is targeted for pulsing.</p>
	 * 
	 * <p>Not dependent on third party tweeners!</p>
	 * 
	 * 
	 */
	public class PulseList
	{
		/**
		 * @private
		 */
		protected static var pulseList:ArrayList = new ArrayList();
		
		/**
		 * @private
		 */
		protected static var current:uint = 0;
		
		/**
		 * @private
		 */
		protected static var locked:Boolean;
		
		/**
		 * @private
		 */
		protected static var debug:Boolean = false;
		
		/**
		 * @private
		 */
		protected static var on:Boolean=true;

		/**
		 * Sets or unsets debug mode to enable tracing.
		 * 
		 * @param value Boolean value for debug on or off
		 */
		public static function setDebug(value:Boolean):void
		{
			if(value==false)
				debug=false;
			if(value==true)
				debug=true;
		}
		
		
		/**
		 * Adds an object to the list.
		 * 
		 * @param o anything you desire
		 */
		public static function addToList(o:*):void
		{
			if(o is UIComponent)
			{
				if(debug)
				{
					trace("(pulseList): "+o.id+" added");
				}
				pulseList.addItem(o);
			}
						
		}
		
		/**
		 * Initializes the pulsing sequence by iterating all elements and adding listeners to it.
		 */
		public static function init(startPoint:uint=0):void
		{
			if(pulseList.length==0)
				return;
			
			setCurrent(startPoint);
			for(var i:uint=0;i<pulseList.length-1;i++)
			{
				var o:* = pulseList.getItemAt(i);
				if(o is UIComponent)
				{
					if(o is IWritable)
					{
						pulseList.getItemAt(i).addEventListener(KeyboardEvent.KEY_UP, onKeyPressed);
					}else{
						if(o is IClickable && o.referringTo is MP3Audio)
						{
							locked=true;
							pulseList.getItemAt(i).referringTo.addEventListener(MP3Audio.FINISHED_PLAYING, onFinishedPlaying);
						}else{
							pulseList.getItemAt(i).addEventListener(MouseEvent.CLICK, onComponentClicked);	
						}
					}
				}

			}
		}
		
		
		/**
		 * Starts pulsing the first element.
		 */
		public static function start():void
		{
			pulse();	
		}
		

		/**
		 * Removes listeners, items and references and restarts the list.
		 */
		public static function flush():void
		{
			for(var i:uint=0;i<pulseList.length;i++)
			{
					try
					{
						pulseList.getItemAt(i).removeEventListener(MouseEvent.CLICK, onComponentClicked);
						if(pulseList.getItemAt(i).referringTo is MP3Audio)
						{
							pulseList.getItemAt(i).referingTo.removeEventListener(MP3Audio.FINISHED_PLAYING, onFinishedPlaying);	
						}
						if(debug)trace("(pulseList): listeners removed");
					} 
					catch(error:Error) 
					{
						if(debug)trace("(pulseList):remove  listeners failed");
					}
			}
			pulseList.removeAll();
			pulseList = new ArrayList();
			current = 0;
			if(debug)trace("(pulseList): flushed");
		}
		
		/**
		 * Returns the current item's id or a fallback.
		 * 
		 * @return A string of the current target's id.
		 */
		public static function returnCurrentPointer():String
		{
			return pulseList.length>0&&current<pulseList.length?pulseList.getItemAt(current).id:"list is null or pointer out of bound";
		}
		
		
		
		/**
		 * @private
		 */
		protected static function pulse():void
		{
			if(debug)
			{
				trace("(pulseList):pulse: "+returnCurrentPointer());
			}
			if(pulseList.length>0 && current < pulseList.length)
			{
				var o:* = pulseList.getItemAt(current);
				var delay:uint = (current>0 && pulseList.getItemAt(current-1) is IWritable)?1800:0;
				
				//add pulse effect
				ReaVisualUtils.pulseFocus(o,delay);
			}
			
		}
		
		/**
		 * @private
		 */
		protected static function next():void
		{
			if(debug)
			{
				trace("(pulseList):jump from "+current);
			}
			if(pulseList.length>0 && current < pulseList.length-1)
				current++;
			if(debug)
			{
				trace("to "+current);
			}
		}

		
		/**
		 * @private
		 */
		protected static function onComponentClicked(event:MouseEvent):void
		{
			if(debug)
				trace("(pulseList): click event");
			var b:* = event.currentTarget;
			for(var i:uint=0;i<pulseList.length;i++)
			{
				if(pulseList.getItemAt(i).id == b.id)
				{
					setCurrent(i);
				}
			}
			next();
			pulse();	
		}
		
		/**
		 * @private
		 */
		protected static function onKeyPressed(event:KeyboardEvent):void
		{
			if(Number(event.keyCode) <=48 || Number(event.keyCode) >= 122)return;
			var w:IWritable = event.currentTarget as IWritable;
			for(var i:uint=0;i<pulseList.length;i++)
			{
				if(pulseList.getItemAt(i).id == w.id)
				{
					setCurrent(i);
				}
			}
			next();
			pulse();
		}
		
		/**
		 * @private
		 */
		protected static function onFinishedPlaying(event:Event):void
		{
			if(debug)
				trace("(pulseList): sound finished event");
			var s:MP3Audio = event.currentTarget as MP3Audio;
			var b:IClickable = s.parent as IClickable;
			//get to the current index position
			if(debug)
				trace("(pulseList): get current index");
			for(var i:uint=0;i<pulseList.length;i++)
			{
				try
				{
					if(pulseList.getItemAt(i).id == b.id)
					{
						if(debug)
							trace("(pulseList): found, change current to" + i);
						
						setCurrent(i);
					}	
				} 
				catch(error:Error) 
				{
					if(debug)
						trace("(pulseList): error at: " + event.currentTarget);
				}
				
			}
			//look for the next AND PULSE IT
			next();
			pulse();			
		}
		
		
		/**
		 * @private
		 */
		protected static function setCurrent(index:uint):void
		{
			if(index < pulseList.length)
				current = index;
			
		}
	}
}