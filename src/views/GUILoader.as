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
package views
{
	import components.BasicSoundButton;
	import components.ReaButton;
	import components.SkinnedComponents.LabelLineGroup;
	
	import interfaces.IDisposable;
	
	import models.Globals;
	
	import mx.core.IVisualElement;
	
	import spark.components.Group;
	import spark.components.Label;

	/**
	 * A helper class to initialize generic components on an AbstractView
	 */
	public class GUILoader implements IDisposable
	{
		
		/**
		 * Reference to globalsettings class.
		 */
		protected var _globals:Globals;
		
		/**
		 * Constructor, sets intial reference to global settings.
		 */
		public function GUILoader(globals:Globals){_globals = globals;}
		
		/**
		 * @inheritDoc
		 */
		public function unload():void
		{
			
		}
		
		/**
		 * Pases a target view to process the initialization of labels, button references, sounds etc.
		 * 
		 * @param view The targeted view as AbstractView, will be handled as group internally.
		 */
		public function initGUI(view:AbstractView):void
		{
			initGroup(view);
		}
		
		/**
		 * Recursive function to initialize objects in a group. Can be called with AbstractView as parameter, but can only 
		 * call recursive with a group since AbstractView cannot be casted back towards a Group instance.
		 * 
		 * @param view Group instance
		 */
		public function initGroup(view:Group):void
		{
			if( !view  )return;
			for (var i:int = 0; i < view.numElements; i++) 
			{
				var el:IVisualElement = view.getElementAt(i);
				
				if( el is Label)initLabel( el as Label );
				
				if( el is ReaButton)initButton( el as ReaButton );
				
				if( el is BasicSoundButton)initSoundButton( el as BasicSoundButton );
				
				if( el is LabelLineGroup)
				{
					var llg:LabelLineGroup = el as LabelLineGroup;
					if( llg.label_ref is Label)
						initLabel(llg.label_ref as Label);
					if( llg.button_ref is BasicSoundButton)
						initSoundButton(llg.button_ref as BasicSoundButton);
				}
				
				if( el is Group )initGroup( el as Group);
			}
		}
		
		/**
		 * <p>Note: If you want to init groups of elements, use the initGroup function. For views use the initGUI function.</p>
		 * 
		 * Initializes a label by searching up it's id and adding the corresponding text value.
		 * 
		 * @param label A spark Label, which usually occurs within groups.
		 */
		public function initLabel(label:Label):void
		{
			label.text = _globals.returnLabelValue( label.id ) || label.text;
		}
		
		/**
		 * <p>Note: If you want to init groups of elements, use the initGroup function. For views use the initGUI function.</p>
		 * 
		 * Initializes a button by searching up it's id and assigning the corresponding label text.
		 */
		public function initButton(button:ReaButton):void
		{
			button.label = _globals.returnLabelValue( button.id ) || button.label;
		}
		
		/**
		 * <p>Note: If you want to init groups of elements, use the initGroup function. For views use the initGUI function.</p>
		 * 
		 * Initializes a soundbutton by adding the corresponding label as well as sound paths to load the referred MP3 sound.
		 */
		public function initSoundButton(button:BasicSoundButton):void
		{
			initButton(button);
			button.scriptUrl = _globals.returnPathValue("rootUrl") + _globals.returnPathValue("includeScript");
			button.source = _globals.returnSoundUrl(button.referringTo==null ? button.id : button.referringTo.id);
		}
		
	}
}