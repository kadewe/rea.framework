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

package MainApplication
{
	import ItemApplication.ItemModule;
	
	import MainApplication.*;
	
	import administration.AdminObject;
	
	import components.factories.ComponentsFactory;
	
	import enums.GlobalConstants;
	
	import events.CustomModuleEvents;
	import events.ItemEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.system.System;
	
	import models.Globals;
	import models.Session;
	import models.TestCollection;
	
	import mx.managers.CursorManager;
	
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.Label;
	
	import trackers.ErrorDispatcher;
	import trackers.InputTracker;
	import trackers.TrackingTypes;
	
	import utils.ReaVisualUtils;
	
	import views.*;
	
	/**
	 * The core controller class.
	 * Manages the loading and unloading of the modules as well as the communication between them and the model related data.
	 * Modules a loaded by name, their functions are accessed via <code>ICustomModule</code> interface.
	 * The view component of the modules get connected with the <code>DisplayManager</code>
	 * 
	 * @author Jan Küster
	 * 
	 * @see Interfaces.ICustomModule;
	 * @see MainApplication.DisplayManager
	 */
	public class MainAppManager extends EventDispatcher
	{
		//----------------------------------//
		// Event Constants
		//----------------------------------//
		
		/**
		 * Dispatched when a module is finished.
		 */
		public static const MODULE_FINISHED:String = "creationComplete";
		
		/**
		 * Dispatched when everything has been loaded.
		 */
		public static const LOAD_COMPLETE:String = "loadComplete";
		
		/**
		 * Dispatched when a display update is necessary.
		 */
		public static const DISPLAY_UPDATE:String = "displayUpdate";
		
		
		//----------------------------------//
		// Application Settings-Flags
		//----------------------------------//
		
		/**
		 * @private
		 */
		private var displaySkipButton:Boolean;
		
		
		
		/**
		 * @private
		 */
		private var displaySkipTweenButton:Boolean;
		
		/**
		 * @private
		 */
		private var displaySessionMonitor:Boolean;
		
		/**
		 * @private
		 */
		private var soundMode:Boolean;
		
		/**
		 * @private
		 */
		private var debug:Boolean;
		
		/**
		 * @private
		 */
		private var _track:Boolean;

		/**
		 * Represents if tracking is active
		 */
		public function get track():Boolean
		{
			return _track;
		}

		public function set track(value:Boolean):void
		{
			_track = value;
		}

		
		//----------------------------------//
		// Data Structures (MODEL)
		//----------------------------------//
		
		/**
		 * The test collection representing the dimensions, levels and item list for all possible tests.
		 */
		protected var testCollection:TestCollection;
		
		/**
		 * The session reference. Is required to update the user session.
		 */
		protected var session:Session;
		
	
		//----------------------------------//
		// Control Structures
		//----------------------------------//
		
		/**
		 * The current instance of an abstract module. The manager communicated via the abstract methods, which are implemented by each class differently.
		 */
		protected var instance:AbstractModule;
		
		
		/**
		 * @private
		 */
		private var incl:String;
		
		//----------------------------------------------------//
		//
		//			CONSTRUCTIOR
		//
		//----------------------------------------------------//		
		
		/**
		 * Constructor, no parameters. Initializes <code>Globals</code> and starts a new <code>Session</code>.
		 * 
		 * @see Model.Globals
		 * @see Model.Session
		 */
		public function MainAppManager()					
		{
			
			session=new Session();
			session.reset();
			Globals.instance().addEventListener(Globals.GLOBALS_LOADED, onGlobalsLoaded);
			Globals.instance().addEventListener(Globals.GLOBALS_FAULT, onGlobalsFault);
			Globals.instance().initializeData();
		}
		
		
		
		
		//----------------------------------------------------////----------------------------------------------------//
		//
		//
		//												DISPLAY CREATION
		//
		//
		//----------------------------------------------------////----------------------------------------------------//
		
		/**
		 * Returns a reference to the view component, owned by the current module instance. Debug and monitoring components will be injected by the <code>getDisplayComponents()</code> method. 
		 * If an error occurs, the fallback catches it with returning the standard view group of a modules' instance.
		 * 
		 * 
		 * @return Group view object, usually a group based mxml component.
		 */
		public function getView():Group
		{
			var errormes:String="";
			try
			{
				return getDisplayComponents();
			}catch(e:Error){
				ErrorDispatcher.processNewError
					(
						"3",
						GlobalConstants.NULLREFERENCE,
						e.errorID.toString(),
						e.name + " could not access all monitoring/debug components. "
						,"MainAppManager.as",
						Globals.instance().returnPathValue(Globals.ROOTURL) + Globals.instance().returnPathValue(Globals.SCRIPTURL),
						false
					);
				errormes+="\n could not access all monitoring/debug components."+e.message;
			}
			try
			{
				return instance.returnView();
				
			}catch(e:Error){
				ErrorDispatcher.processNewError
					(
						"3",
						GlobalConstants.NULLREFERENCE,
						e.errorID.toString(),
						e.name + " could not access module instance's view component. "
						,"MainAppManager.as",
						Globals.instance().returnPathValue(Globals.ROOTURL) + Globals.instance().returnPathValue(Globals.SCRIPTURL),
						false
					);
				errormes+="\n ould not access module instance's view component"+e.message;
			}
			return new ErrorView().setMessage("Mainappmanager view is null"+errormes);
		}
		
		
		/**
		 * @private
		 **/
		private function getDisplayComponents():Group
		{
			
			var view:Group = instance.returnView();
			
			var hgr:HGroup = new HGroup();
			var s:Array = session.returnAsArray();
			var i:int=0;
			var b:Button;
			
			
			//------------------------- DEBUG ADDITIONS ----------------------//
			
			if(displaySessionMonitor)
			{
				trace("[MainAppManager]: add session monitor display");
				for(i= 0; i<s.length;i++)
				{
					var l:Label = new Label();
					l.text = s[i][0] + " " + s[i][1];
					l.styleName = "Text-Monitor";
					hgr.addElement(l);
				}		
			}
			if(displaySkipButton)
			{
				trace("[MainAppManager]: add skip button");
				b = new Button();
				b.label = "skip";
				b.addEventListener(MouseEvent.CLICK, onSkipButtonClick);
				hgr.addElement(b);
			}
			if(displaySkipTweenButton)
			{
				trace("[MainAppManager]:add skip tween");
				b = new Button();
				b.label = "tween";
				b.addEventListener(MouseEvent.CLICK, onSkipButtonClick);
				hgr.addElement(b);
			}
			
			if(displaySessionMonitor || displaySkipButton || displaySkipTweenButton)view.addElement(hgr);
			
			return view;
		}
		


		
		//----------------------------------------------------////----------------------------------------------------//
		//
		//
		//												MONITOR FEATURES EVENTS
		//
		//
		//----------------------------------------------------////----------------------------------------------------//
		
		/**
		 * @private
		 */
		private function onSkipButtonClick(event:MouseEvent):void
		{
			if(instance.getClassName() == GlobalConstants.ITEM_MOD)
				instance.dispatchEvent(new CustomModuleEvents(instance.returnModuleFinishedEvent(),false,false,null,session.item,"",session.level,session.dimension,false,new XML()));
		}
		
		
		/**
		 * Informs the current instance of an AbstractModule that the tween is finished.
		 */
		public function sendTweenComplete():void
		{
			if(instance!=null)
			{
				if(track)
				{
					try
					{
						InputTracker.logEvent(instance.returnCurrentState(),instance.returnView().stage.mouseX,instance.returnView().stage.mouseY,TrackingTypes.MODULE_START,instance.getClassName());
					}catch(error:Error){}
						
				}
				instance.sendTweenFinished();
				
			}		
		}
		

		

	
		
		/**
		 * Calls the current instance to return its view's currentState. 
		 */
		public function getCurrentViewState():String
		{
			if(instance==null)return "loading view";
			return instance.returnCurrentState();
		}
		
		//----------------------------------------------------////----------------------------------------------------//
		//
		//
		//												PRIVATE MAIN METHODS
		//
		//
		//----------------------------------------------------////----------------------------------------------------//
		
		/**
		 * Classname reference to the login module
		 */
		public static const MOD_LOGIN:String = "LoginModule";
		
		
		/**
		 * Classname reference to the overview module
		 */
		public static const MOD_OVERVIEW:String = "OverviewModule";
		
		/**
		 * Classname reference to the start module
		 */
		public static const MOD_STARTAPP:String = "StartAppModule";
		
		/**
		 * Classname reference to the module which is loaded after the tests have been finished
		 */
		public static const MOD_FINISHED:String = "TestFinishedModule";
		
		/**
		 * Classname reference to the generic item module
		 */
		public static const MOD_ITEM:String = "ItemModule";
		
		/**
		 * Classname reference to the admin module
		 */
		public static const MOD_ADMIN:String = "AdminObject";
		
		
		
		
		/**
		 * Loads a new module by classname. See constants which begin with MOD_ to see the possible modules. Catches errors by loading the start module.
		 * 
		 * 
		 * @param className The name of the current class to load.
		 * @see MainApplication.AbstractModule
		 */
		protected function loadModule(className:String):void
		{
			try
			{
				
				var split:Array = className.split(".");
				var classRef:String = split.length > 1 ? split[1] : split[0];
				switch(classRef)
				{
					case MOD_LOGIN:
						instance = new LoginModule();
						break;
					case MOD_OVERVIEW:
						instance = new OverviewModule();
						break;
					case MOD_STARTAPP:
						instance = new StartAppModule();
						break;
					case MOD_FINISHED:
						instance = new TestFinishedModule();
						break;
					case MOD_ITEM:
						instance = new ItemModule();
						instance.addEventListener(ItemEvent.TEST_ABORTED, onTestAborted);
						break;
					case MOD_ADMIN:
						instance = new AdminObject();
						break;
					
					default:
						instance = new StartAppModule();
						break;
				}
				
				
				//instance =new ClassReference() as ICustomModule;
				instance.debug = debug;
				instance.track = track;
				instance.playSound = soundMode;
				
				//add standard module events 
				instance.addEventListener(CustomModuleEvents.MODULE_LOAD_COMPLETE, onInstanceLoadComplete);
				instance.addEventListener(CustomModuleEvents.MODULE_FINISHED, onModuleFinished);
				
				instance.load(Globals.instance(),testCollection,session);	//BE SURE THAT NO ERRORS OCCUR IN THE LOAD FUNCTION (WILL BE CATCHED BY THIS STATEMENT!)
				
			}catch(e:Error){
				ErrorDispatcher.processNewError
					(
					"4",
					GlobalConstants.CANNOT_LOAD_MODULE,
					e.errorID.toString(),
					e.name + " classreference: "+className,"MainAppManager.as",
					Globals.instance().returnPathValue(Globals.ROOTURL) + Globals.instance().returnPathValue(Globals.SCRIPTURL),
					false
					);
				
				throw new Error(e);
				//extreme fallback to very first module.
				//write other fallback here
				this.loadModule("MainApplication.StartAppModule");
			}
			if(track)
			{
				try
				{
					InputTracker.setModuleType(className);
					InputTracker.setUser(session.returnTrackSessionUser());
				}catch(error:Error){}
			}
			CursorManager.removeAllCursors();
		}
		
		
		/**
		 * Cleans up the current module and returns to the overview. This method is only called if we are in an item module.
		 * 
		 * @param event Standard Event.
		 */
		protected function onTestAborted(event:Event):void
		{
			
			//cleanup
			dispatchEvent(new Event(MODULE_FINISHED));
			instance.removeAllEventListeners();
			instance=null;
			this.loadModule(MOD_OVERVIEW);
		}
		

		
		/**
		 * Dispatches a load complete event to the application root.
		 * 
		 * @param event Standard Event.
		 */
		protected function onInstanceLoadComplete(event:Event):void
		{
			dispatchEvent(new Event(LOAD_COMPLETE));
		}
		
		
		/**
		 * If a module instance dispatches the finish event, this method updates the session, gets the next item and module to load and then calls the loadmodule function.
		 * 
		 * @param event A custom module event. In this case CustomModuleEvents.MODULE_FINISHED which is dispatched by the current module
		 * 
		 * @see Events.CustomModuleEvents
		 * @see #loadModule 
		 */
		protected function onModuleFinished(event:CustomModuleEvents):void
		{
			
			CursorManager.setBusyCursor();
			if(track)
			{
				try
				{
					InputTracker.processLog();
					InputTracker.sendLog(incl,false);
				}catch(error:Error){}
				
			}

			//instance.unload();
			
			//highest priority!!!!
			if(event.adminMode)
			{
				dispatchEvent(new Event(MODULE_FINISHED));
				instance.removeAllEventListeners();
				instance.unload();
				instance=null;
				this.loadModule(LoaderManagement.getNext2Load("","admin"));
				return;
			}
			
			//update Session Object
			session.updateSession(event._dimension,event._level,event._itemString);
			
			var nextItem:String = event._isNext==true?event._itemString:testCollection.searchNextItem(session.dimension,session.level,session.item);
			
			//fallback update if not in item collection
			session.updateSession(-1,-1,nextItem);
			
			//create user object if user url has been passed
			if(event._userDataUrl!=null)
			{
				session.create_user(event._userDataUrl);
			}
			if(event._isNext)
			{
				session.user.startSession(
					testCollection.getDimensionAt(session.dimension).returnCollectionAt(session.level).returnItems(),
					testCollection.getDimensionName(session.dimension),
					testCollection.getLevelName(session.dimension,session.level),
					(incl)
				);
			}
			
			//update user session
			if(!event._isNext && event._itemString)
			{
				session.user.updateSession(
					event._itemString,
					event._timeStamp,
					event._updatedXML,
					(incl)
				);
			}
			
			//get the next module 
			var nextInstance:String = LoaderManagement.getNext2Load(instance.getClassName(),nextItem);
			
	
			//cleanup
			dispatchEvent(new Event(MODULE_FINISHED));
			instance.removeAllEventListeners();
			instance.unload();
			instance=null;
			
			System.pauseForGCIfCollectionImminent(1.0);
			
			this.loadModule(nextInstance);
		}
		
	
		
		/**
		 * @private
		 */
		private function onGlobalsFault(event:Event):void
		{
			Globals.instance().removeAllEventListeners();
			
			//write fallback here
		}
		

		
		/**
		 * @private
		 */
		private function onGlobalsLoaded(event:Event):void
		{
			Globals.instance().removeAllEventListeners();
			
			//set include script path
			incl = (Globals.instance().returnPathValue(Globals.ROOTURL)+Globals.instance().returnPathValue(Globals.SCRIPTURL));
			
			ComponentsFactory.scriptUrl = Globals.instance().returnPathValue(Globals.SCRIPTURL);
			
			//set global settings
			displaySkipButton = 			Globals.instance().returnSettingsValue(GlobalConstants.SHOW_NEXTITEM_BUTTON) == "1" ? true : false;
			displaySkipTweenButton =		Globals.instance().returnSettingsValue(GlobalConstants.SHOW_SKIP_TWEEN_BUTTON) == "1" ? true : false;
			displaySessionMonitor = 		Globals.instance().returnSettingsValue(GlobalConstants.SHOW_CURRENT_SESSION)=="1"?true:false;
			debug = 						Globals.instance().returnSettingsValue(GlobalConstants.DEBUG)=="1"?true:false;
			soundMode = 					Globals.instance().returnSettingsValue(GlobalConstants.IGNORE_SOUND)=="1"?true:false;
			track = 						Globals.instance().returnSettingsValue(GlobalConstants.TRACKINPUT) == "1" ? true : false;
			ReaVisualUtils.setPulseOnOff(	Globals.instance().returnSettingsValue(GlobalConstants.SCAFFOLDING) == "1" ? true : false );
			
			if(track)
			{
				session.setTrackSessionUser(8);
				InputTracker.setGlobalSettings(Globals.instance().returnSource());
			}
			
			//-----------------------------------------// Global Settings loaded, now we can start the application
			this.loadModule(MOD_STARTAPP);

			
			//-----------------------------------------// meanwhile load the testcollection
			testCollection = new TestCollection(Globals.instance().returnPathValue(Globals.ROOTURL),Globals.instance().returnPathValue('getTCollection'),Globals.instance().returnPathValue(Globals.SCRIPTURL));
			testCollection.addEventListener(TestCollection.TC_BUILD, onTCBuild);
			testCollection.addEventListener(TestCollection.TC_ERROR, onTCError);
		}
		
		/**
		 * @private
		 */
		private function onTCBuild(event:Event):void
		{
			testCollection.removeAllEventListeners();
			trace("TestCollection build successfully");
		}
		
		
		/**
		 * @private
		 */
		private function onTCError(event:Event):void
		{
			testCollection.removeAllEventListeners();
			//write fallback
			//throw new Error("Could not load Testcollection!");
		}
		
	}
}