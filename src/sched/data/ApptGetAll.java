package sched.data;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.ResourceBundle;
import javax.jdo.PersistenceManager;
import javax.jdo.Query;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import sched.data.model.Service;
import sched.data.model.Store;
import sched.data.model.User;
import sched.data.model.Appt;
import sched.utils.DateUtils;
import sched.utils.EditMessages;
import sched.utils.RequestUtils;
import sched.utils.SessionUtils;

/**
 * Get appts from a starting date for a given duration.
 *
 * From the given date, go back 1 day and forward the days in the display.
 *
 * @author Brian Spiegel
 */
public class ApptGetAll
{
    private static final String AND="&&";
    //private static final String SERVICE_FILTER="(serviceId==serviceIdParam)";
    private static final String STARTDATE_FILTER="(startDate > startDateParam) && (startDate < endDateParam)";
    private static final String STORE_FILTER="(storeId == storeIdParam)";
    //private static final String USER_FILTER="(userId==userIdParam)";

    /**
     * Get appts.
     *
     * @param aRequest The request
     * @since 1.0
     */
    public void execute(HttpServletRequest aRequest)
    {
        Map<Long,Service> services=RequestUtils.getServices(aRequest);
        Map<Long,User> users=RequestUtils.getUsers(aRequest);    
    
        // Get store Id
        Store currentStore=RequestUtils.getCurrentStore(aRequest);
        if (currentStore==null)
        {
            RequestUtils.addEditUsingKey(aRequest,EditMessages.CURRENT_STORE_NOT_SET);
            return;
        }
        long storeId=currentStore.getKey().getId();

        // Get date.
        Calendar startCalendar=null;

        // If no year, use current date.
        Long startYear=(Long)aRequest.getAttribute("startYear");
        if (startYear==null)
        {
            startCalendar=DateUtils.getCalendar(aRequest);

            // Set time to start of day.
            startCalendar.set(Calendar.HOUR_OF_DAY, 0);
            startCalendar.set(Calendar.MINUTE, 0);
            startCalendar.set(Calendar.SECOND, 0);
        }
        else
        {
            Long startMonth=(Long)aRequest.getAttribute("startMonth");
            Long startDay=(Long)aRequest.getAttribute("startDay");
            startCalendar=DateUtils.getCalendar(aRequest, startYear, startMonth, startDay, new Long(0), new Long(0), DateUtils.AM);
        }

        // Get days in display
        Long displayDays=(Long)aRequest.getAttribute("displayDays");
        if (displayDays==null)
        {
            displayDays=new Long(7);
        }

        // Check next or previous
        String action=(String)aRequest.getAttribute("action");
        if (action!=null)
        {
            ResourceBundle bundle = ResourceBundle.getBundle("Text", SessionUtils.getLocale(aRequest));

            if (action.equals(bundle.getString("viewPreviousPeriodButton")))
            {
                startCalendar.add(Calendar.DATE, -1*displayDays.intValue());
            }
            else if (action.equals(bundle.getString("viewNextPeriodButton")))
            {
                startCalendar.add(Calendar.DATE, displayDays.intValue());
            }

            // Update request
            startYear = new Long( new Integer(startCalendar.get(Calendar.YEAR)) ).longValue();
            Long startMonth = new Long( new Integer(startCalendar.get(Calendar.MONTH)+1) ).longValue();
            Long startDay = new Long( new Integer(startCalendar.get(Calendar.DATE)) ).longValue();

            aRequest.setAttribute("startYear", startYear);
            aRequest.setAttribute("startMonth", startMonth);
            aRequest.setAttribute("startDay", startDay);
        }

        // Set in request
        aRequest.setAttribute("startDate",startCalendar.getTime());

        // Go back 1 day as appts can only be 1 day long
        startCalendar.add(Calendar.DATE, -1);
        Date startDate=startCalendar.getTime();

        // Go forward 1 + days in display
        startCalendar.add(Calendar.DATE, 1 + displayDays.intValue());
        Date endDate=startCalendar.getTime();

        // User Id
        /*
        Long userId=(Long)aRequest.getAttribute("userId");
        boolean allUsers=false;
        if (userId==null || userId.longValue()==User.ALL_USERS)
        {
            allUsers=true;
        }
        */
        
        // Check if user exists
        // Using the map users because it's already present.
        // Otherwise, UserUtils.getUserFromStore could be used.
        /*
        else if (users==null || !users.containsKey(userId))
        {
            RequestUtils.addEditUsingKey(aRequest,EditMessages.USER_NOT_FOUND_FOR_STORE);
            return;
        }
        */
        
        // Service Id
        /*
        boolean allAppts=false;
        Long serviceId=(Long)aRequest.getAttribute("serviceId");
        if (serviceId==null || serviceId.longValue()==Service.ALL_SERVICES)
        {
            allAppts=true;
        }
        // Check if service exists
        else if (services==null || !ServiceUtils.isValidService(services,serviceId))
        {
            RequestUtils.addEditUsingKey(aRequest,EditMessages.SERVICE_NOT_FOUND_FOR_STORE);
            return;
        }
        */

        PersistenceManager pm=null;
        try
        {
            pm=PMF.get().getPersistenceManager();

            // Get appts
            Query query=null;
            try
            {
                // Get appts.
                query = pm.newQuery(Appt.class);
                query.setOrdering("startDate ASC");
                List<Appt> results = null;

                query.setFilter(STORE_FILTER + AND + STARTDATE_FILTER);
                query.declareParameters("long storeIdParam, java.util.Date startDateParam, java.util.Date endDateParam");
                Object[] parameters = { storeId, startDate, endDate };
                results = (List<Appt>) query.executeWithArray(parameters);

                // Transfer collection LinkedHashMap
                Map appts=new LinkedHashMap();

                if (results!=null)
                {
                    // Keyed by User with value being appts in a list.
                    for (Appt appt: results)
                    {
                        if (ServiceUtils.isValidService(services,appt.getServiceId())
                        && UserUtils.isValidUser(users,appt.getProviderUserId())
                        && (UserUtils.isValidUser(users,appt.getRecipientUserId()) || appt.getRecipientUserId()==User.NO_USER))
                        {
                            List<Appt> apptsList=null;

                            Long appt_userId=new Long(appt.getProviderUserId());

                            if (appts.containsKey(appt_userId))
                            {
                                apptsList = (List<Appt>)appts.get(appt_userId);
                            }
                            else
                            {
                                apptsList = new ArrayList<Appt>();
                                appts.put(appt_userId, apptsList);
                            }

                            apptsList.add(pm.detachCopy(appt));
                        }
                    }
                }

                // Set into request
                aRequest.setAttribute("appts", appts);
            }
            finally
            {
                if (query!=null)
                {
                    query.closeAll();
                }
            }
        }
        catch (Exception e)
        {
            System.err.println(this.getClass().getName() + ": " + e);
            e.printStackTrace();
            RequestUtils.addEditUsingKey(aRequest,EditMessages.ERROR_PROCESSING_REQUEST);
        }
        finally
        {
            if (pm!=null)
            {
                pm.close();
            }
        }
    }
}
