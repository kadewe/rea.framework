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
package trackers
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayList;
	import mx.graphics.codec.PNGEncoder;
	import mx.utils.Base64Encoder;
	
	import spark.components.Group;
	import spark.components.Image;
	
	
	/**
	 * The InputTracker Class provides static methods for logging user input. Its underlying strucutre is an internal model, see <code>InputTrackerModel</code>, which buffers the log entries until the <code>sendLog</code> is called. The model is also a dynamic object which is refreshed autmatically, once the old log is send to the server.
	 */
	public class InputTracker
	{
		
		//-------------------------------------------------------------------
		//
		//
		//		VARIABLES
		//
		//
		//-------------------------------------------------------------------
		
		private static var model:InputTrackerModel=null; 
		
		private static var _global:XML;
		
		//-------------------------------------------------------------------
		//
		//
		//		FUNCTIONS
		//
		//
		//-------------------------------------------------------------------
		
		/**
		 * Adds a log entry to the internal log model. Beware that null objects are logged with a null entry instead of empty strings.
		 * 
		 * @param currentView The current state of a model's view component. Use the returnCurrentState() Method, implemented by ICustomModule get the the actual viewstate
		 * @param mousePosX allows you to log the mouseposition x axis as a unsigned integer
		 * @param mousePosY allows you to log the mouseposition Y axis as a unsigned integer
		 * @param currentEvent Does not need to be an eventType. You may also write things like "click" or "module start" or whatever you might want to log.
		 * @param eventTarget Does not need to be an even target Object (if so, use <code>event.target.id</code> if possible). You may also write things like "Start Button" or whatever you want to log.
		  */
		public static function logEvent(currentView:String,mousePosX:uint,mousePosY:uint,currentEvent:String,eventTarget:String):void
		{
			checkModel();
			model.addLog(currentView,mousePosX,mousePosY,currentEvent,eventTarget);
		}
		
		
		/**
		 * Makes the model merge its subclasses and builds the final result file, ready to be send to the server.
		 */
		public static function processLog():void
		{
			model.merge();
		}
		
		/**
		 * Sends the log to the given url via URLRequest. If navigate is true, the results can be viewed in a new browser window.
		 * <br />
		 * The data is passed in the following structure:
		 * <br />
		 * <code>param = "tracking"</code> (To let php indicate which script to include).
		 * <br />
		 * <code>type = String(model.returnType())</code>
		 * <br />
		 * <code>id = String(model.returnUser())</code> (In this case id means userid)
		 * <br />
		 * <code>xml = model.returnFinal()</code>(The final xml content to be send) 
		 * 
		 */
		public static function sendLog(url:String,navigate:Boolean=false):void
		{
			
			var encoded:String="";
			var paths:String="";
			try
			{
				trace("SEND LOG::::::");
				var  screens:ArrayList = model.returnImages();
				trace("screenshots:"+screens.length);
				var png:PNGEncoder = new PNGEncoder();
				var base:Base64Encoder = new Base64Encoder();

				for(var i:int=0;i<screens.length;i++)
				{
					var g:Group = new Group();
					var a:Array = screens.getItemAt(i) as Array;
					trace(a[0]+ " "+a[1]);
					var im:Image = a[0];
					g.addElement(im);
					var b:ByteArray = png.encode(im.bitmapData);
					base.encodeBytes(b);
					var str:String = base.drain();
					encoded+=(str+"#");
					paths+=(a[1]+"#");
				}
				trace(encoded.length);
				trace(paths.length);
			} 
			catch(error:Error) 
			{
				trace("error writing images");
			}

			//send urlrequest to server
			var l:URLLoader = new URLLoader();
			var u:URLRequest = new URLRequest(url);
			var data:URLVariables = new URLVariables();
			u.method = URLRequestMethod.POST;
			u.data = data;
			data.param = 'tracking';
			data.type=model.returnType();
			data.sub = model.returnSubType();
			data.id = model.returnUser();
			data.xml=model.returnFinal();
			data.images=encoded;
			data.paths=paths;
			l.load(u);
			
			var s:String = navigate==true?"new":null;
			if(navigate)
				navigateToURL(u,"new");
			
			model.unload();
			model = null;
		}
		
		/**
		 * Defines additional meta information (ModuleType, what is the actual module in front of the user).
		 */
		public static function setModuleType(arg:*):void
		{
			checkModel();
			model.addType(arg);
			initGlobals();
		}
		
		public static function newView(viewName:String,screenshot:Image):void
		{
			checkModel();
			model.addView(viewName,screenshot);
		}
		
		
		
		/**
		 * Defines additional meta information (ModuleSubType, specially for itemnumbers).
		 */
		public static function setModuleSubType(arg:*):void
		{
			checkModel();
			model.addSubType(arg);
		}

		/**
		 * Defines a user id for the log file
		 */
		public static function setUser(arg:*):void
		{
			checkModel();
			model.addUser(arg);
		}
		
	
		
		public static function setGlobalSettings(globals:XML):void
		{
			_global = globals;
			initGlobals();
		}
		// PRIVATE
		
		private static function checkModel():void
		{
			model =  model==null?new InputTrackerModel():model;
		}
		
		
		private static function initGlobals():void
		{
			
			checkModel();
			model.addGlobals(_global);
		}
		
	}
}