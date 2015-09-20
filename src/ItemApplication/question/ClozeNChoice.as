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
	import components.SelectableLabel;
	import components.SkinnedComponents.CustomTextInput;
	import components.SkinnedComponents.SmallEyeButton;
	import components.factories.ComponentsFactory;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import interfaces.ICustomEventDispatcher;
	
	import models.Globals;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.events.FlexEvent;
	
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.Label;
	
	import utils.HorizontalMultilineLayout;
	import utils.PulseList;
	

	public class ClozeNChoice extends QuestionsObject
	{
		public function ClozeNChoice()
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
		
		private var selectables_list:ArrayList;
		
		
		override public function displayQuestions(param:Number):void
		{
			
			PulseList.flush();
			//first assign the multiline layout!
			var g:Group = new Group();
			var hml: HorizontalMultilineLayout = new HorizontalMultilineLayout();
			hml.verticalAlign="middle";
			hml.verticalLayoutInLine = "middle";
			hml.lineHeightInPixel=28;
			hml.verticalGap=0;
			g.layout = hml;
			
			//call parents method for q_text
			try
			{
				g.addElement(display_q_text(param));
			}finally{}
			
			
			var task:XMLList = source.questionpage[param].question.children().children();
			for(var i:uint=0;i<task.length();i++)
			{
				var node:XML = task[i];
				if(node.name().toString() == "a_text")
				{
					try
					{
						var s:String = node.children().toString();
						var a:ArrayCollection = new ArrayCollection(s.split(' '));
						for(var j:uint = 0;j<a.length;j++)
						{	
							var l:Label = new Label();
							l.id = "atext_"+param+"_"+i+"_"+j;
							l.text =  answerExists(l.id) ? getAnswerString(l.id) : a[j];
							l.styleName = Globals.TEXT_STANDARD;
							g.addElement(l);
						}
					}finally{}
				}
				if(node.name().toString() == "textchoices")
				{
					try
					{
						g.addElement(display_word_choices(node,i));
					}finally{}
				}
		
			}
			
			g.addEventListener(FlexEvent.UPDATE_COMPLETE, onGroupUpdate);

			qView.content.addElement(g);
			PulseList.init();
			display_navigation_buttons(param);
		}
		
		private function display_word_choices(node:XML, index:uint):Group
		{
			if(selectables_list == null)
				selectables_list = new ArrayList();
			
			var h:HGroup = new HGroup();
			
			
			var choices:XMLList = node.children();
			var sl1:SelectableLabel = new SelectableLabel(choices[0].children().toString(),Globals.TEXT_INPUT_STANDARD);
				sl1.id = choices[0].@answerid;
				sl1.editable = false;
				sl1.maxChars = sl1.text.length;
				sl1.selected = answerExists(sl1.id)?getAnswerValue(sl1.id):false;
				sl1.addEventListener(MouseEvent.CLICK, onChoiceClicked);
				sl1.addEventListener(MouseEvent.MOUSE_OVER, onChoiceOver);
				sl1.addEventListener(MouseEvent.MOUSE_OUT, onChoiceOut);
			references.push(sl1);
			
			var l:Label = ComponentsFactory.createLabe(node.@delimiter,"delimiter_"+index,Globals.TEXT_STANDARD);
			
			var sl2:SelectableLabel = new SelectableLabel(choices[1].children().toString(),Globals.TEXT_INPUT_STANDARD);
				sl2.id = choices[1].@answerid;
				sl2.editable = false;
				sl2.maxChars = sl1.text.length;
				sl2.selected = answerExists(sl2.id)?getAnswerValue(sl2.id):false;
				sl2.addEventListener(MouseEvent.CLICK, onChoiceClicked);
				sl2.addEventListener(MouseEvent.MOUSE_OVER, onChoiceOver);
				sl2.addEventListener(MouseEvent.MOUSE_OUT, onChoiceOut);
			references.push(sl2);
			
		
			
			var pair:Array = new Array();
			pair.push(sl1);
			pair.push(sl2);
			selectables_list.addItem(pair);
			

			h.addElement(sl1);
			h.addElement(l);
			h.addElement(sl2);
			
			return h;
		}
		
		
		private function onChoiceClicked(e:MouseEvent):void
		{
			var s:SelectableLabel = e.currentTarget as SelectableLabel;
			s.selected  = true;
			for(var i:uint=0;i<selectables_list.length;i++)
			{
				var a:Array = selectables_list.getItemAt(i) as Array;
				if(a[0].id == s.id)
				{
					a[1].selected = false;
				}
				if(a[1].id == s.id)
				{
					a[0].selected = false;
				}
			}
		}
		
		private function onChoiceOver(e:MouseEvent):void
		{
			var s:SelectableLabel = e.currentTarget as SelectableLabel;
			s.hovered = true;
		}
		
		private function onChoiceOut(e:MouseEvent):void
		{
			var s:SelectableLabel = e.currentTarget as SelectableLabel;
			s.hovered = false;
		}
		
		private function display_eye_button():Group
		{
			var hg:HGroup = new HGroup();
			hg.addElement(new SmallEyeButton());
			hg.addElement(new SmallEyeButton());
			return hg;
		}
		
		
		
		/**
		 * Uses the update function to assign the calculated with from the label to the textinput. Workaround, to avoid complex implementeation within textinput component.
		 */
		private function onGroupUpdate(event:Event):void
		{
			var g:Group = event.currentTarget as Group;
			g.removeEventListener(FlexEvent.UPDATE_COMPLETE, onGroupUpdate);
			var elements:Array = new Array(g.numElements);
			var hml:HorizontalMultilineLayout = new HorizontalMultilineLayout();
			hml.lineHeightInPixel = 28;
			hml.verticalAlign="middle";
			hml.verticalLayoutInLine = "middle";
			g.layout = hml;
			
			var i:uint;
			for(i=0;i<g.numElements;i++)
			{
				try
				{
					var l:Label = g.getElementAt(i) as Label;
					if(l.id.charAt(0) == "a")
					{
						var ct:CustomTextInput = new CustomTextInput();
						ct.id = l.id;
						ct.autoresize=true;
						l.id = "old_"+String(uint(Math.random()*10000));
						ct.width = l.width + 2;
						ct.text = l.text;
						ct.maxChars = l.text.length + 2;
						ct.height = 26;
						ct.styleName = "editable_textinput";

						references.push(ct);
						elements[i] = ct;
					}
				} 
				catch(e:Error)
				{
					elements[i]  = g.getElementAt(i);
				}
			}
			g.removeAllElements();
			for(i=0;i<elements.length;i++)
			{
				g.addElement(elements[i]);
			}
		} 
	}
}