package sched.utils;

import com.google.appengine.api.memcache.MemcacheService;
import com.google.appengine.api.memcache.MemcacheServiceFactory;

import java.util.Map;
import javax.servlet.http.HttpServletRequest;

import sched.data.model.Service;
import sched.data.model.Store;
import sched.data.model.User;

/**
 * Mem cache utilities.
 *
 * @author Brian Spiegel
 */
public class MemCacheUtils
{
    public static String SERVICES="services";
    public static String STORE="store";
    public static String USERS="users";
    public static String STAFF="staff";

    /**
    * Get the current store Id as String.
    *
    * @param aRequest Servlet Request
    * @return the current Store Id as a String
    */
    public static String getCurrentStoreIdAsString(HttpServletRequest aRequest)
    {
         // Get store Id
        Store currentStore=RequestUtils.getCurrentStore(aRequest);
        if (currentStore==null)
        {
            return null;
        }
        return new Long(currentStore.getKey().getId()).toString();
    }

    /**
    * Get the services from cache.
    *
    * @param aRequest Servlet Request
    */
    public static Map<Long,Service> getServices(HttpServletRequest aRequest)
    {
        String storeId=getCurrentStoreIdAsString(aRequest);

        // Try cache.
        Map<Long,Service> services=null;
        if (storeId!=null)
        {
            MemcacheService memcache=MemcacheServiceFactory.getMemcacheService();
            services=(Map<Long,Service>)memcache.get(storeId + SERVICES);
        }

        return services;
    }
    
    /**
    * Get the staff from cache.
    *
    * @param aRequest Servlet Request
    */
    public static Map<Long,User> getStaff(HttpServletRequest aRequest)
    {
        String storeId=getCurrentStoreIdAsString(aRequest);

        // Try cache.
        Map<Long,User> staff=null;
        if (storeId!=null)
        {
            MemcacheService memcache=MemcacheServiceFactory.getMemcacheService();
            staff=(Map<Long,User>)memcache.get(storeId + STAFF);
        }

        return staff;
    }

    /**
    * Get the store from cache.
    *
    * @param aRequest Servlet Request
    */
    public static Store getStore(HttpServletRequest aRequest)
    {
        String storeId=getCurrentStoreIdAsString(aRequest);

        // Try cache.
        Store store=null;
        if (storeId!=null)
        {
            MemcacheService memcache=MemcacheServiceFactory.getMemcacheService();
            store=(Store)memcache.get(storeId + STORE);
        }

        return store;
    }

    /**
    * Get the users from cache.
    *
    * @param aRequest Servlet Request
    */
    public static Map<Long,User> getUsers(HttpServletRequest aRequest)
    {
        String storeId=getCurrentStoreIdAsString(aRequest);

        // Try cache.
        Map<Long,User> users=null;
        if (storeId!=null)
        {
            MemcacheService memcache=MemcacheServiceFactory.getMemcacheService();
            users=(Map<Long,User>)memcache.get(storeId + USERS);
        }

        return users;
    }

    /**
    * Set the services into cache.
    *
    * @param aRequest Servlet Request
    * @param aServices Services
    */
    public static void setServices(HttpServletRequest aRequest, Map<Long,Service> aServices)
    {
        String storeId=getCurrentStoreIdAsString(aRequest);
        if (storeId!=null)
        {
            MemcacheService memcache=MemcacheServiceFactory.getMemcacheService();
            memcache.put(storeId + SERVICES, aServices);
        }
    }
    
    /**
    * Set the staff into cache.
    *
    * @param aRequest Servlet Request
    * @param aStaff Staff
    */
    public static void setStaff(HttpServletRequest aRequest, Map<Long,User> aStaff)
    {
        String storeId=getCurrentStoreIdAsString(aRequest);
        if (storeId!=null)
        {
            MemcacheService memcache=MemcacheServiceFactory.getMemcacheService();
            memcache.put(storeId + STAFF, aStaff);
        }
    }

    /**
    * Set the store into cache.
    *
    * @param aRequest Servlet Request
    * @param aStore store
    */
    public static void setStore(HttpServletRequest aRequest, Store aStore)
    {
        String storeId=getCurrentStoreIdAsString(aRequest);
        if (storeId!=null)
        {
            MemcacheService memcache=MemcacheServiceFactory.getMemcacheService();
            memcache.put(storeId + STORE, aStore);
        }
    }

    /**
    * Set the users into cache.
    *
    * @param aRequest Servlet Request
    * @param aUsers Users
    */
    public static void setUsers(HttpServletRequest aRequest, Map<Long,User> aUsers)
    {
        String storeId=getCurrentStoreIdAsString(aRequest);
        if (storeId!=null)
        {
            MemcacheService memcache=MemcacheServiceFactory.getMemcacheService();
            memcache.put(storeId + USERS, aUsers);
        }
    }
}
