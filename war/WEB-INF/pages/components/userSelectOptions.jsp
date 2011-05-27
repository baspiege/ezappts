<%-- This JSP creates a list of user select options. --%>
<%@ page language="java"%>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Map.Entry" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="sched.data.model.User" %>
<%@ page import="sched.utils.DisplayUtils" %>
<%@ page import="sched.utils.HtmlUtils" %>
<%@ page import="sched.utils.SessionUtils" %>
<%
    ResourceBundle bundle = ResourceBundle.getBundle("Text", SessionUtils.getLocale(request));

    Map<Long,User> users=(Map<Long,User>)request.getAttribute("users");
    if (users!=null)
    {
        long userIdSelect=0;
        Long userIdSelectLong=(Long)request.getAttribute("customerId");
        if (userIdSelectLong!=null)
        {
           userIdSelect=userIdSelectLong.longValue();
        }

        Iterator iter = users.entrySet().iterator();
        while (iter.hasNext())
        {
            Entry entry = (Entry)iter.next();
            User user=(User)entry.getValue();

            long userId=user.getKey().getId();

            out.write("<option");

            // Selected
            if (userIdSelect==userId)
            {
                out.write(" selected=\"true\"");
            }

            out.write(" value=\"");
            out.write( new Long(userId).toString() );
            out.write("\">");
            out.write( HtmlUtils.escapeChars(DisplayUtils.formatName(user.getFirstName(),user.getLastName(),true)) );
            out.write("</option>");
        }
        
        out.write("<option value=\"" + User.NO_USER + "\"");

        // No user selected
        if (userIdSelect==User.NO_USER)
        {
            out.write(" selected=\"true\"");
        }

        out.write("\">");

        out.write(bundle.getString("noCustomerLabel"));

        out.write("</option>");
    }
%>