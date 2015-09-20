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
	import events.CustomEventDispatcher;
	
	import interfaces.IReaModule;
	
	
	import models.Globals;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.utils.getDefinitionByName;
	
	import spark.components.Group;
	
	public class AdministrationManager extends CustomEventDispatcher
	{
		private var globals:Globals;
		
		//----------------------------------//
		// NULL References (needed to ensure load by classname)
		//----------------------------------//
		private var loginRef:AdminSuite=null;
		private var adminRef:AdminObject = null; 
		private var teacherModeRef:TeacherMode = null;
		
		//----------------------------------//
		// Control Structures
		//----------------------------------//
		private var ClassReference:Class;
		private var instance:IAdminModule;
		
		//----------------------------------//
		// Event Constants
		//----------------------------------//
		public static const MODULE_FINISHED:String = "creationComplete";
		public static const LOAD_COMPLETE:String = "loadComplete";
		public static const DISPLAY_UPDATE:String = "displayUpdate";
		
		
		//------------------------------------------------
		//
		//	INITIALIZATION
		//
		//------------------------------------------------		
		
		
		public function AdministrationManager(target:IEventDispatcher=null)
		{
			super(target);
			Globals.instance().addEventListener(Globals.GLOBALS_LOADED, onGlobalsLoaded);
			Globals.instance().addEventListener(Globals.GLOBALS_FAULT, onGlobalsFault);
			Globals.instance().initializeData();
		}
		
		
		private function initModule(classname:String):void
		{
			ClassReference = getDefinitionByName(classname) as Class;
			instance =new ClassReference() as IAdminModule;
			instance.addEventListener(instance.returnLoadFinishedEvent(), onInstanceLoadComplete);
			instance.addEventListener(instance.returnModuleFinishedEvent(), onModuleFinished);
			instance.addEventListener(instance.returnUpdateEvent(), onInstanceUpdate);
			instance.init(Globals.instance());
		}
		
		//------------------------------------------------
		//
		//	COMMUNICATION
		//
		//------------------------------------------------
		
		public function returnView():Group
		{
			trace(instance + "return View to ROOT APPLICATION");
			
			return instance.returnCurrentDisplay();	
		}
		
		
		
		//------------------------------------------------
		//
		//	Module Events
		//
		//------------------------------------------------
		
		private function onInstanceLoadComplete(event:Event):void
		{
			dispatchEvent(new Event(LOAD_COMPLETE));
		}
		
		
		/**
		 * @private
		 */
		private function onModuleFinished(event:AdminEvent):void
		{
			dispatchEvent(new Event(MODULE_FINISHED));
			instance.unload();
			instance = null;
			ClassReference = null;
			
			initModule(event.nextModule);
		}
		
		
		private function onInstanceUpdate(event:Event):void
		{
			dispatchEvent(new Event(DISPLAY_UPDATE));
		}
		//------------------------------------------------
		//
		//	PRIVATE
		//
		//------------------------------------------------
		
		private function onGlobalsLoaded(event:Event):void
		{
			trace("AdminMan::globals loaded");
			//globals.removeAllEventListeners();
			initModule("administration.AdminSuite");
		}
		
		private function onGlobalsFault(event:Event):void
		{
			trace("AdminMan::globals fault");
			globals.removeAllEventListeners();
			//fallback --> create new globals object
		}
	}
}