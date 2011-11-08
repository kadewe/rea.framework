package Model
{
	import Shared.ErrorDispatcher;
	import Shared.EventDispatcher;
	
	import enumTypes.ErrorTypeEnum;
	import enumTypes.PHPParameterTypeEnum;
	
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;
	
	import mx.controls.Alert;

	
	/**
	 * This class represents the login session of a certain user. The information are stored temporarily and usually written in an xml file which will be permanently send to the server.
	 */
	public class UserObject extends Shared.EventDispatcher
	{
		public var userName:String;
		public var relUrl:String;
		private var path:String;
		private var navigate:Boolean;
		
		public var userData:XML;		//contains performed tasks

		protected var _test:XMLList;
		protected var tempTimeStamp:String;
		
		private var debug:Boolean=false;
		
		protected var state:Number = 0;
		
		private var references:Array = new Array();
		
		public static const CREATION_COMPLETE:String = "creationComplete";
		public static const CREATION_ERROR:String = "creationError";
		
		private var loader:URLLoader;
		private var req:URLRequest;
		
		//--------------------------------------------------------//--------------------------------------------------------
		//
		//													PUBLIC FUNCTIONS
		//
		//--------------------------------------------------------//--------------------------------------------------------
		
		/**
		 * Constructor, initializes the <code>URLLoader</code> but does not call its <code>load()</code> function.
		 * 
		 * @param scriptUrl the include script (php) on the server
		 * @param _id the user id from the login
		 * @param navigate2url for debugging purposes, opens the navigated url in a new tab or window to enable a view of php echos or error messages
		 */
		public function UserObject(scriptUrl:String,_id:String,navigate2url:Boolean=false)
		{
			trace("[userobject]: load userdata ==> from "+ scriptUrl + " with " + _id);
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, handleUserXML);
			userName = _id;
			relUrl = scriptUrl;
			navigate=navigate2url;
		}
		

		
		/**
		 * First adds variables to the URLLoader to define the parameter for the include script and the Post variable userid then starts the request.
		 */
		public function load():void
		{
			var v:URLVariables = new URLVariables();
			v.param = PHPParameterTypeEnum.GET_USERDATA.getValue();
			v.userid = userName;
			
			req= new URLRequest(relUrl);
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
					"UserObject.as -->"+userName,
					relUrl,
					false
				);
				//fallback
			}
		}	


		
		/**
		 * Constructs a new entry for the actual Dimension and level, chosen by the user into. Calls the private <code>updateUserXML(scriptUrl)</code> function, 
		 * to send the updated xml to php.
		 * 
		 * @param itemList An array of all item names within the chosen dimension and level
		 * @param dimension the chosen dimension or sometimes called subject
		 * @param level the level of difficulty
		 * @param scriptUrl the directlink to the php script, which will handle the data
		 * 
		 * @see #updateUserXML()
		 */	
		public function startSession(itemList:Array,dimension:String,level:String,scriptUrl:String):void
		{
			
			//create  timestamp
			var d:Date = new Date();
			var stamp:String = d.getFullYear().toString() + "_" 	// year_ 
				+ (d.getMonth()+1).toString() + "_" 		// month_
				+ d.getDate().toString() + "_" 				// date_
				+ d.getHours().toString() + "_" 		// hour_
				+ d.getMinutes().toString() + "_"		// minute_
				+ d.getSeconds().toString();			//seconds
			//create xml node
			var tmp:String = "<test timestamp='" + stamp + "' subject='" + dimension + "' level='" + level + "'></test>";
			var test:XMLList = XMLList(tmp);
			//append items from list
			for(var i:uint = 0; i<itemList.length;i++)
			{
				var t:String = "<item iname='" + itemList[i] + "' data='' />";
				test.appendChild(XML(t));
			}
			//append note to user xml
			userData.appendChild(test);
			updateUserXML(scriptUrl);
		}
		
		
		/**
		 * Updates a session by adding an entry at the data attribute of the item tag. (After item was completed) The entry consists of the
		 * userName, the timestamp and the itemnumber and the ending <code>.xml</code>. 
		 * <p>This sequence will also be the name of the immediate path to the completed item xml file, which usually will be placed in the same directory as the user xml file</p>
		 * <p>Calls the private function   <code>updateUserXML(scriptUrl)</code> to send the data to the server.</p>
		 */
		public function updateSession(item:String,timestamp:String,finalXml:XML,scriptUrl:String):void
		{
			//update final xml
			updateItemXML(item,timestamp,finalXml,scriptUrl);
			trace("UPDATE USER XML");
			//update entry in user xml
			var testList:XMLList = userData.test as XMLList;
			for(var i:uint=0;i<testList.length();i++)	//--------------------------// Check all Collections
			{
				var itemList:XMLList = testList[i].children();
				for(var j:uint=0;j<itemList.length();j++)	//--------------------------// Check all Items in a collection
				{
					if(itemList[j].@iname == item && itemList[j].@data=="") //--------------------------// if item found
					{
						itemList[j].@data = userName + "_" + timestamp+ "_" + item + ".xml";	// new Entry
					}
				}
			}
			trace(testList);
			userData = new XML("<performedtests></performedtests>");
			userData.appendChild(testList);
			updateUserXML(scriptUrl);
		}
		
		/**
		 * returns the userdata as an xml object
		 * 
		 * @returns user data file as an xml object
		 */
		public function get _userData():XML
		{
			return this.userData;
		}
		
		public function setDebug(value:Boolean):void
		{
			debug = value;
		}
		

		

		
		//--------------------------------------------------------//--------------------------------------------------------
		//
		//													PRIVATE FUNCTIONS
		//
		//--------------------------------------------------------//--------------------------------------------------------
		
		
		/**
		 * @private
		 */
		private function handleUserXML(event:Event):void
		{
			if(loader.data =="failed")
			{
				trace("[userobject]: user data failed, check your server paths! Will create now new directory");
				//error
				ErrorDispatcher.processNewError
					(
						ErrorTypeEnum.URL_INVALID_ERROR.getNumber().toString(),
						ErrorTypeEnum.URL_INVALID_ERROR.getValue(),
						"no flash error",
						"invalid userdata database entry or wrong url",
						"UserObject.as -->"+userName,
						this.relUrl,
						false
					); 
				//write fallback
				dispatchEvent(new Event(CREATION_ERROR));
			}else{
				userData = XML(loader.data);
				trace("[userobject]: user data received successfully");
			}
			unload();
		}
		
		
		
		/**
		 * @private
		 */
		private function updateItemXML(item:String,timestamp:String,finalXml:XML,scriptUrl:String):void
		{
			loader = new URLLoader();
			var v:URLVariables = new URLVariables();
			v.param = PHPParameterTypeEnum.SEND_FINAL_XML.getValue();
			v.user = userName;
			v.xmlFile = finalXml;
			v.date = timestamp;
			v.item = item;
			
			req= new URLRequest(scriptUrl);
			req.data = v;
			
			req.method = URLRequestMethod.POST;
			try
			{
				loader.load(req);
			}catch(e:Error){
				if(debug)
					Alert.show("loading error "+e.message);
				ErrorDispatcher.processNewError(
					ErrorTypeEnum.URL_INVALID_ERROR.getNumber().toString(),
					ErrorTypeEnum.URL_INVALID_ERROR.getValue(),
					e.errorID.toString(),
					e.name,
					"UserObject.as -->"+PHPParameterTypeEnum.SEND_FINAL_XML.getValue(),
					relUrl,
					false
				);
				//fallback
			}
		}
		
		/**
		 * @private
		 */
		private function updateUserXML(scriptUrl:String):void
		{
			loader=new URLLoader();
			var v:URLVariables = new URLVariables();
			v.param = PHPParameterTypeEnum.UPDATE_USER.getValue();
			v.user = userName;
			v.xml = userData;
			
			req= new URLRequest(scriptUrl);
			req.data = v;
			
			req.method = URLRequestMethod.POST;
			try
			{
				loader.load(req);
			}catch(e:Error){
				if(debug)
					Alert.show("loading error "+e.message);
				ErrorDispatcher.processNewError(
					ErrorTypeEnum.URL_INVALID_ERROR.getNumber().toString(),
					ErrorTypeEnum.URL_INVALID_ERROR.getValue(),
					e.errorID.toString(),
					e.name,
					"UserObject.as -->"+PHPParameterTypeEnum.UPDATE_USER.getValue(),
					relUrl,
					false
				);
				//fallback
			}	
		}
		
		/**
		 * @private
		 */
		private function onUpdateComplete(event:Event):void
		{
			unload();
		}
		
		/**
		 * @private
		 */
		private function unload():void
		{
			loader = null;
			req = null;
		}
		
	
		

	}
}