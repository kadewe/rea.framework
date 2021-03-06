# rea.framework


## Licence

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





## Installation

### Requirements

Server:

* Apache Webserver
* php / mysql (you need the simple_xml library)

* Adobe Flex Sdk 4.6 (Better: Apache Flex current Build)
* A Flex IDE for development

### Procedure

1. Extract the 'server_env' folder's content on your server environment and set the following rights (recursively):
```
data 0644
phplib 0644
wwwroot 0775
```
  1. if you are developing in XAMPP (on MacOSX), you must run the following commands:
```
$ cd /path/to/reaframework/
$ sudo chown -R nobody:nobody data/
```
This ensures, that your XAMPP php can manipulate directories (mkdir()) in your data folder.


  2. Root path is currently set to '/localhost/reaframework/' so you have to configure the paths in the following file, if you want to run on your server:
```
reaApplication/Assets/globals.xml (in your client app src)
```

2. The user login works with a mysql database. 

You can import the reaFrameworkDB.sql via phpMyadmin.

The login settings are currently the following:
```
dbhost: localhost
dbname: reaFrameworkDB
dbuser: sqlUserDummy
dbpw:   sqlPasswordDummy
```
If you want to experiment in your XAMPP environment, you can create a user with these settings. It is NOT recommended to to so on a running server! For this purpose, create a new mysql user (see phpmyadmin) and modify the following files:
```
phplib/userCreateNew.php
phplib/userAuthent.php
```
There you have to change the line
```
$link = mysql_connect('localhost', 'sqlUserDummy', 'sqlPasswordDummy', 'reaFrameworkDB');
```
to reaplce it with your values.


3. Compile your client application and copy the exported files into your wwwroot folder.
The client application 

### Further Reading

We aimed to provide a comprehensive Actionscript Documentation, which can be viewed in the browser. Try to open the asdoc-outpu/index.html page

### Notes for Apache Flex Users

This framework has been build using Flex 4.6. If you intend to build with Apache Flex, beware, that there were recent changes in basic classes like ArrayList! Errors may occur and need to be fixed before you can run.
