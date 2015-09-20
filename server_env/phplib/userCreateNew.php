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

// Generate a random password
function generatePW($length=5)
{
 
	//$dummy = array_merge(range('0', '9'), range('a', 'z'), range('A', 'Z'), array('#','&','@','$','_','%','?','+'));
	$dummy = array_merge(array('A','B','C','D','E','F','G','H'), array('I','K','L','M','O','R','S','T'), array('U','W','X','Y','Z'), array('1','2','3','4','5','6','7','8','9'));
	 
	// shuffle array
	mt_srand((double)microtime()*1000000);
	
	for ($i = 1; $i <= (count($dummy)*2); $i++)
	{
		$swap = mt_rand(0,count($dummy)-1);
		$tmp = $dummy[$swap];
		$dummy[$swap] = $dummy[0];
		$dummy[0] = $tmp;
	}
	 
	// get password
	return substr(implode('',$dummy),0,$length);
 
}

$link = mysql_connect('localhost', 'sqlUserDummy', 'sqlPasswordDummy', 'reaFrameworkDB');
if (!$link) {
	echo"fail to connect db";
    die('keine Verbindung möglich: ' . mysql_error());
}


$result = 0;

while ($result == 0 ) {
	$pass = generatePW(5);
	
	$result = mysql_query("INSERT INTO reaFrameworkDB.user(id) VALUES(\"$pass\")");
	if (!$result) {
	echo "fail to insert value into table";
    die('Ungültige Abfrage: ' . mysql_error());
	}
}


mysql_close($link);





//background


$dir = "../data/user/". $pass;

if (!file_exists($dir) && !is_dir($dir)) {
    mkdir($dir);         
} 

$datapath = "../data/user/". $pass."/".$pass.".xml";

$content = "<performedtests></performedtests>";

$file = fopen($datapath,"w");
fputs($file, $content);
fclose($file);

if (!file_exists($dir) && !is_dir($dir)) {
    echo "could not create directory ".$dir;
	die("directory fail");        
} 

//return new user path
echo "<userDataUrl>".$pass."</userDataUrl>";

?> 