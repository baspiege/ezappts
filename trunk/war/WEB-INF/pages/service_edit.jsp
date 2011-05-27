<%-- This JSP has the HTML for the service update page.--%>
<%@ page language="java"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="sched.data.ServiceGetSingle" %>
<%@ page import="sched.data.ServiceAddUpdate" %>
<%@ page import="sched.data.model.Service" %>
<%@ page import="sched.data.model.User" %>
<%@ page import="sched.utils.DateUtils" %>
<%@ page import="sched.utils.HtmlUtils" %>
<%@ page import="sched.utils.RequestUtils" %>
<%@ page import="sched.utils.SessionUtils" %>
<%@ page import="sched.utils.StringUtils" %>
<%
    ResourceBundle bundle = ResourceBundle.getBundle("Text", SessionUtils.getLocale(request));
    ResourceBundle colorBundle = ResourceBundle.getBundle("Color", SessionUtils.getLocale(request));

    // If cancel, forward right away.
    String action=RequestUtils.getAlphaInput(request,"action","Action",false);
    if (action!=null && action.equals(bundle.getString("cancelLabel")))
    {
        // Reset fields
        request.setAttribute("durationHour",null);					
        request.setAttribute("durationMinute",null);	

        RequestUtils.resetAction(request);
        RequestUtils.removeEdits(request);
        %>
        <jsp:forward page="/WEB-INF/pages/service.jsp"/>
        <%
    }	

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
    User currentUser=RequestUtils.getCurrentUser(request);
    boolean isCurrentUserAdmin=false;
    if (currentUser!=null && currentUser.getIsAdmin())
    {
        isCurrentUserAdmin=true;
    }
    else
    {
        // Forward them to the sched page.
        RequestUtils.resetAction(request);
        RequestUtils.removeEdits(request);
        %>
        <jsp:forward page="/sched.jsp"/>
        <%
    }

    // Get Id
    Long serviceIdRequest=RequestUtils.getNumericInput(request,"serviceId",bundle.getString("serviceIdLabel"),true);
    if (serviceIdRequest==null)
    {
        RequestUtils.resetAction(request);
        RequestUtils.removeEdits(request);
        %>
        <jsp:forward page="/service.jsp"/>
        <%
    }

    // Set fields
    String desc="";
    String color="000000";
    Long durationHour=null;
    Long durationMinute=null;

    // Get service info
    if (!RequestUtils.hasEdits(request))
    {
        new ServiceGetSingle().execute(request);
        Service service=(Service)request.getAttribute("service");

        if (service==null)
        {
            RequestUtils.resetAction(request);
            RequestUtils.removeEdits(request);
            %>
            <jsp:forward page="/service.jsp"/>
            <%
        }

        // Set fields
        desc=service.getDesc();
        color=service.getColor();
        request.setAttribute("color",color);

        // Get duration and calculate hour and min.
        int serviceDuration=service.getDuration();

        long durationHourLong=0;
        long durationMinuteLong=0;		

        if (serviceDuration!=0)
        {
            durationHourLong=serviceDuration/60;
            durationMinuteLong=serviceDuration%60;
        }

        request.setAttribute("durationHour",new Long(durationHourLong));
        request.setAttribute("durationMinute",new Long(durationMinuteLong));				

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
        
            if (action.equals(bundle.getString("updateLabel")))
            {
                // Required
                color=RequestUtils.getColorInput(request,"color",bundle.getString("colorLabel"),true);
                desc=RequestUtils.getAlphaInput(request,"desc",bundle.getString("nameLabel"),true);				

                durationHour=RequestUtils.getNumericInput(request,"durationHour",bundle.getString("durationHoursLabel"),true);
                durationMinute=RequestUtils.getNumericInput(request,"durationMinute",bundle.getString("durationMinutesLabel"),true);		

                if (!RequestUtils.hasEdits(request))
                {
                    new ServiceAddUpdate().execute(request);
                }

                // If successful, go back to service page.
                if (!RequestUtils.hasEdits(request))
                {
                    // Reset fields
                    request.setAttribute("durationHour",null);					
                    request.setAttribute("durationMinute",null);					
                    request.setAttribute("color",null);

                    RequestUtils.resetAction(request);

                    // Route to service page.
                    %>
                    <jsp:forward page="/service.jsp"/>
                    <%
                }
            }
        }
    }

    String title=HtmlUtils.escapeChars(RequestUtils.getCurrentStoreName(request));
%>
<%@ include file="/WEB-INF/pages/components/noCache.jsp" %>
<%@ include file="/WEB-INF/pages/components/docType.jsp" %>
<title><%= title %> - <%= bundle.getString("editServiceLabel") %></title>
<link type="text/css" rel="stylesheet" href="/stylesheets/main.css" />
<meta http-equiv="Content-Type" content="text/html;charset=utf-8" /></head>
<body>
<jsp:include page="/WEB-INF/pages/components/navLinks.jsp"/>

  <form id="service" method="post" action="service_edit.jsp?serviceId=<%=serviceIdRequest%>" autocomplete="off">
    <fieldset class="action">
      <legend><b><%= bundle.getString("editServiceLabel") %></b></legend>

<jsp:include page="/WEB-INF/pages/components/edits.jsp"/>

      <table>
        <tr><td><label for="desc"><%=bundle.getString("nameLabel")%></label></td><td><input type="text" name="desc" value="<%=HtmlUtils.escapeChars(desc)%>" id="desc" maxlength="100" title="<%=bundle.getString("nameLabel")%>"/></td></tr>
        <tr>
          <td><%=bundle.getString("defaultDurationLabel")%></td>
          <td><% request.setAttribute("apptDatePrefix","duration"); %><jsp:include page="/WEB-INF/pages/components/durationSelect.jsp"/></td>
        </tr>

       <tr>
          <td><%=bundle.getString("colorLabel")%></td>
          <td><select name="color" title="<%=bundle.getString("colorLabel")%>"><jsp:include page="/WEB-INF/pages/components/colorSelectOptions.jsp"/></select></td>
        </tr>

      </table>
      <br/>

      <input type="hidden" name="csrfToken" value="<%= SessionUtils.getCSRFToken(request) %>"/>
      <input type="submit" name="action" value="<%=bundle.getString("updateLabel")%>"></input> <input type="submit" name="action" value="<%=bundle.getString("cancelLabel")%>"/>
    </fieldset>
  </form>

<jsp:include page="/WEB-INF/pages/components/footer.jsp"/>
</body>
</html>