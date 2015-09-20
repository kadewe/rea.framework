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
package trackers
{
	
	
	/**
	 * Data layer, representing the meta data part in an xml logger object.
	 */
	internal class ModuleMetaData
	{
		private var moduletype:String;
		private var modulesubtype:String;
		
		private var userid:String;
		private var date:String;
		
		private var viewslist:XMLList;
		private var globals:XMLList;
		
		private var views:Array;
		
		public function ModuleMetaData()
		{
			moduletype="";
			modulesubtype="";
			userid="";
			var d:Date = new Date();
			date = String(d.getFullYear())+"_"+String(d.getMonth()+1)+"_"+String(d.getDate());
			viewslist = new XMLList("<views></views>");
			views=new Array();
		}
		
		internal function addType(value:*):void
		{
			moduletype = value;
		}
		
		internal function addsubtype(value:String):void
		{
			modulesubtype = value;
		}
		
		internal function addUserid(value:String):void
		{
			userid = value;
		}
		
		internal function addViewImage(url:String):void
		{
			
			views.push(url);
		}
		
		internal function addGlobalSettings(value:XMLList):void
		{
			trace(value.length());
			globals = value;
		}
		
		internal function returnSub():String
		{
			return this.modulesubtype;
		}
		
		internal function hasView(name:String):Boolean
		{
			for (var i:int = 0; i < views.length; i++) 
			{
				trace("meta:" +views.length+" "+views[i] + " current: " + name);
				if(views[i]==name)
				{
					trace("found");
					return true;
				}
			}
			trace("not found");
			return false;
		}

		internal function returnViewList():XMLList
		{
			for (var i:int = 0; i < views.length; i++) 
			{
				var line:XML = XML("<view img_src='"+views[i]+".png' />");
				viewslist.appendChild(line);
			}
			return viewslist;
		}
		
		internal function returnType():String
		{
			return moduletype.length>0?moduletype:"error";
		}
		internal function returnUser():String
		{
			return userid;
		}
		
		internal function returnAsXMLList():XMLList
		{
			var l:XMLList = XMLList(
				"<meta_data>" +
					"<user id='"+userid+"' />" +
					"<module type='"+moduletype+"' subtype='"+modulesubtype+"' />" +
					"<test_date date='"+date+"' />"+
					globals + 
					returnViewList()+
				"</meta_data>"
				);
			return l;
		}
		
		
	}
}