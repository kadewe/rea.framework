package Shared
{
	import flash.events.Event;

	public class ItemEvent extends Event
	{
		//-------------------------------------------------
		
		//	ITEM EVENT NAMES
		
		//-------------------------------------------------
		public static const START_ITEM:String = "startItem";
		public static const ITEM_PLUS:String  = "itemPlus";
		public static const QPAGE_FORWARD:String = "qpageForward";
		public static const QPAGE_BACK:String = "qpageBack";
		public static const WRITE_DATA:String = "writeData";
		public static const ITEM_FINISHED:String = "itemFinished";
		
		
		//-------------------------------------------------
		
		//	ITEM EVENT VARIABLES
		
		//-------------------------------------------------
		public var currentItem:String;
		public var nextItem:String;
		public var timeStamp:String;
		
		public function ItemEvent(type:String,bubbles:Boolean,cancelable:Boolean,_current:String=null,_next:String=null,_time:String=null)
		{
			super(type,bubbles,cancelable);
			currentItem = _current;
			nextItem = _next;
			timeStamp = _time;
		}
		
		public function get _currentItem():Object
		{
			return currentItem;
		}
		
		public function get _nextitem():String
		{
			return nextItem;
		}
		
		public function get _timeStamp():String
		{
			return timeStamp;
		}
		
		override public function clone():Event
		{
			return new CustomModuleEvents(type,bubbles,cancelable,currentItem,nextItem,timeStamp);
		}
	}
}