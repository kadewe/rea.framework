package MainApplication
{
	/**
	 * A static class, representing a sequence to arrange the required modules in a predefined order.
	 */
	public class LoaderManagement
	{
		private static var sequence:Array = 
		[
			"MainApplication.StartAppObject",
			"MainApplication.LoginObject",
			"MainApplication.OverviewObject",
			"ItemApplication.ItemObject",
			"MainApplication.TestFinishedObject"
		];
	
		private static var tutorial:String = "ItemApplication.TutorialObject";
		
		/**
		 * Iterates a sequence of module class names and tries to find matches.
		 * 
		 * @return Returns a String-Name of the Class definition, which makes the module accessable via getClassByDefinition.
		 * 
		 * @param moduleName the name of the current module to match with the sequence
		 * @param nextitem is a parameter which indeicated, that there is still an item in the load queue
		 */
		public static function getNext2Load(moduleName:String,nextItem:String):String
		{
			if(nextItem!=null) // as long as there is a next item in the queue, we load a new itemObject
			{
				
				return nextItem.charAt(0)=="t"?tutorial:"ItemApplication.ItemObject";
			}
			for(var i:uint=0;i<sequence.length;i++) // else we iterate the sequence
			{
				if(sequence[i]==moduleName)			//if the modulename fits the current...
				{
					if(i!= sequence.length-1)		//...and its not tha last in the sequence...
					{
						return sequence[i+1];		//...load it or...
					}else{
						return 	"MainApplication.OverviewObject";	//its the last and we go back to overview
					}
				}
			}
			return "";
		}
	}
}