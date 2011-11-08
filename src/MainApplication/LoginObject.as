package MainApplication
{

	import DisplayApplication.LogInView;
	
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
	
	import enumTypes.ErrorTypeEnum;
	import enumTypes.UrlTypeEnum;
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import mx.controls.Alert;
	import mx.events.FlexEvent;
	import mx.managers.CursorManager;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	import spark.components.Button;

	/**
	 * Represents a login form handler. User input will be sent to the server, server evaluates and answers with a value. The value influences the state of the handler and
	 * either a login is performed or fault or a new user code is requestet.
	 */
	public class LoginObject extends Shared.EventDispatcher implements ICustomModule,ICustomEventDispatcher
	{
		
		//--------------------------------------
		//	Services
		//--------------------------------------
		private var user_login:HTTPService;		
		private var user_newCode:HTTPService;
				
		
		//--------------------------------------
		//	Model and Data
		//--------------------------------------		
		public var view:LogInView;
		private var labelList:Array;		
		private var newUserString:String="";
		private var userDataUrl:String = "";		
		private var userDataXml:XML;
		

		

		
		//--------------------------------------
		//	States and Events
		//--------------------------------------
		private var references:Array=new Array();
		private var _listeners:Object = {};		
		protected var loginState:Number=0;
		
		//--------------------------------------
		//	Event Constants
		//--------------------------------------
		public static const LOGIN_SUCCESS:String ="loginSuccess";
		public static const LOGIN_FAULT:String = "logInFault";
		public static const REQUEST_ERROR:String = "requestError";
		public static const USERDATA_RECEIVED:String = "userDataReceived";
		public static const LOAD_COMPLETE:String = "loadComplete";
		
		//--------------------------------------
		//	URLS and PATHS
		//--------------------------------------
		private var scriptUrl:String;
		private var newCodeScriptURL:String;
		private var mediaUrl:String;
		private var soundUrl:String;
		

		//--------------------------------------// 
		// DEBUG AND SOUND SETTINGS
		//--------------------------------------//
		private var _debug:Boolean=false;
		private var _sound:Boolean=false;
		private var _data:Object=null;
		
		
		/**
		 * constructor. No variables will be pased. Initializes view component.
		 */
		public function LoginObject()
		{
			view = new LogInView();
			view.addEventListener(FlexEvent.CREATION_COMPLETE, onViewCreation);
			references.push(view);	
		}
		
		

		public function set debug(value:Boolean):void
		{
			_debug=value;
		}
		
		public function set soundMode(value:Boolean):void
		{
			_sound=value;
		}
		
		public function get debug():Boolean
		{
			return _debug;
		}
		
		public function get soundMode():Boolean
		{
			return _sound;
		}
		
		public function get data():Object
		{
			return _data;
		}
		
		public function set data(value:Object):void
		{
			_data=value;
		}		
		
		
		
		public function getClassDefinition():String
		{
			return "MainApplication.LoginObject";
		}
		

		public function returnLoadFinishedEvent():String
		{
			return	LOAD_COMPLETE;
		}
		
		public function returnModuleFinishedEvent():String
		{
			return CustomModuleEvents.MODULE_FINISHED;
		}
		
		
		
		
		/**
		 * Extracts the urls and paths from the globals model and prepares the http service for server request.
		 * 
		 * @param _globals the global settings lib object, storing all labels and paths for the application
		 * @param _tcollection the testcollection lib object, not used in this class
		 * @param _session the session lib object, not used in this class
		 */
		public function load(_globals:Globals,_tcollection:TestCollection,_session:Session):void
		{
			var _labels:Array = _globals.labels;
			var _urls:Array = _globals.paths;
			this.labelList=_labels;
			var root:String;
			for(var i:uint=0;i<_urls.length;i++)
			{
				if(_urls[i][0]==UrlTypeEnum.ROOT.getValue())
				{
					root = _urls[i][1];
				}
				if(_urls[i][0]==UrlTypeEnum.INCLUDE_SCRIPT.getValue())
				{
					scriptUrl = root + _urls[i][1];
				}
				if(_urls[i][0]==UrlTypeEnum.SOUNDS.getValue())
				{
					soundUrl = _urls[i][1];
				}
				
			}
			
			user_login = new HTTPService();
			user_login.url = this.scriptUrl;
			user_login.useProxy = false;
			user_login.method = "POST";
			user_login.addEventListener(ResultEvent.RESULT, onResult);
			user_login.addEventListener(FaultEvent.FAULT, onFault);
			trace("[loginobject]: load complete");	
			dispatchEvent(new Event(LOAD_COMPLETE));
			
		}
		
		
		public function returnView():Object
		{
			return this.view;	
		}
		
		
		public function unload():void
		{
			for(var i:uint=0;i<references.length;i++)
			{
				if(references[i] is ICustomEventDispatcher)
				{
					references[i].removeAllEventListeners();
				}
				references[i]=null;
			}
			this.view.removeAllElements();
			this.view = null;
		}
		
		/**
		 * not required in this class
		 */
		public function sendTweenFinished():void
		{
			//empty
		}
		
		/**
		 * @private
		 */
		private function onViewCreation(event:FlexEvent):void
		{		
			//create Labels
			for(var j:uint=0;j<this.labelList.length;j++)
			{
				if(labelList[j][0]==view.testMadeInPast.id)
				{
					view.testMadeInPast.text=labelList[j][1];
					if(!soundMode)
					{
						var testMadeSound:MP3Audio = new MP3Audio(scriptUrl,soundUrl + labelList[j][2]);
						view.newuserSoundButton.referringTo = testMadeSound;
						view.newuserSoundButton.addEventListener(MouseEvent.CLICK, playAudio);
						references.push(testMadeSound);	
					}
					
				}
				if(labelList[j][0]==view.yesButton.id)
				{
					view.yesButton.label=labelList[j][1];
					view.yesButton.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
				}
				if(labelList[j][0]==view.noButton.id)
				{
					view.noButton.label=labelList[j][1];
					view.noButton.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
				}
			}
			trace("[loginobject]: VIEW CREATION COMPLETE");
			view.yesButton.addEventListener(MouseEvent.CLICK, onEnterLogin);
			view.noButton.addEventListener(MouseEvent.CLICK, requestNewUser);
			//Shared.StaticFunctions.pulseFocus(this.view.newuserSoundButton);
		}
		
		
		/**
		 * @private
		 */
		private function onEnterLogin(event:Event):void
		{
			Shared.StaticFunctions.fadeOutSound();
			Shared.StaticFunctions.stopPulse();
			initHandlers();
		}
		
		
		/**
		 * @private
		 */
		private function onMouseOver(event:MouseEvent):void
		{
			var b:Button = event.currentTarget as Button;
			var _id:String = b.id;
			for(var i:uint=0;i<labelList.length;i++)
			{
				if(labelList[i][0] == _id)
				{
					Shared.StaticFunctions.fadeOutSound();
					var m:MP3Audio = new MP3Audio(scriptUrl,soundUrl + labelList[i][2]);
					m.playAudio();
				}
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
					"LoginObject.as",
					scriptUrl,
					false
				);
				//fallback
				event.target.removeEventListener(MouseEvent.CLICK, playAudio);
			}	
		}
		
		
		/**
		 * @private
		 */
		private function initHandlers():void
		{
			trace("[loginobject]: init keyboard events and labels");
			try
			{
				view.input.addEventListener(KeyboardEvent.KEY_UP,keyHandler);
				view.input1.addEventListener(KeyboardEvent.KEY_UP,keyHandler);
				view.input2.addEventListener(KeyboardEvent.KEY_UP,keyHandler);
				view.input3.addEventListener(KeyboardEvent.KEY_UP,keyHandler);
				view.input4.addEventListener(KeyboardEvent.KEY_UP,keyHandler);
				view.login_submitButton.addEventListener(MouseEvent.CLICK, send);
				
				switch(view.currentState)
				{
					case("login"):
						trace("[loginobject]: init labels in login state");
						for(var j:uint=0;j<this.labelList.length;j++)
						{
							if(labelList[j][0]==view.pleaseEnterCode.id)
							{
								
								view.pleaseEnterCode.text=labelList[j][1];
								if(!soundMode)
								{
									var enterCodeSound:MP3Audio = new MP3Audio(scriptUrl,soundUrl+labelList[j][2]);
									view.loginSoundButton.referringTo = enterCodeSound;
									view.loginSoundButton.addEventListener(MouseEvent.CLICK, playAudio);
									Shared.StaticFunctions.pulseFocus(view.loginSoundButton);
									references.push(enterCodeSound);	
								}
							}
							if(labelList[j][0]==view.login_submitButton.id)
							{
								view.login_submitButton.label=labelList[j][1];
							}
						}
						break;
					case("register"):
						trace("[loginobject]: init labels in register state");
						for(var i:uint=0;i<this.labelList.length;i++)
						{
							if(labelList[i][0]==view.yourNewCode.id)
							{
								view.yourNewCode.text=labelList[i][1];
							}
							if(labelList[i][0]==view.login_submitButton.id)
							{
								view.login_submitButton.label=labelList[i][1];
							}
						}
						
						break;
				}
				view.input.setFocus();
			}catch(e:Error){
				trace(e);
			}
			
		}
		
		
		/**
		 * @private
		 */
		private function keyHandler(event:KeyboardEvent):void
		{
			//trace(event.currentTarget + " " + event.keyCode);
			if(Number(event.keyCode) >=48 && Number(event.keyCode) <= 122)
			{
				switch(event.currentTarget.id.toString())
				{
					case("input"):
						var txt:String = view.input.text;
						view.input.text = txt.toUpperCase();
						view.input1.setFocus();
						break;
					case("input1"):
						var txt:String = view.input1.text;
						view.input1.text = txt.toUpperCase();
						view.input2.setFocus();
						break;
					case("input2"):
						var txt:String = view.input2.text;
						view.input2.text = txt.toUpperCase();
						view.input3.setFocus();
						break;
					case("input3"):
						var txt:String = view.input3.text;
						view.input3.text = txt.toUpperCase();
						view.input4.setFocus();
						break;
					case("input4"):
						CursorManager.setBusyCursor();
						CursorManager.removeAllCursors();
						var txt:String = view.input4.text;
						view.input4.text = txt.toUpperCase();
						view.login_submitButton.setFocus();
						break;
				}				
			}
			
		}
		
		
		/**
		 * @private
		 */
		private function getUserData(event:ResultEvent):void
		{
			
		}
		
		
		/**
		 * @private
		 */
		private function send(event:MouseEvent):void
		{
			Shared.StaticFunctions.fadeOutSound();
			Shared.StaticFunctions.stopPulse();
			view.removeEventListener(KeyboardEvent.KEY_UP,keyHandler);
			try
			{
				var finalIn:String = view.input.text + view.input1.text + view.input2.text + view.input3.text + view.input4.text;
				trace(finalIn);
				var a:Object = {
					param:'login',
					password:finalIn};
				user_login.request = a;
				requestData();
			}catch(e:Error){
				trace("[loginobject]: "+"invalid input   "+e);
			}
		}
		
		
		/**
		 * This method starts the http request.
		 */
		public function requestData():void
		{
			user_login.send();
		}
		
		/**
		 *	For other objects, to retrieve userdata url.
		 */
		public function returnUserData():String
		{
			return userDataUrl;
		}
		
		
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
				dispatchEvent(new CustomModuleEvents(CustomModuleEvents.MODULE_FINISHED,false,false,userDataUrl,null,null));
			}else{
				trace("[loginobject]: login fault");
				
				//if current view is register or login a hint label should show up to encourage 
				//users to reinput the code
				if(view.currentState=="register"||view.currentState=="login")
				{
					Shared.StaticFunctions.stopPulse();
					Shared.StaticFunctions.pulseFocus(view.retrysound);
					for(var j:uint=0;j<this.labelList.length;j++)
					{
						if(labelList[j][0]==view.retryInput.id)
						{
							if(!soundMode)
							{
								view.retrylabel.text=labelList[j][1];
								var retrySound:MP3Audio = new MP3Audio(scriptUrl,soundUrl+labelList[j][2]);
								view.retrysound.referringTo = retrySound;
								view.retrysound.addEventListener(MouseEvent.CLICK, playAudio);
								references.push(retrySound);
							}
		
						}
					}
					view.retryInput.alpha=0;
					view.retryInput.visible=true;
					Shared.StaticFunctions.tweenAlpha(view.retryInput);
				}
				
				trace("[loginobject]: "+event.result.loginsuccess);
				trace("[loginobject]: "+event.result.sqlresult);
				view.input.text="";
				view.input1.text="";
				view.input2.text="";
				view.input3.text="";
				view.input4.text="";
				view.input.setFocus();				
				this._loginState = 2;
			}
		}
		
		

		/**
		 * @private
		 */
		private function onFault(event:FaultEvent):void
		{
			trace("http status fault!");

			this.loginState = 3;
		}

		
		/**
		 * @private
		 */
		private function requestNewUser(event:MouseEvent):void
		{
			Shared.StaticFunctions.fadeOutSound();
			Shared.StaticFunctions.stopPulse();
			this.user_newCode = new HTTPService();
			this.user_newCode.url = this.newCodeScriptURL;
			this.user_newCode.useProxy = false;
			this.user_newCode.method = "POST";
			var a:Object = {param:'newuser'};
			this.user_newCode.request = a;
			this.user_newCode.addEventListener(ResultEvent.RESULT, onNewUserResult);
			this.user_newCode.send();
		}
		
		
		/**
		 * @private
		 */
		private function onNewUserResult(event:ResultEvent):void
		{
			view.currentState="register";
			this.initHandlers();
			newUserString = event.result.userDataUrl;
			trace("[loginobject]: newuserstring"+newUserString);
			user_login.removeEventListener(ResultEvent.RESULT,onNewUserResult);
			view.login_newCode.text = newUserString;
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
		
		
		/**
		 * @private
		 */
		public function set _loginState(newState:Number):void
		{
			trace("[loginobject]: state changed");
			loginState = newState;
			switch(loginState)
			{
				case(0):
					break;
				case(1):
					trace("[loginobject]: loginsuccess event fired!");
					
					dispatchEvent(new Event(LOGIN_SUCCESS));
					break;
				case(2):
					dispatchEvent(new Event(LOGIN_FAULT));
					break;
				case(3):
					dispatchEvent(new Event(REQUEST_ERROR));
					break;
				default:
					break;
			}
		}
		
		/**
		 * @private
		 */
		public function get _loginState():Number
		{
			return _loginState;
		}
		
		
	}
}