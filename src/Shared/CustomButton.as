package Shared
{
	import Interfaces.IClickableComponent;
	import Interfaces.ICustomEventDispatcher;
	
	import spark.components.Button;

	
	/**
	 * An extended Button class, implementing the minimum criteria for linking to other objects and removeAllEventListeners function.
	 * <p>Most buttons in this Application will extend this</p>
	 */
	public class CustomButton extends Button implements ICustomEventDispatcher, IClickableComponent
	{
		private var _listeners:Object = {};
		private var _referringTo:Object = null;
		private var _visibleReference:Object =null;
		
		/**
		 * empty constructor
		 */
		public function CustomButton()
		{
			super();
		}
		
		/**
		 * get the reference to the linked object
		 */
		public function get referringTo():Object
		{
			return _referringTo!=null?_referringTo:new Object();
		}
		
		
		/**
		 * gets a reference to a linked visible object
		 */
		public function get visibleReference():Object
		{
			return _visibleReference!=null?_visibleReference:new Object();
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
		 * sets a reference to a linked visible object
		 */
		public function set visibleReference(value:Object):void
		{
			if(_visibleReference!=value)
				_visibleReference=value;
		}
		
		//idea and concept by Justin Shacklette  www.saturnboy.com
		/**
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