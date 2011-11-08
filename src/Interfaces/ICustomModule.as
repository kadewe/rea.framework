package Interfaces
{
	
	import Model.Globals;
	import Model.TestCollection;
	
	import Model.Session;
	
	import flash.events.IEventDispatcher;

	/**
	 * Defines the minimal criteria for a class to be a module. This makes it possible for the MainAppManager to load any Module with the same abstract sequence of instructions.
	 */
	public interface ICustomModule extends IEventDispatcher,ICustomEventDispatcher
	{
		//----------------------------////----------------------------//
		//
		// 						DEBUG VARIABLES
		//
		//----------------------------////----------------------------//
		
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
		function returnView():Object;
		
		/**
		 * Returns a String of the module class plus the package name. Ensure to change their names, when refactor.
		 */
		function getClassDefinition():String;
		

		
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