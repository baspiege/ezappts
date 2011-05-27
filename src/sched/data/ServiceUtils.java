package sched.data;

import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.ResourceBundle;
import javax.jdo.PersistenceManager;
import javax.jdo.Query;
import javax.servlet.http.HttpServletRequest;

import sched.data.model.Service;
import sched.data.model.Store;
import sched.data.model.User;
import sched.utils.DisplayUtils;
import sched.utils.EditMessages;
import sched.utils.RequestUtils;
import sched.utils.SessionUtils;

/**
 * Service utils.
 *
 * @author Brian Spiegel
 */
public class ServiceUtils
{
    /**
     * Check if desc already exists.
     *
     * @param aRequest The request
     * @param aPm PersistenceManager
     * @param aStoreId store Id
     * @param aDesc desc
     * @param aServiceIdToSkip optional Service Id to skip.  If none, use -1.
     *
     * @since 1.0
     */
    public static void checkIfDescExists(HttpServletRequest aRequest, PersistenceManager aPm, long aStoreId, String aDesc, long aServiceIdToSkip)
    {
        Query query=null;
        try
        {
            query = aPm.newQuery(Service.class);
            query.setFilter("(storeId == storeIdParam) && (descLowerCase == descLowerCaseParam)");
            query.declareParameters("long storeIdParam, String descLowerCaseParam");
            query.setRange(0,2);  // Get 2 because current will be there still.

            List<Service> results = (List<Service>) query.execute(aStoreId, aDesc.toLowerCase());

            for (Service service : results)
            {
                if (aServiceIdToSkip!=service.getKey().getId())
                {
                    ResourceBundle bundle = ResourceBundle.getBundle("Text", SessionUtils.getLocale(aRequest));
                    String editMessage=bundle.getString("ServiceExistsEdit") + service.getDesc();
                    RequestUtils.addEdit(aRequest,editMessage);
                }
            }
        }
        catch (Exception e)
        {
            System.err.println(ServiceUtils.class.getName() + ": " + e);
            e.printStackTrace();
            RequestUtils.addEditUsingKey(aRequest,EditMessages.ERROR_PROCESSING_REQUEST);
        }
        finally
        {
            if (query!=null)
            {
                query.closeAll();
            }
        }
    }

    /**
     * Get the Service for a store.
     *
     * @param aRequest The request
     * @param aPm PersistenceManager
     * @param aStoreId store Id
     * @param aServiceId Service Id
     * @return a Service or null if not found
     *
     * @since 1.0
     */
    public static Service getServiceFromStore(HttpServletRequest aRequest, PersistenceManager aPm, long aStoreId, long aServiceId)
    {
        Service service=null;

        Query query=null;
        try
        {
            // Get Service.
            // Do not use getObjectById as the Service Id could have been changed by the Service.
            // Use a query to get by Service Id and store Id to verify the Service Id is in the
            // current store.
            query = aPm.newQuery(Service.class);
            query.setFilter("(storeId == storeIdParam) && (key == serviceIdParam)");
            query.declareParameters("long storeIdParam, long serviceIdParam");
            query.setRange(0,1);

            List<Service> results = (List<Service>) query.execute(aStoreId, aServiceId);

            if (!results.isEmpty())
            {
                service=(Service)results.get(0);
            }
        }
        finally
        {
            if (query!=null)
            {
                query.closeAll();
            }
        }

        return service;
    }

    /**
     * Is the service valid?
     *
     * @param aServices services
     * @param aServiceId service Id
     * @return if appt is valid
     *
     * @since 1.0
     */
    public static boolean isValidService(Map<Long,Service> aServices, long aServiceId)
    {
        return (aServices.containsKey(new Long(aServiceId)) || aServiceId==Service.NO_SERVICE);
    }
}
