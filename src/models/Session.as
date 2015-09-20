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
package models
{
	import events.CustomEventDispatcher;
	
	import flash.events.Event;
	
	import utils.StringUtils;

	/**
	 * This class represents a running user session with global variables.
	 */
	public class Session extends CustomEventDispatcher
	{
		
		//=================================================================================
		//
		//
		//	CONSTRUCTOR
		//
		//=================================================================================
		
		/**
		 * Constructor is empty.
		 */
		public function Session()
		{
			
		}
		
		//---------------------------------------
		//
		//	VARIABLES
		//
		//---------------------------------------
		
		
		public static const USER_CREATION_COMPLETE:String = "userCreationComplete";
		
		public static const USER_CREATION_ERROR:String = "userCreationError";
		
		
		
		public static const ADMIN_USER:String = "admin";

		
		/**
		 * @private
		 */
		private var track:Boolean;
		
		/**
		 * @private
		 */
		private var trackSessionUser:String;
	

		
		//=================================================================================
		//
		//
		//
		//	USER
		//
		//
		//=================================================================================
		
		
		/**
		 * @private Represents a user.
		 */
		private var _user:UserData;
		
		public function get user():UserData
		{
			return _user;
		}
		
		/**
		 * Creates a new user with a given id.
		 */
		public function create_user(userid:String):void
		{
			if(_user!=null && _user.userName == userid)return;
			_user = new UserData();
			if(userid==ADMIN_USER)return;
			
			
			_user.prepare(
				Globals.instance().returnPathValue("rootUrl")+
				Globals.instance().returnPathValue("includeScript"), userid);
			_user.addEventListener(UserData.CREATION_ERROR, onUserCreationError);
			_user.addEventListener(UserData.CREATION_COMPLETE, onUserCreationComplete);
			_user.load();
		}
		
		
		
		/**
		 * @private
		 */
		protected function onUserCreationComplete(event:Event):void
		{
			dispatchEvent(new Event(USER_CREATION_COMPLETE));
		}
		
		/**
		 * @private
		 */
		protected function onUserCreationError(event:Event):void
		{
			dispatchEvent(new Event(USER_CREATION_ERROR));
		}		
		
		//=================================================================================
		//
		//
		//
		//	LEVELS / DIMENSIONS / ITEMS
		//
		//
		//=================================================================================
		
		
		/**
		 * Resets the session.
		 */
		public function reset():void
		{
			_dimension = -1;
			_item = null;
			_level = -1;
			_next = null;
			track=false;
		}
		
		//------------------------------------
		// Current Dimension
		//------------------------------------
		
		/**
		 * @private
		 */
		private var _dimension:int;
		
		/**
		 * the current dimension index (relative to the entries within the testcollection)
		 */
		public function get dimension():int
		{
			return _dimension;
		}
		
		//------------------------------------
		// Current LEVEL
		//------------------------------------
		
		/**
		 * @private
		 */
		private var _level:int;
		
		
		/**
		 * the current level index (relative to the entries within the testcollection)
		 */
		public function get level():int
		{
			return _level;
		}
		
		//------------------------------------
		// Current LEVEL
		//------------------------------------
		
		/**
		 * @private
		 */
		private var _item:String;

		/**
		 * the current item name (relative to the entries within the testcollection)
		 */
		public function get item():String
		{
			return _item;
		}
		
		//------------------------------------
		// Next ITEM
		//------------------------------------
		
		
		/**
		 * @private
		 */
		private var _next:String;
		
		/**
		 * the next item name (relative to the entries within the testcollection)
		 */
		public function get next():String
		{
			return _next;
		}
		
		
		//=================================================================================
		//
		//
		//
		//	UPDATE SESSION
		//
		//
		//=================================================================================
		

		/**
		 * updates the user session by replacing dimension, level and item
		 */
		public function updateSession(currentDimension:int,currentLevel:int,currentItem:String):void
		{
			
			//update dimension
			if(currentDimension>=0)
			{
				_dimension = currentDimension;
			}
			
			//update level
			if(currentLevel>=0)
			{
				_level = currentLevel;
			}
			
			//update item
			if(currentItem!=null && currentItem!= "")
			{
				_item = currentItem; 
			}
		}
		
		/**
		 * returns current session snapshot as an array of arrays which each contain a reference to the values user, item, dimension, level.
		 */
		public function returnAsArray():Array
		{
			var a:Array = new Array();
			var b:Array = new Array("user",user);
			var c:Array = new Array("item",item);
			var d:Array = new Array("dimension", dimension);
			var e:Array = new Array("level",level);
			
			a.push(b);
			a.push(c);
			a.push(d);
			a.push(e);
			return a;
		}
		
		//---------------------------------------
		//
		//	FOR TRACKING ONLY!
		//
		//---------------------------------------
		
		public function setTrackSessionUser(charLength:uint):void
		{
			if(!track)
			{
				trackSessionUser = StringUtils.createRandomWord(charLength);
				track = true;
			}
			trace("[Session]: set Track Session : "+trackSessionUser);
		}
		
		public function returnTrackSessionUser():String
		{
			return trackSessionUser;
		}

	}
}