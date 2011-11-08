
package Shared
{
	import Interfaces.ICustomEventDispatcher;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	
	/**
	 * This class overrides the eventdispatcher to allow a removal of all eventListeners of an Object.
	 * Idea and concept by Justin Shacklette, Copyright holds Justin Shacklette www.saturnboy.com
	 */
	public class EventDispatcher extends flash.events.EventDispatcher implements ICustomEventDispatcher
	{
		private var _listeners:Object = {};
		public function EventDispatcher(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		//idea and concept by Justin Shacklette  www.saturnboy.com
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
		
		//idea and concept by Justin Shacklette  www.saturnboy.com
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
	}
}