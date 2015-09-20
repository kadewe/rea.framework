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
	import mx.collections.ArrayList;
	
	import spark.components.Image;

	internal class InputTrackerModel
	{
		private var _final:XML;
		
		private var meta:ModuleMetaData;
		
		private var logs:ArrayList;
		
		private var screens:ArrayList;
		
		//-------------------------------------------------------------------
		//
		//		INIT / UNLOAD
		//
		//-------------------------------------------------------------------
		
		public function InputTrackerModel()
		{
			meta = new ModuleMetaData();
			logs = new ArrayList();
			screens = new ArrayList();
		}
		
		internal function unload():void
		{
				
		}	
		
		//-------------------------------------------------------------------
		//
		//		PROCESSING
		//
		//-------------------------------------------------------------------
		
		
		internal function merge():void
		{
	
			//meta data
			_final = XML("<?xml version='1.0' ?><tracking></tracking>");
			_final.appendChild(meta.returnAsXMLList());
			
			//log data	
			var tmp:String = "<log_data>";
			for(var i:uint=0;i<logs.length;i++)
			{
				tmp+=logs.getItemAt(i).returnLogString();
			}
			tmp+="</log_data>";
			_final.appendChild(XMLList(tmp));
		}
		
		internal function returnFinal():XML
		{
			return _final!=null?_final:new XML();
		}
		
		internal function returnType():String
		{
			return meta.returnType();
		}
		
		internal function returnUser():String
		{
			return meta.returnUser();
		}
		
		internal function returnSubType():String
		{
			return meta.returnSub();
		}
		

		
		
		internal function returnImages():ArrayList
		{
			return screens;
		}
		//-------------------------------------------------------------------
		//
		//		ADD META DATA FUNCTIONS
		//
		//-------------------------------------------------------------------
		
		internal function addType(arg:*):void
		{
			meta.addType(arg);
		}

		internal function addSubType(arg:*):void
		{
			meta.addsubtype(arg);
		}
		
		internal function addUser(arg:*):void
		{
			meta.addUserid(arg);
		}
		

		internal function addGlobals(globals:XML):void
		{
			
			meta.addGlobalSettings(globals.settings);
		}
		
		internal function addView(view:String,image:Image):void
		{
			
			
			var has:Boolean = meta.hasView(view);
			//trace(has);
		
			if(!has && image != null)
			{
				trace("[InputTrackerModel]: add new image --> "+view+image);
				var a:Array = new Array(image,view+".png");
				screens.addItem(a);
			}
			meta.addViewImage(view);
		}
		//-------------------------------------------------------------------
		//
		//		ADD LOG DATA FUNCTIONS
		//
		//-------------------------------------------------------------------

		
		internal function addLog(currentView:String,posx:uint,posy:uint,event:String,target:String):void
		{
			var l:ModuleLogData = new ModuleLogData(getTime(),currentView,posx,posy,event,target);
			//trace("[LOG]: "+l.returnLogString()	);
			logs.addItem(l);
		}
		
		//-------------------------------------------------------------------
		//
		//		PRIVATE
		//
		//-------------------------------------------------------------------
				
		
		private function getTime():String
		{
			var d:Date = new Date();
			var time:String = String(d.hours+":"+d.minutes+":"+d.seconds+":"+d.milliseconds);
			return time;
		}
	}
}