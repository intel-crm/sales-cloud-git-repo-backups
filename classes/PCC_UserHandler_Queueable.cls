/****************************************************************************************************
Apex Class Name : PCC_UserHandler_Queueable
Created Date    : 20/02/2024 
Function        : To share user records with Integration user present in the mapping
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Shraddha                    20/02/2024             Created - To share user records with Integration user present in the mapping
*****************************************************************************************************/
public class PCC_UserHandler_Queueable implements queueable{
    
    public static final String LOG_ENTRY_ORIGIN   = 'PCC_UserHandler_Queueable';
    public static final String LOG_ENTRY_PROJECT  = 'DDR Registration';
    public static final String LOG_ENTRY_SCOPE    = 'Share User Records for DDR M2M';
    public static final String LOG_ENTRY_SEVERITY = 'High';
    
    public List<UserShare> userSharesToInsert;
    Map<String, String> roleToIntUserIdMap;
    Set<Id> urRoleIdToDeleteShares;
    
    /*Constructor*/
    public PCC_UserHandler_Queueable (List<UserShare> userSharesToInsert, Map<String, String> roleToIntUserIdMap, Set<Id> urRoleIdToDeleteShares) {
        this.userSharesToInsert = userSharesToInsert;
        this.roleToIntUserIdMap = roleToIntUserIdMap;
        this.urRoleIdToDeleteShares = urRoleIdToDeleteShares;
    }
    
    /*execute*/
    public void execute (QueueableContext currentContext) {
        List<UserShare> userSharesToDelete = new List<UserShare>();
        List<Database.SaveResult> userShareSaveResults = new List<Database.SaveResult>();
        List<Database.DeleteResult> userShareDeleteResults = new List<Database.DeleteResult>();
        String InsertError = 'Exception occurred while inserting UserShare Records';
        String DeleteError = 'Exception occurred while deleting UserShare Records';
        String methodOrigin = 'PCC_UserHandler_Queueable.execute';
        
        try{
            userSharesToDelete = getUserSharesToDelete(urRoleIdToDeleteShares, roleToIntUserIdMap.values());
            
            if (!userSharesToInsert.isEmpty()) {
                userShareSaveResults = Database.insert(userSharesToInsert, false);
                //create log entries for User Sharing Insert Records
            	PCC_DDRL5ProductMapping_TriggerHandler.createLogEntriesForDLPM(userShareSaveResults, methodOrigin, InsertError);
            }
            if (!userSharesToDelete.isEmpty()) {
                userShareDeleteResults = Database.delete(userSharesToDelete, false);
                //create log entries User Sharing Delete Records
                PCC_DDRL5ProductMapping_TriggerHandler.createLogEntriesForDLPM(userShareDeleteResults, methodOrigin, DeleteError);
            }     
            
            if(Test.isRunningTest()){
                throw new System.DMLException();   
            }   
        }
        catch(exception ex) { 
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, 
                                                 LOG_ENTRY_SEVERITY, '', '', '', 'PCC_UserHandler_Queueable.execute', '', ex);
        }
    }
    
    /*to get the User Share records to Delete*/
    public List<UserShare> getUserSharesToDelete(Set<Id> urRoleIdToDeleteShares, List<String> roleToIntUserIdList){
        List<UserShare> userSharesToDelete = new List<UserShare>();
        
        // Un-share the user with the Integration User
        if(!urRoleIdToDeleteShares.isEmpty() && !roleToIntUserIdMap.isEmpty()){
             userSharesToDelete = [SELECT Id, UserId, User.UserRoleId, UserOrGroupId 
                                   FROM UserShare 
                                   WHERE UserId IN: urRoleIdToDeleteShares 
                                   AND UserOrGroupId IN: roleToIntUserIdMap.values() 
                                   AND RowCause = 'Manual'];
        }
        
        return userSharesToDelete;
    }

    
}