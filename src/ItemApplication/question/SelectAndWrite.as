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
	import components.SelectableImage;
	import components.SkinnedComponents.CustomTextInput;
	
	import flash.events.MouseEvent;
	
	import interfaces.ICustomEventDispatcher;
	
	import mx.core.IVisualElement;
	
	import spark.components.HGroup;
	import spark.components.VGroup;
	
	import utils.PulseList;

	/**
	 * Represents the process of loading, arrangin and displaying data for a selection of images and a textarea.
	 */
	public class SelectAndWrite extends QuestionsObject
	{
		/**
		 * Constructor, calls superclass.
		 * 
		 * @param _source the xmllist source file
		 * @param scripturl path to the php script for loading images, mp3 and other data
		 * @param relativeUrl the equivalent to rooturl  
		 */
		public function SelectAndWrite()
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
		
		
		private var selectables:Array;
		private var gapRef:CustomTextInput;
		
		/**
		 * loads all required data, according to a specific questionspage.
		 * <p>Builds questions instruction first</p>
		 * <p>loads images and arranges them in a rectangle shaped group of four images</p>
		 * <p>creates a textinput area next to the images group</p>
		 */
		override public function displayQuestions(param:Number):void
		{
			//---------------------------------// Q_TEXT
			try
			{
				qView.content.addElement(display_q_text(param));
			} 
			catch(error:Error) 
			{
				trace("could not generate question_text");
				
			}
			
			//---------------------------------// QUESTIONPAGE CONTENT
			selectables=new Array();
			var contentGroup:HGroup = new HGroup();
				contentGroup.gap = 50;
				contentGroup.horizontalAlign = "center";
				contentGroup.verticalAlign = "middle";
			var imgGroup:VGroup = new VGroup();
			var task:XMLList = source.questionpage[param].question; //---------------------------------// the part of the array which is important for the several qpage
			for(var i:uint=0;i<task.length();i++)
			{
				//---------------------------------// ANSWERTEXt
				//call parents method for answertext
				try
				{
					qView.content.addElement(display_answer_text(task,i));
				} 
				catch(error:Error) 
				{
					trace("could not generate answer_text");
				}
				var choices:XMLList = task[i].choices.children();
				var top:HGroup=new HGroup();
				var bottom:HGroup=new HGroup();
				trace("[Select AND write]: number of images: "+choices.length());
				for(var j:uint=0;j<choices.length();j++)
				{
					trace("[Select AND write]: load Image => "+relUrl + choices[j].@img);
					var im:SelectableImage = new SelectableImage(scriptUrl,relUrl + choices[j].@img);
						im.id = choices[j].@answerid;
						im.selected = answerExists(im.id)?getAnswerValue(im.id):false;
						im.addEventListener(MouseEvent.CLICK, onImageClick);
					
					selectables.push(im);
					references.push(im);
					//---------------------------------// display as a tetra-square
					if((j+1)%2==0)
					{
						top.addElement(im as IVisualElement);
					}else{
						bottom.addElement(im as IVisualElement);
					}
				}
				imgGroup.addElement(top);
				imgGroup.addElement(bottom);
			}
			//---------------------------------// GAP
			var gap:CustomTextInput = new CustomTextInput();
				gapRef = gap;
				gap.id = task.gap.@answerid;
				gap.maxChars = int(task.gap.@length);
				gap.layoutDirection
				gap.width=100;
				gap.height=100;
				gap.styleName=(task.gap.@style!="")?task.gap.@style.toString():"TextInput_default";
				gap.text = answerExists(task.gap.@answerid)==true?getAnswerString(task.gap.@answerid):"";
			references.push(gap);
			
			//--------------------------------// ADD TO DISPLAY
			contentGroup.addElement(imgGroup);
			PulseList.addToList(imgGroup);
			contentGroup.addElement(gap);
			PulseList.addToList(gap);
			qView.content.addElement(contentGroup);
			
			
			display_navigation_buttons(param);
		}
		
		/**
		 * @private
		 * 
		 * by clicking an image it iterates all selectable images to determine, if an image should be surraounded by a color or not
		 */
		private function onImageClick(event:MouseEvent):void
		{
			var im:SelectableImage = event.currentTarget as SelectableImage;
				im.selected = im.selected?false:true;
			for(var i:uint=0;i<selectables.length;i++)
			{
				if(selectables[i]!=im)
				{
					selectables[i].selected=false;
				}
			}
			if(gapRef!=null)
				gapRef.setFocus();
			
		}
		

	}
}