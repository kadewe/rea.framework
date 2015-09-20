<?php

$item = $_POST['itemid'];

$path = "../data/item/".$item."/".$item . ".xml";

if (file_exists($path)) 
{
	echo $item;
} else {
	echo "failed";
}

?>