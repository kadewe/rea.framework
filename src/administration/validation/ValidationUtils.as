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
package administration.validation
{
	import mx.utils.ObjectUtil;

	public class ValidationUtils
	{
		
		/**
		 * Checks an array if there are double string entries. Prints a message (sourcename required) if yes and returns an array which contains all double entries (once per entry).
		 * 
		 * @param source
		 * @param sourcename
		 * @return Array with double entries, length of zero means no double entries
		 */
		public static function hasnodoubleEntries(source:Array, sourcename:String=null):Boolean
		{
			for(var i:uint=0;i<source.length;i++)
			{
				for(var j:uint=0;j<source.length;j++)
				{
					if(source[i] == source[j] && j!=i)
					{
						trace("[Utils]: "+sourcename + " has double entries");
						return false;
					}
				}
			}
			return true;
		}
		
		/**
		 * Checks for double entries but also checks if they are linked to a non-doubled entry in another list. FOr this case we assume, that the linked values are in the same position in the array indices.
		 */
		public static function hasnoDoubleEntriesWithLinking(source:Array, links:Array,sourcename:String,linkname:String):Boolean
		{
			if(source.length != links.length)
			{
				trace("[Utils]: "+sourcename + " has no correct lengthmatch with " + linkname);
				return false;
			}
			
			var doubles:Array = new Array(source.length);
			
			for(var i:uint=0;i<source.length;i++)
			{
				var c:Array = new Array(source[i],links[i]);
				doubles[i] = c;
			}
			for(var j:uint=0;j<doubles.length;j++)
			{
				for(var k:uint=0;k<doubles.length;k++)
				{
					var a:Array = doubles[j];
					var b:Array = doubles[k];
					if(a[0]==b[0] && a[1] == b[1] && j!=k)
					{
						trace("found double objects:" + i +" "+j+a[0]+" "+b[0]+" "+a[1]+" "+b[1]);
						return false;
					}
				}
			}
			return true;
		}
		
		
		public static function arrays_have_same_entries(a:Array,b:Array):Boolean
		{
			for(var i:uint=0;i<a.length;i++)
			{
				var found:Boolean=false;
				for(var j:uint=0;j<b.length;j++)
				{
					if(a[i] == b[j])
					{
						found=true;
					}
				}
				if(!found)
				{
					trace("[MiscUtils]: could not find matching string to "+a[i]);
					trace("sources:");
					var len:uint = a.length>b.length?a.length:b.length;
					for(var k:uint=0;j<len;k++)
					{
						if(k< a.length && k<b.length)
						{
							trace(a[k] + " --> " + b[k]);
						}
						if(k< a.length)
						{
							trace(a[k] + " --> ");
						}
						if(k<b.length)
						{
							trace("      --> " + b[k]);
						}
						
					}
					return false;
				}
			}
			return true;
		}
		
		public static function a_entries_in_b(a:Array,b:Array):Boolean
		{
			for(var i:uint=0;i<a.length;i++)
			{
				var found:Boolean=false;
				for(var j:uint=0;j<b.length;j++)
				{
					if(a[i] == b[j])
					{
						found=true;
					}
				}
				if(!found)
				{
					return false;
				}
			}
			return true;
		}		
	}
}