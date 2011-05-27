<%-- This JSP has the HTML for the delete task. --%>
<%@ page language="java"%>
<%@ page import="sched.data.DeleteInactiveStoresTask" %>
<%@ page import="sched.data.DeleteOldApptsTask" %>
<%@ page import="sched.data.DeleteTask" %>
<%
	new DeleteInactiveStoresTask().execute(request);
    new DeleteTask().execute(request);
    new DeleteOldApptsTask().execute(request);
%>

<%@ include file="/WEB-INF/pages/components/noCache.jsp" %>
<%@ include file="/WEB-INF/pages/components/docType.jsp" %>
<title> Deleting Task </title>
<link type="text/css" rel="stylesheet" href="/stylesheets/main.css" />
<meta http-equiv="Content-Type" content="text/html;charset=utf-8" /></head>
<body>

<jsp:include page="/WEB-INF/pages/components/edits.jsp"/>

<p> Delete task. </p>

<jsp:include page="/WEB-INF/pages/components/footer.jsp"/>
</body>
</html>