package sched.utils;

/**
 * HTML utilities.
 *
 * @author Brian Spiegel
 */
public class HtmlUtils
{

    /**
     * Escape characters: ampersand, greater than, less than, double quote,
     * single qutoe, slash
     *
     * @param aInput the String to escape
     *
     * @return an escaped String
     */
    public static String escapeChars(String aInput)
    {
        if (aInput==null)
        {
            return "";
        }

        int inputLength = aInput.length();

        StringBuffer output = new StringBuffer(inputLength);

        for (int i = 0; i < inputLength; i++)
        {

            char currChar = aInput.charAt(i);

            if (currChar == '&')
            {
                output.append("&amp;");
            }
            else if (currChar == '<')
            {
                output.append("&lt;");
            }
            else if (currChar == '>')
            {
                output.append("&gt;");
            }
            else if (currChar == '\"')
            {
                output.append("&quot;");
            }
            else if (currChar == '\'')
            {
                output.append("&#x27;");
            }
            else if (currChar == '/')
            {
                output.append("&#x2F;");
            }
            else
            {
                output.append(currChar);
            }
        }

        return output.toString();
    }
}
