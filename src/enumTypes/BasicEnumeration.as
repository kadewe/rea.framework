package enumTypes
{
	/**
	 * Basic grid of an enumeration.
	 */
	public class BasicEnumeration
	{
		protected var value:String;
		protected var ordinal:uint;
		
		protected var _list:Array = new Array();
		
		/**
		 * Constructor.
		 */
		public function BasicEnumeration(newValue:String,newOrdinal:int)
		{
			this.value = newValue;
			this.ordinal = newOrdinal;
			_list.push(this);
		}

		/**
		 * Get the String value of an enum.
		 */
		public function getValue():String
		{
			return value;
		}
		
		/**
		 * Get the ordinal number of an enum-.
		 */
		public function getNumber():int
		{
			return ordinal;
		}
		
	}
}