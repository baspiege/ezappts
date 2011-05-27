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
 * Add a user to a store.
 *
 * Check if a user is an admin.
 * Check that the email address is not already being used.
 * Check that first and last name are not already used.
 *
 * @author Brian Spiegel
 */
public class UserAdd
{
    /**
     * Add a user.
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

        // Get fields
        String firstName=(String)aRequest.getAttribute("firstName");
        String lastName=(String)aRequest.getAttribute("lastName");
        String emailAddress=(String)aRequest.getAttribute("emailAddr");
        String userType=(String)aRequest.getAttribute("userType");
        String note=(String)aRequest.getAttribute("note");
        String phone=(String)aRequest.getAttribute("phone");

        PersistenceManager pm=null;
        try
        {
            pm=PMF.get().getPersistenceManager();

            // Check if name exists
            if (!RequestUtils.hasEdits(aRequest))
            {
                UserUtils.checkIfNameExists(aRequest, pm, storeId, firstName, lastName, -1);
            }

            // Check if email address exists
            if (!RequestUtils.hasEdits(aRequest) && emailAddress!=null && emailAddress.length()!=0)
            {
                UserUtils.checkIfEmailAddressExists(aRequest, pm, storeId, emailAddress, -1);
            }

            if (!RequestUtils.hasEdits(aRequest))
            {
                // Create user.
                User user=new User(storeId, firstName, lastName);
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
                    user.setIsStaff(true);                
                }

                // Save user.
                pm.makePersistent(user);

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
