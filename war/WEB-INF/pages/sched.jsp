<%-- This JSP has the HTML for the schedule page.--%>
<%@ page language="java"%>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Calendar" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Map.Entry" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.TimeZone" %>
<%@ page import="sched.data.ApptCopyMove" %>
<%@ page import="sched.data.ApptDelete" %>
<%@ page import="sched.data.ApptGetAll" %>
<%@ page import="sched.data.ApptMove" %>
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

    // Check if admin
    boolean isAdmin=false;
    User currentUser=RequestUtils.getCurrentUser(request);
    if (currentUser!=null)
    {
        if (currentUser.getIsAdmin())
        {
            isAdmin=true;
        }
    }

    // Get parameters
    Long startYear=null;
    Long startMonth=null;
    Long startDay=null;
    Long displayDays=null;

    ResourceBundle bundle = ResourceBundle.getBundle("Text", SessionUtils.getLocale(request));

    // Only check if not forwarded
    if (!RequestUtils.isForwarded(request))
    {
        startYear=RequestUtils.getNumericInput(request,"startYear",bundle.getString("startYearLabel"),false);
        startMonth=RequestUtils.getNumericInput(request,"startMonth",bundle.getString("startMonthLabel"),false,0,13);
        startDay=RequestUtils.getNumericInput(request,"startDay",bundle.getString("startDayLabel"),false,0,32);
        displayDays=RequestUtils.getNumericInput(request,"displayDays",bundle.getString("daysInDisplayLabel"),false,0,32);
    }
    else
    {
        request.setAttribute("startYear",null);
        request.setAttribute("startMonth",null);
        request.setAttribute("startDay",null);
        request.setAttribute("displayDays",null);
    }

    // Set from session if not specified.
    if (startYear==null && session.getAttribute("startYear")!=null)
    {
        request.setAttribute("startYear",(Long)session.getAttribute("startYear"));
    }
    if (startMonth==null && session.getAttribute("startMonth")!=null)
    {
        request.setAttribute("startMonth",(Long)session.getAttribute("startMonth"));
    }
    if (startDay==null && session.getAttribute("startDay")!=null)
    {
        request.setAttribute("startDay",(Long)session.getAttribute("startDay"));
    }
    if (displayDays==null && session.getAttribute("displayDays")!=null)
    {
        request.setAttribute("displayDays",(Long)session.getAttribute("displayDays"));
    }	

     // Get users.
    Map<Long,User> users=RequestUtils.getUsers(request);

    // Get services (needed for ApptGetAll)
    Map<Long,Service> services=RequestUtils.getServices(request);

    String action=RequestUtils.getAlphaInput(request,"action","Action",false);
    if (!StringUtils.isEmpty(action) && !RequestUtils.isForwarded(request))
    {
        Long token=RequestUtils.getNumericInput(request,"csrfToken","CSRF Token",true);
        if (!SessionUtils.isCSRFTokenValid(request,token))
        {
            %>
            <jsp:forward page="/logonForward.jsp"/>
            <%
        }

        // Delete appts
        if (action.equals(bundle.getString("deleteLabel")) && !RequestUtils.isForwarded(request))
        {
            List<Long> apptIds=RequestUtils.getNumericInputs(request,"a",bundle.getString("apptIdLabel"),false);

            if (!RequestUtils.hasEdits(request))
            {
                for (Long apptId: apptIds)
                {
                    request.setAttribute("apptId",apptId);		
                    new ApptDelete().execute(request);
                }
            }
        }

        // Copy and move appts
        else if (action.equals(bundle.getString("copyMoveLabel")) && !RequestUtils.isForwarded(request))
        {
            List<Long> apptIds=RequestUtils.getNumericInputs(request,"a",bundle.getString("apptIdLabel"),false);
            Long daysToMove=RequestUtils.getNumericInput(request,"daysToMove",bundle.getString("moveDaysLabel"),true);
            request.setAttribute("s",apptIds);

            if (!RequestUtils.hasEdits(request))
            {
                new ApptCopyMove().execute(request);
            }
        }

        // Move appt
        else if (action.equals("Move") && !RequestUtils.isForwarded(request))
        {
            Long apptIdToMove=RequestUtils.getNumericInput(request,"apptId",bundle.getString("apptIdLabel"),true);
            Long userIdTarget=RequestUtils.getNumericInput(request,"userIdMove",bundle.getString("userIdLabel"),true);

            // Check date from schedule.
            String startDateString=RequestUtils.getDateInput(request,"dateMove",bundle.getString("startDateLabel"),true);
            if (startDateString!=null)
            {
                // Split into 3 parts
                String[] dateParts=startDateString.split("-");

                startYear=new Long((String)dateParts[0]);
                startMonth=new Long((String)dateParts[1]);
                startDay=new Long((String)dateParts[2]);

                request.setAttribute("startYearMove",startYear);
                request.setAttribute("startMonthMove",startMonth);
                request.setAttribute("startDayMove",startDay);
            }

            if (!RequestUtils.hasEdits(request))
            {
                new ApptMove().execute(request);
            }
        }
    }

    // User, Service - Optional
    Long userIdLong=SessionUtils.getFieldAsLongCheckingRequest(request, SessionUtils.STAFF_ID_DISPLAYED_ON_SCHEDULE, "staffId", bundle.getString("staffIdLabel"), User.ALL_USERS);
    Long customerIdLong=SessionUtils.getFieldAsLongCheckingRequest(request, SessionUtils.CUSTOMER_ID_DISPLAYED_ON_SCHEDULE, "customerId", bundle.getString("customerIdLabel"), User.ALL_USERS);
    Long serviceIdLong=SessionUtils.getFieldAsLongCheckingRequest(request, SessionUtils.SERVICE_ID_DISPLAYED_ON_SCHEDULE, "serviceId" , bundle.getString("serviceIdLabel"), Service.ALL_SERVICES);		

    // Check if services exist.
    if (serviceIdLong!=null && serviceIdLong.longValue()!=Service.NO_SERVICE && serviceIdLong.longValue()!=Service.ALL_SERVICES && !services.containsKey(serviceIdLong))
    {
        serviceIdLong=new Long(Service.ALL_SERVICES);
        request.setAttribute("serviceId",null);			
    }		
    SessionUtils.setServiceIdDisplayedOnSchedule(request,serviceIdLong);

    // Check if user exists.
    if (userIdLong!=null && userIdLong.longValue()!=User.ALL_USERS && !users.containsKey(userIdLong))
    {
        userIdLong=new Long(User.ALL_USERS);
        request.setAttribute("staffId",null);			
    }		
    SessionUtils.setStaffIdDisplayedOnSchedule(request,userIdLong);		
    
    // Check if customer exists.
    if (customerIdLong!=null && customerIdLong.longValue()!=User.NO_USER && customerIdLong.longValue()!=User.ALL_USERS && !users.containsKey(customerIdLong))
    {
        customerIdLong=new Long(User.ALL_USERS);
        request.setAttribute("customerId",null);			
    }		
    SessionUtils.setCustomerIdDisplayedOnSchedule(request,customerIdLong);

    new ApptGetAll().execute(request);

    // Set date into session.  Do this after ApptGetAll because the dates can be changed.
    session.setAttribute("startYear",request.getAttribute("startYear"));
    session.setAttribute("startMonth",request.getAttribute("startMonth"));
    session.setAttribute("startDay",request.getAttribute("startDay"));
    session.setAttribute("displayDays",request.getAttribute("displayDays"));

    String title=HtmlUtils.escapeChars(RequestUtils.getCurrentStoreName(request));
%>
<%@ include file="/WEB-INF/pages/components/noCache.jsp" %>
<%@ include file="/WEB-INF/pages/components/docType.jsp" %>
<title><%= title %> <%= bundle.getString("scheduleLabel")%></title>
<link type="text/css" rel="stylesheet" href="/stylesheets/main.css" />
<meta http-equiv="Content-Type" content="text/html;charset=utf-8" /></head>
<%
    out.write("<body onunload=\"saveSchedPos();\"");

    if (!RequestUtils.hasEdits(request))
    {
        Long scrollX=RequestUtils.getCookieValueNumeric(request,"schedX",0L);
        Long scrollY=RequestUtils.getCookieValueNumeric(request,"schedY",0L);

        out.write(" onload=\"window.scrollTo(" + scrollX.toString() + "," + scrollY.toString() + ");");
    }
    
    //out.write("\" style=\"background-color:#FFFFFF; filter:progid:DXImageTransform.Microsoft.Gradient(GradientType=0,StartColorStr=\'#FEEEFF//\',EndColorStr=\'#FFFFFF\');margin: 0px auto;\"");
    
    
    out.write("\">");
%>
<jsp:include page="/WEB-INF/pages/components/navLinks.jsp"/>
<jsp:include page="/WEB-INF/pages/components/edits.jsp"/>

  <form name="schedView" method="get" action="sched.jsp" onsubmit="saveSchedPos();">
    <fieldset class="action">
      <legend><b><%= bundle.getString("startDateLabel")%></b></legend>

    <%
    request.setAttribute("apptDatePrefix","start");
    request.setAttribute("apptDateTime","false");
    %><jsp:include page="/WEB-INF/pages/components/dateSelect.jsp"/>

          <label for="displayDays"><%= bundle.getString("daysLabel")%></label>

<%
    // Display Days
    out.write("<input type=\"text\" name=\"");
    out.write("displayDays\" id=\"displayDays\" title=\"");
    out.write(bundle.getString("daysInDisplayLabel"));
    out.write("\" value=\"");

    Long displayDaysSelect=(Long)request.getAttribute("displayDays");
    if (displayDaysSelect==null)
    {
       displayDaysSelect=new Long(7);
    }
    out.write(displayDaysSelect.toString());

    out.write("\" size=\"2\" maxlength=\"2\" >");
%>
      <input type="submit" name="action" value="<%= bundle.getString("viewButton")%>"></input>
      <input type="submit" name="action" value="<%= bundle.getString("viewPreviousPeriodButton")%>"></input>
      <input type="submit" name="action" value="<%= bundle.getString("viewNextPeriodButton")%>"></input>
      <input type="hidden" name="csrfToken" value="<%= SessionUtils.getCSRFToken(request) %>"/>
    </fieldset>
  </form>
  <form name="sched" method="post" action="sched.jsp" onsubmit="saveSchedPos();">

<div style="float:right;">  
<!--    <button onclick="checkAll(document.sched.a,true);return false;"><%= bundle.getString("selectAllLabel")%></button> -->
<!--    <button onclick="checkAll(document.sched.a,false);return false;"><%= bundle.getString("unSelectAllLabel")%></button> -->
    <input type="submit" name="action" value="<%= bundle.getString("deleteLabel")%>"></input>
</div>
<div style="clear:both;"/>
<%

    // Get TimeZone.
    TimeZone timeZone=RequestUtils.getCurrentStore(request).getTimeZone();
    Locale locale=SessionUtils.getLocale(request);

    // Date format.  Set TimeZone for all of them.
    SimpleDateFormat displayMonthDateDayofWeek=new SimpleDateFormat("MMM dd EEE", locale);
    displayMonthDateDayofWeek.setTimeZone(timeZone);

    SimpleDateFormat displayMonthDate=new SimpleDateFormat("MMM dd", locale);
    displayMonthDate.setTimeZone(timeZone);

    SimpleDateFormat displayHourAmPm=new SimpleDateFormat("h aa", locale);
    displayHourAmPm.setTimeZone(timeZone);

    SimpleDateFormat displayHour=new SimpleDateFormat("h", locale);
    displayHour.setTimeZone(timeZone);

    SimpleDateFormat displayHourMinAmPm=new SimpleDateFormat("h:mm aa", locale);
    displayHourMinAmPm.setTimeZone(timeZone);

    SimpleDateFormat displayHourMin=new SimpleDateFormat("h:mm", locale);
    displayHourMin.setTimeZone(timeZone);

    // Get start date
    Date startDate=(Date)request.getAttribute("startDate");
    if (startDate==null)
    {
        startDate=new Date();
    }

    Calendar currCalendar = DateUtils.getCalendar(request);
    currCalendar.setTime( startDate );

    // Build table (days on first row, then user and schedule for days)
    out.write("<table id=\"sched\" border=\"1\" class=\"sched\">");

    // Number of days
    int displayDaysSelectInt=displayDaysSelect.intValue();
    int width=100/(displayDaysSelectInt+1);

    for (int i=0;i<displayDaysSelectInt+1;i++)
    {
        // Create columns
        out.write("<col width=\"" + width + "%\"/>");
    }

    out.write("<tr>");
    out.write("<th>");
    out.write(bundle.getString("staffLabel"));
    out.write(" / ");
    out.write(bundle.getString("daysLabel"));
    out.write("</th>");

    // Each day in the display
    List days=new ArrayList();
    for(int i=0;i<displayDaysSelectInt;i++)
    {
        out.write("<th id=\"");
        out.write(new Integer(currCalendar.get(Calendar.YEAR)).toString());
        out.write("-");
        out.write(new Integer(currCalendar.get(Calendar.MONTH)+1).toString());
        out.write("-");
        out.write(new Integer(currCalendar.get(Calendar.DATE)).toString());
        out.write("\">");

        out.write("<input type=\"checkbox\" name=\"selCol\" title=\"" + bundle.getString("selectColLabel") + "\" value=\"\" onclick=\"checkCol(this," + i + ");\"/> ");

        out.write(displayMonthDateDayofWeek.format(currCalendar.getTime()));
        out.write("</th>");
        currCalendar.add(Calendar.DATE, 1);
    }
    out.write("</tr>");

    // Display users and the appts in the days
    Map<Long,Appt> apptsMap=(Map)request.getAttribute("appts");

    Map<Long,User> staff=RequestUtils.getStaff(request);

    if (staff!=null && !staff.isEmpty() && apptsMap!=null)
    {
        String addLabel=bundle.getString("addLabel");

        // For each user
        Iterator iter = staff.entrySet().iterator();
        int row=0;
        while (iter.hasNext())
        {
            row++;
            Entry entry = (Entry)iter.next();
            User user=(User)entry.getValue();

            long currUserId=user.getKey().getId();

            if (userIdLong.longValue()==User.ALL_USERS || userIdLong.longValue()==currUserId)
            {

                List appts=(List)apptsMap.get(new Long(currUserId));
                if (appts==null)
                {
                    appts=new ArrayList();
                }

                // Id is user Id.  Used for drag and drop.
                out.write("<tr id=\"" +  currUserId + "\">");

                // User name
                out.write("<th>");
                String userName=HtmlUtils.escapeChars(DisplayUtils.formatName(user.getFirstName(),user.getLastName(),true));
                out.write("<input type=\"checkbox\" name=\"selRow\" title=\"" + bundle.getString("selectRowLabel") + "\" value=\"\" onclick=\"checkRow(this," + row + ");\"/> ");
                out.write( userName );
                out.write("</th>");

                currCalendar.setTime( startDate );

                for(int i=0;i<displayDaysSelectInt;i++)
                {
                    String cellDateDisplay=displayMonthDateDayofWeek.format(currCalendar.getTime());

                    out.write("<td title=\"" + userName + " - ");
                    out.write(cellDateDisplay);
                    out.write("\">");

                    // Spin through all appts for this user
                    boolean hasAppt=false;

                    // Display appts
                    for (int j=0;j<appts.size();j++)
                    {
                        Appt appt=(Appt)appts.get(j);

                        if (!currentUser.getIsAdmin()
                         && !(currentUser.getIsStaff() && currentUser.getKey().getId()==appt.getProviderUserId())
                         && !(currentUser.getKey().getId()==appt.getRecipientUserId())
                         && appt.getIsPending())
                        {
                            continue;
                        }
                        
                        Date startAppt=appt.getStartDate();
                        Date endAppt=DateUtils.getEndDate(startAppt,appt.getDuration());
                        long currServiceId=appt.getServiceId();
                        long currCustomerId=appt.getRecipientUserId();

                        Calendar startApptCalendar = DateUtils.getCalendar(request);
                        startApptCalendar.setTime( startAppt );

                        Calendar endApptCalendar = DateUtils.getCalendar(request);
                        endApptCalendar.setTime( endAppt );

                        StringBuffer apptDisplay=new StringBuffer();
                        boolean hasCurrentAppt=false;
                        boolean startsDayBefore=false;

                        // Create next day.  Clone current and add 1 day.
                        Calendar nextDay=(Calendar)currCalendar.clone();
                        nextDay.add(Calendar.DATE, 1);

                        // Appts are ordered by start time so if the appt start
                        // time is greater than next day, break.
                        if (startAppt.compareTo(nextDay.getTime())>0)
                        {
                            break;
                        }
                                                    
                        // Check if details show
                        boolean showDetails=currentUser.getIsAdmin()
                            || (currentUser.getIsStaff() && currentUser.getKey().getId()==appt.getProviderUserId())
                            || (currentUser.getKey().getId()==appt.getRecipientUserId());

                        // For services, if display all and the current service exists or is no service, OR current service is the service to display.
                        if (!showDetails || 
                           (((serviceIdLong.longValue()==Service.ALL_SERVICES && (services.containsKey(new Long(currServiceId)) || currServiceId==Service.NO_SERVICE)) || serviceIdLong.longValue()==currServiceId)
                        &&  (customerIdLong.longValue()==User.ALL_USERS || customerIdLong.longValue()==currCustomerId)) )
                        {
                            boolean endsOnSameDay=
                                startApptCalendar.get(Calendar.DATE)==endApptCalendar.get(Calendar.DATE) &&
                                startApptCalendar.get(Calendar.MONTH)==endApptCalendar.get(Calendar.MONTH) &&
                                startApptCalendar.get(Calendar.YEAR)==endApptCalendar.get(Calendar.YEAR);

                            // If the appt starts on the same day as the current day, then add it to
                            // the display.
                            if( startApptCalendar.get(Calendar.DATE)==currCalendar.get(Calendar.DATE) &&
                                startApptCalendar.get(Calendar.MONTH)==currCalendar.get(Calendar.MONTH) &&
                                startApptCalendar.get(Calendar.YEAR)==currCalendar.get(Calendar.YEAR)
                                )
                            {
                                hasCurrentAppt=true;
                                hasAppt=true;

                                // If am/pm is same, only use on end.
                                if (endsOnSameDay && startApptCalendar.get(Calendar.AM_PM)==endApptCalendar.get(Calendar.AM_PM))
                                {
                                    // If min not zero, display minutes.
                                    apptDisplay.append(DisplayUtils.getHourMinuteDisplay(startApptCalendar, startAppt, displayHour, displayHourMin));
                                }
                                else
                                {
                                    apptDisplay.append(DisplayUtils.getHourMinuteDisplay(startApptCalendar, startAppt, displayHourAmPm, displayHourMinAmPm));

                                }

                                // If the appt ends on the same day, add the end appt.
                                if(endsOnSameDay)
                                {
                                    apptDisplay.append(" &rarr; ");
                                    apptDisplay.append(DisplayUtils.getHourMinuteDisplay(endApptCalendar, endAppt, displayHourAmPm, displayHourMinAmPm));

                                    // Remove from list as it isn't needed anymore.
                                    // Since item is removed, decrease counter by 1.
                                    appts.remove(j);
                                    j=j-1;
                                }
                                // If the appt doesn't end on the same day, if must proceed to the next day.
                                else
                                {
                                    // If ends at the start of the next day, remove from list because otherwise
                                    // the appt will be of zero length on that day.
                                    if (endAppt.compareTo(nextDay.getTime())==0)
                                    {
                                        apptDisplay.append( " &rarr; 12AM"  );

                                        // Remove from list as it isn't needed anymore.
                                        // Since item is removed, decrease counter by 1.
                                        appts.remove(j);
                                        j=j-1;
                                    }
                                    else
                                    {
                                        apptDisplay.append( " &rarr; (" + bundle.getString("nextDayLabel") + ")"  );
                                    }
                                }

                            }
                            // If end is same as date
                            else if (endApptCalendar.get(Calendar.DATE)==currCalendar.get(Calendar.DATE) &&
                                endApptCalendar.get(Calendar.MONTH)==currCalendar.get(Calendar.MONTH) &&
                                endApptCalendar.get(Calendar.YEAR)==currCalendar.get(Calendar.YEAR) && (endApptCalendar.get(Calendar.HOUR_OF_DAY)!=0 || endApptCalendar.get(Calendar.MINUTE)!=0)  )
                            {
                                startsDayBefore=true;

                                hasCurrentAppt=true;
                                hasAppt=true;

                                apptDisplay.append( "(" + bundle.getString("previousDayLabel") + ") &rarr; "  );
                                apptDisplay.append(DisplayUtils.getHourMinuteDisplay(endApptCalendar, endAppt, displayHourAmPm, displayHourMinAmPm));

                                // Remove from list as it isn't needed anymore.
                                // Since item is removed, decrease counter by 1.
                                appts.remove(j);
                                j=j-1;


                            }
                            // If appt starts before this day and ends after, then mark as All Day.
                            else if (currCalendar.getTime().compareTo(startAppt)>0 && endAppt.compareTo(nextDay.getTime())>0)
                            {
                                startsDayBefore=true;

                                hasCurrentAppt=true;
                                hasAppt=true;
                                apptDisplay.append( bundle.getString("allDayLabel")  );
                            }
                        }

                        if (hasCurrentAppt)
                        { 
                            // Check if checkbox shows
                            boolean showCheckbox=currentUser.getIsAdmin()
                                || (currentUser.getIsStaff() && currentUser.getKey().getId()==appt.getProviderUserId())
                                || (currentUser.getKey().getId()==appt.getRecipientUserId() && appt.getIsPending());
                        
                            if (showCheckbox)
                            {                        
                                if (appt.getIsPending())
                                {
                                    out.write("<div class=\"drag pending\"");
                                }
                                else
                                {
                                    out.write("<div class=\"drag\"");
                                }
                            }
                            else if (showDetails)
                            {
                                if (appt.getIsPending())
                                {
                                    out.write("<div class=\"appt pending\"");
                                }
                                else
                                {
                                    out.write("<div class=\"appt confirmed\"");
                                }
                            }
                            else
                            {
                                out.write("<div class=\"appt\"");                            
                            }

                            Service service=(Service)services.get(new Long(currServiceId));

                            // Get service color
                            if (service!=null && service.getColor()!=null && showDetails)
                            {
                                out.write(" style=\"border-color:#" + HtmlUtils.escapeChars(service.getColor()) + ";\"");
                            }

                            out.write(">");
                            
                            String apptIdString=new Long(appt.getKey().getId()).toString();

                            if (!startsDayBefore)
                            {
                                if (showCheckbox)
                                {
                                    out.write("<input class=\"si\" type=\"checkbox\" name=\"a\" value=\"" + apptIdString + "\"/> ");
                                }
                                else
                                {
                                    out.write("&#9632 "); // black square
                                    // out.write("&bull; ");
                                }
                            }

                            if (showDetails)
                            {
                                out.write("<a href=\"appt.jsp?a=");
                                out.write(apptIdString);
                                out.write("\">");

                                out.write(apptDisplay.toString());
                                
                                // Get user description
                                User recipient=(User)users.get(new Long(appt.getRecipientUserId()));
                                if (recipient!=null)
                                {
                                    out.write(" ");
                                    out.write(HtmlUtils.escapeChars(DisplayUtils.formatName(recipient.getFirstName(),recipient.getLastName(),true)));
                                }

                                // Get service description
                                if (service!=null)
                                {
                                    out.write(" ");
                                    out.write(HtmlUtils.escapeChars(service.getDesc()));
                                }

                                out.write("</a>");
                                
                                if (appt.getIsPending())
                                {
                                    out.write(" *" + bundle.getString("pendingLabel"));
                                }
                            }
                            else
                            {
                                out.write(apptDisplay.toString());                            
                            }
                            
                            out.write("</div>");
                        }
                    }

                    // Admins can edit, staff can change their own, and customers can add to any staff because added in pending.
                    if (currentUser.getIsAdmin()
                    || (currentUser.getIsStaff() && currentUser.getKey().getId()==currUserId)
                    || !currentUser.getIsStaff())
                    {		
                        out.write("<a class=\"add\" href=\"appt.jsp?");
                        out.write("&s=");
                        out.write(new Long(currUserId).toString());
                        out.write("&d=");
                        out.write(new Integer(currCalendar.get(Calendar.YEAR)).toString());
                        out.write("-");
                        out.write(new Integer(currCalendar.get(Calendar.MONTH)+1).toString());
                        out.write("-");
                        out.write(new Integer(currCalendar.get(Calendar.DATE)).toString());
                        out.write("\">");
                        out.write("+");
                        out.write("</a>");
                    }
                    else
                    {
                        if (!hasAppt)
                        {
                            out.write("&nbsp;");
                        }
                    }

                    out.write("</td>");

                    // Increment current day
                    currCalendar.add(Calendar.DATE, 1);
                }
                out.write("</tr>");
            }	
        }
    }
    else
    {
        // Will not happen because page can't display if no users, but just in case. (change --- to "No Users")
        out.write("<tr><td colspan=\"" + (displayDaysSelectInt+1) + "\"> --- </td></tr>");
    }

    out.write("</table>");
%>
<input type="hidden" name="csrfToken" value="<%= SessionUtils.getCSRFToken(request) %>"/>
</form>
<form name="moveForm" id="moveForm" method="post" action="sched.jsp" onsubmit="saveSchedPos();">
<input type="hidden" name="action" value="Move"/>
<input type="hidden" name="csrfToken" value="<%= SessionUtils.getCSRFToken(request) %>"/>
</form>
<jsp:include page="/WEB-INF/pages/components/footer.jsp"/>
<%-- <pre id="debug"></pre> --%>
</body>
<script type="text/javascript" src="/js/sched.js" >
</script>
</html>