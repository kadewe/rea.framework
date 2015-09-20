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
package components
{
	import interfaces.IClickable;
	import interfaces.ICustomEventDispatcher;
	import interfaces.IDisposable;
	import interfaces.IInteractiveVisual;
	
	import spark.components.Button;

	
	/**
	 * <p>An extended Button class with Extended Event Dispatcher methods (removeAll) and references to other objects.</p>
	 * <p>All buttons in this Application will extend this class.</p>
	 */
	public class ReaButton extends Button implements ICustomEventDispatcher, IClickable,IInteractiveVisual,IDisposable
	{
		/**
		 * Constructor, calls super constructor.
		 */
		public function ReaButton()
		{
			super();
		}
		
		//---------------------------------------
		//
		//	VARIABLES
		//
		//---------------------------------------
		
		/**
		 * @private listeners object for extended event dispatcher
		 */
		private var _listeners:Object = {};
		
		/**
		 * @private DEPRECATED! Use AbstractSoundButton for sound reference
		 */
		private var _referringTo:Object = null;
		
		/**
		 * getS the reference to the linked object
		 */
		public function get referringTo():Object
		{
			return _referringTo;
		}
		
		/**
		 * sets a reference to a linked object
		 */
		public function set referringTo(value:Object):void
		{
			if(_referringTo!=value)
				_referringTo = value;
		}
		
		/**
		 * @private a reference to a visual element, used by VisibleList
		 */
		private var _visibleReference:Object =null;
		
		/**
		 * a reference to a linked visible object
		 */
		public function get visibleReference():Object
		{
			return _visibleReference!=null?_visibleReference:new Object();
		}
		
		/**
		 * sets a reference to a linked visible object
		 */
		public function set visibleReference(value:Object):void
		{
			if(_visibleReference!=value)
				_visibleReference=value;
		}
		
		//---------------------------------------
		//
		//	PUBLIC FUNCTIONS
		//
		//---------------------------------------

		/**
		 * @inheritDoc
		 */
		override public function stylesInitialized():void
		{
			super.stylesInitialized();
			
			//setStyle("skinClass", CustomButtonSkin); //use custom skin class
		}
		
		
		/**
		 * Unloads referred objects. Implements IDisposable
		 */
		public function unload():void
		{
			_referringTo = null;
			_visibleReference = null;
		}
		

		/**
		 * @private deprecated!
		 */
		public function getFiltersArray():Array
		{
			return filters;
		}
		
		/**
		 * @private deprecated!
		 */
		public function setFiltersArray(newFilters:Array=null):void
		{
			this.filters = newFilters;
		}
		
		//---------------------------------------
		//
		//	EVENTDISPATCHER FUNCTIONS
		//
		//---------------------------------------
		//idea and concept by Justin Shacklette  www.saturnboy.com
		
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