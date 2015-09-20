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
	import components.SkinnedComponents.LabelLineGroup;
	import components.SkinnedComponents.SmallEyeButton;
	import components.SkinnedComponents.SmallSoundButton;
	
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.primitives.Line;

	
	/**
	 * Creates more complex components or compositions of components.
	 */
	public class ComplexComponentsFactory
	{
		
		/**
		 * Creates a group with soundbutton, vertical line and label.
		 * 
		 * @param invisible
		 * @param horizontal
		 * @param idPrefix the prefix for all ids in this group
		 * @param labelText
		 * @param labelStyle
		 * @param soundMode
		 * @param scriptUrl
		 * @param relUrl
		 * @param soundName
		 * @param 
		 */
		public static function createLabelLineGroup(invisible:Boolean , horizontal:Boolean , idPrefix:String , labelText:String , labelStyle:String , 
													muteSound:Boolean=false , scriptUrl:String="" , relUrl:String="" , soundName:String="" ,debug:Boolean=false):LabelLineGroup
		{

			
			//---------------------------- TOP LEVEL GROUP WRAPPER --------------------------//
			
			var topLevelGroup:LabelLineGroup = new LabelLineGroup();
				topLevelGroup.id="complex__group_"+idPrefix;
				topLevelGroup.percentWidth  = 100;
				
				
				
			
			//---------------------------- LABEL --------------------------//
			
				
				
			var label:spark.components.Label = ComponentsFactory.createLabe(
				labelText,
				"complex_label"+idPrefix ,
				labelStyle,
				100
			);
			
			topLevelGroup.label_ref = label;
			
			//---------------------------- Line --------------------------//
		
			var line:Line = ComponentsFactory.createLine(0,0,2,0.2,0x000000,0,100);
				line.id = "complex_line"+idPrefix;

				topLevelGroup.line_ref = line;
			
			//------------- WRAPPER ------------//
			
			var wrap:HGroup = new HGroup();
				wrap.id = "label_line_wrappergroup";
				wrap.addElement(line);
				wrap.addElement(label);
				wrap.verticalAlign="middle";
				wrap.percentWidth=100;
			
			//------------- SOUND ------------//
			
			if(!muteSound && soundName.length>0 && scriptUrl.length>0 && relUrl.length>0)
			{
				var ssndBtn:SmallSoundButton = ComponentsFactory.createSmallSoundButton(scriptUrl,relUrl + soundName,"complex_soundData"+idPrefix,"complex_soundButton"+idPrefix,wrap) as SmallSoundButton;
					ssndBtn.visibleReference = wrap;
				if(debug)
				{
					ssndBtn.referringTo.setDebug();
				}
				if(invisible)
				{
					ssndBtn.visible=false;
				}
				topLevelGroup.addElement(ssndBtn);
				topLevelGroup.button_ref = ssndBtn;
			}else{
				var seBtn:SmallEyeButton = ComponentsFactory.createSmallEyeButton("complex_eyeButton"+idPrefix,wrap) as SmallEyeButton;
					seBtn.visibleReference = wrap;
				if(invisible)
				{
					seBtn.visible = false;
				}
				topLevelGroup.addElement(seBtn);
				topLevelGroup.button_ref = seBtn;
			}
			

			
			//---------------------------- STRUCTURIZING --------------------------//
			
			if(invisible)
			{
				wrap.visible = false;
				wrap.alpha =0;	
			}
			
			topLevelGroup.addElement(wrap);

			return topLevelGroup;
		}
		
	}
}