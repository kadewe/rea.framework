package Model
{
	import Interfaces.ICustomEventDispatcher;
	
	
	import Shared.EventDispatcher;
	
	import flash.events.Event;
	
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;

	/**
	 * This class loads the xml with the contained information about subjects, levels and item IDs and parse it into an XMLLIST. 
	 * <p>The data is read-only and will be written only once when the class will be initialized</p>
	 * <p>To overwirte the data, the class must be unloaded and be instanciated again</p>
	 * 
	 */
	public class TestCollection extends EventDispatcher implements ICustomEventDispatcher
	{
		//-------------------------------//
		// LOADER SERVICES
		//-------------------------------//
		private var service:HTTPService = new HTTPService();
		private static var url:String = "testcollections.xml"
		
		//-------------------------------//
		// underlying Data Structure
		//-------------------------------//	
		private  var allDimensions:XMLList;
		
		//-------------------------------//
		//	EVENTS
		//-------------------------------//
		public static const TC_BUILD:String = "tcBuild";
		public static const TC_ERROR:String = "tcError";
		

	
		/**
		 * constructor, immediately initializes http service and loads the testcollection from the related Url
		 * 
		 * @param _relUrl the relative path to the xml file on the server, will be combined with the url String
		 */
		public  function TestCollection(_relUrl:String):void
		{
			service.url = _relUrl+url;
			service.method = "GET";
			service.resultFormat = "e4x";
			service.showBusyCursor=true;
			service.addEventListener(FaultEvent.FAULT,http_onFault);
			service.addEventListener(ResultEvent.RESULT,http_onResult);
			service.send();
		}
		

		/**
		 * dispatched an error event and unloads the service.
		 */
		private function http_onFault(event:FaultEvent):void
		{
			trace("[TEST_COLLECTION]: loader fault");
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
			trace("[TEST_COLLECTION]: loader success");
			var x:XML = event.result as XML;
			allDimensions = x.children();
			service.removeEventListener(FaultEvent.FAULT,http_onFault);
			service.removeEventListener(ResultEvent.RESULT,http_onResult);
			service = null;
			dispatchEvent(new Event(TC_BUILD));
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
				return new Dimension("test","the requestet dimension either doesn't exist or index is out of bound","");
			}
			for(var i:uint=0;i<allDimensions.length();i++)
			{
				if(i==index)
				{
					var d:Dimension = new Dimension(allDimensions[i].@dname,allDimensions[i].@description,allDimensions[i].@sound);
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
			return new Dimension("test","the requestet dimension either doesn't exist or index is out of bound","");
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
				return new Dimension("test","the requestet dimension either doesn't exist or index is out of bound","");
			}
			for(var i:uint=0;i<allDimensions.length();i++)
			{
				if(allDimensions[i].@dname==name)
				{
					var d:Dimension = new Dimension(allDimensions[i].@dname,allDimensions[i].@description,allDimensions[i].@sound);
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
			return new Dimension("test","the requestet dimension either doesn't exist or index is out of bound","");
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
			trace("[TEST_COLLECTION]: itemlist at dimension "+currentDimension+" and Level "+currentLevel);
			trace(list);
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