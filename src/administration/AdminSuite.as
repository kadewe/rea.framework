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
	import events.CustomModuleEvents;
	import events.CustomEventDispatcher;
	
	import interfaces.ICustomEventDispatcher;
	
	import ItemApplication.Evaluator;
	import ItemApplication.ItemModule;
	
	import models.Globals;
	import models.Session;
	import models.TestCollection;
	
	import components.factories.ComponentsFactory;
	
	import administration.view.AdminLoginView;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.sampler.NewObjectSample;
	import flash.ui.Keyboard;
	
	import mx.collections.ArrayList;
	import mx.collections.XMLListCollection;
	import mx.events.FlexEvent;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	import spark.components.Button;
	import spark.components.DataGrid;
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.HScrollBar;
	import spark.components.Label;
	import spark.components.VGroup;
	import spark.components.VScrollBar;
	import spark.primitives.Line;
	
	import administration.validation.ItemChecker;
	import administration.validation.ValidationsSuite;
	import administration.validation.XMLDocumentValidator;
	
	public class AdminSuite extends CustomEventDispatcher implements IAdminModule
	{
		private var view:AdminLoginView;
		
		private var currentView:Group;
		private var references:ArrayList;
		
		private var labels:Array;
		private var paths:Array;
		
		private var http:HTTPService;
		
		private var rootUrl:String;
		private var scriptUrl:String;
		
		
		private var check:ItemChecker;
		
		private var globals:Globals;
		
		
		public static const LOAD_COMPLETE:String = "loadCOmplete";
		public static const UPDATE:String = "update";
		
		public function AdminSuite(target:IEventDispatcher=null)
		{
			trace("AdminSuite::init");
			super(target);
			view = new AdminLoginView();
			currentView = view;
			
			references = new ArrayList();
			references.addItem(view);
		}
		
		public function init(globals:Globals):void
		{	
			this.globals = globals;
			this.rootUrl = globals.returnPathValue("rootUrl");
			this.scriptUrl = globals.returnPathValue("includeScript");
			trace(rootUrl);
			trace(scriptUrl);
			view.addEventListener(FlexEvent.CREATION_COMPLETE, onViewComplete);
			view.addEventListener(FlexEvent.STATE_CHANGE_COMPLETE, onStateChange);
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
			for(var i:uint=0;i< references.length;i++)
			{
				if(references.getItemAt(i) is ICustomEventDispatcher)
				{
					references.getItemAt(i) .removeAllEventListeners();
				}
				if(references.getItemAt(i) is Group)
				{
					references.getItemAt(i).removeAllElements();
				}
			}
			try
			{
				references.removeAll();
			} 
			catch(error:Error) 
			{
				//
			}
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
			return currentView;
		}
		
		public function returnUpdateEvent():String
		{
			return UPDATE;
		}
		
		
		//----------------------------------------------------------------
		//
		//		PRIVATE
		//
		//----------------------------------------------------------------
		
		//---------- USER REPORT HANDLERS -----------------//
		
		private function onUserReport(event:MouseEvent):void
		{
			loadUserReport();
		}

		
		private function onEnterPressed_user(event:KeyboardEvent):void
		{	
			if(event.keyCode == Keyboard.ENTER)
				loadUserReport();
		}
		
		private function loadUserReport():void
		{
			trace("LOAD USER REPORT:");
			var s:String = view.useridInput.text;
			trace(s);
			var final:String = "";
			for(var i:uint=0;i<s.length;i++)
			{
				try
				{
					var copy:String = s.charAt(i).toUpperCase();
					final+=copy;
				}catch(e:Error){
					trace("no uppercase");
				}
			}
			
			//loading user
			//HTTPService...
		}
		
		
		//---------- ITEM  HANDLERS -----------------//
		
		private function onItemCall(event:MouseEvent):void
		{
			checkItem();
		}
		
		private function onEnterPressed_item(event:KeyboardEvent):void
		{
			if(event.keyCode == Keyboard.ENTER)
				checkItem();
		}
		
		
		private function checkItem():void
		{
			check = new ItemChecker();
			check.addEventListener(ItemChecker.ID_CORRECT, loadItem);
			check.addEventListener(ItemChecker.ID_WRONG, loadErrorMessage);
			check.checkIfExists(view.itemidInput.text,this.rootUrl,this.scriptUrl);
		}
		
		
		private var io:ItemModule;
		private function  loadItem(event:Event):void
		{
			check.removeAllEventListeners();
			check.unload();
			check=null;
			trace("item exists, will continue with loading item-xml");
			io= new ItemModule();
			io.debug = false;
			io.playSound = false;
			io.track = false;
			io.addEventListener(CustomModuleEvents.MODULE_LOAD_COMPLETE, onItemLoadComplete);
			io.addEventListener(CustomModuleEvents.MODULE_FINISHED, onItemFinished);

			
			//create dummys
			var tc:TestCollection = new TestCollection(this.rootUrl,null,this.scriptUrl);
			var sess:Session = new Session();
				sess.create_user("admin");
				sess.updateSession(0,0,view.itemidInput.text);
			
			io.load(this.globals,tc,sess);
		}
		
		private function  loadErrorMessage(event:Event):void
		{
			check.removeAllEventListeners();
			check.unload();
			check=null;
			trace("item NOT EXISTSSSSSS!!!!");
			view.itemidInput.text = "";
		}
		
		
		private function onItemLoadComplete(event:Event):void
		{
			var i:ItemModule = event.currentTarget as ItemModule;
			this.currentView = null;
			this.currentView = i.returnView();
			dispatchEvent(new Event(UPDATE));
		}
		
		private function onItemFinished(event:Event):void
		{
			//doc validation
			var valid:Boolean = XMLDocumentValidator.validate_id_linking(io.sourceXML);
			
			
			//create evaluator
			var e:Evaluator = io.evaluator;



			//wrapper group with scroll function
			var wrapper:HGroup = new HGroup();
			wrapper.height = 700;
			wrapper.width=1000;
			wrapper.clipAndEnableScrolling = true;
			wrapper.addEventListener(FlexEvent.UPDATE_COMPLETE, onScrollerUpdate);
			
			//group for content
			var g:VGroup = new VGroup();
			g.id="vertical";
			g.gap = 25;
			g.width = 960;
			

			
			var entry:XMLList = e.getLog().children();
			for(var i:uint;i<entry.length();i++)
			{
				var entry_wrapper:VGroup = new VGroup();
				entry_wrapper.percentWidth=100;
				
				//headline
				var headline:HGroup = new HGroup();
				headline.percentWidth=100;
				
				var style:String = int(entry[i].final.@mark) == 1 ?"Text-GreenBG" : "Text-RedBG";
				
				var marklabel:Label = ComponentsFactory.createLabe(entry[i].marking.@markid + "(alpha="+entry[i].marking.@alphaid+") => POINT: "+entry[i].final.@mark,"head_"+i.toString(),style);
				headline.addElement(marklabel);
				entry_wrapper.addElement(headline);
				
				//responses
				var resp:XMLList = entry[i].response.children();
				for (var j:int = 0; j < resp.length(); j++) 
				{
					var resp_wrap:HGroup = new HGroup();
					resp_wrap.percentWidth=100;
					
					//answerid & points
					var answerid_points:VGroup = new VGroup();
					answerid_points.horizontalAlign="left";
					answerid_points.addElement(ComponentsFactory.createLabe("answerid: "+resp[j].@answerid,"answerid_"+i.toString()+j.toString()));
					answerid_points.addElement(ComponentsFactory.createLabe("points: "+resp[j].@points,"points"+i.toString()+j.toString()));
					resp_wrap.addElement(answerid_points);
					
					resp_wrap.addElement(ComponentsFactory.createLine(0,30));
					
					//case & match & length
					var matching:VGroup = new VGroup();
					matching.horizontalAlign="left";
					matching.addElement(ComponentsFactory.createLabe("matchtype: "+resp[j].@matchtype,"matchtype"+i.toString()+j.toString()));
					matching.addElement(ComponentsFactory.createLabe("matchlength: "+resp[j].@matchlength,"matchlength"+i.toString()+j.toString()));
					//matching.addElement(ComponentsCreator.createLabe("case: "+resp[j].@casesen,"case"+i.toString()+j.toString()));
					resp_wrap.addElement(matching);
					
					resp_wrap.addElement(ComponentsFactory.createLine(0,30));
					
					//answer & match
					var answer:VGroup = new VGroup();
					answer.horizontalAlign="left";
					answer.addElement(ComponentsFactory.createLabe("answer: "+resp[j].@answer,"answer"+i.toString()+j.toString()));
					answer.addElement(ComponentsFactory.createLabe("match : "+resp[j].@matchvalue,"matchvalue"+i.toString()+j.toString()));
					resp_wrap.addElement(answer);
					
					resp_wrap.addElement(ComponentsFactory.createLine(0,30));
					
					//partial points
					var point:VGroup = new VGroup();
					point.horizontalAlign="center";
					point.verticalAlign = "middle";
					point.addElement(ComponentsFactory.createLabe(resp[j].@result,"points_"+i.toString()+j.toString()));
					resp_wrap.addElement(point);
					
					entry_wrapper.addElement(resp_wrap);
				}
				g.addElement(entry_wrapper);
			}
			
			
			//buttom and finish event
			var b:Button = new Button();
			b.label = "OK!";
			b.addEventListener(MouseEvent.CLICK, onEvalFinished);
			g.addElement(b);
			
			wrapper.addElement(g);
			
			var vsb:VScrollBar = new VScrollBar();
			vsb.width = 30;
			vsb.viewport = wrapper;
			wrapper.addElement(vsb);
			
			
			this.currentView = wrapper;
			dispatchEvent(new Event(UPDATE));
		}
		
		
		private function onScrollerUpdate(event:FlexEvent):void
		{
			var g:Group = event.target as Group;
			
			var v:VScrollBar;
			var newHeight:uint;
			for (var i:int = 0; i < g.numElements; i++) 
			{
				var obj:* = g.getElementAt(i);
				if(obj.id == "vertical")
				{
					newHeight = obj.height;
				}
				if(obj is VScrollBar)
				{
					v = obj;
				}
			}
			if(newHeight>0)
			{
				v.height = newHeight;
				g.removeEventListener(FlexEvent.UPDATE_COMPLETE, onScrollerUpdate);	
			}
		}
		
		
		private function onEvalFinished(event:Event):void
		{
			io.unload();
			io = null;
			view.itemidInput.text = "";
			trace("ITEM FINSIHED");
			this.currentView = this.view;
			dispatchEvent(new Event(UPDATE));
		}
	
		
		//---------- View HANDLERS -----------------//
		
		private var reflist:ArrayList;
		
		private function onStateChange(event:FlexEvent):void
		{
			switch(view.currentState)
			{
				case("report"):
					view.requestReport.addEventListener(MouseEvent.CLICK, onUserReport);
					view.useridInput.addEventListener(KeyboardEvent.KEY_UP, onEnterPressed_user);
					break;
				case("item"):
					view.requestItem.addEventListener(MouseEvent.CLICK, onItemCall);
					view.itemidInput.addEventListener(KeyboardEvent.KEY_UP, onEnterPressed_item);
					view.itemidInput.setFocus();
					break;
				case("testsuite"):
					reflist = new ArrayList();
					view.backButton.addEventListener(MouseEvent.CLICK, onTestSuiteEnd);
					reflist.addItem(vs);
					var vs:ValidationsSuite = new ValidationsSuite();
					vs.prepare(this.rootUrl,this.scriptUrl,globals.returnPathValue("getTCollection"));
					vs.addEventListener(ValidationsSuite.TC_LOADED, onvsready);
					view.showtc.referringTo = vs;
					view.validtc.referringTo = vs;
					view.validitem.referringTo = vs;
					break;
			}
		}
		
		private function onvsready(event:Event):void
		{
			view.pleasewait.visible=false;
			view.showtc.enabled=true;
			view.validtc.enabled=true;
			view.validitem.enabled = true;
			view.showtc.addEventListener(MouseEvent.CLICK, showtestcollection_content);
			view.validtc.addEventListener(MouseEvent.CLICK, validatetc);
			view.validitem.addEventListener(MouseEvent.CLICK, validateitem);
		}
		
		
		private function validateitem(event:MouseEvent):void
		{
			var vs:ValidationsSuite = event.currentTarget.referringTo as ValidationsSuite;
			vs.validate_singleitem(view.validate_itemidInput.text);
		}
		
		private function onTestSuiteEnd(event:Event):void
		{
			for each (var i:Object in reflist) 
			{
				if(i is ICustomEventDispatcher)
					i.removeAllEventListeners();
				
				i=null;
			}
			view.showtc.referringTo = null;
			view.validtc.referringTo = null;
			view.testOutput.removeAllElements();
		}
			
			
		private function showtestcollection_content(event:Event):void
		{
			var vs:ValidationsSuite = event.currentTarget.referringTo as ValidationsSuite;
			view.testOutput.addElement(vs.show_tc_content(view.testOutput.width));
		}
		
		private function validatetc(event:MouseEvent):void
		{
			var vs:ValidationsSuite = event.currentTarget.referringTo as ValidationsSuite;
			vs.validate_items();
		}
		
		private function onViewComplete(event:FlexEvent):void
		{
			dispatchEvent(new Event(LOAD_COMPLETE));
		}
		


	}
}