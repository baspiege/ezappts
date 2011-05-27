<%-- This JSP creates a list of user select options. --%>
<%@ page language="java"%>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="sched.utils.RequestUtils" %>
<%@ page import="sched.utils.SessionUtils" %>
<%
    
    ResourceBundle bundle = ResourceBundle.getBundle("Text", SessionUtils.getLocale(request));                    
    
    String userType=(String)request.getAttribute("userType");
    
    out.write("<select id=\"userType\" name=\"userType\" title=\"" + bundle.getString("typeLabel") + "\">");
    
    // Customer
    out.write("<option value=\"customer\"");
    if ("customer".equals(userType))
    {
	    out.write(" selected=\"true\"");    
    }
    out.write(">" + bundle.getString("customerLabel") + "</option>");

    // Staff
    out.write("<option value=\"staff\"");
    if ("staff".equals(userType))
    {
	    out.write(" selected=\"true\"");    
    }
    out.write(">" + bundle.getString("staffLabel") + "</option>");
    
    // Admin
    out.write("<option value=\"admin\"");
    if ("admin".equals(userType))
    {
	    out.write(" selected=\"true\"");    
    }
    out.write(">" + bundle.getString("administratorLabel") + "</option>");
    
    out.write("</select>");        
%>