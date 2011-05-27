package sched.data;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import javax.jdo.PersistenceManager;
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
import sched.utils.ValidationUtils;

/**
 * Move a appt.
 *
 * @author Brian Spiegel
 */
public class ApptMove
{
    /**
     * Move a appt.
     *
     * @param aRequest The request
     *
     * @since 1.0
     */
    public void execute(HttpServletRequest aRequest)
    {
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
        
        Long providerId=(Long)aRequest.getAttribute("userIdMove");
        if (providerId==null)
        {
            return;
        }

        // Locale
        Locale locale=SessionUtils.getLocale(aRequest);

        // Date display
        SimpleDateFormat displayDateFormat=new SimpleDateFormat("yyyy MMM dd EEE h:mm aa", locale);
        displayDateFormat.setTimeZone(currentStore.getTimeZone());

        // Get appt
        Long apptId=(Long)aRequest.getAttribute("apptId");
        if (apptId==null)
        {
            return;
        }

        // Get user.
        User user=null;
        if (users.containsKey(providerId))
        {
            user=users.get(providerId);
        }
        // Shouldn't happen, but just in case.
        if (user==null)
        {
            RequestUtils.addEditUsingKey(aRequest,EditMessages.USER_NOT_FOUND_FOR_STORE);
            return;
        }        

        // Get date
        Long startYear=(Long)aRequest.getAttribute("startYearMove");
        Long startMonth=(Long)aRequest.getAttribute("startMonthMove");
        Long startDay=(Long)aRequest.getAttribute("startDayMove");

        if (startYear==null || startMonth==null || startDay==null)
        {
            return;
        }

        PersistenceManager pm=null;
        try
        {
            pm=PMF.get().getPersistenceManager();

            // Get appt and add to list
            Appt appt=ApptUtils.getApptFromStore(aRequest,pm,storeId,apptId.longValue());
            if (appt==null)
            {
                return;
            }

            // Check if user has access to the appt.
            if (!ValidationUtils.checkUpdateAccessToAppt(aRequest, currentUser, appt))
            {
                return;
            }
            
            // TODO - What if staff user wants services of another staff user?
            if (!currentUser.getIsAdmin())
            {
                if (currentUser.getIsStaff() && currentUser.getKey().getId()!=providerId)
                {
                    return;
                }
                if (!currentUser.getIsStaff() && (currentUser.getKey().getId()!=appt.getRecipientUserId() || !appt.getIsPending()))
                {
                    return;
                }                
            }

            // Set start
            Calendar startCalendar=DateUtils.getCalendar(aRequest);
            startCalendar.setTime(appt.getStartDate());
            startCalendar.set(Calendar.YEAR, startYear.intValue());
            startCalendar.set(Calendar.MONTH, startMonth.intValue()-1);
            startCalendar.set(Calendar.DATE, startDay.intValue());

            Date endDate=DateUtils.getEndDate(startCalendar.getTime(),appt.getDuration());

            // Get existing appts
            List existingProviderAppts=ApptUtils.getProviderAppts(aRequest,pm,storeId,providerId,startCalendar.getTime(),endDate);
            
            List existingRecipientAppts=null;
            if (appt.getRecipientUserId()!=User.NO_USER)
            {
                existingRecipientAppts=ApptUtils.getRecipientAppts(aRequest,pm,storeId,appt.getRecipientUserId(),startCalendar.getTime(),endDate);
            }

            boolean existsProvider=false;
            boolean existsRecipient=false;
            
            if (!appt.getIsPending())
            {
                existsProvider=ApptUtils.checkIfApptExists(aRequest,existingProviderAppts,startCalendar.getTime(),endDate,displayDateFormat, -1);
                
                if (existingRecipientAppts!=null)
                {
                    existsRecipient=ApptUtils.checkIfApptExists(aRequest,existingRecipientAppts,startCalendar.getTime(),endDate,displayDateFormat, appt.getKey().getId());
                }
            }
            
            if (RequestUtils.hasEdits(aRequest))
            {
                return;
            }
            
            // Update
            if (appt.getIsPending() || (!existsProvider && !existsRecipient))
            {
                appt.setProviderUserId(providerId);
                appt.setStartDate(startCalendar.getTime());
                appt.setLastUpdateUserId(currentUser.getKey().getId());
                appt.setLastUpdateTime(new Date());
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
