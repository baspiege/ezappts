package sched.utils;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Map;

/**
 * Display utilities.
 *
 * @author Brian Spiegel
 */
public class DisplayUtils
{
    /**
    * Display non breaking space if null or an HTML escaped string.
    */
    public static String getSpaceIfNull(String aString)
    {
        if (aString==null || aString.length()==0)
        {
            return "&nbsp;";
        }
        else
        {
            return HtmlUtils.escapeChars(aString);
        }
    }

    /**
    * Get minute select.
    */
    public static String getHourMinuteDisplay(Calendar aCalendar, Date aDate, SimpleDateFormat aHour, SimpleDateFormat aHourMin)
    {
        if (aCalendar.get(Calendar.MINUTE)!=0)
        {
            return aHourMin.format(aDate);
        }
        else
        {
            return aHour.format(aDate);
        }
    }

    /**
     * Format duration.
     *
     * @param aMinutes minutes
     *
     * @return a formatted name
     */
    public static String formatDuration(int aMinutes)
    {
        int hours=0;
        int minutes=0;

        if (aMinutes!=0)
        {
            hours=aMinutes/60;
            minutes=aMinutes%60;
        }

        String display=new Integer(hours).toString() + " Hrs " + new Integer(minutes).toString() + " Mins";

        return display;
    }

    /**
     * Format a name.
     *
     * @param aFirstName first name
     * @param aLastName last name
     *
     * @return a formatted name
     */
    public static String formatName(String aFirstName, String aLastName, boolean aLastNameFirst)
    {
        String name=null;

        boolean noFirst=aFirstName==null || aFirstName.length()==0;
        boolean noLast=aLastName==null || aLastName.length()==0;

        if (noFirst && noLast)
        {
            name="";
        }
        else if (noFirst)
        {
            name=aLastName;
        }
        else if (noLast)
        {
            name=aFirstName;
        }
        else
        {
            if (aLastNameFirst)
            {
                name=aLastName + ", " + aFirstName;
            }
            else
            {
                name=aFirstName + " " + aLastName;
            }
        }

        return name;
    }

    /**
     * Format time from minutes to hours, minutes, and AM/PM.
     *
     * @param aMinutes minutes
     *
     * @return a formatted time
     */
    public static String formatTime(int aMinutes)
    {
        int hours=0;
        int minutes=0;

        if (aMinutes!=0)
        {
            hours=aMinutes/60;
            minutes=aMinutes%60;
        }

        StringBuffer timeDisplay=new StringBuffer();
        if (hours==0)
        {
            timeDisplay.append("12");
        }
        else if (hours>12)
        {
            timeDisplay.append(hours-12);
        }
        else
        {
            timeDisplay.append(hours);
        }

        timeDisplay.append(":");

        // Minutes
        if (minutes<10)
        {
            timeDisplay.append("0");
        }
        timeDisplay.append(minutes);

        // Am/Pm
        if (hours>11)
        {
            timeDisplay.append(" PM");
        }
        else
        {
            timeDisplay.append(" AM");
        }

        return timeDisplay.toString();
    }
}
