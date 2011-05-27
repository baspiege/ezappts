<%-- This JSP has the HTML for the user update page. --%>
<%@ page language="java"%>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="sched.data.UserGetSingle" %>
<%@ page import="sched.data.UserUpdate" %>
<%@ page import="sched.data.model.User" %>
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
    
    // Get Id
    Long userIdRequest=RequestUtils.getNumericInput(request,"userId",bundle.getString("userIdLabel"),true);
    if (userIdRequest==null)
    {
        RequestUtils.resetAction(request);
        RequestUtils.removeEdits(request);
        %>
        <jsp:forward page="/user.jsp"/>
        <%
    }

    // Set fields
    String firstName="";
    String lastName="";
    String emailAddr="";
    String userType="";
    String phone="";
    String note="";

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
        
        // Set fields
        firstName=user.getFirstName();
        lastName=user.getLastName();
        emailAddr=user.getEmailAddress();
        phone=user.getPhone();
        note=user.getNote();
        
        if (user.getIsAdmin())
        {
            userType="admin";
        }
        else if (user.getIsStaff())
        {
            userType="staff";        
        }
        else
        {
            userType="customer";
        }
        
        request.setAttribute("userType",userType);

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
                firstName=RequestUtils.getAlphaInput(request,"firstName",bundle.getString("firstNameLabel"),true);
    
                // Optional
                lastName=RequestUtils.getAlphaInput(request,"lastName",bundle.getString("lastNameLabel"),false);
                emailAddr=RequestUtils.getAlphaInput(request,"emailAddr",bundle.getString("emailAddressLabel"),false);
                userType=RequestUtils.getAlphaInput(request,"userType",bundle.getString("userTypeLabel"),true);
                phone=RequestUtils.getAlphaInput(request,"phone",bundle.getString("phoneLabel"),false);
                note=RequestUtils.getAlphaInput(request,"note",bundle.getString("noteLabel"),false);
        
                if (!RequestUtils.hasEdits(request))
                {
                    new UserUpdate().execute(request);
                }
    
                // If the user changes their own email, forward to logon so they re-enter the site.
                Boolean userChangedOwnEmailAddress=(Boolean)request.getAttribute("userChangedOwnEmailAddress");
                if (userChangedOwnEmailAddress!=null && userChangedOwnEmailAddress.booleanValue())
                {
                    RequestUtils.resetAction(request);
                    RequestUtils.removeEdits(request);
                    %>
                    <jsp:forward page="/logonForward.jsp"/>
                    <%
                }

                // If successful, go back to user page.
                if (!RequestUtils.hasEdits(request))
                {            
                    RequestUtils.resetAction(request);
                    request.setAttribute("userType",null);

                    // Route to user page.
                    %>
                    <jsp:forward page="/user.jsp"/>
                    <%
                }
            }
        }
    }
%>
<%@ include file="/WEB-INF/pages/components/noCache.jsp" %>
<%@ include file="/WEB-INF/pages/components/docType.jsp" %>
<title><%= HtmlUtils.escapeChars(RequestUtils.getCurrentStoreName(request)) %> - <%= bundle.getString("editUserLabel") %></title>
<link type="text/css" rel="stylesheet" href="/stylesheets/main.css" />
<meta http-equiv="Content-Type" content="text/html;charset=utf-8" /></head>
<body>
<jsp:include page="/WEB-INF/pages/components/navLinks.jsp"/>

<form id="updates" method="post" action="user_edit.jsp?userId=<%=userIdRequest%>" autocomplete="off">
    <fieldset class="action">
      <legend><b><%= bundle.getString("editUserLabel") %></b></legend>

<jsp:include page="/WEB-INF/pages/components/edits.jsp"/>

    <table>
    <tr><td><label for="firstName"><%= bundle.getString("firstNameLabel") %> (<%= bundle.getString("requiredLabel") %>)</label></td><td><input type="text" name="firstName" title="<%= bundle.getString("firstNameLabel") %>" value="<%=HtmlUtils.escapeChars(firstName)%>" id="firstName" maxlength="100"/></td></tr>
    <tr><td><label for="lastName"><%= bundle.getString("lastNameLabel") %></label></td><td><input type="text" name="lastName" title="<%= bundle.getString("lastNameLabel") %>" value="<%=HtmlUtils.escapeChars(lastName)%>" id="lastName" maxlength="100"/></td></tr>
    <tr><td><label for="emailAddr"><%= bundle.getString("emailAddressLabel") %><sup><small>*</small></sup></label></td><td><input type="text" name="emailAddr" title="<%= bundle.getString("emailAddressLabel") %>" value="<%=HtmlUtils.escapeChars(emailAddr)%>" id="emailAddr" maxlength="100"/></td></tr>
    <tr><td><label for="phone"><%= bundle.getString("phoneLabel")%></label></td><td><input type="text" name="phone" title="<%= bundle.getString("phoneLabel")%>" value="<%=HtmlUtils.escapeChars(phone)%>" id="phone" maxlength="100"/></td></tr>
    <tr><td><label for="note"><%= bundle.getString("noteLabel")%></label></td><td><input type="text" name="note" title="<%= bundle.getString("noteLabel")%>" value="<%=HtmlUtils.escapeChars(note)%>" id="note" maxlength="100"/></td></tr>

    <tr><td><label for="userType"><%= bundle.getString("typeLabel")%></label></td><td>
        <jsp:include page="/WEB-INF/pages/components/userTypeSelect.jsp"/></td></tr>

    </table>

    <p><sup><small>*</small></sup><%= bundle.getString("userEmailSignInFootnote")%> <%= bundle.getString("userEmailChangeFootnote")%> </p> 

    <input type="hidden" name="csrfToken" value="<%= SessionUtils.getCSRFToken(request) %>"/>
    <input type="submit" name="action" value="<%= bundle.getString("updateLabel")%>"/> <input type="submit" name="action" value="<%= bundle.getString("cancelLabel")%>"/>
    </fieldset>
</form>

<jsp:include page="/WEB-INF/pages/components/footer.jsp"/>
</body>
</html>