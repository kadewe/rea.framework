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
package ItemApplication.question
{
	import components.ReaImage;
	import components.SelectableLabel;
	import components.SkinnedComponents.CustomTextInput;
	import components.SkinnedComponents.MiniSoundButton;
	import components.SkinnedComponents.SmallSoundButton;
	import components.factories.ComponentsFactory;
	
	import flash.events.MouseEvent;
	
	import interfaces.ICustomEventDispatcher;
	
	import models.Globals;
	
	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;
	
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.Label;
	
	import utils.HorizontalMultilineLayout;
	import utils.PulseList;
	import utils.ReaVisualUtils;

	/**
	 * Representing the loading, arranging and displaying data for a cloze text.
	 */
	public class Cloze extends QuestionsObject
	{

		private var editable:Boolean=false;
		
		private var selectables:Array;
		
		/**
		 * constructor, calls superclass.
		 * 
		 * @param _source see <code>QuestionsObject</code>
		 * @param scripturl see <code>QuestionsObject</code>
		 * @param relativeUrl see <code>QuestionsObject</code>
		 * 
		 * @see QuestionsObject
		 **/
		public function Cloze()
		{
			super();
		}
		
		override public function unload():void
		{
			if(qView)
			{
				qView.removeAllElements();
				qView = null;
			}
			
			
			for (var i:int = 0; i < references.length; i++) 
			{
				if(references[i] is ICustomEventDispatcher)
					ICustomEventDispatcher(references[i]).removeAllEventListeners();
				references[i] = null;
			}
			references = null;
		}
		
		/**
		 * loads the certain data and displays it in a way of a text with empty text areas and soundbuttons.
		 * <p>it uses the modified <code>HorizontalMultilineLayout</code> to arrange the elements in a row</p> 
		 * <p>the Text will be completely split up, so every single word as well as the input area is encapsulated by a <code>Group</code> and can be Designed with css properties.</p>
		 * 
		 * @param param the parameter indicates which questionpage is actually displayed
		 * 
		 * @see QuestionsObject
		 * @see Shared.HorizontalMultilineLayout
		 */
		override public function displayQuestions(param:Number):void
		{
			//call parent function display_q_text
			try
			{
				qView.content.addElement(display_q_text(param));
			} 
			catch(error:Error) 
			{
				trace("could not generate question_text");
			}


			var task:XMLList = source.questionpage[param].question;

			
			for(var i:uint=0;i<task.length();i++)
			{
				var answerText:XMLList = task[i].answertext;	//ITERATE ANSWERTEXT
				for(var j:uint=0;j<answerText.length();j++)
				{
					//Create Parent Group
					var hg:Group = new Group();
						hg.percentWidth=100;
					var flow:HorizontalMultilineLayout = new HorizontalMultilineLayout();
						flow.verticalAlign="middle";
						flow.verticalLayoutInLine = "middle";
						flow.lineHeightInPixel=28;
						flow.verticalGap=0;
					hg.layout= flow;
					
					//create answertext sound button 
					if(!ignoreSound && answerText[j].@sound.length() >0)
					{
						var _sndbtn:SmallSoundButton = ComponentsFactory.createSmallSoundButton(scriptUrl,relUrl+answerText[j].@sound,"answertextSound_"+answerText[j].@sound,"button_"+answerText[j].@sound,null) as SmallSoundButton;
						flow.lineHeightInPixel = _sndbtn.height;
						hg.addElement(_sndbtn);
						references.push(_sndbtn);			
						PulseList.addToList(_sndbtn);
					}else{
						flow.lineHeightInPixel = 40;	
					}
					
					var gap_text:XMLList = answerText[j].children();
					for(var k:uint=0;k<gap_text.length();k++)
					{
						var x:XML;
						var xname:String;
						try{
							x = gap_text[k];
							xname=x.name().toString();
						}catch(e:Error){continue;}
						//no xml errors? then build the stuff
						switch(xname)
						{
							case("a_text"):
								//Split String into words to ensure correct rendering
								var s:String = gap_text[k].children().toString();
								var a:ArrayCollection = new ArrayCollection(s.split(' '));
								for(var l:uint=0;l<a.length;l++)
								{
									var _txt:spark.components.Label = new spark.components.Label();
										_txt.text = a[l];  
										_txt.styleName= Globals.TEXT_STANDARD;
									hg.addElement(_txt);
									references.push(_txt);	
								}
								break;
							case("gap"):
								//--------------------------------// Create SoundButton and Text Input Field
								var pair:HGroup = new HGroup();
									pair.verticalAlign = "middle";
									pair.height=40;
								//mini sound button
								var gap:XML = gap_text[k];
								if(!ignoreSound && gap.@sound.length()>0)
								{
									var _snd:MiniSoundButton = ComponentsFactory.createMiniSoundButton(scriptUrl,relUrl+gap_text[k].@sound,"sound_"+gap_text[k].@sound,"button_"+gap_text[k].@sound,null) as MiniSoundButton;
									pair.addElement(_snd);
									references.push(_snd);
									PulseList.addToList(_snd);
								}
								
	
								
								var len:Number = gap_text[k].@length*28;
								if( len > 450)
								{
									len = 450;	//hotfix for long sentence labels
								}
								
								var _gap:CustomTextInput = ComponentsFactory.createCustomTextInput(
									gap_text[k].@answerid,
									len,
									answerExists(gap_text[k].@answerid)==true?getAnswerString(gap_text[k].@answerid):gap_text[k].children(),
									uint(gap_text[k].@length),
									gap_text[k].@style,
									true
								);
								
								//_gap.addEventListener(FlexEvent.CREATION_COMPLETE, onCustomTextinputComplete);
								PulseList.addToList(_gap);
								pair.addElement(_gap);
								hg.addElement(pair);
								references.push(_gap);
								break;
							case("media"):
								var im:ReaImage = new ReaImage(scriptUrl,relUrl+ gap_text[k].@file);
									im.addEventListener(FlexEvent.UPDATE_COMPLETE, onImageUpdate);
								hg.addElement(im);
								references.push(im);
								break;
							case("textchoices"):
								selectables = new Array();
								trace("textchoices found" + gap_text[k].children());
								var choices:XMLList = gap_text[k].children();
								var chGroup:HGroup = new HGroup();
								chGroup.horizontalAlign ="center";
								for(var m:uint=0;m<choices.length();m++)
								{
									
									var ch:String = choices[m].children().toString();
									var sl:SelectableLabel = new SelectableLabel(ch,"");
										sl.id = choices[m].@answerid;
										sl.selected = answerExists(sl.id)?getAnswerValue(sl.id):false;
										sl.addEventListener(MouseEvent.CLICK, onImageClick);
										sl.addEventListener(MouseEvent.MOUSE_OVER,onImageOver);
									selectables.push(sl);
									references.push(sl);
									chGroup.addElement(sl);
								}
								
								hg.addElement(chGroup);
								break;
							case("e_text"):
								editable=true;
								trace("E_TEXT FOUND");
								var edit:String = gap_text[k];
								trace(edit);
								var split:ArrayCollection = new ArrayCollection(edit.split(' '));
								var _ansId:String = gap_text[k].@answerid;
								trace(_ansId);
								for(var n:uint=0;n<split.length;n++)
								{
									var ei:CustomTextInput = new CustomTextInput();
										ei.text = answerExists(_ansId+n.toString())?getAnswerString(_ansId+n.toString()):" " + split[n];
									trace(ei.text);
										ei.id = "sub_"+n.toString()+"-"+_ansId;
										//ei.width = ei.text.length * 12;
									hg.addElement(ei);
									references.push(ei);
								}
								break;
							default:
								break;
						}
					}
					//vg.addElement(hg);
					//PulseList.addToList(hg);
					qView.content.addElement(hg);
				}
				
			}
			//qView.content.addElement(vg);
			display_navigation_buttons(param);
		}
		

		/**
		 * @private
		 * 
		 * by clicking an image it iterates all selectable images to determine, if an image should be surraounded by a color or not
		 */
		private function onImageClick(event:MouseEvent):void
		{
			var im:SelectableLabel = event.currentTarget as SelectableLabel;
			im.selected = im.selected?false:true;
			for(var i:uint=0;i<selectables.length;i++)
			{
				if(selectables[i]!=im)
				{
					selectables[i].selected=false;
				}
			}
		}
		
		/**
		 * @private 
		 * 
		 * calls the functions of an image to show the surrounded colored border to show users the status of being dragged 
		 */
		private function onImageOver(event:MouseEvent):void
		{
			var im:SelectableLabel = event.currentTarget as SelectableLabel;
				im.hovered=true;
				im.addEventListener(MouseEvent.MOUSE_OUT, onImageOut);
		}
		
		/**
		 * @private
		 * 
		 * remove colored border of a dragged image
		 */
		private function onImageOut(event:MouseEvent):void
		{
			var im:SelectableLabel = event.currentTarget as SelectableLabel;
				im.hovered=false;
				im.removeEventListener(MouseEvent.MOUSE_OUT, onImageOut);
		}	
		
		private function onImageUpdate(event:FlexEvent):void
		{
			var i:ReaImage = event.target as ReaImage;
			//resize Image
			utils.ReaVisualUtils.resizeImages(i,100,50);
		}
	}	
}