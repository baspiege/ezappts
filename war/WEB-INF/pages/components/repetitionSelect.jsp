<%-- This JSP returns the duration select. --%>
<%@ page language="java"%>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="sched.utils.SessionUtils" %>

<%
    ResourceBundle bundle = ResourceBundle.getBundle("Text", SessionUtils.getLocale(request));

    // Prefix for the request parameters.
    String prefix=(String)request.getAttribute("apptDatePrefix");

    // Repetition
    int repetitionSelect;
    Long repetitionSelectLong=(Long)request.getAttribute(prefix + "Repetition");
    if (repetitionSelectLong!=null)
    {
       repetitionSelect=repetitionSelectLong.intValue();
    }
    else
    {
       repetitionSelect=1;
    }

    out.write("<input type=\"text\" name=\"");
    out.write(prefix);
    out.write("Repetition\" title=\"");
    out.write(bundle.getString("timesLabel"));
    out.write("\" value=\"");
    out.write(new Integer(repetitionSelect).toString());
    out.write("\" size=\"2\" maxlength=\"2\" >");

    out.write("<label for=\"");
    out.write(prefix);
    out.write("Repetition\"> " + bundle.getString("timesLabel") + " </label> ");

    // Repetition Type
    int daysBetweenSelect;
    Long daysBetweenSelectLong=(Long)request.getAttribute(prefix + "DaysBetweenRepetitions");
    if (daysBetweenSelectLong!=null)
    {
       daysBetweenSelect=daysBetweenSelectLong.intValue();
    }
    else
    {
       daysBetweenSelect=1;
    }

    out.write("<input type=\"text\" name=\"");
    out.write(prefix);
    out.write("DaysBetweenRepetitions\" title=\"");
    out.write(bundle.getString("daysBetweenRepetitionsLabel"));
    out.write("\" value=\"");
    out.write(new Integer(daysBetweenSelect).toString());
    out.write("\" size=\"2\" maxlength=\"2\" >");

    out.write("<label for=\"");
    out.write(prefix);
    out.write("DaysBetweenRepetitions\"> " + bundle.getString("daysBetweenRepetitionsLabel") + "</label> ");
%>