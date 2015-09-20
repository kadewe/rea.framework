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
	import events.CustomEventDispatcher;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	import interfaces.ICustomEventDispatcher;
	import interfaces.IDisposable;
	
	import models.Globals;
	import models.Session;
	import models.TestCollection;
	
	import mx.collections.ArrayList;
	
	import spark.components.Group;
	
	import views.GUILoader;
	
	
	/**
	 * Abstract base class for all modules in this application. Functions, except Constructor, throw errors and have to overridden.
	 */
	public class AbstractModule extends CustomEventDispatcher implements IDisposable, ICustomEventDispatcher
	{
		
		//---------------------------------------
		//
		//	CONSTRUCTOR
		//
		//---------------------------------------

		/**
		 * Constructor empty.
		 */
		public function AbstractModule(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		/**
		 * The reference list which keeps references to all objects, loaded at runtime. Will be used in the unload() method.
		 * @see #unload
		 * @see Interfaces.IDisposable
		 */
		protected var references:ArrayList = new ArrayList();
		
		
		//------------------------------------------------
		// Path to Server Root
		//------------------------------------------------
		
		/**
		 * @private
		 */
		private var _rootUrl:String;
		
		/**
		 * represents the root url on the server. Can be changed within the globals.xml
		 */
		public function get rootUrl():String
		{
			return _rootUrl;
		}
		
		public function set rootUrl(value:String):void
		{
			if(_rootUrl != value)
				_rootUrl = value;
		}
		
		//------------------------------------------------
		// Path to Include Script
		//------------------------------------------------
		/**
		 * @private
		 */
		private var _scriptUrl:String;
		
		/**
		 * Represents the path to the php script which will include scripts from the restricted area. Can be changed within the globals.xml
		 */
		public function get scriptUrl():String
		{
			return _scriptUrl;
		}
		
		public function set scriptUrl(value:String):void
		{
			if(_scriptUrl != value)
				_scriptUrl = value;
		}
		
		//------------------------------------------------
		// Path to Sound Directory on server
		//------------------------------------------------
		
		/**
		 * @private
		 */
		private var _soundUrl:String;
		
		/**
		 * Represents the path to the sound files in the restricted area. Can be changed within the globals.xml
		 */
		public function get soundUrl():String
		{
			return _soundUrl;
		}
		
		public function set soundUrl(value:String):void
		{
			if(_soundUrl != value)
				_soundUrl = value;
		}
		

		
		//------------------------------------------------
		// List of HelpVideos
		//------------------------------------------------
		/**
		 * @private
		 */
		private var _helpVideos:Array;
		
		/**
		 * Represents the path to help video files on the server. Can be changed within the globals.xml
		 */
		public function set helpVideos(value:Array):void
		{
			if(_helpVideos != value)
				_helpVideos = value;
		}
		
		public function get helpVideos():Array
		{
			return _helpVideos;
		}
		
		
		//------------------------------------------------
		// Switch for tracking on or off (developer internal)
		//------------------------------------------------
		/**
		 * @private
		 */
		private var _track:Boolean;
		
		/**
		 * Represents the value of tracking enabled or disabled. Can be changed within the globals.xml
		 */
		public function set track(value:Boolean):void
		{
			if(_track != value)
				_track = value;
		}
		public function get track():Boolean
		{
			return _track;
		}
		
		
		//------------------------------------------------
		// Switch for debug mode on or off (developer internal)
		//------------------------------------------------
		/**
		 * @private
		 */
		private var _debug:Boolean;
		
		/**
		 * Represents the debug value. Can be changed within the globals.xml
		 */
		public function get debug():Boolean
		{
			return _debug;
		}
		

		public function set debug(value:Boolean):void
		{
			if(_debug != value)
				_debug = value;
		}
		
		
		//------------------------------------------------
		// Switch for sound on or off (developer internal)
		//------------------------------------------------
		/**
		 * @private
		 */
		private var _playSound:Boolean;
		
		/**
		 * Represents the value of sound on or of. Can be changed within the globals.xml
		 */
		public function get playSound():Boolean
		{
			return _playSound;
		}
		
		/**
		 * <p>Sets sound to on or off</p>
		 * <p>Enables to use application without sound errors, ideal for rapid item development and debug</p>
		 */
		public function set playSound(value:Boolean):void
		{
			if(_playSound != value)
				_playSound = value;
		}
		
		
		//------------------------------------------------
		// GUI LOADER
		//------------------------------------------------
		
		protected var _guiloader:GUILoader;
		

		
		
		//----------------------------////----------------------------//
		//
		// 			METHODS FOR CONNECTING WITH OTHER CONTROLLERS
		//
		//----------------------------////----------------------------//
		
		/**
		 * <p>Loading the module.</p>
		 * <p>
		 * Connect the modules internal variables with data from GlobalSettings, TestCollections and Session.
		 * Usually there are only some of them needed, so not all the modules will behave like in the following description.
		 * </p>
		 * 
		 * <p>loads debug states, url paths to data on the server, and text for labels from globalsettings</p>
		 * <p>loads the collection of possible dimensions, levels and the associated items as Strings</p>
		 * <p>loads actual session states. These can include actual dimension, actual level and actual item.</p>
		 * 
		 * @throws Error if not overridden by subclass
		 */
		public function load(_globals:Globals,_tcollection:TestCollection,_session:Session):void
		{
			//ALWAYS OVERRIDE
			
			throw new Error("unoverridden method in abstract class");
		}
		

		
		
		/**
		 * <p>Unloads all contained and related objects of a module. Removes all event listeners if possible and sets all objects and relations to null.</p>
		 * <p>Therefore all related objects of a module should be stored in an array calles references.</p>
		 * 
		 * @see #references
		 */
		public function unload():void
		{
			for(var i:int=0;i<references.length;i++)
			{
				var object:Object = references.getItemAt(i);
				if(object is ICustomEventDispatcher)
				{
					object.removeAllEventListeners();
				}
				if(object is IDisposable)
				{
					object.unload();
				}
				object = null;
			}
			references.removeAll();
			references = null;

		}
		
		/**
		 * To access the private view component only via referencs, instead of direct access.
		 * 
		 * @throws Error if not overridden by subclass
		 */
		public function returnView():Group
		{
			//ALWAYS OVERRIDE
			throw new Error("unoverridden method in abstract class");
			return null;
		}
		
		/**
		 * Returns a String of the module class plus the package name. Ensure to change their names, when refactor.
		 * 
		 * @throws Error if not overridden by subclass
		 */
		public function getClassName():String
		{
			throw new Error("unoverridden method in abstract class");
			return "";
		}
		
		/**
		 * called when help event is invoked
		 * 
		 * @throws Error if not overridden by subclass
		 */
		protected function open_help(event:Event):void
		{
			throw new Error("unoverridden method in abstract class");
		}
		
		/**
		 * Returns the current view state.
		 * 
		 * @throws Error if not overridden by subclass
		 */
		public function returnCurrentState():String
		{
			//OVERRIDE
			throw new Error("unoverridden method in abstract class");
			return "";
		}
		
		
		
		
		//----------------------------////----------------------------//
		//
		// 						EVENT RELATED
		//
		//----------------------------////----------------------------//
		
		
		/**
		 * Event const cannot be accessed via get, therefore we use this method, to enable <code>addEventListener(anyModuleInstance.returnLoadFinishedEvent())</code>
		 */
		public function returnLoadFinishedEvent():String
		{
			throw new Error("unoverridden method in abstract class");
			return "";
		}
		
		/**
		 * Event const cannot be accessed via get, therefore we use this method, to enable <code>addEventListener(anyModuleInstance.returnModuleFinishedEvent())</code>
		 */
		public function returnModuleFinishedEvent():String
		{
			throw new Error("unoverridden method in abstract class");
			return "";
		}
		
		/**
		 * Tells the module, that the screen is visible and specific actions can be performed now.
		 */
		public function sendTweenFinished():void
		{
			
		}
	}
}