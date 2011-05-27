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
 * Item to delete.
 * 
 * @author Brian Spiegel
 */
public class ItemToDelete implements Serializable {

    private static final long serialVersionUID = 1L;

    public static final int STORE = 1;
    public static final int SERVICE = 2;
    public static final int USER = 3;
 
    @PrimaryKey 
    @Persistent(valueStrategy = IdGeneratorStrategy.IDENTITY) 
    private Key key;

    @Persistent 
    private int typeToDelete;

    @Persistent 
    private long storeId;

    @Persistent 
    private long idToDelete;
  
    /**
     * Constructor.
     * 
     */ 
    public ItemToDelete(int aTypeToDelete, long aStoreId, long aIdToDelete)
    { 
        typeToDelete=aTypeToDelete;
        storeId=aStoreId;
        idToDelete=aIdToDelete;
    } 
 
    // Accessors for the fields.  JDO doesn't use these, but the application does. 
 
    public Key getKey()
    { 
        return key; 
    }

    public long getIdToDelete()
    { 
        return idToDelete; 
    }

    public long getStoreId()
    { 
        return storeId; 
    }

    public int getTypeToDelete()
    { 
        return typeToDelete; 
    }
}