set JAVA_HOME=c:\Program Files\Java\jdk1.6.0_15\bin

"%JAVA_HOME%\java" -cp "c:\dev\appengine-java-sdk-1.3.6\lib\appengine-tools-api.jar" ^
    com.google.appengine.tools.KickStart ^
       com.google.appengine.tools.development.DevAppServerMain %*