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
package components.factories
{
	import components.ReaButton;
	
	import models.Globals;
	
	import views.EvaluationView;
	import views.HelpView;

	public class DisplayFactory
	{
		
		
		/**
		 * Creates a new HelpView.
		 */
		public static function helpDisplay(className:String,currentView:String, stop_vid_ref:ReaButton=null):HelpView
		{
			var help:HelpView = new HelpView();			
			return help;
		}
		
		
		/**
		 * Returns a new EvaluationView.
		 * 
		 * @param userid The user to evaluate
		 * @param dimension the dimension of evaluation
		 * @param scriptUrl the include script
		 * @param progress the current progress of the testcolleciton 
		 */
		public static function evaluationDisplay(userid:String, dimension:String, scriptUrl:String,progress:Number=100):EvaluationView
		{

			var ev:EvaluationView = new EvaluationView();
				ev.load(
				dimension,
				scriptUrl,
				userid,
				Globals.instance().returnPathValue("feedbackSounds"),
				progress
				);
			return ev;
		}
	}
}