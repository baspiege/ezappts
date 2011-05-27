package sched.data;

import java.security.Principal;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.jdo.JDOObjectNotFoundException;
import javax.jdo.PersistenceManager;
import javax.jdo.Query;
import javax.servlet.http.HttpServletRequest;

import sched.data.model.Store;
import sched.data.model.User;
import sched.utils.EditMessages;
import sched.utils.RequestUtils;

/**
 * Get all stores.
 *
 * @author Brian Spiegel
 */
public class StoreGetAll
{
    /**
     * Get all stores.
     *
     * @param aRequest The request
     *
     * @since 1.0
     */
    public void execute(HttpServletRequest aRequest)
    {
        PersistenceManager pm=null;
        try
        {
            pm=PMF.get().getPersistenceManager();

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

            Query query=null;
            try
            {
                List<Store> stores=new ArrayList<Store>();
                Map<Long,User> currentUserInStores=new HashMap<Long,User>();

                // 1.) Get all store Ids for this user
                query = pm.newQuery(User.class);
                query.setFilter("emailAddressLowerCase == userNameParamLowerCase");
                query.declareParameters("String userNameParamLowerCase");
                List<User> results = (List<User>) query.execute(userName.toLowerCase());

                // 2.) Get the store from the store Id
                for (User user : results)
                {
                    // Get store
                    try
                    {
                        Store store=(Store)pm.getObjectById(Store.class,user.getStoreId());
                        if (store!=null)
                        {
							// Set last accessed time to current time
							store.setLastTimeAccessed(new Date());
                            stores.add(pm.detachCopy(store));
                            currentUserInStores.put(new Long(store.getKey().getId()),pm.detachCopy(user));
                        }
                    }
                    catch (JDOObjectNotFoundException jnfe)
                    {
                        // Do nothing, but this means that a store was deleted but the user table
                        // wasn't updated.  This will happen because deleting won't update the user
                        // table.  The store will just be removed.
                        ;
                    }
                }

                Collections.sort(stores);

                // Set into request
                aRequest.setAttribute("stores", stores);
                aRequest.setAttribute("currentUserInStores", currentUserInStores);
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
