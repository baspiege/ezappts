package sched.data;

import java.util.List;
import java.util.Map;
import java.util.ResourceBundle;
import javax.jdo.PersistenceManager;
import javax.jdo.Query;
import javax.servlet.http.HttpServletRequest;

import sched.data.model.Store;
import sched.data.model.User;
import sched.utils.DisplayUtils;
import sched.utils.EditMessages;
import sched.utils.RequestUtils;
import sched.utils.SessionUtils;

/**
 * User utils.
 *
 * @author Brian Spiegel
 */
public class UserUtils
{

    /**
     * Check if email address already exists.
     *
     * @param aRequest The request
     * @param aPm PersistenceManager
     * @param aStoreId store Id
     * @param aEmailAddress email address to check
     * @param aUserIdToSkip optional user Id to skip.  If none, use -1.
     *
     * @since 1.0
     */
    public static void checkIfEmailAddressExists(HttpServletRequest aRequest, PersistenceManager aPm, long aStoreId, String aEmailAddress, long aUserIdToSkip)
    {
        Query query=null;
        try
        {
            query = aPm.newQuery(User.class); 
            query.setFilter("(storeId == storeIdParam) && (emailAddressLowerCase == emailAddressLowerCaseParam)"); 
            query.declareParameters("long storeIdParam, String emailAddressLowerCaseParam");            
            query.setRange(0,2);  // Get 2 because current be there still.

            List<User> results = (List<User>) query.execute(aStoreId, aEmailAddress.toLowerCase());

            for (User user : results)
            {
                if (aUserIdToSkip!=user.getKey().getId())
                {    
                    ResourceBundle bundle = ResourceBundle.getBundle("Text", SessionUtils.getLocale(aRequest));
                    String editMessage=bundle.getString("emailAddressExistsEdit") + aEmailAddress + "," + DisplayUtils.formatName(user.getFirstName(),user.getLastName(),false);
                    RequestUtils.addEdit(aRequest,editMessage);                
                }
            }
        }
        catch (Exception e)
        {
            System.err.println(UserUtils.class.getName() + ": " + e);
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
     * Check if name already exists.
     *
     * @param aRequest The request
     * @param aPm PersistenceManager
     * @param aStoreId store Id
     * @param aFirstName first name
     * @param aLastName last name
     * @param aUserIdToSkip optional user Id to skip.  If none, use -1.
     *
     * @since 1.0
     */
    public static void checkIfNameExists(HttpServletRequest aRequest, PersistenceManager aPm, long aStoreId, String aFirstName, String aLastName, long aUserIdToSkip)
    {
        Query query=null;
        try
        {
            query = aPm.newQuery(User.class); 
            query.setFilter("(storeId == storeIdParam) && (firstNameLowerCase == firstNameLowerCaseParam) && (lastNameLowerCase == lastNameLowerCaseParam)"); 
            query.declareParameters("long storeIdParam, String firstNameLowerCaseParam, String lastNameLowerCaseParam");
            query.setRange(0,2);  // Get 2 because current be there still.

            List<User> results = (List<User>) query.execute(aStoreId, aFirstName.toLowerCase(), aLastName.toLowerCase());

            for (User user : results)
            {
                if (aUserIdToSkip!=user.getKey().getId())
                {    
                    ResourceBundle bundle = ResourceBundle.getBundle("Text", SessionUtils.getLocale(aRequest));
                    String editMessage=bundle.getString("userNameExistsEdit") + DisplayUtils.formatName(user.getFirstName(),user.getLastName(),false);
                    RequestUtils.addEdit(aRequest,editMessage);
                }
            }
        }
        catch (Exception e)
        {
            System.err.println(UserUtils.class.getName() + ": " + e);
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
     * Get user from map.
     *
     * @param aUser users     
     * @param aUserId user Id          
     * @return if appt is valid
     *
     * @since 1.0
     */    
    public static User getUser(Map<Long,User> aUsers, long aUserId)
    {    
        return (User)aUsers.get(aUserId);    
    }    
                
    /**
     * Get the user from a store.
     *
     * @param aRequest The request
     * @param aPm PersistenceManager
     * @param aStoreId store Id
     * @param aUserId user Id
     * @return a user or null if not found
     *
     * @since 1.0
     */
    public static User getUserFromStore(HttpServletRequest aRequest, PersistenceManager aPm, long aStoreId, long aUserId)
    {
        User user=null;

        Query query=null;
        try
        {
            // Get user.
            // Do not use getObjectById as the User Id could have been changed by the user.
            // Use a query to get by user Id and store Id to verify the user Id is in the
            // current store.
            query = aPm.newQuery(User.class); 
            query.setFilter("(storeId == storeIdParam) && (key == userIdParam)"); 
            query.declareParameters("long storeIdParam, long userIdParam");
            query.setRange(0,1);

            List<User> results = (List<User>) query.execute(aStoreId, aUserId); 

            if (!results.isEmpty())
            {
                user=(User)results.get(0);
            }
        }
        finally
        {
            if (query!=null)
            {   
                query.closeAll(); 
            }
        }

        return user;
    }
    
    /**
     * Get the user from a store by user name.
     *
     * @param aRequest The request
     * @param aPm PersistenceManager
     * @param aStoreId store Id
     * @param aUserName user name
     * @return a user or null if not found
     *
     * @since 1.0
     */
    public static User getUserFromStoreByUserName(HttpServletRequest aRequest, PersistenceManager aPm, long aStoreId, String aUserName)
    {
        User user=null;

        Query query=null;
        try
        {
            query = aPm.newQuery(User.class); 
            query.setFilter("(storeId==storeIdParam) && (emailAddressLowerCase == userNameParamLowerCase)"); 
            query.declareParameters("long storeIdParam, String userNameParamLowerCase");
            query.setRange(0,1);
            List<User> results = (List<User>) query.execute(aStoreId, aUserName.toLowerCase());

            if (!results.isEmpty())
            {
                user=(User)results.get(0);
            }
        }
        finally
        {
            if (query!=null)
            {   
                query.closeAll(); 
            }
        }

        return user;
    }	
    
    /**
     * Is the user valid?
     *
     * @param aUser users     
     * @param aUserId user Id          
     * @return if appt is valid
     *
     * @since 1.0
     */    
    public static boolean isValidUser(Map<Long,User> aUsers, long aUserId)
    {    
        return aUsers.containsKey(aUserId);    
    }         
}
