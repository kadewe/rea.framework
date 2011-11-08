package MainApplication
{
	import DisplayApplication.ErrorView;
	import DisplayApplication.StartAppView;
	
	import Interfaces.ICustomEventDispatcher;
	import Interfaces.ICustomModule;
	
	import Model.Globals;
	import Model.Session;
	import Model.TestCollection;
	
	import Shared.CustomModuleEvents;
	import Shared.EventDispatcher;
	import Shared.StaticFunctions;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.controls.Alert;
	import mx.events.FlexEvent;
	
	import org.osmf.events.TimeEvent;
	
	import spark.components.Group;

	
	/**
	 * <p>First module, loaded after initialization of the application. Includes a VideoPlayer for introducing the applications funcionalities.</p> 
	 */
	public class StartAppObject extends EventDispatcher implements ICustomModule,ICustomEventDispatcher
	{
		/**
		 * The view component, which will be linked to the display.
		 * 
		 * @see MainApplication.MainAppManager
		 * @see MainApplication.DisplayManager
		 */
		public var view:StartAppView;		
		
		
		/**
		 * Constructor
		 */
		public function StartAppObject()
		{
			trace("[STARTAPP OBJECT]: new instance");
			view = new StartAppView();
			view.mainAppStartButton.addEventListener(MouseEvent.CLICK, onStartApplication);
			Shared.StaticFunctions.pulseFocus(this.view.videoPlayer);
		}
		
		
		
		
		//--------------------------------------// 
		//
		// DEBUG AND SOUND SETTINGS
		//
		//--------------------------------------//
		
		private var _debug:Boolean=false;
		private var _sound:Boolean=false;
		
		public function set debug(value:Boolean):void
		{
			_debug=value;
		}
		
		public function set soundMode(value:Boolean):void
		{
			_sound=value;
		}
		
		public function get debug():Boolean
		{
			return _debug;
		}
		
		public function get soundMode():Boolean
		{
			return _sound;
		}
		
		
		
		
		
		//--------------------------------------// 
		// Module Loading
		//--------------------------------------//
		
		public function load(_globals:Globals,_tcollection:TestCollection,_session:Session):void
		{
			var _labels:Array = _globals.labels;
			var _urls:Array = _globals.paths;
			trace("[STARTAPP OBJECT]: load");
			try
			{
				for(var i:uint=0;i<_labels.length;i++)
				{
					if(_labels[i][0]=="mainAppStartButton")
					{
						this.view.mainAppStartButton.label=_labels[i][1]
					}
				}	
			}catch(e:Error){
				
				if(_debug)
					Alert.show(e.message);
			}
			//video player
			trace("[STARTAPP OBJECT]: load video");
			try
			{
				var relUrl:String="";
				var mediaUrl:String="";
				var vidUrl:String="";
				for(var i:uint=0;i<_urls.length;i++)
				{
					if(_urls[i][0]=="rootUrl")
					{
						relUrl = _urls[i][1];
					}
					if(_urls[i][0]=="mediaPath")
					{
						mediaUrl = _urls[i][1];
					}					
					if(_urls[i][0]=="introVideoFile")
					{
						vidUrl=_urls[i][1];
						var _source:String = relUrl + mediaUrl + vidUrl;
						view.videoPlayer.source = _source; 
						view.videoPlayer.styleName="Text-INSTR-smaller";
						view.videoPlayer.autoDisplayFirstFrame=true;
						view.videoPlayer.addEventListener(FlexEvent.CREATION_COMPLETE, onVideoPlay);
						
					}
				}
			}catch(e:Error){
				if(_debug)
					Alert.show(e.message);
			}
			dispatchEvent(new Event(LOAD_COMPLETE));
		}
		
		public function returnView():Object
		{
			return this.view!=null?view:new ErrorView();	
		}
		
		public function sendTweenFinished():void
		{
			try
			{
				view.videoPlayer.play();	
			}catch(e:Error){
				//error log
				//fallback
			}
			
		}
		
		
		public function unload():void
		{
			this.view.videoPlayer = null;
			this.view.removeAllElements();
			this.view = null;
		}
		
		
		
		
		//--------------------------------------------// 
		// VIDEO PLAYER RELATED
		//--------------------------------------------// 
		
		private function onVideoPlay(event:FlexEvent):void
		{
			view.videoPlayer.removeEventListener(FlexEvent.CREATION_COMPLETE, onVideoPlay);
			view.videoPlayer.addEventListener(TimeEvent.COMPLETE, onVideoComplete);
			Shared.StaticFunctions.stopPulse();
		}
		
		private function onVideoComplete(event:TimeEvent):void
		{
			view.videoPlayer.removeEventListener(TimeEvent.COMPLETE,onVideoComplete);
			Shared.StaticFunctions.pulseFocus(this.view.mainAppStartButton);
		}
		
		private function onStartApplication(event:Event):void
		{
			trace("[STARTAPP OBJECT]: finished");
			Shared.StaticFunctions.stopPulse();
			dispatchEvent(new CustomModuleEvents(CustomModuleEvents.MODULE_FINISHED,false,false,null,null,null));
		}
		
		
		
		
		//--------------------------------------------// 
		// Module Finished
		//--------------------------------------------// 
		
		public static const LOAD_COMPLETE:String = "loadComplete";
		
		public function returnModuleFinishedEvent():String
		{
			return CustomModuleEvents.MODULE_FINISHED;
		}

		public function returnLoadFinishedEvent():String
		{
			return LOAD_COMPLETE;
		}
		
		public function getClassDefinition():String
		{
			return "MainApplication.StartAppObject";
		}
	}
}