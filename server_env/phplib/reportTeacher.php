<?php


/* ----------------------------------------------------------------------

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

---------------------------------------------------------------------- */

function getContent($img)
{
	$fd = fopen($img, "rb");
	$size = filesize($img);
	$cont = fread($fd, $size);
	fclose($fd);
	
	return $cont;
}
	//header("Content-Type: application/octet-stream");
	

	$user = 	$_POST['user'];
	$script = '../R/teacherReport_break.R';
	$thresh = 100;
	
	$xmlutvonal = exec("$script $user $thresh");

	
	$dir = "/home/otulea/data/user/".$user."/";
	
	$path = $dir.$xmlutvonal;
	
	
	if (file_exists($path)) 
	{
		echo $xmlutvonal;
	}else{
		echo "file does not exist:".$path;
	}
	
/*	if(file_exists($dir.$xmlutvonal))
	{
		$encFile = getContent($dir.$xmlutvonal);
	}else{
		$encFile = "failed: " + $dir.$xmlutvonal+ " not existendt" ;
	}
	
	if($encFile==0)echo "failed: "+ $dir.$xmlutvonal+ " is 0" ;
	echo $encFile;	
	
	
	*/






?>