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
	 * Defines a set of events realted to the item object and its children. Also stores the result xml of the actual item, in order to pass it to other handlers.
	 */
	public class ItemEvent extends Event
	{
		
		
		/**
		 * Constructor. Calls superclass and applies parameters.
		 * @param _dataObject the data object containing the finished item xml, ready to be sent to the server
		 */
		public function ItemEvent(type:String,bubbles:Boolean=false,cancelable:Boolean=false,newdataObject:Object=null)
		{
			super(type,bubbles,cancelable);
			_dataObject = newdataObject;
		}
		
		//----------------------------------------------------////----------------------------------------------------//
		//
		//
		//				CONSTANTS
		//
		//
		//----------------------------------------------------////----------------------------------------------------//
		
		public static const ITEM_ONLOAD:String = "itemOnload";
		
		public static const ITEM_FINISHED:String = "itemFinished";
		
		public static const DATA_SENT:String = "dataSent";
		
		public static const DATA_RECEIVED:String = "dataReceived";
		
		public static const QPAGE_LOADED:String = "qpageLoaded";
		
		public static const PAGE_CHANGED:String = "pageChanged";
		
		public static const QPAGE_FINISHED:String = "qpageFinished";
		
		
		public static const EVALUATION_CALLED:String = "evaluationCalled";
		
		public static const TEST_ABORTED:String = "testAborted";
		
		//----------------------------------------------------////----------------------------------------------------//
		//
		//
		//				VARIABLES
		//
		//
		//----------------------------------------------------////----------------------------------------------------//
		
		/**
		 * @private
		 */
		private var _dataObject:Object;

		
		/**
		 * The data object containing the finished item xml, ready to be sent to the server.
		 */
		public function get dataObject():Object
		{
			return _dataObject;
		}
		
		//----------------------------------------------------////----------------------------------------------------//
		//
		//
		//		PUBLIC FUNCTIONS
		//
		//
		//----------------------------------------------------////----------------------------------------------------//
		
		/**
		 * @inheritDoc
		 */
		override public function clone():Event
		{
			return new ItemEvent(type,bubbles,cancelable,_dataObject);
		}
		
		
	}
}