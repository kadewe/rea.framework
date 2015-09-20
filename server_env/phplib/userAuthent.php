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


$pw = $_POST['password'];


$output ="<loginsuccess>";


$link = mysql_connect('localhost', 'sqlUserDummy', 'sqlPasswordDummy', 'reaFrameworkDB');
if (!$link) {
    die('keine Verbindung möglich: ' . mysql_error());
}


$query = mysql_query("SELECT COUNT(*) FROM reaFrameworkDB.user WHERE id = '$pw' ");



$result = mysql_result($query,0);


if($result==1)
{
	$output.="yes";
}else{
	$output.="no";

}


$xml="";


$output.="</loginsuccess>";
$output.="<userDataUrl>";
$output.= $pw;
$output.="</userDataUrl>";
$output.="<sqlresult>";
$output.= $result;
$output.="</sqlresult>";
$output.="<file>";
$output.="</file>";
$output.="<path>";
$output.= "../data/user/".$pw."/".$pw.".xml";
$output.="</path>";


print $output;


mysql_close($link);
?>