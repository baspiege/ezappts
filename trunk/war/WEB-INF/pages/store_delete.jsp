<%-- This JSP has the HTML for the store delete page. --%>
<%@ page language="java"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="sched.data.StoreDelete" %>
<%@ page import="sched.data.StoreGetSingle" %>
<%@ page import="sched.data.UserSetCurrent" %>
<%@ page import="sched.data.model.Store" %>
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
    
    // Get Id
    Long storeIdRequest=RequestUtils.getNumericInput(request,"storeId",bundle.getString("storeIdLabel"),true);
    if (storeIdRequest==null)
    {
        RequestUtils.resetAction(request);
        RequestUtils.removeEdits(request);
        %>
        <jsp:forward page="/store.jsp"/>
        <%
    }

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

    // Display name
    String displayName="";

    // Get store info
    if (!RequestUtils.hasEdits(request))
    {
        displayName=HtmlUtils.escapeChars( store.getName() );
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
    
        if (action.equals(bundle.getString("deleteLabel")))
        {
            new StoreDelete().execute(request);

            // If successful, go back to store page.
            if (!RequestUtils.hasEdits(request))
            {
                // Since store is removed, remove from session and request.
                RequestUtils.setCurrentStore(request,null);
                SessionUtils.setCurrentStoreId(request,null);

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
<title><%= displayName %> - <%= bundle.getString("deleteStoreLabel") %></title>
<link type="text/css" rel="stylesheet" href="/stylesheets/main.css" />
<meta http-equiv="Content-Type" content="text/html;charset=utf-8" /></head>
<body>
<jsp:include page="/WEB-INF/pages/components/navLinks.jsp"/>

<form id="updates" method="post" action="store_delete.jsp">

  <fieldset class="action">
    <legend><b><%= bundle.getString("deleteStoreLabel") %></b></legend>

<jsp:include page="/WEB-INF/pages/components/edits.jsp"/>

    <p><%= displayName %> - <%= bundle.getString("deleteConfStoreSentence1") %> <%= bundle.getString("deleteConfStoreSentence2") %></p>
    <input type="submit" name="action" value="<%= bundle.getString("deleteLabel") %>"/>
    <input type="submit" name="action" value="<%= bundle.getString("cancelLabel") %>"/>
    <input type="hidden" name="storeId" value="<%=storeIdRequest%>"/>
    <input type="hidden" name="csrfToken" value="<%= SessionUtils.getCSRFToken(request) %>"/>
    </fieldset>
</form>

<jsp:include page="/WEB-INF/pages/components/footer.jsp"/>
</body>
</html>