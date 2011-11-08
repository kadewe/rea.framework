package Model
{
	/**
	 * A class representing one testcollection of a dimension / subject. 
	 * 
	 */
	public class Collection
	{
		private var name:String;
		private var description:String;
		private var soundUrl:String;
		
		private var items:Array;
		
		/**
		 * Constructor.
		 * 
		 * @param _name the name of the difficulty level
		 * @param des description of this collection and level
		 * @soundurl url to the sound file, related with the description text
		 */
		public function Collection(_name:String,des:String,soundurl:String)
		{
			items=new Array();
			name=_name;
			description=des;
			soundUrl=soundurl;
		}
		
		/**
		 * adds an xmllist of items and excerps the itemnumbers. Stored in a common array.
		 */
		public function addItems(_items:XMLList):void
		{
			for(var i:uint=0;i<_items.length();i++)
			{
				items.push(_items[i].@iname);
			}
		}
		
		/**
		 * returns the array of items
		 */
		public function returnItems():Array
		{
			return items;
		}
		
		/**
		 * reuturns an itemnumber at a specific index. Usefull if you desire the nth-item of the collection.
		 */
		public function returnItemAt(index:int):String
		{
			return items[index];
		}
		
		/**
		 * returns the level of the collection
		 */
		public function getName():String
		{
			return name;
		}
		
		/**
		 * returns the description text of this collection
		 */
		public function getDescription():String
		{
			return description;
		}
		
		/**
		 * reutrns the soundurl of this collection
		 */
		public function getSound():String
		{
			return soundUrl;
		}
	}
}