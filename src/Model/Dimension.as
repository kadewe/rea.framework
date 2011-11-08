package Model
{
	/**
	 * This class represents a dimension or subject with all its included data.
	 */
	public class Dimension
	{
		private var name:String;
		private var description:String;
		private var soundUrl:String;
		
		private var collectionList:Array;
		
		/**
		 * Constructor
		 */
		public function Dimension(_name:String,des:String,url:String)
		{
			collectionList=new Array();
			name=_name;
			description=des;
			soundUrl=url;
		}
		
		
		/**
		 * adds an xmllist to the collection list. usually a collection is stored as an xml file, so it can be decoded by itering an xmllis.
		 */
		public function addToCollectionList(e:XMLList):void
		{
			collectionList.push(e);
		}
		
		/**
		 * adds a collection object to the collection list. useful if once the collection is created out of an xmllist.
		 */
		public function addCollectionToList(c:Collection):void
		{
			collectionList.push(c);
		}
		
		/**
		 * returns the entire collectionList as an array
		 */
		public function returnCollection():Array
		{
			return collectionList;
		}
		
		/**
		 * returns a specific collection by passing an index number as parameter.
		 * 
		 * @param index the index of the desired collection
		 * @return Collection Object (level)
		 */
		public function returnCollectionAt(index:int):Collection
		{
			return collectionList[index];
		}
		
		/**
		 * returns the name of this dimension 
		 */
		public function getName():String
		{
			return name;
		}
		
		/**
		 * returns the description of this dimension
		 */
		public function getDescription():String
		{
			return description;
		}
		
		/**
		 * returns the soundurl of this dimension
		 */
		public function getSoundUrl():String
		{
			return soundUrl;
		}
	}
}