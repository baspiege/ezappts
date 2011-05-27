package sched.data;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import javax.jdo.PersistenceManager;
import javax.jdo.Query;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import sched.data.model.Service;
import sched.data.model.Store;
import sched.utils.EditMessages;
import sched.utils.RequestUtils;
import sched.utils.SessionUtils;

/**
 * Get all services for a store.
 *
 * @author Brian Spiegel
 */
public class ServiceGetAll
{
    /**
     * Get all services.
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
                // Get all services
                query = pm.newQuery(Service.class);
                query.setFilter("storeId == storeIdParam");
                query.declareParameters("long storeIdParam");
                query.setOrdering("descLowerCase ASC");

                List<Service> results = (List<Service>) query.execute(storeId);

                Map serviceMap=new LinkedHashMap();
                for (Service service : results)
                {
                    serviceMap.put(new Long(service.getKey().getId()),pm.detachCopy(service));
                }
                aRequest.setAttribute(RequestUtils.SERVICES, serviceMap);
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
