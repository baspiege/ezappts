package sched.utils;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.TimeZone;
import javax.servlet.http.HttpServletRequest;

import sched.data.model.Store;

/**
 * Date utilities.
 *
 * @author Brian Spiegel
 */
public class DateUtils
{
    public static String AM="AM";
    public static String PM="PM";
    public static String NO_AM_PM="none";

    /**
    * Get Calendar.
    *
    * @param aRequest request
    * @return a Calendar
    */
    public static Calendar getCalendar(HttpServletRequest aRequest)
    {
        Store store=RequestUtils.getCurrentStore(aRequest);
        Calendar calendar = Calendar.getInstance(store.getTimeZone(),Locale.getDefault());
        return calendar;
    }

    /**
    * Get Calendar.
    *
    * @param aRequest request
    * @param aYear year
    * @param aMonth month
    * @param aDay day
    * @param aHour if 12 hr: 12,1,2,3...,10,11,12,1..., else if 24 hr: 0-23
    * @param aMinute minute
    * @param aAmPm AM or PM or "none" if 24 hr
    * @return a Calendar
    */
    public static Calendar getCalendar(HttpServletRequest aRequest, Long aYear, Long aMonth, Long aDay, Long aHour, Long aMinute, String aAmPm)
    {
        Calendar calendar = getCalendar(aRequest);

        // Calculate hour
        int hour=aHour.intValue();
        if (aAmPm.equals(AM))
        {
            if (hour==12)
            {
                hour=0;
            }
        }
        else if (aAmPm.equals(PM))
        {
            if (hour!=12)
            {
                hour+=12;
            }
        }

        calendar.set(aYear.intValue(),aMonth.intValue()-1,aDay.intValue(),hour,aMinute.intValue(),0);
        calendar.set(Calendar.MILLISECOND, 0);

        return calendar;
    }

    /**
    * Get the end date from the start date and duration.
    *
    * @param aStartDate a start date
    * @param aDurationMinutes duration in minutes
    * @return a Date object
    */
    public static Date getEndDate(Date aStartDate, long aDurationMinutes)
    {
        return new Date(aStartDate.getTime()+(aDurationMinutes*60*1000));
    }

    /**
    * Get minutes from hour, minutes, and AM/PM.
    *
    * @param aRequest request
    * @param aHour if 12 hr: 12,1,2,3...,10,11,12,1..., else if 24 hr: 0-23
    * @param aMinute minute
    * @param aAmPm AM or PM or "none" if 24 hr
    * @return the time in minutes
    */
    public static int getMinutes(HttpServletRequest aRequest, Long aHour, Long aMinute, String aAmPm)
    {
        // Calculate hour
        int hour=aHour.intValue();
        if (aAmPm.equals(AM))
        {
            if (hour==12)
            {
                hour=0;
            }
        }
        else if (aAmPm.equals(PM))
        {
            if (hour!=12)
            {
                hour+=12;
            }
        }

        return hour*60 + aMinute.intValue();
    }

    /**
    * Check if the time zone Id is valid.
    *
    * @param aTimeZone a time zone Id to check
    * @return a boolean indicating if the time zone Id is valid
    */
    public static List getTimeZones()
    {
        List timeZoneList=new ArrayList();

        String[] timeZones=TimeZone.getAvailableIDs();

        for(int i=0;i<timeZones.length;i++)
        {
            String timeZone=(String)timeZones[i];

            if (timeZone.length()!=3)
            {
                timeZoneList.add(timeZone);
            }
        }

        return timeZoneList;
    }

    /**
    * Check if the time zone Id is valid.
    *
    * @param aTimeZone a time zone Id to check
    * @return a boolean indicating if the time zone Id is valid
    */
    public static boolean isTimeZoneValid(String aTimeZone)
    {
        List timezonesList=getTimeZones();
        if (timezonesList.contains(aTimeZone))
        {
            return true;
        }
        return false;
    }
}
