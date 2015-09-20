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
package interfaces
{
	
	import flash.events.IEventDispatcher;
	
	import models.Globals;
	import models.Session;
	import models.TestCollection;
	
	import spark.components.Group;
	
	import views.HelpView;

	/**
	 * DEPRECATED! Instead use AbstractModule class. Defines the minimal criteria for a class to be a module. This makes it possible for the MainAppManager to load any Module with the same abstract sequence of instructions.
	 */
	public interface IReaModule extends IEventDispatcher,ICustomEventDispatcher
	{
		
		
		function get rootUrl():String;
		function set rootUrl(value:String):void;
		
		function get scriptUrl():String;
		function set scriptUrl(value:String):void;
		
		function get soundUrl():String;
		function set soundUrl(value:String):void;
		
		function get mediaUrl():String;
		function set mediaUrl(value:String):void;
		
		function set helpVideos(value:Array):void;
		function get helpVideos():Array;
		
		
		
		//----------------------------////----------------------------//
		//
		// 						DEBUG VARIABLES
		//
		//----------------------------////----------------------------//
		
		
		function set track(value:Boolean):void;
		function get track():Boolean;
		
		
		/**
		 * @private
		 * gets Debug Value.
		 */
		function get debug():Boolean;
		
		/**
		 * <p>Set the Debugging state to <code>true</code>.</p>
		 * <p>Enables to determine errors without sourcecode by showing alertboxes, if an error occurs</p>
		 */
		function set debug(value:Boolean):void;
		
		/**
		 * @private
		 * gets soudn debug value
		 */
		function get soundMode():Boolean;
		
		/**
		 * <p>Sets sound to on or off</p>
		 * <p>Enables to use application without sound errors, ideal for rapid item development and debug</p>
		 */
		function set soundMode(value:Boolean):void;
				
		
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
		 */
		function load(_globals:Globals,_tcollection:TestCollection,_session:Session):void;
		
		/**
		 * <p>Unloads all contained and related objects of a module. Removes all event listeners if possible and sets all objects and relations to null.</p>
		 * <p>Therefore all related objects of a module should be stored in an array calles references.</p>
		 */
		function unload():void;
		
		/**
		 * To access the private view component only via referencs, instead of direct access.
		 */
		function returnView():Group;
		
		/**
		 * Returns a String of the module class plus the package name. Ensure to change their names, when refactor.
		 */
		function getClassDefinition():String;
		

		function getHelpDisplay():HelpView;
		
		function returnCurrentState():String;
		
		//----------------------------////----------------------------//
		//
		// 						EVENT RELATED
		//
		//----------------------------////----------------------------//
		
		
		
		
		/**
		 * Event const cannot be accessed via get, therefore we use this method, to enable <code>addEventListener(anyModuleInstance.returnLoadFinishedEvent())</code>
		 */
		function returnLoadFinishedEvent():String;
		
		/**
		 * Event const cannot be accessed via get, therefore we use this method, to enable <code>addEventListener(anyModuleInstance.returnModuleFinishedEvent())</code>
		 */
		function returnModuleFinishedEvent():String;
		
		/**
		 * Tells the module, that the screen is visible and specific actions can be performed now.
		 */
		function sendTweenFinished():void;

	}
}