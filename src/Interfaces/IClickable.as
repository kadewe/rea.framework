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
package interfaces
{
	import mx.core.IButton;


	/**
	 * Defines the minimum criteria to be clickable and refer to any object, which many of the buttons need in this app.
	 * 
	 * <p>There are many different Types of buttons in this application, many of them have refer to a sound and therefore we need to generalize the 
	 * properties of a button which makes ist possible to play a sound by clickign itr dragging it</p>
	 */
	public interface IClickable extends IButton,IIdentifiable
	{
		/**
		 * Get the reference to a specific sound object.
		 */
		function get referringTo():Object;
		
		/**
		 * Get the reference to a specific visible object like an image.
		 */
		function get visibleReference():Object;
	
		/**
		 * Set the reference to a specific sound object.
		 */
		function set referringTo(value:Object):void;
		
		/**
		 * Set the reference to a specific visible object like an image.
		 */
		function set visibleReference(value:Object):void;
	}
}