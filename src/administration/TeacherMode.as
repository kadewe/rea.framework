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
package administration
{
	import events.CustomEventDispatcher;
	
	import administration.view.TeacherView;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	
	import models.Globals;
	
	import mx.collections.ArrayList;
	
	import spark.components.Group;
	
	
	public class TeacherMode extends CustomEventDispatcher implements IAdminModule
	{
		private var view:TeacherView;
		
		private var references:ArrayList;
		
		private var root:String;
		private var scriptUrl:String;
		private  var rscript:String;
		
		public static const LOAD_COMPLETE:String = "loadCOmplete";
		
		
		public function TeacherMode(target:IEventDispatcher=null)
		{
			super(target);
			view = new TeacherView();
		}
		
		public function init(globals:Globals):void
		{
			view.getResults.addEventListener(MouseEvent.CLICK,onStudentsReportCall);
			var p:Array = globals.paths;
			for(var i:uint=0; i<globals.paths.length;i++)
			{
				if(p[i][0] == "rootUrl")
				{
					root = p[i][1];
				}
				if(p[i][0] == "includeScript")
				{
					scriptUrl = root + p[i][1]; 
				}
				if(p[i][0] == "rootUrl")
				{
					rscript = p[i][1];
				}
			}
			dispatchEvent(new Event(LOAD_COMPLETE));
		}
		
		public function load():void
		{
			
		}
		
		public function returnView():Group
		{
			return view;
		}
		
		public function unload():void
		{
			
		}
		
		public function getClassDefinition():String
		{
			return null;
		}
		
		public function returnLoadFinishedEvent():String
		{
			return LOAD_COMPLETE;
		}
		
		public function returnModuleFinishedEvent():String
		{
			return AdminEvent.MODULE_FINISHED;
		}
		
		public function returnCurrentDisplay():Group
		{
			return new Group();
		}
		
		public function returnUpdateEvent():String
		{
			return "";
		}
		
		private function onStudentsReportCall(event:MouseEvent):void
		{
			trace("call for report");
/*			var user:String = view.studentsNumber.text;
			
			var r:ReportHandler = new ReportHandler()
			r.prepare(this.scriptUrl,rscript);
			r.callReport(user,true);*/
		}
	}
}