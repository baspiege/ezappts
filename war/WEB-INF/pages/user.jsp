<%-- This JSP has the HTML for the user page. --%>
<%@ page language="java"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.LinkedHashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Map.Entry" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="sched.data.UserAdd" %>
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
    boolean isCurrentUserStaff=false;

    if (currentUser!=null)
    {
        if (currentUser.getIsAdmin())
        {
            isCurrentUserAdmin=true;
            isCurrentUserStaff=true;            
        }
        else if (currentUser.getIsStaff())
        {
            isCurrentUserStaff=true;            
        }
    }
    
    ResourceBundle bundle = ResourceBundle.getBundle("Text", SessionUtils.getLocale(request));                    

    // Default
    String firstName="";
    String lastName="";
    String emailAddr="";
    String userType="";
    String phone="";
    String note="";

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
            // Required
            firstName=RequestUtils.getAlphaInput(request,"firstName",bundle.getString("firstNameLabel"),true);
            userType=RequestUtils.getAlphaInput(request,"userType",bundle.getString("userTypeLabel"),true);

            // Optional
            lastName=RequestUtils.getAlphaInput(request,"lastName",bundle.getString("lastNameLabel"),false);
            emailAddr=RequestUtils.getAlphaInput(request,"emailAddr",bundle.getString("emailAddressLabel"),false);
            phone=RequestUtils.getAlphaInput(request,"phone",bundle.getString("phoneLabel"),false);
            note=RequestUtils.getAlphaInput(request,"note",bundle.getString("noteLabel"),false);
            
            if (!RequestUtils.hasEdits(request))
            {
                new UserAdd().execute(request);
            }

            // If successful, reset form.
            if (!RequestUtils.hasEdits(request))
            {
                firstName="";
                lastName="";
                emailAddr="";
                phone="";
                note="";
                userType="";
                request.setAttribute("userType","");
            }
        }
    }

    // Set the users into the request.
    if (isCurrentUserStaff)
    {
        RequestUtils.getUsers(request);
    }
    else
    {
        Map<Long,User> staffAndUser=new LinkedHashMap<Long,User>();
         
        // Add current user
        staffAndUser.put(new Long(currentUser.getKey().getId()),currentUser);
        
        // Add staff
        staffAndUser.putAll(RequestUtils.getStaff(request));

        request.setAttribute("users", staffAndUser);
    }

    // Create title.  Plural for admins.
    StringBuffer titleSb=new StringBuffer();
    titleSb.append(HtmlUtils.escapeChars(RequestUtils.getCurrentStoreName(request)));
    titleSb.append(" ");	
    titleSb.append(bundle.getString("usersLabel"));				
    
    String title=titleSb.toString();
%>
<%@ include file="/WEB-INF/pages/components/noCache.jsp" %>
<%@ include file="/WEB-INF/pages/components/docType.jsp" %>
<title><%= title %></title>
<link type="text/css" rel="stylesheet" href="/stylesheets/main.css" />
<meta http-equiv="Content-Type" content="text/html;charset=utf-8" /></head>
<body>
<jsp:include page="/WEB-INF/pages/components/navLinks.jsp"/>

<%
// Only admins can add others
if (isCurrentUserAdmin)
{
%>
<form id="updates" method="post" action="user.jsp" autocomplete="off">
    <fieldset class="action">
      <legend><b><%= bundle.getString("addUserLabel")%></b></legend>

<jsp:include page="/WEB-INF/pages/components/edits.jsp"/>

    <table>
    <tr><td><label for="firstName"><%= bundle.getString("firstNameLabel")%> (<%= bundle.getString("requiredLabel")%>)</label></td><td><input type="text" name="firstName" title="<%= bundle.getString("firstNameLabel")%>" value="<%=HtmlUtils.escapeChars(firstName)%>" id="firstName" maxlength="100"/></td></tr>
    <tr><td><label for="lastName"><%= bundle.getString("lastNameLabel")%></label></td><td><input type="text" name="lastName" title="<%= bundle.getString("lastNameLabel")%>" value="<%=HtmlUtils.escapeChars(lastName)%>" id="lastName" maxlength="100"/></td></tr>
    <tr><td><label for="emailAddr"><%= bundle.getString("emailAddressLabel")%><sup><small>*</small></sup></label></td><td><input type="text" name="emailAddr" title="<%= bundle.getString("emailAddressLabel")%>" value="<%=HtmlUtils.escapeChars(emailAddr)%>" id="emailAddr" maxlength="100"/></td></tr>
    <tr><td><label for="phone"><%= bundle.getString("phoneLabel")%></label></td><td><input type="text" name="phone" title="<%= bundle.getString("phoneLabel")%>" value="<%=HtmlUtils.escapeChars(phone)%>" id="phone" maxlength="100"/></td></tr>
    <tr><td><label for="note"><%= bundle.getString("noteLabel")%></label></td><td><input type="text" name="note" title="<%= bundle.getString("noteLabel")%>" value="<%=HtmlUtils.escapeChars(note)%>" id="note" maxlength="100"/></td></tr>
    <tr><td><label for="userType"><%= bundle.getString("typeLabel")%></label></td><td>
        <jsp:include page="/WEB-INF/pages/components/userTypeSelect.jsp"/></td></tr>

    </table>
    <p><sup><small>*</small></sup><%= bundle.getString("userEmailSignInFootnote")%></p> 
    
    <input type="submit" style="display:none" id="addButtonDisabled" disabled="disabled" value="<%=bundle.getString("addLabel")%>"/>
    <input type="submit" name="action" onclick="this.style.display='none';document.getElementById('addButtonDisabled').style.display='inline';" value="<%=bundle.getString("addLabel")%>"/>
    
    <input type="hidden" name="csrfToken" value="<%= SessionUtils.getCSRFToken(request) %>"/>
    </fieldset>
</form>
<br/>
<%  
}
%>

<%
    //out.write("<h1>" + title + "</h1>");

    Map<Long,User> users=(Map<Long,User>)request.getAttribute("users");	

    if (users!=null && !users.isEmpty())
    {

        out.write("<table border=\"1\" style=\"text-align:left;\"><tr>");
        out.write("<th>" + bundle.getString("userNameLabel") + "</th>");
        
        // Only admins can see details
        if (isCurrentUserAdmin)
        {        
            out.write("<th>" + bundle.getString("emailAddressLabel") + "</th>");
            out.write("<th>" + bundle.getString("phoneLabel") + "</th>");
        }

        out.write("<th>" + bundle.getString("typeLabel") + "</th>");        
        out.write("<th>" + bundle.getString("noteLabel") + "</th>");        
        
        // Only admins can add others
        if (isCurrentUserAdmin)
        {
            out.write("<th>" + bundle.getString("actionLabel") + "</th>");
        }
        
        out.write("</tr>");

        Iterator iter = users.entrySet().iterator();
        while (iter.hasNext())
        {
            Entry entry = (Entry)iter.next();
            User user=(User)entry.getValue();
        
            out.write("<tr>");
            
            // Name
            out.write("<td>");            
            out.write(DisplayUtils.getSpaceIfNull(DisplayUtils.formatName(user.getFirstName(),user.getLastName(),true)));
            out.write("</td>");

            // Email
            if (isCurrentUserAdmin)
            {            
                out.write("<td>");                            
                out.write(DisplayUtils.getSpaceIfNull(user.getEmailAddress()));
                out.write("</td>");            
                
                out.write("<td>");                            
                out.write(DisplayUtils.getSpaceIfNull(user.getPhone()));
                out.write("</td>");            
            }

                // User Type
                out.write("<td>");
                if (user.getIsAdmin())
                {
                    out.write(bundle.getString("administratorLabel"));
                }
                else if (user.getIsStaff())
                {
                    out.write(bundle.getString("staffLabel"));
                }
                else
                {
                    out.write(bundle.getString("customerLabel"));
                }
                
                out.write("</td>");
             
                out.write("<td>");                            
                out.write(DisplayUtils.getSpaceIfNull(user.getNote()));
                out.write("</td>");          
             
            if (isCurrentUserAdmin)
            {         
                // Actions            
                out.write("<td>");                
                long userId=user.getKey().getId();

                if (isCurrentUserAdmin)
                {                
                    // Edit
                    out.write("<a href=\"user_edit.jsp?userId=" + userId + "\">" + bundle.getString("editLabel") + "</a>");

                    // Delete
                    out.write(" <a href=\"user_delete.jsp?userId=" + userId + "\">" + bundle.getString("deleteLabel") + "</a>");
                }   
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