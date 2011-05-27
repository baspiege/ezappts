package sched.data;

import java.util.List;
import javax.jdo.PersistenceManager;
import javax.jdo.Query;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import sched.data.model.Service;
import sched.data.model.Store;
import sched.data.model.User;
import sched.utils.DateUtils;
import sched.utils.EditMessages;
import sched.utils.MemCacheUtils;
import sched.utils.RequestUtils;
import sched.utils.SessionUtils;
import sched.utils.ValidationUtils;

/**
 * Add or update a service to a store.
 *
 * Check that the desc is not already being used.
 *
 * @author Brian Spiegel
 */
public class ServiceAddUpdate
{
    /**
     * Add or update a service.
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

        // Check if admin
        User currentUser=RequestUtils.getCurrentUser(aRequest);
        if (currentUser==null)
        {
            // Should be caught by SessionUtils.isLoggedOn, but just in case.
            RequestUtils.addEditUsingKey(aRequest,EditMessages.CURRENT_USER_NOT_FOUND);
            return;
        }
        else if (!currentUser.getIsAdmin())
        {
            RequestUtils.addEditUsingKey(aRequest,EditMessages.ADMIN_ACCESS_REQUIRED);
            return;
        }

        // Get appt Id. If present, then editing.
        boolean isEditing=false;
        Long serviceId=(Long)aRequest.getAttribute("serviceId");
        if (serviceId!=null)
        {
            isEditing=true;
        }

        // Get Desc
        String desc=(String)aRequest.getAttribute("desc");

        // Duration in minutes
        Long durationHour=(Long)aRequest.getAttribute("durationHour");
        Long durationMinute=(Long)aRequest.getAttribute("durationMinute");
        int durationMin=durationHour.intValue()*60 + durationMinute.intValue();

        // Check duration
        ValidationUtils.checkDuration(aRequest, durationMin);
        
        // Color
        String color=(String)aRequest.getAttribute("color");

        PersistenceManager pm=null;
        try
        {
            pm=PMF.get().getPersistenceManager();

            // Editing
            if (isEditing)
            {
                Service serviceEditing=ServiceUtils.getServiceFromStore(aRequest,pm,storeId,serviceId.longValue());
                if (serviceEditing==null)
                {
                    RequestUtils.addEditUsingKey(aRequest,EditMessages.SERVICE_NOT_FOUND_FOR_STORE);
                    return;
                }

                // Check if desc exists
                if (!RequestUtils.hasEdits(aRequest))
                {
                    ServiceUtils.checkIfDescExists(aRequest, pm, storeId, desc, serviceEditing.getKey().getId());
                }

                // Update
                if (!RequestUtils.hasEdits(aRequest))
                {
                    serviceEditing.setDesc(desc);
                    serviceEditing.setDuration(durationMin);
                    serviceEditing.setColor(color);

                    // Clear request and cache.
                    RequestUtils.setServices(aRequest,null);
                    MemCacheUtils.setServices(aRequest,null);
                }
            }
            // Adding
            else
            {
                // Check if desc exists
                if (!RequestUtils.hasEdits(aRequest))
                {
                    ServiceUtils.checkIfDescExists(aRequest, pm, storeId, desc, -1);
                }

                if (!RequestUtils.hasEdits(aRequest))
                {
                    // Create service.
                    Service service=new Service(storeId, durationMin, desc);
                    service.setColor(color);

                    // Save service.
                    pm.makePersistent(service);

                    // Clear request and cache.
                    RequestUtils.setServices(aRequest,null);
                    MemCacheUtils.setServices(aRequest,null);
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
