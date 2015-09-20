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
	import enums.GlobalConstants;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;
	import flash.utils.ByteArray;
	
	import interfaces.ICustomEventDispatcher;
	import interfaces.IDisposable;
	import interfaces.IIdentifiable;
	
	import mx.controls.Alert;
	
	import spark.components.Image;
	
	import trackers.ErrorDispatcher;
	
	import utils.MyBase64Decoder;

	
	
	/**
	 * This class extends spark image with framework compliance and a base 64 decoding. Thus, it requires the data as a base64 string. 
	 */
	public class ReaImage extends Image implements ICustomEventDispatcher,IIdentifiable, IDisposable
	{
		//---------------------------------------
		//
		//	VARIABLES
		//
		//---------------------------------------
		
		/**
		 * Image has been decoded completeley
		 */
		public static const IMAGE_DECODED_COMPLETE:String = "creationcomplete";
		
		
		protected var loader:URLLoader;
		protected var req:URLRequest;
		protected var debug:Boolean;
		
		protected var _listeners:Object = {};
		protected var decoder:MyBase64Decoder;
		protected var byteArray:ByteArray;
		
		protected var imageLoader:Loader;
		
		//---------------------------------------
		//
		//	CONSTRUCTOR
		//
		//---------------------------------------
		
		/**
 		* 	Constructor. Requires an url and a relative path to the image file. Will automatically load the image as a base64 string and decode it to an image source.
		*
		 * @param	scripturl	the url to the script which loads the image
		 * @param	relPath		the path parameter passed to the url via POST
		 * @param 	navigate	for debugging purposes, navigates to the url of the script
 		*/
		public function ReaImage(scriptUrl:String,relPath:String,navigate:Boolean=false)
		{
			super();
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onLoadComplete);
			
			var v:URLVariables = new URLVariables();
				v.param = GlobalConstants.GET_IMAGE;
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
					"1",
					GlobalConstants.URL_INVALID_ERROR,
					e.errorID.toString(),
					e.name,
					"CustomImage.as -->"+relPath,
					scriptUrl,
					false
				);
				//fallback
				flush();
			}
		}
		

		
		//---------------------------------------
		//
		//	PUBLIC FUNCTIONS
		//
		//---------------------------------------
		
		/**
		 * sets the debug value to the desired value true or fals
		 * 
		 * @param value the new value for the components debugmode
		 */
		public function setDebug(value:Boolean):void
		{
			debug = value;
		}
		
		
		/**
		 * @inherentDoc
		 */
		public function unload():void
		{
			flush();
			if(bitmapData!=null)bitmapData.dispose();
		}
		
		
		//---------------------------------------
		//
		//		PROTECTED FUNCTIONS
		//
		//---------------------------------------
		
		
		/**
		 * @protected
		 */
		protected function flush():void
		{
			if(loader)loader = null;
			if(req)req = null;
			if(decoder)
			{
				decoder.flush();
				decoder.reset();
				decoder = null;
			}
			if(imageLoader)imageLoader = null;
			if(byteArray)
			{
				byteArray.clear();
				byteArray = null;
			}
			
		}
		
		//---------------------------------------
		//
		//	EVENTS
		//
		//---------------------------------------
		
		/**
		 * @private
		 */
		protected function onLoadComplete(event:Event):void
		{
			loader.removeEventListener(Event.COMPLETE, onLoadComplete);
			if(loader.data!="failed")
			{
				imageLoader = new Loader();
				decoder = new MyBase64Decoder();
				decoder.addEventListener(MyBase64Decoder.BYTES_CONVERTED, onDecodingFinished);
				decoder.decode(loader.data.toString());
			}else{
				trace("[CUSTOMIMAGE]: data transfer failed:");
				trace(loader.data);
			}
		}
		
		/**
		 * @private
		 */
		protected function onDecodingFinished(event:Event):void
		{
			decoder.removeEventListener(MyBase64Decoder.BYTES_CONVERTED, onDecodingFinished);
			byteArray = decoder.toByteArray();
			imageLoader.visible=false;
			imageLoader.loadBytes(byteArray);	
			imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onbytesloaded);
			
		}
		
		/**
		 * @private
		 */
		protected function onbytesloaded(event:Event):void
		{
			imageLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onbytesloaded);
			source = imageLoader.content;
			smooth = true;
			dispatchEvent(new Event(IMAGE_DECODED_COMPLETE));
			flush();
		}
		
		//---------------------------------------
		//
		//	EVENTDISPATCHER FUNCTIONS
		//
		//---------------------------------------
				
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