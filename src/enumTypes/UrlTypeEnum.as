package enumTypes
{
	/**
	 * Collection of enumeration ids, to access globals parameters. They are hardcoded, so changes in this file will require changes in the globals file and vice versa.
	 */
	public class UrlTypeEnum extends BasicEnumeration
	{
		/**
		 * Represents the root url on the server. It must be a realtive path to the root directory of this application and will be combined with other paths to load specific data or scripts
		 * 
		 * <p>Example: <code>http://mydomain.subdomain.com/apps/thisapp/</code></p>
		 */
		public static const ROOT:UrlTypeEnum = new UrlTypeEnum("rootUrl",0);
		
		/**
		 * The relative path to the includescript. Must be combined with ROOT to a full usable url
		 */
		public static const INCLUDE_SCRIPT:UrlTypeEnum = new UrlTypeEnum("includeScript",1);
		
		/**
		 * The relative path to the application sounds on the serve. Does not include item sounds. Must be combined with ROOT. 
		 */
		public static const SOUNDS:UrlTypeEnum = new UrlTypeEnum("soundPath",2);
		
		/**
		 * The relative path to the userData directories. Must be combined with ROOT.
		 */
		public static const USER:UrlTypeEnum = new UrlTypeEnum("userPath",3);
		
		/**
		 * The relative path to the itemData directories. Must be combined with ROOT. 
		 */
		public static const ITEM:UrlTypeEnum = new UrlTypeEnum("itemsPath",4);
	
		
		
		/**
		 * Constructor.
		 * 
		 * @param newValue the string value, represented by the enumeration.
		 * @param newOrdinal the position in the sequence of the enumeration.
		 */
		public function UrlTypeEnum(newValue:String,newOrdinal:int)
		{
			super(newValue,newOrdinal);
		}
		
		/**
		* returns an array with all enums.
		*/
		public static function get list():Array
		{
			return [ROOT,INCLUDE_SCRIPT,SOUNDS,USER,ITEM];
		}
		
		/**
		 * looks for an enumeration by a passed string value. Returns null of not found.
		 */
		public static function selectByValue(value:String):UrlTypeEnum
		{
			for each(var e:UrlTypeEnum in list)
			{
				if(value == e.value)
				{
					return e;
				}
			}
			return null;
		}
	}
}