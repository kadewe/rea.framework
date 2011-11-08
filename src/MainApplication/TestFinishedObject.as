package MainApplication
{
	import DisplayApplication.Components.CustomDesignButton;
	import DisplayApplication.TestFinishedView;
	
	import Interfaces.IClickableComponent;
	import Interfaces.ICustomEventDispatcher;
	import Interfaces.ICustomModule;
	
	import Model.Globals;
	import Model.Session;
	import Model.TestCollection;
	
	import Shared.CustomModuleEvents;
	import Shared.ErrorDispatcher;
	import Shared.EventDispatcher;
	import Shared.MP3Audio;
	import Shared.StaticFunctions;
	import Shared.UserEvent;
	
	import enumTypes.ErrorTypeEnum;
	import enumTypes.UrlTypeEnum;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.controls.Alert;
	import mx.events.FlexEvent;

	/**
	 * After finishing a test, this Class is loaded to provide functions for printing the evaluation and choosing the further activities.
	 * 
	 */
	public class TestFinishedObject extends EventDispatcher implements ICustomModule,ICustomEventDispatcher
	{
		private var view:TestFinishedView;
		
		//-------------------------------------- 
		// states events and references
		//--------------------------------------
		
		private var references:Array=new Array();
		
		private var labels:Array;
		private var _urls:Array;
		
		private var rootUrl:String;
		private var scriptUrl:String;
		private var soundUrl:String;
		
		private var buttonSoundUrl:String;
		private var labelSoundUrl:String;
		
		/**
		 * empty constructor
		 */
		public function TestFinishedObject()
		{
			//empty
		}
		
		//--------------------------------------// 
		// Module Loading
		//--------------------------------------//
		
		
		public function load(_globals:Globals,_tcollection:TestCollection,_session:Session):void
		{
			trace("[testfinished]: load");
			view = new TestFinishedView();
			view.addEventListener(TestFinishedView.FINISHED,onNewTest);
			view.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			labels=_globals.labels;
			_urls = _globals.paths;
			
			for(var i:uint=0;i<_urls.length;i++)
			{
				if(_urls[i][0]==UrlTypeEnum.ROOT.getValue())
				{
					rootUrl = _urls[i][1];
				}
				if(_urls[i][0]==UrlTypeEnum.INCLUDE_SCRIPT.getValue())
				{
					scriptUrl = rootUrl + _urls[i][1];
				}
				if(_urls[i][0]==UrlTypeEnum.SOUNDS.getValue())
				{
					soundUrl = _urls[i][1];
				}
				
			}
			
			dispatchEvent(new Event(LOAD_COMPLETE));
		}
		
		
		public function returnView():Object
		{
			return this.view;	
		}
		
		public function sendTweenFinished():void
		{
			//	
		}
		
		
		public function unload():void
		{

			this.view.removeAllElements();
			this.view = null;
		}
		
		
		//--------------------------------------// 
		// DEBUG AND SOUND SETTINGS
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
		
		
		private function onNextState(event:MouseEvent):void
		{
			trace(view.currentState);
			for(var i:uint=0;i<labels.length;i++)
			{
				if(view.whatNext.id==labels[i][0])
				{
					view.whatNext.text = labels[i][1];
					if(!soundMode)
					{
						var m:MP3Audio = new MP3Audio(scriptUrl,soundUrl + labels[i][2]);
						view.whatNextSound.referringTo = m;
						view.whatNextSound.addEventListener(MouseEvent.CLICK, playAudio);
					}
				}
				if(view.newTestButton.id==labels[i][0]){view.newTestButton.label = labels[i][1];}
				if(view.mainAppEndButton.id==labels[i][0]){view.mainAppEndButton.label = labels[i][1];}
			}
			
			view.newTestButton.addEventListener(MouseEvent.MOUSE_OVER, playAudio);
			view.mainAppEndButton.addEventListener(MouseEvent.MOUSE_OVER, playAudio);
		}
		
		private function onCreationComplete(event:FlexEvent):void
		{
			trace("[testfinished]: created");
			//--------------------------------------------// LABELS
			for(var i:uint=0;i<labels.length;i++)
			{
				if(view.youCanPrint.id==labels[i][0])
				{
					view.youCanPrint.text = labels[i][1];
					if(!soundMode)
					{
						var m:MP3Audio = new MP3Audio(scriptUrl, soundUrl + labels[i][2]);
						view.printSound.referringTo = m;
						view.printSound.addEventListener(MouseEvent.CLICK, playAudio);
					}
				}
				if(view.congrats.id==labels[i][0])
				{
					view.congrats.text = labels[i][1];
					if(!soundMode)
					{
						var _m:MP3Audio = new MP3Audio(scriptUrl,soundUrl + labels[i][2]);
						view.congratsSound.referringTo = _m;
						view.congratsSound.addEventListener(MouseEvent.CLICK, playAudio);
					}
				}
				if(view.forwardButton.id==labels[i][0]){view.forwardButton.label = labels[i][1];}
			}

			
			view.forwardButton.addEventListener(MouseEvent.CLICK, onNextState);
			view.congrats.addEventListener(MouseEvent.CLICK, playAudio);
			view.youCanPrint.addEventListener(MouseEvent.CLICK, playAudio);
			
		}
		

		private function onNewTest(event:Event):void
		{
			Shared.StaticFunctions.fadeOutSound();
			dispatchEvent(new CustomModuleEvents(CustomModuleEvents.MODULE_FINISHED,false,false,null,null,null,-1,-1,false));
		}
		


		/**
		 * @private 
		 * 
		 * This method is called by event and plays the audio file (MP3Audio), the specific SoundButton is referring to.
		 *
		 * @see DisplayApplication.SoundButton
		 * @see Shared.MP3Audio
		 */
		private function playAudio(event:MouseEvent):void
		{
			Shared.StaticFunctions.fadeOutSound();
			Shared.StaticFunctions.stopPulse();
			var cl:IClickableComponent = event.target as IClickableComponent;
			try
			{
				cl.referringTo.playAudio();
			}catch(e:Error){
				if(debug)
					Alert.show(e.message);
				ErrorDispatcher.processNewError(
					ErrorTypeEnum.NULLREFERENCE.getNumber().toString(),
					ErrorTypeEnum.NULLREFERENCE.getValue(),
					e.errorID.toString(),
					e.name + " " + event.target,
					"LoginObject.as",
					scriptUrl,
					false
				);
				//fallback
				event.target.removeEventListener(MouseEvent.CLICK, playAudio);
			}	
		}
		
		
		//--------------------------------------------// 
		// Module Finished
		//--------------------------------------------// 
		
		public static const LOAD_COMPLETE:String = "loadComplete";
		
		public function returnModuleFinishedEvent():String
		{
			Shared.StaticFunctions.fadeOutSound();
			return CustomModuleEvents.MODULE_FINISHED;
		}
		
		public function returnLoadFinishedEvent():String
		{
			return LOAD_COMPLETE;
		}
		
		public function getClassDefinition():String
		{
			return "MainApplication.TestFinishedObject";
		}
		
	}
}