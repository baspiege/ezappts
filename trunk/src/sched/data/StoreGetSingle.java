package sched.data;

import java.security.Principal;
import java.util.List;
import javax.jdo.JDOObjectNotFoundException;
import javax.jdo.PersistenceManager;
import javax.jdo.Query;
import javax.servlet.http.HttpServletRequest;

import sched.data.model.Store;
import sched.data.model.User;
import sched.utils.EditMessages;
import sched.utils.RequestUtils;

/**
 * Get a store.
 *
 * @author Brian Spiegel
 */
public class StoreGetSingle
{
    /**
     * Get a store.
     *
     * @param aRequest The request
     *
     * @since 1.0
     */
    public void execute(HttpServletRequest aRequest)
    {
        // Get user name.
        Principal principal=aRequest.getUserPrincipal();
        if (principal==null)
        {
            RequestUtils.addEditUsingKey(aRequest,EditMessages.CURRENT_USER_NAME_NOT_FOUND);
            return;
        }

        String userName=principal.getName();
        if (userName==null || userName.trim().length()==0)
        {
            RequestUtils.addEditUsingKey(aRequest,EditMessages.CURRENT_USER_NAME_NOT_FOUND);
            return;
        }

        // Get store Id
        long storeId=((Long)aRequest.getAttribute("storeId")).longValue();

        PersistenceManager pm=null;
        Query query=null;
        try
        {
            pm=PMF.get().getPersistenceManager();

            // Check if the current user is in the store selected
            User user=UserUtils.getUserFromStoreByUserName(aRequest,pm,storeId,userName);
            if (user==null)
            {
                RequestUtils.addEditUsingKey(aRequest,EditMessages.USER_NOT_FOUND_FOR_STORE);
                return;
            }

            // Get store
            Store store=null;
            try
            {
                store=(Store)pm.getObjectById(Store.class,storeId);
                if (store!=null)
                {
                    // Set into request
                    aRequest.setAttribute("store", pm.detachCopy(store));
                }
            }
            catch (JDOObjectNotFoundException jnfe)
            {
                // Do nothing.  Edit will be made in finally below
            }
            finally
            {
                if (store==null)
                {
                    RequestUtils.addEditUsingKey(aRequest,EditMessages.STORE_NOT_FOUND);
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
