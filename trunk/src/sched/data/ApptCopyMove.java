package sched.data;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Collections;
import java.util.ArrayList;
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
 * Copy and move a list of appts.
 *
 * @author Brian Spiegel
 */
public class ApptCopyMove
{
    /**
     * Copy and move a list of appts.
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

        // Locale
        Locale locale=SessionUtils.getLocale(aRequest);

        // Date display
        SimpleDateFormat displayDateFormat=new SimpleDateFormat("yyyy MMM dd EEE h:mm aa", locale);
        displayDateFormat.setTimeZone(currentStore.getTimeZone());

        // Get appt
        List<Long> apptIds=(List<Long>)aRequest.getAttribute("s");

        // Days to move
        int daysToMove=1;
        Long daysToMoveLong=null;
        daysToMoveLong=(Long)aRequest.getAttribute("daysToMove");
        if (daysToMoveLong==null)
        {
            daysToMove=1;
        }
        else
        {
            daysToMove=daysToMoveLong.intValue();
        }

        PersistenceManager pm=null;
        try
        {
            pm=PMF.get().getPersistenceManager();

            List<Appt> appts=new ArrayList<Appt>();

            for (Long apptId: apptIds)
            {
                // Get appt and add to list
                Appt appt=ApptUtils.getApptFromStore(aRequest,pm,storeId,apptId.longValue());

                if (appt!=null)
                {
                    appts.add(appt);
                }
            }

            // Order by start time descending
            Collections.sort(appts,new ApptSortByStartDate());

            for (Appt appt: appts)
            {
                // Check if user has access to the appt.
                if (!ValidationUtils.checkUpdateAccessToAppt(aRequest, currentUser, appt))
                {
                    // Try next appt.
                    continue;
                }

                // Set start
                Calendar startCalendar=DateUtils.getCalendar(aRequest);
                startCalendar.setTime(appt.getStartDate());
                startCalendar.add(Calendar.DATE, daysToMove);

                Date endDate=DateUtils.getEndDate(startCalendar.getTime(),appt.getDuration());

                // Get existing appts
                List existingApptsProvider=ApptUtils.getProviderAppts(aRequest,pm,storeId,appt.getProviderUserId(),startCalendar.getTime(),endDate);
                
                List existingApptsRecipient=null;
                if (appt.getRecipientUserId()!=User.NO_USER)
                {
                    existingApptsRecipient=ApptUtils.getRecipientAppts(aRequest,pm,storeId,appt.getRecipientUserId(),startCalendar.getTime(),endDate);
                }
                
                boolean existsProvider=false;
                boolean existsRecipient=false;
                
                if (!appt.getIsPending())
                {
                    existsProvider=ApptUtils.checkIfApptExists(aRequest,existingApptsProvider,startCalendar.getTime(),endDate,displayDateFormat, -1);
                    
                    if (existingApptsRecipient!=null)
                    {
                        existsRecipient=ApptUtils.checkIfApptExists(aRequest,existingApptsRecipient,startCalendar.getTime(),endDate,displayDateFormat, -1);
                    }
                }
                
                // Add
                if (appt.getIsPending() || (!existsProvider && !existsRecipient))
                {
                    // Create new appt
                    Appt newAppt=new Appt();
                    
                    newAppt.setStoreId(storeId);
                    newAppt.setProviderUserId(appt.getProviderUserId());
                    newAppt.setRecipientUserId(appt.getRecipientUserId());
                    newAppt.setStartDate(startCalendar.getTime());
                    newAppt.setDuration(appt.getDuration());
                    newAppt.setServiceId(appt.getServiceId());
                    newAppt.setIsPending(appt.getIsPending());
                    newAppt.setNote(appt.getNote());                    
                    newAppt.setLastUpdateUserId(currentUser.getKey().getId());
                    newAppt.setLastUpdateTime(new Date());
                    
                    // Save
                    pm.makePersistent(newAppt);
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
