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
	
	public class TrackingEvent extends Event
	{
		
		
		/**
		 * Constructor of the event. Passes params to the event object.
		 * 
		 *	@param type flash event internal
		 *  @param bubbles flash event internal
		 *  @param cancelable flash event internal
		 * 
		 * @param mouseX x value of the mouse cursor position
		 * @param mouseY y value of the mosue cursor position
		 * @param key which key has been pressed
		 * @param moved boolean indicates if the mouse has been moved
		 * @param clicked boolean indicates if a mouse key has been clicked
		 * @param keyPressed boolean for indicating if a key has been pressed
		 * @param target the target of the tracking event (may differ from the event.target or event.currentTarget object).
		 * 
		 */
		public function TrackingEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false,mouseX:int=0,mouseY:int=0,key:String="",moved:Boolean=false,clicked:Boolean=false,keyPressed:Boolean=false,target:*=null)
		{
			super(type, bubbles, cancelable);
			
			_mouseX=mouseX;
			_mouseY=mouseY;
			_clicked=clicked;
			_moved=moved;
			_keyPressed=keyPressed;
			_key = key;
			_eventTarget=target;
		}

		
		//----------------------------------------------------////----------------------------------------------------//
		//
		//
		//				CONSTANTS
		//
		//
		//----------------------------------------------------////----------------------------------------------------//
		
		
		public static const INPUT_OCCURED:String ="inputOccured";

		
		//----------------------------------------------------////----------------------------------------------------//
		//
		//
		//				VARIABLES
		//
		//
		//----------------------------------------------------////----------------------------------------------------//
		
		
		private var _eventTarget:*;

		public function get eventTarget():*
		{
			return _eventTarget;
		}

		private var _moved:Boolean;

		public function get moved():Boolean
		{
			return _moved;
		}

		private var _mouseX:int;
		
		public function get mouseX():int
		{
			return _mouseX;
		}

		private var _mouseY:int;
		
		public function get mouseY():int
		{
			return _mouseY;
		}
		
		private var _clicked:Boolean;

		
		public function get clicked():Boolean
		{
			return _clicked;
		}
		
		private var _key:String;
		
		public function get key():String
		{
			return _key;
		}
		
		private var _keyPressed:Boolean;
		
		public function get keyPressed():Boolean
		{
			return _keyPressed;
		}

	}
}