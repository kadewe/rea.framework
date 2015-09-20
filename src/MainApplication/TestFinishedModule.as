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
	import components.factories.DisplayFactory;
	
	import events.CustomModuleEvents;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;
	
	import models.Globals;
	import models.Session;
	import models.TestCollection;
	
	import mx.events.FlexEvent;
	
	import spark.components.Group;
	
	import utils.MP3Audio;
	import utils.ReaVisualUtils;
	
	import views.EvaluationView;
	import views.TestFinishedView;

	/**
	 * After finishing a test, this Class is loaded to provide functions for printing the evaluation and choosing the further activities.
	 * 
	 */
	public class TestFinishedModule extends AbstractModule
	{
		private var view:TestFinishedView;
		
		//-------------------------------------- 
		// states events and references
		//--------------------------------------
		
		
		private var labels:Array;
		private var _urls:Array;
		

		private var buttonSoundUrl:String;
		private var labelSoundUrl:String;
		private var redirect:String;
		/**
		 * empty constructor
		 */
		public function TestFinishedModule()
		{
			//empty
		}
		
		//--------------------------------------// 
		// Module Loading
		//--------------------------------------//
		
		private var _dimension:int;
		private var _level:int;
		
		private var _feedback_url:String;
		
		private var _user_name:String;
		
		override public function load(_globals:Globals,_tcollection:TestCollection,_session:Session):void
		{
			trace("[testfinished]: load");
			view = new TestFinishedView();
			view.addEventListener(TestFinishedView.FINISHED,onNewTest);
			view.addEventListener(FlexEvent.STATE_CHANGE_COMPLETE, onStateChangeComplete);
			references.addItem(view);
			
			labels=_globals.labels;
			_urls = _globals.paths;
			_dimension = _session.dimension;
			_level = _session.level;
			_user_name = _session.user.userName;

			for(var i:uint=0;i<_urls.length;i++)
			{
				if(_urls[i][0]==Globals.ROOTURL)
				{
					rootUrl = _urls[i][1];
				}
				if(_urls[i][0]==Globals.SCRIPTURL)
				{
					scriptUrl = rootUrl + _urls[i][1];
				}
				if(_urls[i][0]==Globals.SOUND_PATH)
				{
					soundUrl = _urls[i][1];
				}
				if(_urls[i][0]==Globals.END_APP_REDICECT)
				{
					redirect = _urls[i][1];		
				}
				
				if(_urls[i][0] == Globals.FEEDBACKSOUND_PATH)
				{
					_feedback_url = _urls[i][1];	
				}
				
	
			}
			helpVideos = _globals.videos;
			dispatchEvent(new CustomModuleEvents(CustomModuleEvents.MODULE_LOAD_COMPLETE));
		}
		
			/*
				<s:State name="result_page"/>
				<s:State name="choose_next_acitivity"/>
				<s:State name="save_print_resutls"/>
			*/
		protected function onStateChangeComplete(event:FlexEvent):void
		{
			utils.ReaVisualUtils.fadeOutSound();
			utils.ReaVisualUtils.stopPulse();
			
			switch(view.currentState)
			{
				case "result_page":
					if(!_result_init)
					{
						initFinishedState();
						_result_init=true;
					}
					break;
				case "choose_next_acitivity":
					if(!_next_init)
					{
						initChooseActivityState();
						_next_init=true;
					}
					break;
				case "save_print_resutls":
					if(!_save_print_init)
					{
						initPrintSaveSate();
						_save_print_init=true;
					}
					break;
			}
		}		
		
		
		private var _result_init:Boolean;
		private var _save_print_init:Boolean;
		private var _next_init:Boolean;
		
		override public function returnView():Group
		{
			return this.view;	
		}
		
		override public function sendTweenFinished():void
		{
			//	
		}
		
		
		override public function unload():void
		{
			this.view.removeAllElements();
			this.view = null;
			
			super.unload();
		}
		
		
		

		
		
	
		
		override public function returnCurrentState():String
		{
			return view.currentState;
		}
		
		
		
		private var _current_dimension_name:String;
		private function initFinishedState():void
		{
			switch(_dimension)
			{
				case 0:
				{
					//view.dimension_button.styleName = "readingButton";
					
					_current_dimension_name="lesen";
					break;
				}
				case 1:
				{
					//view.dimension_button.styleName = "writingButton";
					_current_dimension_name="schreiben";
					break;
				}
				case 2:
				{
					//view.dimension_button.styleName = "mathButton";
					_current_dimension_name="rechnen";
					break;
				}
				case 3:
				{
					//view.dimension_button.styleName = "languageButton";
					_current_dimension_name="sprache";
					break;
				}
				default:
				{
					//view.dimension_button.visible=false;
					break;
				}
			}
			//view.dimension_button.visible = view.dimension_button.includeInLayout=false;
			
			//--------------------------------------------// LABELS
			for(var i:uint=0;i<labels.length;i++)
			{
				
					
				//--------------------------------------------//CONGRAT INFO + sound
				if(view.congrats.id==labels[i][0])
				{
					view.congrats.text = labels[i][1];
					if(!playSound)
					{
						var _m:MP3Audio = new MP3Audio(scriptUrl,soundUrl + labels[i][2]);
						view.congratsSound.referringTo = _m;
						view.congratsSound.addEventListener(MouseEvent.CLICK, _m.playAudio);
					}
				}
				/*
				
				//--------------------------------------------// I can do label
				if(labels[i][0]==view.candoLabel.id)
				{
					view.candoLabel.text = labels[i][1];
					if(!playSound)
					{
						var candoSnd:MP3Audio = new MP3Audio(scriptUrl,soundUrl + labels[i][2]);
						view.candoSound.referringTo = candoSnd;
						view.candoSound.addEventListener(MouseEvent.CLICK, candoSnd.playAudio);
					}
				}
				
				
				//--------------------------------------------// next level
				var nextlevl:String = view.nextLevelLabel.id+String(_level);
				
				if(labels[i][0]==nextlevl)
				{
					view.nextLevelLabel.text = labels[i][1];
					if(!playSound)
					{
						var nlvlsnd:MP3Audio = new MP3Audio(scriptUrl,soundUrl + labels[i][2]);
							view.nextLevelSound.referringTo = nlvlsnd;
							view.nextLevelSound.addEventListener(MouseEvent.CLICK, nlvlsnd.playAudio);
					}
				}
				
				//--------------------------------------------// what to improve
				if(labels[i][0]==view.improveLabel.id)
				{
					view.improveLabel.text = labels[i][1];
					if(!playSound)
					{
						var imprSnd:MP3Audio = new MP3Audio(scriptUrl,soundUrl + labels[i][2]);
						view.improveSound.referringTo = imprSnd;
						view.improveSound.addEventListener(MouseEvent.CLICK, imprSnd.playAudio);
					}
				}*/
				
				//--------------------------------------------// FORWARD BUTTON
				if(labels[i][0]==view.forwardButton.id)
				{
					view.forwardButton.label = labels[i][1];
					if(!playSound)
					{
						var fwdSound:MP3Audio = new MP3Audio(scriptUrl,soundUrl + labels[i][2]);
						view.forwardButton.referringTo = fwdSound;
						view.forwardButton.addEventListener(MouseEvent.MOUSE_OVER, fwdSound.playAudio);

					}
				}
				
			}
			
			
			//view.next_level_wrapper.visible = view.next_level_wrapper.includeInLayout= false;	//make invisible
		
			var eval_group:EvaluationView =DisplayFactory.evaluationDisplay(_user_name, _current_dimension_name,scriptUrl,100); 
				eval_group.addEventListener(EvaluationView.REPORT_GENERATION_FAULT, showForward);
				eval_group.addEventListener(EvaluationView.REPORT_GENERATION_COMPLETE, showForward);
			view.result_group.addElement(eval_group);
			
			view.forwardButton.visible=false;
		}
		
		protected var _result:XML;
		
		protected function showForward(event:Event):void
		{
			trace("SHOW FORWARD");
			view.forwardButton.visible=true;
			
			_result = EvaluationView(event.currentTarget).result;
		}		
		
		private function initPrintSaveSate():void
		{

			//--------------------------------------------// LABELS
			for(var i:uint=0;i<labels.length;i++)
			{
/*				
				//--------------------------------------------// PRINT INFO + SOUND
				if(view.youCanPrint.id==labels[i][0])
				{
					view.youCanPrint.text = labels[i][1];
					view.youCanPrint.addEventListener(MouseEvent.CLICK, printResults);
					if(!soundMode)
					{
						var m:MP3Audio = new MP3Audio(scriptUrl, soundUrl + labels[i][2]);
						view.printSound.referringTo = m;
						view.printSound.addEventListener(MouseEvent.CLICK, playAudio);
					}
				}*/
				//--------------------------------------------//Save INFO + sound
				if(view.youCanSave.id==labels[i][0])
				{
					view.youCanSave.text = labels[i][1];
					if(!playSound)
					{
						var snd:MP3Audio = new MP3Audio(scriptUrl, soundUrl + labels[i][2]);
						view.saveSound.referringTo = snd;
						view.saveSound.addEventListener(MouseEvent.CLICK, snd.playAudio);
					}
				}

				//--------------------------------------------// BACK BUTTON
				if(labels[i][0]==view.backButton.id)
				{
					view.backButton.label = labels[i][1];
					if(!playSound)
					{
						var bckSound:MP3Audio = new MP3Audio(scriptUrl,soundUrl + labels[i][2]);
						view.backButton.referringTo = bckSound;
						view.backButton.addEventListener(MouseEvent.MOUSE_OVER, bckSound.playAudio);
					}
				}
				
			}
			//interactive Events
			view.saveIcon.addEventListener(MouseEvent.CLICK, onSaveAction);
			
			

			/*
			view.printIcon.addEventListener(MouseEvent.CLICK, onPrintAction);
			view.printIcon.addEventListener(MouseEvent.MOUSE_OVER, onIconOver);
			view.printIcon.addEventListener(MouseEvent.MOUSE_OUT, onIconOut);*/
			
		}
		
		
		private function initChooseActivityState():void
		{

			trace(view.currentState);
			for(var i:uint=0;i<labels.length;i++)
			{
				if(view.whatNext.id==labels[i][0])
				{
					view.whatNext.text = labels[i][1];
					if(!playSound)
					{
						var nextSound:MP3Audio = new MP3Audio(scriptUrl,soundUrl + labels[i][2]);
						view.whatNextSound.referringTo = nextSound;
						view.whatNextSound.addEventListener(MouseEvent.CLICK, nextSound.playAudio);
						utils.ReaVisualUtils.pulseFocus(view.whatNextSound);
					}
				}
				if(view.newTestButton.id==labels[i][0])
				{
					view.newTestButton.label = labels[i][1];
					if(!playSound)
					{
						var newTestSound:MP3Audio = new MP3Audio(scriptUrl,soundUrl + labels[i][2]);
						view.newTestButton.referringTo = newTestSound;
						view.newTestButton.addEventListener(MouseEvent.MOUSE_OVER, newTestSound.playAudio);
					}
				}
				if(view.mainAppEndButton.id==labels[i][0])
				{
					view.mainAppEndButton.label = labels[i][1];
					if(!playSound)
					{
						var appEndSound:MP3Audio = new MP3Audio(scriptUrl,soundUrl + labels[i][2]);
						view.mainAppEndButton.referringTo = appEndSound;
						view.mainAppEndButton.addEventListener(MouseEvent.MOUSE_OVER, appEndSound.playAudio);
					}
				}

			}
			
			
			
			view.mainAppEndButton.addEventListener(MouseEvent.CLICK, onAppEnd);
		}
		
		

		private function onNewTest(event:Event):void
		{
			utils.ReaVisualUtils.fadeOutSound();
			dispatchEvent(new CustomModuleEvents(CustomModuleEvents.MODULE_FINISHED,false,false,null,null,null,-1,-1,false));
		}
		


		private function onAppEnd(event:MouseEvent):void
		{
			var req:URLRequest = new URLRequest(redirect);
			navigateToURL(req,"_self");
		}
		
		
	
		override public function getClassName():String
		{
			return "TestFinishedModule";
		}
		

		private function onSaveAction(event:MouseEvent):void
		{
			var download_target:String = _result..print.@file;
			trace("SAVE:::"+_user_name+"/"+download_target);
			if(download_target.length>0)
			{
				var v:URLVariables = new URLVariables();
					v.param = "download";
					v.type  = "application/pdf";
					v.file  = download_target;
					v.display= "attachment";
					v.user	= _user_name;
				var req:URLRequest = new URLRequest(scriptUrl);
					req.data = v;
					req.method= URLRequestMethod.POST;
					navigateToURL(req,"_blank");
			}
			
		}
		


		
		
		
		

		

		
		
		
		private function cleanScreen():void
		{
			view.setCurrentState("choose_next_acitivity");
			view.backButton.visible=false;
		}

		
		

	}
}