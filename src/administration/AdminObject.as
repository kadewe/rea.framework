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
package administration
{
	import MainApplication.AbstractModule;
	
	import administration.view.AdminView;
	
	import enums.GlobalConstants;
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import models.Globals;
	import models.Session;
	import models.TestCollection;
	
	import mx.events.FlexEvent;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	import spark.components.Button;
	import spark.components.Group;
	
	import views.TcView;
	
	public class AdminObject extends AbstractModule
	{
		//---------------------------------------
		//
		//	VARIABLES
		//
		//---------------------------------------
		
		public static const LOAD_COMPLETE:String = "loadComplete";
		
		private var view:AdminView;
		private var tcview:TcView;
		
		//comment
		
		private var urls:Array;
		private var settings:Array;
		private var labels:Array;
		private var itemUrl:String;
		
		private var globals:Globals;
		private var tc:TestCollection;
		
		private var user_login:HTTPService;
		private var loginCount:uint; //prevent brute force --> 5 wrong logins maximum!
		
	
		
		//---------------------------------------
		//
		//	CONSTRUCTOR
		//
		//---------------------------------------
		
		public function AdminObject()
		{
			view = new AdminView();
			view.addEventListener(FlexEvent.CREATION_COMPLETE, onViewCreationComplete);
			references.addItem(view);
			loginCount=0;
		}
		
	
		
		//---------------------------------------
		//
		//	PUBLIC FUNCTIONS
		//
		//---------------------------------------
		
		
		override 	public function load(_globals:Globals, _tcollection:TestCollection, _session:Session):void
		{
			//parameters
			globals = _globals;
			tc = _tcollection;
			
			updateUrls();
			
			//services and logic 
			user_login = new HTTPService();
			user_login.url = this.scriptUrl;
			user_login.useProxy = false;
			user_login.method = "POST";
			user_login.addEventListener(ResultEvent.RESULT, onResult);
			user_login.addEventListener(FaultEvent.FAULT, onFault);

			dispatchEvent(new Event(LOAD_COMPLETE));
		}
		
		override public function returnCurrentState():String
		{
			return view.currentState;
		}
		
		//ACCESS//
		
		override public function unload():void
		{
			super.unload();
		}
		
		override public function returnView():Group
		{
			return view;
		}
		
		override public function getClassName():String
		{
			return "AdminObject";
		}

		
		override public function sendTweenFinished():void
		{
			//start something
		}
		
		
		//---------------------------------------
		//
		//	PRIVATE FUNCTIONS
		//
		//---------------------------------------
		
		private function updateUrls():void
		{
			urls = globals.paths;
			labels = globals.labels;
			settings=globals.settings;
			helpVideos = globals.videos;
			for(var i:uint=0;i<urls.length;i++)
			{
				if(urls[i][0]==GlobalConstants.ROOT)
				{
					rootUrl = urls[i][1];
				}
				if(urls[i][0]==GlobalConstants.INCLUDE_SCRIPT)
				{
					scriptUrl = rootUrl + urls[i][1];
				}
				if(urls[i][0]==GlobalConstants.SOUNDS)
				{
					soundUrl = urls[i][1];
				}
				if(urls[i][0] == GlobalConstants.ITEMSPATH)
				{
					itemUrl = rootUrl + urls[i][1];
				}
			}
		}	

		private function login():void
		{
			var o:Object = {
				param:'alogin',
				user:view.userName.text,
				password:view.password.text
			};
			user_login.request=o;
			user_login.send();
		}

		//		TEACHER'S FUNCTIONS   //

		private function teachersMode():void
		{
			view.setCurrentState("teacher");
			trace(view.currentState);
			view.tcmenu.addEventListener(MouseEvent.CLICK, onTeachersTcMenu);
		}
		
		private function tcmenu():void
		{
			tcview = new TcView();
			
			for(var i:uint=0;i<tc.getDimensionsCount();i++)
			{
				var b:Button = new Button();
				b.label = i.toString();
				tcview.tcmenu.addElement(b);
			}
			view.teacherscontent.addElement(tcview);
		}
		
		private function parseGlobals():void
		{
			//----------------- URLS ----------------//
			for(var i:uint=0;i<urls.length;i++)
			{
				var a:Object = {
					url_id:urls[i][0],
					url_path:urls[i][1]
				};
				view.urlarray.addItem(a);
			}
			
			
			//---------------- LABELS ---------------//
			
			for(i=0;i<labels.length;i++)
			{
				
				var b:Object = {
					label_id:labels[i][0],
					label_text:labels[i][1],
					label_sound:labels[i][2]
				};
				view.labelsarray.addItem(b);
			}
			
			
			//---------------- SETTINGS ---------------//
			
			for(i=0;i<settings.length;i++)
			{
				
				var c:Object = {
					settings_id:settings[i][0],
					settings_value:settings[i][1]
				};
				view.settingsarray.addItem(c);
			}
		}
			
				
		//---------------------------------------
		//
		//	EVENTS
		//
		//---------------------------------------
		
		private function onViewCreationComplete(event:FlexEvent):void
		{
			view.userName.setFocus();
			view.send.addEventListener(MouseEvent.CLICK, onSendButtonClicked);
			view.password.addEventListener(KeyboardEvent.KEY_UP, onPasswordEnterKeyDown);
		}
		
		private function onPasswordEnterKeyDown(event:KeyboardEvent):void
		{
			
			if(event.keyCode == Keyboard.ENTER)
			{
				view.password.removeEventListener(KeyboardEvent.KEY_UP,onPasswordEnterKeyDown);
				login();
			}
		}
		
		private function onSendButtonClicked(event:MouseEvent):void
		{
			login();	
		}
		
		private function onResult(event:ResultEvent):void
		{
			trace(event.result);
			
			//if(result.code==xxx...){...}
		}
		
		private function onFault(event:FaultEvent):void
		{
			teachersMode();
		}
		
		private function onTeachersTcMenu(event:MouseEvent):void
		{
			tcmenu();
		}
		
	}
}