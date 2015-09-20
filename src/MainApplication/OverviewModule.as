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
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import models.Globals;
	import models.Session;
	import models.TestCollection;
	
	import mx.events.FlexEvent;
	import mx.events.StateChangeEvent;
	
	import spark.components.Group;
	
	import views.ErrorView;
	import views.GUILoader;
	import views.Overview;

	/**
	 * the handler class for an overview, where users will choose their next testcollection by choosing a dimension and the corresponding level.
	 */
	public class OverviewModule extends AbstractModule
	{
		
		private var view:Overview;
		
		//---------------------------------
		// states listeners and references
		//---------------------------------
		private var state:Number = 0;
		
		
		//---------------------------------
		// session variables
		//---------------------------------
		private var itemToLoad:String;
		private var _last_item:String;
		private var chosenSubject:int;
		private var chosenLevel:int;
		
		private var tcreference:TestCollection;

		
		//---------------------------------
		// Labels and Urls
		//---------------------------------
		private var labels:Array;
		private var urls:Array;

		
		//--------------------------------------////--------------------------------------// 
		// 								Applications Settings
		//--------------------------------------////--------------------------------------//

		private var _session_ref:Session; // BAD!
		
		/**
		 * constructor, initializes view component.
		 */
		public function OverviewModule()
		{
			view = new Overview();
			view.addEventListener(FlexEvent.CREATION_COMPLETE, viewCreationComplete);
			references.addItem(view);
		}
		

		
		//--------------------------------------////--------------------------------------//
		// 									Module Loading
		//--------------------------------------////--------------------------------------//
		
		/**
		 * loads path urls and labels from globals. Makes a reference to testcollection, because we need this later for session building.
		 * 
		 * @param _globals reference to the globals lib
		 * @param _tcollection reference to the testcollection lib
		 * @param _session reference to the session lib, not used in this class
		 */
		override public function load(_globals:Globals,_tcollection:TestCollection,_session:Session):void
		{
			labels = _globals.labels;
			urls = _globals.paths;
			helpVideos = _globals.videos;
			_session_ref = _session;
			tcreference=_tcollection;
			view.setTestCollection(_tcollection);
			view.setGlobals(_globals);
			_guiloader = new GUILoader(_globals);	
			
			dispatchEvent(new CustomModuleEvents(CustomModuleEvents.MODULE_LOAD_COMPLETE));
		}
		
		
		//--------------------------------------------// 
		// Module Finished
		//--------------------------------------------// 
		
		/**
		 * returns the package and calass name as a string to allow search within the loader management
		 */
		override public function getClassName():String
		{
			return "OverviewModule";
		}	
		
		
		//-----------------------------//
		// PRIVATE
		//-----------------------------//
		
		/**
		 * @private
		 * 
		 * after creation complete, labels, urls and eventListeners will be set up to display.
		 */
		private function viewCreationComplete(event:FlexEvent):void
		{
			
			view.removeEventListener(FlexEvent.CREATION_COMPLETE, viewCreationComplete);
			view.addEventListener(StateChangeEvent.CURRENT_STATE_CHANGE, onViewStateChanged);
			view.addEventListener(Overview.END, onApplicationEnd);
			view.addEventListener(Overview.LEVEL_SELECTED, onLevelSelected);
			view.addEventListener(Overview.RESTART_COLLECTION, restartCollection);
			view.addEventListener(Overview.CONTINUE, continueCollection);
			
			for(var i:int=0;i<urls.length;i++)
			{
				if(urls[i][0]==Globals.ROOTURL)
				{
					rootUrl = urls[i][1];
					trace("[loginobject]: "+rootUrl);
				}
				if(urls[i][0]==Globals.SCRIPTURL)
				{
					scriptUrl = rootUrl + urls[i][1];
					trace("[loginobject]: "+scriptUrl);
				}
				if(urls[i][0]==Globals.SOUND_PATH)
				{
					soundUrl = urls[i][1];
					trace("[loginobject]: "+soundUrl);
				}
			}
			
			
			_guiloader.initGUI( view );

			
			
		}
		
		
		protected function onApplicationEnd(event:Event):void
		{
			var req:URLRequest = new URLRequest(Globals.instance().returnPathValue(Globals.END_APP_REDICECT));
			navigateToURL(req,"_self");
		}
	
		
		protected function onLevelSelected(event:Event):void
		{
			
			
			_last_item = _session_ref.user.last_solved_item(view.chosenSubject,view.chosenLevel );
			if(_last_item.length>0)
			{
				var _collection_progress:Number = tcreference.get_testcollection_progress(chosenSubject,chosenLevel, _last_item);
				trace(_collection_progress);
				if(_collection_progress>0 && _collection_progress < 100)
				{
					view.setCurrentState(Overview.CONTINUE);
					view.updateProgressbar(_last_item, _collection_progress);
					
				}
				else
					load_new_item_collection();	
			}else{
				load_new_item_collection();
			}
		}
		
		protected function restartCollection(event:Event):void
		{
			load_new_item_collection();
		}
		
		protected function continueCollection(event:Event):void
		{
			itemToLoad = _last_item;
			dispatchEvent(new CustomModuleEvents(CustomModuleEvents.MODULE_FINISHED,false,false,null,itemToLoad,null,chosenLevel,chosenSubject,true));
		}		
		
		protected function load_new_item_collection():void
		{
			_session_ref.user.unsetPrev();	//unsets the previously found test reference
			itemToLoad = tcreference.getDimensionAt(chosenSubject).returnCollectionAt(chosenLevel).returnItemAt(0);
			dispatchEvent(new CustomModuleEvents(CustomModuleEvents.MODULE_FINISHED,false,false,null,itemToLoad,null,chosenLevel,chosenSubject,true));
		}

		protected function onViewStateChanged(event:StateChangeEvent):void
		{
			if(!view.getcurrentStateIsInitialized())
			{
				_guiloader.initGUI( view );
				view.setcurrentStateIsInitialized( true );
			}
		}
		/**
		 * Returns a reference to the view component.
		 */
		override public function returnView():Group
		{
			return this.view!=null?view:new ErrorView().setMessage("Overview view is null");	
		}
		
		/**
		 * not used in this class
		 */
		override public function sendTweenFinished():void
		{
			//empty
		}
		
		/**
		 * cleanup event listeners and references 
		 */
		override public function unload():void
		{
			this.view.removeAllElements();
			this.view.removeAllEventListeners();
			this.view = null;
			super.unload();
		}
		
		override public function returnCurrentState():String
		{
			return view.currentState;
		}
	}
}