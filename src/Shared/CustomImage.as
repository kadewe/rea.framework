package Shared
{
	import Interfaces.ICustomEventDispatcher;
	
	import enumTypes.ErrorTypeEnum;
	import enumTypes.PHPParameterTypeEnum;
	
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;
	import mx.controls.Image;
	
	/**
	 * Basic class which automatically loads an image from url and catches errors as well as allows a dynamic adding or removing of eventlisteners. Be aware, that it requires the data as a base64 string.
	 */
	public class CustomImage extends Image implements ICustomEventDispatcher
	{
		//---------------------------------------
		//
		//	VARIABLES
		//
		//---------------------------------------
		
		public static const CREATION_COMPLETE:String = "creationcomplete";
		
		private var loader:URLLoader;
		private var req:URLRequest;
		private var debug:Boolean;
		
		private var _listeners:Object = {};
		private var d:MyBase64Decoder;
		private var b:ByteArray;
		
		//---------------------------------------
		//
		//	PUBLIC FUNCTIONS
		//
		//---------------------------------------
		
		/**
 		* 	Constructor. Requires an url and a relative path to the image file. Will automatically loads the image as a base64 string and decodes it to an image source.
		*
		 * @param	scripturl	the url to the script which loads the image
		 * @param	relPath		the path parameter passed to the url via POST
		 * @param 	navigate	for debugging purposes, navigates to the url of the script
 		*/
		public function CustomImage(scriptUrl:String,relPath:String,navigate:Boolean=false)
		{
			super();
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onLoadComplete);
			
			var v:URLVariables = new URLVariables();
			v.param = PHPParameterTypeEnum.GET_IMAGE.getValue();
			v.imagePath = relPath;
			
			req= new URLRequest(scriptUrl);
			req.data = v;
			
			req.method = URLRequestMethod.POST;
			try
			{
				loader.load(req);
				if(navigate)
					navigateToURL(req,"new");
			}catch(e:Error){
				if(debug)
					Alert.show("loading error "+e.message);
				ErrorDispatcher.processNewError(
					ErrorTypeEnum.URL_INVALID_ERROR.getNumber().toString(),
					ErrorTypeEnum.URL_INVALID_ERROR.getValue(),
					e.errorID.toString(),
					e.name,
					"CustomImage.as -->"+relPath,
					scriptUrl,
					false
				);
				//fallback
				unload();
			}
		}
		
		/**
		 * sets the debug value to the desired value true or fals
		 * 
		 * @param value the new value for the components debugmode
		 */
		public function setDebug(value:Boolean):void
		{
			debug = value;
		}
		
		
		//---------------------------------------
		//
		//	PRIVATE FUNCTIONS
		//
		//---------------------------------------
		
		/**
		 * @private
		 */
		private function onLoadComplete(event:Event):void
		{
			loader.removeEventListener(Event.COMPLETE, onLoadComplete);
			if(loader.data!="failed")
			{
				d = new MyBase64Decoder();
				d.addEventListener(MyBase64Decoder.BYTES_CONVERTED, onDecodingFinished);
				d.decode(loader.data.toString());
			}else{
				trace("[CUSTOMIMAGE]: data transfer failed");
			}
		}
		
		/**
		 * @private
		 */
		private function onDecodingFinished(event:Event):void
		{
			d.removeEventListener(MyBase64Decoder.BYTES_CONVERTED, onDecodingFinished);
			b = d.toByteArray();
			this.source = b;
			
			dispatchEvent(new Event(CREATION_COMPLETE));
			
			unload();
		}
		
		/**
		 * @private
		 */
		private function unload():void
		{
			loader = null;
			req = null;
			d = null;
			
		}
		
		//----------------------------------------------------
		//
		//	ICUSTOMEVENTDISPATCHER Functions
		//
		//----------------------------------------------------
		
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