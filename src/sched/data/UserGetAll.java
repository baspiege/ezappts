package sched.data;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
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
 * Get all users for a store.
 *
 * @author Brian Spiegel
 */
public class UserGetAll
{
    /**
     * Get all users.
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

        PersistenceManager pm=null;
        try
        {
            pm=PMF.get().getPersistenceManager();

            Query query=null;
            try
            {
                // Get all users
                query = pm.newQuery(User.class);
                query.setFilter("storeId == storeIdParam");
                query.declareParameters("long storeIdParam");
                query.setOrdering("lastNameLowerCase ASC, firstNameLowerCase ASC");

                List<User> results = (List<User>) query.execute(storeId);

                Map userMap=new LinkedHashMap();
                for (User user : results)
                {
                    userMap.put(new Long(user.getKey().getId()),pm.detachCopy(user));
                }
                aRequest.setAttribute(RequestUtils.USERS, userMap);
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
