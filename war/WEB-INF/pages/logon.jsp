<%-- This JSP has the HTML for the log on page.--%>
<%@ page language="java"%>
<%@ page import="com.google.appengine.api.users.UserService" %>
<%@ page import="com.google.appengine.api.users.UserServiceFactory" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="sched.data.StoreGetAll" %>
<%@ page import="sched.data.UserSetCurrent" %>
<%@ page import="sched.data.model.Store" %>
<%@ page import="sched.utils.RequestUtils" %>
<%@ page import="sched.utils.SessionUtils" %>
<% 
    // If not secure, redirect to https.  But do not redirect if testing
    // locally as the SDK doesn't support https as of 1/30/2010.
    if (!request.isSecure() && request.getServerName().indexOf("localhost")==-1)
    {
        %>
        <jsp:forward page="/logonRedirect.jsp"/>
        <%
    }

    // Check if signed in by checking Google user info.
    UserService userService = UserServiceFactory.getUserService();

    // True to get new session Id.
    String logonUrl = RequestUtils.getLogonUri(request,true);
    boolean isSignedIn=request.getUserPrincipal()!= null;

    // If signed in, mark session as logged on.  Also, get the user's stores and route to the
    // appropriate page.
    if (isSignedIn)
    {
        session.setAttribute("loggedOn",new Boolean(true));
        SessionUtils.setCSRFToken(request);

        // Get all stores available for this user
        new StoreGetAll().execute(request);
        List<Store> stores=(List<Store>)request.getAttribute("stores");

        // If user has only one store available, forward to schedule page.
        if (stores!=null && stores.size()==1)
        {
            // Select store and user
            Store store=(Store)stores.get(0);
            RequestUtils.setCurrentStore(request,store);
            SessionUtils.setCurrentStoreId(request,new Long(store.getKey().getId()));

            new UserSetCurrent().execute(request);
            %>
            <jsp:forward page="/sched.jsp"/>
            <%
        }
        // If user has more than 1 or no stores, forward to store page to select or add a store.
        else
        {
            %>
            <jsp:forward page="/store.jsp"/>
            <%
        }
    }
    // Marked session as logged off.
    else
    {
        session.setAttribute("loggedOn",new Boolean(false));
    }
    
    ResourceBundle bundle = ResourceBundle.getBundle("Text", SessionUtils.getLocale(request));        
%>
<%@ include file="/WEB-INF/pages/components/noCache.jsp" %>
<%@ include file="/WEB-INF/pages/components/docType.jsp" %>
<title><%= bundle.getString("signOnLink")%></title>
<link type="text/css" rel="stylesheet" href="/stylesheets/main.css" />
<meta http-equiv="Content-Type" content="text/html;charset=utf-8" /></head>
<body>

<div style="float:left;"><h1><%= bundle.getString("logonHeading")%></h1><p><%= bundle.getString("logonPara")%></p></div>

<jsp:include page="/WEB-INF/pages/components/navLinksPreAuth.jsp"/>

<p><a href="<%=userService.createLoginURL(logonUrl)%>"><%= bundle.getString("signOnLink")%></a> <%= bundle.getString("signOnPara")%></p>

<jsp:include page="/WEB-INF/pages/components/footer.jsp"/>
</body>
</html>