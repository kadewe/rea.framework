package Shared
{
	import flash.events.Event;

	/**
	 * An event class for passing session related values via event. Especially useful if you want to avoid to code this into an interface (and therefore into all other module classes).
	 */
	public class CustomModuleEvents extends Event
	{
		/**
		 * Declares the state of being ready to unload. Related to any module.
		 */
		public static const MODULE_FINISHED:String = "moduleFinished";
		
		//user related
		private var userDataUrl:String;
		private var timeStamp:String;
		
		//item related
		private var itemString:String;
		private var level:int;
		private var dimension:int;
		private var isNext:Boolean;
		private var updatedXml:XML;
		
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
		public function CustomModuleEvents(type:String,bubbles:Boolean,cancelable:Boolean,_userDataUrl:String=null,_itemString:String=null,_timeStamp:String=null,_level:int=-1,_dimension:int=-1,_isNext:Boolean=false,updated:XML=null)
		{
			super(type,bubbles,cancelable);
			userDataUrl = _userDataUrl;
			itemString = _itemString;
			timeStamp = _timeStamp;
			level=_level;
			dimension=_dimension;
			isNext = _isNext;
			updatedXml = updated;
		}
		
		public function get _userDataUrl():String
		{
			return userDataUrl;
		}
		
		public function get _itemString():String
		{
			return itemString;
		}
		
		public function get _timeStamp():String
		{
			return timeStamp;
		}
		
		public function get _level():int
		{
			return level;
		}
		
		public function get _dimension():int
		{
			return dimension;
		}
		
		public function get _isNext():Boolean
		{
			return isNext;
		}
		
		public function get _updatedXML():XML
		{
			return updatedXml;
		}
		
		override public function clone():Event
		{
			return new CustomModuleEvents(type,bubbles,cancelable,userDataUrl,itemString,timeStamp,level,dimension,isNext,updatedXml);
		}
		
	}
}