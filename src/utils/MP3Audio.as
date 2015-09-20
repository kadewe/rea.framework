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
package utils
{
	import enums.GlobalConstants;
	
	import events.CustomEventDispatcher;
	
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
	
	import interfaces.ICustomEventDispatcher;
	import interfaces.IDisposable;


	/**
	 * Creates a new wrapper for loaded mp3 files. Can handle all required events for a common mp3 player like play, pause, stop etc. The underlying data structure is a Sound Object.
	 * 
	 * @see flash.media.Sound
	 * @see flash.media.SoundChannel
	 */
	public class MP3Audio extends CustomEventDispatcher implements ICustomEventDispatcher, IDisposable
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
		
		/**
		 * Link to parent object which 'keeps' this one.
		 */
		public var parent:Object;
		
		/**
		 * Identifiable ID of this sound object
		 */
		public var id:String;
		
		//------------------------------------
		// Events
		//------------------------------------
		
		/**
		 * Disptached when MP3 data has been loaded correctly.
		 */
		public static const LOAD_COMPLETE:String = "loadComplete";
		
		/**
		 * Dispatched when the sound starts playing
		 */
		public static const START_PLAYING:String = "startPlaying";
		
		/**
		 * Dispatched when the sound is paused.
		 */
		public static const PAUSE_PLAYING:String = "pausePlaying";
		
		/**
		 * Dispatched when the sound has completed plaing.
		 */
		public static const FINISHED_PLAYING:String  = "finishedPLaying";
		
		/**
		 * Dispatched when playing has been stopped.
		 */
		public static const STOPPED_PLAYING:String = "stoppedPlaying";
		
		/**
		 * Dispatched when the component has been initialized
		 */
		public static const INIT_COMPLETE:String = "initComplete";
		
		/**
		 * Dispatched when an error occured while loading mp3 data
		 */
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

			this.scriptUrl = _scriptUrl;
			this.relPath = relPath;
			//--------------------//
			
			audio = new Sound();
			
			audio.addEventListener(Event.COMPLETE, onCompleteDataLoad);
			audio.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
			audio.addEventListener(ProgressEvent.PROGRESS, onProgress);
			
			trace("[MP3AUDIO]: script url: "+scriptUrl+"  path: "+relPath);
			var v:URLVariables = new URLVariables();
				v.param = GlobalConstants.GET_AUDIO;
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
				trace("[MP3AUDIO]: LOADER ERROR");
				trace("[MP3AUDIO]: "+e.message);
				unload();
			}
			dispatchEvent(new Event(INIT_COMPLETE));
			if(navigate)
				navigateToURL(req,"new");
				//navigateToURL(req,"new");	//DEBUG
		}
		

		/**
		 * unloads soundObject related events and the object itself.
		 */
		public function unload():void
		{
			//unload audio
			audio.removeEventListener(Event.COMPLETE,onCompleteDataLoad);
			audio.removeEventListener(IOErrorEvent.IO_ERROR,onIoError);
			audio.removeEventListener(ProgressEvent.PROGRESS,unload);
			audio = null;
			
			//unload loaders
			req = null;
			context=null;
			
			//unload refss
			parent=null;
			channel = null;
		}
		
		

		/**
		 * opens the soundchannel and adds the playing soundobject to it. enabled to autodetect, when the soundobject finished playing. isPlaying will be set to true.
		 * Does nothing if the sound object is null. This can happen for example if the unload method was called external or internal when an error occured.
		 * 
		 * @see #returnIsPlaying()
		 */
		public function playAudio(e:*=null):void
		{
			//do nothing if audio is null
			utils.ReaVisualUtils.fadeOutSound();
			utils.ReaVisualUtils.stopPulse();
			
			if(audio==null)
			{
				trace("[MP3AUDIO]: Audio is null");
				isPlaying = false;
				dispatchEvent(new Event(FINISHED_PLAYING));
				return;
			}
			
			try
			{
				channel=audio.play();
				channel.addEventListener(Event.SOUND_COMPLETE, onPlayingFinished);
				isPlaying=true;
				dispatchEvent(new Event(START_PLAYING));
			}
			catch(error:Error)
			{
				trace("[MP3AUDIO]: Fehler beim abspielen der Sounddatei");
				//if(debugMode)
				trace(error.message);
				//fallback
				isPlaying=false;
				dispatchEvent(new Event(FINISHED_PLAYING));
				//unload();
			}
			
		}
		
		
		/**
		 * Manually pauses the sound object.
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
				trace(e.message);
				//create fallback
				//unload();
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
			dispatchEvent(new Event(LOAD_COMPLETE));
		}
		
		
		/**
		 * @private
		 */
		private function onIoError(event:IOErrorEvent):void
		{
			audio=null;
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
			//else
			try
			{
				audio.close();
				isPlaying=false;
				dispatchEvent(new Event(PAUSE_PLAYING));
			}catch(e:Error){
				//alert box
				trace("[MP3AUDIO]: Fehler beim Stream schliessen!");
				//create fallback
				unload();
			}
		}

		
		/**
		 * @private
		 */
		private function onPlayingFinished(event:Event):void
		{
			dispatchEvent(new Event(FINISHED_PLAYING));
		}
		

		
		


	}
}