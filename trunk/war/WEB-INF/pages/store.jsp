<%-- This JSP has the HTML for the store page. --%>
<%@ page language="java"%>
<%@ page import="java.util.Arrays" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="java.util.TimeZone" %>
<%@ page import="sched.data.StoreAdd" %>
<%@ page import="sched.data.StoreGetAll" %>
<%@ page import="sched.data.UserSetCurrent" %>
<%@ page import="sched.data.model.Store" %>
<%@ page import="sched.data.model.User" %>
<%@ page import="sched.utils.DateUtils" %>
<%@ page import="sched.utils.HtmlUtils" %>
<%@ page import="sched.utils.RequestUtils" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="sched.utils.SessionUtils" %>
<%@ page import="sched.utils.StringUtils" %>
<%
    // Verify user is logged on.
    if (!SessionUtils.isLoggedOn(request))
    {
        RequestUtils.resetAction(request);
        RequestUtils.removeEdits(request);
        %>
        <jsp:forward page="/logonForward.jsp"/>
        <%
    }
    
    ResourceBundle bundle = ResourceBundle.getBundle("Text", SessionUtils.getLocale(request));            
    
    String DEFAULT_TIMEZONE="America/Chicago";
    String storeName="";	
    String timeZone=DEFAULT_TIMEZONE;	

    // Process based on action
    boolean hasAction=false;
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
    
        if (action.equals(bundle.getString("addLabel")) && !RequestUtils.isForwarded(request))
        {
            hasAction=true;

            storeName=RequestUtils.getAlphaInput(request,"storeName",bundle.getString("storeNameLabel"),true);
            timeZone=RequestUtils.getAlphaInput(request,"timeZone",bundle.getString("timeZoneLabel"),true);

            if (!RequestUtils.hasEdits(request))
            {
                new StoreAdd().execute(request);
            }

            // If successful, reset form.			
            if (!RequestUtils.hasEdits(request))
            {
                storeName="";
                timeZone=DEFAULT_TIMEZONE;
            }
            
            new StoreGetAll().execute(request);
        }

        if (action.equals(bundle.getString("selectLabel")))
        {
            hasAction=true;

            // Get store Id
            Long storeIdLong=RequestUtils.getNumericInput(request,"storeId",bundle.getString("storeIdLabel"),true);

            if (!RequestUtils.hasEdits(request))
            {
                long storeId=storeIdLong.longValue();

                // Get all the stores for this user and select the chosen one.
                // Alternatively, 2 queries could have been made.  One to check if the user
                // is in the store and another to get the store.  But since we have to get
                // all the store anyway for display, might as well check this way and just
                // make one query.
                new StoreGetAll().execute(request);
                List<Store> stores=(List<Store>)request.getAttribute("stores");
                if (stores!=null && !stores.isEmpty())
                {
                    for (Store store : stores)
                    {
                        if (storeId==store.getKey().getId())
                        {
                            // Set store.
                            RequestUtils.setCurrentStore(request,store);
                            SessionUtils.setCurrentStoreId(request,new Long(store.getKey().getId()));

                            // Set user.
                            new UserSetCurrent().execute(request);
                            break;
                        }
                    }
                }
            }
            
            // Go to schedule page.
            %>
            <jsp:forward page="/sched.jsp"/>
            <%            
         }
    }
    
    if (!hasAction)
    {
        // Set the current store into the request.
        SessionUtils.setCurrentStoreIntoRequest(request);

        // Set the stores into the request.  This might have already been done.
        if (request.getAttribute("stores")==null);
        {
            new StoreGetAll().execute(request);
        }

        // If there is no current store, select first.
        Store currentStore=RequestUtils.getCurrentStore(request);
        if (currentStore==null)
        {
            List<Store> stores=(List<Store>)request.getAttribute("stores");
            if (stores!=null && !stores.isEmpty())
            {
                Store store=(Store)stores.get(0);
                // Set store.
                RequestUtils.setCurrentStore(request,store);
                SessionUtils.setCurrentStoreId(request,new Long(store.getKey().getId()));
            }
        }

        // If there is a store, set the current user.
        if (RequestUtils.getCurrentStore(request)!=null)
        {
            // Set user.
            new UserSetCurrent().execute(request);
        }
    }
%>
<%@ include file="/WEB-INF/pages/components/noCache.jsp" %>
<%@ include file="/WEB-INF/pages/components/docType.jsp" %>
<title><%=bundle.getString("storesLabel")%></title>
<link type="text/css" rel="stylesheet" href="/stylesheets/main.css" />
<meta http-equiv="Content-Type" content="text/html;charset=utf-8" /></head>
<body>
<jsp:include page="/WEB-INF/pages/components/navLinks.jsp"/>

<form id="updates" method="post" action="store.jsp" autocomplete="off">
    <fieldset class="action">
      <legend><b><%=bundle.getString("addStoreLabel")%></b></legend>

<jsp:include page="/WEB-INF/pages/components/edits.jsp"/>

    <table>
    <tr><td><label for="storeName"><%=bundle.getString("storeNameLabel")%></label></td><td><input type="text" name="storeName" value="<%= HtmlUtils.escapeChars(storeName) %>" id="storeName" maxlength="100" title="<%=bundle.getString("storeNameLabel")%>"/></td></tr>
    <tr><td><label for="timeZone"><%=bundle.getString("timeZoneLabel")%></label></td><td>

<select name="timeZone" title="<%=bundle.getString("timeZonesLabel")%>" id="timeZone">
<% request.setAttribute("timeZone",timeZone); %>
<jsp:include page="/WEB-INF/pages/components/timeZoneSelectOptions.jsp"/>
</select>
</td></tr>

    </table>
      <br/>
      
    <input type="submit" style="display:none" id="addButtonDisabled" disabled="disabled" value="<%=bundle.getString("addLabel")%>"/>
    <input type="submit" name="action" onclick="this.style.display='none';document.getElementById('addButtonDisabled').style.display='inline';" value="<%=bundle.getString("addLabel")%>"/>
    <input type="hidden" name="csrfToken" value="<%= SessionUtils.getCSRFToken(request) %>"/>

    </fieldset>

</form>
<br/>

<%
    List<Store> stores=(List<Store>)request.getAttribute("stores");
    Map<Long,User> currentUserInStores=(Map<Long,User>)request.getAttribute("currentUserInStores");

    if (stores!=null && !stores.isEmpty())
    {    
        out.write("<table border=\"1\" style=\"text-align:left;\"><tr>");
        out.write("<th>" + bundle.getString("storeNameLabel") + "</th>");
        out.write("<th>" + bundle.getString("storeIdLabel") + "</th>");
        out.write("<th>" + bundle.getString("timeZoneLabel") + "</th>");
        out.write("<th>" + bundle.getString("currentlySelectedLabel") + "</th>");
        out.write("<th>" + bundle.getString("actionLabel") + "</th>");        
        out.write("</tr>");

        // Current store Id
        long currentStoreId=-1;
        Store currentStore=RequestUtils.getCurrentStore(request);
        if (currentStore!=null)
        {
            currentStoreId=currentStore.getKey().getId();
        }

        for (Store store : stores)
        {
            long storeId=store.getKey().getId();

            // Check if admin
            boolean isAdmin=false;
            User user=currentUserInStores.get(new Long(storeId));
            if (user!=null)
            {
                isAdmin=user.getIsAdmin();
            }

            // Name
            out.write("<tr>");
            out.write("<td>");            
            out.write( HtmlUtils.escapeChars(store.getName()) );
            out.write("</td>");

            // Created by
            out.write("<td>");
            out.write( new Long(storeId).toString() );
            out.write("</td>");            

            // Time zone
            out.write("<td>");
            out.write( HtmlUtils.escapeChars(store.getTimeZoneId()) );
            out.write("</td>");            

            // Selected?
            out.write("<td>");
            if (currentStoreId==storeId)
            {
                out.write(bundle.getString("yesLabel"));
            }
            else
            {
                out.write("&nbsp;");
            }
            out.write("</td>");
            
            // Actions
            out.write("<td>");            
            out.write("<a href=\"store.jsp?action=" + bundle.getString("selectLabel"));
            out.write("&storeId=" + storeId);
            out.write("&csrfToken=" + SessionUtils.getCSRFToken(request));
            out.write("\">" + bundle.getString("selectLabel") + "</a>");
            
            // Admin only actions
            if (isAdmin)
            {
                // Edit
                out.write(" <a href=\"store_edit.jsp?storeId=" + storeId + "\">" + bundle.getString("editLabel") + "</a>");
    
                // Delete
                out.write(" <a href=\"store_delete.jsp?storeId=" + storeId + "\">" + bundle.getString("deleteLabel") + "</a>");
            }

            out.write("</td>");
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