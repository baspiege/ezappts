<%-- This JSP creates a list of service select options. --%>
<%@ page language="java"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Map.Entry" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="sched.data.model.Service" %>
<%@ page import="sched.utils.DisplayUtils" %>
<%@ page import="sched.utils.HtmlUtils" %>
<%@ page import="sched.utils.RequestUtils" %>
<%@ page import="sched.utils.SessionUtils" %>
<%

    ResourceBundle bundle = ResourceBundle.getBundle("Text", SessionUtils.getLocale(request));

    boolean showApptTempateDescOnly=((Boolean)request.getAttribute("showServiceDescOnly")).booleanValue();

    Map<Long,Service> services=(Map<Long,Service>)RequestUtils.getServices(request);
    if (services!=null && !services.isEmpty())
    {
        Long serviceIdSelect=(Long)request.getAttribute("serviceId");
        if (serviceIdSelect==null)
        {
            serviceIdSelect=new Long(Service.ALL_SERVICES);
        }

        Iterator iter = services.entrySet().iterator();

        while (iter.hasNext())
        {
            Entry entry = (Entry)iter.next();
            Long serviceId=(Long)entry.getKey();
            Service service=(Service)entry.getValue();

            out.write("<option");

            // Selected
            if (serviceIdSelect.equals(serviceId))
            {
                out.write(" selected=\"true\"");
            }

            out.write(" value=\"");
            out.write( serviceId.toString() );
            out.write("\">");
            out.write( HtmlUtils.escapeChars(service.getDesc()) );

            if (!showApptTempateDescOnly)
            {
                // Duration
                out.write(" (");
                out.write(HtmlUtils.escapeChars(DisplayUtils.formatDuration(service.getDuration())));
                out.write(")");
            }

            out.write("</option>");
        }

        out.write("<option value=\"" + Service.NO_SERVICE + "\"");

        // No service selected        
        if (serviceIdSelect.equals(new Long(Service.NO_SERVICE)))
        {
            out.write(" selected=\"true\"");
        }

        out.write("\">");

        out.write(bundle.getString("noServiceLabel"));

        out.write("</option>");
    }
    else
    {
        out.write("<option value=\"" + Service.NO_SERVICE + "\">" + bundle.getString("noServicesAddedLabel") + "</option>");
    }
%>