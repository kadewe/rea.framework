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

/*	Student version of report	*/


$user = $_POST['user']; // user id

$test = $_POST['test']; // timestamp of the test to be evaluated (as specified in the global user file, f.i. 2014_3_3_20_32_49)

echo '<results>
  <print file="'.$test.$user.'"/>
  <timestamp order="YmdHis" value="'.$test.'"/>
  <subject value="Example Subject"/>
  <level value="Schwer"/>
  <eval mode="A1">
    <alphanode alphaID="A001" userdescription="Ich kann dies das" example="mal hier mal da"/>
    <alphanode alphaID="A002" userdescription="Ich kann noch mehr" example="Beispieltext"/>
    <alphanode alphaID="A003" userdescription="Ich kann so richtig viel." example="So viel wie du."/>
  </eval>
  <eval mode="A2">
    <alphanode alphaID="B001" userdescription="Ich muss das noch lernen" example="f(x)=x-2"/>
    <alphanode alphaID="B002" userdescription="Ich muss das auch noch lenerne" example="1,2,3..."/>
  </eval>
</results>';


?>
