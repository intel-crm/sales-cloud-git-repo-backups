public class Core_Account_Accessor
{
    // READ-WRITE properties        
    private Id pAccountId;
    public  Id accountId {
        set {
                pAccountId   = value;
                pTeamUserIds = NULL;
        }    
        get {
            return pAccountId;
        }
    }


    // READ-ONLY properties        
    private Set<Id> pTeamUserIds;
    public  Set<Id> teamUserIds { 
        get { 
                if (pTeamUserIds == NULL)
                {
                    pTeamUserIds = new Set<Id>();
                    for (AccountTeamMember tm : [SELECT UserId 
                                                 FROM AccountTeamMember
                                                 WHERE AccountId = :pAccountId
                                                   AND isDeleted = False])
                        pTeamUserIds.add(tm.UserId);                                 
                }
                
                return pTeamUserIds; 
            } 
    }

    
    // Constructor
    public Core_Account_Accessor() {
    }

        
}