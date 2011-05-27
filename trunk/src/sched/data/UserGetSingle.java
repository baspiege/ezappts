package sched.data;

import java.util.ArrayList;
import java.util.List;
import javax.jdo.PersistenceManager;
import javax.jdo.Query;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import sched.data.model.Store;
import sched.data.model.User;
import sched.utils.EditMessages;
import sched.utils.RequestUtils;
import sched.utils.SessionUtils;

/**
 * Get a user for a store.
 *
 * @author Brian Spiegel
 */
public class UserGetSingle
{
    /**
     * Get a user.
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

            aRequest.setAttribute("user", pm.detachCopy(user));
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
