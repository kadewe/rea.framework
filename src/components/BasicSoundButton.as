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
package components
{
	import flash.events.MouseEvent;
	
	import utils.MP3Audio;

	
	/**
	 * Extends CustomButton and keeps a reference to an MP3Audio object.
	 */
	public class BasicSoundButton extends ReaButton
	{
		/**
		 * Constructor. Calls super constructor.
		 */
		public function BasicSoundButton()
		{
			super();
		}
		
		
		//----------------------------------------------
		//
		//	CONSTANTS / VARIABLES
		//
		//----------------------------------------------
		
		//-------------------------------
		// SOUND Reference
		//-------------------------------
		
		protected var _sound:MP3Audio;

		/**
		 * Sound Object which plays mp3 sounds.
		 */
		public function get sound():MP3Audio
		{
			return _sound;
		}
		
		
		//-------------------------------
		// include script reference
		//-------------------------------
		/**
		 * url to php script for loading the refered sound
		 */
		protected var _scriptUrl:String;
		
		/**
		 * url to php script for loading the refered sound
		 */
		public function get scriptUrl():String
		{
			return _scriptUrl;
		}
		
		/**
		 * url to php script for loading the refered sound
		 */
		public function set scriptUrl(value:String):void
		{
			_scriptUrl = value;
		}
		
		//----------------------------------------------
		//
		//	PUBLIC METHODS
		//
		//----------------------------------------------
		
		/**
		 * @override
		 */
		override public function unload():void
		{
			_sound.unload();
			_sound=null;
			super.unload();
		}
		
		
		protected var _mute:Boolean;
		
		public function set mute(value:Boolean):void
		{
			_mute = value;
		}
		
		
		/**
		 * Adds an event listener for MouseOver to the Button which will play sound on hover.
		 * Can be used in mxml to quick set play behavior.
		 */
		public function set playHover(value:Boolean):void
		{
			if(!value)return;
			this.addEventListener(MouseEvent.MOUSE_OVER, playSound);
		}
		
		/**
		 * Adds an event listener for Click to the Button which will play sound on click.
		 * Can be used in mxml to quick set play behavior.
		 */
		public function set playClick(value:Boolean):void
		{
			if(!value)return;
			this.addEventListener(MouseEvent.CLICK,playSound);
		}
		
		/**
		 * Sets the url for the sound object source.
		 * 
		 * @param url the relative url to the sound. Will be attached as post parameter to the include script.
		 * 
		 * @see MP3Audio
		 */
		public function set source(url:String):void
		{
			if(!url || !_scriptUrl)return;
			_sound = new MP3Audio(_scriptUrl,url);
		}
		
		//----------------------------------------------
		//
		//	PROTECTED METHODS
		//
		//----------------------------------------------
		
		/**
		 * plays sound based on which event has been connected
		 */
		protected function playSound(event:MouseEvent):void
		{
			if(!_sound || _mute)return;
			_sound.playAudio();
		}
	}
}