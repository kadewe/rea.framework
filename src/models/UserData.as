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
package models
{
	import enums.GlobalConstants;
	
	import events.CustomEventDispatcher;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;
	
	import mx.controls.Alert;
	
	import trackers.ErrorDispatcher;
	
	import utils.StringUtils;

	
	/**
	 * This class represents the login session of a certain user. The information are stored temporarily and usually written in an xml file 
	 * which will be send permanently to the server.
	 */
	public class UserData extends events.CustomEventDispatcher
	{
		//---------------------------------------
		//
		//	CONSTRUCTOR
		//
		//---------------------------------------
		
		/**
		 * Constructor. Empty.
		 */
		public function UserData()
		{
			
		}
		
		
		//---------------------------------------
		//
		//	VARIABLES
		//
		//---------------------------------------
		
		/**
		 * Disptached when the data has been loaded and the user has been created.
		 */
		public static const CREATION_COMPLETE:String = "creationComplete";
		
		/**
		 * Dispatched when something went wrong
		 */
		public static const CREATION_ERROR:String = "creationError";
		
		/**
		 * The id of the user
		 */
		public var userName:String;
		

		protected var _userData:XML;
		
		/**
		 * returns the userdata as an xml object
		 * 
		 * @returns user data file as an xml object
		 */
		public function get userData():XML
		{
			return this._userData;
		}
		
		
		
		/**
		 * @private
		 */
		private var relUrl:String;
		
		private var _test:XMLList;
		
		private var state:Number = 0;
		
		private var path:String;
		
		private var navigate:Boolean;
		
		private var currentSessionTimeStamp:String;
		
		private var _prev:String;
		
		private var debug:Boolean=false;
		
		private var references:Array = new Array();
		
		private var loader:URLLoader;
		
		private var req:URLRequest;
		
		private var _prepared:Boolean; 
		


	
		
		//---------------------------------------
		//
		//	PUBLIC FUNCTIONS
		//
		//---------------------------------------
		
		/**
		 * prepares the user object class for loading the user file.
		 */
		public function prepare(scriptUrl:String,_id:String,navigate2url:Boolean=false):void
		{
			trace("[userobject]: load userdata ==> from "+ scriptUrl + " with " + _id);
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, handleUserXML);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecError);
			userName = _id;
			relUrl = scriptUrl;
			navigate=navigate2url;
			_prepared= true;
		}
		
		/**
		 * Loads the user file from external server.Throws error if not prepare() has been called before.
		 */
		public function load():void
		{
			if(!_prepared)throw new Error("UserObject is not prepared: load method has been called before preapre method.");
			var v:URLVariables = new URLVariables();
				v.param = GlobalConstants.GET_USERDATA;
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
					GlobalConstants.URL_INVALID_ERROR,
					GlobalConstants.URL_INVALID_ERROR,
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
			
			currentSessionTimeStamp = StringUtils.get_timestamp();
			//create xml node
			var tmp:String = "<test timestamp='" + currentSessionTimeStamp + "' subject='" + dimension + "' level='" + level + "'" 
			if(_prev && _prev.length > 0)
			{
				tmp+=" prev='" + _prev + "'"; 
			}
				tmp+="></test>";
			var test:XMLList = XMLList(tmp);
			//append items from list
			for(var i:uint = 0; i<itemList.length;i++)
			{
				if(itemList[i].toString().charAt(0)!="t")
				{
					var t:String = "<item iname='" + itemList[i] + "' data='' />";
					test.appendChild(XML(t));	
				}
				
			}
			//append note to user xml
			userData.appendChild(test);
			
			unsetPrev();
			
			updateUserXML(scriptUrl);
			
			
		}
		
		public function unsetPrev():void
		{
			_prev="";
		}
		
		
		/**
		 * Updates a session by adding an entry at the data attribute of the item tag. (After item was completed) The entry consists of the
		 * userName, the timestamp and the itemnumber and the ending <code>.xml</code>. 
		 * <p>This sequence will also be the name of the immediate path to the completed item xml file, which usually will be placed in the same directory as the user xml file</p>
		 * <p>Calls the private function   <code>updateUserXML(scriptUrl)</code> to send the data to the server.</p>
		 */
		public function updateSession(item:String,timestamp:String,finalXml:XML,scriptUrl:String):void
		{
			if(item.charAt(0)=="t")
			{
				return;
			}
			//update final xml
			updateItemXML(item,timestamp,finalXml,scriptUrl);
			trace("UPDATE USER XML: "+item);
			//update entry in user xml
			var testList:XMLList = userData.test as XMLList;
			for(var i:uint=0;i<testList.length();i++)	//--------------------------// Check all Collections
			{
				if(testList[i].@timestamp == currentSessionTimeStamp)
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
				
			}
			//trace(testList);
			_userData = new XML("<performedtests></performedtests>");
			userData.appendChild(testList);
			updateUserXML(scriptUrl);
		}
		
		
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
		private function updateItemXML(item:String,timestamp:String,finalXml:XML,scriptUrl:String):void
		{
			if(item.charAt(0)=="t")
			{
				return;
			}
			loader = new URLLoader();
			var v:URLVariables = new URLVariables();
				v.param = GlobalConstants.SEND_FINAL_XML;
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
					"0",
					GlobalConstants.URL_INVALID_ERROR,
					e.errorID.toString(),
					e.name,
					"UserObject.as -->"+GlobalConstants.SEND_FINAL_XML,
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
			trace("update user:");
			//trace(userData.toXMLString());
			loader=new URLLoader();
			var v:URLVariables = new URLVariables();
				v.param = GlobalConstants.UPDATE_USER;
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
					"1",
					GlobalConstants.URL_INVALID_ERROR,
					e.errorID.toString(),
					e.name,
					"UserObject.as -->"+GlobalConstants.UPDATE_USER,
					relUrl,
					false
				);
				//fallback
			}	
		}
		
		
		public function last_solved_item(dimension:String, level:String):String
		{
			//trace("last solved:");
			//trace(userData.toXMLString());
			var performedtests:XMLList = userData..test;
			for (var i:int = performedtests.length()-1; i >= 0; i--) 
			{
				var test:XML = performedtests[i];						// <test timestamp="2014_6_17_11_0_8" subject="Lesen" level="Einfach">
				
				if( test.@subject == dimension && test.@level == level) // if match iterate items
				{
					//trace("last found: "+test.@timestamp);
					var items:XMLList = test.children();
				
					//EXAMPLE LIST:
					//<item iname="1.2.1" data=""/>
					//<item iname="1.2.2" data=""/>
					//<item iname="1.3.2" data=""/>
					if(String(items[items.length-1].@data).length > 0)return "";	//case 0: abort if collection has been solved
					
					//if(String(items[0].@data).length == 0 )continue;				//case a: skip if empty entry or already done, uncomment if only unaborted collections should be continued!
					
					
					var result:String="";
					var len:int = items.length();
					for (var j:int = 0; j < len; j++) 
					{
						var item:XML = items[j];
						//trace(item.toXMLString());
						if(String(item.@data).length>0 && j<len-1)
						{
							
							result = items[j+1].@iname;
							//trace("candidate: "+result);
						}
					}
					if(result.length>0)												//case b: entry found
					{
						_prev=(String(test.@timestamp));	//update prev entry in user xml
						return result;								
					}
				}
			}
			return "";
		}

		
		
		/**
		 * @private
		 */
		private function unload():void
		{
			try
			{
				loader.removeEventListener(Event.COMPLETE, handleUserXML);
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
				loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecError);
			}catch(e:Error){
				//fallback
			}
			loader = null;
			req = null;
		}
		

		
		
		//---------------------------------------
		//
		//	EVENTS
		//
		//---------------------------------------

		
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
						"1",
						GlobalConstants.URL_INVALID_ERROR,
						"no flash error",
						"invalid userdata database entry or wrong url",
						"UserObject.as -->"+userName,
						this.relUrl,
						false
					); 
				//write fallback
				dispatchEvent(new Event(CREATION_ERROR));
			}else{
				_userData = XML(loader.data);
				trace("[userobject]: user data received successfully");
			}
			trace("Print Data:");
			//trace(userData.toXMLString());
			dispatchEvent(new Event(CREATION_COMPLETE));
			unload();
		}
		
		
		private function onIOError(event:IOErrorEvent):void
		{
			unload();
			dispatchEvent(new Event(CREATION_ERROR));
		}
		
		private function onSecError(event:SecurityErrorEvent):void
		{
			unload();
			dispatchEvent(new Event(CREATION_ERROR));
		}
			
		/**
		 * @private
		 */
		private function onUpdateComplete(event:Event):void
		{
			unload();
		}
		
				

	}
}