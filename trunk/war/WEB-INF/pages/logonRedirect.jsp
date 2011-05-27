<%-- This JSP invalidates the session and redirects to the logon page. --%>
<%@ page language="java"%>
<%@ page import="sched.utils.RequestUtils" %>
<% 
    // Invalidate the session to remove all data from session.
    session.invalidate();
    request.getSession(true);

    response.sendRedirect(RequestUtils.getLogonUri(request,false));
%>