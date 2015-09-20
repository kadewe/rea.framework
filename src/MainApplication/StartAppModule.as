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
	
	import spark.components.Group;
	
	import utils.ReaVisualUtils;
	
	import views.ErrorView;
	import views.GUILoader;
	import views.StartAppView;

	
	/**
	 * <p>First module, loaded after initialization of the application. Includes a VideoPlayer for introducing the applications funcionalities.</p> 
	 */
	public class StartAppModule extends AbstractModule
	{
		/**
		 * The view component, which will be linked to the display.
		 * 
		 * @see MainApplication.MainAppManager
		 * @see MainApplication.DisplayManager
		 */
		public var view:StartAppView;		
		
		
		/**
		 * Constructor, also inits view.
		 */
		public function StartAppModule()
		{
			view = new StartAppView();
			view.addEventListener(FlexEvent.CREATION_COMPLETE, onViewCreationComplete);
			references.addItem(view);
		}
		
		/**
		 * @private
		 */
		protected function onViewCreationComplete(event:FlexEvent):void
		{
			view.removeEventListener(FlexEvent.CREATION_COMPLETE, onViewCreationComplete);
			
			//view.mainAppStartButton.label = Globals.instance().returnLabelValue("mainAppStartButton");
			view.mainAppStartButton.addEventListener(MouseEvent.CLICK, onStartApplicationButtonClicked);
			
			_guiloader.initGUI( view );
			view.setcurrentStateIsInitialized( true );
			
			view.addEventListener(FlexEvent.STATE_CHANGE_COMPLETE, initGui);
		}		
		
		protected function initGui(event:FlexEvent):void
		{
			if(!view.getcurrentStateIsInitialized())
			{
				_guiloader.initGUI( view );
				view.setcurrentStateIsInitialized( true );
			}
		}
		
		
		//--------------------------------------////--------------------------------------//
		//
		//
		// 				Overrides
		//
		//
		//--------------------------------------////--------------------------------------// 
		
		/**
		 * @inheritDoc
		 */
		override public function load(_globals:Globals,_tcollection:TestCollection,_session:Session):void
		{
			_guiloader = new GUILoader(_globals);
			dispatchEvent(new CustomModuleEvents(CustomModuleEvents.MODULE_LOAD_COMPLETE));
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function returnView():Group
		{
			return this.view!=null?view:new ErrorView().setMessage("Startapp module view is null");	
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function sendTweenFinished():void
		{
			
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function getClassName():String
		{
			return "StartAppModule";
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function unload():void
		{
			//unload internal stuff here
			
			super.unload();
		}
		
		
		
		/**
		 * @inheritDoc
		 */
		override public function returnCurrentState():String
		{
			return view.currentState;
		}
		
		
		
		//--------------------------------------////--------------------------------------//
		//
		//
		// 				Video Player Related
		//
		//
		//--------------------------------------////--------------------------------------// 
		

		
		private function onStartApplicationButtonClicked(event:Event):void
		{
			utils.ReaVisualUtils.stopPulse();
			dispatchEvent(new CustomModuleEvents(CustomModuleEvents.MODULE_FINISHED,false,false,null,null,null));
		}
		


	}
}