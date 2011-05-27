package sched.data;

import java.util.Map;
import javax.jdo.PersistenceManager;
import javax.servlet.http.HttpServletRequest;

import sched.data.model.Service;
import sched.data.model.Store;
import sched.data.model.User;
import sched.data.model.Appt;
import sched.utils.DisplayUtils;
import sched.utils.EditMessages;
import sched.utils.RequestUtils;
import sched.utils.SessionUtils;
import sched.utils.ValidationUtils;

/**
 * Delete a appt of a store.
 *
 * @author Brian Spiegel
 */
public class ApptDelete
{
    /**
     * Delete a appt.
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

        // Get current user
        User currentUser=RequestUtils.getCurrentUser(aRequest);
        if (currentUser==null)
        {
            // Should be caught by SessionUtils.isLoggedOn, but just in case.
            RequestUtils.addEditUsingKey(aRequest,EditMessages.CURRENT_USER_NOT_FOUND);
            return;
        }

        // Get appt Id.
        Long apptId=(Long)aRequest.getAttribute("apptId");

        PersistenceManager pm=null;
        try
        {
            pm=PMF.get().getPersistenceManager();

			// Get appt
			Appt appt=ApptUtils.getApptFromStore(aRequest,pm,storeId,apptId);
			if (appt==null)
			{
				RequestUtils.addEditUsingKey(aRequest,EditMessages.APPT_NOT_FOUND_FOR_STORE);
				return;
			}

			// Check if user has access to the appt.
			ValidationUtils.checkUpdateAccessToAppt(aRequest, currentUser, appt);
			if (RequestUtils.hasEdits(aRequest))
			{
				return;
			}

            // Delete appt.
            pm.deletePersistent(appt);
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
