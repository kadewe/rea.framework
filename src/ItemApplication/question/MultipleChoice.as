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
	import components.SkinnedComponents.CustomCheckBox;
	import components.SkinnedComponents.SmallSoundButton;
	import components.factories.ComponentsFactory;
	
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilter;
	
	import interfaces.ICustomEventDispatcher;
	
	import models.Globals;
	
	import mx.core.IVisualElement;
	import mx.events.FlexEvent;
	
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.VGroup;
	import spark.layouts.HorizontalLayout;
	import spark.layouts.VerticalLayout;
	import spark.primitives.Line;
	
	import utils.PulseList;
	import utils.ReaVisualUtils;
	
	/**
	 * Represents the process of loading, arranging and displaying data within a multiple choice item. The data model is a checkbox group, which allows one or many or all selected choices as an answer.
	 */
	public class MultipleChoice extends QuestionsObject
	{

		/**
		 * constructor, calls superclass.
		 * 
		 * @see QuestionsObject
		 */
		public function MultipleChoice()
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
		 * 
		 * 
		 * @param param the number of the questionpage. 0 means page 1
		 */
		override public function displayQuestions(param:Number):void
		{
			//call parents method for q_text
			try
			{
				qView.content.addElement(display_q_text(param));
			} 
			catch(error:Error) 
			{
				trace("could not generate question_text");
			
			}
			//QUESTIONPAGE CONTENT
			var task:XMLList = source.questionpage[param].question; // the part of the array which is important for the several qpage
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
				
				
				// fraction calculations
				
				var fract:XMLList = task[i].calc.children();
				
				if(fract != null && fract.length() > 0)
				{
					trace("FRACTION:");
					//wrapper group
					var fhg:HGroup = ComponentsFactory.createHGroup("calculationGroup","center","middle");
					for(var o:uint=0;o<fract.length();o++)
					{
						var node:XML = fract[o];
						if(node.name().toString() == "fraction")
						{
							var f:VGroup = ComponentsFactory.createFractionComponent(Number(node.@top),Number(node.@bottom),"calc"+String(o));
							fhg.addElement(f);
						}
						
						if(node.name().toString() == "operator")
						{
							var op:Label = ComponentsFactory.createLabe(node.@symbol,"op"+String(o));
							fhg.addElement(op);
						}
					}
					this.qView.content.addElement(fhg);
				}
			
				// term calculations
				var term:XMLList = task[i].term.children();
				if(term != null && term.length() > 0)
				{
					
					trace("[SingleChoice]: create vertical term");
					var vertical_wrapper:VGroup = new VGroup();

					
					var term_group:HGroup = new HGroup();	//wrapper group for child group
						term_group.horizontalAlign = "center";
						term_group.verticalAlign="bottom";
					
					
					var operator_group:VGroup = new VGroup();//wrapper group for operator
						operator_group.verticalAlign="bottom";
					
					var numbers_group:VGroup = new VGroup();//wrapper group for numbers
						numbers_group.verticalAlign = "bottom";
						numbers_group.horizontalAlign = "right";
					
					var num_one_group:HGroup = new HGroup();//uppernumber
						num_one_group.horizontalAlign="right";
					
					var num_two_group:HGroup = new HGroup();//lowernumber
						num_two_group.horizontalAlign="right";
					
					for(var p:uint=0;p<term.length();p++)
					{	
						var _node:XML = term[p];
						if(_node.name().toString() == "num_one")
						{
							num_one_group.addElement(ComponentsFactory.createLabe(_node.children().toString(),"term_"+String(p)));
						}
						
						if(_node.name().toString() == "num_two")
						{
							operator_group.addElement(ComponentsFactory.createLabe(_node.@operator,"op"+String(o)));
							num_two_group.addElement(ComponentsFactory.createLabe(_node.children().toString(),"term_"+String(p)));
							
						}
					}
					//
					//build groups together
					//
					
					//add numbers to num group
					numbers_group.addElement(num_one_group);
					numbers_group.addElement(num_two_group);
					
					
					//add wrappers to term group
					term_group.addElement(operator_group);
					term_group.addElement(numbers_group);
					
					//add term group to vert wrapper
					vertical_wrapper.addElement(term_group);
					
					//add line
					var term_line:Line = ComponentsFactory.createLine(0,1,2,1,0x000000,100);
					vertical_wrapper.addElement(term_line);
					
					qView.content.addElement(vertical_wrapper);
					
					
				}
				
				//---------------------------------// Choices
				var choices:XMLList = task[i].choices.children();
				
				var layout:String = task[i].choices.@layout;
				var choiceGroup:Group;
				if(layout=="horizontal")
				{
					var horiLay:HorizontalLayout = ComponentsFactory.createHorizontalLayout("middle","center",25);
					choiceGroup = ComponentsFactory.createGroup("choiceGroup",horiLay);
				}else{
					var vertiLay:VerticalLayout = ComponentsFactory.createVerticalLayout("middle","left",20);
					choiceGroup = ComponentsFactory.createGroup("choiceGroup",vertiLay);
				}
				
				/*

				//CheckBox*
				var box:CustomCheckBox = new CustomCheckBox();
				box.id = choices[k].@answerid;						
				box.addEventListener(MouseEvent.MOUSE_OVER, onMouseOverBox);
				box.addEventListener(MouseEvent.MOUSE_OUT, onMouseOutBox);
				box.label = null;
				box.selected = answerExists(choices[k].@answerid)==true?getAnswerValue(choices[k].@answerid):false;
				hg.addElement(box);
				references.push(box);
				
				*/
					
				for(var k:uint=0;k<choices.length();k++)
				{
					//------------------------------// HGroup //------------------------------//
					var hg:HGroup = new HGroup();
					hg.horizontalAlign="left";
					hg.verticalAlign="middle";
					
					
					//------------------------------// CheckBox //------------------------------//
					//CheckBox*
					var box:CustomCheckBox = new CustomCheckBox();
					box.id = choices[k].@answerid;						
					box.addEventListener(MouseEvent.MOUSE_OVER, onMouseOverBox);
					box.addEventListener(MouseEvent.MOUSE_OUT, onMouseOutBox);
					box.label = null;
					box.selected = answerExists(choices[k].@answerid)==true?getAnswerValue(choices[k].@answerid):false;
					hg.addElement(box);
					references.push(box);
					
					
					
					//------------------------------// FRACTION //------------------------------//
					var fracTrue:Boolean = false;
					try
					{
						var cc:XMLList = choices[k].children();
						var nod:XML = cc[0];
						if(nod.@top.length()>0)
						{
							var frac:VGroup = ComponentsFactory.createFractionComponent(nod.@top,nod.@bottom,"choice"+String(k));
							hg.addElement(frac);
							fracTrue = true;	
						}
						
					}catch(e:Error){
						fracTrue=false;
					}
					
					
					//------------------------------// IMAGE //------------------------------//
					var furl:String=choices[k].@files;
					if(furl!="" && furl.length>0)
					{
						var arr:Array = furl.split(",");
						for(var l:uint=0;l<arr.length;l++)
						{
							var img:ReaImage = new ReaImage(scriptUrl,relUrl + arr[l]);
							img.addEventListener(FlexEvent.UPDATE_COMPLETE, onImageUpdate);
							hg.addElement(img as IVisualElement);
							references.push(img);
						}
					}
					
					//------------------------------// SOUND //------------------------------//
					if(!ignoreSound && choices[k].@sound.length()>0)
					{
						var mbtn:SmallSoundButton = ComponentsFactory.createSmallSoundButton(scriptUrl, relUrl + choices[k].@sound,"sound_"+choices[k].@sound,"button_"+choices[k].@sound) as SmallSoundButton;
						references.push(mbtn);
						hg.addElement(mbtn);
						PulseList.addToList(mbtn);
					}
					
					
					//------------------------------// Label //------------------------------//
					//------------------------------// LINE / STROKE //------------------------------//
					if(!fracTrue)
					{						
						var box_label_line:Line = ComponentsFactory.createLine(0,1,2,0.2,0x000000,100,0);
						//hg.addEventListener(FlexEvent.UPDATE_COMPLETE, onLineUpdate);
						hg.addElement(box_label_line);
						var rblbl:Label = ComponentsFactory.createLabe(choices[k].children(),"radioLabel_"+choices[k].@answerid,choices[k].@style.length>0?choices[k].@style:Globals.TEXT_STANDARD);
						hg.addElement(rblbl);
					}
					
					choiceGroup.addElement(hg);

			
					
				}
				this.qView.content.addElement(choiceGroup);
			}
			
			//Create HGroup for arrows
			display_navigation_buttons(param);
		}
		
		
		
		private function onMouseOverBox(event:MouseEvent):void
		{
			var bx:CustomCheckBox = event.target as CustomCheckBox;
			var filter:BitmapFilter = utils.ReaVisualUtils.getGloFil();
			var _filters:Array = new Array();
			_filters.push(filter);
			bx.filters = _filters;
		}
		
		private function onMouseOutBox(event:MouseEvent):void
		{
			var bx:CustomCheckBox = event.target as CustomCheckBox;
			bx.filters = null;
		}
		
		protected function onImageUpdate(event:FlexEvent):void
		{
			var i:ReaImage = event.target as ReaImage;
			//resize Image
			utils.ReaVisualUtils.resizeImages(i,100,50);
		}

		
		private function horizontalResize(g:Group,targetWidth:uint):void
		{
			for(var i:uint=0;i<g.numChildren;i++)
			{
				if(g.getElementAt(i) is Line)
				{
					var l:Line = g.getElementAt(i) as Line;
					l.width = targetWidth;
				}
				if(g.getElementAt(i) is Group)
				{
					horizontalResize(g.getElementAt(i) as Group,targetWidth);
				}
			}
		}
	}
}