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
	import components.SkinnedComponents.CustomRadioButton;
	import components.SkinnedComponents.MiniSoundButton;
	
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	
	import mx.core.IVisualElement;
	import mx.events.FlexEvent;
	
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.Label;
	
	import utils.MP3Audio;
	import utils.MathUtils;
	import utils.PulseList;
	import utils.ReaVisualUtils;

	/**
	 * Provides a cloud of radiobuttons and labels to click. The positions within the cloud will be chosen randomly and the cloud can increase its size by having trouble with positioning elements due to limited space.
	 */
	public class ScCloud extends SingleChoice
	{
		private var cloudElements:Array;
		private var shuffleCounter:uint;
		
		private var selectionPointer:Array;
		private var labelsPointer:Array;
		
		/**
		 * constructor calls superclass.
		 * 
		 * @see QuestionsObject
		 */
		public function ScCloud()
		{
			super();
		}
		
		override public function unload():void
		{
			super.unload();
		}
		
		/**
		 * 
		 */
		override public function displayQuestions(param:Number):void
		{
			try
			{
				qView.content.addElement(display_q_text(param));
			} 
			catch(error:Error) 
			{
				trace("could not generate question_text");
				
			}

			var task:XMLList = source.questionpage[param].question; // the part of the array which is important for the several qpage
			trace(task);
			for(var i:uint=0;i<task.length();i++)
			{
				//call parents method for answertext
				try
				{
					qView.content.addElement(display_answer_text(task,i));
				} 
				catch(error:Error) 
				{
					trace("could not generate answer_text");
				}
				//CHOICES
				var choices:XMLList = task[i].choices.children();
				
				var cloud:Group = new Group();
				
				cloudElements = new Array(choices.length());
				selectionPointer = new Array(choices.length());
				labelsPointer = new Array(choices.length());
				shuffleCounter=0;
				//------------------------------------------------------//
				// CLOUD //
				
				for(var k:uint=0;k<choices.length();k++)
				{
					//HGroup: radiobutton + vgroup!
					var hg:HGroup = new HGroup();
					hg.verticalAlign="middle";
					hg.horizontalAlign="center";
					

					
					//RADIOBUTTON
					var rbtn:CustomRadioButton = new CustomRadioButton();
					rbtn.id = choices[k].@answerid;						
					//rbtn.addEventListener(MouseEvent.MOUSE_OVER, onMouseOverRadio);
					//rbtn.addEventListener(MouseEvent.MOUSE_OUT, onMouseOutRadio);
					rbtn.addEventListener(MouseEvent.CLICK, onRadioClick);
					rbtn.label = null;
					rbtn.selected = answerExists(choices[k].@answerid)==true?getAnswerValue(choices[k].@answerid):false;
					rbtn.filters = rbtn.selected?[utils.ReaVisualUtils.getGloFil(0x4466FF)]:null;
					
					
					hg.addElement(rbtn);
					selectionPointer[k] = rbtn;
					references.push(rbtn);

					
					//------------------------------// OPTIONAL MEDIA
					//------------------------------//
					
					//SoundButton
					if(!ignoreSound && choices[k].@sound.length()>0)
					{
						var sound:MP3Audio = new MP3Audio(scriptUrl,relUrl + choices[k].@sound);
						var mbtn:MiniSoundButton = new MiniSoundButton();
						mbtn.referringTo = sound;
						references.push(mbtn);
						hg.addElement(mbtn);
						PulseList.addToList(mbtn);
					}
					//ImageFiles
					var furl:String=choices[k].@files;
					if(furl!="")
					{
						var arr:Array = furl.split(",");
						for(var l:uint=0;l<arr.length;l++)
						{
							
							var img:ReaImage = new ReaImage(scriptUrl,relUrl + arr[l]);
							hg.addElement(img as IVisualElement);
							references.push(img);
						}
					}
					
					//------------------------------// Label
					//------------------------------//
					
					
					var rblbl:Label = new Label();
					rblbl.text = choices[k].children();
					rblbl.id = "label";
					rblbl.styleName="bglabel";
					
					hg.addElement(rblbl);
					hg.x=0;
					hg.y=0;
					hg.addEventListener(FlexEvent.UPDATE_COMPLETE, onUpdateComplete);
					cloudElements[k] = hg;
					cloud.addElement(hg);
				}
				this.qView.content.addElement(cloud);
			}
			display_navigation_buttons(param);
		}
		
		
		private function onUpdateComplete(event:FlexEvent):void
		{
			shuffleCounter++;
			var h:HGroup = event.currentTarget as HGroup;
			h.removeEventListener(FlexEvent.UPDATE_COMPLETE, onUpdateComplete);
			h.height+=2;
			h.width+=8;
			h.invalidateDisplayList();
			h.invalidateSize();
			h.drawRoundRect(h.x,h.y,h.width,h.height,8.0,0xEFEFEF,1.0);
			if(shuffleCounter==cloudElements.length)
			{
				shuffle();	
			}
		}
		
		private function shuffle():void
		{
			for(var k:uint=0;k<cloudElements.length;k++)
			{
				var positions:Array = utils.MathUtils.getRandomSquarePosition(cloudElements[k].width+8,cloudElements[k].height+4,qView.width-80,qView.content.height-350,cloudElements,cloudElements.length);
				cloudElements[k].x = positions[0];
				cloudElements[k].y = positions[1];
			}
		}
		
		private function onRadioClick(event:MouseEvent):void
		{
			for(var i:uint=0;i<selectionPointer.length;i++)
			{
				selectionPointer[i].filters=null;
			}
			var glo:flash.filters.GlowFilter = utils.ReaVisualUtils.getGloFil(0x4466FF,3);
			var rb:CustomRadioButton = event.currentTarget as CustomRadioButton;
			rb.filters = [glo];
		}
		

	}
	

}