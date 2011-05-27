<%-- This JSP creates the navigation links for a logged on user. --%>
<%@ page language="java"%>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="com.google.appengine.api.users.UserService" %>
<%@ page import="com.google.appengine.api.users.UserServiceFactory" %>
<%@ page import="sched.data.model.User" %>
<%@ page import="sched.utils.RequestUtils" %>
<%@ page import="sched.utils.SessionUtils" %>
<%
    // Get UserService for log off URL.
    UserService userServiceNavLabel = UserServiceFactory.getUserService();

    boolean showAdd=false;
    boolean isAdmin=false;
	  boolean isUserForStore=false;
    User currentUser=RequestUtils.getCurrentUser(request);
    if (currentUser!=null)
    {
		isUserForStore=true;

        // If admin
        if (currentUser.getIsAdmin())
        {
            showAdd=true;
            isAdmin=true;
        }
    }

%>
<p>
<%
    ResourceBundle bundle = ResourceBundle.getBundle("Text", SessionUtils.getLocale(request));

	if (isUserForStore)
	{
        // Trades
        //out.write("<a href=\"userApptRequestSwitch.jsp\">");
        //out.write(bundle.getString("tradesLabel"));
        //out.write("</a> | ");

        // Schedule
        out.write("<a href=\"sched.jsp\">");
        out.write("Sched");//bundle.getString("scheduleLabel"));
        out.write("</a>");
	}
    if (showAdd)
    {
        // Add Appt
        //out.write(" | <a href=\"userAppt.jsp\">");
        //out.write(bundle.getString("addApptLabel"));
        //out.write("</a>");
    }
    if (isAdmin)
    {
        // Service
        out.write(" | <a href=\"service.jsp\">");
        out.write("Srvc");//bundle.getString("servicesLabel"));
        out.write("</a>");
    }
	if (isUserForStore)
	{
		out.write(" | <a href=\"user.jsp\">");

		//if (isAdmin)
		//{
			out.write("Usr");//bundle.getString("usersLabel"));
		//}
		//else
		//{
		//	out.write(bundle.getString("userLabel"));
		//}

		// Put | here as there will always be Stores after this link.
		out.write("</a> | ");
	}

    // Set query string.  Use opposite (en vs es).
    String locale=SessionUtils.getLocaleString(request);
    String queryString="";
    if (locale==null || locale.equals("en"))
    {
        queryString="es";
    }
    else
    {
       queryString="en";
    }

%>
<a href="store.jsp">Str</a>

<%-- <p><a href="lang.jsp?locale=<%= queryString %>"><%= bundle.getString("langLabel")%></a> | <a href="about.jsp">Abt</a></a> | <a href="help.jsp"><%= bundle.getString("helpLabel")%></a> | <a href="contactUs.jsp"><%= bundle.getString("contactUsLabel")%></a> | <a href="<%=userServiceNavLabel.createLogoutURL(RequestUtils.getLogonUri(request,true))%>"><%= bundle.getString("logOffLabel")%></a></p> --%>
| <a href="about.jsp">Abt</a> | <a href="<%=userServiceNavLabel.createLogoutURL(RequestUtils.getLogonUri(request,true))%>"><%= bundle.getString("logOffLabel")%></a></p>