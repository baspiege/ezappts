package sched.data.model;

import com.google.appengine.api.datastore.Key; 

import java.io.Serializable;
import java.util.Date;
import java.util.TimeZone;

import javax.jdo.annotations.IdGeneratorStrategy; 
import javax.jdo.annotations.IdentityType; 
import javax.jdo.annotations.PersistenceCapable; 
import javax.jdo.annotations.Persistent; 
import javax.jdo.annotations.PrimaryKey; 
 
@PersistenceCapable(identityType = IdentityType.APPLICATION, detachable="true")

/**
 * Store.
 * 
 * @author Brian Spiegel
 */
public class Store implements Serializable, Comparable
{ 
    private static final long serialVersionUID = 1L;

    @PrimaryKey 
    @Persistent(valueStrategy = IdGeneratorStrategy.IDENTITY) 
    private Key key;

    @Persistent 
    private Date lastTimeAccessed;
 
    @Persistent 
    private String name;

    @Persistent 
    private String timeZoneId; 

    // Don't save this field:
    private TimeZone timeZone=null;

    /**
     * Constructor.
     * 
     */ 
    public Store(String aName, String aTimeZoneId)
    { 
        name=aName;
        timeZoneId=aTimeZoneId;
    } 

    /**
     * Compare based on store name.
     * 
     */ 
    public int compareTo(Object aAnotherStore) throws ClassCastException
    {
        if (!(aAnotherStore instanceof Store))
        {
            throw new ClassCastException("Store object expected.");
        }

        String anotherStoreName=((Store)aAnotherStore).getName();
        
        return this.getName().toLowerCase().compareTo(anotherStoreName.toLowerCase());
    }

    public Date getLastTimeAccessed()
    { 
        return lastTimeAccessed; 
    }
 
    // Accessors for the fields.  JDO doesn't use these, but the application does. 
    public Key getKey()
    { 
        return key; 
    } 
 
    public String getName()
    { 
        return name; 
    }

    /**
    * Return a time zone object based on the time zone Id.
    */
    public TimeZone getTimeZone()
    {
        if (timeZone==null)
        {
            timeZone=TimeZone.getTimeZone(timeZoneId);
        }
        return timeZone;
    }

    public String getTimeZoneId()
    { 
        return timeZoneId; 
    }

    public void setLastTimeAccessed(Date aLastTimeAccessed)
    { 
        lastTimeAccessed=aLastTimeAccessed; 
    }

    public void setName(String aName)
    { 
        name=aName; 
    }

    public void setTimeZoneId(String aTimeZoneId)
    { 
        timeZoneId=aTimeZoneId; 
    }
}