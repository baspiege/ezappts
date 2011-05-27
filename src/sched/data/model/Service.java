package sched.data.model;

import com.google.appengine.api.datastore.Key;

import java.io.Serializable;

import javax.jdo.annotations.IdGeneratorStrategy;
import javax.jdo.annotations.IdentityType;
import javax.jdo.annotations.PersistenceCapable;
import javax.jdo.annotations.Persistent;
import javax.jdo.annotations.PrimaryKey;

@PersistenceCapable(identityType = IdentityType.APPLICATION, detachable="true")

/**
 * Service has the desc, duration in minutes.
 *
 * @author Brian Spiegel
 */
public class Service implements Serializable {

    private static final long serialVersionUID = 1L;

    public static final long NO_SERVICE = -1;
    public static final long ALL_SERVICES = -2;

    @PrimaryKey
    @Persistent(valueStrategy = IdGeneratorStrategy.IDENTITY)
    private Key key;

    @Persistent
    private long storeId;

    @Persistent
    private String desc;

    @Persistent
    private String descLowerCase;

    @Persistent
    private int duration;
    
    @Persistent
    private String color;

    /**
     * Constructor.
     *
     */
    public Service(long aStoreId, int aDuration, String aDesc)
    {
        storeId = aStoreId;
        duration = aDuration;

        desc = aDesc;
        if (desc!=null)
        {
            descLowerCase = aDesc.toLowerCase();
        }
    }

    // Accessors for the fields.  JDO doesn't use these, but the application does.
    
    public String getColor()
    {
        return color;
    }

    public String getDesc()
    {
        return desc;
    }

    public int getDuration()
    {
        return duration;
    }

    public Key getKey()
    {
        return key;
    }

    public long getStoreId()
    {
        return storeId;
    }
    
    public void setColor(String aColor)
    {
        color=aColor;
    }

    public void setDesc(String aDesc)
    {
        desc = aDesc;
        if (desc!=null)
        {
            descLowerCase = aDesc.toLowerCase();
        }
    }

    public void setDuration(int aDuration)
    {
        duration=aDuration;
    }
}
