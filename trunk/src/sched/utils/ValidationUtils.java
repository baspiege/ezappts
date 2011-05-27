package sched.utils;

import java.util.Map;

import sched.data.model.Appt;
import sched.data.model.User;
import sched.utils.EditMessages;

import javax.servlet.http.HttpServletRequest;

/**
 * Validation utilities.
 *
 * @author Brian Spiegel
 */
public class ValidationUtils
{
    /**
     * Check the duration
     *
     * @param aRequest The request
     *
     * @since 1.0
     */
    public static void checkDuration(HttpServletRequest aRequest, int aDurationMin)
    {
        // Check if duration is 0 or less.
        if (aDurationMin<=0)
        {
            RequestUtils.addEditUsingKey(aRequest,EditMessages.DURATION_MUST_BE_GREATER_THAN_ZERO);
        }
        // Check if duration is more than 24 hrs.
        else if (aDurationMin>24*60)
        {
            RequestUtils.addEditUsingKey(aRequest,EditMessages.DURATION_MUST_BE_24_HOURS_OR_LESS);
        }
    }

    /**
     * Check that a user has update access to a appt.  Create edit if no access.
     *
     * @param aRequest The request
     * @param aUser User
     * @param aAppt Appt
     * @return a boolean indicting if the user has update access to a role
     *
     * @since 1.0
     */
    public static boolean checkUpdateAccessToAppt(HttpServletRequest aRequest, User aUser, Appt aAppt)
    {
        boolean hasAccess=false;
    
        // Admin always have access.
        if (aUser.getIsAdmin())
        {
            hasAccess=true;
        }        
        // If staff and user is provider.
        else if (aUser.getIsStaff() && aUser.getKey().getId()==aAppt.getProviderUserId())
        {
            hasAccess=true;
        }
        // If customer, user is recipient, and 'is pending'.
        else if (aAppt.getIsPending() && aUser.getKey().getId()==aAppt.getRecipientUserId())
        {
            hasAccess=true;        
        }

        if (!hasAccess)
        {
            RequestUtils.addEditUsingKey(aRequest,EditMessages.ADMIN_ACCESS_REQUIRED);
        }

        return hasAccess;
    }
}
