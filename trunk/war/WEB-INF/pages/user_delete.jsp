<%-- This JSP has the HTML for the user delete page. --%>
<%@ page language="java"%>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="sched.data.UserDelete" %>
<%@ page import="sched.data.UserGetSingle" %>
<%@ page import="sched.data.ApptGetAllForSingleUser" %>
<%@ page import="sched.data.model.User" %>
<%@ page import="sched.data.model.Appt" %>
<%@ page import="sched.utils.DateUtils" %>
<%@ page import="sched.utils.DisplayUtils" %>
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
        <jsp:forward page="/WEB-INF/pages/user.jsp"/>
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
        // Forward them to the user page.
        RequestUtils.resetAction(request);
        RequestUtils.removeEdits(request);
        %>
        <jsp:forward page="/user.jsp"/>
        <%
    }

    // Get User Id
    Long userIdRequest=RequestUtils.getNumericInput(request,"userId",bundle.getString("userIdLabel"),true);
    if (userIdRequest==null)
    {
        RequestUtils.resetAction(request);
        RequestUtils.removeEdits(request);
        %>
        <jsp:forward page="/user.jsp"/>
        <%
    }

    // Display name
    String displayName="";

    // Get user info
    if (!RequestUtils.hasEdits(request))
    {
        new UserGetSingle().execute(request);

        User user=(User)request.getAttribute("user");
        if (user==null)
        {
            RequestUtils.resetAction(request);
            RequestUtils.removeEdits(request);
            %>
            <jsp:forward page="/user.jsp"/>
            <%
        }

        displayName=DisplayUtils.formatName(user.getFirstName(),user.getLastName(),false);

        // Set the user appts into the request.
        // new ApptGetAllForSingleUser().execute(request);
    }
    else
    {
        RequestUtils.resetAction(request);
        RequestUtils.removeEdits(request);
        %>
        <jsp:forward page="/user.jsp"/>
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
            new UserDelete().execute(request);

            // If successful, go back to user page.
            if (!RequestUtils.hasEdits(request))
            {
                RequestUtils.resetAction(request);

                // Route to user page.
                %>
                <jsp:forward page="/user.jsp"/>
                <%
            }
        }
    }
%>

<%@ include file="/WEB-INF/pages/components/noCache.jsp" %>
<%@ include file="/WEB-INF/pages/components/docType.jsp" %>
<title><%= HtmlUtils.escapeChars(RequestUtils.getCurrentStoreName(request)) %> - <%= bundle.getString("deleteUserLabel")%></title>
<link type="text/css" rel="stylesheet" href="/stylesheets/main.css" />
<meta http-equiv="Content-Type" content="text/html;charset=utf-8" /></head>
<body>
<jsp:include page="/WEB-INF/pages/components/navLinks.jsp"/>

<form id="updates" method="post" action="user_delete.jsp">

  <fieldset class="action">
    <legend><b><%= bundle.getString("deleteUserLabel")%></b></legend>

<jsp:include page="/WEB-INF/pages/components/edits.jsp"/>

    <p><%= HtmlUtils.escapeChars(displayName) %> - <%= bundle.getString("deleteUserConfSentence1") %> <%= bundle.getString("deleteUserConfSentence2") %></p>
    <input type="submit" name="action" value="<%= bundle.getString("deleteLabel")%>"/>
    <input type="submit" name="action" value="<%= bundle.getString("cancelLabel")%>"/>
    <input type="hidden" name="userId" value="<%=userIdRequest%>"/>
    <input type="hidden" name="csrfToken" value="<%= SessionUtils.getCSRFToken(request) %>"/>
    </fieldset>
</form>
<%--
<h1><%= bundle.getString("apptsLabel") %></h1>
<jsp:include page="/WEB-INF/pages/components/apptTable.jsp"/>
--%>

<jsp:include page="/WEB-INF/pages/components/footer.jsp"/>
</body>
</html>