<%-- This JSP creates the navigation links for an un-authenticated user. --%>
<%@ page language="java"%>
<%@ page import="java.util.Locale" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="sched.utils.SessionUtils" %>
<%
    // Set query string.  Use opposite (en vs es).
    String locale=SessionUtils.getLocaleString(request);
    String queryString="";
    if (locale==null || locale.equals("en"))
    {
        queryString="es";
    }
    else
    {
       queryString="en";
    }

    ResourceBundle bundle = ResourceBundle.getBundle("Text", SessionUtils.getLocale(request));
%>
<div style="float:right;">
<%-- <p><a href="lang.jsp?locale=<%= queryString %>"><%= bundle.getString("langLabel")%></a> | <a href="about.jsp"><%= bundle.getString("aboutLabel")%></a> | <a href="help.jsp"><%= bundle.getString("helpLabel")%></a> | <a href="contactUs.jsp"><%= bundle.getString("contactUsLabel")%></a></p> --%>
<p><a href="about.jsp"><%= bundle.getString("aboutLabel")%></a></a></p>
</div>
<div style="clear:both;"/>