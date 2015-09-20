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
package views
{
	import interfaces.ICustomEventDispatcher;
	import interfaces.IDisposable;
	
	import mx.collections.ArrayList;
	import mx.events.FlexEvent;
	import mx.states.State;
	
	import spark.components.Group;
	
	/**
	 * Baseclass for all view components. Provides the minimum of functionality of a view to ensure proper component cycling.
	 */
	public class AbstractView extends Group implements ICustomEventDispatcher, IDisposable
	{
		
		/**
		 * A list of references objects for proper unloading.
		 */
		protected var _references:ArrayList;

		/**
		 * Array of strings with names of the states, which already have been initialized to prevent unwanted or unnecessary reloading. Reloading can still be reinforced.
		 */
		protected var _states_initialized:Array;

		
		/**
		 * A reference to the previous state to enable switching back.
		 */
		protected var last_state:String;

		
		/**
		 * Constructor initializes references and adds listeners.
		 */
		public function AbstractView()
		{
			super();
			_references = new ArrayList();
			addEventListener(FlexEvent.CREATION_COMPLETE, updateStates);
		}
		
		

		/**
		 * Abstract method. Override in child classes.
		 */
		public function unload():void
		{
			throw new Error("Unoveridden method in abstract class");
		}
		
		
		/**
		 * Returns, whether the current state is initialized or not.
		 */
		public function getcurrentStateIsInitialized():Boolean
		{
			for (var i:int = 0; i < states.length; i++) 
			{
				if(State(states[i]).name == currentState)
				{
					return _states_initialized[i];
				}
			}
			return false;
		}
		
		/**
		 * Sets the current state as initialized or uninitialized.
		 */
		public function setcurrentStateIsInitialized(value:Boolean):void
		{
			for (var i:int = 0; i < states.length; i++) 
			{
				if(State(states[i]).name == currentState)
				{
					_states_initialized[i] = value;
				}
			}
		}
		
		
		/**
		 * @private
		 */
		protected function updateStates(event:FlexEvent):void
		{
			removeEventListener(FlexEvent.CREATION_COMPLETE, updateStates);
			_states_initialized = new Array(states.length);
			for (var i:int = 0; i < _states_initialized.length; i++) 
			{
				_states_initialized[i] = false;
			}
			
		}

		
		

		
		//---------------------------------------
		//
		//	EVENTDISPATCHER FUNCTIONS
		//
		//---------------------------------------
		//idea and concept by Justin Shacklette  www.saturnboy.com
		
		/**
		 * Event listener dictionary.
		 */
		protected var _listeners:Object = {};
		
		/**
		 * @inheritDoc
		 * @see Shared.EventDispatcher
		 */
		override public function addEventListener(type:String,listener:Function,useCapture:Boolean = false,priority:int =0,useWeakReference:Boolean = false):void
		{
			super.addEventListener(type,listener,useCapture,priority,useWeakReference);
			
			if(_listeners.hasOwnProperty(type))
			{
				(_listeners[type] as Array).push(listener);
			}else{
				_listeners[type] = [listener];
			}
		}
		
		//idea and concept by Justin Shacklette  www.saturnboy.com
		/**
		 * @inheritDoc
		 * @see Shared.EventDispatcher
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
		
		//idea and concept by Justin Shacklette  www.saturnboy.com
		/**
		 * @inheritDoc
		 * @see Shared.EventDispatcher
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
		 * @see Shared.EventDispatcher
		 */
		public function hasAtLeastOneListener():Boolean
		{
			if(_listeners is Array && _listeners.length != 0)
			{
				return true;
			}
			return false;
		}

		
	}
}