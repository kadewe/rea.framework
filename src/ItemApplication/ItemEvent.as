package ItemApplication
{
	import flash.events.Event;

	/**
	 * Defines a set of events realted to the item object and its children. Also stores the result xml of the actual item, in order to pass it to other handlers.
	 */
	public class ItemEvent extends Event
	{
		public static const ITEM_ONLOAD:String = "itemOnload";
		public static const ITEM_FINISHED:String = "itemFinished";
		public static const DATA_SENT:String = "dataSent";
		public static const DATA_RECEIVED:String = "dataReceived";
		public static const QPAGE_LOADED:String = "qpageLoaded";
		public static const PAGE_CHANGED:String = "pageChanged";
		public static const QPAGE_FINISHED:String = "qpageFinished";
		
		private var dataObject:Object;
		
		
		/**
		 * constructor, calls superclass.
		 * 
		 * @param required: type the name of the event type, see the event constants
		 * 
		 * @param bubbles bubbles on or off
		 * @param cancelable cancelable on or off
		 * @param _dataObject the dataobject containing the finished item xml, ready to get sent to the server
		 */
		public function ItemEvent(type:String,bubbles:Boolean=false,cancelable:Boolean=false,_dataObject:Object=null)
		{
			super(type,bubbles,cancelable);
			dataObject = _dataObject;
		}
		
		public function get _dataObject():Object
		{
			return dataObject;
		}
		
		override public function clone():Event
		{
			return new ItemEvent(type,bubbles,cancelable,dataObject);
		}
		
		
	}
}