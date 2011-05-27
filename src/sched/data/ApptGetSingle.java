package sched.data;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
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
import sched.utils.EditMessages;
import sched.utils.RequestUtils;
import sched.utils.SessionUtils;

/**
 * Get a single appt.
 *
 * @author Brian Spiegel
 */
public class ApptGetSingle
{
    /**
     * Get a single appt.
     *
     * @param aRequest The request
     *
     * @since 1.0
     */
    public void execute(HttpServletRequest aRequest)
    {
        // Get store Id
        Store currentStore=RequestUtils.getCurrentStore(aRequest);
        if (currentStore==null)
        {
            RequestUtils.addEditUsingKey(aRequest,EditMessages.CURRENT_STORE_NOT_SET);
            return;
        }
        long storeId=currentStore.getKey().getId();

        // Use appt Id
        long apptId=((Long)aRequest.getAttribute("apptId")).longValue();

        PersistenceManager pm=null;
        try
        {
            pm=PMF.get().getPersistenceManager();

            Appt appt=ApptUtils.getApptFromStore(aRequest,pm,storeId,apptId);
            if (appt==null)
            {
                RequestUtils.addEditUsingKey(aRequest,EditMessages.APPT_NOT_FOUND_FOR_STORE);
                return;
            }

			// For now, pass user back in "apptUtils_user" entry.
			User user=(User)aRequest.getAttribute("apptUtils_user");
			if (user!=null)
			{
			     aRequest.setAttribute("user", pm.detachCopy(user));
			}
			// Shouldn't happen, but just in case.
			else
			{
				appt=null;
			}

            aRequest.setAttribute("appt", pm.detachCopy(appt));
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
