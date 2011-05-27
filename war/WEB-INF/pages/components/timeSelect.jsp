<%-- This JSP returns the user list for a select. --%>
<%@ page language="java"%>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="sched.utils.DateUtils" %>
<%@ page import="sched.utils.SessionUtils" %>

<%
    ResourceBundle bundle = ResourceBundle.getBundle("Text", SessionUtils.getLocale(request));

    // Prefix for the request parameters.
    String prefix=(String)request.getAttribute("apptDatePrefix");

    String hourDisplay=bundle.getString(prefix + "HourLabel");

    // Hour
    int hourSelect;
    Long hourSelectLong=(Long)request.getAttribute(prefix + "Hour");
    if (hourSelectLong!=null)
    {
       hourSelect=hourSelectLong.intValue();
    }
    else
    {
       hourSelect=6;
    }

    out.write("<input type=\"text\" name=\"");
    out.write(prefix);
    out.write("Hour\" title=\"");
    out.write(hourDisplay);
    out.write("\" value=\"");
    out.write(new Integer(hourSelect).toString());
    out.write("\"");

    // Id
    out.write(" id=\"");
    out.write(prefix);
    out.write("Hour");
    out.write("\"");

    out.write(" size=\"2\" maxlength=\"2\" >");

    out.write(" : ");

    // Minute
    int minuteSelect;
    Long minuteSelectLong=(Long)request.getAttribute(prefix + "Minute");
    if (minuteSelectLong!=null)
    {
       minuteSelect=minuteSelectLong.intValue();
    }
    else
    {
       minuteSelect=0;
    }

    String minuteDisplay=bundle.getString(prefix + "MinuteLabel");

    out.write("<input type=\"text\" name=\"");
    out.write(prefix);
    out.write("Minute\" title=\"");
    out.write(minuteDisplay);
    out.write("\" value=\"");

    if (minuteSelect<10)
    {
        // Extra zero
        out.write("0");
    }

    out.write(new Integer(minuteSelect).toString());
    out.write("\"");

    // Id
    out.write(" id=\"");
    out.write(prefix);
    out.write("Minute");
    out.write("\"");

    out.write(" size=\"2\" maxlength=\"2\" >");

    // AM/PM
    String amPmString=(String)request.getAttribute(prefix + "AmPm");

    boolean isAm=true;
    if (amPmString!=null)
    {
       isAm=amPmString.equals(DateUtils.AM);
    }

    String startAmDisplay=bundle.getString(prefix + "AmLabel");
    String startPmDisplay=bundle.getString(prefix + "PmLabel");

    out.write("<input type=\"radio\" name=\"");
    out.write(prefix);
    out.write("AmPm\" title=\"");
    out.write(startAmDisplay);
    out.write("\" value=\"AM\" id=\"");
    out.write(prefix);
    out.write("Am\"");
    out.write((isAm?" checked=\"checked\"":""));
    out.write("/><label for=\"");
    out.write(prefix);
    out.write("Am\">AM</label>");

    out.write("<input type=\"radio\" name=\"");
    out.write(prefix);
    out.write("AmPm\" title=\"");
    out.write(startPmDisplay);
    out.write("\" value=\"PM\" id=\"");
    out.write(prefix);
    out.write("Pm\"");
    out.write((!isAm?" checked=\"checked\"":""));
    out.write("/><label for=\"");
    out.write(prefix);
    out.write("Pm\">PM</label>");
%>