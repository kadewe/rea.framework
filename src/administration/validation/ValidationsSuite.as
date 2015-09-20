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
	import ItemApplication.Evaluator;
	
	import components.factories.ComponentsFactory;
	
	import enums.GlobalConstants;
	
	import events.CustomEventDispatcher;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import models.TestCollection;
	
	import spark.components.HGroup;
	import spark.components.VGroup;
	
	public class ValidationsSuite extends CustomEventDispatcher
	{
		public function ValidationsSuite(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		private var _tc:TestCollection;
		private var _updated:Boolean;
		
		private var _relUrl:String;
		private var _scriptUrl:String;
		
		
		public static const TC_LOADED:String ="tc_loaded";
		
		public function prepare(relUrl:String,scriptUrl:String,sourceUrl:String):void
		{
			_tc = new TestCollection(relUrl,sourceUrl,scriptUrl);
			_tc.addEventListener(TestCollection.TC_BUILD, onTcBuild);
			
			_relUrl = relUrl;
			_scriptUrl = scriptUrl;
		}
		
		public function get_updated_test_collection():TestCollection
		{
			if(_updated)
				return _tc;
			else
				return null;
		}
		
		private function onTcBuild(event:Event):void
		{
			//trace("test collection build successfully!");
			dispatchEvent(new Event(TC_LOADED));
		}
		
		public function show_tc_content(maxwidth:Number):VGroup
		{
			item_list = new Array();
			return build_tc_list_structure(_tc.getALLDimensions(), maxwidth);
		}
		
		
		private var item_list:Array;
		
		private function build_tc_list_structure(x:XMLList, maxw:Number):VGroup
		{
			var v:VGroup = new VGroup();
			for(var i:uint=0;i<x.length();i++)
			{
				switch(x[i].localName())
				{
					case "dimension":
						v.addElement(ComponentsFactory.createLabe(x[i].@dname,"","Text-RedBG",maxw));
						break;
					
					case "testcollection":
						v.addElement(ComponentsFactory.createLabe(x[i].@tname,"","Text-BlueBG",maxw));
						break;
					
					case "item":
						var h:HGroup = new HGroup();
						h.gap = 15;
						h.addElement(ComponentsFactory.createLabe(x[i].@iname,"","Text-22",maxw));
						item_list.push(new Array(x[i].@iname,h));
						v.addElement(h);
						break;
				}
				if(x[i].children().length() > 0)
				{
					v.addElement(build_tc_list_structure(x[i].children(),maxw));
				}
			}
			return v;
		}
		
				
		private var load_count:uint;
		public function validate_items():void
		{
			if(item_list == null || item_list.length<1)
			{
				return;
			}
			
			load_count=0;
			load();

			
		}
		
		public function validate_singleitem(itemid:String):void
		{
			for(var i:uint=0;i<item_list.length;i++)
			{
				if(item_list[i][0] == itemid)
				{
					load_count = i;
				}
			}
			var itemLoader:URLLoader = new URLLoader();
			itemLoader.addEventListener(Event.COMPLETE, singleitemCompleteHandler);
			//itemLoader.addEventListener(IOErrorEvent.IO_ERROR, singleitemioerror);
			
			var v:URLVariables = new URLVariables();
			v.param = GlobalConstants.GET_ITEM_DATA;
			v.itemid = itemid;
			
			var req:URLRequest= new URLRequest(_relUrl + _scriptUrl);
			req.data = v;
			
			req.method = URLRequestMethod.POST;
			
			itemLoader.load(req);
		}
		
		private function singleitemCompleteHandler(event:Event):void
		{
			var lo:URLLoader = event.target as URLLoader;
			displayResult(lo);
		}
		
	
		private function load():void
		{
			if(load_count == item_list.length)
			{
				return;
			}
			var itemLoader:URLLoader = new URLLoader();
				itemLoader.addEventListener(Event.COMPLETE, onCompleteHandler);
				itemLoader.addEventListener(IOErrorEvent.IO_ERROR, onioerror);
			
			var v:URLVariables = new URLVariables();
				v.param = GlobalConstants.GET_ITEM_DATA;
				v.itemid = item_list[load_count][0];
			
			var req:URLRequest= new URLRequest(_relUrl + _scriptUrl);
				req.data = v;
				req.method = URLRequestMethod.POST;
			
			itemLoader.load(req);
		}
			
		private function onioerror(event:IOErrorEvent):void
		{
			var output:HGroup = item_list[load_count][1] as HGroup;
			var lo:URLLoader = event.target as URLLoader;
			output.addElement(ComponentsFactory.createLabe("IO Error","","Text-RedBG"));
			lo.removeEventListener(IOErrorEvent.IO_ERROR, onioerror);
			lo.removeEventListener(Event.COMPLETE, onCompleteHandler);
			lo = null;
			load_count++;
			load();
		}
		
		private function onCompleteHandler(event:Event):void
		{
			var lo:URLLoader = event.target as URLLoader;
			displayResult(lo);
			load_count++;
			load();
		}
		
		
		private function displayResult(lo:URLLoader):void
		{	
			var output:HGroup = item_list[load_count][1] as HGroup;
			
			
			//loaded?
			if(lo.data == "failed")
			{
				output.addElement(ComponentsFactory.createLabe("Load Failed","","Text-RedBG"));
			}else{
				output.addElement(ComponentsFactory.createLabe("Load OK","","Text-GreenBG"));
			}
			
			
			
			//ids correct?
			try
			{
				item_list[load_count].push(XML(lo.data));
				output.addElement(ComponentsFactory.createLabe("XML Parse OK","","Text-GreenBG"));
				try
				{
					var check:Boolean = XMLDocumentValidator.validate_id_linking(item_list[load_count][2] as XML);
					if(check)
					{	output.addElement(ComponentsFactory.createLabe("IDs Valid","","Text-GreenBG"));
						
					}else{
						output.addElement(ComponentsFactory.createLabe("IDs invalid","","Text-RedBG"));
					}
				} 
				catch(error:Error) 
				{
					output.addElement(ComponentsFactory.createLabe("Validation Failed","","Text-RedBG"));
				}
			} 
			catch(error:Error) 
			{
				output.addElement(ComponentsFactory.createLabe("XML Parse Failed","","Text-RedBG"));
			}
			
			
			//evaluation correct for all wrong?
			/*
			<answers>
				<answer answerid="4.8.3_1_1" question="1"></answer>
				<answer answerid="4.8.3_1_2" question="1"></answer>
				<answer answerid="4.8.3_1_3" question="1"></answer>
				<answer answerid="4.8.3_1_4" question="1"></answer>
			</answers>
			<correctResponse>
				<value itemnumber="4.8.3_1" answerid="4.8.3_1_3" casesensitiv="yes" match="full" points="0.5">1</value>
				<value itemnumber="4.8.3_1" answerid="4.8.3_1_4" casesensitiv="yes" match="full" points="0.5">1</value>
				<value itemnumber="4.8.3_1" answerid="4.8.3_1_1" casesensitiv="yes" match="full" points="-10">1</value>
				<value itemnumber="4.8.3_1" answerid="4.8.3_1_2" casesensitiv="yes" match="full" points="-10">1</value>
				</correctResponse>
			</marking>
			*/
			try
			{
				var item:XML = item_list[load_count][2] as XML;
				var  answers:XMLList = item.answers.children();
				var response:XMLList = item.correctResponse.children();
				var marking:XMLList  = item.marking.children();
				for each (var answer:XML in answers) 
				{
					if(String(answer.@debug).length>0)
					{
						answer.appendChild(String(answer.@debug));
					}else{
						var value:String= get_cr_value(response, String(answer.@answerid));
						answer.appendChild(value);
					}
					//trace(value + " "+ answer.toXMLString());
				}
		
				
				
				
				var evaluator:Evaluator = new Evaluator();
				evaluator.init(marking,response,answers,String(item.meta_item.children()));
				//evaluator.addEventListener(Evaluator.EVALUTION_DONE, onEvalFinished);
				marking = evaluator.loadSynchron();
				var list:XMLList = marking;
				//trace("RETURNED LIST");
				//trace(list.toXMLString());
				
				var clean:Boolean=true;
				for each (var mark:XML in list) 
				{
					if(mark.name() =="pointuse")continue;
					//trace(mark.toXMLString());
					if(!String(mark.children()))
					{
						throw new Error("failed");
					}
					if(String(mark.children()) != "1")
					{
						clean=false;
						output.addElement(ComponentsFactory.createLabe("Marking invalid","","Text-RedBG"));
						//trace("error");
						break;
					}
				}
				if(clean)output.addElement(ComponentsFactory.createLabe("Marking Valid","","Text-GreenBG"));
			} 
			catch(error:Error) 
			{
			//	if(error.message=="failed")
					throw error;
					//trace(error.message);
					//trace(error.getStack//trace());
			}
			
			//cleanup
			lo.removeEventListener(Event.COMPLETE, onCompleteHandler);
			lo.removeEventListener(IOErrorEvent.IO_ERROR, onioerror);
			lo = null;
		}
		
		private function get_cr_value(list:XMLList,answerid:String):String
		{
			var ret:String="";
			
			var found:Boolean=false;
			for each (var node:XML in list) 
			{
				//trace(answerid+" " +node.toXMLString()+ " " + (String(node.@answerid) == answerid));
				if(String(node.@answerid) == answerid)
				{
					found=true;
					ret= String(node);
				}
			}
			//if(!found)//trace("error");
			return ret;
		}
		
		
	}
}