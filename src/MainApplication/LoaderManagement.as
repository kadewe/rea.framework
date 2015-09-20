/*

"Rich E-Assesment (REA) Framework"
A software framework for the use within the domain of e-assessment.

Copyright (C) 2014  University of Bremen, 
Working Group education media | media education 

Prof. Dr. Karsten Wolf, wolf@uni-bremen.de
Dipl.-Päd. Ilka Koppel, ikoppel@uni-bremen.de
Dipl.-Math. Kai Schwedes, kais@zait.uni-bremen.de
B.Sc. Jan Küster, jank87@tzi.de

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/
package MainApplication
{
	/**
	 * A static class, representing a sequence to arrange the required modules in a predefined order.
	 */
	public class LoaderManagement
	{
		//---------------------------------------
		//
		//	VARIABLES
		//
		//---------------------------------------
		
		private static var sequence:Array = 
		[
			startApp,
			"LoginModule",
			"OverviewModule",
			"ItemModule",
			"TestFinishedModule"
		];
	
		private static var startApp:String = "StartAppModule";
		private static var tutorial:String = "TutorialObject";
		private static var adminArea:String ="AdminObject";

		//---------------------------------------
		//
		//	PUBLIC FUNCTIONS
		//
		//---------------------------------------
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
			trace("load manager: "+moduleName+" "+nextItem);
			if(nextItem == "admin")
			{
				return adminArea;
			}
			if(nextItem!=null) // as long as there is a next item in the queue, we load a new itemObject
			{
				trace("LoaderManagement: "+nextItem);
				return nextItem.charAt(0)=="t"?tutorial:"ItemModule";
			}
			for(var i:uint=0;i<sequence.length;i++) // else we iterate the sequence
			{
				if(sequence[i]==moduleName)			//if the modulename fits the current...
				{
					if(i!= sequence.length-1)		//...and its not tha last in the sequence...
					{
						return sequence[i+1];		//...load it or...
					}else{
						return 	"OverviewModule";	//its the last and we go back to overview
					}
				}
			}
			return "";
		}
	}
}