package sched.utils;

/**
 * String utilities.
 *
 * @author Brian Spiegel
 */
public class StringUtils
{
    /**
    * Check if a string is empty.
    *
    * @param aString a string to check
    */
    public static boolean isEmpty(String aString)
    {
        return aString==null || aString.trim().length()==0;
    }
}
