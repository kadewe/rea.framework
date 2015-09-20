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
package ItemApplication
{
	import ItemApplication.question.*;
	
	import MainApplication.AbstractModule;
	
	import components.ReaButton;
	import components.ReaImage;
	import components.SkinnedComponents.LabelLineGroup;
	import components.factories.ComplexComponentsFactory;
	import components.factories.ComponentsFactory;
	import components.factories.DisplayFactory;
	
	import enums.GlobalConstants;
	
	import events.CustomModuleEvents;
	import events.ItemEvent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.Timer;
	
	import models.Globals;
	import models.Session;
	import models.TestCollection;
	
	import mx.controls.Alert;
	import mx.core.IVisualElement;
	import mx.events.FlexEvent;
	import mx.managers.CursorManager;
	
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.Label;
	
	import trackers.InputTracker;
	
	import utils.PulseList;
	import utils.ReaVisualUtils;
	import utils.VisibleList;
	
	import views.ErrorView;
	import views.ItemViewContainer;


	/**
	 * Represents a handler for all item releated actions.
	 */
	public class ItemModule extends AbstractModule
	{
		
		//module related variables
		public var relUrl:String;
		private var itemID:String;
		private var nextItem:String;
		
		private var view:ItemViewContainer;
		
		//private var itemInfo:xmlLoader;
		private var responseFlag:Boolean = false;
		private var itemFinalXML:XML = null;
		
		//Item Meta Information
		private var itemType:XMLList;
		private var itemNumber:String;
		private var createVersion:XMLList;
		private var create_date:XMLList;
		private var create_person:XMLList;
		private var answerList:XMLList;
		private var questionsList:XMLList;
		private var preScreenList:XMLList;
		private var imSource:String;
		
		//Item Correct Response
		private var itemCorrectResponseList:XMLList;
		
		//Item Marking
		private var markingList:XMLList;
		public var evaluator:Evaluator;
		
		//Time Components
		private var timeCount:Timer = new Timer(1000);
		private var itemDate:Date = new Date;
		private var currentDay:String;
		//item time
		private var startTime:String;
		private var endTime:String;
		private var currentTime:String;
		private var duration:Number = 0;
		//UserNumber
		private var userNumber:String;
		private var labels:Array;
		

		
		private var playFinished:Boolean=false;
		private var visibleFlagsCollector:Array=new Array();
		
		//------------------------------------------//------------------------------------------//
		//
		//	 									CONSTRUCTOR
		//
		//------------------------------------------//------------------------------------------//
		
		
		/**
		 * Constructor, will only be used by first instantiation.<code>bla</code>
		 * 
		 * @param relative_url the relative path to the applications root directory on the server
		 * @param item_ID alias for itemnumber -> combined  with relative_url will result in path to item data
		 * @param userNumber user number for writing in user folder and xml
		 */
		public function ItemModule(relative_url:String=null,item_ID:String=null,_userNumber:String=null)
		{	
			trace("[itemobject]: instanziation");
			view = new ItemViewContainer();
			references.addItem(view);
			itemID = item_ID
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onCompleteHandler);
			
		}
		
		
		//------------------------------------------//------------------------------------------//
		//
		//	 								SETUP COMPONENTS
		//
		//------------------------------------------//------------------------------------------//
		
		private var loader:URLLoader;
		private var req:URLRequest;
		
		
		private var _collection_progress:Number;
		private var _dimension:int;
		
		/**
		 * Like in the most Classes, this class has a load method seperated from the constructor to ensure a successfull event listener setup.
		 * 
		 */
		override public function load(_globals:Globals,_tcollection:TestCollection,_session:Session):void
		{
			//add event listener to visible list to activate or deactivate elements if a visible event occurs
			VisibleList.addEventListener(VisibleList.IS_BUSY, onVisibleListBusy);
			VisibleList.addEventListener(VisibleList.IS_FREE, onVisibleListFree);
			
			//load progress
			
			_collection_progress = _tcollection.get_testcollection_progress(_session.dimension, _session.level, _session.item);
			
			_dimension = _session.dimension;
			
			var _labels:Array = _globals.labels;
			var _urls:Array = _globals.paths;
			itemID = _session.item;
			userNumber = _session.user.userName;
			trace(userNumber);
			trace("[itemobject]: load with itemid "+itemID);
				
			labels=_labels;

			var itemspath:String
			//looping urls to get item's path
			for(var i:int=0;i<_urls.length;i++)
			{
				rootUrl		= _urls[i][0]==Globals.ROOTURL?_urls[i][1]:rootUrl;	
				scriptUrl 	= _urls[i][0]==Globals.SCRIPTURL?rootUrl+_urls[i][1]:scriptUrl;
				itemspath	= _urls[i][0]==Globals.ITEMS_PATH?_urls[i][1]:itemspath;
				soundUrl	= _urls[i][0]==Globals.SOUND_PATH?_urls[i][1]:soundUrl;
			}
			helpVideos = _globals.videos;
			relUrl = itemspath +itemID+"/";
			trace("[itemobject]: itemid "+ itemID);
			trace("[itemobject]: scriptUrl "+ scriptUrl);
			
			//---------------------------------// LOAD XML DATA
			
			var v:URLVariables = new URLVariables();
				v.param = GlobalConstants.GET_ITEM_DATA;
				v.itemid = itemID;
			
			req= new URLRequest(scriptUrl);
			req.data = v;
			
			req.method = URLRequestMethod.POST;
			
			loader.load(req);
			
			//navigateToURL(req, "new"); //debug
			
			//starting Timer and Count every second
			timeCount.start();
			timeCount.addEventListener(TimerEvent.TIMER, updateSeconds);
			
			//initialise Date and Time settings to trigger start and end time of the application
			currentDay= String(itemDate.getFullYear()) + "_" + String(itemDate.getMonth()+1) + "_" + String(itemDate.getDate());
			startTime = currentDay + "_" + String(itemDate.getHours()) + "_" + String(itemDate.getMinutes()) + "_" + String(itemDate.getSeconds());
			currentTime = startTime;
			//view.time.text = currentTime;
			//dispatchEvent(new Event(LOAD_COMPLETE));
		}
		
		
		//------------------------------------------//------------------------------------------//
		//
		//	 								PUBLIC FUNCTIONS
		//
		//------------------------------------------//------------------------------------------//
		override public function returnView():Group
		{
			return this.view!=null?view:new ErrorView();
		}
		
		/**
		 * tells the class, that the screen is tweened
		 */
		override public function sendTweenFinished():void
		{
			//dies nothing	
		}
		
		
		override public function returnCurrentState():String
		{
			if(currentView=="questionspage")
			{
				return currentView+"_"+qRef._qpState;
			}else{
				return currentView; 
			}
		}
		
		
		/**
		 * removes all eventlisteners from all stored objects and sets them to null
		 */
		override public function unload():void
		{
			trace("[itemobject]: Remove view");
			VisibleList.removeAllEventListeners();
			
			
			if(qRef!=null)qRef.unload();
			
			if(view)view.removeAllElements();
			view = null;
			
			super.unload();
		}
		
		
		
		public function get sourceXML():XML
		{
			if(itemFinalXML!=null)
			{
				return itemFinalXML;
			}else{
				return new XML();
			}
		}
		


		
		override public function getClassName():String
		{
			return "ItemModule";
		}	
		

		
		//------------------------------------------//------------------------------------------//
		//
		//	 							SETUP FOR VISUAL COMPONENTS
		//
		//------------------------------------------//------------------------------------------//
		
		
		
		/**
		 * After a successfull xmlresult the method will fetch all required information for further process.
		 * The Instructional Part of the XML will be read and the relaevant Objects (text,images, buttons) will be created.
		 * Be sure that you change this well, if you change the xml structure. All display components will be load at once but displayed in a different manner. Some Items will implement
		 * a prescreen, watch out for the different implementations for prescreen and instruction part.
		 * 
		 * @see #load()
		 * @see ItemApplication.xmlLoader
		 * @see Shared.XLoader
		 */
		private function onCompleteHandler(event:Event):void
		{
			if(loader.data=="failed")
			{
				trace("[itemobject]: loading item failed");
				dispatchEvent(new Event(CustomModuleEvents.MODULE_FINISHED));
			}else{
				trace("[itemobject]: loading item XML successful");
				try
				{
					this.itemFinalXML = XML(loader.data);	
				} 
				catch(error:Error) 
				{
					dispatchEvent(new CustomModuleEvents(CustomModuleEvents.MODULE_FINISHED,false,true,userNumber,itemID,currentDay));	
				}
				view.addEventListener(FlexEvent.CREATION_COMPLETE, onViewCreationComplete);
				dispatchEvent(new CustomModuleEvents(CustomModuleEvents.MODULE_LOAD_COMPLETE));
			}
			
		}
		
		
		private function onViewCreationComplete(event:FlexEvent):void
		{
			trace("VIEW CREATION COMPLETE");
			initComponents();
		}

		private var currentView:String;

		private var _current_dimension_name:String;
		
		/**
		 * @private
		 */
		private function initComponents():void
		{
			//INIT PROGRESSBAR
			view.task_progress_bar.setProgress(_collection_progress, 100);
			view.task_progress_bar.label = itemID;
				
			//INIT NVAIGATIONBUTTON EVENTS
			view.addEventListener(ItemViewContainer.ABORT, function():void{dispatchEvent(new ItemEvent(ItemEvent.TEST_ABORTED))});
			view.addEventListener(ItemViewContainer.RESUME, resumeViewState);
			
			//init eval button
			if(_collection_progress > 0)
			{
				view.evaluation_button.addEventListener(MouseEvent.CLICK, function():void{dispatchEvent(new ItemEvent(ItemEvent.EVALUATION_CALLED))});
				view.evaluation_button.scriptUrl = scriptUrl;
				view.evaluation_button.source 	 = Globals.instance().returnSoundUrl(view.evaluation_button.id);	
			}else{
				view.evaluation_button.enabled=false;
			}
			
			
			
			//init abort button
			view.abort_button.scriptUrl = scriptUrl;
			view.abort_button.source	= Globals.instance().returnSoundUrl(view.abort_button.id);
			
			
			
			view.addEventListener(FlexEvent.STATE_CHANGE_COMPLETE, onViewStateChanged);
			
			//colorize background theme and pbar
			var from_col:uint ;
			switch(_dimension)
			{
				case 0:
					from_col = uint(Globals.instance().returnSettingsValue("readingFromColor"));
					view.from_color.color = from_col;
					view.task_progress_bar.barColor = from_col;
					view.to_color.color = uint(Globals.instance().returnSettingsValue("readingToColor"));
					_current_dimension_name = "lesen";
					break;
				case 1:
					from_col = uint(Globals.instance().returnSettingsValue("writingFromColor"));
					view.from_color.color = from_col;
					view.task_progress_bar.barColor = from_col;
					view.to_color.color = uint(Globals.instance().returnSettingsValue("writingToColor"));
					_current_dimension_name = "lchreiben";
					break;
				case 2:
					from_col = uint(Globals.instance().returnSettingsValue("mathFromColor"));
					view.from_color.color = from_col;
					view.task_progress_bar.barColor = from_col;
					view.to_color.color = uint(Globals.instance().returnSettingsValue("mathToColor"));
					_current_dimension_name = "rechnen";
					break;
				case 3:
					from_col= uint(Globals.instance().returnSettingsValue("languageFromColor"));
					view.from_color.color = from_col;
					view.task_progress_bar.barColor = from_col;
					view.to_color.color = uint(Globals.instance().returnSettingsValue("languageToColor"));
					_current_dimension_name = "sprache";
					break;
			}
			
			
			PulseList.flush();
			PulseList.setDebug(true);
			this.itemType = XMLList(itemFinalXML.meta_item);
			this.itemNumber = itemID;
			
			this.createVersion = XMLList(itemFinalXML.Item_creation.version);
			this.create_date = XMLList(itemFinalXML.Item_creation.date);
			this.create_person = XMLList(itemFinalXML.Item_creation.person);
			this.questionsList = XMLList(itemFinalXML.questions);
			
			this.itemCorrectResponseList =  XMLList(itemFinalXML.correctResponse.children());		
			this.markingList = XMLList(itemFinalXML.marking.children());
			this.answerList = XMLList(itemFinalXML.answers.children());
			
			initPreScreen();
			dispatchEvent(new CustomModuleEvents(CustomModuleEvents.MODULE_LOAD_COMPLETE));
		}
		
		protected function resumeViewState(event:Event):void
		{
			// TODO Auto-generated method stub
			view.setCurrentState(last_state);
		}
		
		//intially always prescreen
		private var last_state:String = ItemViewContainer.PRESCREEN;
		
		private var _abort_init:Boolean=false;
		
		
		protected function onViewStateChanged(event:FlexEvent):void
		{
			switch(view.currentState)
			{
				
				//----------- Abort to main menu screen ------------//
				
				case ItemViewContainer.ABORT:
					if(_abort_init)break;
					view.confirmAbort.text = 		Globals.instance().returnLabelValue(view.confirmAbort.id);
					view.confirmAbortSound.scriptUrl = 	scriptUrl;
					view.confirmAbortSound.source = Globals.instance().returnSoundUrl(view.confirmAbort.id);
					view.yesButton.scriptUrl = 			scriptUrl;
					view.noButton.scriptUrl = 			scriptUrl;
					view.yesButton.source = 		Globals.instance().returnSoundUrl(view.yesButton.id);
					view.noButton.source = 			Globals.instance().returnSoundUrl(view.noButton.id);
					_abort_init=true;
					break;
				
				//----------- item task pre screen ------------//
				
				case ItemViewContainer.PRESCREEN:
					last_state = view.currentState;
					break;
				
				
				//----------- item instruction and question screen ------------//
				
				case ItemViewContainer.NORMAL:
					last_state = view.currentState;
					if(!instructions_initialized)
						initInstructions();
					break;
				
				
				//----------- evaluation screen ------------//
				
				case ItemViewContainer.EVALUATE:
					if(_evaluation_init)break;
					
					//setup end button
					view.endButton.scriptUrl = scriptUrl;
					view.endButton.source = Globals.instance().returnSoundUrl(view.endButton.id);
					
					//setup continue to task button
					view.forwardButton.scriptUrl = scriptUrl;
					view.forwardButton.source = Globals.instance().returnSoundUrl(view.forwardButton.id);
					
					if(_collection_progress > 0)
						view.evaluation_content.addElement(DisplayFactory.evaluationDisplay(userNumber, _current_dimension_name,scriptUrl,_collection_progress));
					else
					{
						var hg:HGroup = ComponentsFactory.createHGroup("24569023njk","center","middle");
							hg.percentHeight = 100;
							hg.percentWidth =  100;
						var l:Label = ComponentsFactory.createLabe("Sie haben noch keine Aufgabe bearbeitet.","noTaskFinished");
							l.percentWidth = 50;
							l.setStyle("textAlign","center");
							hg.addElement(l);
						view.evaluation_content.addElement(hg);
					}
					

					
					_evaluation_init=true;	
					break;
				
				
				//----------- help screen ------------//
				
				case ItemViewContainer.HELP:
					trace(last_state);
					var currentViewRef:String=ItemViewContainer.NORMAL;
						currentViewRef = (last_state == ItemViewContainer.PRESCREEN || last_state == ItemViewContainer.EVALUATE) ? last_state : itemType.toString();
					view.help_wrapper.addElement(DisplayFactory.helpDisplay("ItemModule",currentViewRef, view.stop_vid_ref));
					break;
			}
		}		
		
		protected var _evaluation_init:Boolean;
		
		
		//------------------------------------------------------//
		//		PRE SCREEN
		//------------------------------------------------------//
		
		protected function initPreScreen():void
		{
			VisibleList.init();


			trace("INIT PRESCREEN");
			//view.item_questionWrapperBox.visible=false;
			
			//Image Group on PreScreen
			var pre_image_group:HGroup = ComponentsFactory.createHGroup("preImGrp","center","top");
				pre_image_group.percentWidth = 100;
				pre_image_group.percentHeight = 100;
				
			var pre:XMLList =  new XMLList(itemFinalXML.prescreen);
			if( pre.hasComplexContent() )
			{
				trace("[itemObject]: create PreScreen");
				
				preScreenList = pre.children();
				if(preScreenList.length()>0)currentView="preScreen";
				
				//ITERATE PRESCREN NODES
				for(var i:int=0;i<preScreenList.length();i++)
				{
					switch(preScreenList[i].localName())
					{
						case("pre_text"):
							var preGrp:LabelLineGroup = ComplexComponentsFactory.createLabelLineGroup(
								true,true,"_preText_"+i.toString(),
								preScreenList[i],preScreenList[i].@cssstyle,
								playSound,scriptUrl,relUrl,preScreenList[i].@sound
							);
							
							VisibleList.addToList(	preGrp.button_ref as IVisualElement);
							PulseList.addToList(	preGrp.button_ref	);

							view.pregroup_content.addElement(preGrp);
							references.addItem(preGrp);
							break;
						case("pre_media"):
							//image
							var preIm:ReaImage = ComponentsFactory.createCustomImage("preImage"+i.toString(),scriptUrl,relUrl+preScreenList[i].@file,100,100);
							pre_image_group.addElement(preIm as IVisualElement);
							break;
					}
				}

				view.pregroup_content.addElement(pre_image_group);
				view.pregroup_forwardButton.label = Globals.instance().returnLabelValue("forwardButton");
				
				PulseList.addToList(view.pregroup_forwardButton);
				VisibleList.start();
				PulseList.start();
				PulseList.init();
			}else{
				view.setCurrentState("normal");
			}
			
			
		}

		//------------------------------------------------------//
		//		INSTRUCTION INIT
		//------------------------------------------------------//
		protected var instructions_initialized:Boolean;
		protected function initInstructions():void
		{
			PulseList.flush();
			VisibleList.flush();

			//instructional information build up
			var imCount:Number=0;
			var textSize:Number=0;
			var instr:XMLList = XMLList(itemFinalXML.instruction.children());
			
			for(var i:int=0;i<instr.length();i++)
			{
				switch(instr[i].localName())
				{
					case("in_text"):
						
						//instructionsgroup
						var insGroup:LabelLineGroup = 
						ComplexComponentsFactory.createLabelLineGroup(
							true,true,i.toString(),instr[i].children(),
							instr[i].@style,
							playSound,scriptUrl,relUrl,instr[i].@sound || ""
						);
						trace("ITEM BUTTON REF: "+insGroup.button_ref);
						VisibleList.addToList(	insGroup.button_ref as ReaButton);
						PulseList.addToList(	insGroup.button_ref);

						view.instrGroup.addElement(insGroup);
						break;
					case("media"):
						imCount++;						
						var _im:ReaImage = ComponentsFactory.createCustomImage("insIm"+i.toString(),scriptUrl, relUrl+instr[i].@file,90,90);
						view.instrGroup.addElement(_im as IVisualElement);	
						references.addItem(_im);
						trace("[itemobject]: image: " + imSource);		
						break;
				}
				
			}
			
			/*
			always create a button for next stage
			*/
			var show:ReaButton = ComponentsFactory.createStartButton("ins_fwd",null) as ReaButton;
				show.addEventListener(MouseEvent.CLICK,makeQVisible);
				show.visible=false;
			PulseList.addToList(show);
			view.content_wrapper.addElement(show);
				
			VisibleList.addToList(show);
			VisibleList.start();
			
			PulseList.init();
			PulseList.start();
			
			instructions_initialized=true;
		}
		

		//-------------------------------------------
		// VISUAL EVENTS
		//-------------------------------------------
		
		
		protected function onVisibleListBusy(event:Event):void
		{
			if(view)
			{
				view.disable_navigation();
			}
		}
		
		protected function onVisibleListFree(event:Event):void
		{
			if(view)
				view.enable_navigation();
		}


		
		
		/**
		 * @private
		 * In this event driven method, the target is searched in the refernces Array and if found, reduced to
		 * the minimum size to ensure a correct display of the questions view component.
		 */
		private function makeQVisible(event:Event):void
		{
			ReaVisualUtils.stopPulse();
			view.content_wrapper.removeElement(event.target as IVisualElement);
			ReaVisualUtils.fadeOutSound();
			CursorManager.setBusyCursor();
			trace("[itemObject]:create questionpage");
			createQuestions();
			trace("[itemObject]: add qref complete eventlistener");
			qRef.addEventListener(QuestionsObject.LOAD_COMPLETE, questionsReady);
			qRef.load();
		}
		
		
		private function questionsReady(event:Event):void
		{
			
			trace("[itemObject]: qref load complete received");
			currentView="questionspage";
			CursorManager.removeAllCursors();
			VisibleList.start();
		}
		




		
		//------------------------------------------//------------------------------------------//
		//
		//	 							SETUP FOR QUESTION OBJECT
		//
		//------------------------------------------//------------------------------------------//
		
		private var qRef:QuestionsObject = null;
		
		/** 
		 * @private
		 * loads the correct question type by reading the "meta" tag from the item xml
		 * content from question object will be displayed as components of view.qwrapper
		 * 
		 * @see DisplayApplication.ItemViewContainer
		 */
		private function createQuestions():void
		{
			trace("[itemObject]: type: " + this.itemType.toString());
			InputTracker.setModuleSubType(this.itemID);

			switch(this.itemType.toString())
			{
				case("cloze"):
					trace("[itemObject]: load cloze");
					//trace(itemInfo.n_questions);
					var _cloze:Cloze = new Cloze();
					qRef = _cloze;
					_cloze.current_item_id = itemID;
					_cloze.init(questionsList,scriptUrl,relUrl);
					_cloze.addEventListener(ItemEvent.QPAGE_FINISHED, onItemFinished);
					_cloze.ignoreSound = playSound;
					_cloze.debug = debug;
					_cloze.track = track;
					
					view.item_questionWrapperBox.addElement(_cloze.qView);
					references.addItem(_cloze);
					
					break;
				case("mchoice"):
					trace("[itemObject]: load single choice");
					var _mchoice:SingleChoice = new SingleChoice();
					qRef = _mchoice;
					_mchoice.current_item_id = itemID;
					_mchoice.init(questionsList,scriptUrl,relUrl);
					_mchoice.addEventListener(ItemEvent.QPAGE_FINISHED, onItemFinished);
					_mchoice.ignoreSound = playSound;
					_mchoice.debug = debug;
					_mchoice.track = track;
					view.item_questionWrapperBox.addElement(_mchoice.qView);
					references.addItem(_mchoice);
					break;
				case("rmchoice"):
					trace("[itemObject]: load multiple choice");
					var _rmchoice:MultipleChoice = new MultipleChoice();
					qRef = _rmchoice;
					_rmchoice.current_item_id = itemID;
					_rmchoice.init(questionsList,scriptUrl,relUrl);
					_rmchoice.addEventListener(ItemEvent.QPAGE_FINISHED, onItemFinished);
					_rmchoice.ignoreSound = playSound;
					_rmchoice.debug = debug;
					_rmchoice.track = track;
					view.item_questionWrapperBox.addElement(_rmchoice.qView);
					references.addItem(_rmchoice);
					break;
				case("sccloud"):
					trace("[itemObject]: load sc cloud");
					var _sccloud:ScCloud = new ScCloud();
					qRef = _sccloud;
					_sccloud.current_item_id = itemID;
					_sccloud.init(questionsList,scriptUrl,relUrl);
					_sccloud.addEventListener(ItemEvent.QPAGE_FINISHED, onItemFinished);
					_sccloud.ignoreSound = playSound;
					_sccloud.debug = debug;
					_sccloud.track = track;
					view.item_questionWrapperBox.addElement(_sccloud.qView);
					references.addItem(_sccloud);
					break;
				case("selectandwrite"):
					trace("[itemObject]: load selectandwrite");
					var _saw:SelectAndWrite = new SelectAndWrite();
					qRef = _saw;
					_saw.current_item_id = itemID;
					_saw.init(questionsList,scriptUrl,relUrl);
					_saw.addEventListener(ItemEvent.QPAGE_FINISHED, onItemFinished);
					_saw.ignoreSound = playSound;
					_saw.debug = debug;
					_saw.track = track;
					view.item_questionWrapperBox.addElement(_saw.qView);
					references.addItem(_saw);
					break;
				case("clozenchoice"):
					var _cnz:ClozeNChoice = new ClozeNChoice();
					qRef = _cnz;
					_cnz.current_item_id = itemID;
					_cnz.init(questionsList,scriptUrl,relUrl);
					_cnz.addEventListener(ItemEvent.QPAGE_FINISHED, onItemFinished);
					_cnz.ignoreSound = playSound;
					_cnz.debug = debug;
					_cnz.track = track;
					view.item_questionWrapperBox.addElement(_cnz.qView);
					references.addItem(_cnz);
					break;
				default: Alert.show("wrong question type declared!");
					//error log
					//fallback
					break;
			}
			
			VisibleList.flush();
			VisibleList.addToList(view.item_questionWrapperBox);
			
			
		}
		

		
		
		/**
		 * Timer for simulating a clock to ensure correct timeStamp entries.
		 * 
		 * @see timeStamp
		 */
		public function updateSeconds(event:TimerEvent):void
		{
			itemDate = new Date;
			currentTime = currentDay + "_" + String(itemDate.getHours()) + "_" + String(itemDate.getMinutes()) + "_" + String(itemDate.getSeconds());
			duration+=1;
		}
		

		


		
		
		
		//------------------------------------------//------------------------------------------//
		//
		//	 							   POST ITEM PROCESSING
		//
		//------------------------------------------//------------------------------------------//
		
		
		/**
		 * If User finishes an item, this function will be called by event and evaluates the user inputs to prepare writing the xml-.
		 */					
		private function onItemFinished(event:ItemEvent):void
		{
			utils.ReaVisualUtils.fadeOutSound();
			this.endTime = this.currentTime;
			trace("[itemobject]: endtime: " + endTime);
			trace("");
			trace("******************");
			trace("[itemobject]: questions finished received, will now evaluate user input data");
			trace("");
			
			var uInput:Array = event.dataObject as Array;

			for(var i:int=0; i<uInput.length;i++)
			{
				for(var j:int=0;j<answerList.length();j++)
				{
					if(answerList[j].@answerid == uInput[i][0])
					{
						try
						{
							answerList[j].setChildren(uInput[i][1]);	
						}catch(e:Error){
							trace("[Item Object]: critical Error: children not set correctly, evaluation might be invalid!");
							//fallback
							answerList[i].setChildren("failed");
						}
						trace(answerList[j].toXMLString());
					}
				}
			}
			
			evaluator = new Evaluator(true);
			evaluator.init(this.markingList,this.itemCorrectResponseList,this.answerList,this.itemType.children().toString());
			evaluator.addEventListener(Evaluator.EVALUTION_DONE, onEvalFinished);
			evaluator.load();
			//evaluation();
			
		}
		
		
		
		private function onEvalFinished(event:Event):void
		{
			
			
			
			this.markingList = evaluator.returnMarkingList();
			buildXML();
			dispatchEvent(new CustomModuleEvents(CustomModuleEvents.MODULE_FINISHED,false,false,null,itemID,startTime,-1,-1,false,itemFinalXML));
		}
		

		
		

		
		/**
		 * constructs a new xml copy of the origin by constructing the different elements in right order.
		 * Be sure that you really have to change this, if you change the xml structure. 
		 */
		private function buildXML():void
		{
			this.itemFinalXML.answers.setChildren(this.answerList);
			this.itemFinalXML.marking.setChildren(this.markingList);
			this.itemFinalXML.time.start_time.setChildren(this.startTime);
			this.itemFinalXML.time.end_time.setChildren(this.endTime);
			this.itemFinalXML.time.time_consumption.setChildren(String(this.duration));
			this.itemFinalXML.usernumber.appendChild(this.userNumber);
		}
		

		

	}
}