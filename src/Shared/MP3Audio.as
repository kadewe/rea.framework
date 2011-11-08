package Shared
{
	import Interfaces.ICustomEventDispatcher;
	
	import enumTypes.ErrorTypeEnum;
	import enumTypes.PHPParameterTypeEnum;
	
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundLoaderContext;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;
	
	import mx.controls.Alert;


	/**
	 * Creates a new wrapper for loaded mp3 files. Can handle all required events for a common mp3 player like play, pause, stop etc. The underlying data structure is a Sound Object.
	 * 
	 * @see flash.media.Sound
	 * @see flash.media.SoundChannel
	 */
	public class MP3Audio extends EventDispatcher implements ICustomEventDispatcher
	{
		
		//------------------------------------------------------------
		//
		//	VARIABLES
		//
		//------------------------------------------------------------
		
		private var audio:Sound = new Sound();
		private var isPlaying:Boolean=false;
		private var channel:SoundChannel;
		private var playingFinished:Boolean=false;
		
		private var req:URLRequest;
		private var context:SoundLoaderContext;
		private var scriptUrl:String;
		private var relPath:String;
		
		private var debugMode:Boolean=false;
				
		private var progress:Number=0;
		
		public var parent:Object	
		public var id:String;
		
		//------------------------------------
		// Events
		//------------------------------------
		public static const LOAD_COMPLETE:String = "loadComplete";
		
		public static const START_PLAYING:String = "startPlaying";
		public static const PAUSE_PLAYING:String = "pausePlaying";
		public static const FINISHED_PLAYING:String  = "finishedPLaying";
		public static const STOPPED_PLAYING:String = "stoppedPlaying";
		public static const INIT_COMPLETE:String = "initComplete";			
		public static const ONLOAD_ERROR:String = "onLoadError";
		
		
		
		//------------------------------------------------------------
		//
		//	PUBLIC FUNCTIONS
		//
		//------------------------------------------------------------
		
		/**
		 * Constructor. Requires an url to load an mp3 from an external source. events will be auto-build.
		 * 
		 * @param	_scriptUrl	the path to the include script on the server
		 * @param	relPath		the relative path to the mp3 object
		 * @param	id			allows to set an id for accessing objects at runtime
		 * @param 	navigate	for debug purposes, navigates to url of the include script
		 */
		public function MP3Audio(_scriptUrl:String,relPath:String=null,id:String=null,navigate:Boolean=false)
		{
			     this.id = id;
				 this.scriptUrl = _scriptUrl;
				 this.relPath = relPath;
			//--------------------//
			
			audio = new Sound();
			audio.addEventListener(Event.COMPLETE, onCompleteDataLoad);
			audio.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
			audio.addEventListener(ProgressEvent.PROGRESS, onProgress);
			
			trace("[MP3AUDIO]: script url: "+scriptUrl+"  path: "+relPath);
			var v:URLVariables = new URLVariables();
			v.param = PHPParameterTypeEnum.GET_AUDIO.getValue();
			v.audioPath = relPath;
			
			req= new URLRequest(scriptUrl);
			req.data = v;
			
			req.method = URLRequestMethod.POST;
			//--------------------------------
			//	try to load the requested url
			//	and catch possible errors
			//--------------------------------
			try
			{
				audio.load(req);	
			}catch(e:Error){
				if(debugMode)
					Alert.show("loading error "+e.message);
				ErrorDispatcher.processNewError(
					ErrorTypeEnum.URL_INVALID_ERROR.getNumber().toString(),
					ErrorTypeEnum.URL_INVALID_ERROR.getValue(),
					e.errorID.toString(),
					e.name,
					"MP3Audio.as -->"+relPath,
					scriptUrl,
					false
					);
				//fallback
				unload();
			}
			dispatchEvent(new Event(INIT_COMPLETE));
			if(navigate)
				navigateToURL(req,"new");
				//navigateToURL(req,"new");	//DEBUG
		}
		

		/**
		 * opens the soundchannel and adds the playing soundobject to it. enabled to autodetect, when the soundobject finished playing. isPlaying will be set to true.
		 * Does nothing if the sound object is null. This can happen for example if the unload method was called external or internal when an error occured.
		 * 
		 * @see #returnIsPlaying()
		 */
		public function playAudio():void
		{
			//do nothing if audio is null
			if(audio==null)
			{
				return;
			}
			
			try
			{
				channel=audio.play();
				channel.addEventListener(Event.SOUND_COMPLETE, onPlayingFinished);
				isPlaying=true;
				dispatchEvent(new Event(START_PLAYING));
			}
			catch(e:Error)
			{
				trace("[MP3AUDIO]: Fehler beim abspielen der Sounddatei");
				if(debugMode)
					Alert.show("loading error "+e.message);
				ErrorDispatcher.processNewError(
					ErrorTypeEnum.CANNOT_PLAY_AUDIO_ERROR.getNumber().toString(),
					ErrorTypeEnum.CANNOT_PLAY_AUDIO_ERROR.getValue(),
					e.errorID.toString(),
					e.name,
					"MP3Audio.as -->"+audio.url+relPath,
					scriptUrl,
					false
				);
				//fallback
				isPlaying=false;
				unload();
			}
			
		}
		
		
		/**
		 * manually pauses the sound object.
		 */
		public function pause():void
		{
			if(audio==null)
			{
				return;
			}
			try
			{
				audio.close();
				isPlaying=false;
				dispatchEvent(new Event(PAUSE_PLAYING));
			}catch(e:Error){
				trace("[MP3AUDIO]: Fehler beim Stream schliessen!");
				if(debugMode)
					Alert.show("loading error "+e.message);
				ErrorDispatcher.processNewError(
					ErrorTypeEnum.CANNOT_PLAY_AUDIO_ERROR.getNumber().toString(),
					ErrorTypeEnum.CANNOT_PLAY_AUDIO_ERROR.getValue(),
					e.errorID.toString(),
					e.name,
					"MP3Audio.as -->"+audio.url,
					scriptUrl,
					false
				);
				//create fallback
				unload();
			}
		}

	
		/**
		 * return if the underlying sound object is in playing state
		 * 
		 * @returns Boolean isPlaying true if playing false if not
		 */
		public function returnIsPlaying():Boolean
		{
			return isPlaying;
		}
		
		/**
		 * returns a progress value for external objects to access the loading state of the sound object
		 * 
		 * @returns Number a percent value as a number
		 */
		public function returnProgress():Number
		{
			return 	progress;
		}
		
		/**
		 * unloads soundObject related events and the object itself.
		 */
		public function unload():void
		{
			audio.removeEventListener(Event.COMPLETE,onCompleteDataLoad);
			audio.removeEventListener(IOErrorEvent.IO_ERROR,onIoError);
			audio.removeEventListener(ProgressEvent.PROGRESS,unload);
			audio = null;
			req = null;
		}
		
		/**
		 * stops a sound.
		 */
		public function stop():void
		{
			channel.stop();
			dispatchEvent(new Event(STOPPED_PLAYING));
		}
		
		/**
		 * lets an external class set this state to debugMode, allows to show alert boxes on screen
		 */
		public function setDebug():void
		{
			this.debugMode=true;
		}
		
		
		//------------------------------------------------------------
		//
		//	PRIVATE FUNCTIONS
		//
		//------------------------------------------------------------
		
		
		/**
		 * @private
		 */
		private function onCompleteDataLoad(event:Event):void
		{
			trace("audio mp3 load complete");
			dispatchEvent(new Event(LOAD_COMPLETE));
		}
		
		
		/**
		 * @private
		 */
		private function onIoError(event:IOErrorEvent):void
		{
			trace("audio mp3 load error");
			dispatchEvent(new Event(ONLOAD_ERROR));
		}
		
		
		/**
		 * @private
		 */
		private function onProgress(event:Event):void
		{
			progress = Math.floor(audio.bytesLoaded/audio.bytesTotal*100);
		}
		
		
		
		/**
		 * @private
		 */
		private function stopAudio(event:Event):void
		{
			if(audio==null)
			{
				return;
			}
			try
			{
				audio.close();
				isPlaying=false;
				dispatchEvent(new Event(PAUSE_PLAYING));
			}catch(e:Error){
				//alert box
				trace("[MP3AUDIO]: Fehler beim Stream schliessen!");
				if(debugMode)
					Alert.show("loading error "+e.message);
				//write new error log
				ErrorDispatcher.processNewError(
					ErrorTypeEnum.CANNOT_PLAY_AUDIO_ERROR.getNumber().toString(),
					ErrorTypeEnum.CANNOT_PLAY_AUDIO_ERROR.getValue(),
					e.errorID.toString(),
					e.name,
					"MP3Audio.as -->"+audio.url,
					scriptUrl,
					false
				);
				//create fallback
				unload();
			}
		}

		
		/**
		 * @private
		 */
		private function onPlayingFinished(event:Event):void
		{
			trace("[MP3AUDIO]: audio playing finished dispatched!");
			dispatchEvent(new Event(FINISHED_PLAYING));
		}
		

		
		


	}
}