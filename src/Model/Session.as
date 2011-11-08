package Model
{
	import Interfaces.ICustomEventDispatcher;
	
	import Shared.EventDispatcher;

	/**
	 * This is a Data Structure, where each session for one item is stored. In detail, it stores the slected dimension, level and item. This ensures, that application always knows, where the user is at the moment.
	 */
	public class Session extends Shared.EventDispatcher implements ICustomEventDispatcher
	{
		public function Session()
		{
			super();
			_dimension = -1;
			_item = null;
			_level = -1;
			_next = null;
		}
		
		//---------------------------------//
		// 	Current Dimension
		//---------------------------------//
		
		private var _dimension:int;
		
		public function get dimension():int
		{
			return _dimension;
		}
		
		//---------------------------------//
		// 	Current Item
		//---------------------------------//
		
		private var _item:String;
		
		public function get item():String
		{
			return _item;
		}
		
		//---------------------------------//
		// 	Next Item
		//---------------------------------//
		
		private var _next:String;
		
		public function get next():String
		{
			return _next;
		}
		
		//---------------------------------//
		// Current Level
		//---------------------------------//
		
		private var _level:int;
		
		public function get level():int
		{
			return _level;
		}
		
		public function updateSession(currentDimension:int,currentLevel:int,currentItem:String):void
		{
			trace("[SESSION]: update dimension: "+currentDimension+" level: "+currentLevel+" item: "+currentItem);
			if(currentDimension>=0)
			{
				_dimension = currentDimension;
			}
			if(currentLevel>=0)
			{
				_level = currentLevel;
			}
			if(currentItem!=null && currentItem!= "")
			{
				_item = currentItem; 
			}
		}
	}
}