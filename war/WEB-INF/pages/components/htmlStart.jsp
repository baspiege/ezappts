<%@page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="sched.utils.SessionUtils" %>
<%
    String locale=SessionUtils.getLocaleString(request);
    if (locale==null)
    {
        locale="en";
    }
%>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="<%= locale %>" lang="<%= locale %>">
<head>
<link rel="shortcut icon" href="favicon.ico" />
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=0"/>