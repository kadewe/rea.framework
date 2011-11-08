package enumTypes
{
	/**
	 * Enumeration of error types to indicate the number and the type of the error.
	 */
	public class ErrorTypeEnum extends BasicEnumeration
	{
		
		public static const CANNOT_PLAY_AUDIO_ERROR:ErrorTypeEnum = new ErrorTypeEnum("Audio error, cannot play Audiofile. Eitehr invalid format or null.",0);
		
		public static const URL_INVALID_ERROR:ErrorTypeEnum = new ErrorTypeEnum("The requested URL is invalid or null.",1);
		
		public static const CANNOT_LOAD_MODULE:ErrorTypeEnum = new ErrorTypeEnum("the moduleclass is not recognized or null.",2);
		
		public static const NULLREFERENCE:ErrorTypeEnum = new ErrorTypeEnum("an object is null",3);
		
		/**
		 * Constructor.
		 */
		public function ErrorTypeEnum(newValue:String, newOrdinal:int)
		{
			super(newValue, newOrdinal);
		}
		
		/**
		 * returns an array with all enums.
		 */
		public static function get list():Array
		{
			return [CANNOT_PLAY_AUDIO_ERROR,URL_INVALID_ERROR];
		}
		
		/**
		 * looks for an enumeration by a passed string value. Returns null of not found.
		 */
		public static function selectByValue(value:String):ErrorTypeEnum
		{
			for each(var e:ErrorTypeEnum in list)
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