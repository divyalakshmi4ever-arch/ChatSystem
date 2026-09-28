SIMPLE CHATTING SYSTEM
=======================

Technologies:
JSP, Servlet, AJAX, JDBC, MySQL, HTML/CSS, Maven

REQUIREMENTS:
- JDK 17
- Eclipse Enterprise Java
- Apache Tomcat 10.1+
- MySQL
- Maven

1. DATABASE
-----------
Open MySQL Workbench and run database.sql.

2. MYSQL PASSWORD
-----------------
Open:
src/main/java/com/chat/util/DBConnection.java

Change:
private static final String PASSWORD = "YOUR_MYSQL_PASSWORD";

to your actual MySQL root password.

3. ECLIPSE
----------
Import this folder as:
File -> Import -> Maven -> Existing Maven Projects

Select the ChatSystem folder.

4. TOMCAT
---------
Add Apache Tomcat 10.1+ to Eclipse.

Right click project:
Run As -> Run on Server

5. LOGIN
--------
Use:
divya
or
arun

6. TEST CHAT
------------
Open two browser windows/incognito windows.
Login as divya in one.
Login as arun in another.
Select the other user and send messages.

AJAX:
- Sending uses fetch() POST without page refresh.
- Messages are fetched using fetch() GET.
- Chat automatically refreshes every 2 seconds.

IMPORTANT:
If your MySQL port is not 3306, change it in DBConnection.java.

If your MySQL username is not root, change USER in DBConnection.java.
