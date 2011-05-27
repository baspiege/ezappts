package sched.utils;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Map.Entry;
import java.util.ResourceBundle;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import sched.data.ServiceGetAll;
import sched.data.UserGetAll;
import sched.data.UserSetCurrent;
import sched.data.model.Service;
import sched.data.model.Store;
import sched.data.model.User;

/**
 * Request utilities.
 *
 * @author Brian Spiegel
 */
public class RequestUtils
{
    public static String CURRENT_STORE="currentStore";
    public static String CURRENT_USER="currentUser";
    public static String FORWARDED="forwarded";
    public static String EDITS="edits";
    public static String SERVICES="services";
    public static String USERS="users";
    public static String STAFF="staff";

    // These are thread-safe.
    private static Pattern mAlphaPattern=Pattern.compile("[a-zA-Z_0-9\\.\\&\\'\\-\\@\\!\\#\\$\\%\\*\\+\\/\\=\\?\\^\\(\\)\\{\\}\\|\\`\\\\,\\\" \\u00c0-\\u00ff]*");
    private static Pattern mAmPmPattern=Pattern.compile("(AM)|(PM)");
    private static Pattern mBooleanPattern=Pattern.compile("(true)|(false)");
    private static Pattern mColorPattern=Pattern.compile("[0-9a-fA-F]{6}");
    private static Pattern mDatePattern=Pattern.compile("(\\d)*(\\-)(\\d)*(\\-)(\\d)*");
    private static Pattern mLocalePattern=Pattern.compile("(en)|(es)");
    private static Pattern mNumbersPattern=Pattern.compile("(-)?(\\d)*");

    /**
    * Add edit.
    *
    * @param aRequest Servlet Request
    * @param aEditMessage edit message
    */
    public static void addEdit(HttpServletRequest aRequest, String aEditMessage)
    {
        getEdits(aRequest).add(aEditMessage);
    }

    /**
    * Add edit.
    *
    * @param aRequest Servlet Request
    * @param aKey key in Text ResourceBundle
    */
    public static void addEditUsingKey(HttpServletRequest aRequest, String aKey)
    {
        ResourceBundle bundle = ResourceBundle.getBundle("Text", SessionUtils.getLocale(aRequest));
        getEdits(aRequest).add(bundle.getString(aKey));
    }

    /**
    * Get a String input and store into the request if there are no edits.
    *
    * @param aRequest Servlet Request to get input from
    * @param aFieldToCheck Field to check
    * @param aDescription Description of field for edit message
    * @param aRequired Indicates if required
    * @return the field if no edits
    */
    public static String getAlphaInput(HttpServletRequest aRequest, String aFieldToCheck, String aDescription, boolean aRequired)
    {
        String value=aRequest.getParameter(aFieldToCheck);
        if (isFieldEmpty(aRequest, value, aFieldToCheck, aDescription, aRequired))
        {
            value="";
            aRequest.setAttribute(aFieldToCheck,value);
        }
        else if (!mAlphaPattern.matcher(value).matches())
        {
            value="";

            ResourceBundle bundle = ResourceBundle.getBundle("Text", SessionUtils.getLocale(aRequest));
            String editMessage=aDescription + ": " + bundle.getString("alphaFieldValidCharsEdit");
            addEdit(aRequest,editMessage);
        }
        else if (value.length()>100)
        {
            value=value.substring(0,100);
            aRequest.setAttribute(aFieldToCheck,value);

            ResourceBundle bundle = ResourceBundle.getBundle("Text", SessionUtils.getLocale(aRequest));
            String editMessage=aDescription + ": " + bundle.getString("alphaFieldMaxLengthEdit");
            addEdit(aRequest,editMessage);
        }
        else
        {
            value=value.trim();
            aRequest.setAttribute(aFieldToCheck,value);
        }

        return value;
    }

    /**
    * Get the AM/PM input and store into the request if there are no edits.
    *
    * @param aRequest Servlet Request to get input from
    * @param aFieldToCheck Field to check
    * @param aDescription Description of field for edit message
    * @param aRequired Indicates if required

    * @return the field if no edits
    */
    public static String getAmPmInput(HttpServletRequest aRequest, String aFieldToCheck, String aDescription, boolean aRequired)
    {
        String value=aRequest.getParameter(aFieldToCheck);
        if (isFieldEmpty(aRequest, value, aFieldToCheck, aDescription, aRequired))
        {
            // Do nothing
            // TODO Keep?
            aRequest.setAttribute(aFieldToCheck,value);
        }
        else if (!mAmPmPattern.matcher(value).matches())
        {
            value=null;

            ResourceBundle bundle = ResourceBundle.getBundle("Text", SessionUtils.getLocale(aRequest));
            String editMessage=aDescription + ": " + bundle.getString("amPmFieldValidCharsEdit");
            addEdit(aRequest,editMessage);
        }
        else
        {
            aRequest.setAttribute(aFieldToCheck,value);
        }

        return value;
    }

    /**
    * Get a boolean input and store into the request if there are no edits.
    *
    * @param aRequest Servlet Request to get input from
    * @param aFieldToCheck Field to check
    * @param aDescription Description of field for edit message
    * @param aRequired Indicates if required
    * @return the field if no edits
    */
    public static boolean getBooleanInput(HttpServletRequest aRequest, String aFieldToCheck, String aDescription, boolean aRequired)
    {
        boolean retValue=false;

        String value=aRequest.getParameter(aFieldToCheck);
        if (isFieldEmpty(aRequest, value, aFieldToCheck, aDescription, aRequired))
        {
            // Do nothing
        }
        else if (!mBooleanPattern.matcher(value).matches())
        {
            ResourceBundle bundle = ResourceBundle.getBundle("Text", SessionUtils.getLocale(aRequest));
            String editMessage=aDescription + ": " + bundle.getString("booleanFieldValidCharsEdit");
            addEdit(aRequest,editMessage);
        }
        else
        {
            retValue=value.equals("true");
        }

        aRequest.setAttribute(aFieldToCheck,new Boolean(retValue));

        return retValue;
    }
    
    /**
    * Get the color input and store into the request if there are no edits.
    *
    * @param aRequest Servlet Request to get input from
    * @param aFieldToCheck Field to check
    * @param aDescription Description of field for edit message
    * @param aRequired Indicates if required

    * @return the field if no edits
    */
    public static String getColorInput(HttpServletRequest aRequest, String aFieldToCheck, String aDescription, boolean aRequired)
    {
        String value=aRequest.getParameter(aFieldToCheck);
        if (isFieldEmpty(aRequest, value, aFieldToCheck, aDescription, aRequired))
        {
            // Do nothing
            // TODO Keep?
            aRequest.setAttribute(aFieldToCheck,value);
        }
        else if (!mColorPattern.matcher(value).matches())
        {
            value=null;

            ResourceBundle bundle = ResourceBundle.getBundle("Text", SessionUtils.getLocale(aRequest));
            String editMessage=aDescription + ": " + bundle.getString("colorFieldValidCharsEdit");
            addEdit(aRequest,editMessage);
        }
        else
        {
            aRequest.setAttribute(aFieldToCheck,value);
        }

        return value;
    }

    /**
    * Get the current store or null if not found.
    *
    * @param aRequest Servlet Request
    * @return the current Store
    */
    public static Store getCurrentStore(HttpServletRequest aRequest)
    {
        Store store=(Store)aRequest.getAttribute(CURRENT_STORE);
        return store;
    }

    /**
    * Get the current store name or empty String if not found.
    *
    * @param aRequest Servlet Request
    * @return the current Store name
    */
    public static String getCurrentStoreName(HttpServletRequest aRequest)
    {
        Store store=getCurrentStore(aRequest);
        if (store!=null)
        {
            return store.getName();
        }
        return "";
    }

    /**
    * Get the current user or null if not found.
    *
    * @param aRequest Servlet Request
    * @return the current user
    */
    public static User getCurrentUser(HttpServletRequest aRequest)
    {
        User user=(User)aRequest.getAttribute(CURRENT_USER);
        return user;
    }

    /**
    * Get a Date input and store into the request if there are no edits.
    *
    * @param aRequest Servlet Request to get input from
    * @param aFieldToCheck Field to check
    * @param aDescription Description of field for edit message
    * @param aRequired Indicates if required
    * @return the field if no edits
    */
    public static String getDateInput(HttpServletRequest aRequest, String aFieldToCheck, String aDescription, boolean aRequired)
    {
        String value=aRequest.getParameter(aFieldToCheck);
        if (isFieldEmpty(aRequest, value, aFieldToCheck, aDescription, aRequired))
        {
            value=null;
            aRequest.setAttribute(aFieldToCheck,value);
        }
        else if (!mDatePattern.matcher(value).matches())
        {
            value=null;

            ResourceBundle bundle = ResourceBundle.getBundle("Text", SessionUtils.getLocale(aRequest));
            String editMessage=aDescription + ": " + bundle.getString("dateFieldValidCharsEdit");
            addEdit(aRequest,editMessage);
        }
        else
        {
            value=value.trim();
            aRequest.setAttribute(aFieldToCheck,value);
        }

        return value;
    }

    /**
    * Get the edits.
    *
    * @return a list of edits
    */
    public static List<String> getEdits(HttpServletRequest aRequest)
    {
        List<String> edits=(List<String>)aRequest.getAttribute("edits");
        if (edits==null)
        {
            edits=new ArrayList<String>();
            aRequest.setAttribute(EDITS,edits);
        }

        return edits;
    }

    /**
    * Get a locale input and store into the request if there are no edits.
    *
    * @param aRequest Servlet Request to get input from
    * @param aFieldToCheck Field to check
    * @param aDescription Description of field for edit message
    * @param aRequired Indicates if required
    * @return the field if no edits
    */
    public static String getLocaleInput(HttpServletRequest aRequest, String aFieldToCheck, String aDescription, boolean aRequired)
    {
        String value=aRequest.getParameter(aFieldToCheck);
        if (isFieldEmpty(aRequest, value, aFieldToCheck, aDescription, aRequired))
        {
            value=null;
            aRequest.setAttribute(aFieldToCheck,value);
        }
        else if (!mLocalePattern.matcher(value).matches())
        {
            value=null;

            ResourceBundle bundle = ResourceBundle.getBundle("Text", SessionUtils.getLocale(aRequest));
            String editMessage=aDescription + ": " + bundle.getString("localeFieldValidCharsEdit");
            addEdit(aRequest,editMessage);
        }
        else
        {
            value=value.trim();
            aRequest.setAttribute(aFieldToCheck,value);
        }

        return value;
    }

    /**
    * Logon uri with https scheme.  TODO - Arg aRedirect is not used.  Remove it.
    *
    * @param aRequesdt request
    */
    public static String getLogonUri(HttpServletRequest aRequest, boolean aRedirect)
    {
        StringBuffer uri=new StringBuffer();

        String serverName=aRequest.getServerName();

        if (serverName.indexOf("localhost")==-1)
        {
            uri.append("https");
            uri.append("://");
            uri.append(serverName);
        }
        else
        {
            uri.append("http://localhost:8080");
        }

        String contextPath=aRequest.getContextPath();
        if (contextPath!=null && contextPath.trim().length()!=0)
        {
            uri.append("/");
            uri.append(contextPath);
        }

        if (aRedirect)
        {
            uri.append("/logonForward.jsp");
        }
        else
        {
            uri.append("/logon.jsp");
        }

        return uri.toString();
    }

    /**
    * Get a numeric input and store into the request if there are no edits.
    *
    * @param aRequest Servlet Request to get input from
    * @param aFieldToCheck Field to check
    * @param aDescription Description of field for edit message
    * @param aRequired Indicates if required
    * @return the field if no edits
    */
    public static Long getNumericInput(HttpServletRequest aRequest, String aFieldToCheck, String aDescription, boolean aRequired)
    {
        Long retValue=null;
        String value=aRequest.getParameter(aFieldToCheck);
        if (isFieldEmpty(aRequest, value, aFieldToCheck, aDescription, aRequired))
        {
            // Do nothing
        }
        else if (!mNumbersPattern.matcher(value).matches())
        {
            retValue=null;

            ResourceBundle bundle = ResourceBundle.getBundle("Text", SessionUtils.getLocale(aRequest));
            String editMessage=aDescription + ": " + bundle.getString("numberFieldValidCharsEdit");
            addEdit(aRequest,editMessage);
        }
        else
        {
            try
            {
                retValue=new Long(value);
                aRequest.setAttribute(aFieldToCheck,retValue);
            }
            catch (NumberFormatException e)
            {
                retValue=null;

                ResourceBundle bundle = ResourceBundle.getBundle("Text", SessionUtils.getLocale(aRequest));
                String editMessage=aDescription + ": " + bundle.getString("numberFieldNotValidEdit");
                addEdit(aRequest,editMessage);
            }
        }

        return retValue;
    }

    /**
    * Get numeric input from multiple values.
    *
    * TODO: Store into the request if there are no edits?
    *
    * @param aRequest Servlet Request to get input from
    * @param aFieldToCheck Field to check
    * @param aDescription Description of field for edit message
    * @param aRequired Indicates if required
    * @return a list of values
    */
    public static List<Long> getNumericInputs(HttpServletRequest aRequest, String aFieldToCheck, String aDescription, boolean aRequired)
    {
        List<Long> retValue=new ArrayList<Long>();
        String[] values=aRequest.getParameterValues(aFieldToCheck);
        if (isFieldArrayEmpty(aRequest, values, aFieldToCheck, aDescription, aRequired))
        {
            // Do nothing
        }

        if (values != null)
        {
            for (int i = 0; i < values.length; i++)
            {
                String value=(String)values[i];

                if (!mNumbersPattern.matcher(value).matches())
                {
                    ResourceBundle bundle = ResourceBundle.getBundle("Text", SessionUtils.getLocale(aRequest));
                    String editMessage=aDescription + ": " + bundle.getString("numberFieldValidCharsEdit");
                    addEdit(aRequest,editMessage);
                }
                else
                {
                    try
                    {
                        retValue.add(new Long(value));
                    }
                    catch (NumberFormatException e)
                    {
                        ResourceBundle bundle = ResourceBundle.getBundle("Text", SessionUtils.getLocale(aRequest));
                        String editMessage=aDescription + ": " + bundle.getString("numberFieldNotValidEdit");
                        addEdit(aRequest,editMessage);
                    }
                }
            }
        }

        return retValue;
    }

    /**
    * Get a numeric input and store into the request if there are no edits.
    *
    * @param aRequest Servlet Request to get input from
    * @param aFieldToCheck Field to check
    * @param aDescription Description of field for edit message
    * @param aRequired Indicates if required
    * @param aMin Min value
    * @param aMax Max value
    * @return the field if no edits
    */
    public static Long getNumericInput(HttpServletRequest aRequest, String aFieldToCheck, String aDescription, boolean aRequired, long aMin, long aMax)
    {
        Long value=getNumericInput(aRequest, aFieldToCheck, aDescription, aRequired);

        if (value!=null)
        {
            long valueLong=value.longValue();
            if (valueLong<=aMin || valueLong>= aMax)
            {
                value=null;
                aRequest.setAttribute(aFieldToCheck,value);

                ResourceBundle bundle = ResourceBundle.getBundle("Text", SessionUtils.getLocale(aRequest));
                String editMessage=aDescription + ": " + bundle.getString("numberFieldRangeEdit");
                addEdit(aRequest,editMessage + aMin + ", " + aMax);
            }
        }

        return value;
    }

    /**
    * Get the services.  If not in request, set them.
    *
    * @param aRequest Servlet Request
    */
    public static Map<Long,Service> getServices(HttpServletRequest aRequest)
    {
        // Get from request
        Map<Long,Service> services=(Map<Long,Service>)aRequest.getAttribute(SERVICES);
        if (services==null)
        {
            // Try cache.
            services=MemCacheUtils.getServices(aRequest);
            if (services!=null)
            {
                // Set into request.
                aRequest.setAttribute(SERVICES,services);
            }
            else
            {
                // Get from the datastore which sets into the request.
                // And put into the cache.
                new ServiceGetAll().execute(aRequest);
                services=(Map<Long,Service>)aRequest.getAttribute(SERVICES);
                MemCacheUtils.setServices(aRequest,services);
            }
        }

        return services;
    }
    
    /**
    * Get the staff.
    *
    * @param aRequest Servlet Request
    */
    public static Map<Long,User> getStaff(HttpServletRequest aRequest)
    {
        // Get from request
        Map<Long,User> staff=(Map<Long,User>)aRequest.getAttribute(STAFF);
        if (staff==null)
        {
            // Try cache.
            staff=MemCacheUtils.getStaff(aRequest);
            if (staff!=null)
            {
                // Set into request.
                aRequest.setAttribute(STAFF,staff);
            }
            else
            {
                Map<Long,User> users=getUsers(aRequest);
                staff=new LinkedHashMap<Long,User>();
                    
                // Create new map of staff.
                if (users!=null && !users.isEmpty())
                {
                    Iterator iter = users.entrySet().iterator();
                    while (iter.hasNext())
                    {
                        Entry entry = (Entry)iter.next();
                        User user=(User)entry.getValue();
                       
                        if (user.getIsStaff())
                        {
                            staff.put(new Long(user.getKey().getId()),user);
                        }
                    }
                }
                
                aRequest.setAttribute(STAFF,staff);
                MemCacheUtils.setStaff(aRequest,staff);
            }
        }
        
        return staff;
    }

    /**
    * Get the users.  If not in request, set them.
    *
    * @param aRequest Servlet Request
    */
    public static Map<Long,User> getUsers(HttpServletRequest aRequest)
    {
        // Get from request
        Map<Long,User> users=(Map<Long,User>)aRequest.getAttribute(USERS);
        if (users==null)
        {
            // Try cache.
            users=MemCacheUtils.getUsers(aRequest);
            if (users!=null)
            {
                // Set into request.
                aRequest.setAttribute(USERS,users);
            }
            else
            {
                // Get from the datastore which sets into the request.
                // And put into the cache.
                new UserGetAll().execute(aRequest);
                users=(Map<Long,User>)aRequest.getAttribute(USERS);
                MemCacheUtils.setUsers(aRequest,users);
            }
        }

        return users;
    }

    /**
    * Has edits.
    *
    * @param aRequest Servlet Request
    * @return a boolean indicating if there are edits
    */
    public static boolean hasEdits(HttpServletRequest aRequest)
    {
        boolean hasEdits=false;
        List<String> edits=(List<String>)aRequest.getAttribute(EDITS);
        if (edits!=null && edits.size()>0)
        {
            hasEdits=true;
        }

        return hasEdits;
    }

    /**
    * Check if the current user has access to the store. This needs to be done for every request
    * in case a user is removed from a store while the user is in session.
    *
    * @param aRequest request
    * @return a boolean indicating if the current user is in the store
    */
    public static boolean isCurrentUserInStore(HttpServletRequest aRequest)
    {
        // Set current user.
        new UserSetCurrent().execute(aRequest);

        // Check if there is a current user.
        User currentUser=getCurrentUser(aRequest);
        if (currentUser==null)
        {
            return false;
        }

        return true;
    }

    /**
    * Check if empty.  If required, create an edit.
    *
    * @param aRequest Servlet Request to get input from
    * @param aValue value to check
    * @param aDescription Description of field for edit message
    * @param aRequired Indicates if required
    * @return a boolean indicating if the field is empty
    */
    private static boolean isFieldEmpty(HttpServletRequest aRequest, String aValue, String aFieldToCheck, String aDescription, boolean aRequired)
    {
        boolean isEmpty=false;

        if (aValue==null || aValue.trim().length()==0)
        {
            isEmpty=true;

            if (aRequired)
            {
                ResourceBundle bundle = ResourceBundle.getBundle("Text", SessionUtils.getLocale(aRequest));
                String editMessage=aDescription + ": " + bundle.getString("fieldRequiredEdit");
                addEdit(aRequest,editMessage);
            }
            else
            {
                aRequest.setAttribute(aFieldToCheck,null);
                //aRequest.setAttribute(aFieldToCheck,aValue);
            }
        }

        return isEmpty;
    }

    /**
    * Check if empty.  If required, create an edit.
    *
    * @param aRequest Servlet Request to get input from
    * @param aValue value to check
    * @param aDescription Description of field for edit message
    * @param aRequired Indicates if required
    * @return a boolean indicating if the field is empty
    */
    private static boolean isFieldArrayEmpty(HttpServletRequest aRequest, String[] aValue, String aFieldToCheck, String aDescription, boolean aRequired)
    {
        boolean isEmpty=false;

        if (aValue==null || aValue.length==0)
        {
            isEmpty=true;

            if (aRequired)
            {
                ResourceBundle bundle = ResourceBundle.getBundle("Text", SessionUtils.getLocale(aRequest));
                String editMessage=aDescription + ": " + bundle.getString("fieldRequiredEdit");
                addEdit(aRequest,editMessage);
            }
            else
            {
                aRequest.setAttribute(aFieldToCheck,null);
            }
        }

        return isEmpty;
    }

    /**
    * Check if forwarded.
    *
    * @param aRequest Servlet Request
    */
    public static boolean isForwarded(HttpServletRequest aRequest)
    {
        Boolean value=(Boolean)aRequest.getAttribute(FORWARDED);

        if (value!=null && value.booleanValue())
        {
            return true;
        }
        return false;
    }

    /**
    * Remove edits.
    *
    * @param aRequest Servlet Request
    */
    public static void removeEdits(HttpServletRequest aRequest)
    {
        List<String> edits=(List<String>)aRequest.getAttribute(EDITS);
        if (edits!=null && edits.size()>0)
        {
            edits.clear();
        }
    }

    /**
    * Reset action.
    *
    * @param aRequest Servlet Request
    */
    public static void resetAction(HttpServletRequest aRequest)
    {
        aRequest.setAttribute(FORWARDED,new Boolean(true));
    }

    /**
    * Set the current store.
    *
    * @param aRequest Servlet Request
    * @param aStore a store
    */
    public static void setCurrentStore(HttpServletRequest aRequest, Store aStore)
    {
        aRequest.setAttribute(CURRENT_STORE, aStore);
    }
   
    /**
    * Set the services into request.
    *
    * @param aRequest Servlet Request
    * @param aServices
    */
    public static void setServices(HttpServletRequest aRequest, Map<Long,Service> aServices)
    {
        aRequest.setAttribute(SERVICES, aServices);
    }
    
    /**
    * Set the staff into request.
    *
    * @param aRequest Servlet Request
    * @param aStaff Staff
    */
    public static void setStaff(HttpServletRequest aRequest, Map<Long,User> aStaff)
    {
        aRequest.setAttribute(STAFF, aStaff);
    }

    /**
    * Set the users into request.
    *
    * @param aRequest Servlet Request
    * @param aUsers Users
    */
    public static void setUsers(HttpServletRequest aRequest, Map<Long,User> aUsers)
    {
        aRequest.setAttribute(USERS, aUsers);
    }

    /**
    * Get a cookie which has a numeric value.
    *
    * @param aRequest Servlet Request
    * @param aCookieName name
    * @param aDefaultValue default value
    * @return a cookie's value
    */
    public static Long getCookieValueNumeric(HttpServletRequest aRequest, String aCookieName, Long aDefaultValue)
    {
        Cookie[] cookies=aRequest.getCookies();

        for(int i=0; i<cookies.length; i++)
        {
            Cookie cookie = cookies[i];

            if (aCookieName.equals(cookie.getName()))
            {
                if (mNumbersPattern.matcher(cookie.getValue().trim()).matches())
                {
                    return(new Long(cookie.getValue()));
                }
            }
        }

        return aDefaultValue;
    }
}
