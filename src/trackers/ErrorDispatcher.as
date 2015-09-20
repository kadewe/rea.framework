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
	import enums.GlobalConstants;
	
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;

	/**
	 * Static class. Prepares a custom error type to be send to server which writes an error log
	 */
	public class ErrorDispatcher
	{
		
		
		/**
		 * creates an sends a new error message by combining the parameters and adding a timestamp. Then a urlloader will be created to request the specific php script which will write the message into a log file.
		 * 
		 * @param error custom number of error type
		 * @param description custom description of error type
		 * @param flashErrorId original falsh error id
		 * @param causedBy the source of the error
		 * @param line the module and if important also the line (line is usually useless, due to continual development)
		 * @param scriptUrl the url to the php script
		 * @param navigate for debugging, shows the target url
		 * 
		 */
		public static function processNewError(error:String,description:String,flashErrorId:String,causedBy:String,line:String,scriptUrl:String,navigate:Boolean=false):void
		{
			if(!scriptUrl)return;
			
			trace("ERROR -->");
			trace("processError call: "+causedBy);
			//-----------------------------
			//TEXT TO BE SEND
			//-----------------------------
			var text:String ="#";
			
			
			//create Timestamp
			var d:Date = new Date();
			text+= d.fullYear
					+ "_"
					+ (d.month+1)
					+ "_"
					+ d.date
					+ "|"
					+ d.getHours()
					+ ":"
					+ d.getMinutes()
					+ ":"
					+ d.getSeconds()
					+ ":"
					+ d.getMilliseconds()
					;
			//add Version
			//text+=version;
			
			//add variables
			text+= ": " + error + " - " + description + " (Flash Error ID:"+ flashErrorId + ") causedBy: " + causedBy + " At Class/File: " + line + "\n";
			
			//create a new url request an load the php script
			var loader:URLLoader = new URLLoader();
			var v:URLVariables = new URLVariables();
				v.param = GlobalConstants.SEND_ERROR_MESSAGE;
				v.error = text;
			var req:URLRequest= new URLRequest(scriptUrl);
				req.data = v;
				req.method = URLRequestMethod.POST;
			loader.load(req);
			if(navigate)
				navigateToURL(req,"new");
		}
	}
}