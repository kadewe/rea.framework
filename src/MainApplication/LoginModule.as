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

	import events.CustomModuleEvents;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import models.Globals;
	import models.Session;
	import models.TestCollection;
	
	import mx.events.FlexEvent;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	import spark.components.Group;
	
	import trackers.InputTracker;
	import trackers.TrackingTypes;
	
	import utils.ExtendedTweener;
	import utils.ReaVisualUtils;
	
	import views.GUILoader;
	import views.LogInView;

	/**
	 * Represents a login form handler. User input will be sent to the server, server evaluates and answers with a value. The value influences the state of the handler and
	 * either a login is performed or fault or a new user code is requestet.
	 */
	public class LoginModule extends AbstractModule
	{
		
		//--------------------------------------
		//	Services
		//--------------------------------------
		
		/**
		 * @private
		 */
		private var user_login:HTTPService;
		
		/**
		 * @private
		 */
		private var user_newCode:HTTPService;
				
		
		//--------------------------------------
		//	Model and Data
		//--------------------------------------		
		
		public var view:LogInView;
		
		/**
		 * @private
		 */
		private var labelList:Array;
		
		/**
		 * @private
		 */
		private var newUserString:String="";
		
		/**
		 * @private
		 */
		private var userDataUrl:String = "";
		
		/**
		 * @private
		 */
		private var userDataXml:XML;


		

		
		//--------------------------------------
		//	States and Events
		//--------------------------------------

		
		/**
		 * @private
		 */
		private var loginState:Number=0;
		
		/**
		 * @private
		 */
		private var mousePosX:Number;
		
		/**
		 * @private
		 */
		private var mousePosY:Number;
		
		//--------------------------------------
		//	Event Constants
		//--------------------------------------
		
		/**
		 * Dispatched when the login has been granted
		 */
		public static const LOGIN_SUCCESS:String ="loginSuccess";
		
		/**
		 * Dispatched if login has been denied
		 */
		public static const LOGIN_FAULT:String = "logInFault";
		
		/**
		 * Disptached if any error (e.g. IOError or SecurityError) occured
		 */
		public static const REQUEST_ERROR:String = "requestError";
		
		/**
		 * Dispatched when user related datafile has been loaded
		 */
		public static const USERDATA_RECEIVED:String = "userDataReceived";

		
		
		
		//--------------------------------------////--------------------------------------//
		//
		// 									CONSTRCUTOR
		//
		//--------------------------------------////--------------------------------------// 
		
		
		
		/**
		 * constructor. No variables will be pased. Initializes view component.
		 */
		public function LoginModule()
		{
			view = new LogInView();
			view.addEventListener(FlexEvent.CREATION_COMPLETE, onViewCreation);
			view.addEventListener(LogInView.CODE_REQUEST, requestNewUser);
			references.addItem(view);
		}

		
		
		//--------------------------------------////--------------------------------------//
		//
		// 									OVERRIDES
		//
		//--------------------------------------////--------------------------------------// 
		
		/**
		 * @inheritDoc
		 */
		override public function getClassName():String
		{
			return "LoginModule";
		}
		


		public function get _loginState():Number
		{
			return _loginState;
		}

		
		/**
		 * @inheritDoc
		 */
		override public function returnView():Group
		{
			return this.view;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function unload():void
		{
			this.view.removeAllElements();
			this.view = null;
			
			super.unload();
		}
		
		/**
		 * not required in this class
		 */
		override public function sendTweenFinished():void
		{
			//empty in this class
		}
		
		/**
		 * @inheritDoc
		 */
		override public function returnCurrentState():String
		{
			return view.currentState;
		}
			
		
		/**
		 * @inheritDoc
		 */
		override public function load(_globals:Globals,_tcollection:TestCollection,_session:Session):void
		{
			var _labels:Array = _globals.labels;
			var _urls:Array = _globals.paths;
			this.labelList=_labels;
			
			var root:String;
			for(var i:int=0;i<_urls.length;i++)
			{
				if(_urls[i][0]==Globals.ROOTURL)
				{
					root = _urls[i][1];
				}
				if(_urls[i][0]==Globals.SCRIPTURL)
				{
					scriptUrl = root + _urls[i][1];
				}
				if(_urls[i][0]==Globals.SOUND_PATH)
				{
					soundUrl = _urls[i][1];
				}
				
			}
			
			this.helpVideos = _globals.videos;
			
			user_login = new HTTPService();
			user_login.url = this.scriptUrl;
			user_login.useProxy = false;
			user_login.method = "POST";
			user_login.addEventListener(ResultEvent.RESULT, onResult);
			user_login.addEventListener(FaultEvent.FAULT, onFault);
			
			_guiloader = new GUILoader(_globals);	
			
			dispatchEvent(new CustomModuleEvents(CustomModuleEvents.MODULE_LOAD_COMPLETE));
		}
		
		


		//--------------------------------------// SETUP LABELS AND SOUNDS //--------------------------------------//
		
		/**
		 * @private
		 */
		private function onViewCreation(event:FlexEvent):void
		{		
			_guiloader.initGUI( view );
			view.setcurrentStateIsInitialized( true );
			view.addEventListener(LogInView.CODE_SEND, send);
			view.addEventListener(FlexEvent.STATE_CHANGE_COMPLETE, onStateChanged);
		}
		
		/**
		 * @private
		 */
		protected function onStateChanged(event:FlexEvent):void
		{
			utils.ReaVisualUtils.fadeOutSound();
			utils.ReaVisualUtils.stopPulse();
			
			if(!view.getcurrentStateIsInitialized())
			{
				_guiloader.initGUI( view );
				view.setcurrentStateIsInitialized( true );
			}
			switch(view.currentState)
			{
				case("login"):
					view.cleanupLogin();
					view.input.setFocus();
					break;
				case("register"):
					view.cleanupLogin()
					view.input.setFocus();
					break;
			}
		}
		
		
		
		//--------------------------------------////--------------------------------------//
		//
		//
		// 									LOGIN SYSTEM	
		//
		//
		//--------------------------------------////--------------------------------------// 
		
		
		/**
		 * @private
		 */
		private function send(event:Event):void
		{
			utils.ReaVisualUtils.fadeOutSound();
			utils.ReaVisualUtils.stopPulse();

			try
			{
				var finalIn:String = view.getLoginCode();
				finalIn = finalIn.toUpperCase();
				trace(finalIn);
				var a:Object = {
					param:'login',
					password:finalIn};
				user_login.request = a;
				user_login.send();
				
				
			}catch(e:Error){
				//ErrorDispatcher.processNewError(e.id, e.message, e.errorID, event.target,"",scriptUrl);
			}
		}
		



		//--------------------------------------// RESULT BEHAVIOR //--------------------------------------//
		
		/**
		 * @private
		 */
		private function onResult(event:ResultEvent):void
		{
			//Shared.StaticFunctions.stopPulse();
			trace("[loginobject]: login - http result received");
			if(event.result.loginsuccess=="yes")
			{
				userDataUrl = event.result.userDataUrl;
				trace("[loginobject]: login success => USERDATA:");
				trace("[loginobject]: "+event.result.loginsuccess);
				trace("[loginobject]: "+event.result.sqlresult);
				trace("[loginobject]: "+event.result.xml);
				trace("[loginobject]: "+event.result.path);
				if(track)
				{
					try
					{
						InputTracker.logEvent(view.currentState,view.stage.mouseX,view.stage.mouseY,TrackingTypes.LOGIN_SUCCESS,event.result.userDataUrl);	
					} 
					catch(error:Error) 
					{
						
					}
				}
					
				dispatchEvent(new CustomModuleEvents(CustomModuleEvents.MODULE_FINISHED,false,false,userDataUrl,null,null));
			}else{
				trace("[loginobject]: login fault");
				if(track)
				{
					try
					{
						InputTracker.logEvent(view.currentState,view.stage.mouseX,view.stage.mouseY,TrackingTypes.LOGIN_FAULT,null);	
					} 
					catch(error:Error) 
					{
						
					}	
				}
				
				view.retrylabel.visible=true;
				
				view.retryInput.alpha=0;
				view.retryInput.visible=true;
				ExtendedTweener.tween(view.retryInput,1.0,{alpha:1});
				
				view.cleanupLogin();
				view.input.setFocus();				
			}
		}
		
		

		/**
		 * @private
		 */
		private function onFault(event:FaultEvent):void
		{
			//view.currentState="fault";
		}

		
		/**
		 * @private
		 */
		private function requestNewUser(event:Event):void
		{
			trace("[LoginModule]: Request New user =>"+ scriptUrl);
				
			utils.ReaVisualUtils.fadeOutSound();
			utils.ReaVisualUtils.stopPulse();
			
			user_newCode = new HTTPService();
			user_newCode.url = this.scriptUrl;
			user_newCode.useProxy = false;
			user_newCode.method = "POST";
	
			var a:Object = {param:'newuser'};
			
			user_newCode.request = a;
			user_newCode.addEventListener(ResultEvent.RESULT, onNewUserResult);
			user_newCode.addEventListener(FaultEvent.FAULT, onNewUserFault);
			user_newCode.send();
		}
		
		
		/**
		 * @private
		 */
		private function onNewUserResult(event:ResultEvent):void
		{
			if(view.currentState!="register")view.setCurrentState("register");

			view.retryInput.visible = false;
			
			
			trace("[loginobject]: request result= "+event.result);
			
			newUserString = event.result.userDataUrl;
			
			user_login.removeEventListener(ResultEvent.RESULT,onNewUserResult);
			view.login_newCode.text = newUserString;
		}
		
		
		private function onNewUserFault(event:FaultEvent):void
		{
			trace("[LoginModule]: login fault");
			view.currentState="fault";
		}
		
		/**
		 * @private
		 */
		public function set _userDataUrl(newString:String):void
		{
			trace("[loginobject]: userDataUrl:   " + newString);
			userDataUrl = newString;
			dispatchEvent(new CustomModuleEvents(CustomModuleEvents.MODULE_FINISHED,false,false,userDataUrl,null,null));
		}
		
		/**
		 * @private
		 */
		public function get _userDataUrl():String
		{
			return _userDataUrl;
		}
		
	}
}