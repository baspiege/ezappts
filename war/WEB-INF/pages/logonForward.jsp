<%-- This JSP forwards to the logon page. --%>
<%@ page language="java"%>
<%@ page import="sched.utils.RequestUtils" %>
<%@ page import="sched.utils.SessionUtils" %>
<% 
    //Invalidate the session to remove all data from session.
    session.invalidate();
    request.getSession(true);
    
    // Remove current store.
    //RequestUtils.setCurrentStore(request,null);
    //SessionUtils.setCurrentStoreId(request,null);    
%>
<jsp:forward page="/logon.jsp"/>