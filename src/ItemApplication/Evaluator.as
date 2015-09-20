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

package ItemApplication
{
	import ItemApplication.question.ItemTypes;
	
	import events.CustomEventDispatcher;
	
	import flash.events.Event;
	
	import interfaces.IDisposable;
	
	import utils.StringUtils;

	/**
	 * Strict Evaluation - each mark links to exactly ONE correct response and ONE answer
	 
	 for each itemnumber in markinglist
	 look in correct responselist for matching
	 if match
	 take answerid and get answervalue from answerslist
	 compare answervalue with correct responses (different options)
	 if match
	 return points for mark entry
	 
	 
	 Variable evaluation - 
	 
	 foreach itemnumber in markinglist
	 create new array of responses
	 look in correct responselist for matching
	 if match
	 push on array
	 
	 for each response in array
	 look at points
	 if points is 0.5
	 evaluation is score sum
	 take answerid and get answervalue from answerslist
	 compare answervalue with correct responses (different options)
	 add to score
	 if points is 1
	 evaluation is inclusive or
	 take answerid and get answervalue from answerslist
	 compare answervalue with correct responses (different options)
	 set flag if true
	 
	 when score sum
	 return point for mark entry if all responses have been answered correct
	 
	 when inclusive or
	 return point for markf if any entry is correct 
	 * 
	 * 
	 */
	public class Evaluator extends CustomEventDispatcher implements IDisposable
	{
		//-----------------------------------------------------------------------
		//
		//
		//
		//
		//	Variables
		//
		//
		//
		//-----------------------------------------------------------------------
		
		
		//SOURCES
		private var markingList:XMLList;
		private var itemCorrectResponseList:XMLList;
		private var answerList:XMLList;
		
		//LOGGING
		private var log:XML;
		private var logtmp:String;
		
		//FLAGS
		private var itemTYPE:String;
		private var debug:Boolean;
		
		//EVENTS
		/**
		 * Dispatched when the evaluation has been fully completed
		 */
		public static const EVALUTION_DONE:String = "evaluationDone";
		
		//-----------------------------------------------------------------------
		//
		//
		//
		//
		//	CONSTRUCTION
		//
		//
		//
		//-----------------------------------------------------------------------
		
		/**
		 * CONSTRUCTOR initializes class, optionally with debug options
		 */
		public function Evaluator(debugging:Boolean=false)
		{
			debug=debugging;
		}
		
		public function unload():void
		{
			
		}
		
		/**
		 * Passes XMLList structures and links them into the Evaluator.
		 * 
		 * @return boolean true if input values fulfill requirements false if not.
		 */
		public function init(markList:XMLList,correctResponseList:XMLList,answersList:XMLList, itemtype:String):Boolean
		{
			if( markList.length() < 1 ||
				correctResponseList.length() < 1 || 
				answersList.length() < 1 || 
				itemtype.length < 1)
			{
				if(debug)trace("[Evaluator]: incorrect input types");
				return false;
			}
			this.markingList = markList;
			this.itemCorrectResponseList = correctResponseList;
			this.answerList = answersList;
			this.itemTYPE = itemtype;
			
			log = new XML("<logs type='"+itemTYPE+"'></logs>");
			
			if(debug)
			{
				trace("[Evaluator]: init Evaluation with following parameters:");
				trace("[Evaluator]: marklist");
				trace(markingList.toXMLString());
				trace("[Evaluator]: correct responslist");
				trace(itemCorrectResponseList.toXMLString());
				trace("[Evaluator]: answersslist");
				trace(answersList.toXMLString());
				trace("[Evaluator]: itemtype "+itemtype);
			}
			return true;
		}
		
		/**
		 * Loads the evaluation
		 */
		public function load():void
		{
			for(var i:uint = 0;i<this.markingList.length();i++)
			{
				if(markingList[i].name()=="pointuse")continue;
				var mark:String;
				if(itemTYPE == ItemTypes.SINGLE_CHOICE || itemTYPE == ItemTypes.SINGLE_CHOICE_CLOUD)
				{
					//evaluate strict
					//trace("[Evaluator]: evaluate strict");
					mark = evaluate_strict(markingList[i]);
				}else{
					//evaluate variable
					//trace("[Evaluator]: evaluate variable");
					mark = evaluate_variable(markingList[i]);
				}
				//trace("[Evaluator]: mark: "+mark);
				markingList[i].setChildren(mark);
				
				try
				{
					var logxml:XML = XML(logtmp);
					if(logtmp.length>0)
						log.appendChild(logxml);
				}catch(e:Error){
					//trace("[Evaluator]: error at creating log-tmp file, pushing log-->"+logtmp);
				}
			}
			if(debug)
			{
				//trace("[Evaluator]: log-tmp:");
				//trace(log);	
			}
			
			dispatchEvent(new Event(EVALUTION_DONE));
		}
		
		
		public function loadSynchron():XMLList
		{
			//trace("[Evaluator]: start synchron");
			for(var i:uint = 0;i<this.markingList.length();i++)
			{
				if(markingList[i].name()=="pointuse")continue;
				var mark:String;
				if(itemTYPE == ItemTypes.SINGLE_CHOICE || itemTYPE == ItemTypes.SINGLE_CHOICE_CLOUD)
				{
					//evaluate strict
					//trace("[Evaluator]: evaluate strict");
					mark = evaluate_strict(markingList[i]);
						
				}else{
					//evaluate variable
					//trace("[Evaluator]: evaluate variable");
					mark = evaluate_variable(markingList[i]);
				}
				//trace("[Evaluator]: return mark: "+mark);
				markingList[i].setChildren(mark);
				//trace(markingList.toXMLString());
				try
				{
					var logxml:XML = XML(logtmp);
					if(logtmp.length>0)
						log.appendChild(logxml);
				}catch(e:Error){
					//trace("[Evaluator]: error at creating log-tmp file, pushing log-->"+logtmp);
				}
			}
			

			
			return markingList;
		}
		
		//-----------------------------------------------------------------------
		//
		//
		//
		//
		//	ACCESS
		//
		//
		//
		//-----------------------------------------------------------------------
		
		/**
		 * returns the completed marking list, including all entries for marking.
		 */
		public function returnMarkingList():XMLList
		{
			return markingList;
		}

		/**
		 * prints the internal evaluation log on the console
		 */
		public function traceTempLog():void
		{
			//trace(logtmp);
		}
		
		public function getTempLog():XML
		{
			return XML(logtmp);
		}
		
		public function getLog():XML
		{
			return log;
		}
		
		//-----------------------------------------------------------------------
		//
		//
		//
		//
		//	EVALUATION METHODS FOR ITEM TYPES
		//
		//
		//
		//-----------------------------------------------------------------------
		
		
		
		
		private function evaluate_strict(markelement:XML):String
		{
			if(debug)
			{
				//trace("EVALUATE STRICT");
				//trace(markelement.toXMLString());
			}
			
			//initial values and buffers
			var markentry:String="";
			var itNumber:String = markelement.@itemnumber;		
			if(markelement==null || itNumber.length == 0)
			{
				return "failed";
			}
				
			logtmp = "<entry>";
			logtmp+="<marking alphaid='"+markelement.@alphalevel+"' markid='"+itNumber+"' />";

			//get correct response item and write log
			var cr:XML = getCorrectResponseElement(itNumber);
			if(cr == null || cr.length()==0)
			{
				throw new Error("failed");
				return "failed";
			}
			logtmp += "<response>";
			
			//get answer value
			var answervalue:String = getAnswerValue(cr.@answerid);
			if(answervalue == "failed")
			{
				throw new Error("failed");
				return "failed";
			}
			
			logtmp+="<cr answer='"+ answervalue +"'  matchvalue='"+ cr.children() +"' matchtype='"+cr.@match+"' answerid='"+cr.@answerid+"' case='"+cr.@casesensitiv+"' matchlength='"+cr.@matchlength+"' points='"+cr.@points+"' ";
			
			
			//evaluate answer with correct response
			if(cr.@casesensitiv=="no")answervalue = answervalue.toLowerCase();
			markentry = evaluate_match_pattern(answervalue,cr);
			if(markentry.length == 0 || markentry == "failed")
			{
				throw new Error("failed");
				return "failed"
			}
			
			logtmp+=" result='"+markentry+"' />";
			logtmp+="</response>";
			logtmp+="<final mark='"+markentry+"' />";
			logtmp+="</entry>";
			return markentry;
		}
		
	
		private function evaluate_variable(markelement:XML):String
		{
			//init values and buffers
			var item_number:String = markelement.@itemnumber;
			var markentry:String="";
			var correct_responses:Array = getCorrectResponseArray(item_number);
			
			
			//check responses
			if(correct_responses.length == 0)
			{
				throw new Error("failed");
				return "failed";
			}
			logtmp = "<entry>";
			logtmp+="<marking alphaid='"+markelement.@alphalevel+"' markid='"+item_number+"' />";
			
			
			//switch evaluation type
			var uses_scoresum:Boolean = getVariableEvaluationType(correct_responses);
			var score_sum:Array=new Array();
			
			
			//go through correct responses
			logtmp+="<response len='"+correct_responses.length+"'>";
			for (var i:int=0;i< correct_responses.length;i++) 
			{
				//get answervalue
				var answervalue:String = getAnswerValue(correct_responses[i].@answerid);
				if(answervalue == "failed")
				{
					throw new Error("failed");
					return "failed";
				}
				logtmp+="<cr answer='"+ answervalue +"'  matchvalue='"+ correct_responses[i].children() +"' matchtype='"+correct_responses[i].@match+"' answerid='"+correct_responses[i].@answerid+"' case='"+correct_responses[i].@casesensitiv+"' matchlength='"+correct_responses[i].@matchlength+"' points='"+correct_responses[i].@points+"' ";
				
				//evaluate answer with corrct response by match pattern
				var markbuffer:String= evaluate_match_pattern(answervalue,correct_responses[i]);
				//push value to score summary
				score_sum.push(markbuffer);
				if(markbuffer.length == 0)
				{
					throw new Error("failed");
					return "failed";
				}
				logtmp+=" result='"+markbuffer+"' />";
			}
			logtmp+="</response>";
			
			//if scoresum is used
			if(uses_scoresum)
			{
				logtmp+="<scoresum_values>";
				//get score sum of all points related to an item
				var sum:Number = getScoreSum(score_sum);
				logtmp+="<sum value='"+sum+"' />";
				//trace("SCORESUM: "+sum+ " score.len " +score_sum.length);
				markentry = sum >= 1 ? "1" : "0";
				logtmp+="</scoresum_values>";
				//trace("scoresum")
				//trace(markelement.toXMLString());
				//trace(sum);
				//trace("end");
			}else{
				
				markentry = find_single_score(score_sum) ? "1" : "0";
			}
			logtmp+="<final mark='"+markentry+"' /></entry>";
			return markentry;
		}
		
		
		//-----------------------------------------------------------------------
		//
		//
		//
		//
		//	Helpers
		//
		//
		//
		//-----------------------------------------------------------------------
		
		private function getScoreSum(score:Array):Number
		{
			var count:Number=0;
			for(var i:int=0;i<score.length;i++)
			{
				logtmp+="<score value='"+score[i]+"' />";
				count+=Number(score[i]);
			}
			return count;
		}
		
		/**
		 * looks in array, if at least one value is score
		 */
		private function find_single_score(score:Array):Boolean
		{
			for(var i:int=0;i<score.length;i++)
			{
				if(Number(score[i]) == 1)
				{
					return true;
				}
			}
			return false;
		}
		 
		
		private function getVariableEvaluationType(allResp:Array):Boolean
		{
			var score:Boolean=false;
			for(var i:int=0;i<allResp.length;i++)
			{
				if(StringUtils.editDistance(allResp[i].@points,"0.5") == 0)
				{
					return true;
				}
			}
			return score;
		}
		
		private function getAnswerValue(answerid:String):String
		{
			if(debug)//trace("[Evaluator]:* compare "+answerid);
			for (var j:int = 0; j < answerList.length(); j++) 
			{
				if(StringUtils.editDistance(answerList[j].@answerid,answerid)==0)
				{
					return answerList[j].children();
				}
			}
			if(debug)trace("[Evaluator]:! no answerid match found");
			return "failed";
		}
		
		private function getCorrectResponseElement(itemNumber:String):XML
		{
			if(debug)//trace("[Evaluator]:* get correct response value for "+itemNumber);
			for (var j:int = 0; j < itemCorrectResponseList.length(); j++) 
			{
				if(StringUtils.editDistance(itemCorrectResponseList[j].@itemnumber,itemNumber)==0)
				{
					return itemCorrectResponseList[j];
				}
			}
			if(debug)trace("[Evaluator]:! no match found");
			return null;
		}
		
		private function getCorrectResponseArray(itemNumber:String):Array
		{
			var tmp:Array = new Array();
			for (var j:int = 0; j < itemCorrectResponseList.length(); j++) 
			{
				if(StringUtils.editDistance(itemCorrectResponseList[j].@itemnumber , itemNumber)==0)
				{
					tmp.push( itemCorrectResponseList[j] );
				}
			}
			return tmp;
		}
		
		
		private function evaluate_match_pattern(_answer:String,crlist:XML):String
		{
			var _matchString:String= crlist.children();
			if(crlist.@casesensitiv=="no")
			{
				_answer = _answer.toLowerCase();
				_matchString = _matchString.toLowerCase();
			}

			var whitespace:RegExp = /\s+/g;
			
			//trace("[Evaluator]: check "+ crlist.@itemnumber + " => "+_answer + " with "+ _matchString +" => "+crlist.@match.toString());
			switch(crlist.@match.toString())
			{
				case "full":
					//trim whitespace
					_answer = _answer.replace(whitespace,"");
					_matchString = _matchString.replace(whitespace,"");
					//just compare string 2 string
					//trace("[itemobject]: check full => " + _answer + " with " + _matchString);
					if(StringUtils.editDistance(_answer,_matchString)==0)
					{
						return crlist.@points.toString();
					}else{
						return "0";
					}
					break;
				case "first":
					//trim whitespace
					_answer = _answer.replace(whitespace,"");
					_matchString = _matchString.replace(whitespace,"");
					var sub_answer:String = _answer.slice(0,crlist.@matchlength);
					//trace("[itemobject]: check first => " + sub_answer + " with " + _matchString);
					if(StringUtils.editDistance(sub_answer,_matchString)==0)
					{
						return crlist.@points.toString();
					}else{
						return "0";
					}
					break;
				case "last":
					//trim whitespace
					_answer = _answer.replace(whitespace,"");
					_matchString = _matchString.replace(whitespace,"");
					//compare _answer.length-@matchlength till _answer.length
					var _sub_answer:String = _answer.slice(_answer.length- crlist.@matchlength,_answer.length);
					//trace("[itemobject]: check last => " + sub_answer + " with " + _matchString);
					if(StringUtils.editDistance(_sub_answer,_matchString)==0)
					{
						return crlist.@points.toString();
					}else{
						return "0";
					}
					break;
				case "levenshtein":
					
					//trim whitespace
					_answer = _answer.replace(whitespace,"");
					_matchString = _matchString.replace(whitespace,"");
					
					var lev:uint = utils.StringUtils.editDistance(_answer,_matchString);
					//trace("[ItemObject]: levenshtein function returns "+lev);
					if(lev <= uint(crlist.@matchlength))
					{
						return crlist.@points.toString();
					}else{
						return "0";
					}
					break;
				case "find_words":
					//trace("[Evaluator]: find word => "+_matchString + " => in => " +_answer +  " "+ uint(crlist.@matchlength));
					if(utils.StringUtils.findWords(_answer,_matchString,int(crlist.@matchlength)))
					{
						//trace("=> found, return "+ crlist.@points.toString());
						return crlist.@points.toString();
					}else{
						//trace("=> not found, return 0");
						return "0";
					}
					
					break;
				case "find_pattern":
					
					//trim whitespace
					_answer = _answer.replace(whitespace,"");
					_matchString = _matchString.replace(whitespace,"");
					

					
					//trace("[Evaluator]: find pattern => in => "+_matchString + " in " +_answer+" "+_matchString.indexOf(_answer)+" "+matches.length);
					if(utils.StringUtils.checkStringPattern(_answer,_matchString))
					{
						//trace("=> found, return "+ crlist.@points.toString());
						return crlist.@points.toString();
					}else{
						//trace("=> not found, return 0");
						return "0";
					}
					
					break;
			}
			return "failed";
		}
		

		
	}
}