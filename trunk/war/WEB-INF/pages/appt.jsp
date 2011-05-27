<%-- This JSP has the HTML for the user appt page. --%>
<%@page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page language="java"%>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Calendar" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Map.Entry" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.TimeZone" %>
<%@ page import="sched.data.ApptAddUpdate" %>
<%@ page import="sched.data.ApptDelete" %>
<%@ page import="sched.data.ApptGetSingle" %>
<%@ page import="sched.data.model.Service" %>
<%@ page import="sched.data.model.User" %>
<%@ page import="sched.data.model.Appt" %>
<%@ page import="sched.utils.DateUtils" %>
<%@ page import="sched.utils.DisplayUtils" %>
<%@ page import="sched.utils.HtmlUtils" %>
<%@ page import="sched.utils.RequestUtils" %>
<%@ page import="sched.utils.SessionUtils" %>
<%@ page import="sched.utils.StringUtils" %>
<%
    String action=RequestUtils.getAlphaInput(request,"action","Action",false);

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
    // This is needed when determing if the user is eligible for what type of page.
    User currentUser=RequestUtils.getCurrentUser(request);

    // Get services (needed for ApptGetSingle)
    Map<Long,Service> services=RequestUtils.getServices(request);

    // Get users
    Map<Long, User> users=RequestUtils.getUsers(request);	

    // There are two ways to come to this page.
    // 1.) Without a appt specified.  In this case, the user can only add.
    // 2.) With a appt specified.  In this case, the appt can be updated or forwarded to the view page.
    
    ResourceBundle bundle = ResourceBundle.getBundle("Text", SessionUtils.getLocale(request));        
    String pageTitle=null;
    boolean fromSched=RequestUtils.getBooleanInput(request,"fromSched","From Schedule",false);

    // Type
    int type=0;
    int ADD=1;
    int EDIT=2;

    // If appt Id, then either updating or viewing.
    Long apptId=RequestUtils.getNumericInput(request,"a",bundle.getString("apptIdLabel"),false);
    Appt appt=null;
    if (apptId!=null)
    {
        // Get single appt.
        request.setAttribute("apptId",apptId);
        new ApptGetSingle().execute(request);

        // If appt is null, forward to sched page.
        appt=(Appt)request.getAttribute("appt");
        if (appt==null)
        {
            RequestUtils.resetAction(request);
            RequestUtils.removeEdits(request);
            %>
            <jsp:forward page="/sched.jsp"/>
            <%
        }

        // If an admin or self, then editing.
        if (currentUser.getIsAdmin()
           || (currentUser.getIsStaff() && currentUser.getKey().getId()==appt.getProviderUserId())
           || (currentUser.getKey().getId()==appt.getRecipientUserId() && appt.getIsPending()))
        {
            type=EDIT;
            pageTitle=bundle.getString("editApptLabel");
        }
        else
        {
            // Forward to view page.
            %>
            <jsp:forward page="/appt_view.jsp"/>
            <%
        }
    }
    else
    {
        type=ADD;
        pageTitle=bundle.getString("addAppointmentLabel");
    }

    // If admin, get user list.
    if (currentUser.getIsAdmin())
    {
        // Get users
        // Add message if there are no users.
        // This will never occur but check anyway.
        if (users!=null && users.isEmpty())
        {                       
            RequestUtils.addEdit(request,bundle.getString("addUserBeforeAddingApptEdit"));
        }
    }

    // Defaults
    Long providerUserIdRequest=null;
    Long recipientUserIdRequest=null;
    boolean usesCustomDuration=false;
    boolean isPending=false;
    Long serviceId=null;
    Long startYear=null;
    Long startMonth=null;
    Long startDay=null;
    Long apptRepetition=null;
    Long daysBetweenRepetitions=null;
    Long startHour=null;
    Long startMinute=null;
    String startAmPm=null;
    String note=null;

    appt=(Appt)request.getAttribute("appt");
    if (appt!=null && (action==null || action.length()==0))
    {
        providerUserIdRequest=new Long(appt.getProviderUserId());
        recipientUserIdRequest=new Long(appt.getRecipientUserId());

        request.setAttribute("staffId",providerUserIdRequest);
        request.setAttribute("customerId",recipientUserIdRequest);
        
        // Service
        serviceId=new Long(appt.getServiceId());
        request.setAttribute("serviceId",serviceId);
        
        // Is Pending?
        isPending=appt.getIsPending();
        request.setAttribute("isPending",isPending);

        // Get appt template for comparison of default time and duration
        Service service=(Service)services.get(new Long(serviceId));		

        // Set date
        Date startAppt=appt.getStartDate();
        Calendar startApptCalendar = DateUtils.getCalendar(request);
        startApptCalendar.setTime( startAppt );

        // Year
        startYear=new Long(startApptCalendar.get(Calendar.YEAR));
        request.setAttribute("startYear",startYear);

        // Month
        startMonth=new Long(startApptCalendar.get(Calendar.MONTH)+1);
        request.setAttribute("startMonth",startMonth);

        // Day
        startDay=new Long(startApptCalendar.get(Calendar.DATE));
        request.setAttribute("startDay",startDay);

        // Hour
        startHour=new Long(startApptCalendar.get(Calendar.HOUR));
        if (startHour==0)
        {
            startHour=12L;
        }
        request.setAttribute("startHour",startHour);		

        // Minute
        startMinute=new Long(startApptCalendar.get(Calendar.MINUTE));		
        request.setAttribute("startMinute",startMinute);

        int amPm=startApptCalendar.get(Calendar.AM_PM);
        if (amPm==Calendar.PM)
        {
            request.setAttribute("startAmPm",DateUtils.PM);
        }
        else
        {
            request.setAttribute("startAmPm",DateUtils.AM);
        }

        // If hour and minute do not equal default, check box.
        int hourOfDay=startApptCalendar.get(Calendar.HOUR_OF_DAY);
        int startTime=(hourOfDay*60) + startMinute.intValue();

        // If duration matches default, check box and update field.
        int apptDuration=appt.getDuration();

        long durationHour=0;
        long durationMinute=0;		

        if (service==null || service.getDuration()!=apptDuration)
        {
            usesCustomDuration=true;
            request.setAttribute("usesCustomDuration",new Boolean(true));

            if (apptDuration!=0)
            {
                durationHour=apptDuration/60;
                durationMinute=apptDuration%60;
            }
        }
        else
        {
            if (service.getDuration()!=0)
            {
                durationHour=service.getDuration()/60;
                durationMinute=service.getDuration()%60;
            }
        }

        request.setAttribute("durationHour",new Long(durationHour));
        request.setAttribute("durationMinute",new Long(durationMinute));				

        note=appt.getNote();		
    }
    else
    {
        // Uses custom times.
        usesCustomDuration=RequestUtils.getBooleanInput(request,"usesCustomDuration",bundle.getString("overrideDurationLabel"),false);

        // Is Pending
        isPending=RequestUtils.getBooleanInput(request,"isPending",bundle.getString("isPendingLabel"),false);
        
        providerUserIdRequest=RequestUtils.getNumericInput(request,"s",bundle.getString("staffIdLabel"),false);
        if (providerUserIdRequest==null)
        {
            providerUserIdRequest=RequestUtils.getNumericInput(request,"staffId",bundle.getString("staffIdLabel"),false);
        }
        else
        {
            request.setAttribute("staffId",providerUserIdRequest);
        }
        
        recipientUserIdRequest=RequestUtils.getNumericInput(request,"c",bundle.getString("customerIdLabel"),false);
        if (recipientUserIdRequest==null)
        {
            recipientUserIdRequest=RequestUtils.getNumericInput(request,"customerId",bundle.getString("customerIdLabel"),false);
        }
        else
        {
            request.setAttribute("customerId",recipientUserIdRequest);
        }


        // Check date from schedule.
        String startDateString=RequestUtils.getDateInput(request,"d",bundle.getString("startDateLabel"),false);
        if (startDateString!=null)
        {
            fromSched=true;

            // Split into 3 parts
            String[] dateParts=startDateString.split("-");

            startYear=new Long((String)dateParts[0]);
            startMonth=new Long((String)dateParts[1]);
            startDay=new Long((String)dateParts[2]);

            request.setAttribute("startYear",startYear);
            request.setAttribute("startMonth",startMonth);
            request.setAttribute("startDay",startDay);
        }
        // Date from this page.
        else
        {
            startYear=RequestUtils.getNumericInput(request,"startYear",bundle.getString("startYearLabel"),false);
            startMonth=RequestUtils.getNumericInput(request,"startMonth",bundle.getString("startMonthLabel"),false,0,13);
            startDay=RequestUtils.getNumericInput(request,"startDay",bundle.getString("startDayLabel"),false,0,32);
        }

        // Repeats
        apptRepetition=RequestUtils.getNumericInput(request,"apptRepetition",bundle.getString("repeatsLabel"),false,0,32);
        daysBetweenRepetitions=RequestUtils.getNumericInput(request,"apptDaysBetweenRepetitions",bundle.getString("daysBetweenRepetitionsLabel"),false,0,32);

        // Note
        note=RequestUtils.getAlphaInput(request,"note",bundle.getString("noteLabel"),false);		
    }

    // Process based on action
    if (!StringUtils.isEmpty(action) && !RequestUtils.isForwarded(request))
    {   
        Long token=RequestUtils.getNumericInput(request,"csrfToken","CSRF Token",true);
        if (!SessionUtils.isCSRFTokenValid(request,token))
        {
            %>
            <jsp:forward page="/logonForward.jsp"/>
            <%
        }
    
        if ((type==ADD && action.equals(bundle.getString("addLabel"))) || (type==EDIT && action.equals(bundle.getString("updateLabel"))))
        {		
            if (providerUserIdRequest==null)
            {
                //String message=bundle.getString("staffIdLabel") + ": " + bundle.getString("fieldRequiredEdit");                
                //RequestUtils.addEdit(request,message);
            }
            
            if (recipientUserIdRequest==null)
            {
                //String message=bundle.getString("customerIdLabel") + ": " + bundle.getString("fieldRequiredEdit");                
                //RequestUtils.addEdit(request,message);
            }

            if (startYear==null)
            {
                String message=bundle.getString("startYearLabel") + ": " + bundle.getString("fieldRequiredEdit");                
                RequestUtils.addEdit(request,message);            
            }

            if (startMonth==null)
            {
                String message=bundle.getString("startMonthLabel") + ": " + bundle.getString("fieldRequiredEdit");                
                RequestUtils.addEdit(request,message);            
            }

            if (startDay==null)
            {
                String message=bundle.getString("startDayLabel") + ": " + bundle.getString("fieldRequiredEdit");                
                RequestUtils.addEdit(request,message);            
            }

            // Required
            serviceId=RequestUtils.getNumericInput(request,"serviceId",bundle.getString("serviceIdLabel"),true);

                // Start
                startHour=RequestUtils.getNumericInput(request,"startHour",bundle.getString("startHourLabel"),true,0,13);
                startMinute=RequestUtils.getNumericInput(request,"startMinute",bundle.getString("startMinuteLabel"),true,-1,60);
                startAmPm=RequestUtils.getAmPmInput(request,"startAmPm",bundle.getString("startAmPmLabel"),true);

            // Custom Duration
            if (usesCustomDuration || serviceId.longValue()==Service.NO_SERVICE)
            {
                // Duration
                Long durationHour=RequestUtils.getNumericInput(request,"durationHour",bundle.getString("durationHoursLabel"),true);
                Long durationMinute=RequestUtils.getNumericInput(request,"durationMinute",bundle.getString("durationMinutesLabel"),true);
            }

            if (!RequestUtils.hasEdits(request))
            {
                new ApptAddUpdate().execute(request);
            }

            // If no edits or from the schedule, forward to the schedule.
            if (!RequestUtils.hasEdits(request) && (type==EDIT || fromSched))
            {				
                RequestUtils.resetAction(request);			
                %>
                <jsp:forward page="/sched.jsp"/>
                <%
            }
        }
        else if (type==EDIT && action.equals(bundle.getString("deleteLabel")))
        {
            new ApptDelete().execute(request);

            // If successful, go back to schedule.
            if (!RequestUtils.hasEdits(request))
            {
                RequestUtils.resetAction(request);

                // Route to page.
                %>
                <jsp:forward page="/sched.jsp"/>
                <%
            }
        }
    }
    else if (type==ADD)
    {
        // Not required
        serviceId=RequestUtils.getNumericInput(request,"serviceId",bundle.getString("serviceIdLabel"),false);
    }
%>
<%@ include file="/WEB-INF/pages/components/noCache.jsp" %>
<%@ include file="/WEB-INF/pages/components/docType.jsp" %>
<title>
<%
    out.write( HtmlUtils.escapeChars(RequestUtils.getCurrentStoreName(request)) );
    out.write( " - ");
    out.write( pageTitle );
%></title>
<link type="text/css" rel="stylesheet" href="/stylesheets/main.css" />
<script type="text/javascript">//<![CDATA[
function highlightOverride(checkboxId, hourId, minuteId)
{
    var checkbox=document.getElementById(checkboxId);
    var hour=document.getElementById(hourId);
    var minute=document.getElementById(minuteId);

    if (checkbox && hour && minute){
        if (checkbox.checked){
            hour.disabled=false;
            hour.style.backgroundColor="#ffffff";
            minute.disabled=false;
            minute.style.backgroundColor="#ffffff";
        }else{
            hour.disabled=true;
            hour.style.backgroundColor="#c0c0c0";
            minute.disabled=true;
            minute.style.backgroundColor="#c0c0c0";
        }
    }
}
//]]></script>
<meta http-equiv="Content-Type" content="text/html;charset=utf-8" /></head>
<body onload="highlightOverride('usesCustomDuration','durationHour','durationMinute');">
<jsp:include page="/WEB-INF/pages/components/navLinks.jsp"/>

  <form id="appt" method="post" action="appt.jsp" autocomplete="off">
    <fieldset class="action">
      <legend><b><%= pageTitle %></b></legend>

<jsp:include page="/WEB-INF/pages/components/edits.jsp"/>

      <table>
<% if (currentUser.getIsAdmin() || !currentUser.getIsStaff())
{%>
        <tr>
          <td><label for="staffId"><%= bundle.getString("staffLabel") %></label></td>
          <td><select name="staffId" title="<%= bundle.getString("staffLabel") %>" id="staffId">
<jsp:include page="/WEB-INF/pages/components/staffSelectOptions.jsp"/>
          </select></td></tr>
<%}
%>

<% if (currentUser.getIsAdmin() || currentUser.getIsStaff())
{%>
        <tr>
          <td><label for="customerId"><%= bundle.getString("customerLabel") %></label></td>
          <td><select name="customerId" title="<%= bundle.getString("customerLabel") %>" id="customerId">
<jsp:include page="/WEB-INF/pages/components/userSelectOptions.jsp"/>
          </select></td></tr>
<%}%>

        <tr>
        
          <td><%= bundle.getString("startDateLabel") %></td>
          <td>
<% request.setAttribute("apptDatePrefix","start"); %><jsp:include page="/WEB-INF/pages/components/dateSelect.jsp"/></td>
        </tr>

        <tr>
          <td>


<%          
          out.write(bundle.getString("startTimeLabel") );
%>
</td>
        <td><% request.setAttribute("apptDatePrefix","start"); %><jsp:include page="/WEB-INF/pages/components/timeSelect.jsp"/></td>
        </tr>

<%
    boolean noServices=(services==null || services.isEmpty());
%>
        <tr>
          <td><label for="serviceId"><%= bundle.getString("serviceLabel") %></label></td>
          <td>
            <select name="serviceId" title="<%= bundle.getString("servicesLabel") %>" id="serviceId">
<% request.setAttribute("showServiceDescOnly",new Boolean(false)); %>			
<jsp:include page="/WEB-INF/pages/components/serviceSelectOptions.jsp"/>
            </select>
          </td>
        </tr>
        
        <tr>
          <td>
<% if (!noServices)
{
    out.write("<input type=\"checkbox\" name=\"usesCustomDuration\" id=\"usesCustomDuration\" value=\"true\"");

    if (usesCustomDuration)
    {
        out.write("checked=\"checked\"");
    }
    out.write(" onclick=\"highlightOverride('usesCustomDuration','durationHour','durationMinute');\"");
    out.write(">");
    out.write("<label for=\"usesCustomDuration\">");
    out.write( bundle.getString("overrideDurationLabel") );
    out.write("</label>");    
}
else
{
    out.write( bundle.getString("durationLabel") );
}       
%>
</td>
          <td><% request.setAttribute("apptDatePrefix","duration"); %><jsp:include page="/WEB-INF/pages/components/durationSelect.jsp"/></td>
        </tr>
        
<% 
    if (currentUser.getIsAdmin() || currentUser.getIsStaff())
    {
        out.write("<tr><td>");
        out.write("<label for=\"isPending\">");
        out.write(bundle.getString("statusLabel"));
        out.write("</label>");    
        out.write("</td>");
        out.write("<td>");
        out.write("<select name=\"isPending\" title=\"");
        out.write(bundle.getString("statusLabel"));
        out.write("\" id=\"isPending\">");

        request.setAttribute("isPending",isPending);
 %>			
<jsp:include page="/WEB-INF/pages/components/statusSelectOptions.jsp"/>
<%     
        out.write( "</select></td></tr>" );
    }
%>

<% if (type==ADD)
{%>
       <tr>
          <td><%= bundle.getString("repeatsLabel") %></td>
          <td><% request.setAttribute("apptDatePrefix","appt"); %><jsp:include page="/WEB-INF/pages/components/repetitionSelect.jsp"/></td>
       </tr>
<%}%>
        <tr><td><label for="desc"><%= bundle.getString("noteLabel") %></label></td><td><input type="text" name="note" value="<%= HtmlUtils.escapeChars(note) %>" id="note" title="<%= bundle.getString("noteLabel") %>" maxlength="100"/></td></tr>
<%
    if (type==EDIT && appt!=null)
    {
        // Last updated by	
        User lastUpdateUser=null;
        Long lastUpdateUserIdLong=new Long(appt.getLastUpdateUserId());
        if (users.containsKey(lastUpdateUserIdLong))
        {
            lastUpdateUser=users.get(lastUpdateUserIdLong);
        }		

        String lastUpdateUserName;	
        if (lastUpdateUser!=null)
        {
            lastUpdateUserName=DisplayUtils.formatName(lastUpdateUser.getFirstName(),lastUpdateUser.getLastName(),true);	
        }
        else
        {
            lastUpdateUserName="N/A";
        }
        out.write( "<tr><td>" + bundle.getString("lastUpdatedByLabel") + "</td><td>" );
        out.write(HtmlUtils.escapeChars(lastUpdateUserName));
        out.write( "</td></tr>" );

        // Last updated time
        Locale locale=SessionUtils.getLocale(request);        
        SimpleDateFormat displayDateTime=new SimpleDateFormat("yyyy MMM dd EEE h:mm aa",locale);
        TimeZone timeZone=RequestUtils.getCurrentStore(request).getTimeZone();		
        displayDateTime.setTimeZone(timeZone);		
        out.write( "<tr><td>" + bundle.getString("lastUpdatedTimeLabel") + "</td><td>" );
        out.write(HtmlUtils.escapeChars(displayDateTime.format(appt.getLastUpdateTime())));
        out.write( "</td></tr>" );
    }
%>
      </table>

<%
    if (!noServices)
    {
        //out.write("<p><sup><small>*</small></sup>" + bundle.getString("overrideFootnote") + "</p>");
        out.write("<br/>");
    }
    else
    {
        out.write("<br/>");
    }

    // If adding, use add button.
    if (type==ADD)
    {
        out.write("<input type=\"hidden\" name=\"fromSched\" value=\"" + fromSched + "\"></input>");	
     %>   
     <input type="submit" style="display:none" id="addButtonDisabled" disabled="disabled" value="<%=bundle.getString("addLabel")%>"/>
     <input type="submit" name="action" onclick="this.style.display='none';document.getElementById('addButtonDisabled').style.display='inline';" value="<%=bundle.getString("addLabel")%>"/>       
     <% 
    }
    // If editing, use update and delete.
    if (type==EDIT)
    {
        out.write("<input type=\"hidden\" name=\"a\" value=\"" + apptId.toString() + "\"></input>");
        out.write("<input type=\"submit\" name=\"action\" value=\"" + bundle.getString("updateLabel") + "\"></input>");
        out.write(" <input type=\"submit\" name=\"action\" value=\"" + bundle.getString("deleteLabel") + "\"></input>");
    }
%>
      <input type="hidden" name="csrfToken" value="<%= SessionUtils.getCSRFToken(request) %>"/>
    </fieldset>
  </form>

    <%-- Not used
    List apptAdditions=(List)request.getAttribute("appts");
    if (apptAdditions!=null && apptAdditions.size()>0)
    {
        out.write("<h1>" + bundle.getString("apptsAddedLabel"));

        /*
        String userName=null;
        if (users.containsKey(userIdRequest))
        {
            User user=users.get(userIdRequest);
            userName=HtmlUtils.escapeChars(DisplayUtils.formatName(user.getFirstName(),user.getLastName(),false));					
        }		
        else
        {
            userName="";
        }

        out.write(userName);
        */
        out.write("</h1>");		

        %>
        <jsp:include page="/WEB-INF/pages/components/apptTable.jsp"/>
        <%
    }
    --%>


<jsp:include page="/WEB-INF/pages/components/footer.jsp"/>
</body>
</html>