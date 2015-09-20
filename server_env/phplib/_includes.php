<?php


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

$param = $_POST['param'];
//echo("param: ".$param);
	switch($param)
	{
		//------------ DATA ACCESS ------------//
		case('getFile'):
			include_once('getXML.php');
			break;
			
		case('getImage'):
			include_once('getImage.php');
			break;
			
		case('getAudio'):
			include_once('getAudio.php');
			break;
			
		case('getItem'):
			include_once('getItem.php');
			break;			
		
		case('checkItem'):
			include_once('getItemCheck.php');
			break;
			
		case('download'):
			include_once('getDownloadLink.php');
			break;
		
		//------------ USER DATA ------------//	
			
		case('login'):
			include_once('userAuthent.php');
			break;
			
		case('getUser'):
			include_once('userLoadSourceFile.php');
			break;
	
		case('newuser'):
			include_once('userCreateNew.php');
			break;
			
		case('updateUser'):
			include_once('userUpdateSourceFile.php');
			break;
			
		case('sendFinalXml'):
			include_once('userUpdateItemResult.php');
			break;
			
			
		//------------ REPORT CALLS ------------//	
		case('teacher'):
			include_once('reportTeacher.php');
			break;
		case('r'):
			include_once('reportStudent.php');
			break;
			
		
		//------------ TRACKING ------------//	
		
		case('sendError'):
			include_once('trackError.php');
			break;
	
		case('tracking'):
			include_once('trackInput.php');
			break;
			
		//------------ MISC ------------//		
			
		case('admin'):
			include_once('adm.php');
			break;
			
		default:
		echo $param." no script loaded";
			break;
	}
	
	die();
?>