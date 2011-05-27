package sched.data;

import java.security.Principal;
import java.util.List;

import javax.jdo.PersistenceManager;
import javax.jdo.Query;
import javax.servlet.http.HttpServletRequest;

import sched.data.model.ItemToDelete;
import sched.data.model.Store;
import sched.data.model.User;
import sched.utils.DisplayUtils;
import sched.utils.EditMessages;
import sched.utils.MemCacheUtils;
import sched.utils.RequestUtils;
import sched.utils.SessionUtils;

/**
 * Delete a store.
 *
 * Check if a user is an admin.
 *
 * @author Brian Spiegel
 */
public class StoreDelete
{
    /**
     * Delete a store.
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

            // Verify user is an admin in the store.
            if (!user.getIsAdmin())
            {
                RequestUtils.addEditUsingKey(aRequest,EditMessages.ADMIN_ACCESS_REQUIRED);
                return;
            }

            // Delete store.
            // Could use getObjectById as well.
            query = pm.newQuery(Store.class);
            query.setFilter("(key == storeIdParam)");
            query.declareParameters("long storeIdParam");
            query.deletePersistentAll(storeId);

            // Clear cache.
            MemCacheUtils.setStore(aRequest,null);

            // Mark store to be deleted (corresponding items)
            ItemToDelete itemToDelete=new ItemToDelete(ItemToDelete.STORE, storeId , -1);
            pm.makePersistent(itemToDelete);
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
