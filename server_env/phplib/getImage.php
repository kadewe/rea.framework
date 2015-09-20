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

//loads a file from path and encodes it to base64 string
function encodeImg($img)
{
	$fd = fopen($img, "rb");
	$size = filesize($img);
	$cont = fread($fd, $size);
	fclose($fd);
	$encImg = base64_encode($cont);
	return $encImg;
}

//debugger function to display immediately in browser
function displayImg($imgEnc, $type)
{
	header('Content-type: image/'.$type);
	header('Content-length: '.strlen($imgEnc));
	echo base64_decode($imgEnc);
}

$imagePath = $_POST['imagePath'];

$filename = "../".$imagePath;


if(file_exists($filename))
{
	$encodedImage = encodeImg($filename);
}else{
	$encodedImage = "failed";
}

echo $encodedImage;



?>