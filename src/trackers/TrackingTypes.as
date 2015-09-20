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
	public class TrackingTypes
	{
		//MODULE EVENTS
		public static const MODULE_START:String = "Module Start";
		public static const MODULE_FINISHED:String = "Module Finished";
		
		
		//KEYBOARD
		public static const KEYPRESSED_OK:String = "Key Pressed 1";
		public static const KEYPRESSED_WRONG:String = "Key Pressed 2";
		
		
		//DATA EVENTS
		public static const DATA_SEND:String ="Send Data";
		public static const DATA_SEND_FAILED:String ="Data Sending Failed";
		public static const DATA_RECEIVED_OK:String ="Data Successfully Received";
		public static const DATA_RECEIVED_BAD:String ="Data Receive-Fault";
		
		//PERMISSION
		public static const LOGIN_SUCCESS:String ="Login Success";
		public static const LOGIN_FAULT:String ="Login Fault";
		
		//ERROR
		public static const ERROR:String = "ERROR OCCURED!";
		
		//MOUSE EVENTS
		public static const MOUSECLICK:String = "Mouse Clicked";
		public static const MOUSEOVER:String = "Mouse Over";
		public static const MOUSEOUT:String ="Mouse Out";
		public static const MOUSEMOVED:String ="Mouse Moved";
		
	}
}