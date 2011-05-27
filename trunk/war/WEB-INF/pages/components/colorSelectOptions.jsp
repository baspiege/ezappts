<%-- This JSP creates a list of appt template select options. --%>
<%@ page language="java"%>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.ResourceBundle" %>
<%@ page import="sched.utils.DisplayUtils" %>
<%@ page import="sched.utils.HtmlUtils" %>
<%@ page import="sched.utils.RequestUtils" %>
<%@ page import="sched.utils.SessionUtils" %>
<%

    ResourceBundle colorBundle = ResourceBundle.getBundle("Color", SessionUtils.getLocale(request));

    // When adding new colors, add to resource bundle for labels.
    String[] colors={"000000","808080","A9A9A9","D3D3D3","FFFFFF","7FFFD4",
                     "0000FF","000080","800080","FF1493","EE82EE","FFC0CB",
                     "006400","008000","9ACD32","FFFF00","FFA500","FF0000",
                     "A52A2A","DEB887","F5F5DC"};

    String color=(String)request.getAttribute("color");

    for (String colorKey: colors)
    {
        out.write("<option");

        // Selected
        if (colorKey.equalsIgnoreCase(color))
        {
            out.write(" selected=\"true\"");
        }

        String label=colorBundle.getString(colorKey);

        out.write(" value=\"");
        out.write( colorKey );
        out.write("\" style=\"background-color:#");
        out.write( colorKey );
        out.write(";\">");
        out.write(label);
        out.write("</option>");
    }
%>