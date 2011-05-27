<%-- This JSP creates a list of edits. --%>
<%@ page language="java"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="sched.utils.SessionUtils" %>
<%@ page import="sched.utils.HtmlUtils" %>
<%
    ResourceBundle bundle = ResourceBundle.getBundle("Text", SessionUtils.getLocale(request));

    // Get edits
    List edits=(List)request.getAttribute("edits");
    if (edits!=null && edits.size()>0)
    {
        out.write("<div class=\"edits\">");
        out.write("<br/><b>" + bundle.getString("requestNotProcessedEditLabel") + "</b><ul>");

        for (int i=0;i<edits.size();i++)
        {
            out.write("<li>");
            out.write(HtmlUtils.escapeChars((String)edits.get(i)));
            out.write("</li>");
        }

        out.write("</ul>");
        out.write("</div>");
    }
%>
