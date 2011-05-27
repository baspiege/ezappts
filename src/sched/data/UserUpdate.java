package sched.data;

import java.util.List;
import javax.jdo.PersistenceManager;
import javax.jdo.Query;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import sched.data.model.Store;
import sched.data.model.User;
import sched.utils.DisplayUtils;
import sched.utils.EditMessages;
import sched.utils.MemCacheUtils;
import sched.utils.RequestUtils;
import sched.utils.SessionUtils;

/**
 * Update a user of a store.
 *
 * Check if a user is an admin.
 * Check that the email address is not already being used.
 * Check that first and last name are not already used.
 *
 * @author Brian Spiegel
 */
public class UserUpdate
{
    /**
     * Update a user.
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

        // User Id
        long userId=((Long)aRequest.getAttribute("userId")).longValue();;

        // Get fields
        String firstName=(String)aRequest.getAttribute("firstName");
        String lastName=(String)aRequest.getAttribute("lastName");
        String emailAddress=(String)aRequest.getAttribute("emailAddr");
        String userType=(String)aRequest.getAttribute("userType");
        String note=(String)aRequest.getAttribute("note");
        String phone=(String)aRequest.getAttribute("phone");
            
        PersistenceManager pm=null;
        Query query=null;
        try
        {
            pm=PMF.get().getPersistenceManager();

            // Get user.
            User user=user=UserUtils.getUserFromStore(aRequest,pm,storeId,userId);
            if (user==null)
            {
                RequestUtils.addEditUsingKey(aRequest,EditMessages.USER_NOT_FOUND_FOR_STORE);
                return;
            }

            // Check if name exists
            if (!RequestUtils.hasEdits(aRequest))
            {
                UserUtils.checkIfNameExists(aRequest, pm, storeId, firstName, lastName, userId);
            }

            // Check if email address exists
            if (!RequestUtils.hasEdits(aRequest) && emailAddress!=null && emailAddress.length()!=0)
            {
                UserUtils.checkIfEmailAddressExists(aRequest, pm, storeId, emailAddress, userId);
            }

            if (!RequestUtils.hasEdits(aRequest))
            {
                // For security, if a user changes their own email, they need to log back into the
                // site.
                if (currentUser.getKey().getId()==userId && !user.getEmailAddress().equals(emailAddress))
                {
                    aRequest.setAttribute("userChangedOwnEmailAddress",new Boolean(true));
                }

                user.setFirstName(firstName);
                user.setLastName(lastName);
                user.setEmailAddress(emailAddress);
                user.setNote(note);
                user.setPhone(phone);

                if (userType.equals("admin"))
                {
                    user.setIsAdmin(true);
                    user.setIsStaff(true);                
                }
                else if (userType.equals("staff"))
                {
                    user.setIsAdmin(false);
                    user.setIsStaff(true);                
                }
                else
                {
                    user.setIsAdmin(false);
                    user.setIsStaff(false);                
                }
                
                // Clear request and cache.
                RequestUtils.setUsers(aRequest,null);
                RequestUtils.setStaff(aRequest,null);
                MemCacheUtils.setUsers(aRequest,null);
                MemCacheUtils.setStaff(aRequest,null);
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
