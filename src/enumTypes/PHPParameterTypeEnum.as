package enumTypes
{
	/**
	 * Collection of enumeration ids, to access php parameters. They are hardcoded, so changes in this file will require changes in the include php file and vice versa.
	 */
	public class PHPParameterTypeEnum extends BasicEnumeration
	{
		/**
		 * The parameter name to access the loginScript in the php include file.
		 */
		public static const LOGIN:PHPParameterTypeEnum = new PHPParameterTypeEnum("login",0);
		
		/**
		 * The parametername to access the getUser script in the php include file.
		 */
		public static const GET_USERDATA:PHPParameterTypeEnum = new PHPParameterTypeEnum("getUser",1);
		
		/**
		 * The parametername to access the getImage script in the php include file.
		 */
		public static const GET_IMAGE:PHPParameterTypeEnum = new PHPParameterTypeEnum("getImage",2);
		
		/**
		 * The parametername to access the getAudio script in the php include file.
		 */
		public static const GET_AUDIO:PHPParameterTypeEnum = new PHPParameterTypeEnum("getAudio",3);
		
		/**
		 * The parametername to access the newUser script in the php include file.
		 */
		public static const CREATE_NEW_USER:PHPParameterTypeEnum = new PHPParameterTypeEnum("newUser",4);
		
		/**
		 * The parametername to access the updateUser script in the php include file.
		 */
		public static const UPDATE_USER:PHPParameterTypeEnum = new PHPParameterTypeEnum("updateUser",5);
		
		/**
		 * The parametername to access the sendFinalXml script in the php include file.
		 */
		public static const SEND_FINAL_XML:PHPParameterTypeEnum = new PHPParameterTypeEnum("sendFinalXml",6);
		
		/**
		 * The parametername to access the getItem script in the php include file.
		 */
		public static const GET_ITEM_DATA:PHPParameterTypeEnum = new PHPParameterTypeEnum("getItem",7);
		
		/**
		 * The parametername to access the sendError script in the php include file.
		 */
		public static const SEND_ERROR_MESSAGE:PHPParameterTypeEnum = new PHPParameterTypeEnum("sendError",8);
		
		/**
		 * The parametername to access the getVideo script in the php include file.
		 */
		public static const GET_VIDEO:PHPParameterTypeEnum = new PHPParameterTypeEnum("getVideo",9);
		
		/**
		 * Constructor. See extended class.
		 */
		public function PHPParameterTypeEnum(newValue:String, newOrdinal:int)
		{
			super(newValue, newOrdinal);
		}
		
		/**
		 * returns an array with all enums.
		 */
		public static function get list():Array
		{
			return [LOGIN,GET_USERDATA,GET_IMAGE,GET_AUDIO,CREATE_NEW_USER,UPDATE_USER,SEND_FINAL_XML,GET_ITEM_DATA];
		}
		
		/**
		 * looks for an enumeration by a passed string value. Returns null of not found.
		 */
		public static function selectByValue(value:String):PHPParameterTypeEnum
		{
			for each(var e:PHPParameterTypeEnum in list)
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