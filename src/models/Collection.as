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
package models
{
	/**
	 * A class for representing one testcollection of a dimension / subject. 
	 * 
	 */
	public class Collection
	{
		//---------------------------------------
		//
		//	CONSTRUCTOR
		//
		//---------------------------------------
		
		/**
		 * Constructor.
		 * 
		 * @param _name the name of the difficulty level
		 * @param des description of this collection and level
		 * @soundurl url to the sound file, related with the description text
		 */
		public function Collection(_name:String,des:String,soundurl:String)
		{
			items=new Array();
			name=_name;
			description=des;
			soundUrl=soundurl;
		}
		
		
		//---------------------------------------
		//
		//	VARIABLES
		//
		//---------------------------------------
		
		/**
		 * @private
		 */
		private var name:String;
		
		/**
		 * @private
		 */
		private var description:String;
		
		/**
		 * @private
		 */
		private var soundUrl:String;
		
		/**
		 * @private
		 */
		private var items:Array;


		//---------------------------------------
		//
		//	PUBLIC FUNCTIONS
		//
		//---------------------------------------
				
		/**
		 * adds an xmllist of items and excerps the itemnumbers. Stored in a standard array.
		 * 
		 * @param _items the list of items from the current collection in 'testcollections.xml'
		 */
		public function addItems(_items:XMLList):void
		{
			for(var i:uint=0;i<_items.length();i++)
			{
				items.push(_items[i].@iname);
			}
		}
		
		/**
		 * Returns the array of items
		 */
		public function returnItems():Array
		{
			return items;
		}
		
		/**
		 * returns an itemnumber at a specific index. Usefull if you desire the nth-item of the collection.
		 * 
		 * @param index the index of the desired item
		 * @return Returns the itemnumber of the item.
		 */
		public function returnItemAt(index:int):String
		{
			return items[index];
		}
		
		
		/**
		 * Returns the length of the collection
		 * 
		 * 
		 */
		public function returnItemsLength():int
		{
			return items.length;
		}
		
		/**
		 * Searches for a specific itemnumber and returns its index.
		 * 
		 * @param key The item number or key for finding the item.
		 * @return Returns the item index if found, otherwise returns -1
		 */
		public function returnItemIndex(key:String):int
		{
			if(items == null || items.length == 0)return -1;
			for (var i:int = 0; i < items.length; i++) 
			{
				if(key == items[i])
					return i;
			}
			return -1;
		}
		
		/**
		 * returns the level of the collection
		 * 
		 * @Return the collecton name entry
		 */
		public function getName():String
		{
			return name;
		}
		
		/**
		 * returns the description text of this collection
		 * 
		 * @return the description entry
		 */
		public function getDescription():String
		{
			return description;
		}
		
		/**
		 * reutrns the soundurl of this collection
		 * 
		 * @return the sound url
		 */
		public function getSound():String
		{
			return soundUrl;
		}
	}
}