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
package ItemApplication.question
{
	import components.SkinnedComponents.SmallEyeButton;
	import components.SkinnedComponents.SmallSoundButton;
	import components.factories.ComponentsFactory;
	
	import events.CustomEventDispatcher;
	import events.ItemEvent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import interfaces.ICustomEventDispatcher;
	import interfaces.ISelectable;
	import interfaces.IWritable;
	
	import models.Globals;
	
	import mx.events.FlexEvent;
	
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.primitives.Line;
	
	import utils.PulseList;
	import utils.ReaVisualUtils;
	
	import views.QuestionView;

	
	/**
	 * Defines the basic structure and bahvior of a question object. The detailed behavior like load and display data is defined in each of the extending quesion classes.
	 * 
	 * <p>A special feature is the load content by page behavior. All Data will be loaded immediately after calling the specific questionspage and will be unloaded
	 * by calling another questionpage. This frees memory and enables a fluid application.</p>
	 */
	public class QuestionsObject extends CustomEventDispatcher implements ICustomEventDispatcher
	{
		/**
		 * xml source data, received from itemObject
		 */
		public var source:XMLList;
		public var qView:QuestionView;						//display object
		
		
		public static const LOAD_COMPLETE:String = "loadCOmplete";
		
		private var _track:Boolean;
		
		/**
		 * Stores information about the recent user input, this Array is used temporary for each questionpage.
		 */
		public var answers:Array = new Array();
		
		/**
		 * Stores the summary of all answers arrays (all answers of all questionpages)
		 */
		public var allAnswers:Array = new Array();
		
		/**
		 * stores references to all the question related instances to ensure removing
		 */
		public var references:Array = new Array();
		
		/**
		 * The state of the module.
		 */
		protected var moduleState:Number = 0;
		
		/**
		 * This States affects only internal processes --> next page / previous page
		 */
		protected var qpState:Number =0;					//state of pages
		
		/**
		 * managing listeners (for parent object)
		 */
		protected var _listeners:Object = {};
		
		/**
		 * relative url path for loading data
		 */
		protected var relUrl:String;
		
		protected var scriptUrl:String;
		
		
		protected var _current_item_id:String;
		
		public function set current_item_id(value:String):void
		{
			_current_item_id = value;
		}
		
		/**
		 * Constructor of each questions object contains a xmlList source (of questions) and the relative url path for loading data. Also initializes the view component.
		 * 
		 * 
		 * @param _source the source xmllist containing the item data, defined in each item xml document
		 * 
		 * @param scripturl the realtive url the php script which is required to load and store data
		 * 
		 * @relativeUrl alias for rooturl (depreaced)
		 */
		public function QuestionsObject()
		{
			qView = new QuestionView();
			
		}
		
		//-------------------------------------------------//
		// 			INIT Links and LOAD
		//-------------------------------------------------//
		
		public function init(_source:XMLList,scripturl:String, relativeUrl:String):void
		{
			scriptUrl = scripturl;
			relUrl = relativeUrl;
			source = _source;
		}
		
		/**
		 * Call this function after event listeners have been set. Final function, no changes in children objects allowed.
		 */
		final public function load():void
		{
			displayQuestions(this.qpState);
			trace("dispatch load complete");
			dispatchEvent(new Event(LOAD_COMPLETE));
			trace("dispatch load complete finsihed");
		}
		
		//-------------------------------------------------//
		// 			Visual Setup
		//-------------------------------------------------//
		
		
		public function getView():QuestionView
		{
			return qView;
		}
		
		
		public function display_q_text(param:Number):Group
		{
			trace("[QuestionsObject]: check for q_text");
			//init pulse list
			PulseList.setDebug(true);
			PulseList.flush();
			//get qtext element
			
			var qText:XMLList = source.questionpage[param].q_text;
			if( qText == null || qText.length()==0)
			{
				return new Group();	//fallback => return empty group
			}
			
			trace("[QuestionsObject]: q_text element found, check for sound file");
			//layout the wrapper group
			var hgr:HGroup = new HGroup();
				hgr.horizontalAlign="left";
				hgr.verticalAlign="middle";
				hgr.percentWidth = 100;
			//does it have mp3 linked?
			trace("sound name: "+qText.@sound);
			if(!ignoreSound && qText.@sound.length()>0)
			{
				trace("[QuestionsObject]: sound exists. fetching data...");
				var q_sound:SmallSoundButton = ComponentsFactory.createSmallSoundButton(this.scriptUrl,relUrl + qText.@sound,"q_text_sound","q_text_sound_button",null) as SmallSoundButton;
				references.push(q_sound);
				hgr.addElement(q_sound);
				PulseList.addToList(q_sound);
			}else{
				trace("[QuestionsObject]: sound does not exists. replace button with placeholder");
				var rb:SmallEyeButton = ComponentsFactory.createSmallEyeButton("q_text_eye_butotn",null) as SmallEyeButton;
				references.push(rb);
				hgr.addElement(rb);
				PulseList.addToList(rb);
			}
			if( qText.length()>0 && String(qText.children()).length>0 )
			{
				//----------------------------// Line
				var ln:Line = ComponentsFactory.createLine(0,0,2,0.2,0x000000,0,100);
				hgr.addElement(ln);
				
				
				
				var _insLbl:Label = ComponentsFactory.createLabe(qText.toString(),"q_text_label",qText.@style.length>0?qText.@style:Globals.TEXT_STANDARD,100);
				hgr.addElement(_insLbl);
				references.push(_insLbl);	
			}


			
			trace("[QuestionsObject]: q_text complete");
			return hgr;
		}

		public function display_answer_text(task:XMLList,i:uint):Group
		{
			var atext:String=task[i].answertext.children().toString();
			if( atext.length==0)
			{
				return null;
			}
			
			trace("[QuestionsObject]: answertext found, generate group");
			var answerGroup:HGroup = new HGroup();
				answerGroup.horizontalAlign="left";
				answerGroup.verticalAlign="middle";
				answerGroup.percentWidth = 100;
				answerGroup.addEventListener(FlexEvent.UPDATE_COMPLETE, onGroupComponentUpdate);	
			
			if(!ignoreSound && task[i].answertext.a_text.@sound.length()>0)
			{
				var asbtn:SmallSoundButton = ComponentsFactory.createSmallSoundButton(scriptUrl,relUrl + task[i].answertext.a_text.@sound, "ansertext_sound","answertext_sound_button",null) as SmallSoundButton;

				references.push(asbtn);
				answerGroup.addElement(asbtn);
				PulseList.addToList(asbtn);
			}else{
				var read:SmallEyeButton = ComponentsFactory.createSmallEyeButton("answertext_eye_button",null) as SmallEyeButton;
				references.push(read);
				answerGroup.addElement(read);
				PulseList.addToList(read);
			}
			
			//----------------------------// Line
			var li:Line = ComponentsFactory.createLine(0,0,2,0.2,0x000000,0,100);
			answerGroup.addElement(li);
			//---------------------------------// ANSWERTEXT
			var answLbl:Label = ComponentsFactory.createLabe( task[i].answertext.a_text.toString(),"answertext_label",task[i].@style.length>0?task[i].@style:Globals.TEXT_STANDARD,100);
			references.push(answLbl);
			answerGroup.addElement(answLbl);
			trace("[QuestionsObject]: answertext complete.");
			return answerGroup;
		}
		
		/**
		 * This function is the main process for displaying the content. It will vary for each Questionsobject, so it need to be overridden.
		 */
		public function displayQuestions(param:Number):void
		{
			//override this Function in each item format	
		}
	
		
		private var backbutton_initialized:Boolean;
		private var forwardbtn_initialized:Boolean;
		
		public function display_navigation_buttons(param:Number):void
		{
			if(!backbutton_initialized)								//create a "go back" button only if the actual questionpage is NOT the first page
			{
					qView.backbutton.label = "Zurück";	//change to multilang
					qView.backbutton.addEventListener(MouseEvent.CLICK,prevQpage);
					backbutton_initialized = true;
			}
			
			qView.backbutton.visible = param > 0 ? true : false;

		//	qView.currentitem.text = "Aufgabe:"+_current_item_id;

			
			if(!forwardbtn_initialized)
			{
				qView.forwardbutton.addEventListener(MouseEvent.CLICK,nextQpage);
				qView.forwardbutton.label = "Weiter"; //make multilang
				
				forwardbtn_initialized = true;
			}

			PulseList.addToList(qView.forwardbutton);
			PulseList.init();
			PulseList.start();


		}
		
		//-------------------------------------------------//
		// 			INIT Links
		//-------------------------------------------------//
		
		
		public function unload():void
		{
			//override in children
			throw new Error("unoverridden method in abstract class");
		}
			
		
		//-------------------------------------------------//
		// 			Results and Synchronization
		//-------------------------------------------------//
		
		
		public function getResults():Array
		{
			return allAnswers;
		}
		
		/**
		 * This method initially loops the references Array and checks if the reference has listeners or is a specific object.
		 * Listeners will be removed, Objects will be set to null.
		 * 
		 * @see references
		 */
		protected function removeQuestions():void
		{
			trace("[QuestionsObject]: remove content");
			for(var i:uint=0;i<references.length;i++)
			{
				if(references[i] is ICustomEventDispatcher)
				{
					references[i].removeAllEventListeners();
				}
				references[i] = null;
			}
			references = null;			//remove array
			references = new Array();	//and recreate
		}
		
		
		/**
		 * iterates the answer array to check if an anser was already given to a specific field. This allows a reload of a previous page with pre-existing answer settings.
		 */
		protected function answerExists(id:String):Boolean
		{
			//first check if empty or null
			if(allAnswers.length==0 || allAnswers==null)
			{
				return false;
			}
			for(var i:uint=0;i<allAnswers.length;i++)
			{
				if(allAnswers[i][0]==id)
				{
					return true;
				}
			}
			return false;
		}
		
		/**
		 * checks, if a value in the answer array was already given by comparing the ids.
		 */
		protected function getAnswerValue(id:String):Boolean
		{
			for(var i:uint=0;i<allAnswers.length;i++)
			{
				if(allAnswers[i][0]==id)
				{
					return allAnswers[i][1];
				}
			}
			return false;
		}
		
		/**
		 * returns the answervalue, if value is a string
		 */
		protected function getAnswerString(id:String):String
		{
			for(var i:uint=0;i<allAnswers.length;i++)
			{
				if(allAnswers[i][0]==id)
				{
					return allAnswers[i][1];
				}
			}
			return "";
		}
		
		/**
		 * This method is like an undo function. Important to know: allAnswers.pop() will delete the input on the previous 
		 * questionpage and substitude it with the new input.
		 * The clear screen behavior is not defined here but rather the change of the qpState.
		 * 
		 * @see qpState
		 */
		protected function prevQpage(event:MouseEvent):void
		{
			utils.ReaVisualUtils.fadeOutSound();
			trace("[QuestionsObject]:  prevpage");
			//var _bbtn:BackButton = event.currentTarget as BackButton;
			//_bbtn.removeEventListener(MouseEvent.CLICK, prevQpage);
			trace("[QuestionsObject]: allanswers length:  "+allAnswers.length);
			synchronize();
			this._qpState-=1;
		}
		
		/**
		 * This Method loops the reference array, searching for the Radiobutton Reference and get its ID and selection status.
		 * These information represents the user input and is fundamental for evaluation.
		 * Evaluation is always done in <code>ItemObject</code>.
		 * The clear screen behavior is not defined here but rather the change of the qpState.
		 * 
		 * @see qpState
		 * @see ItemApplication.ItemObject
		 */
		protected function nextQpage(event:MouseEvent):void
		{
			utils.ReaVisualUtils.fadeOutSound();
			trace("[QuestionsObject]:  nextpage");
			//var _bbtn:ForwardButton = event.currentTarget as ForwardButton;
			//_bbtn.removeEventListener(MouseEvent.CLICK, nextQpage);
			trace("[QuestionsObject]: allanswers length:  "+allAnswers.length);
			synchronize();
			this._qpState+=1;
		}
		
		/**
		 * This function is required to synchronize the answer arrays with the new answers every time a questionpage has been built.
		 */
		protected function synchronize():void
		{
			trace("SYNCHRONIZING ANSWER-IDS");
			for(var i:uint=0;i<references.length;i++)
			{
				var ref:Object = references[i];
				//------------------------------------// ICUSTOMSELECTABLE
				if(ref is ISelectable)
				{
					var found_ics:Boolean=false;
					for(var j:uint=0;j<allAnswers.length;j++)
					{	
						if(ref.id == allAnswers[j][0])
						{
							trace("found and overwritten: "+allAnswers[j][0]+" with "+ref.selected);
							allAnswers[j][1] = ref.selected==true?1:0;
							found_ics=true;
						}
					}
					if(!found_ics)
					{
						var answerBuffer:Array = new Array(2)
						answerBuffer[0] = ref.id;
						answerBuffer[1] = ref.selected==true?1:0;
						allAnswers.push(answerBuffer);
						trace("not found and added: allAnswers["+j+"] with "+ref.selected);
					}
				}
				//------------------------------------// ICUSTOMWRITABLE
				if(ref is IWritable)
				{
					var found_icw:Boolean=false;
					for(var k:uint=0;k<allAnswers.length;k++)
					{	
						if(ref.id == allAnswers[k][0])
						{
							trace("found and overwritten: "+allAnswers[k][0]+" with "+ref.text);
							allAnswers[k][1] = ref.text;
							found_icw=true;
						}
					}
					if(!found_icw)
					{
						var _answerBuffer:Array = new Array(2)
						_answerBuffer[0] = ref.id;
						_answerBuffer[1] = ref.text;
						allAnswers.push(_answerBuffer);
						trace("not found and added: allAnswers["+j+"] with "+ref.text);
					}
				}
			}
		}
		
		
		//----------------------------------------------------//
		//Event Related
		//----------------------------------------------------//		
		
		
		protected function onGroupComponentUpdate(event:FlexEvent):void
		{
			trace("ANSWERGROUP UPDATED");
			var g:Group = event.currentTarget as Group;
				g.removeEventListener(FlexEvent.UPDATE_COMPLETE, onGroupComponentUpdate);
			//ReaVisualUtils.dynamicLineResize_vertical(g, true);
			//Shared.ReaVisualUtils.recursive_line_resize(g,g.height,false);
		}
		
		/**
		 * Set the current questionpage state.
		 */
		public function set _qpState(newState:Number):void
		{
			trace("[QuestionsObject]:  page changed");
			qpState = newState;
			dispatchEvent(new ItemEvent(ItemEvent.PAGE_CHANGED));
			//this.qView.buttonArea.removeAllElements();
			this.qView.content.removeAllElements();
			removeQuestions();
			if(qpState<this.source.questionpage.length())
			{
				displayQuestions(qpState);
			}else{
				this._moduleState = 2;
			}
			
		}
		
		/**
		 * Get the current questionspage state.
		 */
		public function get _qpState():Number
		{
			return qpState;
		}
		
		
		/**
		 * Set the current module state. Important for finishing the questions and evaluate the answers in the parent object.
		 */
		public function set _moduleState(newState:Number):void
		{
			trace("[QuestionsObject]:  modulestate changed");
			moduleState = newState;
			switch(moduleState)
			{
				case(1):
					dispatchEvent(new ItemEvent(ItemEvent.QPAGE_LOADED));
					break;
				case(2):
					trace("[QuestionsObject]:  qpage finsihed event fired!");
					for(var i:uint=0;i<references.length;i++)
					{
						var x:Class = references[i];
						x=null;
					}
					this.qView.removeAllElements();
					this.qView = null;
					dispatchEvent(new ItemEvent(ItemEvent.QPAGE_FINISHED,false,false,allAnswers));
					break;
			}
		}
		

		
		public function firstPulse():void
		{
			PulseList.init(0);
			PulseList.start();
		}
		
		//--------------------------------------------// Sound and Debug
		
		private var _debug:Boolean=false;
		
		private var _ignoreSound:Boolean=false;
		
		public function get debug():Boolean
		{
			return _debug;
		}
		
		public function get ignoreSound():Boolean
		{
			return _ignoreSound;
		}
		
		
		public function set debug(value:Boolean):void
		{
			_debug = value;
		}
		
		
		public function set ignoreSound(value:Boolean):void
		{
			_ignoreSound = value;	
		}
		//---------// OLD
		
		public function get _moduleState():Number
		{
			return moduleState;
		}
		
		
		public function returnAnswerList():Array
		{
			return allAnswers;
		}
		
		
		public function set track(value:Boolean):void
		{
			_track = value;
		}
		
		public function get track():Boolean
		{
			return _track;
		}
		
		/**
		 * Because this Class is extending <code>Shared.EventDispatcher</code>, we can check if the listeners array is filled with
		 * at least one reference to a listener object. This may be required to check if an object's listener is removable.
		 */
		public function hasAtLeastOneListener():Boolean
		{
			if(_listeners is Array && _listeners.length != 0)
			{
				return true;
			}
			return false;
		}
		
		
		
		
	}
}