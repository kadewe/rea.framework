/*

"Rich E-Assesment (REA) Framework"
A software framework for the use within the domain of e-assessment.

Copyright (C) 2014  University of Bremen, 
Working Group education media | media education 

Prof. Dr. Karsten Wolf, wolf@uni-bremen.de
Dipl.-Päd. Ilka Koppel, ikoppel@uni-bremen.de
Dipl.-Math. Kai Schwedes, kais@zait.uni-bremen.de
B.Sc. Jan Küster, jank87@tzi.de

Idea and concept by Justin Shacklette, (http://saturnboy.com/2010/03/event-listeners-in-flex-4/)

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
package events
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import interfaces.ICustomEventDispatcher;
	
	
	/**
	 * This class overrides the eventdispatcher to allow a removal of all eventListeners of an Object.
	 * Idea and concept by Justin Shacklette, (http://saturnboy.com/2010/03/event-listeners-in-flex-4/)
	 */
	public class CustomEventDispatcher extends flash.events.EventDispatcher implements ICustomEventDispatcher
	{
		private var _listeners:Object = {};
		public function CustomEventDispatcher(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		
		/**
		 * Overridden to manage an interal list of listeners, updated on
		 * every add.
		 */
		override public function addEventListener(type:String,listener:Function,useCapture:Boolean = false,priority:int=0,useWeakReference:Boolean = false):void
		{
			super.addEventListener(type,listener,useCapture,priority,useWeakReference);
			if(_listeners.hasOwnProperty(type))
			{
				(_listeners[type] as Array).push(listener);
			}else{
				_listeners[type] = [listener];
			}
		}
		
		/**
		 * Overridden to manage an interal list of listeners, updated on
		 * every delete.
		 */
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			super.removeEventListener(type,listener,useCapture);
			
			if(_listeners.hasOwnProperty(type))
			{
				var listeners:Array = _listeners[type] as Array;
				if(listeners.length<=1)
				{
					delete _listeners[type];
				}else{
					var idx:int = listeners.indexOf(listener);
					if(idx !=1)
					{
						listeners.splice(idx,1);
					}
				}
			}
		}
		
		/**
		 * Remove all listeners of a given event type, if type is blank
		 * remove everything.
		 */
		public function removeAllEventListeners(type:String = ''):void 
		{
			if (type.length == 0) 
			{
				for (var t:String in _listeners) 
				{
					removeAllEventListeners(t);
				}
			} else if (_listeners.hasOwnProperty(type)) {
				if (hasEventListener(type)) 
				{
					for each (var listener:Function in _listeners[type]) 
					{
						removeEventListener(type, listener);
					}
				}
			}
		}
		
		/**
		 * Return debug info about listeners
		 */
		public function getDebug():String {
			var s:String = '';
			var count:int = 0;
			for (var type:String in _listeners) {
				var len:int = (_listeners[type] as Array).length;
				s += type + ' (len=' + len + ")\n";
				count += len;
			}
			return 'Listeners (count=' + count + ')\n' + s;
		}
	}
}