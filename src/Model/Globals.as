package Model
{
	import Interfaces.ICustomEventDispatcher;
	
	import Shared.EventDispatcher;
	
	import flash.events.Event;
	
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	

	/**
	 * This class is a model for all global settings like paths and labels.
	 * 
	 * <p>The globals.xml file will be analysed and the particular data will be stored in different arrays</p>
	 */
	public class Globals extends EventDispatcher implements ICustomEventDispatcher
	{
		//-------------------------------// 
		//	Data to Store
		//-------------------------------//
		private var _paths:Array;
		private var _labels:Array;
		private var _soundIgnore:Boolean=false;
		private var _debugMode:Boolean=false;
		
		//-------------------------------// 
		//loader service
		//-------------------------------//
		private var service:HTTPService = new HTTPService();
		private static var url:String = "Assets/globals.xml";
		
		//-------------------------------//
		//Events
		//-------------------------------//
		public static const GLOBALS_LOADED:String="globalsLoaded";
		public static const GLOBALS_FAULT:String="globalsFault";
		
		/**
		 * Constructor. Http Service will be set up.
		 */
		public function Globals()
		{
			paths = new Array();
			labels = new Array();
			service.url = url;
			service.method = "GET";	//why not post?
			service.resultFormat = "e4x";
			service.showBusyCursor=true;
			service.addEventListener(FaultEvent.FAULT,http_onFault);
			service.addEventListener(ResultEvent.RESULT,http_onResult);
			service.send();
		}
		
		/**
		 * @private
		 */
		private function http_onFault(event:FaultEvent):void
		{
			trace("[GLOBAL_SETTINGS]: loader fault");
			dispatchEvent(new Event(GLOBALS_FAULT));
			service.removeEventListener(FaultEvent.FAULT,http_onFault);
			service.removeEventListener(ResultEvent.RESULT,http_onResult);
			service=null;
		}
		
		/**
		 * @private
		 */
		private function http_onResult(event:ResultEvent):void
		{
			trace("[GLOBAL_SETTINGS]: loader success");
			var x:XML = event.result as XML;
			_soundIgnore = x.mode.@ignoresound=="1"?true:false;
			_debugMode = x.mode.@debug=="1"?true:false;
			trace("[GLOBAL_SETTINGS]: soundIgnore: "+_soundIgnore);
			trace("[GLOBAL_SETTINGS]: debugMode: "+_debugMode);
			//-------------------------------// create Paths
			var urlList:XMLList = x.paths.children();
			for(var i:uint=0;i<urlList.length();i++)
			{
				var newUrl:Array = new Array();
				newUrl.push(urlList[i].@id);
				newUrl.push(urlList[i].@url);
				this.paths.push(newUrl);
			}
			//-------------------------------// create labels
			var lbList:XMLList = x.labels.children();
			for(var j:uint=0;j<lbList.length();j++)
			{
				var newLb:Array=new Array();
				newLb.push(lbList[j].@id);
				newLb.push(lbList[j].@text);
				if(lbList[j].@sound!=null||lbList[j].@sound!=""){newLb.push(lbList[j].@sound);}else{newLb.push("");}
				this.labels.push(newLb);
			}
			dispatchEvent(new Event(GLOBALS_LOADED));
			service.removeEventListener(FaultEvent.FAULT,http_onFault);
			service.removeEventListener(ResultEvent.RESULT,http_onResult);
			service=null;
		}
		
		/**
		 * returns all paths stored in an array
		 */
		public function get paths():Array
		{
			return _paths;
		}
		
		/**
		 *	reutns all labels stored in an array 
		 */
		public function get labels():Array
		{
			return _labels;
		}
		
		/**
		 * writing to paths
		 */
		public function set paths(value:Array):void
		{
			_paths = value;
		}
		
		/**
		 * writing to labels
		 */
		public function set labels(value:Array):void
		{
			_labels=value;
		}
		
		/**
		 * returns a boolean value, whether sound is enabled or disabled
		 */
		public function get soundIgnore():Boolean
		{
			return _soundIgnore;
		}

		/**
		 * returns a boolean value, whether debug is enabled or disabled
		 */
		public function get debugMode():Boolean
		{
			return _debugMode;
		}
		
		
		//--------------------------------------------//
		//
		// RETURN FUNCTIONS
		//
		//--------------------------------------------//
		
		/**
		 * returns a specific path by comparing the id of the path.
		 * Usually it will ba an UrlTypeEnum but it can also be any string.
		 * 
		 * @see enumTypes.UrlTypeEnums
		 */
		public function returnPathValue(id:String):String
		{
			if(_paths == null)
			{
				return "";
			}
			for(var i:uint=0;i<_paths.length;i++)
			{
				if(_paths[i][0]==id)
				{
					return _paths[i][1];
				}
			}
			return "";
		}
		
		/**
		 * returns a specific label by comparing the id of the path.
		 * Usually it will ba an UrlTypeEnum but it can also be any string.
		 * 
		 * @see enumTypes.UrlTypeEnums
		 */
		public function returnLabelValue(id:String):String
		{
			if(_labels==null)
			{
				return "";
			}
			for(var i:uint=0;i<_labels.length;i++)
			{
				if(_labels[i][0]==id)
				{
					return _labels[i][1];
				}
			}
			return "";
		}
	}
}