package sched.data;

import java.security.Principal;
import java.util.ArrayList;
import java.util.List;
import javax.jdo.PersistenceManager;
import javax.jdo.Query;
import javax.servlet.http.HttpServletRequest;

import sched.data.model.Store;
import sched.data.model.User;
import sched.utils.EditMessages;
import sched.utils.RequestUtils;
import sched.utils.SessionUtils;

/**
 * Set the current user.
 *
 * @author Brian Spiegel
 */
public class UserSetCurrent
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
        // Reset current user
        // Probably isn't set, but just in case.
        aRequest.setAttribute(RequestUtils.CURRENT_USER,null);

        PersistenceManager pm=null;
        try
        {
            pm=PMF.get().getPersistenceManager();

            // Get store Id
            Store currentStore=RequestUtils.getCurrentStore(aRequest);
            if (currentStore==null)
            {
                RequestUtils.addEditUsingKey(aRequest,EditMessages.CURRENT_STORE_NOT_SET);
                return;
            }
            long storeId=currentStore.getKey().getId();

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
                List<User> users=new ArrayList<User>();

                // 1.) Get all entries for this user
                query = pm.newQuery(User.class);
                query.setFilter("(storeId == storeIdParam) && (emailAddressLowerCase == userNameParamLowerCase)");
                query.declareParameters("long storeIdParam,String userNameParamLowerCase");
                query.setRange(0,1);
                List<User> results = (List<User>) query.execute(storeId,userName.toLowerCase());

                // 2.) Set entry
                // TODO: Check if more than 1?  Then there is an error.
                if (results.size()==1)
                {
                    User user=(User)results.get(0);

                    // Set into request
                    aRequest.setAttribute(RequestUtils.CURRENT_USER, pm.detachCopy(user));
                }
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
