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
	
	import interfaces.ICustomEventDispatcher;
	
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	

	/**
	 * This class loads the xml with the contained information about subjects, levels and item IDs and parse it into an XMLLIST. 
	 * <p>The data is read-only and will be written only once when the class will be initialized</p>
	 * <p>To overwirte the data, the class must be unloaded and be instanciated again</p>
	 * 
	 */
	public class TestCollection extends CustomEventDispatcher implements ICustomEventDispatcher
	{
		
		//---------------------------------------
		//
		//	CONSTRUCTOR
		//
		//---------------------------------------
		
		
		/**
		 * constructor, immediately initializes http service and loads the testcollection from the related Url
		 * 
		 * @param _relUrl the relative path to the xml file on the server, will be combined with the url String
		 */
		public  function TestCollection(relUrl:String,sourceUrl:String,scriptUrl:String):void
		{
			_scriptUrl = scriptUrl;
			_relUrl = relUrl;
			
			service.url = relUrl+scriptUrl;
			service.method = "POST";
			service.showBusyCursor=true;
			service.resultFormat = HTTPService.RESULT_FORMAT_XML;
			
			service.addEventListener(FaultEvent.FAULT,http_onFault);
			service.addEventListener(ResultEvent.RESULT,http_onResult);
			
			var a:Object =
			{
				param:GlobalConstants.GET_FILE,
				path:sourceUrl
			};
			
			service.request = a;
			
			trace("[TEST_COLLECTION]: url: "+service.url+"  path:"+sourceUrl);
			service.send();			
			
		}
		
		
		//---------------------------------------
		//
		//	VARIABLES
		//
		//---------------------------------------
		//-------------------------------//
		//	EVENTS
		//-------------------------------//
		public static const TC_BUILD:String = "tcBuild";
		public static const TC_ERROR:String = "tcError";

		//Loader Services//
		private var service:HTTPService = new HTTPService();
		private var loader:URLLoader;
		private var req:URLRequest;
		
		private static var url:String;
		private var _scriptUrl:String;
		private var _relUrl:String;
		
		//-------------------------------//
		// underlying Data Structure
		//-------------------------------//	
		private  var allDimensions:XMLList;	//XMLLIST BASE will never be changed!
		private var errorItems:Array;
		private var itemList:Array;
		private var itemIndex:uint;
		


		//---------------------------------------
		//
		//	PUBLIC FUNCTIONS
		//
		//---------------------------------------
		/**
		 * dispatched an error event and unloads the service.
		 */
		private function http_onFault(event:FaultEvent):void
		{
			trace("[TEST_COLLECTION]: loader fault => "+event.message);
			trace(event.fault);
			dispatchEvent(new Event(TC_ERROR));
			service.removeEventListener(FaultEvent.FAULT,http_onFault);
			service.removeEventListener(ResultEvent.RESULT,http_onResult);
			service = null;
		}
		
		/**
		 * unloads the service and converts the result into an xmllist object. Dispatched a complete event. 
		 */
		private function http_onResult(event:ResultEvent):void
		{
			trace("[TEST_COLLECTION]: url loader success "+ event.result);
			var x:XML = XML(event.result);
			if(!x)
			{
				trace("no x");
				dispatchEvent(new Event(TC_ERROR));
				return;
			}
			
			
			allDimensions = x.children();
			service.removeEventListener(FaultEvent.FAULT,http_onFault);
			service.removeEventListener(ResultEvent.RESULT,http_onResult);
			service = null;
			//init data
			errorItems = new Array();
			itemList = new Array();
			itemIndex = 0;
			parseCollection(false);
		}
		
		
		//-----------------------------------// testcollection rebuild //-----------------------------------// 
		
		private function parseCollection(checked:Boolean):void
		{
			//trace("=========== PARSE COLLECTION ===========");
			//iterate xmllist >>> itemList
			for(var i:uint=0;i<allDimensions.length();i++)
			{
				var colList:XMLList = allDimensions[i].children();
				for(var j:uint=0;j<colList.length();j++)
				{
					var items:XMLList = colList[j].children();
					for(var k:uint=0;k<items.length();k++)
					{
						if(!checked)
						{
							itemList.push(items[k].@iname);	
						}else{
							//rebuild
							for(var l:uint=0;l<errorItems.length;l++)
							{
								//trace(k +" "+ items[k].@iname + " "+l+" "+errorItems[l]);
								if(errorItems[l]==items[k].@iname && items[k].localName()=="item")
								{
									//trace("found and deleted"+items[k]);
									delete items[k];
									delete errorItems[l];
								}
							}
						}
					}
					colList[j].setChildren(items);
				}
				allDimensions[i].setChildren(colList);
			}
			//initialize checking process
			
			if(!checked)
			{
				checkProcess();	
			}else{
				//tc rebuild
				dispatchEvent(new Event(TC_BUILD));
			}			
		}
		

		
		private function checkProcess():void
		{
			if(itemIndex == itemList.length)
			{
				//process finished
				for(var i:uint=0;i<errorItems.length;i++)
				{
					trace("[TEST_COLLECTION]: error: "+errorItems[i]);
				}
				parseCollection(true);
			}else{
				checkScriptService(itemList[itemIndex]);
			}
		}
		
		
		
		private function checkScriptService(item:String):void
		{
			loader=new URLLoader();
			loader.addEventListener(Event.COMPLETE, onLoaderCompleteHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onIOErrorHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			
			//	variables / parameters	//
			var v:URLVariables = new URLVariables();
				v.param = GlobalConstants.CHECK_ITEM_DATA;
				v.itemid = item;
			
			req = new URLRequest(_relUrl + _scriptUrl);
			trace(req.url+ " ===> "+v.param);
			req.data = v;
			req.method = URLRequestMethod.POST;
			try
			{
				loader.load(req);
			}catch(e:Error){
				//fallback
			}	
		}
		
		
		private function onItemError():void
		{
			trace("[TEST_COLLECTION]: error: "+ itemList[itemIndex]);
			errorItems.push(itemList[itemIndex]);
			itemIndex++;
			checkProcess();
		}
		
		private function checkNext():void
		{
			trace("[TEST_COLLECTION]: success: "+ itemList[itemIndex]);
			itemIndex++;
			checkProcess();
		}
		
		
		//-----------------------------------// LOADER EVENTS //-----------------------------------// 
		
		private function onLoaderCompleteHandler(event:Event):void
		{
			loader.removeEventListener(Event.COMPLETE, onLoaderCompleteHandler);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onIOErrorHandler);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			if(loader.data!=itemList[itemIndex])
			{
				onItemError();
			}else{
				checkNext();
			}
			
		}
		
		
		private function onIOErrorHandler(event:IOErrorEvent):void
		{
			loader.removeEventListener(Event.COMPLETE, onLoaderCompleteHandler);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onIOErrorHandler);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			onItemError();
		}
		
		
		private function onSecurityError(event:SecurityErrorEvent):void
		{
			loader.removeEventListener(Event.COMPLETE, onLoaderCompleteHandler);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onIOErrorHandler);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			onItemError();
		}
		
		
		//--------------------------------------------------//--------------------------------------------------
		//
		//												Get TC values
		//
		//--------------------------------------------------//--------------------------------------------------
		
		
		public function getDimensionsCount():int
		{
			return allDimensions.length();
		}

		public function getErrorItems():Array
		{
			return this.errorItems;
		}
		
		
		/**
		 * Returns a reference to the data.
		 * 
		 * @return XMLList the testcollection data as an XMLList
		 */
		public function getALLDimensions():XMLList
		{
			return allDimensions;
		}
		
		/**
		 * Returns a specific Dimension with all its related levels and items.
		 * 
		 * @param index the number of one of the four possible dimensions. See your testcollection xml to determine which number represents which dimension.
		 * 
		 * @return if found it returns the appropiate dimension as a Dimension object, if not it returns an empty Dimension object dummy.
		 * @see Dimension
		 */
		public function getDimensionAt(index:int):Dimension
		{
			if(allDimensions==null)
			{
				return new Dimension("test","the requestet dimension either doesn't exist or index is out of bound","","");
			}
			for(var i:uint=0;i<allDimensions.length();i++)
			{
				if(i==index)
				{
					var d:Dimension = new Dimension(allDimensions[i].@dname,allDimensions[i].@description,allDimensions[i].@sound,allDimensions[i].@requires);
					var colList:XMLList = allDimensions[i].children();
					for(var j:uint=0;j<colList.length();j++)
					{
						var c:Collection = new Collection(colList[j].@tname,colList[j].@description,colList[j].@sound);
						c.addItems(colList[j].children());
						d.addCollectionToList(c);
					}
					return d;
				}
			}
			return new Dimension("test","the requestet dimension either doesn't exist or index is out of bound","","");
		}

		/**
		 * Returns a specific Dimension with all its related levels and items, determined by its name.
		 * 
		 * @param name the name of one of the four possible dimensions.
		 * 
		 * @return if found it returns the appropiate dimension as a Dimension object, if not it returns an empty Dimension object dummy.
		 * @see Dimension
		 */
		public function getDimensionByName(name:String):Dimension
		{
			if(allDimensions==null)
			{
				return new Dimension("test","the requestet dimension either doesn't exist or index is out of bound","","");
			}
			for(var i:uint=0;i<allDimensions.length();i++)
			{
				if(allDimensions[i].@dname==name)
				{
					var d:Dimension = new Dimension(allDimensions[i].@dname,allDimensions[i].@description,allDimensions[i].@sound,allDimensions[i].@requires);
					var colList:XMLList = allDimensions[i].children();
					for(var j:uint=0;j<colList.length();j++)
					{
						var c:Collection = new Collection(colList[j].@tname,colList[j].@description,colList[j].@sound);
						c.addItems(colList[j].children());
						d.addCollectionToList(c);
					}
					return d;
				}
			}
			return new Dimension("test","the requestet dimension either doesn't exist or index is out of bound","","");
		}
		
		
		public function getDimensionIndexByName(name:String):int
		{
			if(allDimensions==null)
			{
				return -1;
			}
			for(var i:uint=0;i<allDimensions.length();i++)
			{
				trace(allDimensions[i].@dname+" "+name);
				if(allDimensions[i].@dname==name)
				{
					return i;
				}
			}
			return -1;
		}
		
		
		/**
		 * Tries to find the item number of the follwer item. If nothing is found, the actual item was the last one within the current level.
		 * 
		 * @param currentDimension	the current dimension, usually stored in a session object or sent by a custommodule event
		 * @param currentLevel		the current level, usually stored in a session object or sent by a custommodule event
		 * @param currentItem		the current item, usually stored in a session object or sent by a custommodule event
		 * 
		 * @return String if found, the next item id as a String, else null
		 * 
		 * @see Shared.CustomModuleEvents
		 * @see Session
		 */
		public function searchNextItem(currentDimension:int,currentLevel:int,currentItem:String):String
		{
			if(currentItem==null || currentItem=="")
			{
				return null;
			}
			var list:Array = this.getDimensionAt(currentDimension).returnCollectionAt(currentLevel).returnItems();
			//trace("[TEST_COLLECTION]: itemlist at dimension "+currentDimension+" and Level "+currentLevel);
			//trace("[TEST_COLLECTION]: "+list);
			//lets iterate all items in the collectiobn
			for(var j:uint=0;j<list.length;j++)
			{
				//if the current item is found in the list and its not the last element
				if(list[j] == currentItem && j<list.length-1) 
				{
					return list[j+1];
				}
			}
			return null;
		}
		
		
		public function get_testcollection_progress(current_dimension:int, current_level:int, current_item:String):Number
		{
			if(allDimensions == null || allDimensions.length() == 0)return 0;
			
			var dim:Dimension = this.getDimensionAt(current_dimension);
			if(dim==null)return 0;
			var col:Collection=	dim.returnCollectionAt(current_level);
			if(col==null)return 0;
			var index:int = col.returnItemIndex(current_item);
			if(index==-1)return 0;
			//index++;
			
			return index / col.returnItems().length * 100;
			
		}
		
		public function getDimensionEnabled(index:int):Boolean
		{
			return allDimensions!=null?Boolean(allDimensions[index].@enabled):false;
		}
		
		/**
		 * Returns the name of a dimension at a given index.
		 * 
		 * @param index the specific index of a dimension, ranges within <code>[0..3]</code>
		 * @return String the name of the dimension as a String value
		 */
		public function getDimensionName(index:int):String
		{
			return allDimensions!=null?allDimensions[index].@dname:"";
		}
		
		/**
		 * Returns the name of a level at a given index.
		 * 
		 * @param index the specific index of a dimension, ranges within the amount of levels
		 * @return String the name of the level as a String value
		 */
		public function getLevelName(dindex:int,lindex:int):String
		{
			return allDimensions!=null?getDimensionAt(dindex).returnCollectionAt(lindex).getName():"";
		}			
			
		
		
	}

}