<%-- This JSP has the HTML for the about page.--%>
<%@ page language="java"%>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="sched.data.UserSetCurrent" %>
<%@ page import="sched.utils.RequestUtils" %>
<%@ page import="sched.utils.SessionUtils" %>
<%
    // Set the current store into the request.
    SessionUtils.setCurrentStoreIntoRequest(request);

    // Set user if there is a store.
    if (RequestUtils.getCurrentStore(request)!=null)
    {
        new UserSetCurrent().execute(request);
    }
    
    ResourceBundle bundle = ResourceBundle.getBundle("Text", SessionUtils.getLocale(request));    
%>
<%@ include file="/WEB-INF/pages/components/noCache.jsp" %>
<%@ include file="/WEB-INF/pages/components/docType.jsp" %>
<title><%= bundle.getString("aboutLabel")%></title>
<link type="text/css" rel="stylesheet" href="/stylesheets/main.css" />
<style type="text/css">
ul {margin-top:0; margin-bottom:0;}
</style>
<meta http-equiv="Content-Type" content="text/html;charset=utf-8" /></head>
<body>

<%-- Get nav based on authentication. --%>
<%@ page import="sched.utils.SessionUtils" %>
<%
    String heading="<h1>" + bundle.getString("aboutSiteHeading") + "</h1>";

    // If user is logged on, use full nav.
    if (SessionUtils.isLoggedOn(request))
    {
        %>
        <jsp:include page="/WEB-INF/pages/components/navLinks.jsp"/>
        <%
        out.write(heading);
    }
    else
    {
        %>
        <div style="float:left;">
        <p><a href="logon.jsp"><%= bundle.getString("homeLabel")%></a></p>
        </div>
        <jsp:include page="/WEB-INF/pages/components/navLinksPreAuth.jsp"/>
        <%
        out.write(heading);
    }
%>

<p><%= bundle.getString("aboutSitePara1")%></p>
<%-- <p> bundle.getString("aboutSitePara2") </p> --%>

<h2> <%= bundle.getString("benefitsHeading")%> </h2>
<ul>
<li> <%= bundle.getString("benefitsBullet1")%> </li>
</ul>

<h2> <%= bundle.getString("securityLabel")%> </h2>

<table border="1">
<%-- <caption style="text-align:left;"><b> bundle.getString("accessTableCaption") </b></caption> --%>
<tr><th><%= bundle.getString("userTypeLabel")%></th><th><%= bundle.getString("accessLabel")%></th></tr>
<tr><td><%= bundle.getString("customerLabel")%></td><td>
<ul>
<li> <%= bundle.getString("customerAccess1")%> </li>
<li> <%= bundle.getString("customerAccess2")%> </li>
</ul>
</td></tr>

<tr><td><%= bundle.getString("staffLabel")%></td><td>
<ul>
<li> <%= bundle.getString("staffAccess1")%> </li>
<li> <%= bundle.getString("staffAccess2")%> </li>
</ul>
</td></tr>

<tr><td><%= bundle.getString("administratorLabel")%></td><td>
<ul>
<li> <%= bundle.getString("adminUserAccess1")%> </li>
</ul>
</td></tr>
</table>

<h2> <%= bundle.getString("deletionPolicyHeading")%> </h2>
<ul>
<li> <%= bundle.getString("deletionPolicyBullet1")%> </li>
<li> <%= bundle.getString("deletionPolicyBullet2")%> </li>
</ul>

<h2> <%= bundle.getString("contactUsLabel")%> </h2>
<p  style="margin-top:0;"> <%= bundle.getString("contactPara")%> </p>

<jsp:include page="/WEB-INF/pages/components/footer.jsp"/>
</body>
</html>