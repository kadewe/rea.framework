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


/*	Tracking data */

$xml = $_POST['xml'];

$userid = $_POST['id'];

$folder =  $_POST['type'];

$sub = $_POST['sub'];

$images = explode( "#" , $_POST['images']);
$im_paths=explode("#",$_POST['paths']);

print $userid."<br />";
print $folder."<br />";
print $sub."<br />";

print "<br />";
print "<br />";
print "<br />";

print $xml;

print "<br />";
print "<br />";
print "<br />";

print_r($im_paths);

print "<br />";
print "<br />";
print "<br />";

print_r($images);

print "<br />";
print "<br />";
print "<br />";

//PATH and PRINT

$SCRIPT_NAME="[TrackingDataReceiver]: ";

$TIME_STAMP=date("Ymd");

/* CREATE PATH */
mkdir("../data/tracking/".$TIME_STAMP);
$path = "../data/tracking/".$TIME_STAMP."/".$folder;



/*  PRINT PATH */
print $SCRIPT_NAME."data path is >>></br>";
print $path."<br />";


/* create main folders */
if(file_exists($path))
{
	print $SCRIPT_NAME."tracking folder exists"."<br />";
}else{
	print $SCRIPT_NAME."create new tracking folder"."<br />";
	mkdir($path,0777);
	if(file_exists($path))
	{
		print $SCRIPT_NAME."tracking folder created"."<br />";
	}else{
		print $SCRIPT_NAME."tracking folder creation failed"."<br />";
	}
}

/* create sub folders */
if(strlen($sub)>0)
{
	$path.="/".$sub."/";
	if(file_exists($path))
	{
		print $SCRIPT_NAME."tracking folder exists"."<br />";
	}else{
		print $SCRIPT_NAME."create new tracking folder"."<br />";
		mkdir($path,0777);
		if(file_exists($path))
		{
			print $SCRIPT_NAME."tracking folder created"."<br />";
		}else{
			print $SCRIPT_NAME."tracking folder creation failed"."<br />";
		}
	}
}
$imagepath = $path;

/*add user id and write xml file*/
$path.="/".$userid.".xml";

$file = fopen($path, "w");
fputs($file,$xml);
fclose($file);

if(file_exists($path))
{
	print $SCRIPT_NAME."file written"."<br />";
}else{
	print $SCRIPT_NAME."file not written"."<br />";
}


//-------------------------------------------
//
//	save all generated images
//
//-------------------------------------------

print "start saving screenshots<br>";
print $imagepath."<br>";

print "images: "+count($images);
print "paths:  "+count($im_paths);

for($i=0;$i<count($images);$i++)
{
	print "get image<br>";
	$im_path = $imagepath."/".$im_paths[$i];
	print $im_path."<br>";
	
	if(!file_exists($im_path))
	{
		$im = $images[$i];
		$img = imagecreatefromstring(base64_decode($im)); 
		if($img != false) 
		{ 
   			imagepng($img, $im_path);
		} else {
			print "failed to create image at: ".$im_path;	
		}
	}else{
		print "image alreaddy exists";
	}
}




?>