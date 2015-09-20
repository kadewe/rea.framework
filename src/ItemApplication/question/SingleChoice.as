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
	import components.SkinnedComponents.CustomBorderContainer;
	import components.SkinnedComponents.CustomRadioButton;
	import components.SkinnedComponents.SmallEyeButton;
	import components.SkinnedComponents.SmallSoundButton;
	import components.factories.ComponentsFactory;
	
	import interfaces.ICustomEventDispatcher;
	
	import models.Globals;
	
	import mx.core.IVisualElement;
	
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.VGroup;
	import spark.layouts.HorizontalAlign;
	import spark.layouts.HorizontalLayout;
	import spark.layouts.VerticalAlign;
	import spark.layouts.VerticalLayout;
	import spark.primitives.Line;
	
	import utils.PulseList;
	
	/**
	 * Representing the process of loading, arranging and displaying data within a single choice item. The data model is a radiobutton group, whcih allows only one choice per question.
	 */
	public class SingleChoice extends QuestionsObject
	{

		public function SingleChoice()
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
				if(references[i] == null)continue;
				if(references[i] is ICustomEventDispatcher)
					ICustomEventDispatcher(references[i]).removeAllEventListeners();
				references[i] = null;
			}
			references = null;
		}
		
	
		
		
		/**
		 * Displays a vertical set of Radiobuttons and Labels according to the specific questionspage, determined by the parameter.
		 * Optional there can be an image and or a sound button before the answertext.
		 * 
		 * @param param the number of the page
		 */
		override public function displayQuestions(param:Number):void
		{
			//----------------------------------------------
			//
			//	Q_TEXT
			//
			//----------------------------------------------
			try
			{
				qView.content.addElement(display_q_text(param));
			}catch(error:Error){
			} 
			
			
			//----------------------------------------------
			//
			//	ANSWER TEXT
			//
			//----------------------------------------------
			var task:XMLList = source.questionpage[param].question; 
			for(var i:uint=0;i<task.length();i++)
			{	
				try
				{
					qView.content.addElement(display_answer_text(task,i));
				}catch(error:Error){
					trace("could not generate answer_text");
				}
				
				//----------------------------------------------
				//	IF FRACTION
				//----------------------------------------------				
				var fract:XMLList = task[i].calc.children();						
				if( fract != null && fract.length() > 0)
				{
					trace("[SingleChoice]: FRACTION in question");
					//wrapper group
					var fhg:HGroup = ComponentsFactory.createHGroup("calculationGroup","center","middle");
						//fhg.percentWidth = 100;
						fhg.horizontalAlign="left";
						fhg.addElement(ComponentsFactory.createSmallEyeButton("fraction_eye_"+i.toString(),null) as SmallEyeButton);
						
						
					for(var o:uint=0;o<fract.length();o++)
					{
						var node:XML = fract[o];
						if(node.name().toString() == "fraction")
						{
							var f:VGroup = ComponentsFactory.createFractionComponent(Number(node.@top),Number(node.@bottom),"calc"+String(o));
								//f.percentWidth=undefined;
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
				
				
				//----------------------------------------------
				//
				//	TERMS OF ADDITION OR SUBSTRACTION
				//
				//----------------------------------------------
				var term:XMLList = task[i].term.children();
				if( term != null && term.length() > 0)
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
					var term_line:Line = ComponentsFactory.createLine(term_group.width,0,2,1);
						vertical_wrapper.addElement(term_line);
					
					
					var all:HGroup = ComponentsFactory.createHGroup("term_and_button_wrapper","left","middle",100) as HGroup;
						all.addElement(ComponentsFactory.createSmallEyeButton("term_eye",null) as SmallEyeButton);
						all.addElement(vertical_wrapper);
					qView.content.addElement(all);
					
					
				}
						
						
				var choices:XMLList = task[i].choices.children();
				var layout:String = task[i].choices.@layout;
				var choiceGroup:CustomBorderContainer = new CustomBorderContainer();
					choiceGroup.percentWidth = 100;
					choiceGroup.percentHeight= 100;
				
				
				var horizontal:Boolean=(layout=="horizontal")?true:false;
				if(horizontal)
				{
					
					var horiLay:HorizontalLayout = ComponentsFactory.createHorizontalLayout("top","left",25);
											
						horiLay.paddingLeft = 15;
						horiLay.paddingRight = 15;
						horiLay.paddingTop  = 15;
						horiLay.paddingBottom = 15;
					
					//choiceGroup = ComponentsCreator.createGroup("choiceGroup",horiLay);
					choiceGroup.layout = horiLay;
				}else{
					var vertiLay:VerticalLayout = ComponentsFactory.createVerticalLayout("middle","left",20);
												
						vertiLay.paddingLeft = 15;
						vertiLay.paddingRight = 15;
						vertiLay.paddingTop  = 15;
						vertiLay.paddingBottom = 15;
					
					//choiceGroup = ComponentsCreator.createGroup("choiceGroup",vertiLay);
					choiceGroup.layout = vertiLay;
				}
				
				PulseList.addToList(choiceGroup);
				
				var fracTrue:Boolean = false;
				
				//------------------------
				// FOR EACH CHOICE
				//------------------------
				for(var k:uint=0;k<choices.length();k++)
				{
					//------------------------------// HGroup //------------------------------//
					var hg:*;
					
					if(horizontal)
					{
						hg = new VGroup();
						hg.percentWidth = 100;
						//hg.percentHeight= 100;
						hg.verticalAlign=VerticalAlign.TOP;
						hg.horizontalAlign=HorizontalAlign.LEFT;
					}else{
						hg= new HGroup();
						hg.percentWidth = 100;
						//hg.percentHeight= 100;
						hg.verticalAlign=VerticalAlign.MIDDLE;
						hg.horizontalAlign=HorizontalAlign.LEFT;
					}
					
					
					
					//------------------------------// RADIOBUTTON //------------------------------//
					//always create radio button if new child node occurs
					
					var rbtn:CustomRadioButton = new CustomRadioButton();
						rbtn.id = choices[k].@answerid;						
						rbtn.label = null;
						rbtn.selected = answerExists(choices[k].@answerid)==true?Boolean(getAnswerValue(choices[k].@answerid)):false;
					hg.addElement(rbtn);
					references.push(rbtn);
					
					//------------------------------// LINE / STROKE //------------------------------//
					if(!horizontal)
					{
						var rbline:Line = ComponentsFactory.createLine(0,0,2,0.2,0x000000,0,100);
						hg.addElement(rbline);	
						references.push(rbline);
					}
					
					
					//------------------------------// FRACTION in Choices//------------------------------//

					try
					{
						var cc:XMLList = choices[k].children();
						var nod:XML = cc[0];
						if(nod.@top.length()>0)
						{
							trace("[SingleChoice]: fraction in choices");
							var frac:VGroup = ComponentsFactory.createFractionComponent(nod.@top,nod.@bottom,"choice"+String(k));
							hg.addElement(frac);
							references.push(frac);
							fracTrue = true;	
						}
						
					}catch(e:Error){
						fracTrue=false;
					}
					
					
					//------------------------------// IMAGE //------------------------------//
					var furl:String=choices[k].@files;
					if( furl!="" && furl.length>0)
					{
						hg.percentHeight=100; //if image occurs set height 
						var arr:Array = furl.split(",");
						for(var l:uint=0;l<arr.length;l++)
						{
							var img:ReaImage = ComponentsFactory.createCustomImage("choice_image"+k.toString(), scriptUrl,relUrl + arr[l],100,100);
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
					}
					
					
					//------------------------------// Label //------------------------------//

					
					if(choices[k].children().length()>0)
					{

						var rblbl:Label = ComponentsFactory.createLabe(choices[k].children(),"radioLabel_"+choices[k].@answerid,choices[k].@style.length>0?choices[k].@style:Globals.TEXT_STANDARD,100);
						hg.addElement(rblbl);
						references.push(rblbl);
					}
					choiceGroup.addElement(hg);
					references.push(hg);
				}
				this.qView.content.addElement(choiceGroup);
				references.push(choiceGroup);
			}				
						
						

			//Create HGroup for arrows

			
			display_navigation_buttons(param);
		}
		
		

		

		

		
	}
}