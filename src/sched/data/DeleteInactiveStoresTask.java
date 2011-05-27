package sched.data;

import java.util.Calendar;
import java.util.Date;
import java.util.List;
import javax.jdo.PersistenceManager;
import javax.jdo.Query;
import javax.servlet.http.HttpServletRequest;

import sched.data.model.ItemToDelete;
import sched.data.model.Store;
import sched.utils.EditMessages;
import sched.utils.RequestUtils;

/**
 * Delete inactive stores.
 *
 * @author Brian Spiegel
 */
public class DeleteInactiveStoresTask
{
    /**
     * Delete inactive stores.
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

            // Find stores with last accessed time more than 95 days.
            query = pm.newQuery(Store.class);
            query.setFilter("lastTimeAccessed < lastTimeAccessedParam");
            query.declareParameters("java.util.Date lastTimeAccessedParam");

			// Set date.
            Calendar calendar=Calendar.getInstance();
            calendar.add(Calendar.DATE, -95);  // 95 days in the past

			List<Store> results = (List<Store>) query.execute(calendar.getTime());

			// Mark stores to be deleted.
			for (Store store : results)
			{
				ItemToDelete itemToDelete=new ItemToDelete(ItemToDelete.STORE, store.getKey().getId() , -1);
				pm.makePersistent(itemToDelete);

				// Delete store.
                pm.deletePersistent(store);
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
