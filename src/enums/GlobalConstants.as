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
package enums
{
	public class GlobalConstants
	{
		//======================================================================================================================================================
		//
		//
		//
		//
		//		APP SETTINGS
		//
		//
		//
		//======================================================================================================================================================
		
		public static const DEBUG:String = "debug";
		public static const IGNORE_SOUND:String = "ignoresound";
		public static const SHOW_CURRENT_SESSION:String = "showcurrentsession";
		public static const SHOW_NEXTITEM_BUTTON:String = "nextItemButton";
		public static const SHOW_SKIP_TWEEN_BUTTON:String ="skipTweenButoon";
		public static const SCAFFOLDING:String = "scaffolding";
		public static const TRACKINPUT:String ="trackInput";
		
		//======================================================================================================================================================
		//
		//
		//
		//
		//		MODULE NAMING CONVENTIONS
		//
		//
		//
		//======================================================================================================================================================
		private static const MAIN:String = "MainApplication.";
		private static const DISPLAY:String = "DisplayApplication.";
		private static const ITEM:String = "ItemApplication.";
		
		public static const STARTAPP_MOD:String = MAIN + "StartAppModule";
		public static const LOGIN_MOD:String = MAIN +"LoginModule";
		public static const OVERVIEW_MOD:String =MAIN+"OverviewModule";
		public static const TESTFINISH_MOD:String = MAIN+"TestFinishedModule";
		public static const ITEM_MOD:String = ITEM + "ItemModule";
		
		
		//======================================================================================================================================================
		//
		//
		//
		//
		//		PHP INCLUDE SCRIPT PARAMETER TYPES
		//
		//
		//
		//======================================================================================================================================================
		
		/**
		 * The parameter name to access the loginScript in the php include file.
		 */
		public static const LOGIN:String = "login";
		
		/**
		 * The parametername to access the getUser script in the php include file.
		 */
		public static const GET_USERDATA:String = "getUser";
		
		
		public static const GET_FILE:String ="getFile";
		
		/**
		 * The parametername to access the getImage script in the php include file.
		 */
		public static const GET_IMAGE:String="getImage";
		
		/**
		 * The parametername to access the getAudio script in the php include file.
		 */
		public static const GET_AUDIO:String="getAudio";
		
		/**
		 * The parametername to access the newUser script in the php include file.
		 */
		public static const CREATE_NEW_USER:String="newUser";
		
		/**
		 * The parametername to access the updateUser script in the php include file.
		 */
		public static const UPDATE_USER:String="updateUser";
		
		/**
		 * The parametername to access the sendFinalXml script in the php include file.
		 */
		public static const SEND_FINAL_XML:String="sendFinalXml";
		
		/**
		 * The parametername to access the getItem script in the php include file.
		 */
		public static const GET_ITEM_DATA:String="getItem";
		/**
		 * The parametername to access the sendError script in the php include file.
		 */
		public static const SEND_ERROR_MESSAGE:String="sendError";
		
		/**
		 * The parametername to access the getVideo script in the php include file.
		 */
		public static const GET_VIDEO:String="getVideo";
		
		/**
		 * The parametername to access the getVideo script in the php include file.
		 */
		public static const CHECK_ITEM_DATA:String="checkItem";
		
		
		//======================================================================================================================================================
		//
		//
		//
		//
		//		PHP URL TYPES
		//
		//
		//
		//======================================================================================================================================================
		
		/**
		 * Represents the root url on the server. It must be a realtive path to the root directory of this application and will be combined with other paths to load specific data or scripts
		 * 
		 * <p>Example: <code>http://mydomain.subdomain.com/apps/thisapp/</code></p>
		 */
		public static const ROOT:String="rootUrl";
		
		/**
		 * The relative path to the includescript. Must be combined with ROOT to a full usable url
		 */
		public static const INCLUDE_SCRIPT:String="includeScript";
		
		/**
		 * The relative path to the application sounds on the serve. Does not include item sounds. Must be combined with ROOT. 
		 */
		public static const SOUNDS:String="soundPath";
		
		/**
		 * The relative path to the userData directories. Must be combined with ROOT.
		 */
		public static const USER:String="userPath";
		
		/**
		 * The relative path to the itemData directories. Must be combined with ROOT. 
		 */
		public static const ITEMSPATH:String="itemsPath";
		
		
		public static const MEDIA:String="videos";
		
		
		public static const END_REDIRECT:String="endAppRedirect";
		
		//======================================================================================================================================================
		//
		//
		//
		//
		//		ERROR TYPES
		//
		//
		//
		//======================================================================================================================================================
		
		
		public static const CANNOT_PLAY_AUDIO_ERROR:String="Audio error, cannot play Audiofile. Eitehr invalid format or null.";
		
		public static const URL_INVALID_ERROR:String="The requested URL is invalid or null.";
		
		public static const CANNOT_LOAD_MODULE:String="the moduleclass is not recognized or null.";
		
		public static const NULLREFERENCE:String="an object is null";
		
	}
}