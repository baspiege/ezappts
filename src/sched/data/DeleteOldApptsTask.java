package sched.data;

import java.util.Calendar;
import java.util.Date;
import javax.jdo.PersistenceManager;
import javax.jdo.Query;
import javax.servlet.http.HttpServletRequest;

import sched.data.model.Appt;
import sched.utils.EditMessages;
import sched.utils.RequestUtils;

/**
 * Delete appts.
 *
 * @author Brian Spiegel
 */
public class DeleteOldApptsTask
{
    /**
     * Delete old appts.
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

            query = pm.newQuery(Appt.class);
            query.setFilter("startDate < startDateParam");
            query.declareParameters("java.util.Date startDateParam");

            // Set date.
            Calendar calendar=Calendar.getInstance();
            calendar.add(Calendar.DATE, -95);  // 95 days in the past

            query.deletePersistentAll( calendar.getTime() );
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
