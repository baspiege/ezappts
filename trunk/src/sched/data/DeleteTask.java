package sched.data;

import java.util.List;

import javax.jdo.PersistenceManager;
import javax.jdo.Query;
import javax.servlet.http.HttpServletRequest;

import sched.data.model.Appt;
import sched.data.model.ItemToDelete;
import sched.data.model.Service;
import sched.data.model.Store;
import sched.data.model.User;
import sched.utils.EditMessages;
import sched.utils.RequestUtils;

/**
 * Delete task.
 *
 * @author Brian Spiegel
 */
public class DeleteTask
{
    /**
     * Delete task.
     *
     * @param aRequest The request
     *
     * @since 1.0
     */
    public void execute(HttpServletRequest aRequest)
    {
        PersistenceManager pm=null;
        Query query=null;
        try
        {
            pm=PMF.get().getPersistenceManager();

            query = pm.newQuery(ItemToDelete.class);

            // Delete by type
            List<ItemToDelete> results = (List<ItemToDelete>) query.execute();
            for (ItemToDelete itemToDelete : results)
            {
                int type=itemToDelete.getTypeToDelete();
                long storeId=itemToDelete.getStoreId();

                if (type==ItemToDelete.STORE)
                {
                    // Services
                    query = pm.newQuery(Service.class);
                    query.setFilter("(storeId == storeIdParam)");
                    query.declareParameters("long storeIdParam");
                    query.deletePersistentAll(storeId);

                    // Users
                    query = pm.newQuery(User.class);
                    query.setFilter("(storeId == storeIdParam)");
                    query.declareParameters("long storeIdParam");
                    query.deletePersistentAll(storeId);

                    // Appt
                    query = pm.newQuery(Appt.class);
                    query.setFilter("(storeId == storeIdParam)");
                    query.declareParameters("long storeIdParam");
                    query.deletePersistentAll(storeId);

                    // Store - Should be deleted but just in case.
                    query = pm.newQuery(Store.class);
                    query.setFilter("(key == storeIdParam)");
                    query.declareParameters("long storeIdParam");
                    query.deletePersistentAll(storeId);
                }
                else if (type==ItemToDelete.SERVICE)
                {
                    // Appts of this service
                    query = pm.newQuery(Appt.class);
                    query.setFilter("(storeId == storeIdParam) && (serviceId == serviceIdParam)");
                    query.declareParameters("long storeIdParam, long serviceIdParam");
                    query.deletePersistentAll(storeId, itemToDelete.getIdToDelete());
                }
                else if (type==ItemToDelete.USER)
                {
                    // Appts of this user
                    query = pm.newQuery(Appt.class);
                    query.setFilter("(storeId == storeIdParam) && (providerUserId == userIdParam)");
                    query.declareParameters("long storeIdParam, long userIdParam");
                    query.deletePersistentAll(storeId, itemToDelete.getIdToDelete());
                    
                    query = pm.newQuery(Appt.class);
                    query.setFilter("(storeId == storeIdParam) && (recipientUserId == userIdParam)");
                    query.declareParameters("long storeIdParam, long userIdParam");
                    query.deletePersistentAll(storeId, itemToDelete.getIdToDelete());
                }

                 // Delete the marker itself
                 pm.deletePersistent(itemToDelete);
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
