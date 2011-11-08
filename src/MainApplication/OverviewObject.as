package MainApplication
{
	import DisplayApplication.Components.CustomDesignButton;
	import DisplayApplication.Components.SmallSoundButton;
	import DisplayApplication.ErrorView;
	import DisplayApplication.Overview;
	
	import Interfaces.IClickableComponent;
	import Interfaces.ICustomEventDispatcher;
	import Interfaces.ICustomModule;
	
	import Model.Globals;
	import Model.Session;
	import Model.TestCollection;
	
	import Shared.CustomModuleEvents;
	import Shared.ErrorDispatcher;
	import Shared.EventDispatcher;
	import Shared.MP3Audio;
	import Shared.StaticFunctions;
	import Shared.UserEvent;
	
	import enumTypes.ErrorTypeEnum;
	import enumTypes.UrlTypeEnum;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.sampler.NewObjectSample;
	
	import mx.controls.Alert;
	import mx.events.FlexEvent;
	import mx.managers.CursorManager;
	
	import spark.components.Button;
	import spark.components.Label;

	/**
	 * the handler class for an overview, where users will choose their next testcollection by choosing a dimension and the corresponding level.
	 */
	public class OverviewObject extends Shared.EventDispatcher implements ICustomModule, ICustomEventDispatcher
	{
		
		private var view:Overview;
		
		//---------------------------------
		// states listeners and references
		//---------------------------------
		private var state:Number = 0;
		private var references:Array = new Array();
		
		//---------------------------------
		// session variables
		//---------------------------------
		private var itemToLoad:String;
		private var chosenSubject:int;
		private var chosenLevel:int;
		

		
		//---------------------------------
		// Labels and Urls
		//---------------------------------
		private var tcReference:TestCollection=null; //reference to the testcollection
		private var labels:Array;
		private var urls:Array;
		private var root:String;
		private var scriptUrl:String;
		private var soundUrl:String;
		
		//--------------------------------------////--------------------------------------// 
		// 								DEBUG AND SOUND SETTINGS
		//--------------------------------------////--------------------------------------//
		private var _debug:Boolean=false;
		private var _sound:Boolean=false;
		
		
		/**
		 * constructor, initializes view component.
		 */
		public function OverviewObject()
		{
			view = new Overview();
			view.addEventListener(FlexEvent.CREATION_COMPLETE, combineData);
			references.push(view);
		}
		
		//--------------------------------------////--------------------------------------//
		// 									Module Loading
		//--------------------------------------////--------------------------------------//
		
		/**
		 * loads path urls and labels from globals. Makes a reference to testcollection, because we need this later for session building.
		 * 
		 * @param _globals reference to the globals lib
		 * @param _tcollection reference to the testcollection lib
		 * @param _session reference to the session lib, not used in this class
		 */
		public function load(_globals:Globals,_tcollection:TestCollection,_session:Session):void
		{
			var _labels:Array = _globals.labels;
			var _urls:Array = _globals.paths;
			trace("[overviewObject]: load");
			urls = _urls;
			labels = _labels;
			tcReference = _tcollection;
			references.push(tcReference);
			dispatchEvent(new Event(LOAD_COMPLETE));
		}
		
		/**
		 * Returns a reference to the view component.
		 */
		public function returnView():Object
		{
			return this.view!=null?view:new ErrorView();	
		}
		
		/**
		 * not used in this class
		 */
		public function sendTweenFinished():void
		{
			//empty
		}
		
		/**
		 * cleanup event listeners and references 
		 */
		public function unload():void
		{
			for(var i:uint=0;i<references.length;i++)
			{
				if(references[i] is ICustomEventDispatcher)
				{
					references[i].removeAllEventListeners();
				}
				references[i] = null;
			}
			this.view.removeAllElements();
			this.view = null;
		}
		
		

		/**
		 * sets debug value
		 */
		public function set debug(value:Boolean):void
		{
			_debug=value;
		}
		
		/**
		 * sets sounddebug value
		 */
		public function set soundMode(value:Boolean):void
		{
			_sound=value;
		}
		
		/**
		 * gets debug value 
		 */
		public function get debug():Boolean
		{
			return _debug;
		}
		
		/**
		 * gets sounddebug value
		 */
		public function get soundMode():Boolean
		{
			return _sound;
		}
		
		
		//--------------------------------------------// 
		// Module Finished
		//--------------------------------------------// 
		
		/**
		 * representing the event, where this class has finished the loading process
		 */
		public static const LOAD_COMPLETE:String = "loadComplete";
		
		
		/**
		 * allows adding event listeners because get function will not work for constants
		 */
		public function returnModuleFinishedEvent():String
		{
			return CustomModuleEvents.MODULE_FINISHED;
		}
		
		/**
		 * allows adding event listeners because get function will not work for constants
		 */
		public function returnLoadFinishedEvent():String
		{
			return LOAD_COMPLETE;
		}
		
		
		/**
		 * returns the package and calass name as a string to allow search within the loader management
		 */
		public function getClassDefinition():String
		{
			return "MainApplication.OverviewObject";
		}	
		
		
		//-----------------------------//
		// PRIVATE
		//-----------------------------//
		
		/**
		 * @private
		 * 
		 * after creation complete, labels, urls and eventListeners will be set up to display.
		 */
		private function combineData(event:FlexEvent):void
		{
			for(var i:uint=0;i<urls.length;i++)
			{
				if(urls[i][0]==UrlTypeEnum.ROOT.getValue())
				{
					root = urls[i][1];
					trace("[loginobject]: "+root);
				}
				if(urls[i][0]==UrlTypeEnum.INCLUDE_SCRIPT.getValue())
				{
					scriptUrl = root + urls[i][1];
					trace("[loginobject]: "+scriptUrl);
				}
				if(urls[i][0]==UrlTypeEnum.SOUNDS.getValue())
				{
					soundUrl = urls[i][1];
					trace("[loginobject]: "+soundUrl);
				}
			}

			for(var i:uint=0;i<labels.length;i++)
			{
				if(labels[i][0]==view.chooseSubject.id)
				{
					view.chooseSubject.text=labels[i][1];
					if(!soundMode)
					{
						var m:MP3Audio = new MP3Audio(scriptUrl,soundUrl + labels[i][2]);
						view.chooseSubjectSnd.referringTo = m;
						view.chooseSubjectSnd.addEventListener(MouseEvent.CLICK, playAudio);
					}
				}
			}
			var _view:Overview = event.currentTarget as Overview;
			_view.button0.label = tcReference.getDimensionAt(0).getName();
			_view.button0.addEventListener(MouseEvent.CLICK, showLevel);
			_view.button0.addEventListener(MouseEvent.MOUSE_OVER, showDimensionDescription);
			_view.button1.label = tcReference.getDimensionAt(1).getName();
			_view.button1.addEventListener(MouseEvent.CLICK, showLevel);
			_view.button1.addEventListener(MouseEvent.MOUSE_OVER, showDimensionDescription);
			_view.button2.label = tcReference.getDimensionAt(2).getName();
			_view.button2.addEventListener(MouseEvent.CLICK, showLevel);
			_view.button2.addEventListener(MouseEvent.MOUSE_OVER, showDimensionDescription);
			_view.button3.label = tcReference.getDimensionAt(3).getName();
			_view.button3.addEventListener(MouseEvent.CLICK, showLevel);
			_view.button3.addEventListener(MouseEvent.MOUSE_OVER, showDimensionDescription);
		}
		
		
		/**
		 * @private
		 * 
		 * called by clicking a view button. changes the view state to levels and saves the chosen dimension.
		 * rads the levels and creates for each level a new button and sets up events for dragging and clicking them.
		 */
		private function showLevel(event:Event):void
		{
			Shared.StaticFunctions.fadeOutSound();
			event.target.removeEventListener(MouseEvent.CLICK, showLevel);
			view.description.removeAllElements();
			//level related
			var buffer:String = String(event.target.id);
			chosenSubject = int(buffer.charAt(buffer.length-1));
			trace("[OverviewObject]: dimension "+chosenSubject);
			view.currentState = "levels";
			var levels:Array = tcReference.getDimensionAt(chosenSubject).returnCollection();
			for(var i:uint=0;i<levels.length;i++)
			{	
				//BUTTON FOR CHOOSING LEVEL
				var _b:CustomDesignButton = new CustomDesignButton();
				_b.label = levels[i].getName();
				_b.addEventListener(MouseEvent.CLICK, loadItem);
				_b.addEventListener(MouseEvent.MOUSE_OVER, showLevelDescription);
				_b.id = i.toString();
				view.levelButtonsContainer.addElement(_b);
				references.push(_b);
			}
			//----------------------------------------------// LABEL AND SOUND IN LEVEL VIEW
			for(var i:uint=0;i<labels.length;i++)
			{
				if(labels[i][0]==view.whatLevel.id)
				{
					this.view.whatLevel.text = labels[i][1];
					if(!soundMode)
					{
						var m:MP3Audio = new MP3Audio(scriptUrl,soundUrl + labels[i][2]);
						view.levelSoundButton.referringTo = m;
						view.levelSoundButton.addEventListener(MouseEvent.CLICK, playAudio);
					}
				}
			}	
	
		}
		
		
		/**
		 * @private
		 * 
		 * called by dragging a view button. reads the testcollection and tries to display the description as well as creating the related sound object.
		 */
		private function showDimensionDescription(event:MouseEvent):void
		{
			Shared.StaticFunctions.fadeOutSound();
			view.description.removeAllElements();
			var a:Button = event.currentTarget as Button;
			var _id:uint = (uint)(a.id.charAt(a.id.length-1));
			var dlabel:Label = new Label();
			dlabel.maxWidth = view.description.width-100;
			dlabel.text = tcReference.getDimensionAt(_id).getDescription();
			view.description.addElement(dlabel);
			//sound
			if(!soundMode)
			{
				Shared.StaticFunctions.fadeOutSound();
				var snd:MP3Audio = new MP3Audio(scriptUrl,soundUrl + tcReference.getDimensionAt(_id).getSoundUrl());
				snd.playAudio();	
			}
			
		}
		
		
		/**
		 * @private
		 * 
		 * By dragging a level Button, a detailed description will appear at the bottom of the screen as well as a sound object wil be created
		 */
		private function showLevelDescription(event:MouseEvent):void
		{
			Shared.StaticFunctions.fadeOutSound();
			view.description.removeAllElements();
			var _snd:SmallSoundButton = new SmallSoundButton();
			var a:CustomDesignButton = event.currentTarget as CustomDesignButton;
			var dlabel:Label = new Label();
			var _id:uint = int(a.id.charAt(a.id.length-1));
			dlabel.text = tcReference.getDimensionAt(int(chosenSubject)).returnCollectionAt(_id).getDescription();
			//dlabel.text = dimensions[chosenSubject][_id].@description;
			view.description.addElement(dlabel);
			if(!soundMode)
			{
				Shared.StaticFunctions.fadeOutSound();
				var snd:MP3Audio = new MP3Audio(scriptUrl,soundUrl + tcReference.getDimensionAt(int(chosenSubject)).returnCollectionAt(_id).getSound());
				snd.playAudio();	
			}
		}
		

		
		/**
		 * @private 
		 * 
		 * This method is called by event and plays the audio file (MP3Audio), the specific SoundButton is referring to.
		 *
		 * @see DisplayApplication.SoundButton
		 * @see Shared.MP3Audio
		 */
		private function playAudio(event:MouseEvent):void
		{
			Shared.StaticFunctions.fadeOutSound();
			Shared.StaticFunctions.stopPulse();
			var cl:IClickableComponent = event.target as IClickableComponent;
			try
			{
				cl.referringTo.playAudio();
			}catch(e:Error){
				if(debug)
					Alert.show(e.message);
				ErrorDispatcher.processNewError(
					ErrorTypeEnum.NULLREFERENCE.getNumber().toString(),
					ErrorTypeEnum.NULLREFERENCE.getValue(),
					e.errorID.toString(),
					e.name + " " + event.target,
					"OverviewObject.as",
					scriptUrl,
					false
				);
				//fallback
				event.target.removeEventListener(MouseEvent.CLICK, playAudio);
			}	
		}
		
		
		/**
		 * @private
		 * 
		 * if a level button was clicked, this event method is called and the chosen dimension, level and first item of the collection will be dispatched to the parent object in order to load the next item.
		 * important: isnext is <code>true</code> to let the parent object determine, that the next module WILL BE an item object.
		 */
		private function loadItem(event:MouseEvent):void
		{
			Shared.StaticFunctions.fadeOutSound();
			var buffer:String = String(event.target.id);
			
			chosenLevel =  (int(buffer.charAt(buffer.length-1)));
			trace("[OverviewObject]: level "+chosenLevel);
			itemToLoad = tcReference.getDimensionAt(chosenSubject).returnCollectionAt(chosenLevel).returnItemAt(0);
			dispatchEvent(new CustomModuleEvents(CustomModuleEvents.MODULE_FINISHED,false,false,null,itemToLoad,null,chosenLevel,chosenSubject,true));
		}
		

	}
}