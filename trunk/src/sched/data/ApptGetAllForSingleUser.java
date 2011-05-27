package sched.data;

import java.util.ArrayList;
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
import sched.utils.EditMessages;
import sched.utils.RequestUtils;
import sched.utils.SessionUtils;

/**
 * Get appts for a single user.
 * 
 * TODO - Not working yet.  Need to update.
 *
 * @author Brian Spiegel
 */
public class ApptGetAllForSingleUser
{
    /**
     * Get appts.
     *
     * @param aRequest The request
     *
     * @since 1.0
     */
    public void execute(HttpServletRequest aRequest)
    {    
        Map<Long,Service> services=RequestUtils.getServices(aRequest);
    
        // Get store Id
        Store currentStore=RequestUtils.getCurrentStore(aRequest);
        if (currentStore==null)
        {
            RequestUtils.addEditUsingKey(aRequest,EditMessages.CURRENT_STORE_NOT_SET);
            return;
        }
        long storeId=currentStore.getKey().getId();

        // Get user Id
        long userId=((Long)aRequest.getAttribute("userId")).longValue();

        PersistenceManager pm=null;
        try
        {
            pm=PMF.get().getPersistenceManager();

            // Get user.
            User user=UserUtils.getUserFromStore(aRequest,pm,storeId,userId);
            if (user==null)
            {
                RequestUtils.addEditUsingKey(aRequest,EditMessages.USER_NOT_FOUND_FOR_STORE);
                return;
            }

            // Get appts
            Query query=null;
            try
            {
                // Get appts.
                query = pm.newQuery(Appt.class);
                
                // TODO - Get for recipient Id?
                query.setFilter("(storeId == storeIdParam) && (providerUserId == userIdParam)");
                query.declareParameters("long storeIdParam, long userIdParam");
                query.setOrdering("startDate ASC");

                List<Appt> results = (List<Appt>) query.execute(storeId, userId);

                // Transfer collection to new list
                List<Appt> copyAppts=new ArrayList<Appt>();
                for (Appt Appt: results)
                {
                    long ServiceId=Appt.getServiceId();

                    // Check that service exists
                    if (ServiceUtils.isValidService(services,Appt.getServiceId()))
                    {
                        copyAppts.add(pm.detachCopy(Appt));
                    }
                }

                // Set into request
                aRequest.setAttribute("appts", copyAppts);
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
