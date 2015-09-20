
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
package report
{
	import events.CustomEventDispatcher;
	
	import flash.events.IEventDispatcher;
	
	import mx.rpc.Fault;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	/**
	 * Calls the report on the server. An http service is used to connect to the server and pass the variables. The server script answers with a correct result or a 'failed' status.
	 */
	public class ReportHandler extends CustomEventDispatcher
	{
		
		
		//---------------------------------------
		//
		//	CONSTRUCTOR
		//
		//---------------------------------------
		
		/**
		 * Constructor. Empty.
		 */
		public function ReportHandler(target:IEventDispatcher=null)
		{
			super(target);
			
		}
		
		//---------------------------------------
		//
		//	VARIABLES
		//
		//---------------------------------------
		
		private var scriptUrl:String;
		private var serv:HTTPService;
		private var _result:String="";
		private var teacher:Boolean;
		
		//---------------------------------------
		//
		//	API
		//
		//---------------------------------------
		
		/**
		 * Prepares the report http service for calling
		 * 
		 * @param scripturl The name of the php script on the server
		 * @param for_teacher Indicates if the result is an (extended) evaluation for teachers
		 */
		public function prepare(scripturl:String,for_teacher:Boolean=false):void
		{
			teacher= for_teacher;
			this.scriptUrl = scripturl;
			
			serv = new HTTPService();
			serv.url = scriptUrl;
			serv.method = "POST";

			serv.resultFormat = HTTPService.RESULT_FORMAT_XML;
			
				
			serv.showBusyCursor=true;
			serv.addEventListener(ResultEvent.RESULT, onResult);
			serv.addEventListener(FaultEvent.FAULT, onFault);
			
		}
		
		/**
		 * <p>Calls the user report from the server.</p>
		 * <p> use the following PHP VARIABLES:<code> $user = $_POST['user']; $thresh = $_POST['threshold']; $dim =	$_POST['dimension']; $count = $_POST['listCount']; $script = $_POST['scriptCall'];</code> </p>
		 * 
		 * @param userid the id of the user
		 * @param thresholdvalue DEPRECATED the threshold of when a collection is solved correct
		 * @param dim DEPRECATED the dimension to evaluate
		 * @param count DEPRECATED indicates how many results per section will be displayed
		 * @param navigate allows to navigate to the php script if desired to debug php output
		 */
		public function callReport(userid:String,thresholdvalue:int,dim:String,count:int, navigate:Boolean=false):void
		{
			trace("=============== CALL REPORT =====================");
			trace(userid);
			trace(thresholdvalue);
			trace(dim);
			trace(count);
			trace(scriptUrl)
			var target:String = teacher ? "teacher" : "r";
			
			var a:Object = {
				param:target,
				user: userid,
				threshold:thresholdvalue,
				dimension:dim,
				listCount:3
			};
			
			serv.request = a;
			serv.send();
			
		}
			
		//---------------------------------------
		//
		//	EVENTS
		//
		//---------------------------------------
								   
		private function onResult(event:ResultEvent):void
		{
			trace("Report result");
			trace(event.result);
			if(String(event.result).toLowerCase().indexOf("error")!=-1)
			{
				_result="error";
				dispatchEvent(FaultEvent.createEvent(new Fault("0",String(event.result))));
				return;
			}
			_result = String(event.result);
			try
			{
				var x:XML = event.result as XML;
				_result = x.toXMLString();
			} 
			catch(error:Error) 
			{
				_result = String(event.result);
			}
			
			trace("=============== REPORT RESULT =====================");
			dispatchEvent( event.clone() );
		}
		
		private function onFault(event:FaultEvent):void
		{
			trace("fault");
			trace(event.message);
			_result = event.message.body.toString();
			trace("=============== REPORT FAULT =====================");
			dispatchEvent( event.clone() );
		}
	}
}