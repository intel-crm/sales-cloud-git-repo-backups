/******************************************************************************************************************************
Apex Class Name:  Core_UserFieldChangeHistoryTracker
Version     : 1.0 
Created Date: 25 Jan 2019
Added By   :    Accenture - Raushan Singh
Function    : To track changes made on user fields and storing the log into Core_User_Field_Change_History__c object as a record for each changes 

Draco Change		28-09-2021				Added condition to check if the field exists in User Object before comparing with new and old values
Draco Change		08-12-2021				Added condition to exclude executing createUserFeedbackRecords method when system is already in queuable or batch state
*******************************************************************************************************************************/
public without sharing class Core_UserFieldChangeHistoryTracker {
    
	static string USER_ROLE_ID_STR = 'UserRoleId';
    static string Profile_Id_STR = 'ProfileId';
    static string Manager_Id_STR = 'ManagerId';
    static String Approver_Id_STR = 'DelegatedApproverId';
    static String System_Mod_Stamp_STR = 'SystemModstamp';
    static String Last_Modified_By_Id_STR = 'LastModifiedById';
    static String Last_Modified_Date_STR = 'LastModifiedDate';
    static String oldUserRoleId;
    static String newUserRoleId;
    static String oldProfileId;
    static String newProfileId;
    static String oldManagerId;
    static String newManagerId;
    static String oldDelegatedApproverId;
    static String newDelegatedApproverId;
	  /*
* Method name  : createFeed
* Description  : Handler method for logging history of user fields by creating one record in Core_User_Field_Change_History__c object
* Return Type  : VOID
* Parameters   : List<User>, List<User>, map<Id, User>, map<Id, User>
*/

    public static void createFeed(List<User> newUsers, List<User> oldUsers, Map<Id,User> oldUserMap, Map<Id,User> newUserMap){
        
        List<Core_User_Field_Change_History__c> ufields = new List<Core_User_Field_Change_History__c>();
        List<Core_User_Fields_For_Tracking__mdt> metaDataFields = new List<Core_User_Fields_For_Tracking__mdt>();
        
        // Querying Metadatafields fields which are active in the metadata.
        metaDataFields = [SELECT Core_User_Field_API_Name__c,Core_Active_Ind__c fROM Core_User_Fields_For_Tracking__mdt WHERE Core_Active_Ind__c=true];
        
        String fieldName;
        List<UserRole> newUserRoleNames = new List<UserRole>();
        List<UserRole> oldUserRoleNames = new List<UserRole>();
        List<Profile> newProfileNames = new List<Profile>();
        List<Profile> oldProfileNames = new List<Profile>();
        List<User> oldManagerNames = new List<User>();
        List<User> newManagerNames = new List<User>();
        List<User> oldDelegatedApproverNames = new List<User>();
        List<User> newDelegatedApproverNames = new List<User>();
        
        Map<Id,String> oldUserIdToRoleIdMap = new Map<Id,String>();
        Map<Id,String> newuserIdToRoleIdMap = new Map<Id,String>();
        Map<Id,String> oldUserIdToProfileMap = new Map<Id,String>();
        Map<Id,String> newUserIdToProfileMap = new Map<Id,String>();
        Map<Id,String> oldManagerIdToNameMap = new Map<Id,String>();
        Map<Id,String> newManagerIdToNameMap = new Map<Id,String>();
        Map<Id,String> oldDelegatedApproverIdToName = new Map<Id,String>();
        Map<Id,String> newDelegatedApproverIdToName = new Map<Id,String>();
        
       // Loop through all the users who have been modified
        for (User userDetails : newUsers) { 
            // Assigning UserId to oldUser and newUser list
            User oldUser = oldUserMap.get(userDetails.Id);
            User newUser = newUserMap.get(userDetails.Id);
            
            // loop through all trackable fields configured in the metadata
            for(Core_User_Fields_For_Tracking__mdt userField : metaDataFields ){
                fieldName = userField.Core_User_Field_API_Name__c;
                
                // Delegate per-field processing to a helper to reduce cognitive complexity
                processTrackedField(oldUser, newUser, fieldName, ufields,
                                    oldUserIdToRoleIdMap, newuserIdToRoleIdMap,
                                    oldUserIdToProfileMap, newUserIdToProfileMap,
                                    oldManagerIdToNameMap, newManagerIdToNameMap,
                                    oldDelegatedApproverIdToName, newDelegatedApproverIdToName);
            }
        } // end user loop / end users iteration
        
        //Updating roles details
        ufields = updateWithRoleDetails(newUserRoleNames , oldUserRoleNames, oldUserIdToRoleIdMap, newUserIdToRoleIdMap, ufields);
        
        //Updating Profile details
        ufields = updateWithProfileDetails(newProfileNames,oldProfileNames,oldUserIdToProfileMap,newUserIdToProfileMap, ufields);
        
        //Updating Manager details
        ufields = updateWithManagerDetails(newManagerNames,oldManagerNames,oldManagerIdToNameMap,newManagerIdToNameMap, ufields);
        
        //Updating approval details
        ufields = updateWithDelegatedApproverDetails(newDelegatedApproverNames,oldDelegatedApproverNames,oldDelegatedApproverIdToName,newDelegatedApproverIdToName, ufields);
        
        //Serializing ufields
        if(System.IsBatch() == false && System.isFuture() == false){ // Draco Change [08-12-2021]
            String serializableUfields =  json.serialize(ufields);
            createUserFeedbackRecords(serializableUfields);
        }
    }

    //Preparing Role Details with id and name
    private static List<Core_User_Field_Change_History__c> updateWithRoleDetails(List<UserRole> newUserRoleNames , List<UserRole> oldUserRoleNames,
                                                                   Map<Id,String> oldUserIdToRoleIdMap, Map<Id,String>  newUserIdToRoleIdMap 
                                                                                 ,List<Core_User_Field_Change_History__c> ufields){
        
        oldUserRoleNames = [SELECT Id,Name FROM UserRole WHERE Id in :oldUserIdToRoleIdMap.values()];
        newUserRoleNames = [SELECT Id,Name FROM UserRole WHERE Id in :newUserIdToRoleIdMap.values()]; 
        
        //Map of RoleIdToRoleName                                                                            
        Map<Id, String> roleIdToRoleNameMap = new Map<Id, String>();
        
        for(UserRole userRole : oldUserRoleNames){
            
            //Mapping old RoleId to RoleName
            roleIdToRoleNameMap.put(userRole.Id, userRole.Name);
        }
        
        for(UserRole userRole : newUserRoleNames){
            
            //Mapping old RoleId to RoleName
            roleIdToRoleNameMap.put(userRole.Id, userRole.Name);
        }
                                                                                     
       	// if map is non-empty role has been changed for some user record(s)
        for(Id userIdVal : oldUserIdToRoleIdMap.keySet()){ 
            
            Core_User_Field_Change_History__c userFieldTrackingFields = new Core_User_Field_Change_History__c();
            
            if(oldUserIdToRoleIdMap.get(userIdVal) != null)
            	userFieldTrackingFields.Core_Previous_Value__c = roleIdToRoleNameMap.get(oldUserIdToRoleIdMap.get(userIdVal))+'('+oldUserRoleId+')';
            if(newUserIdToRoleIdMap.get(userIdVal) != null)
            	userFieldTrackingFields.Core_Current_Value__c = roleIdToRoleNameMap.get(newUserIdToRoleIdMap.get(userIdVal))+'('+newUserRoleId+')';
            userFieldTrackingFields.Core_Modified_User_Field__c = USER_ROLE_ID_STR;
            userFieldTrackingFields.Core_Impacted_User__c = userIdVal;
            ufields.add(userFieldTrackingFields);
        }
        
        return ufields; 
        
    }
    //Preparing Profile Details with id and name
    private static List<Core_User_Field_Change_History__c> updateWithProfileDetails(List<Profile> newProfileNames , List<Profile> oldProfileNames,
                                                                   Map<Id,String> oldUserIdToProfileMap, Map<Id,String>  newUserIdToProfileMap
                                                                                   ,List<Core_User_Field_Change_History__c> ufields){
          oldProfileNames = [SELECT Id,Name FROM Profile WHERE Id in :oldUserIdToProfileMap.values()]; 
          newProfileNames = [SELECT Id,Name FROM Profile WHERE Id in :newUserIdToProfileMap.values()];
                                                                                       
          //Map of ProfileIdToProfileName
          Map<Id, String> profileIdToProfileNameMap = new Map<Id, String>();
          for(Profile profile : oldProfileNames){
            profileIdToProfileNameMap.put(profile.Id, profile.Name);
        }
        for(Profile profile : newProfileNames){
            profileIdToProfileNameMap.put(profile.Id, profile.Name);
        }
                                                                                       
        // if map is non-empty profile has been changed for some user record(s)
        for(Id profileIdVal : oldUserIdToProfileMap.keySet()){ 
            Core_User_Field_Change_History__c userFieldTrackingFields = new Core_User_Field_Change_History__c();
            if(oldUserIdToProfileMap.get(profileIdVal) != null)
            	userFieldTrackingFields.Core_Previous_Value__c = profileIdToProfileNameMap.get(oldUserIdToProfileMap.get(profileIdVal))+'('+oldProfileId+')';
            if(newUserIdToProfileMap.get(profileIdVal) != null)
            	userFieldTrackingFields.Core_Current_Value__c = profileIdToProfileNameMap.get(newUserIdToProfileMap.get(profileIdVal))+'('+newProfileId+')';
            userFieldTrackingFields.Core_Modified_User_Field__c = Profile_Id_STR;
            userFieldTrackingFields.Core_Impacted_User__c = profileIdVal;
            ufields.add(userFieldTrackingFields);
        }                                                               
                                                                       
         return ufields;           
                                                                       
    }
    //Preparing Manager Details with id and name
    private static List<Core_User_Field_Change_History__c> updateWithManagerDetails(List<User> newManagerNames , List<User> oldManagerNames,
                                                                                    Map<Id,String> oldManagerIdToNameMap, Map<Id,String>  newManagerIdToNameMap
                                                                                   ,List<Core_User_Field_Change_History__c> ufields){
           oldManagerNames = [SELECT Id,Name FROM User WHERE Id in :oldManagerIdToNameMap.values()];                                                                             
           newManagerNames = [SELECT Id,Name FROM User WHERE Id in :newManagerIdToNameMap.values()];
                                                                                       
           //Map Of ManagerIdToManagerName                                                                            
           Map<Id, String> managerIdToManagerNameMap = new Map<Id, String>(); 
           for(User manager : oldManagerNames){
            managerIdToManagerNameMap.put(manager.Id, manager.Name);
           }
           for(User manager : newManagerNames){
            managerIdToManagerNameMap.put(manager.Id, manager.Name);
        }
                                                                                       
			for(Id managerIdVal : oldManagerIdToNameMap.keySet()){
            Core_User_Field_Change_History__c userFieldTrackingFields = new Core_User_Field_Change_History__c();
            if(oldManagerIdToNameMap.get(managerIdVal) != null)
            	userFieldTrackingFields.Core_Previous_Value__c = managerIdToManagerNameMap.get(oldManagerIdToNameMap.get(managerIdVal))+'('+oldManagerId+')';
                
            if(newManagerIdToNameMap.get(managerIdVal) != null)
            	userFieldTrackingFields.Core_Current_Value__c = managerIdToManagerNameMap.get(newManagerIdToNameMap.get(managerIdVal))+'('+newManagerId+')';
            userFieldTrackingFields.Core_Modified_User_Field__c = Manager_Id_STR;
            userFieldTrackingFields.Core_Impacted_User__c = managerIdVal;
            ufields.add(userFieldTrackingFields);
        }                                                                                      
         return ufields;                                                                               
       }
    //Preparing DelegatedApprover Details with id and name
    private static List<Core_User_Field_Change_History__c> updateWithDelegatedApproverDetails(List<User> newDelegatedApproverNames , List<User> oldDelegatedApproverNames,
                                                                                    Map<Id,String> oldDelegatedApproverIdToName, Map<Id,String>  newDelegatedApproverIdToName
                                                                                             ,List<Core_User_Field_Change_History__c> ufields){
           oldDelegatedApproverNames = [SELECT Id,Name FROM User WHERE Id in :oldDelegatedApproverIdToName.values()];                                                                          
           newDelegatedApproverNames = [SELECT Id,Name FROM User WHERE Id in :newDelegatedApproverIdToName.values()];
                                                                                                 
           //Map Of ApproverIdToApproverName                                                                                     
           Map<Id, String> approverIdToApproverNameMap = new Map<Id, String>();
                                                                                                 
           for(User approver : oldDelegatedApproverNames){
            approverIdToApproverNameMap.put(approver.Id, approver.Name);
           }
           for(User approver : newDelegatedApproverNames){
                approverIdToApproverNameMap.put(approver.Id, approver.Name);
        }
                                                                                                 
        //if map is non-empty and delegated approval has been changed for some user record(s)                                                                                
        for(Id approverIdVal : oldDelegatedApproverIdToName.keySet()){ 
            Core_User_Field_Change_History__c userFieldTrackingFields = new Core_User_Field_Change_History__c();
            if(oldDelegatedApproverIdToName.get(approverIdVal) != null)
            	userFieldTrackingFields.Core_Previous_Value__c = approverIdToApproverNameMap.get(oldDelegatedApproverIdToName.get(approverIdVal))+'('+oldDelegatedApproverId+')';           
            if(newDelegatedApproverIdToName.get(approverIdVal) != null)
            	userFieldTrackingFields.Core_Current_Value__c = approverIdToApproverNameMap.get(newDelegatedApproverIdToName.get(approverIdVal))+'('+newDelegatedApproverId+')';
            userFieldTrackingFields.Core_Modified_User_Field__c = Approver_Id_STR;
            userFieldTrackingFields.Core_Impacted_User__c = approverIdVal;
            ufields.add(userFieldTrackingFields);
        }                                                                                      
         return ufields;                                                                               
       }

    /*
     	Performing the dml operations in future method
    */
    @future()
    private static void createUserFeedbackRecords(String strJSON){
        try{
            List<Core_User_Field_Change_History__c> userFieldsForUpdate = (List<Core_User_Field_Change_History__c>) json.deserialize(strJSON, List<Core_User_Field_Change_History__c >.class);
            // Use Database.insert with allOrNone=false to capture per-record failures and log them
            Database.SaveResult[] srResults = Database.insert(userFieldsForUpdate, false);
            // Log any failures
            for (Database.SaveResult sr : srResults) {
                if (!sr.isSuccess()) {
                    for (Database.Error err : sr.getErrors()) {
                        Core_Log_Entry__c excepLog = new Core_Log_Entry__c(
                            Core_Message__c = err.getMessage(),
                            Core_Origin__c = 'createUserFeedbackRecords',
                            Core_Project__c = 'Core_UserFieldChangeHistoryTracker',
                            Core_Details__c = 'Error while creating User Feedback Records',
                            Core_Severity__c = 'error',
                            Core_When__c = System.Now()
                        );     
                        insert excepLog;
                    }
                }
            }
        }catch(Exception e){
            Core_Log_Entry__c excepLog = new Core_Log_Entry__c(Core_Message__c = e.getMessage(), Core_Origin__c = 'createUserFeedbackRecords', Core_Project__c = 'Core_UserFieldChangeHistoryTracker', Core_Details__c = 'Error while creating User Feedback Records', Core_Severity__c = 'error', Core_When__c = System.Now());     
            insert excepLog;
        }
    }
    
    // Helper to process an individual tracked field change. Extracted to reduce cognitive complexity.
    private static void processTrackedField(User oldUser, User newUser, String fieldName,
                                            List<Core_User_Field_Change_History__c> ufields,
                                            Map<Id,String> oldUserIdToRoleIdMap, Map<Id,String> newuserIdToRoleIdMap,
                                            Map<Id,String> oldUserIdToProfileMap, Map<Id,String> newUserIdToProfileMap,
                                            Map<Id,String> oldManagerIdToNameMap, Map<Id,String> newManagerIdToNameMap,
                                            Map<Id,String> oldDelegatedApproverIdToName, Map<Id,String> newDelegatedApproverIdToName) {
        // Comparing if the value in oldMap and newMap is not equal and field exists
        Boolean ifFieldExists = newUser.getSobjectType().getDescribe().fields.getMap().keySet().contains(fieldName.toLowercase());
        if (ifFieldExists == true &&
            (newUser.get(fieldName) != oldUser.get(fieldName)
             && !fieldName.equalsIgnoreCase(Last_Modified_By_Id_STR)
             && !fieldName.equalsIgnoreCase(Last_Modified_Date_STR)
             && !fieldName.equalsIgnoreCase(System_Mod_Stamp_STR))) {
            
            //When UserRole has changed 
            if(fieldName.contains(USER_ROLE_ID_STR)){ 
                String newUserRoleIdLocal = String.valueOf(newUser.get(fieldName));
                newuserIdToRoleIdMap.put((Id)newUser.get('Id') , newUserRoleIdLocal);
                String oldUserRoleIdLocal = String.valueOf(oldUser.get(fieldName));
                oldUserIdToRoleIdMap.put((Id)oldUser.get('Id') , oldUserRoleIdLocal);
                
            //When Profile has been changed 
            } else if(fieldName.contains(Profile_Id_STR)){
                String newProfileIdLocal = String.valueOf(newUser.get(fieldName));
                newUserIdToProfileMap.put((Id)newUser.get('Id') , newProfileIdLocal);
                String oldProfileIdLocal = String.valueOf(oldUser.get(fieldName));
                oldUserIdToProfileMap.put((Id)oldUser.get('Id') , oldProfileIdLocal);
                
            //When Manager gets Changed
            } else if(fieldName.contains(Manager_Id_STR)){
                String newManagerIdLocal = String.valueOf(newUser.get(fieldName));
                newManagerIdToNameMap.put((Id)newUser.get('Id') , newManagerIdLocal);
                String oldManagerIdLocal = String.valueOf(oldUser.get(fieldName));
                oldManagerIdToNameMap.put((Id)oldUser.get('Id') , oldManagerIdLocal); 
                
            //When delegated Approver changed 
            } else if(fieldName.contains(Approver_Id_STR)){
                String newDelegatedApproverIdLocal = String.valueOf(newUser.get(fieldName));
                newDelegatedApproverIdToName.put((Id)newUser.get('Id') , newDelegatedApproverIdLocal);
                String oldDelegatedApproverIdLocal = String.valueOf(oldUser.get(fieldName));
                oldDelegatedApproverIdToName.put((Id)oldUser.get('Id') , oldDelegatedApproverIdLocal); 
                
            // When Changes made on other userfields which are metadata 
            } else {
                Core_User_Field_Change_History__c userFieldTrackingFields = new Core_User_Field_Change_History__c();
                userFieldTrackingFields.Core_Modified_User_Field__c = fieldName;
                userFieldTrackingFields.Core_Current_Value__c = String.valueOf(newUser.get(fieldName));
                userFieldTrackingFields.Core_Previous_Value__c = String.valueOf(oldUser.get(fieldName));
                userFieldTrackingFields.Core_Impacted_User__c = (Id) oldUser.get('Id');
                ufields.add(userFieldTrackingFields);
            }
        }
    }
}