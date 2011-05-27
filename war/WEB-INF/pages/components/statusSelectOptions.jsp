<%-- This JSP creates a list of service select options. --%>
<%@ page language="java"%>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="sched.utils.SessionUtils" %>
<%

    ResourceBundle bundle = ResourceBundle.getBundle("Text", SessionUtils.getLocale(request));

    boolean isPending=false;
    Boolean isPendingBoolean=(Boolean)request.getAttribute("isPending");
    if (isPendingBoolean!=null)
    {
        isPending=isPendingBoolean.booleanValue();
    }
    
    out.write("<option value=\"true\"");
    if (isPending)
    {
        out.write(" selected=\"true\"");
    }
    out.write("\">");
    out.write(bundle.getString("pendingLabel"));
    out.write("</option>");

    out.write("<option value=\"false\"");
    if (!isPending)
    {
        out.write(" selected=\"true\"");
    }
    out.write("\">");
    out.write(bundle.getString("confirmedLabel"));
    out.write("</option>");
    
%>