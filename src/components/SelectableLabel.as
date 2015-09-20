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
package components
{
	import components.SkinnedComponents.CustomTextInput;
	
	import flash.filters.GlowFilter;
	
	import interfaces.IFocusAble;
	import interfaces.IIdentifiable;
	import interfaces.ISelectable;
	
	import utils.ReaVisualUtils;
	
	
	/**
	 * Extends CustomTextInput and adds selectable functionality. This label can be used in items where users have to select to correct term out of many.
	 */
	public class SelectableLabel extends CustomTextInput implements ISelectable,IIdentifiable,IFocusAble
	{
		//---------------------------------------
		//
		//	CONSTRUCTOR
		//
		//---------------------------------------
		
		/**
		 * Constructor. Sets autoresize always to true and maxchars to text length.
		 * 
		 * @param labelText The text to be displayed
		 * @param style The stylename for this object. Fallback is ensured.
		 */
		public function SelectableLabel(labelText:String,style:String)
		{
			autoresize = true;
			text=labelText;
			maxChars = text.length;
			
			styleName = style.length>0?style:"TextInput_locked_22";
		}
		
		
		//---------------------------------------
		//
		//	VARIABLES
		//
		//---------------------------------------
		
		
		//---------------------------------------
		//	SELECTED
		//---------------------------------------
		
		protected var _selected:Boolean=false;
		
		/**
		 * Determines if the element is selected
		 */
		public function get selected():Boolean
		{
			return _selected;
		}
		
		/**
		 * Determines if the element is selected
		 */
		public function set selected(value:Boolean):void
		{
			_selected = value;
			if(value)
			{
				var glo:GlowFilter = utils.ReaVisualUtils.getGloFil(selectedColor);
				filters = [glo];
			}else{
				filters = null;
			}
		}
		
		
		//---------------------------------------
		//	HOVERED
		//---------------------------------------
		
		protected var _hovered:Boolean=false;
		
		
		/**
		 * Determines if the element is hovered
		 */
		public function get hovered():Boolean
		{
			return _hovered;
		}
		
		
		/**
		 * Determines if the element is selected
		 */
		public function set hovered(value:Boolean):void
		{
			_hovered = value;
			if(!selected)
			{
				if(value)
				{
					var glo:GlowFilter = utils.ReaVisualUtils.getGloFil(hoverColor);
					filters = [glo];
				}else{
					filters = null;
				}	
			}
		}
		
		
		//---------------------------------------
		//	HOVER COLOR
		//---------------------------------------
		
		private var _hoverColor:uint = 0xFFD779;

		/**
		 * The glow filter color of this label when hovered
		 * @default 0xFFD779
		 */
		public function get hoverColor():uint
		{
			return _hoverColor;
		}

		/**
		 * @private
		 */
		public function set hoverColor(value:uint):void
		{
			_hoverColor = value;
		}
		
		
		//---------------------------------------
		//	SELECTED COLOR
		//---------------------------------------
		
		private var _selectedColor:uint =0x4466FF;

		/**
		 * The glow filter color of this label when selected
		 * @default 0x4466FF
		 */
		public function get selectedColor():uint
		{
			return _selectedColor;
		}

		/**
		 * @private
		 */
		public function set selectedColor(value:uint):void
		{
			_selectedColor = value;
		}
	
	}
}