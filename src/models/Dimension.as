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
	 * This class represents a dimension or subject with all its included data. Children are usually stores as 'Collection' instances
	 */
	public class Dimension
	{
		
		//---------------------------------------
		//
		//	CONSTRUCTOR
		//
		//---------------------------------------
		
		
		/**
		 * Constructor.
		 * 
		 * @param _name	Name of the dimension eg. 'reading'
		 * @param des Description if the dimension
		 * @param url Sound url for loading the sound related to the name
		 * @param requires Flag 
		 */
		public function Dimension(_name:String,des:String,url:String,requires:String)
		{
			collectionList=new Array();
			name=_name;
			description=des;
			soundUrl=url;
			
			
			_requires=requires=="1"?true:false;
			
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
		private var collectionList:Array;
		

		/**
		 * @private
		 */
		private var _requires:Boolean;
		

		
		//---------------------------------------
		//
		//	PUBLIC FUNCTIONS
		//
		//---------------------------------------
		/**
		 * adds an xmllist to the collection list. usually a collection is stored as an xml file, so it can be decoded by itering an xmllis.
		 */
		public function addToCollectionList(e:XMLList):void
		{
			collectionList.push(e);
		}
		
		/**
		 * adds a collection object to the collection list. useful if once the collection is created out of an xmllist.
		 */
		public function addCollectionToList(c:Collection):void
		{
			collectionList.push(c);
		}
		
		/**
		 * returns the entire collectionList as an array
		 */
		public function returnCollection():Array
		{
			return collectionList;
		}
		

		public function getRequres():Boolean
		{
			return _requires;
		}
		
		/**
		 * returns a specific collection by passing an index number as parameter.
		 * 
		 * @param index the index of the desired collection
		 * @return Collection Object (level)
		 */
		public function returnCollectionAt(index:int):Collection
		{
			return collectionList[index];
		}
		
		/**
		 * returns the name of this dimension 
		 */
		public function getName():String
		{
			return name;
		}
		
		/**
		 * returns the description of this dimension
		 */
		public function getDescription():String
		{
			return description;
		}
		
		/**
		 * returns the soundurl of this dimension
		 */
		public function getSoundUrl():String
		{
			return soundUrl;
		}
	}
}