package sched.data;

import java.util.Comparator;
import java.util.Date;

import sched.data.model.Appt;

/**
 * Comparator for sorting appt by start date - descending.
 *
 * @author Brian Spiegel
 */
public class ApptSortByStartDate implements Comparator
{

    /**
     * Compare based on start date.
     *
     * @param aAppt1 appt 1
     * @param aAppt2 appt 2
     * @return an int indicating the result of the comparison
     */
    public int compare(Object aAppt1, Object aAppt2)
    {
        // Parameter are of type Object, so we have to downcast it
        Date date1=((Appt)aAppt1).getStartDate();
        Date date2=((Appt)aAppt2).getStartDate();

        return date2.compareTo(date1);
    }
}
