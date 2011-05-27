<%-- This JSP has the HTML for the user appt table. --%>
<%@ page language="java"%>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="sched.data.model.Service" %>
<%@ page import="sched.data.model.User" %>
<%@ page import="sched.data.model.Appt" %>
<%@ page import="sched.utils.DateUtils" %>
<%@ page import="sched.utils.DisplayUtils" %>
<%@ page import="sched.utils.HtmlUtils" %>
<%@ page import="sched.utils.RequestUtils" %>
<%@ page import="sched.utils.SessionUtils" %>
<%
    // If there are appts, create a list.
    List appts=(List)request.getAttribute("appts");

    ResourceBundle bundle = ResourceBundle.getBundle("Text", SessionUtils.getLocale(request));

    if (appts!=null && !appts.isEmpty())
    {
        // Users and services
        Map<Long,User> users=(Map<Long,User>)RequestUtils.getUsers(request);
		Map<Long,Service> services=RequestUtils.getServices(request);

        out.write("<table border=\"1\" style=\"text-align:left;\"><tr>");
        out.write("<th>" + bundle.getString("staffLabel") + "</th>");
        out.write("<th>" + bundle.getString("customerLabel") + "</th>");
        out.write("<th>" + bundle.getString("startTimeLabel") + "</th>");
        out.write("<th>" + bundle.getString("endTimeLabel") + "</th>");
        out.write("<th>" + bundle.getString("durationLabel") + "</th>");
        out.write("<th>" + bundle.getString("apptNameLabel") + "</th>");
        out.write("</tr>");

        SimpleDateFormat displayDateTime=new SimpleDateFormat("yyyy MMM dd EEE h:mm aa", SessionUtils.getLocale(request));
        displayDateTime.setTimeZone(RequestUtils.getCurrentStore(request).getTimeZone());

        for (int i=0;i<appts.size();i++)
        {
            Appt appt=(Appt)appts.get(i);

            Date startDate=(Date)appt.getStartDate();
            Date endDate=DateUtils.getEndDate(appt.getStartDate(),appt.getDuration());

            // Get user description
            User user=(User)users.get(new Long(appt.getProviderUserId()));
            String userName=null;
            if (user!=null)
            {
                userName=HtmlUtils.escapeChars(DisplayUtils.formatName(user.getFirstName(),user.getLastName(),false));
            }
            else
            {
                userName="&nbsp;";
            }

            // Get appt template description
            Service service=(Service)services.get(new Long(appt.getServiceId()));
            String serviceDesc=null;
            if (service!=null)
            {
                serviceDesc=HtmlUtils.escapeChars(service.getDesc());
            }
            else
            {
                serviceDesc="&nbsp;";
            }

            out.write("<tr>");

            // User
            out.write("<td>");
			out.write( userName );
            out.write("</td>");

            // Start time
            out.write("<td>");
            out.write(HtmlUtils.escapeChars(displayDateTime.format(startDate)));
            out.write("</td>");

            // End time
            out.write("<td>");
            out.write(HtmlUtils.escapeChars(displayDateTime.format(endDate)));
            out.write("</td>");

            // Duration
            out.write("<td>");
            out.write(HtmlUtils.escapeChars(DisplayUtils.formatDuration(appt.getDuration())));
            out.write("</td>");

            // Service
            out.write("<td>");
            out.write(serviceDesc);
            out.write("</td>");

            out.write("</tr>");
        }

        out.write("</table>");
    }
    else
    {
        out.write("<p>" + bundle.getString("noneLabel") + "</p>");
    }
%>