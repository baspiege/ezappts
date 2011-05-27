<%-- This JSP has the HTML for the store update page.--%>
<%@ page language="java"%>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="sched.data.StoreGetSingle" %>
<%@ page import="sched.data.UserSetCurrent" %>
<%@ page import="sched.data.StoreUpdate" %>
<%@ page import="sched.data.model.Store" %>
<%@ page import="sched.data.model.User" %>
<%@ page import="sched.utils.DateUtils" %>
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
        <jsp:forward page="/WEB-INF/pages/store.jsp"/>
        <%
    }

    // Verify user is logged on.
    if (!SessionUtils.isLoggedOn(request))
    {
        RequestUtils.resetAction(request);
        RequestUtils.removeEdits(request);
        %>
        <jsp:forward page="/logonForward.jsp"/>
        <%
    }

    // Get Store Id
    Long storeIdRequest=RequestUtils.getNumericInput(request,"storeId",bundle.getString("storeIdLabel"),true);
    if (storeIdRequest==null)
    {
        RequestUtils.resetAction(request);
        RequestUtils.removeEdits(request);
        %>
        <jsp:forward page="/store.jsp"/>
        <%
    }
    
    // Set fields
    String storeName="";
    String timeZone="";	

    // Get store
    new StoreGetSingle().execute(request);
    Store store=(Store)request.getAttribute("store");

    // If no store, forward to store page.
    if (store==null)
    {
        // Forward them to the store page.
        RequestUtils.resetAction(request);
        RequestUtils.removeEdits(request);
        %>
        <jsp:forward page="/store.jsp"/>
        <%
    }
    
    // Set store.
    RequestUtils.setCurrentStore(request,store);

    // Set user.
    new UserSetCurrent().execute(request);

    // Check if admin
    User currentUser=RequestUtils.getCurrentUser(request);
    boolean isCurrentUserAdmin=false;
    if (currentUser!=null && currentUser.getIsAdmin())
    {
        isCurrentUserAdmin=true;
    }
    else
    {
        // Forward them to the store page.
        RequestUtils.resetAction(request);
        RequestUtils.removeEdits(request);
        %>
        <jsp:forward page="/store.jsp"/>
        <%
    }

    // Get store info
    if (!RequestUtils.hasEdits(request))
    {
        storeName=store.getName();
        timeZone=store.getTimeZoneId();
    }
    else
    {
        RequestUtils.resetAction(request);
        RequestUtils.removeEdits(request);
        %>
        <jsp:forward page="/store.jsp"/>
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
    
        if (action.equals(bundle.getString("updateLabel")))
        {
            storeName=RequestUtils.getAlphaInput(request,"storeName",bundle.getString("storeNameLabel"),true);
            timeZone=RequestUtils.getAlphaInput(request,"timeZone",bundle.getString("timeZoneLabel"),true);

            if (!RequestUtils.hasEdits(request))
            {
                new StoreUpdate().execute(request);
            }
            
            // If successful, go back to store page.
            if (!RequestUtils.hasEdits(request))
            {
                // Route to store page.
                RequestUtils.resetAction(request);
                %>
                <jsp:forward page="/store.jsp"/>
                <%
            }
        }
    }

%>
<%@ include file="/WEB-INF/pages/components/noCache.jsp" %>
<%@ include file="/WEB-INF/pages/components/docType.jsp" %>
<title><%=bundle.getString("editStoreLabel")%></title>
<link type="text/css" rel="stylesheet" href="/stylesheets/main.css" />
<meta http-equiv="Content-Type" content="text/html;charset=utf-8" /></head>
<body>
<jsp:include page="/WEB-INF/pages/components/navLinks.jsp"/>

  <form id="store" method="post" action="store_edit.jsp?storeId=<%=storeIdRequest%>" autocomplete="off">
    <fieldset class="action">
      <legend><b><%=bundle.getString("editStoreLabel")%></b></legend>

<jsp:include page="/WEB-INF/pages/components/edits.jsp"/>

    <table>
    <tr><td><label for="storeName"><%=bundle.getString("storeNameLabel")%></label></td><td><input type="text" name="storeName" value="<%= HtmlUtils.escapeChars(storeName) %>" id="storeName" maxlength="100" title="<%=bundle.getString("storeNameLabel")%>"/></td></tr>
    <tr><td><label for="timeZone"><%=bundle.getString("timeZoneLabel")%><sup><small>*</small></sup></label></td><td>

<select name="timeZone" title="<%=bundle.getString("timeZonesLabel")%>" id="timeZone">
<% request.setAttribute("timeZone",timeZone); %>
<jsp:include page="/WEB-INF/pages/components/timeZoneSelectOptions.jsp"/>
</select>
</td></tr>
    </table>
    
    <p><sup><small>*</small></sup><%=bundle.getString("timeZonesEditStoreFootNote1")%> </p> 
    <input type="hidden" name="csrfToken" value="<%= SessionUtils.getCSRFToken(request) %>"/>    
    <input type="submit" name="action" value="<%=bundle.getString("updateLabel")%>"/> <input type="submit" name="action" value="<%=bundle.getString("cancelLabel")%>"/>
    </fieldset>
</form>

<jsp:include page="/WEB-INF/pages/components/footer.jsp"/>
</body>
</html>