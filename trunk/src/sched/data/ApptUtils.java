package sched.data;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.ResourceBundle;

import javax.jdo.PersistenceManager;
import javax.jdo.Query;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import sched.data.model.Appt;
import sched.data.model.Service;
import sched.data.model.Store;
import sched.data.model.User;
import sched.utils.DateUtils;
import sched.utils.DisplayUtils;
import sched.utils.EditMessages;
import sched.utils.RequestUtils;
import sched.utils.SessionUtils;

/**
 * Appt utils.
 *
 * @author Brian Spiegel
 */
public class ApptUtils
{

    /**
     * Check if appt already exists.
     *
     * @param aRequest The request
     * @param aAppts existing appts
     * @param aStartDate start date
     * @param aEndDate end date
     * @param aDisplayDateFormat date format
     * @param aApptIdToSkip optional Id to skip.  If none, use -1.	 
     * @return a boolean indicating if an appt already exists during the given start and end date
     *
     * @since 1.0
     */
    public static boolean checkIfApptExists(HttpServletRequest aRequest, List<Appt> aAppts, Date aStartDate, Date aEndDate, SimpleDateFormat aDisplayDateFormat, long aApptIdToSkip)
    {
        boolean exists=false;
        
        // Services
        Map<Long,Service> services=RequestUtils.getServices(aRequest);
        Map<Long,User> users=RequestUtils.getUsers(aRequest);

        for (Appt appt : aAppts)
        {
            // Existing end date
            Date existingStartDate=appt.getStartDate();
            Date existingEndDate=DateUtils.getEndDate(appt.getStartDate(),appt.getDuration());

            /*
                1.) Verify appt is not pending.
                2.) Verify appt Id is being skipped or not.
                3.) If an existing start time is greater or equal than the proposed start time and
                    that existing start time is less than the proposed end time.
                4.) If an existing start time is less than a proposed start time and the
                    corresponding existing end time is greater than the proposed start time.    
            */
            if (!appt.getIsPending() &&
                aApptIdToSkip!=appt.getKey().getId() &&
                // ServiceUtils.isValidService(services,appt.getServiceId()) &&
                ( (existingStartDate.compareTo(aStartDate)>=0 && existingStartDate.compareTo(aEndDate)<0)
                || (existingStartDate.compareTo(aStartDate)<0 && existingEndDate.compareTo(aStartDate)>0)))
            {
                exists=true;
                
                ResourceBundle bundle = ResourceBundle.getBundle("Text", SessionUtils.getLocale(aRequest));
                
                // Get provider.
                User providerUser=null;
                if (UserUtils.isValidUser(users,appt.getProviderUserId()))
                {
                    providerUser=UserUtils.getUser(users,appt.getProviderUserId());
                }
                else
                {
                    RequestUtils.addEditUsingKey(aRequest,EditMessages.USER_NOT_FOUND_FOR_STORE);
                }
                
                // Get recipient.
                User recipientUser=null;
                if (appt.getRecipientUserId()!=User.NO_USER)
                {
                    if (UserUtils.isValidUser(users,appt.getRecipientUserId()))
                    {
                        recipientUser=UserUtils.getUser(users,appt.getRecipientUserId());
                    }
                    else
                    {
                        RequestUtils.addEditUsingKey(aRequest,EditMessages.USER_NOT_FOUND_FOR_STORE);
                    }
                }
                
                // Display name
                String displayNameProvider=DisplayUtils.formatName(providerUser.getFirstName(),providerUser.getLastName(),false);

                String displayNameRecipient=null;
                if (appt.getRecipientUserId()!=User.NO_USER)
                {
                    displayNameRecipient=DisplayUtils.formatName(recipientUser.getFirstName(),recipientUser.getLastName(),false);
                }
                else
                {
                    displayNameRecipient=bundle.getString("noSpecificCustomerLabel");
                }                

                String editMessage=bundle.getString("apptExistsEdit") + displayNameProvider + ", " + displayNameRecipient + ", " + aDisplayDateFormat.format(appt.getStartDate()) + " - " + aDisplayDateFormat.format(existingEndDate);
                RequestUtils.addEdit(aRequest,editMessage);                                
            }
        }

        return exists;
    }

    /**
     * Get existing appts for a provider.
     *
     * @param aRequest The request
     * @param aPm PersistenceManager
     * @param aStoreId store Id
     * @param aUserId user Id
     * @param aStartDate start date
     * @param aEndDate end date
     * @return a list of Appts
     * @since 1.0
     */
    public static List<Appt> getProviderAppts(HttpServletRequest aRequest, PersistenceManager aPm, long aStoreId, long aUserId, Date aStartDate, Date aEndDate)
    {
        List<Appt> results=new ArrayList<Appt>();

        Map<Long,Service> services=RequestUtils.getServices(aRequest);
        Map<Long,User> users=RequestUtils.getUsers(aRequest);    
        
        Query query=null;
        try
        {
            // Get all appts for this user
            query = aPm.newQuery(Appt.class); 
            query.setFilter("(storeId == storeIdParam) && (providerUserId == userIdParam) && (startDate > startDateParam) && (startDate < endDateParam)"); 
            query.declareParameters("long storeIdParam, long userIdParam, java.util.Date startDateParam, java.util.Date endDateParam");

            Calendar startCalendar=DateUtils.getCalendar(aRequest);
            startCalendar.setTime(aStartDate);
            startCalendar.add(Calendar.HOUR_OF_DAY, -24);
            Date startDate=startCalendar.getTime();

            Object[] inputs={aStoreId, aUserId, startDate, aEndDate};
            List<Appt> queryResults = (List<Appt>) query.executeWithArray(inputs); 
            
            for (Appt appt : queryResults)
            {   
                if (ServiceUtils.isValidService(services,appt.getServiceId())
                && UserUtils.isValidUser(users,appt.getProviderUserId())
                && (UserUtils.isValidUser(users,appt.getRecipientUserId()) || appt.getRecipientUserId()==User.NO_USER))
                {
                    results.add(appt);
                }
            }
        }
        catch (Exception e)
        {
            System.err.println(ApptUtils.class.getName() + ": " + e);
            e.printStackTrace();
            RequestUtils.addEditUsingKey(aRequest,EditMessages.ERROR_PROCESSING_REQUEST);
        }
        finally
        {
            if (query!=null)
            {   
                query.closeAll(); 
            }
        }

        return results;
    }
    
    /**
     * Get existing appts for a recipient.
     *
     * @param aRequest The request
     * @param aPm PersistenceManager
     * @param aStoreId store Id
     * @param aUserId user Id
     * @param aStartDate start date
     * @param aEndDate end date
     * @return a list of Appts
     * @since 1.0
     */
    public static List<Appt> getRecipientAppts(HttpServletRequest aRequest, PersistenceManager aPm, long aStoreId, long aUserId, Date aStartDate, Date aEndDate)
    {
        List<Appt> results=new ArrayList<Appt>();
        
        Map<Long,Service> services=RequestUtils.getServices(aRequest);
        Map<Long,User> users=RequestUtils.getUsers(aRequest);    

        Query query=null;
        try
        {
            // Get all appts for this user
            query = aPm.newQuery(Appt.class); 
            query.setFilter("(storeId == storeIdParam) && (recipientUserId == userIdParam) && (startDate > startDateParam) && (startDate < endDateParam)"); 
            query.declareParameters("long storeIdParam, long userIdParam, java.util.Date startDateParam, java.util.Date endDateParam");

            Calendar startCalendar=DateUtils.getCalendar(aRequest);
            startCalendar.setTime(aStartDate);
            startCalendar.add(Calendar.HOUR_OF_DAY, -24);
            Date startDate=startCalendar.getTime();

            Object[] inputs={aStoreId, aUserId, startDate, aEndDate};
            List<Appt> queryResults = (List<Appt>) query.executeWithArray(inputs);

            for (Appt appt : queryResults)
            {   
                if (ServiceUtils.isValidService(services,appt.getServiceId())
                && UserUtils.isValidUser(users,appt.getProviderUserId())
                && (UserUtils.isValidUser(users,appt.getRecipientUserId()) || appt.getRecipientUserId()==User.NO_USER))
                {
                    results.add(appt);
                }
            }
        }
        catch (Exception e)
        {
            System.err.println(ApptUtils.class.getName() + ": " + e);
            e.printStackTrace();
            RequestUtils.addEditUsingKey(aRequest,EditMessages.ERROR_PROCESSING_REQUEST);
        }
        finally
        {
            if (query!=null)
            {   
                query.closeAll(); 
            }
        }

        return results;
    }
    
    /**
     * Get the appt for a store.
     *
     * @param aRequest The request
     * @param aPm PersistenceManager
     * @param aStoreId store Id
     * @param aApptId appt Id
     * @return a appt or null if not found
     *
     * @since 1.0
     */
    public static Appt getApptFromStore(HttpServletRequest aRequest, PersistenceManager aPm, long aStoreId, long aApptId)
    {
        Map<Long,User> users=RequestUtils.getUsers(aRequest);
        Map<Long,Service> services=RequestUtils.getServices(aRequest);
    
        Appt appt=null;

        Query query=null;
        try
        {
            // Get appts.
            query = aPm.newQuery(Appt.class); 
            query.setFilter("(storeId == storeIdParam) && (key == apptIdParam)"); 
            query.declareParameters("long storeIdParam, long apptIdParam");
            query.setRange(0,1);

            List<Appt> results = (List<Appt>) query.execute(aStoreId, aApptId); 

            if (!results.isEmpty())
            {
                Appt currAppt=(Appt)results.get(0);

                long serviceId=currAppt.getServiceId();

                // Check that user exists.
                if (UserUtils.isValidUser(users,currAppt.getProviderUserId())
                && (UserUtils.isValidUser(users,currAppt.getRecipientUserId()) || currAppt.getRecipientUserId()==User.NO_USER))
                {      
                    User user=users.get(new Long(currAppt.getProviderUserId()));
                
                    // Check that service exists
                    if (ServiceUtils.isValidService(services, serviceId))                
                    {
                        aRequest.setAttribute("apptUtils_user", user);
                        appt=currAppt;
                    }
                }
            }
        }
        finally
        {
            if (query!=null)
            {   
                query.closeAll(); 
            }
        }

        return appt;
    } 
}
