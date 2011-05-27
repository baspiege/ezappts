<%-- This JSP returns the date select. --%>
<%@ page language="java"%>
<%@ page import="java.util.Calendar" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="sched.utils.DateUtils" %>
<%@ page import="sched.utils.SessionUtils" %>

<%
    ResourceBundle bundle = ResourceBundle.getBundle("Text", SessionUtils.getLocale(request));

    // Prefix for the request parameters.
    String prefix=(String)request.getAttribute("apptDatePrefix");

    // Current date
    Calendar currCalendar = DateUtils.getCalendar(request);

    // Year
    int yearSelect;
    Long yearSelectLong=(Long)request.getAttribute(prefix + "Year");
    if (yearSelectLong!=null)
    {
       yearSelect=yearSelectLong.intValue();
    }
    else
    {
       yearSelect=currCalendar.get(Calendar.YEAR);;
    }

    String yearDisplay=bundle.getString(prefix + "YearLabel");

    out.write("<input type=\"text\" name=\"");
    out.write(prefix);
    out.write("Year\" title=\"");
    out.write(yearDisplay);
    out.write("\" value=\"");
    out.write(new Integer(yearSelect).toString());
    out.write("\" size=\"4\" maxlength=\"4\" >");

    // Months
    Long monthSelectLong=(Long)request.getAttribute(prefix + "Month");
    int monthSelect;
    if (monthSelectLong!=null)
    {
       monthSelect=monthSelectLong.intValue();
    }
    else
    {
       monthSelect=currCalendar.get(Calendar.MONTH)+1;
    }

    String monthDisplay=bundle.getString(prefix + "MonthLabel");

    out.write("<input type=\"text\" name=\"");
    out.write(prefix);
    out.write("Month\" title=\"");
    out.write(monthDisplay);
    out.write("\" value=\"");
    out.write(new Integer(monthSelect).toString());
    out.write("\" size=\"2\" maxlength=\"2\" >");

    // Days
    int daySelect;
    Long daySelectLong=(Long)request.getAttribute(prefix + "Day");
    if (daySelectLong!=null)
    {
       daySelect=daySelectLong.intValue();
    }
    else
    {
       daySelect=currCalendar.get(Calendar.DATE);
    }

    String dayDisplay=bundle.getString(prefix + "DayLabel");

    out.write("<input type=\"text\" name=\"");
    out.write(prefix);
    out.write("Day\" title=\"");
    out.write(dayDisplay);
    out.write("\" value=\"");
    out.write(new Integer(daySelect).toString());
    out.write("\" size=\"2\" maxlength=\"2\" >");
%>