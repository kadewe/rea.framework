
package MainApplication
{
	import DisplayApplication.*;
	
	import Interfaces.ICustomModule;
	
	import ItemApplication.ItemObject;
	import ItemApplication.TutorialObject;
	
	import MainApplication.*;
	
	import Model.Collection;
	import Model.Dimension;
	import Model.Globals;
	import Model.Session;
	import Model.TestCollection;
	import Model.UserObject;
	
	import Shared.CustomModuleEvents;
	import Shared.ErrorDispatcher;
	
	import enumTypes.ErrorTypeEnum;
	import enumTypes.UrlTypeEnum;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getDefinitionByName;
	
	/**
	 * The core controller class.
	 * Manages the loading and unloading of the modules as well as the communication between them and the model related data.
	 * Modules a loaded by name, their functions are accessed via <code>ICustomModule</code> interface.
	 * The view component of the modules get connected with the <code>DisplayManager</code>
	 * 
	 * @author Jan Küster
	 * 
	 * @see Interfaces.ICustomModule;
	 * @see MainApplication.DisplayManager
	 */
	public class MainAppManager extends EventDispatcher
	{
		
		//----------------------------------//
		// Data Structures
		//----------------------------------//
		private var globals:Globals;
		private var tc:TestCollection;
		private var user:UserObject;
		private var session:Session;
		
		
		//----------------------------------//
		// Dead References (needed to ensure load by classname)
		//----------------------------------//
		private var starAppRef:StartAppObject = null;
		private var loginRef:LoginObject = null;
		private var overviewRef:OverviewObject = null;
		private var itemRef:ItemObject = null;
		private var finishedRef:TestFinishedObject = null;
		private var tutRef:TutorialObject= null;
		
		//----------------------------------//
		// Control Structures
		//----------------------------------//
		private var ClassReference:Class;
		private var instance:ICustomModule;
		
		
		//----------------------------------//
		// Event Constants
		//----------------------------------//
		public static const MODULE_FINISHED:String = "creationComplete";
		public static const LOAD_COMPLETE:String = "loadComplete";
		
		
		//----------------------------------------------------//
		//
		//			PUBLIC METHODS
		//
		//----------------------------------------------------//		
		
		/**
		 * Constructor, no parameters.
		 */
		public function MainAppManager()					
		{
			globals=new Globals();
			session=new Session();
			globals.addEventListener(Globals.GLOBALS_LOADED, onGlobalsLoaded);
			globals.addEventListener(Globals.GLOBALS_FAULT, onGlobalsFault);			
		}
		
		
		/**
		 * Returns a reference to the view component, owned by the current module instance.
		 * 
		 * @author Jan Küster
		 * 
		 * @return Object view object, usually a group based mxml component
		 */
		public function getView():Object
		{
			trace("get view");
			try
			{
				return instance.returnView();	
			}catch(e:Error){
				ErrorDispatcher.processNewError
					(
						ErrorTypeEnum.NULLREFERENCE.getNumber().toString(),
						ErrorTypeEnum.NULLREFERENCE.getValue(),
						e.errorID.toString(),
						e.name + " could not access module instance's view component. "
						,"MainAppManager.as",
						globals.returnPathValue(UrlTypeEnum.ROOT.getValue()) + globals.returnPathValue(UrlTypeEnum.INCLUDE_SCRIPT.getValue()),
						false
					);
			}
			//instead of group better write
			//a real fallback for displaying some stuff
			return new ErrorView();
		}
		
		/**
		 * Sends to the module instance, that the display tween is finished. This ensures a delay of starting animations or scripts until the new screen is visible.
		 * 
		 * @author
		 */
		public function sendTweenComplete():void
		{
			if(instance!=null)
				instance.sendTweenFinished();
		}
		
	
		
		//----------------------------------------------------//
		//
		//			PRIVATE METHODS
		//
		//----------------------------------------------------//
		
		
		/**
		 * @private
		 * loads a new module by passing a classname.
		 */
		private function loadModule(className:String):void
		{
			try
			{
				trace("[mainappmanager]: load "+className);
				ClassReference = getDefinitionByName(className) as Class;
				instance =new ClassReference() as ICustomModule;
				instance.debug = globals.debugMode;
				instance.soundMode = globals.soundIgnore;
				instance.addEventListener(instance.returnLoadFinishedEvent(), onInstanceLoadComplete);
				instance.addEventListener(instance.returnModuleFinishedEvent(), onModuleFinished);
				instance.load(globals,tc,session);	
			}catch(e:Error){
				trace("Load Module Error");
				ErrorDispatcher.processNewError
					(
					ErrorTypeEnum.CANNOT_LOAD_MODULE.getNumber().toString(),
					ErrorTypeEnum.CANNOT_LOAD_MODULE.getValue(),
					e.errorID.toString(),
					e.name + " classreference: "+className,"MainAppManager.as",
					globals.returnPathValue(UrlTypeEnum.ROOT.getValue()) + globals.returnPathValue(UrlTypeEnum.INCLUDE_SCRIPT.getValue()),
					false
					);
				//extreme fallback to very first module.
				//write other fallback here
				this.loadModule("MainApplication.StartAppObject");
			}
			
		}
		
		/**
		 * @private
		 * 
		 */
		private function onInstanceLoadComplete(event:Event):void
		{
			dispatchEvent(new Event(LOAD_COMPLETE));
		}
		
		
		/**
		 * @private
		 */
		private function onModuleFinished(event:CustomModuleEvents):void
		{
			instance.unload();
			
			//update Session Object
			session.updateSession(event._dimension,event._level,event._itemString);
			var nextItem:String = event._isNext==true?event._itemString:tc.searchNextItem(session.dimension,session.level,session.item);
			session.updateSession(-1,-1,nextItem);
			
			//create user object
			if(event._userDataUrl!=null)
			{
				user = new UserObject(globals.returnPathValue(UrlTypeEnum.ROOT.getValue())+globals.returnPathValue(UrlTypeEnum.INCLUDE_SCRIPT.getValue()),event._userDataUrl);
				user.addEventListener(UserObject.CREATION_ERROR, onUserCreationError);
				user.load();
			}
			if(event._isNext)
			{
				user.startSession(tc.getDimensionAt(
					session.dimension).returnCollectionAt(session.level).returnItems(),
					tc.getDimensionName(session.dimension),
					tc.getLevelName(session.dimension,session.level),
					(globals.returnPathValue(UrlTypeEnum.ROOT.getValue())+globals.returnPathValue(UrlTypeEnum.INCLUDE_SCRIPT.getValue()))
				);
			}
			if(!event._isNext && event._itemString)
			{
				user.updateSession(
					event._itemString,
					event._timeStamp,
					event._updatedXML,
					(globals.returnPathValue(UrlTypeEnum.ROOT.getValue())+globals.returnPathValue(UrlTypeEnum.INCLUDE_SCRIPT.getValue()))
				);
			}
			//get the next module 
			var nextInstance:String = LoaderManagement.getNext2Load(instance.getClassDefinition(),nextItem);
			
			//cleanup
			dispatchEvent(new Event(MODULE_FINISHED));
			instance.removeAllEventListeners();
			instance=null;
			this.loadModule(nextInstance);
		}
		
		
		/**
		 * @private
		 */
		private function onGlobalsFault(event:Event):void
		{
			globals.removeAllEventListeners();
			//write fallback here
		}
		
		/**
		 * @private
		 */
		private function onUserCreationError(event:Event):void
		{
			user.removeAllEventListeners();
			//write fallback here	
		}
		
		
		/**
		 * @private
		 */
		private function onGlobalsLoaded(event:Event):void
		{
			//-----------------------------------------// Global Settings loaded, now we can start the application
			globals.removeAllEventListeners();
			this.loadModule("MainApplication.StartAppObject");

			
			//-----------------------------------------// meanwhile load the testcollection
			tc=new TestCollection(globals.returnPathValue("rootUrl"));
			tc.addEventListener(TestCollection.TC_BUILD, onTCBuild);
			tc.addEventListener(TestCollection.TC_ERROR, onTCError);
		}
		
		/**
		 * @private
		 */
		private function onTCBuild(event:Event):void
		{
			tc.removeAllEventListeners();
			var d:Dimension = tc.getDimensionByName("Lesen");
			var c:Collection = d.returnCollectionAt(0);
		}
		
		
		/**
		 * @private
		 */
		private function onTCError(event:Event):void
		{
			tc.removeAllEventListeners();
			//write fallback
			//for example a demo item ;)
		}
		
	}
}