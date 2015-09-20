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
package events
{
	import flash.events.Event;

	/**
	 * Event class for passing user session related values via event from the module to the MainAppManger.
	 */
	public class CustomModuleEvents extends Event
	{
		
		/**
		 * Constructor, calls superclass and passes parameters.
		 * 
		 * @param _userDataUrl	the passed user id
		 * @param _itemString 	the id of the actual item, used to determine the successor item
		 * @param _timeStamp 	the timestamp needed for writing the files on the server in order to the actual time
		 * @param _level 		the chosen level of the testcollection
		 * @param _dimension 	the chosen dimension of the testcollection
		 * @param _isNext		determines if the following module is an item, if <code>true</code>, the next module should be an item AND the item id to load will be dtermined by <code>_itemString</code>
		 * @param updated		contains the updated item xml (after an item was completed). ready to be sent to the server
		 */
		public function CustomModuleEvents(type:String,bubbles:Boolean=false,cancelable:Boolean=true,_userDataUrl:String=null,_itemString:String=null,_timeStamp:String=null,_level:int=-1,_dimension:int=-1,_isNext:Boolean=false,updated:XML=null,adminMode:Boolean=false)
		{
			
			super(type,bubbles,cancelable);
			userDataUrl = _userDataUrl;
			itemString = _itemString;
			timeStamp = _timeStamp;
			level=_level;
			dimension=_dimension;
			isNext = _isNext;
			updatedXml = updated;
			admin = adminMode;
		}
		
		
		//----------------------------------------------------////----------------------------------------------------//
		//
		//
		//				CONSTANTS
		//
		//
		//----------------------------------------------------////----------------------------------------------------//
		
		/**
		 * Disptached by modules when they are finished and ready for post-processing and cleanup.
		 */
		public static const MODULE_FINISHED:String = "moduleFinished";
		
		/**
		 * Dispatched after a module is loaded and data has been pre-processed.
		 */
		public static const MODULE_LOAD_COMPLETE:String = "moduleLoadComplete";
		


		
		//----------------------------------------------------////----------------------------------------------------//
		//
		//
		//				VARIABLES
		//
		//
		//----------------------------------------------------////----------------------------------------------------//
		
		//------- user related ------//
		
		/**
		 * @private
		 */
		private var userDataUrl:String;
		
		public function get _userDataUrl():String
		{
			return userDataUrl;
		}
		
		/**
		 * @private
		 */
		private var admin:Boolean;
		
		/**
		 * Represents if we are in administration mode. 
		 */
		public function get adminMode():Boolean
		{
			return admin;
		}
		
		//------- item related ------//
		
		/**
		 * @private
		 */
		private var itemString:String;

		/**
		 * represents either the curretn item whcih has been solved ot the next item to load
		 * 
		 * @see #isNext
		 */
		public function get _itemString():String
		{
			return itemString;
		}
		

		/**
		 * @private
		 */
		private var timeStamp:String;
		
		
		/**
		 * The timestamp of the last solved item.
		 */
		public function get _timeStamp():String
		{
			return timeStamp;
		}
		
		/**
		 * @private
		 */
		private var level:int;

		/**
		 * The curretn level of difficulty we are currently in.
		 */
		public function get _level():int
		{
			return level;
		}
		
		/**
		 * @private
		 */
		private var dimension:int;

		
		/**
		 * The current dimension / subject we are currently in.
		 */
		public function get _dimension():int
		{
			return dimension;
		}
		
		/**
		 * @private
		 */
		private var isNext:Boolean;

		
		/**
		 * Indicates, that the item id , dispatched with this event is the next item to load.
		 */
		public function get _isNext():Boolean
		{
			return isNext;
		}
		
		/**
		 * @private
		 */
		private var updatedXml:XML;
	
		/**
		 * Represents a result xml from a solved item / test. Is null for all otther modules.
		 */
		public function get _updatedXML():XML
		{
			return updatedXml;
		}
		
		
		//----------------------------------------------------////----------------------------------------------------//
		//
		//
		//		PUBLIC FUNCTIONS
		//
		//
		//----------------------------------------------------////----------------------------------------------------//

		
		override public function clone():Event
		{
			return new CustomModuleEvents(type,bubbles,cancelable,userDataUrl,itemString,timeStamp,level,dimension,isNext,updatedXml,admin);
		}
		
	}
}