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
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	
	import interfaces.IIdentifiable;
	import interfaces.ISelectable;
	
	import utils.ReaVisualUtils;
	
	/**
	 * A simple extension of an image, inmplementing the selectable idea. This image can be used with others to simulate an image based single- or multiple choice construct.
	 */
	public class SelectableImage extends ReaImage implements ISelectable,IIdentifiable
	{
		//---------------------------------------
		//
		//	CONSTRUCTOR
		//
		//---------------------------------------
		
		/**
		 * Constructor.
		 * 
		 * @see Shared.CustomImage
		 */
		public function SelectableImage(scriptUrl:String,relativePath:String)
		{
			super(scriptUrl, relativePath);
		}
		
		
		//---------------------------------------
		//
		//	VARIABLES
		//
		//---------------------------------------
		
		
		//---------------------------------------
		//	HOVER COLOR
		//---------------------------------------
		
		private var _hoverColor:uint = 0xFFD779;

		/**
		 * The glow filter color of this image when hovered
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
		
		private var _selectedColor:uint =0x716159;

		/**
		 * The glow filter color of this image when clicked
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
		
		
		//---------------------------------------
		//	SELECTED
		//---------------------------------------
		
		/**
		 * @private
		 */
		protected var _selected:Boolean=false;
		
		
		/**
		 * Accesses the selected property
		 */
		public function get selected():Boolean
		{
			return _selected;
		}
		
		/**
		 * Sets this component to the selected status, which will also change the appearance to a colored border.
		 */
		public function set selected(value:Boolean):void
		{
			_selected = value;
			if(value)
			{
				var glo:flash.filters.GlowFilter = utils.ReaVisualUtils.getGloFil(selectedColor);
				filters=[glo];
			}else{
				filters=null;
			}
		}
		
		
		//---------------------------------------
		//	HOVERED
		//---------------------------------------
		
		/**
		 * @private
		 */
		protected var _hovered:Boolean=false;
		
		
		/**
		 * Accesses the hovered property
		 * 
		 */
		public function get hovered():Boolean
		{
			return _hovered;
		}
		
		
		/**
		 * Sets this component to the hovered status, which will also change the appearance to a colored border.
		 */
		public function set hovered(value:Boolean):void
		{
			_hovered = value;
			if(!selected)
			{
				if(value)
				{
					var glo:flash.filters.GlowFilter = utils.ReaVisualUtils.getGloFil(hoverColor);
					filters = [glo];
				}else{
					filters = null;
				}	
			}
			
		}
		
		
		//---------------------------------------
		//
		//	EVENTS
		//
		//---------------------------------------
		
		/**
		 * @private 
		 * 
		 * calls the functions of an image to show the surrounded colored border to show users the status of being dragged 
		 */
		protected function onImageOver(event:MouseEvent):void
		{
			
			hovered=true;
			addEventListener(MouseEvent.MOUSE_OUT, onImageOut);
		}
		
		/**
		 * @private
		 * 
		 * remove colored border of a dragged image
		 */
		protected function onImageOut(event:MouseEvent):void
		{
			hovered=false;
			removeEventListener(MouseEvent.MOUSE_OUT, onImageOut);
		}
			
		
	}
}