package sched.data.model;

import com.google.appengine.api.datastore.Key; 

import java.io.Serializable;  
import java.util.Date;

import javax.jdo.annotations.IdGeneratorStrategy; 
import javax.jdo.annotations.IdentityType; 
import javax.jdo.annotations.PersistenceCapable; 
import javax.jdo.annotations.Persistent; 
import javax.jdo.annotations.PrimaryKey; 
 
@PersistenceCapable(identityType = IdentityType.APPLICATION, detachable="true")

/**
 * Appointment has the start date, duration, service Id.
 * Duration is in minutes.
 * 
 * @author Brian Spiegel
 */
public class Appt implements Serializable {

    private static final long serialVersionUID = 1L;
 
    @PrimaryKey 
    @Persistent(valueStrategy = IdGeneratorStrategy.IDENTITY) 
    private Key key;
 
    @Persistent 
    private int duration; 
    
    @Persistent 
    private long lastUpdateUserId;
    
    @Persistent 
    private Date lastUpdateTime;	
    
    @Persistent 
    private boolean isPending; 

    @Persistent 
    private String note; 
    
    @Persistent 
    private long providerUserId;
    
    @Persistent 
    private long recipientUserId;

    @Persistent 
    private long serviceId;

    @Persistent 
    private long storeId;
 
    @Persistent 
    private Date startDate;
 
    /**
     * Constructor.
     * 
     */ 
    public Appt()
    {
    } 
 
    // Accessors for the fields.  JDO doesn't use these, but the application does. 
 
    public int getDuration()
    { 
        return duration; 
    }
    
    public boolean getIsPending()
    { 
        return isPending; 
    }

    public Key getKey()
    { 
        return key; 
    }

    public long getLastUpdateUserId()
    { 
        return lastUpdateUserId; 
    }	
    
    public Date getLastUpdateTime()
    { 
        return lastUpdateTime; 
    }	

    public String getNote()
    { 
        return note; 
    }
    
    public long getProviderUserId()
    { 
        return providerUserId; 
    }
    
    public long getRecipientUserId()
    { 
        return recipientUserId; 
    }

    public long getServiceId()
    { 
        return serviceId; 
    }
 
    public Date getStartDate()
    { 
        return startDate; 
    }

    public long getStoreId()
    { 
        return storeId; 
    }
    
    public void setDuration(int aDuration)
    { 
        duration=aDuration; 
    }	
    
    public void setIsPending(boolean aIsPending)
    { 
        isPending=aIsPending; 
    }	

    public void setLastUpdateUserId(long aUserId)
    { 
        lastUpdateUserId=aUserId; 
    }	
    
    public void setLastUpdateTime(Date aDate)
    { 
        lastUpdateTime=aDate; 
    }	
    
    public void setNote(String aNote)
    { 
        note=aNote; 
    }
   
    public void setProviderUserId(long aUserId)
    { 
        providerUserId=aUserId; 
    }
    
    public void setRecipientUserId(long aUserId)
    { 
        recipientUserId=aUserId; 
    }
    
    public void setServiceId(long aServiceId)
    { 
        serviceId=aServiceId; 
    }
    
    public void setStartDate(Date aStartDate)
    { 
        startDate=aStartDate; 
    }
    
    public void setStoreId(long aStoreId)
    { 
        storeId=aStoreId; 
    }
}