<%@ page import="java.util.Calendar" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="sched.utils.SessionUtils" %>
<% ResourceBundle bundle = ResourceBundle.getBundle("Text", SessionUtils.getLocale(request)); %>
<hr/>
<p style="font-size:small;"><%= bundle.getString("copyright")%> <%= Calendar.getInstance().get(Calendar.YEAR) %> Brian Spiegel</p>