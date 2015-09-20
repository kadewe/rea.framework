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
	import enums.GlobalConstants;
	
	import events.CustomEventDispatcher;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import interfaces.ICustomEventDispatcher;
	
	public class ItemChecker extends CustomEventDispatcher implements ICustomEventDispatcher
	{
		private  var loader:URLLoader;
		private  var req:URLRequest;
		private var itemid:String;
		
		public static const ID_CORRECT:String = "itemidcorrect";
		public static const ID_WRONG:String = "itemidwrong";
		
		public function ItemChecker()
		{
			super();
		}
		
		public function checkIfExists(item:String, relUrl:String, scriptUrl:String):void
		{
			itemid =item;
			loader=new URLLoader();
			loader.addEventListener(Event.COMPLETE, onLoaderCompleteHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onIOErrorHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			
			//variables / parameters
			var v:URLVariables = new URLVariables();
			v.param = GlobalConstants.CHECK_ITEM_DATA;
			v.itemid = itemid;
			
			req= new URLRequest(relUrl + scriptUrl);
			req.data = v;
			
			req.method = URLRequestMethod.POST;
			trace(req.url);
			try
			{
				loader.load(req);
			}catch(e:Error){
				//fallback
			}	
		}
		
		
		public function unload():void
		{
			loader = null;
			req = null;
		}
		
		//-----------------------------------// LOADER EVENTS //-----------------------------------// 
		
		private  function onLoaderCompleteHandler(event:Event):void
		{
			trace(loader.data);
			loader.removeEventListener(Event.COMPLETE, onLoaderCompleteHandler);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onIOErrorHandler);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			if(loader.data!=itemid)
			{
				onItemError();
			}else{
				dispatchEvent(new Event(ID_CORRECT));
			}
			
		}
		
		
		private  function onIOErrorHandler(event:IOErrorEvent):void
		{
			trace("ioerror");
			loader.removeEventListener(Event.COMPLETE, onLoaderCompleteHandler);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onIOErrorHandler);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			onItemError();
		}
		
		
		private  function onSecurityError(event:SecurityErrorEvent):void
		{
			trace("securtiy error");
			loader.removeEventListener(Event.COMPLETE, onLoaderCompleteHandler);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onIOErrorHandler);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			onItemError();
		}
		
		private function onItemError():void
		{
			dispatchEvent(new Event(ID_WRONG));
		}
	}
}