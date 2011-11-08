package Shared
{
	import flash.events.Event;

	
	/**
	 * Custom Event class allows some modules to pass specific data back to the  mainappmanager.
	 */
	public class UserEvent extends Event
	{
		public static const SUBJ_AND_LEVEL_CHOSEN:String = "subjandlevelchosen";
		public static const ITEM_FINISHED:String = "itemFinished";
		public static const USERDATA_RECEIVED:String = "userDataReceived";
		public static const NEWTEST_CHOSEN:String = "newTestChosen";
		public static const ENDTEST_CHOSEN:String = "endTestChosen";
		public static const START_APPLICATION:String = "startApplication";
		
		private var subject:String;
		private var level:String;
		private var userData:String;
		
		/**
		 * constructor, sets the variables.
		 * 
		 * @param	type		see flash.events.Event
		 * @param	bubbles		see flash.events.Event
		 * @param	cancelable	see flash.events.Event
		 * @param	_subject	the actual subject the user has chosen
		 * @param	_level		the actual level the user has chosen
		 * @param	_user		the users id
		 * 
		 * @see flash.events.Event
		 */
		public function UserEvent(type:String,bubbles:Boolean,cancelable:Boolean,_subject:String=null,_level:String=null,_user:String=null)
		{
			super(type,bubbles,cancelable);
			subject = _subject;
			level = _level;
			userData = _user;
		}
		
		public function get _subject():String
		{
			return subject;
		}
		
		public function get _level():String
		{
			return level;
		}
		
		public function get _userData():String
		{
			return userData;
		}

		/**
		 * @override
		 */
		override public function clone():Event
		{
			return new UserEvent(type,bubbles,cancelable,subject,level,userData);
		}
		
	}
}