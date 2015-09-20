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
package tutorial
{
	import ItemApplication.question.Cloze;
	
	import components.ReaImage;
	import components.factories.ComponentsFactory;
	
	import events.CustomEventDispatcher;
	import events.CustomModuleEvents;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import interfaces.IClickable;
	import interfaces.ICustomEventDispatcher;
	import interfaces.IQuestionsObject;
	import interfaces.IReaModule;
	
	import models.Globals;
	import models.Session;
	import models.TestCollection;
	
	import mx.collections.ArrayList;
	import mx.core.IVisualElement;
	
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.VGroup;
	import spark.components.VideoPlayer;
	import spark.layouts.HorizontalAlign;
	
	import views.ErrorView;
	import views.HelpView;
	import views.TutorialView;
	
	public class TutorialObject extends CustomEventDispatcher implements IReaModule, ICustomEventDispatcher
	{
		//-----------------------------------------------------//-----------------------------------------------------
		//
		//													Variables
		//
		//-----------------------------------------------------//-----------------------------------------------------
		
		//DEBUG
		private var _debug:Boolean=false;
		private var _soundMode:Boolean = false;
		
		//Visual Elements
		private var view:TutorialView;
		private var vp:VideoPlayer;
		
		//Events
		public static const LOAD_COMPLETE:String = "loadComplete";
		
		//Data Storage
		private var references:ArrayList;
		private var _urls:Array;
		private var _labels:Array;
		private var _xml:XML;
		
		
		//server connection
		private var loader:URLLoader;
		private var req:URLRequest;
		private var _scriptUrl:String;
		private var _rootUrl:String;
		private var itemspath:String;
		private var itemId:String;
		private var _mediaUrl:String;
		private var relUrl:String;
		private var _helpVideos:Array;
		private var _soundUrl:String;
		
		//-----------------------------------------------------//-----------------------------------------------------
		//
		//												Public Functions
		//
		//-----------------------------------------------------//-----------------------------------------------------
		
		public function TutorialObject(target:IEventDispatcher=null)
		{
			//init components
			super(target);
			view = new TutorialView();
			view.forwardButton.addEventListener(MouseEvent.CLICK, onTutorialFinished);
			//init loader
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onXmlComplete);
			trace("TuroialObject: instace created");
			
		}
		
		
		public function load(_globals:Globals, _tcollection:TestCollection, _session:Session):void
		{
			_urls = _globals.paths;
			_labels = _globals.labels;
			itemId = _session.item;

			
			
			
			//setup paths
			for(var i:uint=0;i<_urls.length;i++)
			{
				rootUrl=_urls[i][0]==UrlTypeEnum.ROOT.getValue()?_urls[i][1]:rootUrl;	
				scriptUrl = _urls[i][0]==UrlTypeEnum.INCLUDE_SCRIPT.getValue()?rootUrl+_urls[i][1]:scriptUrl;
				itemspath=_urls[i][0]==UrlTypeEnum.ITEM.getValue()?_urls[i][1]:itemspath;
				soundUrl = _urls[i][0]==UrlTypeEnum.SOUNDS.getValue()?_urls[i][1]:soundUrl;
				mediaUrl = _urls[i][0]==UrlTypeEnum.MEDIA.getValue()?rootUrl+_urls[i][1]:mediaUrl;
			}
			relUrl = itemspath +itemId+"/";
			helpVideos = _globals.videos;
			
			//setup labels
			for(i=0;i<_labels.length;i++)
			{
				if(_labels[i][0] == "forwardButton")
				{
					view.forwardButton.label = _labels[i][1];
				}
			}
			
			var v:URLVariables = new URLVariables();
			v.param = PHPParameterTypeEnum.GET_ITEM_DATA.getValue();
			v.itemid = itemId;
			req = new URLRequest(scriptUrl);
			req.data = v;
			req.method = URLRequestMethod.POST;
			loader.load(req);
			trace("load tutorial object: "+itemId);
			dispatchEvent(new Event(LOAD_COMPLETE));
			
			
		}
		
		
		public function get debug():Boolean
		{
			return _debug;
		}
		
		public function set debug(value:Boolean):void
		{
			_debug = value;
		}
		
		public function get soundMode():Boolean
		{
			return _soundMode;
		}
		
		public function set soundMode(value:Boolean):void
		{
			_soundMode = value;
		}
		
		public function unload():void
		{
			view.removeAllElements();
			view = null;
			for(var i:uint=0;references!=null && i<references.length;i++)
			{
				if(references.getItemAt(i) is ICustomEventDispatcher)
				{
					references.getItemAt(i).removeAllEventListeners();
				}
				var obj:Object = references.getItemAt(i) as Object;
				references.removeItemAt(i);
				obj = null;
			}
			references = null;
		}
		
		public function returnView():Group
		{
			return this.view!=null?view:new ErrorView();	
		}
		
		public function getClassDefinition():String
		{
			return "ItemApplication.TutorialObject";
		}
		
		public function returnLoadFinishedEvent():String
		{
			return LOAD_COMPLETE;
		}
		
		public function returnModuleFinishedEvent():String
		{
			return CustomModuleEvents.MODULE_FINISHED;
		}
		
		public function sendTweenFinished():void
		{
			//EMpty
		}
		
		
		public function returnCurrentState():String
		{
			return view.currentState;
		}
		
		
		public function getHelpDisplay():HelpView
		{
			//wrapper group
			var h:HelpView = new HelpView();
			
			return h;
		}
		
		//-----------------------------------------------------//-----------------------------------------------------
		//
		//												Private Functions
		//
		//-----------------------------------------------------//-----------------------------------------------------
		
		private function onXmlComplete(event:Event):void
		{
			_xml = loader.data!="failed"?XML(loader.data):null;
			if(_xml != null)
			{
				setupInstruction();
				setupQuestion();
			}
		}
		
		/**
		 * iterate xmllist and create display objects, listeners and so on 
		 */ 
		private function setupInstruction():void
		{
			var insList:XMLList = XMLList(_xml.instruction.children());
			
			var vg:VGroup = ComponentsFactory.createVGroup('insVgroup'+i,"left","top");
			for(var i:uint=0;i<insList.length();i++)
			{
				switch(insList[i].localName())
				{
					case('in_text'):
						var hg:HGroup = ComponentsFactory.createHGroup('insgroup'+i,HorizontalAlign.CENTER);
						var insLbl:Label = ComponentsFactory.createLabelFromXMLNode(insList[i],'inslbl'+i,300);
						var insBtn:IClickable = (!soundMode && insList[i].@sound.length()>0) ? ComponentsFactory.createSmallSoundButton(scriptUrl,relUrl+insList[i].@sound,'insSnd'+i,'insSndBtn'+i) : ComponentsFactory.createSmallEyeButton('insEyeBtn'+i);
						hg.addElement(insBtn as IVisualElement);
						hg.addElement(insLbl);
						vg.addElement(hg);
						break;
					case('media'):
						
						var ci:ReaImage = ComponentsFactory.createCustomImage('insIm'+i,scriptUrl,relUrl+insList[i].@file);
						vg.addElement(ci as IVisualElement);
						break;
				}
			}
			view.addElement(vg);
		}
		
		
		
		private var classRef:Class;
		private var instance:IQuestionsObject; 
		private static const clozeRef:Cloze = null;
		
		private function setupQuestion():void
		{
			var itemType:XMLList = XMLList(_xml.meta_item);
			instance = ModulesCreator.simpleQuestionsFactory("ItemApplication.QuestionTypes."+itemType.toString());
			/*classRef = getDefinitionByName(className) as Class;
			instance = new classRef() as IQuestionsObject;*/
			
			var questionsList:XMLList = XMLList(_xml.questions);
			instance.init(questionsList,scriptUrl,relUrl);
			instance.load();
			view.item_questionWrapperBox.addElement(instance.getView());
		}
		
		private function playVideo(event:MouseEvent):void
		{
			view.videoDisplay.play();
		}
		
		private function onTutorialFinished(event:MouseEvent):void
		{
			trace("unload");
			view.forwardButton.removeEventListener(MouseEvent.CLICK, onTutorialFinished);
			dispatchEvent(new CustomModuleEvents(CustomModuleEvents.MODULE_FINISHED,false,false));
		}
		
		//---------------------------------------------------------------------------------
		//
		//
		// 	Required Variables
		//
		//---------------------------------------------------------------------------------
		
		public function get rootUrl():String
		{
			return _rootUrl;
		}
		public function set rootUrl(value:String):void
		{
			_rootUrl = value;
		}
		
		public function get scriptUrl():String
		{
			return _scriptUrl;
		}
		
		public function set scriptUrl(value:String):void
		{
			_scriptUrl = value;
		}
		
		public function get soundUrl():String
		{
			return _soundUrl;
		}
		
		public function set soundUrl(value:String):void
		{
			_soundUrl = value;
		}
		
		public function get mediaUrl():String
		{
			return _mediaUrl;
		}
		
		public function set mediaUrl(value:String):void
		{
			_mediaUrl = value;
		}
		
		public function set helpVideos(value:Array):void
		{
			_helpVideos = value;
		}
		
		public function get helpVideos():Array
		{
			return _helpVideos;	
		}
		
		
		
		private var _track:Boolean;
		public function set track(value:Boolean):void
		{
			_track = value;
		}
		public function get track():Boolean
		{
			return _track;
		}
	}
}