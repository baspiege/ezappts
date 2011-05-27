<%-- This JSP returns the duration select. --%>
<%@ page language="java"%>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="sched.utils.SessionUtils" %>

<%

    ResourceBundle bundle = ResourceBundle.getBundle("Text", SessionUtils.getLocale(request));

    // Prefix for the request parameters.
    String prefix=(String)request.getAttribute("apptDatePrefix");

    String hourDisplay=bundle.getString(prefix + "HoursLabel");

    // Hour
    int hourSelect;
    Long hourSelectLong=(Long)request.getAttribute(prefix + "Hour");
    if (hourSelectLong!=null)
    {
       hourSelect=hourSelectLong.intValue();
    }
    else
    {
       hourSelect=0;
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

    out.write("<label for=\"");
    out.write(prefix);
    out.write("Hour\"> " + bundle.getString("hoursLabel") + "</label> ");

    // Minute
    int minuteSelect;
    Long minuteSelectLong=(Long)request.getAttribute(prefix + "Minute");
    if (minuteSelectLong!=null)
    {
       minuteSelect=minuteSelectLong.intValue();
    }
    else
    {
       minuteSelect=30;
    }

    String minuteDisplay=bundle.getString(prefix + "MinutesLabel");

    out.write("<input type=\"text\" name=\"");
    out.write(prefix);
    out.write("Minute\" title=\"");
    out.write(minuteDisplay);
    out.write("\" value=\"");
    out.write(new Integer(minuteSelect).toString());
    out.write("\"");

    // Id
    out.write(" id=\"");
    out.write(prefix);
    out.write("Minute");
    out.write("\"");

    out.write(" size=\"2\" maxlength=\"2\" >");

    out.write("<label for=\"");
    out.write(prefix);
    out.write("Minute\"> " + bundle.getString("minutesLabel") + "</label>");
%>