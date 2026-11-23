public class Core_Role_Upload_Temp_Table
{
    public final Integer ACCESS_UPDATE_SIZE = 10;
    public final Integer updateSize         = 90;    
    public final String EDIT_ACCESS         = 'edit';
    public final String READ_ACCESS         = 'read';
    
    public Boolean reloadDisabled {
        get
        {
            return false;
        }            
    }    
    
    
    public String mgrCounts {
        get 
        {
            if (mgrUploadSettings == null)             
            {
                List<Core_Role_Upload_Temp_Table_2__c> mgrUploadSettingsList = [SELECT Core_Update_Managers_Start__c
                                                                                FROM Core_Role_Upload_Temp_Table_2__c];                                                                                                 
                mgrUploadSettings = mgrUploadSettingsList[0];
            }
            return 'Update Start: ' + string.valueof(mgrUploadSettings.Core_Update_Managers_Start__c);
        }
    }
    
    public String subCounts {
        get 
        {
            if (subUploadSettings == null)             
            {
                List<Core_Role_Upload_Temp_Table_3__c> subUploadSettingsList = [SELECT Core_Update_Subordinates_Start__c
                                                                                FROM Core_Role_Upload_Temp_Table_3__c];                                                                                                 
                subUploadSettings = subUploadSettingsList[0];
            }
            return 'Update Start: ' + string.valueof(subUploadSettings.Core_Update_Subordinates_Start__c);
        }
    }
    
    private List <Core_Role_Upload_Temp_Table_2__c> mgrUploadSettingsList = new List <Core_Role_Upload_Temp_Table_2__c>();
    private List <Core_Role_Upload_Temp_Table_3__c> subUploadSettingsList = new List <Core_Role_Upload_Temp_Table_3__c>();
    
    private List <Core_Role_Upload_Temp_Table__c> roleList;        
    private List <UserRole>                       userRoleList;
    
    private Set<String> managers     = new Set<String>();
    private Set<String> subordinates = new Set<String>();
    
    private Core_Role_Upload_Temp_Table_2__c mgrUploadSettings;
    private Core_Role_Upload_Temp_Table_3__c subUploadSettings;
    
    /*  #1  */
    public void deleteRoleUpdateTempTable()    
    {
        delete [select id from Core_Role_Upload_Temp_Table__c];
    }
    
    
    /*  #2 - Use Data Loader */
    
    
    /*  #3 - 200 per press  */
    public void clearUsers()
    {
        List <User> users = [SELECT Id, UserRoleId 
                             FROM User
                             WHERE user.UserRoleId != ''];
        
        List <User> userUpdates = new List <User>();
        
        Integer i = 0;
        for (User user : users)
        {
            user.UserRoleId = null;
            userUpdates.add(user);
            
            i++;
            if (i > 200)
                break;
        }                
        
        update userUpdates;        
    }
    
    
    /*  #4  */
    public void deleteUserRoles()    
    {
        delete [select id from UserRole];
    }
    
    
    /*  #5  */    
    public void topLevel() 
    {
        
        roleList = [SELECT Core_Account_Manager_WWID__c, Core_Top_Level__c,
                    Core_Subordinate_WWID__c, Core_Subordinate_Role_Name__c, Core_Subordinate_Leaf_Node__c
                    FROM Core_Role_Upload_Temp_Table__c];
        
        for (Core_Role_Upload_Temp_Table__c obj : roleList)
        {
            managers.add(obj.Core_Account_Manager_WWID__c);            
            subordinates.add(obj.Core_Subordinate_WWID__c);
        }
        
        for (Core_Role_Upload_Temp_Table__c obj : roleList)
        {
            obj.Core_Top_Level__c                 = !subordinates.contains(obj.Core_Account_Manager_WWID__c);                        
            obj.Core_Account_Manager_Role_Name__c = 'MGR' + obj.Core_Account_Manager_WWID__c;                            
            obj.Core_Subordinate_Leaf_Node__c     = !managers.contains(obj.Core_Subordinate_WWID__c);           
            
            if (obj.Core_Subordinate_Leaf_Node__c)
                obj.Core_Subordinate_Role_Name__c = obj.Core_Account_Manager_Role_Name__c + '_Employee';
            else    
                obj.Core_Subordinate_Role_Name__c = 'MGR' + obj.Core_Subordinate_WWID__c;
        }
        
        update roleList;     
        
    }
    
    
    /*  #6  */
    public void assignRolesToTopLevel()
    {   
        roleList = [SELECT Core_Account_Manager_Last_Name__c, Core_Account_Manager_First_Name__c, Core_Account_Manager_Role_Name__c
                    FROM Core_Role_Upload_Temp_Table__c
                    WHERE Core_Top_Level__c = TRUE
                    AND Core_Account_Manager_Role_Id__c = ''];
        
        List<UserRole> userRoleList = new List<UserRole>();
        
        Set <String> updateIds = new Set <String>();
        
        String debugPrefix = 'II: assignRoles - ';            
        System.debug(debugPrefix + ' - START');        
        
      
        for (Core_Role_Upload_Temp_Table__c obj : roleList)
        {
            String newId = obj.Core_Account_Manager_Role_Name__c;
            if (updateIds.contains(newId))
                continue;
            else
                updateIds.add(newId);
            
            UserRole ur = new UserRole();                               
            ur.CaseAccessForAccountOwner        = EDIT_ACCESS;
            ur.DeveloperName                    = newId;  
            ur.Name                             = newId;  
            ur.OpportunityAccessForAccountOwner = EDIT_ACCESS;
            ur.RollupDescription                = obj.Core_Account_Manager_Last_Name__c + ', ' + obj.Core_Account_Manager_First_Name__c;
            
            userRoleList.add(ur);
        }
        
        insert userRoleList;                                
        System.debug(debugPrefix + ' - END');                
        
    }
    
    
    /*  #7  */           
    public void loadManagerIds()
    {    
        List<UserRole> userRoleList = new List<UserRole>([SELECT Id, Name FROM UserRole]);        
        Map<String, Id> userRoleMap = new Map<String, Id>();
        for (UserRole ur : userRoleList)
            userRoleMap.put(ur.Name, ur.Id);    
        
        roleList = [SELECT Id, Core_Account_Manager_Role_Name__c, Core_Account_Manager_Role_Id__c
                    FROM Core_Role_Upload_Temp_Table__c
                    WHERE Core_Account_Manager_Role_Id__c = ''];
        
        Id managerRoleId;
        
        for (Core_Role_Upload_Temp_Table__c obj : roleList)
        {
            managerRoleId = userRoleMap.get(obj.Core_Account_Manager_Role_Name__c);
            if (managerRoleId != null)
                obj.Core_Account_Manager_Role_Id__c = managerRoleId;        
        }
        
        update roleList;                
    }
    
    
    /*  #8  */
    public void assignRolesToManagers()
    {   
        roleList = [SELECT Core_Account_Manager_Last_Name__c, Core_Account_Manager_First_Name__c, Core_Account_Manager_Role_Name__c, Core_Account_Manager_Role_Id__c,
                    Core_Subordinate_Last_Name__c, Core_Subordinate_First_Name__c, Core_Subordinate_WWID__c, Core_Subordinate_Leaf_node__c
                    FROM Core_Role_Upload_Temp_Table__c
                    WHERE Core_Account_Manager_Role_Id__c != ''
                    AND Core_Subordinate_Role_Id__c = ''];
        
        List<UserRole> userRoleList = new List<UserRole>();
        Set <String> updateIds      = new Set <String>();
        
        String newId;
        for (Core_Role_Upload_Temp_Table__c obj : roleList)
        {
            if (obj.Core_Subordinate_Leaf_Node__c )            
                newId = obj.Core_Account_Manager_Role_Name__c + '_Employee';
            else    
                newId = 'MGR' + obj.Core_Subordinate_WWID__c;
            
            if (updateIds.contains(newId))
                continue;
            else
                updateIds.add(newId);
            
            UserRole ur = new UserRole();                               
            ur.CaseAccessForAccountOwner        = EDIT_ACCESS;  // Switched from 'Edit' to 'Read'
            ur.DeveloperName                    = newId;  
            ur.Name                             = newId;  
            ur.OpportunityAccessForAccountOwner = EDIT_ACCESS;  // Switched from 'Edit' to 'Read'
            ur.ParentRoleId                     = obj.Core_Account_Manager_Role_Id__c;
            
            if (obj.Core_Subordinate_Leaf_Node__c) 
                ur.RollupDescription = 'Employee of ' + obj.Core_Account_Manager_First_Name__c + ' ' + obj.Core_Account_Manager_Last_Name__c;
            else
                ur.RollupDescription = obj.Core_Subordinate_Last_Name__c + ', ' + obj.Core_Subordinate_First_Name__c;
            
            userRoleList.add(ur);
        }
        
        insert userRoleList;                                
        
    }
    
    
    /*  #9  */
    public void loadSubordinateIds()
    {   
        List<UserRole> userRoleList = new List<userRole>([SELECT Id, Name FROM UserRole]);        
        Map<String, Id> userRoleMap = new Map<String, Id>();
        for (UserRole ur : userRoleList)
            userRoleMap.put(ur.Name, ur.Id);    
        
        roleList = [SELECT Core_Subordinate_Role_Name__c, Core_Subordinate_Role_Id__c
                    FROM Core_Role_Upload_Temp_Table__c
                    WHERE Core_Account_Manager_Role_Id__c != ''
                    AND Core_Subordinate_Role_Id__c = ''];
        
        Id subRoleId;            
        for (Core_Role_Upload_Temp_Table__c obj : roleList)
        {
            subRoleId = userRoleMap.get(obj.Core_Subordinate_Role_Name__c);
            if (subRoleId != null)
                obj.Core_Subordinate_Role_Id__c = subRoleId;        
            
        }
        update roleList;
        
    }
    
    
    /*  #10  */
    public void topUpdateRolesToMidLevel()
    {
        
        roleList = [SELECT Core_Subordinate_WWID__c, Core_Subordinate_Role_Id__c
                    FROM Core_Role_Upload_Temp_Table__c
                    WHERE Core_Subordinate_Leaf_Node__c = FALSE
                    AND Core_Subordinate_Role_Id__c > ''];
        
        Map<String, String> roleMap = new Map<String, String>();              
        for (Core_Role_Upload_Temp_Table__c obj : roleList)
            roleMap.put(obj.Core_Subordinate_WWID__c, obj.Core_Subordinate_Role_Id__c);
        
        
        List<Core_Role_Upload_Temp_Table__c> updateList = [SELECT Id, Core_Account_Manager_WWID__c, Core_Account_Manager_Role_Id__c
                                                           FROM Core_Role_Upload_Temp_Table__c
                                                           WHERE Core_Account_Manager_Role_Id__c = ''];           
        
        String mapRoleID;                  
        Integer idx = 0;
        for (Core_Role_Upload_Temp_Table__c updObj : updateList)
        {
            mapRoleID = roleMap.get(updObj.Core_Account_Manager_WWID__c);
            if (mapRoleID != null)
            {
                updObj.Core_Account_Manager_Role_Id__c = mapRoleID;        
                idx++;
            }  
            
            if (idx > 400)
                break;              
            
        }
        
        update updateList;                       
        
    }
    
    
    
    /* 
public void updateManagers()
{      
Integer idx   = 0;                                 
Integer start = mgrUploadSettings.Core_Update_Managers_Start__c.intValue();
Integer stop  = mgrUploadSettings.Core_Update_Managers_Start__c.intValue() + updateSize;

Set<Id> usersProcessed = new Set<Id>();

List<User> users = new List<User>();        

roleList = [SELECT Core_Account_Manager_WWID__c, Core_Account_Manager_Role_Id__c
FROM Core_Role_Upload_Temp_Table__c
WHERE Core_Account_Manager_Role_Id__c != ''];

List<User> selectedUser;

for (Core_Role_Upload_Temp_Table__c obj : roleList)
{
if ((idx >= start) && (idx <= stop))
{
selectedUser = [SELECT Id, UserRoleId 
FROM User 
WHERE Core_WWID__c = :obj.Core_Account_Manager_WWID__c
OR FederationIdentifier = :obj.Core_Account_Manager_WWID__c];  

if (selectedUser.size() > 0)
{
if (!usersProcessed.contains(selectedUser[0].Id))
{                    
usersProcessed.add(selectedUser[0].Id);
selectedUser[0].UserRoleId = obj.Core_Account_Manager_Role_Id__c;
users.add(selectedUser[0]);            
}
}
} 

idx++;         
if (idx > stop)
break;   
}

update users;
}   
*/ 
    // US677993 : ::Start:: Security Scan Fixes - 5 SOQL inside for loop , Code optimized by Gopala Krishna Ch(pegasus) on 15/05/2020.
    
    public void updateManagers()
    {      
        Integer idx   = 0; 
        Integer idx1  = 0;		
        Integer start = mgrUploadSettings.Core_Update_Managers_Start__c.intValue();
        Integer stop  = mgrUploadSettings.Core_Update_Managers_Start__c.intValue() + updateSize;
        
        Set<Id> usersProcessed = new Set<Id>();
        
        List<User> users = new List<User>();        
        
        roleList = [SELECT Core_Account_Manager_WWID__c, Core_Account_Manager_Role_Id__c
                    FROM Core_Role_Upload_Temp_Table__c
                    WHERE Core_Account_Manager_Role_Id__c != ''];
        
        map<string,Core_Role_Upload_Temp_Table__c> roleTempMap=new map<string,Core_Role_Upload_Temp_Table__c>();
        if(roleList.size() > 0){
            for (Core_Role_Upload_Temp_Table__c obj: roleList)
            {
                if ((idx >= start) && (idx <= stop))
                {
                    roleTempMap.put(obj.Core_Account_Manager_WWID__c, obj);
                }
                idx++;         
                if (idx > stop)
                    break;
                
            }   
        }
        map<string,User> usrMap=new map<string,User>();
        List<User> selectedUser=new List<User>();
        
        if(roleTempMap.keySet().size() > 0){
            
            selectedUser=[SELECT Id, UserRoleId,Core_WWID__c FROM User WHERE Core_WWID__c IN : roleTempMap.keySet() OR FederationIdentifier IN : roleTempMap.keySet()];
            
            for(user u : selectedUser){
                
                usrMap.put(u.Core_WWID__c,u);
                system.debug('the user inside==>'+u.Core_WWID__c);
            }
        }
        if(roleList.size() > 0){
            for (Core_Role_Upload_Temp_Table__c obj : roleTempMap.values())
            {
                system.debug('the map inside==>');
                if ((idx1 >= start) && (idx1 <= stop))
                {
                    if (selectedUser.size() > 0)
                    {
                        
                        if (!usersProcessed.contains(usrMap.get(obj.Core_Account_Manager_WWID__c).id) && usrMap.containsKey(obj.Core_Account_Manager_WWID__c)){
                            usersProcessed.add(usrMap.get(obj.Core_Account_Manager_WWID__c).id);
                            usrMap.get(obj.Core_Account_Manager_WWID__c).UserRoleId = obj.Core_Account_Manager_Role_Id__c;
                            users.add(usrMap.get(obj.Core_Account_Manager_WWID__c));
                            system.debug('the final user inside==>'+usrMap.get(obj.Core_Account_Manager_WWID__c).id);    
                        }
                        
                        
                    }
                } 
                
                idx1++;         
                if (idx1 > stop)
                    break;   
            }
        }
        if(users.size() > 0){
            update users;
        }
        
    }  
    // US677993 : ::Stop:: Security Scan Fixes - 5 SOQL inside for loop , Code optimized by Gopala Krishna Ch(pegasus) on 15/05/2020.

    public void updateManagersCounters()
    {
        mgrUploadSettings.Core_Update_Managers_Start__c = mgrUploadSettings.Core_Update_Managers_Start__c + updateSize;
        update mgrUploadSettings;
    }
    
    // US677993 : ::Start:: Security Scan Fixes - 5 SOQL inside for loop , Code optimized by Gopala Krishna Ch(pegasus) on 15/05/2020.
    public void updateSubordinates()
    {
        Integer idx   = 0; 
        Integer idx1   = 0;
        Integer start = subUploadSettings.Core_Update_Subordinates_Start__c.intValue();
        Integer stop  = subUploadSettings.Core_Update_Subordinates_Start__c.intValue() + updateSize;
        
        
        Set<Id> usersProcessed = new Set<Id>();
        
        List<User> users = new List<User>();        
        
        roleList = [SELECT Core_Subordinate_WWID__c, Core_Subordinate_Role_Id__c
                    FROM Core_Role_Upload_Temp_Table__c
                    WHERE Core_Subordinate_Role_Id__c != ''];
        //US677993 : Security Scan Fixes -Avoid Calling SOQL and DML Inside Loops. SOQL on User now outside the for loop Added by Gopala Krishna Ch
        List<User> selectedUser=new List<User>();
        map<string,Core_Role_Upload_Temp_Table__c> roleTempSubMap=new map<string,Core_Role_Upload_Temp_Table__c>();
        
        if(roleList.size() > 0){
            for (Core_Role_Upload_Temp_Table__c obj : roleList)
            {
                if ((idx >= start) && (idx <= stop))
                {
                    roleTempSubMap.put(obj.Core_Subordinate_WWID__c,obj);
                }
                idx++;         
                if (idx > stop)
                    break;
            }
        }
        
        
        if(roleTempSubMap.KeySet().size() > 0){
            selectedUser = [SELECT Id, UserRoleId,Core_WWID__c FROM User WHERE Core_WWID__c IN  : roleTempSubMap.KeySet() OR FederationIdentifier IN : roleTempSubMap.KeySet()];
        }
        
         map<string,User> usrMap=new map<string,User>();
        
        if(selectedUser.size() > 0){
        for(user u : selectedUser){
                usrMap.put(u.Core_WWID__c,u);
            }
        }
        
        
        
        if(roleTempSubMap.values().size() > 0){
            for (Core_Role_Upload_Temp_Table__c obj : roleTempSubMap.values())
            {
                if ((idx1 >= start) && (idx1 <= stop))
                {
                    
                    if (!usersProcessed.contains(usrMap.get(obj.Core_Subordinate_WWID__c).id) && usrMap.containsKey(obj.Core_Subordinate_WWID__c)){
                            usersProcessed.add(usrMap.get(obj.Core_Subordinate_WWID__c).id);
                            usrMap.get(obj.Core_Subordinate_WWID__c).UserRoleId = obj.Core_Subordinate_Role_Id__c;
                            users.add(usrMap.get(obj.Core_Subordinate_WWID__c));
                            system.debug('the final user inside==>'+usrMap.get(obj.Core_Subordinate_WWID__c).id);    
                        }
                    
                } 
                
                idx1++;         
                if (idx1 > stop)
                    break;
            }
        }
        
        if(users.size() > 0){
            update users;
        }
    }   
    
    
    
    public void updateSubsCounters()
    {
        subUploadSettings.Core_Update_Subordinates_Start__c = subUploadSettings.Core_Update_Subordinates_Start__c + updateSize;
        update subUploadSettings;
    }
    
    
    public void updateRoleHierarchyAccess()
    {
        List<UserRole> userRoleList = [SELECT Id, OpportunityAccessForAccountOwner, CaseAccessForAccountOwner
                                       FROM UserRole
                                       WHERE OpportunityAccessForAccountOwner = :READ_ACCESS
                                       AND Name NOT IN ('SMG', 'Admin')                                          
                                       LIMIT :ACCESS_UPDATE_SIZE];
        
        if (userRoleList.size() > 0)
        {                        
            for (UserRole userRole : userRoleList)
            {
                userRole.OpportunityAccessForAccountOwner = EDIT_ACCESS;
                userRole.CaseAccessForAccountOwner        = EDIT_ACCESS;
            }
            
            update userRoleList;                                                   
        }
    } 
}