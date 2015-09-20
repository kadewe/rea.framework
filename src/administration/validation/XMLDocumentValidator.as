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
package administration.validation
{
	import events.CustomEventDispatcher;
	
	import interfaces.ICustomEventDispatcher;
	
	
	import flash.events.IEventDispatcher;
	
	import mx.utils.ArrayUtil;
	
	public class XMLDocumentValidator extends CustomEventDispatcher implements ICustomEventDispatcher
	{
		public function XMLDocumentValidator(target:IEventDispatcher=null)
		{
			super(target);
		}

		
		public static function validate_id_linking(xml:XML):Boolean
		{
			//trace("*********************************");
			//trace("[XMLValidation]: start validation - "+xml.itemnumber.children());
			//pre conditions
			
			var i:uint;
			var j:uint;
			
			//---------------------- PHASE I --------------------//
			/*
			
			
				- no id-doubles in questions and answers (both strict) 
				- every question id is in answers and vice versa
			
			
			*/
			//--------------------------------------------------//
			//trace("[XMLValidation]: start PHASE I");
			
			//	1.create questions answer ids list and check for doubles
			var questions_answerids:Array = get_all_questions_ids(xml.questions.children(),[]);
			if(ValidationUtils.hasnodoubleEntries(questions_answerids,"question_answerids")==false)
			{
				//trace("[XMLValidation]: error! <questions> contains a doubled answerid!");
				return false
			}
			//trace("[XMLValidation]: test 1 passed - questions extracted and no double entries!");
			
			//	2.create answer answer ids list and check for doubles
			var answers_source:XMLList = xml.answers.children();
			var answers_answerids:Array = new Array(answers_source.length());
			
			for(i=0;i<answers_source.length();i++)
			{
				try
				{
					answers_answerids[i] = answers_source[i].@answerid;	
				} 
				catch(error:Error) 
				{
					//trace("[XMLValidation]: error while extracting answerids from <answers> at position "+i);
					return false;
				}
			}
			if(ValidationUtils.hasnodoubleEntries(answers_answerids,"answers_answerids") == false)
			{
				//trace("[XMLValidation]: error! <answers> contains a doubled answerid!");
				return false;
			}
			//trace("[XMLValidation]: test 2 passed - answers extracted and no double entries!");
			
			//	3. check if question_answers and answer_answers are equal and their entries are linked
			if(questions_answerids.length != answers_answerids.length)
			{
				//trace("[XMLValidation]: uncorrect length match of answerids --> "+questions_answerids.length + "(q_ids) and "+answers_answerids.length + "(a_ids)");
				return false;
			}
			if(!ValidationUtils.arrays_have_same_entries(questions_answerids,answers_answerids))
			{
				//trace("[XMLValidation]: id mismatch between <questions>-answerids and <answers>-answerids");	
			}
			//trace("[XMLValidation]: test 3 passed - answers match");
			
			//---------------- PHASE I PASSED! -------------------//
			//trace("[XMLValidation]: PHASE I passed! All questions have a unique answerid which is linked correctly to <answers> section! No doubles in <questions> or <answers>");
			
			
			//---------------------- PHASE II --------------------//
			/*
			
			
			- correct response - itemnumber entries are not doubled
			- every correct response - answerid is in <answers>
			
			
			*/
			//--------------------------------------------------//
			//trace("[XMLValidation]: start PHASE II");
			
			// 4. create correct response lists and check marking sublist for doubles
			var corresp_source:XMLList = xml.correctResponse.children();
			var cr_ans:Array = new Array(corresp_source.length());
			var cr_mark:Array = new Array(corresp_source.length());
			
			for(i=0;i<corresp_source.length();i++)
			{
				try
				{
					cr_ans[i] = corresp_source[i].@answerid;
					cr_mark[i] = corresp_source[i].@itemnumber;
				} 
				catch(error:Error) 
				{
					//trace("[XMLValidation]: error while extracting values from <correctresponse> at position "+i);
					return false;
				}
			}
			if(ValidationUtils.hasnodoubleEntries(cr_mark,"correct response marklist (itemnumbers)") == false)
			{
				//trace("[XMLValidation]: warning! correctresponse-itemnumbers contain a doubled answerid! This can mean, two correct answers link to the same marking.");
				//no return;
				if(ValidationUtils.hasnoDoubleEntriesWithLinking(cr_mark, cr_ans,"correct response itemids", "correct response answerids") == false)
				{
					//trace("[XMLValidation]: linkging mismatch between <correctresponse>-itemid and <correctresponse>-answerid, this seems a serious mistake");
					return false;
				}
			}
			if(ValidationUtils.hasnodoubleEntries(cr_ans,"correct response answerlist (answerids)") == false)
			{
				//trace("[XMLValidation]: warning! correctresponse-answers contain a doubled answerid which needs to be checked manually since this might be an intended entry!");
				//no return!
				if(ValidationUtils.hasnoDoubleEntriesWithLinking(cr_mark, cr_ans,"correct response itemids", "correct response answerids") == false)
				{
					//trace("[XMLValidation]: linkging mismatch between <correctresponse>-itemid and <correctresponse>-answerid");
					return false;
				}
			}
			//trace("[XMLValidation]: test 4 passed - arrays created and no doubles");
			
		
			
			//	5.correct response are corectly linked to <answers>
			if(ValidationUtils.arrays_have_same_entries(cr_ans,answers_answerids) == false)
			{
				//trace("[XMLValidation]: id mismatch between <correctresponse>-answerids and <answers>-answerids");
				return false;
			}
			//trace("[XMLValidation]: test 5 passed - linkings cr and answers correct");
			
			//---------------- PHASE II PASSED! -------------------//
			//trace("[XMLValidation]: PHASE II passed! All correct responses have a unique answerid which is linked correctly to <answers> section! No doubles in <correctresponse>-itemnumbers (link to marking)");
			
			
			//---------------------- PHASE III --------------------//
			/*
			
			
			- all correct response have exactly one link to <marking>
			- no doubles in abilities
			- no mark links to an ability twice (while vice versa is allowed)
			
			*/
			//--------------------------------------------------//
			//trace("[XMLValidation]: start PHASE III");
			
			
		//	6. create marking arrays
			var marksource:XMLList = xml.marking.children();
			var marking_ids:Array = new Array(marksource.length()-1);
			var marking_alphas:Array = new Array(marksource.length()-1);
			
			for(i=1;i<marksource.length();i++)
			{
				try
				{
					marking_ids[i] = marksource[i].@itemnumber;
					marking_alphas[i] = marksource[i].@alphalevel;
				} 
				catch(error:Error) 
				{
					//trace("[XMLValidation]: error while extracting values from <marking> at position "+i);
					return false;
				}
			}
			if(ValidationUtils.hasnodoubleEntries(marking_ids,"marking ids")==false)
			{
				//trace("[XMLValidation]: warning! <marking>-itemids contains a doubled id!");
				//no return
			}
			//trace("[XMLValidation]: test 6 passed - marking created and no doubled");
			
		//	7. create alpha array and check for no-doubles
			var alphas:XMLList = xml.abilities.children();
			var alpha_list:Array = new Array(alphas.length());
			
			for(i=0;i<alphas.length();i++)
			{
				try
				{
					alpha_list[i] = alphas[i].@alphalevel
				} 
				catch(error:Error) 
				{
					//trace("[XMLValidation]: error while extracting values from <abilities> at position "+i);
					return false;
				}
			}
			if(ValidationUtils.hasnodoubleEntries(alpha_list,"alpha ids")==false)
			{
				//trace("[XMLValidation]: error! <abilities>-alphaids contains a doubled id!");
				return false;
			}
			//trace("[XMLValidation]: test 7 passed - marking created and no doubled");
			
		//	8.all correct response have exactly one link to <marking>
			if(ValidationUtils.arrays_have_same_entries(cr_mark,marking_ids) == false)
			{
				//trace("[XMLValidation]: id mismatch between <correctresponse>-itemids and <marking>-itemids");
				return false;
			}
			//trace("[XMLValidation]: test 8 passed - marking and cr match");
			
		//	9. marking links to abilities not more than once
			if(ValidationUtils.hasnoDoubleEntriesWithLinking(marking_ids, marking_alphas,"marking ids", "alpha ids") == false)
			{
				//trace("[XMLValidation]: linkging mismatch between <marking>-aphaid and <marking>-alphaids");
				return false;
			}
			//trace("[XMLValidation]: test 9 passed - marking and abilities match");
			
			//---------------- PHASE III PASSED! -------------------//
			//trace("[XMLValidation]: PHASE III passed! All id linkings are correct");
			
			//trace();
			return true;
		}
		
		
		public static function get_all_questions_ids(list:XMLList,ids:Array):Array
		{
			var answerids:Array = new Array();
			for(var i:uint = 0;i<list.length();i++)
			{
				if(list[i].@answerid.length()>0)
				{
					answerids.push(list[i].@answerid);
				}
				if(list[i].children().length()>0)
				{
					var tmp:Array = get_all_questions_ids(list[i].children(),answerids);
					answerids = answerids.concat(tmp);
				}
			}
			
			return answerids;
		}
		
	}
}