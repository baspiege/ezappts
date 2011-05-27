<%-- This JSP has the HTML for the service delete page. --%>
<%@ page language="java"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="sched.data.ServiceDelete" %>
<%@ page import="sched.data.ServiceGetSingle" %>
<%@ page import="sched.data.model.Service" %>
<%@ page import="sched.data.model.User" %>
<%@ page import="sched.utils.HtmlUtils" %>
<%@ page import="sched.utils.RequestUtils" %>
<%@ page import="sched.utils.SessionUtils" %>
<%@ page import="sched.utils.StringUtils" %>
<%
    ResourceBundle bundle = ResourceBundle.getBundle("Text", SessionUtils.getLocale(request));   

    // If cancel, forward right away.
    String action=RequestUtils.getAlphaInput(request,"action","Action",false);
    if (action!=null && action.equals(bundle.getString("cancelLabel")))
    {
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
        // Forward them to the sched page.  Can't forward to service.
        RequestUtils.resetAction(request);
        RequestUtils.removeEdits(request);
        %>
        <jsp:forward page="/sched.jsp"/>
        <%
    }

    // Get Appt Template Id
    Long serviceIdRequest=RequestUtils.getNumericInput(request,"serviceId",bundle.getString("serviceIdLabel"),true);
    if (serviceIdRequest==null)
    {
        RequestUtils.resetAction(request);
        RequestUtils.removeEdits(request);
        %>
        <jsp:forward page="/service.jsp"/>
        <%
    }

    // Display name
    String desc="";

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
    }
    else
    {
        RequestUtils.resetAction(request);
        RequestUtils.removeEdits(request);
        %>
        <jsp:forward page="/service.jsp"/>
        <%
    }

    // Forward based on action
    if (!StringUtils.isEmpty(action) && !RequestUtils.isForwarded(request))
    {
        Long token=RequestUtils.getNumericInput(request,"csrfToken","CSRF Token",true);
        if (!SessionUtils.isCSRFTokenValid(request,token))
        {
            %>
            <jsp:forward page="/logonForward.jsp"/>
            <%
        }
    
        if (action.equals(bundle.getString("deleteLabel")))
        {
            new ServiceDelete().execute(request);

            // If successful, go back to service page.
            if (!RequestUtils.hasEdits(request))
            {
                RequestUtils.resetAction(request);

                // Route to service page.
                %>
                <jsp:forward page="/service.jsp"/>
                <%
            }
        }
    }
%>

<%@ include file="/WEB-INF/pages/components/noCache.jsp" %>
<%@ include file="/WEB-INF/pages/components/docType.jsp" %>
<title><%= HtmlUtils.escapeChars(RequestUtils.getCurrentStoreName(request)) %> - <%= bundle.getString("deleteServiceLabel")%></title>
<link type="text/css" rel="stylesheet" href="/stylesheets/main.css" />
<meta http-equiv="Content-Type" content="text/html;charset=utf-8" /></head>
<body>
<jsp:include page="/WEB-INF/pages/components/navLinks.jsp"/>

<form id="updates" method="post" action="service_delete.jsp">

  <fieldset class="action">
    <legend><b><%= bundle.getString("deleteServiceLabel")%></b></legend>

<jsp:include page="/WEB-INF/pages/components/edits.jsp"/>

    <p><%= HtmlUtils.escapeChars(desc) %> - <%= bundle.getString("deleteServiceConfSentence1") %> <%= bundle.getString("deleteServiceConfSentence2") %></p>
    <input type="submit" name="action" value="<%= bundle.getString("deleteLabel") %>"/>
    <input type="submit" name="action" value="<%= bundle.getString("cancelLabel") %>"/>
    <input type="hidden" name="serviceId" value="<%=serviceIdRequest%>"/>
    <input type="hidden" name="csrfToken" value="<%= SessionUtils.getCSRFToken(request) %>"/>

    </fieldset>
</form>

<jsp:include page="/WEB-INF/pages/components/footer.jsp"/>
</body>
</html>