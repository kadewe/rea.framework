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

function makeDownload($file, $dir, $type) {
    
    header("Content-Type: application/pdf");

    header("Content-Disposition: attachment; filename=$file");

	
    readfile($dir.$file);
    
}

$user = 	$_POST['user'];
$dir = "../data/user/".$user."/";
$type = 	$_POST['type'];

$display = $_POST['display'];

if(!empty($_POST['file']) && !preg_match('=/=', $_POST['file'])) 
{
    if(file_exists ($dir.$_POST['file']))
	{
        makeDownload($_POST['file'], $dir, $type);
    }
}else{
	echo "error";	
}

?>
<html>
<body onLoad="window.print()">
</body>
</html>