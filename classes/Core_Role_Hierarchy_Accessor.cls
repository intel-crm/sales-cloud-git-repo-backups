public class Core_Role_Hierarchy_Accessor
{
    // READ-WRITE property
    /*private Set<Id> pUserIds;
    public  Set<Id> userIds {
        set {
                pUserIds = value;
                system.Debug('#1 : Users: ' + pUserIds);                
                
                pParentRoleIds = NULL;
                pRoleIds       = NULL;
                pRoleUserIds   = NULL;
        }    
        get {
            return pUserIds;
        }
    }


    // READ-WRITE property
    private Set<Id> pRoleIds;
    public  Set<Id> roleIds {
        set {
                pRoleIds = value;
                System.Debug('#2 Set RoleIds: ' + pRoleIds);

                pParentRoleIds = NULL;
                pRoleUserIds   = NULL;
        }
        get {
                if (pRoleIds != NULL && userIds == NULL) {
                    pRoleIds = new Set<Id>();
                }        
                else if (pRoleIds == NULL && userIds != NULL)
                {
                   if (pRoleIds == NULL)
                       pRoleIds = new Set<Id>();
                       
                    for (User user : [SELECT UserRoleId 
                                      FROM User
                                      WHERE Id IN :userIds
                                        AND UserRoleId != '']) {                   
                       pRoleIds.add(user.UserRoleId);         
                    }         
                    
                    system.Debug('#3 : Parents: ' + pRoleIds);                                    
                    
                }

                return pRoleIds;
        }
    }    


    // READ-ONLY property
    private Set<Id> pParentRoleIds;
    public  Set<Id> parentRoleIds { 
        get { 
                if (pParentRoleIds != NULL && RoleIds == NULL) {
                    pParentRoleIds = new Set<Id>();
                }
                else if (pParentRoleIds == NULL && RoleIds != NULL)
                {
                    if (pParentRoleIds == NULL)
                        pParentRoleIds = new Set<Id>();

                    for (UserRole ur : [SELECT ParentRoleId 
                                        FROM UserRole
                                        WHERE Id IN :RoleIds
                                          AND ParentRoleId != '']) {                            
                        pParentRoleIds.add(ur.ParentRoleId);     
                    }            
                    
                    system.Debug('#4 : Parents: ' + pParentRoleIds);                
                                                                                      
                    
                }

                return pParentRoleIds;
        }
    }
    

    // READ-ONLY property
    private Set<Id> pRoleUserIds;
    public  Set<Id> RoleUserIds { 
        get { 
                if (pRoleUserIds != NULL && pRoleIds == NULL) {
                    pRoleUserIds = new Set<Id>();
                }
                else if (pRoleUserIds == NULL && pRoleIds != NULL)
                {
                    if (pRoleUserIds == NULL)
                        pRoleUserIds = new Set<Id>();
                            
                    for (User user: [SELECT Id
                                     FROM User
                                     WHERE UserRoleId IN :pRoleIds
                                       AND Id != '']) {
                        pRoleUserIds.add(user.Id);
                    }
                                 
                    system.Debug('#5 : RoleUserIds: ' + pRoleUserIds);                
                                                                     
                }    
                        
                return pRoleUserIds; 
            } 
    }


    // Constructor
    public Core_Role_Hierarchy_Accessor() {
    }*/
        
}