<%-- This JSP has the HTML for the service page.--%>
<%@ page language="java"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Map.Entry" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="sched.data.ServiceAddUpdate" %>
<%@ page import="sched.data.model.Service" %>
<%@ page import="sched.data.model.User" %>
<%@ page import="sched.utils.DisplayUtils" %>
<%@ page import="sched.utils.HtmlUtils" %>
<%@ page import="sched.utils.RequestUtils" %>
<%@ page import="sched.utils.SessionUtils" %>
<%@ page import="sched.utils.StringUtils" %>
<%
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
        // Forward them to the sched page.
        RequestUtils.resetAction(request);
        RequestUtils.removeEdits(request);
        %>
        <jsp:forward page="/sched.jsp"/>
        <%
    }

    // Default
    String desc="";
    String color="000000";

    ResourceBundle bundle = ResourceBundle.getBundle("Text", SessionUtils.getLocale(request));
    ResourceBundle colorBundle = ResourceBundle.getBundle("Color", SessionUtils.getLocale(request));

    // Process based on action
    String action=RequestUtils.getAlphaInput(request,"action","Action",false);
    if (!StringUtils.isEmpty(action) && !RequestUtils.isForwarded(request))
    {
        Long token=RequestUtils.getNumericInput(request,"csrfToken","CSRF Token",true);
        if (!SessionUtils.isCSRFTokenValid(request,token))
        {
            %>
            <jsp:forward page="/logonForward.jsp"/>
            <%
        }
    
        if (isCurrentUserAdmin && action.equals(bundle.getString("addLabel")))
        {
            // Description
            desc=RequestUtils.getAlphaInput(request,"desc",bundle.getString("nameLabel"),true);
            
            // Color
            color=RequestUtils.getColorInput(request,"color",bundle.getString("colorLabel"),true);

            // Duration
            Long durationHour=RequestUtils.getNumericInput(request,"durationHour",bundle.getString("durationHoursLabel"),true);
            Long durationMinute=RequestUtils.getNumericInput(request,"durationMinute",bundle.getString("durationMinutesLabel"),true);

            if (!RequestUtils.hasEdits(request))
            {
                new ServiceAddUpdate().execute(request);
            }

            // If successful, reset form.
            if (!RequestUtils.hasEdits(request))
            {
                desc="";
                request.setAttribute("color",null);
            }
        }
    }

    String title=HtmlUtils.escapeChars(RequestUtils.getCurrentStoreName(request));
%>
<%@ include file="/WEB-INF/pages/components/noCache.jsp" %>
<%@ include file="/WEB-INF/pages/components/docType.jsp" %>
<title><%= title %> <%=bundle.getString("servicesLabel") %></title>
<link type="text/css" rel="stylesheet" href="/stylesheets/main.css" />
<meta http-equiv="Content-Type" content="text/html;charset=utf-8" /></head>
<body>
<jsp:include page="/WEB-INF/pages/components/navLinks.jsp"/>

<%
// Display add for admins only
if (isCurrentUserAdmin)
{
%>
  <form id="service" method="post" action="service.jsp" autocomplete="off">
    <fieldset class="action">
      <legend><b><%=bundle.getString("addServiceLabel") %></b></legend>

<jsp:include page="/WEB-INF/pages/components/edits.jsp"/>

      <table>
        <tr><td><label for="desc"><%=bundle.getString("nameLabel")%></label></td><td><input type="text" name="desc" value="<%=HtmlUtils.escapeChars(desc)%>" id="desc" maxlength="100" title="<%=bundle.getString("nameLabel")%>"/></td></tr>

        <tr>
          <td><%=bundle.getString("defaultDurationLabel")%></td>
          <td><% request.setAttribute("apptDatePrefix","duration"); %><jsp:include page="/WEB-INF/pages/components/durationSelect.jsp"/></td>
        </tr>
        
        <tr>
          <td><%=bundle.getString("colorLabel")%></td>
          <td><select name="color" title="<%=bundle.getString("colorLabel")%>"><jsp:include page="/WEB-INF/pages/components/colorSelectOptions.jsp"/></select></td>
        </tr>

      </table>
      <br/>

      <input type="hidden" name="csrfToken" value="<%= SessionUtils.getCSRFToken(request) %>"/>

      <input type="submit" style="display:none" id="addButtonDisabled" disabled="disabled" value="<%=bundle.getString("addLabel")%>"/>
      <input type="submit" name="action" onclick="this.style.display='none';document.getElementById('addButtonDisabled').style.display='inline';" value="<%=bundle.getString("addLabel")%>"/>
    </fieldset>
  </form>
  <br/>
<%
}
%>

<%
    Map<Long,Service> services=RequestUtils.getServices(request);

    if (services!=null && !services.isEmpty())
    {
        out.write("<table border=\"1\" style=\"text-align:left;\"><tr>");
        out.write("<th>" + bundle.getString("nameLabel") + "</th>");
        out.write("<th>" + bundle.getString("defaultDurationLabel") + "</th>");
        out.write("<th>" + bundle.getString("colorLabel") + "</th>");

        // If non-admins, can do actions, update the logic below.
        if (isCurrentUserAdmin)
        {
            out.write("<th>" + bundle.getString("actionLabel") + "</th>");
        }
        out.write("</tr>");

        Iterator iter = services.entrySet().iterator();
        while (iter.hasNext())
        {
            Entry entry = (Entry)iter.next();
            Service service=(Service)entry.getValue();

            out.write("<tr>");

            // Display desc
            out.write("<td>");
            out.write( HtmlUtils.escapeChars(service.getDesc()) );
            out.write("</td>");

            // Duration
            out.write("<td>");
            out.write(HtmlUtils.escapeChars(DisplayUtils.formatDuration(service.getDuration())) );
            out.write("</td>");
            
            // Color
            out.write("<td>");
            if (service.getColor()!=null)
            {
                out.write("<div style=\"border-style:solid;border-width:2px;border-color:#");
                out.write(HtmlUtils.escapeChars(service.getColor()));
                out.write("\">");
                
                if (colorBundle.containsKey(service.getColor()))
                {
                    out.write(colorBundle.getString(service.getColor()));                    
                }
                else
                {
                    out.write("&nbsp;");
                }
                
                out.write("<div>");
            }
            else
            {
                out.write("&nbsp;");
            }

            out.write("</td>");

            long serviceId=service.getKey().getId();

            // Update
            if (isCurrentUserAdmin)
            {
                out.write("<td>");
                out.write("<a href=\"service_edit.jsp?serviceId=" + serviceId);
                out.write("\">" + bundle.getString("editLabel") + "</a>");

                out.write(" <a href=\"service_delete.jsp?serviceId=" + serviceId);
                out.write("\">" + bundle.getString("deleteLabel") + "</a>");
                out.write("</td>");
            }

            out.write("</tr>");
        }

        out.write("</table>");
    }
    else
    {
        out.write("<p>" + bundle.getString("noneLabel") + "</p>");
    }
%>

<jsp:include page="/WEB-INF/pages/components/footer.jsp"/>
</body>
</html>