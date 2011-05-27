<%-- This JSP creates a list of time zone select options. --%>
<%@ page language="java"%>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.List" %>
<%@ page import="sched.utils.DateUtils" %>
<%@ page import="sched.utils.HtmlUtils" %>
<%@ page import="sched.utils.RequestUtils" %>
<%
	String timeZone=(String)request.getAttribute("timeZone");

	// List timezones
	List timezonesList=DateUtils.getTimeZones();
	Collections.sort(timezonesList);
	for (int i=0;i<timezonesList.size(); i++)
	{
		String timeZoneEntry=(String)timezonesList.get(i);

		out.write("<option");

		// Selected
		if (timeZoneEntry.equals(timeZone))
		{
			out.write(" selected=\"true\"");
		}
		out.write(">");
		out.write(HtmlUtils.escapeChars(timeZoneEntry));
		out.write("</option>");
	}
%>