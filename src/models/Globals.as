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
	import components.BasicSoundButton;
	
	import events.CustomEventDispatcher;
	
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import interfaces.ICustomEventDispatcher;
	
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	import spark.components.Label;
	

	/**
	 * This class is a model for all global settings like paths and labels.
	 * 
	 * <p>The globals.xml file will be analysed and the particular data will be stored in different arrays</p>
	 */
	public class Globals extends CustomEventDispatcher implements ICustomEventDispatcher
	{
	
		/**
		 * Use instance() method instead.
		 */
		public function Globals()
		{
			
		}
		
		private static var _instance:Globals;
		
		/**
		 * Returns a single instance of this class (singleton pattern).
		 */
		public static function instance():Globals
		{
			if(_instance==null)_instance = new Globals();
			return _instance;
		}
		
		//-------------------------------// 
		//	CONSTANT SERVER PATH IDs
		//-------------------------------//
		
		public static const ROOTURL:String = "rootUrl";
		
		public static const SCRIPTURL:String="includeScript";
		
		public static const LOGINNEWCODE:String = "loginNewCode";
		
		public static const TESTCOLLECTION:String = "getTCollection";
		
		public static const ITEMS_PATH:String = "itemsPath"; 
			
		public static const USER_PATH:String = "userPath";	
			
		public static const SOUND_PATH:String = "soundPath";
			
		public static const VIDEOS:String = "videos";
		
		public static const END_APP_REDICECT:String = "endAppRedirect";
		
		public static const FEEDBACKSOUND_PATH:String = "feedbackSounds";
		
		public static const ALPHALIST:String = "feedbackList";
		
		//-------------------------------// 
		//	CONSTANTS FOR FALLBACKS
		//-------------------------------//
		
		public static const TEXT_STANDARD:String = "Text-22";
		public static const TEXT_INPUT_STANDARD:String = "TextInput_default";
		
		
		//-------------------------------////-------------------------------// 
		//
		//	VARIABLES
		//
		//
		//-------------------------------////-------------------------------//

		
		//-------------------------------// 
		// PATHS LIST
		//-------------------------------//
		private var _paths:Array;
		
		/**
		 * returns all paths stored in an array
		 */
		public function get paths():Array
		{
			return _paths;
		}
		
		/**
		 * writing to paths
		 */
		public function set paths(value:Array):void
		{
			_paths = value;
		}
		
		//-------------------------------// 
		// LABELS LIST
		//-------------------------------//
		private var _labels:Array;
		
		/**
		 *	reutns all labels stored in an array 
		 */
		public function get labels():Array
		{
			return _labels;
		}
		

		/**
		 * writing to labels
		 */
		public function set labels(value:Array):void
		{
			_labels=value;
		}
		
		//-------------------------------// 
		// SETTINGS LIST
		//-------------------------------//
		
		private var _settings:Array;
		
		/**
		 * returns a boolean value, whether sound is enabled or disabled
		 */
		public function get settings():Array
		{
			return _settings;
		}
		
		/**
		 * returns a boolean value, whether debug is enabled or disabled
		 */
		public function set settings(value:Array):void
		{
			_settings = value;
		}
		
		//-------------------------------// 
		// VIDEOS LIST 
		//-------------------------------//
		
		private var _videos:Array
		
		public function get videos():Array
		{
			return _videos;
		}
		
		public function set videos(value:Array):void
		{
			_videos = value;
		}

		
		//-------------------------------// 
		//loader service
		//-------------------------------//
		private var service:HTTPService = new HTTPService();
		
		//-------------------------------//
		//Events
		//-------------------------------//
		public static const GLOBALS_LOADED:String="globalsLoaded";
		public static const GLOBALS_FAULT:String="globalsFault";
		

		//-------------------------------// 
		//	SOURCE
		//-------------------------------//
		[Embed(source="Assets/system/globals.xml", mimeType="application/octet-stream")]
		private var globals_binary:Class;
		
		private var source:XML;
		
		public function returnSource():XML
		{
			return source;
		}
		
		//-------------------------------// 
		//	INITIALIZATION
		//-------------------------------//
		
		public function initializeData():void
		{
			paths = new Array();
			labels = new Array();
			settings = new Array();
			videos = new Array();
			
			try
			{
				processxml();	
			} 
			catch(error:Error) 
			{
				trace(error);
				dispatchEvent(new Event(GLOBALS_FAULT));
			}
		}
		
		
		/**
		 * @private
		 */
		private function processxml():void
		{
			//wrap xml binaries to bytarray and readbytes into a new XML File
			var byteArray:ByteArray = new globals_binary();
			var x:XML = new XML(byteArray.readUTFBytes(byteArray.length));
			source=x;
			
			var i:uint=0;
			
			//-------------------------------// create app settings
			var settingsList:XMLList = x.settings.children();
			for(i=0;i<settingsList.length();i++)
			{
				var newSet:Array = new Array();
				newSet.push(settingsList[i].@id);
				newSet.push(settingsList[i].@value);
				this.settings.push(newSet);
			}
			
			//-------------------------------// create Paths
			var urlList:XMLList = x.paths.children();
			for(i=0;i<urlList.length();i++)
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
			
			//-------------------------------// video urls
			var vids:XMLList = x.videos.children();
			for(i=0;i<vids.length();i++)
			{
				var newVid:Array = new Array();
				newVid.push(vids[i].@module);
				newVid.push(vids[i].@state);
				newVid.push(vids[i].@url);
				this.videos.push(newVid);
			}
			
			//---------------- // PARSING FINISHED // -----------------//
			
			dispatchEvent(new Event(GLOBALS_LOADED));
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
			if(_paths == null || _paths.length == 0)
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
			if(_labels==null || _labels.length == 0)
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
		
		
		public function attach_labels(source:Vector.<Label>):void
		{
			if(_labels==null || _labels.length == 0)return;
			for(var i:uint=0;i<_labels.length;i++)
			{
				for each (var label:Label in source) 
				{
					if(_labels[i][0]==label.id)
					{
						label.text = _labels[i][1];
					}
				}
				
			}
		}
		
		
		public function attach_sounds(source:Vector.<BasicSoundButton>):void
		{
			if(_labels==null || _labels.length == 0)return;
			for(var i:uint=0;i<_labels.length;i++)
			{
				for each (var button:BasicSoundButton in source) 
				{
					if(_labels[i][0]==button.id)
					{
						button.scriptUrl=returnPathValue("includeScript");
						button.source =  returnPathValue("soundPath") + _labels[i][2];
					}
				}
				
			}
		}
		
		
		public function returnSettingsValue(id:String):String
		{
			if(_settings == null || _settings.length == 0)
			{
				return "";
			}
			for(var i:uint=0;i<_settings.length;i++)
			{
				if(_settings[i][0]==id)
				{
					return _settings[i][1];	
				}
			}
			return "";
		}
		
		
		public function returnSoundUrl(id:String):String
		{
			if(_labels==null || _labels.length == 0)
			{
				return "";
			}
			
			for(var i:uint=0;i<_labels.length;i++)
			{
				if(_labels[i][0]==id)
				{
					return returnPathValue("soundPath") + _labels[i][2];
				}
			}
			return "";
		}
		
		public function getVideoUrl(className:String, viewName:String):String
		{
			trace("[Globals]: get video url for "+className + "  "+viewName);
			if(_videos==null || className==null || className.length==0){return "";}
			if(viewName == null)viewName ="";
			var split:Array = className.split(".");
			var cl:String = split.length > 1 ? split[1] : className;
			
			for(var i:uint=0;i<_videos.length;i++)
			{
				if(_videos[i][0] == cl && _videos[i][1] == viewName)
				{
					var url:String= returnPathValue("rootUrl") + returnPathValue("videos") +  _videos[i][2];
					trace(url);
					return url;
				}
			}
			return "";
		}
		

	}
}