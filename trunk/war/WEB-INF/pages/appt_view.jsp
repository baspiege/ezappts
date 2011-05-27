<%-- This JSP has the HTML for the user appt page. --%>
<%@ page language="java"%>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Map.Entry" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.TimeZone" %>
<%@ page import="sched.data.RoleUtils" %>
<%@ page import="sched.data.UserGetSingle" %>
<%@ page import="sched.data.ApptGetSingle" %>
<%@ page import="sched.data.model.Role" %>
<%@ page import="sched.data.model.Service" %>
<%@ page import="sched.data.model.User" %>
<%@ page import="sched.data.model.Appt" %>
<%@ page import="sched.utils.DateUtils" %>
<%@ page import="sched.utils.DisplayUtils" %>
<%@ page import="sched.utils.HtmlUtils" %>
<%@ page import="sched.utils.RequestUtils" %>
<%@ page import="sched.utils.SessionUtils" %>
<%    
    // Set the current store into the request.
    SessionUtils.setCurrentStoreIntoRequest(request);

    // Verify user is logged on.
    // Verify user has access to the store.
    if (!SessionUtils.isLoggedOn(request)
        || !RequestUtils.isCurrentUserInStore(request))
    {
        RequestUtils.resetAction(request);
        RequestUtils.removeEdits(request);
        %>
        <jsp:forward page="/logonForward.jsp"/>
        <%
    }
    
    // Get current user.
    User currentUser=RequestUtils.getCurrentUser(request);

    ResourceBundle bundle = ResourceBundle.getBundle("Text", SessionUtils.getLocale(request));        
    
    // Get appt Id
    Long userApptId=RequestUtils.getNumericInput(request,"a",bundle.getString("apptIdLabel"),false);
    if (userApptId==null)
    {
        // No appt. 
        RequestUtils.resetAction(request);
        RequestUtils.removeEdits(request);
        %>
        <jsp:forward page="/sched.jsp"/>
        <%
    }
        
    // Get services
    Map<Long,Service> services=RequestUtils.getServices(request);

    // Get users
    Map<Long, User> users=RequestUtils.getUsers(request);	    
    
    // Get appt.
    // Set userApptId into request because UserApptGetSingle expects it.
    request.setAttribute("apptId",userApptId);
    new ApptGetSingle().execute(request);

    // If appt is null, forward to sched page.
    Appt userAppt=(Appt)request.getAttribute("appt");
    if (userAppt==null)
    {
        RequestUtils.resetAction(request);
        RequestUtils.removeEdits(request);
        %>
        <jsp:forward page="/sched.jsp"/>
        <%
    }

    // If not an admin and not self, go to sched.
    if (!currentUser.getIsAdmin()
       && !(currentUser.getIsStaff() && currentUser.getKey().getId()==userAppt.getProviderUserId())
       && !(currentUser.getKey().getId()==userAppt.getRecipientUserId()))
    {
        // Not allowed.
        RequestUtils.resetAction(request);
        RequestUtils.removeEdits(request);
        %>
        <jsp:forward page="/sched.jsp"/>
        <%
    }
    
    // Get user (set by UserApptGetSingle)
    User user=(User)request.getAttribute("user");
    if (user==null)
    {
        RequestUtils.resetAction(request);
        RequestUtils.removeEdits(request);
        %>
        <jsp:forward page="/sched.jsp"/>
        <%
    }

%>
<%@ include file="/WEB-INF/pages/components/noCache.jsp" %>
<%@ include file="/WEB-INF/pages/components/docType.jsp" %>
<title>
<%
    out.write( HtmlUtils.escapeChars(RequestUtils.getCurrentStoreName(request)) );
    out.write( " - ");
    out.write( bundle.getString("viewApptLabel") );
%></title>
<link type="text/css" rel="stylesheet" href="/stylesheets/main.css" />
<meta http-equiv="Content-Type" content="text/html;charset=utf-8" /></head>
<body>
<jsp:include page="/WEB-INF/pages/components/navLinks.jsp"/>

<h1><%= bundle.getString("viewApptLabel") %></h1>

<jsp:include page="/WEB-INF/pages/components/edits.jsp"/>

  <table border="1">

<%
    Locale locale=SessionUtils.getLocale(request);
    SimpleDateFormat displayDateTime=new SimpleDateFormat("yyyy MMM dd EEE h:mm aa",locale);		
    displayDateTime.setTimeZone(RequestUtils.getCurrentStore(request).getTimeZone());
    
    // Staff name
    out.write( "<tr><th>" + bundle.getString("staffLabel") + "</th><td>" );
    String name=HtmlUtils.escapeChars(DisplayUtils.formatName(user.getFirstName(),user.getLastName(),true));
    if (name.length()==0)
    {
        name="&nbsp";
    }
    out.write( name );
    out.write( "</td></tr>" );
    
    User customer=(User)users.get(userAppt.getRecipientUserId());

    // Customer name
    out.write( "<tr><th>" + bundle.getString("customerLabel") + "</th><td>" );
    String customerName=HtmlUtils.escapeChars(DisplayUtils.formatName(customer.getFirstName(),customer.getLastName(),true));
    if (customerName.length()==0)
    {
        customerName="&nbsp";
    }
    out.write( customerName );
    out.write( "</td></tr>" );
    
    // Service
    out.write( "<tr><th>" + bundle.getString("serviceLabel") + "</th><td>" );
    Service service=(Service)services.get(new Long(userAppt.getServiceId()));
    if (service!=null)
    {
        out.write(HtmlUtils.escapeChars(service.getDesc()));
    }
    else
    {
        out.write( "&nbsp;" );
    }
    out.write( "</td></tr>" );
    
    // Service
    //if (userAppt.getIsPending())
    //{
        out.write( "<tr><th>" + bundle.getString("statusLabel") + "</th><td>" );

        if (userAppt.getIsPending())
        {
            out.write(bundle.getString("pendingLabel"));
        }
        else
        {
            out.write(bundle.getString("confirmedLabel"));
        }
        
        /*
        if (userAppt.getIsPending())
        {
            out.write(bundle.getString("yesLabel"));
        }
        else
        {
            out.write(bundle.getString("noLabel"));
        }*/
        
        out.write( "</td></tr>" );
    //}

    // Start Date
    Date startDate=(Date)userAppt.getStartDate();
    out.write( "<tr><th>" + bundle.getString("startTimeLabel") + "</th><td>" );
    out.write(HtmlUtils.escapeChars(displayDateTime.format(startDate)));
    out.write( "</td></tr>" );

    // End Date
    Date endDate=DateUtils.getEndDate(userAppt.getStartDate(),userAppt.getDuration());
    out.write( "<tr><th>" + bundle.getString("endTimeLabel") + "</th><td>" );
    out.write(HtmlUtils.escapeChars(displayDateTime.format(endDate)));
    out.write( "</td></tr>" );

    // Duration
    out.write( "<tr><th>" + bundle.getString("durationLabel") + "</th><td>" );
    out.write(HtmlUtils.escapeChars(DisplayUtils.formatDuration(userAppt.getDuration())));
    out.write( "</td></tr>" );

    // Note
    out.write( "<tr><th>" + bundle.getString("noteLabel") + "</th><td>" );
    out.write( DisplayUtils.getSpaceIfNull(userAppt.getNote()) );
    out.write( "</td></tr>" );

    // Last updated by
    request.setAttribute("user",null);	
    request.setAttribute("userId",new Long(userAppt.getLastUpdateUserId()));	
    new UserGetSingle().execute(request);	 
    User lastUpdateUser=(User)request.getAttribute("user");
    String lastUpdateUserName;	
    if (lastUpdateUser!=null)
    {
        lastUpdateUserName=DisplayUtils.formatName(lastUpdateUser.getFirstName(),lastUpdateUser.getLastName(),true);	
    }
    else
    {
        lastUpdateUserName="N/A";
    }
    
    out.write( "<tr><th>" + bundle.getString("lastUpdatedByLabel") + "</th><td>" );
    out.write(HtmlUtils.escapeChars(lastUpdateUserName));
    out.write( "</td></tr>" );

    // Last updated time
    out.write( "<tr><th>" + bundle.getString("lastUpdatedTimeLabel") + "</th><td>" );
    out.write(HtmlUtils.escapeChars(displayDateTime.format(userAppt.getLastUpdateTime())));
    out.write( "</td></tr>" );
    
    
%>
  </table>

<jsp:include page="/WEB-INF/pages/components/footer.jsp"/>
</body>
</html>