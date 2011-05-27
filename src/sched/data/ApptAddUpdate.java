package sched.data;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import javax.jdo.PersistenceManager;
import javax.jdo.Query;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import sched.data.model.Service;
import sched.data.model.Store;
import sched.data.model.User;
import sched.data.model.Appt;
import sched.utils.DateUtils;
import sched.utils.DisplayUtils;
import sched.utils.EditMessages;
import sched.utils.RequestUtils;
import sched.utils.SessionUtils;
import sched.utils.ValidationUtils;

/**
 * Add or edit a appt for a user.
 *
 * @author Brian Spiegel
 */
public class ApptAddUpdate
{
    /**
     * Add or edit a appt for a user.
     *
     * @param aRequest The request
     *
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

        // Get current user
        User currentUser=RequestUtils.getCurrentUser(aRequest);
        if (currentUser==null)
        {
            // Should be caught by SessionUtils.isLoggedOn, but just in case.
            RequestUtils.addEditUsingKey(aRequest,EditMessages.CURRENT_USER_NOT_FOUND);
            return;
        }

        // Locale
        Locale locale=SessionUtils.getLocale(aRequest);

        // Date display
        SimpleDateFormat displayDateFormat=new SimpleDateFormat("yyyy MMM dd EEE h:mm aa", locale);
        displayDateFormat.setTimeZone(currentStore.getTimeZone());

        // Get appt Id. If present, then editing.
        boolean isEditing=false;
        Long apptId=(Long)aRequest.getAttribute("apptId");
        if (apptId!=null)
        {
            isEditing=true;
        }

        // User Id
        long providerUserId=0;
        long recipientUserId=0;
        
        // Is pending
        boolean isPending=((Boolean)aRequest.getAttribute("isPending")).booleanValue();

        // Admin can add for all.
        if (currentUser.getIsAdmin())
        {
            providerUserId=((Long)aRequest.getAttribute("staffId")).longValue();
            recipientUserId=((Long)aRequest.getAttribute("customerId")).longValue();
        }
        // TODO - What if staff user wants services of another staff user?
        else if (currentUser.getIsStaff())
        {
            providerUserId=currentUser.getKey().getId();
            recipientUserId=((Long)aRequest.getAttribute("customerId")).longValue();
        }
        // Always pending for customers.
        else
        {
            providerUserId=((Long)aRequest.getAttribute("staffId")).longValue();
            recipientUserId=currentUser.getKey().getId();
            isPending=true;
        }

        // Service Id
        Long serviceId=(Long)aRequest.getAttribute("serviceId");
        if (serviceId==null)
        {
            RequestUtils.addEditUsingKey(aRequest,EditMessages.SERVICE_NOT_FOUND_FOR_STORE);
            return;
        }

        // Check if service exists
        if (services==null || !ServiceUtils.isValidService(services,serviceId))
        {
            RequestUtils.addEditUsingKey(aRequest,EditMessages.SERVICE_NOT_FOUND_FOR_STORE);
            return;
        }

        // Get service
        Service service=null;
        boolean noService=false;
        if (services.containsKey(serviceId))
        {
            service=(Service)services.get(serviceId);
        }
        else
        {
            noService=true;
        }            
        
        // Overrides
        boolean usesCustomDuration=((Boolean)aRequest.getAttribute("usesCustomDuration")).booleanValue();

        // Start
        Long startYear=(Long)aRequest.getAttribute("startYear");
        Long startMonth=(Long)aRequest.getAttribute("startMonth");
        Long startDay=(Long)aRequest.getAttribute("startDay");
        Long startHour=null;
        Long startMinute=null;
        String startAmPm=null;

        // Get from form
        startHour=(Long)aRequest.getAttribute("startHour");
        startMinute=(Long)aRequest.getAttribute("startMinute");
        startAmPm=(String)aRequest.getAttribute("startAmPm");

        // Duration in minutes
        int durationMin=0;
        Long durationHour=null;
        Long durationMinute=null;

        // Duration
        if (usesCustomDuration || noService)
        {
            // Get duration from form
            durationHour=(Long)aRequest.getAttribute("durationHour");
            durationMinute=(Long)aRequest.getAttribute("durationMinute");

            // Calculate
            durationMin=durationHour.intValue()*60 + durationMinute.intValue();
        }
        else
        {
            // Get duration from service
            durationMin=service.getDuration();
            if (durationMin!=0)
            {
                durationHour=new Long(durationMin/60);
                durationMinute=new Long(durationMin%60);
            }
        }

        // Check duration
        ValidationUtils.checkDuration(aRequest, durationMin);

        // Repeats
        int repetitions=1;
        int daysBetweenRepetitions=1;

        // Repeats are only for adds.
        if (!isEditing)
        {
            Long repetitionsLong=null;
            repetitionsLong=(Long)aRequest.getAttribute("apptRepetition");
            if (repetitionsLong==null)
            {
                repetitions=1;
            }
            else
            {
                repetitions=repetitionsLong.intValue();
            }

            Long daysBetweenRepetitionsLong=null;
            daysBetweenRepetitionsLong=(Long)aRequest.getAttribute("apptDaysBetweenRepetitions");
            if (daysBetweenRepetitionsLong==null)
            {
                daysBetweenRepetitions=1;
            }
            else
            {
                daysBetweenRepetitions=daysBetweenRepetitionsLong.intValue();
            }
        }

        // Start date
        Calendar startCalendar=DateUtils.getCalendar(aRequest, startYear, startMonth, startDay, startHour, startMinute, startAmPm);
        Date startDate=startCalendar.getTime();

        // End Date
        Date endDate=DateUtils.getEndDate(startDate,durationMin);

        // Note
        String note=(String)aRequest.getAttribute("note");

        PersistenceManager pm=null;
        try
        {
            pm=PMF.get().getPersistenceManager();

            // Get users.
            User providerUser=UserUtils.getUserFromStore(aRequest,pm,storeId,providerUserId);
            if (providerUser==null)
            {
                RequestUtils.addEditUsingKey(aRequest,EditMessages.USER_NOT_FOUND_FOR_STORE);
                return;
            }
            
            // Recipient can be not specified.
            User recipientUser=null;
            if (recipientUserId!=User.NO_USER)
            {
                recipientUser=UserUtils.getUserFromStore(aRequest,pm,storeId,recipientUserId);
                if (recipientUser==null)
                {
                    RequestUtils.addEditUsingKey(aRequest,EditMessages.USER_NOT_FOUND_FOR_STORE);
                    return;
                }
            }

            // If edits, return.
            if (RequestUtils.hasEdits(aRequest))
            {
                return;
            }

            // Additions
            List<Appt> additions=new ArrayList<Appt>();

            aRequest.setAttribute("appts",additions);

            // If edits, return.
            if (RequestUtils.hasEdits(aRequest))
            {
                return;
            }

            // Get existing appts
            Calendar endDateForAllRepetitions=DateUtils.getCalendar(aRequest);

            endDateForAllRepetitions.setTime(endDate);
            endDateForAllRepetitions.add(Calendar.DATE, (repetitions-1) * daysBetweenRepetitions);

            List existingApptsProvider=ApptUtils.getProviderAppts(aRequest,pm,storeId,providerUserId,startDate,endDateForAllRepetitions.getTime());
            
            List existingApptsRecipient=null;
            if (recipientUserId!=User.NO_USER)
            {
                existingApptsRecipient=ApptUtils.getRecipientAppts(aRequest,pm,storeId,recipientUserId,startDate,endDateForAllRepetitions.getTime());
            }

            // Editing
            if (isEditing)
            {
                Appt apptEditing=ApptUtils.getApptFromStore(aRequest,pm,storeId,apptId);
                if (apptEditing==null)
                {
                    RequestUtils.addEditUsingKey(aRequest,EditMessages.APPT_NOT_FOUND_FOR_STORE);
                    return;
                }

                // Check if user has access to the appt.
                ValidationUtils.checkUpdateAccessToAppt(aRequest, currentUser, apptEditing);
                if (RequestUtils.hasEdits(aRequest))
                {
                    return;
                }

                boolean existsProvider=false;
                boolean existsRecipient=false;
                
                if (!isPending)
                {
                    existsProvider=ApptUtils.checkIfApptExists(aRequest,existingApptsProvider,startDate,endDate,displayDateFormat, apptEditing.getKey().getId());
                    
                    if (existingApptsRecipient!=null)
                    {
                        existsRecipient=ApptUtils.checkIfApptExists(aRequest,existingApptsRecipient,startDate,endDate,displayDateFormat, apptEditing.getKey().getId());
                    }
                }
                
                // Update
                if (isPending || (!existsProvider && !existsRecipient))
                {
                    apptEditing.setProviderUserId(providerUserId);
                    apptEditing.setRecipientUserId(recipientUserId);
                    apptEditing.setStartDate(startDate);
                    apptEditing.setDuration(durationMin);
                    apptEditing.setServiceId(serviceId);
                    apptEditing.setIsPending(isPending);
                    apptEditing.setNote(note);
                    apptEditing.setLastUpdateUserId(currentUser.getKey().getId());
                    apptEditing.setLastUpdateTime(new Date());
                }
            }
            // Adding
            // Repeats only for adds
            else
            {
                long currentUserId=currentUser.getKey().getId();

                for(int i=0; i<repetitions; i++)
                {   
                    boolean existsProvider=false;
                    boolean existsRecipient=false;
                    
                    if (!isPending)
                    {
                        existsProvider=ApptUtils.checkIfApptExists(aRequest,existingApptsProvider,startDate,endDate,displayDateFormat, -1);
                        
                        if (existingApptsRecipient!=null)
                        {
                            existsRecipient=ApptUtils.checkIfApptExists(aRequest,existingApptsRecipient,startDate,endDate,displayDateFormat, -1);
                        }
                    }
                        
                    // Add
                    if (isPending || (!existsProvider && !existsRecipient))
                    {
                        Appt appt=new Appt();

                        appt.setStoreId(storeId);                        
                        appt.setProviderUserId(providerUserId);
                        appt.setRecipientUserId(recipientUserId);
                        appt.setStartDate(startDate);
                        appt.setDuration(durationMin);
                        appt.setServiceId(serviceId);
                        appt.setIsPending(isPending);
                        appt.setNote(note);
                        appt.setLastUpdateUserId(currentUser.getKey().getId());
                        appt.setLastUpdateTime(new Date());
                        
                        // Save
                        pm.makePersistent(appt);

                        // Display list
                        additions.add(pm.detachCopy(appt));
                    }

                    // Increment start date and end date.
                    startCalendar.add(Calendar.DATE, daysBetweenRepetitions);
                    startDate=startCalendar.getTime();

                    // End Date
                    endDate=DateUtils.getEndDate(startDate,durationMin);
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
