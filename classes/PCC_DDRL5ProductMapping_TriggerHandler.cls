/***********************************************************************************************************************************************
Apex Class Name:  PCC_DDRL5ProductMapping_TriggerHandler
Created Date: 21 Aug 2023
Function    : Trigger Handler for the PCC_DDRL5ProductMapping_Trigger

Modification Log :
* Developer                     Date                Description                                             TestClass
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Shraddha More                 21/08/2023         Trigger Handler of PCC_DDRL5ProductMapping_Trigger       PCC_DDRL5ProductMapping_TH_Test
* Shivini                       30-sep-2024         Added WITH USER_MODE to SOQL and DML statements.
*************************************************************************************************************************************************/

public without sharing class PCC_DDRL5ProductMapping_TriggerHandler extends TriggerHandler{
    public static final String ORIGIN = 'PCC_DDRL5ProductMapping_TriggerHandler';
    public static final String SEVERITY = 'Critical';
    public static final String PROJECT = 'PCC';  
    public static final string SCOPE = 'Medium';
    
    public override void afterInsert(){
        List<PCC_DDR_L5_Product_Mapping__c> DDRL5List = (List<PCC_DDR_L5_Product_Mapping__c>) Trigger.new;
        Boolean triggerExecution = [SELECT Active__c 
                                    FROM Trigger_Execution__mdt 
                                    WHERE MasterLabel ='PCC_DDR_L5_Product_Mapping_Trigger' Limit 1].Active__c;
        if(triggerExecution){
            ShareDDRL5ProductAttributes(DDRL5List);
        }
    }
  
    
    /*****************************************************************************************************************
* Method Name: ShareDDRL5ProductAttributes
* Date: 21/08/2023    
* Owner: Shraddha
* Description: This is a method to share DDR L5 mapping records based on corresponding DDR sharing
******************************************************************************************************************/
    Public Static void ShareDDRL5ProductAttributes(List<PCC_DDR_L5_Product_Mapping__c> DDRL5List){
        Set<Id> ddrIds = new Set<Id>();
        String methodOrigin = 'PCC_DDRL5ProductMapping_TriggerHandler.ShareDDRL5ProductAttributes';
        
        try{
            //collect all designRegistration Ids
            if(!DDRL5List.isEmpty() && DDRL5List != null){
                for(PCC_DDR_L5_Product_Mapping__c dlpm : DDRL5List){
                    ddrIds.add(dlpm.PCC_Design_Registration__c);
                }
            }
            
            //share DDR L5 mapping records based on corresponding DDR sharing
            if(!ddrIds.isEmpty() && ddrIds != null){
                DDRL5MappingsSharing(ddrIds);
            }
            
        }catch (Exception ex){ Core_Log_Entry.logEntryWithException(ORIGIN, PROJECT, SCOPE, SEVERITY,'', '' ,'' , methodOrigin ,'' ,ex); 
        }
    }
    

    
    
    /*****************************************************************************************************************
* Method Name: DDRL5MappingsSharing
* Date: 21/08/2023    
* Owner: Shraddha
* Description: This is a method to share DDR L5 mapping records based on corresponding DDR sharing
******************************************************************************************************************/
    @future
    Public Static void DDRL5MappingsSharing(Set<Id> ddrIds){
        List<Database.SaveResult> ddrL5InsertResults = new List<Database.SaveResult>();
        List<Database.DeleteResult> ddrL5DeleteResults = new List<Database.DeleteResult>();
        String InsertError = 'Exception occurred while inserting PCC_DDR_L5_Product_Mapping__Share Records';
        String DeleteError = 'Exception occurred while deleting PCC_DDR_L5_Product_Mapping__Share Records';
        String methodOrigin = 'PCC_DDRL5ProductMapping_TriggerHandler.ShareDDRL5ProductAttributes';
        Map<Id, Set<Id>> mapOfDDRIdtoUserOrGroupIdSet = new Map<Id, Set<Id>>();
        Set<Id> ddrL5Ids = new Set<Id>();
        List<PCC_DDR_L5_Product_Mapping__c> DDRL5List = new List<PCC_DDR_L5_Product_Mapping__c>();
        List<String> keysToRemove = new List<String>();
		Map<String, PCC_DDR_L5_Product_Mapping__Share> mapOfIdToDlpmShareToDelete = new Map<String, PCC_DDR_L5_Product_Mapping__Share>();
        Map<String, PCC_DDR_L5_Product_Mapping__Share> mapOfIdToDlpmShareToInsert = new Map<String, PCC_DDR_L5_Product_Mapping__Share>();
        
        try{
            if(!ddrIds.isEmpty() && ddrIds!= null){
                //get list of PCC_DDR_L5_Product_Mapping__c records where we are using updated DDR Ids 
                DDRL5List = [SELECT id, PCC_Design_Registration__c FROM PCC_DDR_L5_Product_Mapping__c WHERE PCC_Design_Registration__c In : ddrIds WITH USER_MODE];
                //collect PCC_DDR_L5_Product_Mapping__c Ids
                for(PCC_DDR_L5_Product_Mapping__c dlpm : DDRL5List){
                    ddrL5Ids.add(dlpm.Id);
                }
                
                //creating map of ddrId to all the groups and users who have access to DDR
                for(Core_Design_Registration__Share dmlShare : [SELECT Id, ParentId, UserOrGroupId, AccessLevel, UserOrGroup.Name, RowCause 
                                                                FROM Core_Design_Registration__Share 
                                                                WHERE ParentId IN : ddrIds]
                   ){
                       if(mapOfDDRIdtoUserOrGroupIdSet.containsKey(dmlShare.ParentId)){
                           mapOfDDRIdtoUserOrGroupIdSet.get(dmlShare.ParentId).add(dmlShare.UserOrGroupId);
                       }else{
                           mapOfDDRIdtoUserOrGroupIdSet.put(dmlShare.ParentId, new Set<Id>{dmlShare.UserOrGroupId});
                       }
                   }
                
            }
            
            System.debug('mapOfDDRIdtoUserOrGroupIdSet-->'+mapOfDDRIdtoUserOrGroupIdSet);
            
            //fetching list of old PCC_DDR_L5_Product_Mapping__Share records to delete
            for(PCC_DDR_L5_Product_Mapping__Share dlpmShare : [SELECT id, AccessLevel, ParentId, RowCause, UserOrGroupId, UserOrGroup.name 
                                                              FROM PCC_DDR_L5_Product_Mapping__Share 
                                                              WHERE ParentId IN : ddrL5Ids
                                                               AND RowCause = 'Manual']
               ){
                   mapOfIdToDlpmShareToDelete.put((String)dlpmShare.UserOrGroupId + (String)dlpmShare.ParentId, dlpmShare);
               }
            
            //share PCC_DDR_L5_Product_Mapping__c record based on DDR access
            for(PCC_DDR_L5_Product_Mapping__c dlpm : DDRL5List){
                if(mapOfDDRIdtoUserOrGroupIdSet.containsKey(dlpm.PCC_Design_Registration__c)){
                    for(Id UserOrGroupId : mapOfDDRIdtoUserOrGroupIdSet.get(dlpm.PCC_Design_Registration__c)
                       ){
                           PCC_DDR_L5_Product_Mapping__Share dlpmShare = new PCC_DDR_L5_Product_Mapping__Share();
                           dlpmShare.ParentId = dlpm.Id;
                           dlpmShare.UserOrGroupId = UserOrGroupId;
                           dlpmShare.AccessLevel = 'Edit';
                           dlpmShare.RowCause = 'Manual';
                           mapOfIdToDlpmShareToInsert.put((String)UserOrGroupId + (String)dlpm.Id, dlpmShare);
                       }
                }
            }
                        
            // Identify keys to remove
            for (String uniqueKey : mapOfIdToDlpmShareToInsert.keySet()) {
                if (mapOfIdToDlpmShareToDelete.containsKey(uniqueKey)) {
                    keysToRemove.add(uniqueKey);
                }
            }
            
            // Remove identified keys from both maps
            for (String key : keysToRemove) {
                mapOfIdToDlpmShareToDelete.remove(key);
                mapOfIdToDlpmShareToInsert.remove(key);
            }
            
            System.debug('mapOfIdToDlpmShareToDelete.values()-->'+mapOfIdToDlpmShareToDelete.values());
            //Delete listOfDLPMSharingToDelete
            if(!mapOfIdToDlpmShareToDelete.isEmpty() && mapOfIdToDlpmShareToDelete != null){
                ddrL5DeleteResults = Database.Delete(mapOfIdToDlpmShareToDelete.values(), false);
            }
                        
            //create log entries for DLPM
            createLogEntriesForDLPM(ddrL5DeleteResults, methodOrigin, DeleteError);
            
           // System.debug('mapOfIdToDlpmShareToInsert.values()-->'+JSON.serialize(mapOfIdToDlpmShareToInsert.values()));
            //Insert ddrL5shareListToInsert
            if(!mapOfIdToDlpmShareToInsert.isEmpty() && mapOfIdToDlpmShareToInsert != null){
                ddrL5InsertResults = Database.Insert(mapOfIdToDlpmShareToInsert.values(), false); // DINESH UNCOMMENTED as part of Defect fix
            }
            
            //create log entries for DLPM
            createLogEntriesForDLPM(ddrL5InsertResults, methodOrigin, InsertError);
            
        }catch (Exception ex){ Core_Log_Entry.logEntryWithException(ORIGIN, PROJECT, SCOPE, SEVERITY,'', '' ,'' , methodOrigin ,'' ,ex); 
        }
        
        
    }
    
    /*****************************************************************************************************************
* Method Name: createLogEntriesForDLPM
* Date: 21/08/2023    
* Owner: Shraddha
* Description: This is a method to create log entries for DLPM
******************************************************************************************************************/
    Public Static void createLogEntriesForDLPM(List<Database.SaveResult> ddrL5SaveResults, String methodOrigin, String ErrorMsg){
        String strDetailsAndEx;
        List<Core_Log_Entry__c> listOfLogEntries = new List<Core_Log_Entry__c>();
        
        //create seperate log entries
        for (Database.SaveResult sr : ddrL5SaveResults) {
            if (!sr.isSuccess() || Test.isRunningTest()) {
                // create the log entry for failed record
                for (Database.Error err : sr.getErrors()){
                    strDetailsAndEx = '';
                    if( sr.getErrors() != null ){ strDetailsAndEx += 'Message: ' + err.getMessage() + '\n'; strDetailsAndEx += 'Fields: ' + err.Fields.toString() + '\n'; strDetailsAndEx += 'StatusCode: ' + err.getStatusCode() + '\n';
                    }
                }
                
                listOfLogEntries.add(new Core_Log_Entry__c(Core_Message__c = ErrorMsg, Core_Origin__c = methodOrigin, Core_Details__c = strDetailsAndEx,
                                                           Core_Severity__c = SEVERITY, Core_When__c = System.Now(), Core_Project__c = PROJECT, 
                                                           Core_sObjectId__c = sr.getId()));
            }
        }
        
        // insert a log entry for the failed record
        if(!listOfLogEntries.isEmpty() && listOfLogEntries !=null){
            Core_Log_Entry.createLogEntries(listOfLogEntries);
        }
    }
    
    /*****************************************************************************************************************
* Method Name: createLogEntriesForDLPM
* Date: 21/08/2023    
* Owner: Shraddha
* Description: This is a method to create log entries for DLPM
******************************************************************************************************************/
    Public Static void createLogEntriesForDLPM(List<Database.DeleteResult> ddrL5DeleteResults, String methodOrigin, String ErrorMsg){
        String strDetailsAndEx;
        List<Core_Log_Entry__c> listOfLogEntries = new List<Core_Log_Entry__c>();
        
        //create seperate log entries
        for (Database.DeleteResult sr : ddrL5DeleteResults) {
            if (!sr.isSuccess() || Test.isRunningTest()) {
                // create the log entry for failed record
                for (Database.Error err : sr.getErrors()){
                    strDetailsAndEx = '';
                    if( sr.getErrors() != null ){ strDetailsAndEx += 'Message: ' + err.getMessage() + '\n'; strDetailsAndEx += 'Fields: ' + err.Fields.toString() + '\n';  strDetailsAndEx += 'StatusCode: ' + err.getStatusCode() + '\n';
                    }
                }
                
                listOfLogEntries.add(new Core_Log_Entry__c(Core_Message__c = ErrorMsg, Core_Origin__c = methodOrigin, Core_Details__c = strDetailsAndEx,
                                                           Core_Severity__c = SEVERITY, Core_When__c = System.Now(), Core_Project__c = PROJECT, 
                                                           Core_sObjectId__c = sr.getId()));
            }
        }
        
        // insert a log entry for the failed record
        if(!listOfLogEntries.isEmpty() && listOfLogEntries !=null){
            Core_Log_Entry.createLogEntries(listOfLogEntries);
        }
    }
    
/*****************************************************************************************************************
* Method Name: checkDDRPS
* Date: 4/02/2025    
* Owner: Manasa
* Description: This is a method to used to check if the user selected on screen by the Approver user , (chnage Approver button) has ddr ps and also return email id of the user.
******************************************************************************************************************/
     public class AssigneeDetails {
    @InvocableVariable
    public Id assigneeId;  
    @InvocableVariable
    public String email;
}
    private static final Map<String, String> regionToGroupMap = new Map<String, String> {
        'APJ' => 'Core_DDR_Access_APJ',
        'EMEA' => 'Core_DDR_Access_EMEA',
        'PRC' => 'Core_DDR_Access_PRC',
        'ASMO' =>'Core_DDR_Access_ASMO'
    };
        
        
@InvocableMethod(label='Check DDR Permission Set' description='Check if the user has the DDR Permission Set assigned')
public static List<AssigneeDetails> checkDDRPS(List<Id> userIds) {
    List<AssigneeDetails> result = new List<AssigneeDetails>();
    
    try {
        List<User> userList = [SELECT Id, Core_User_Geo__c, Email FROM User WHERE Id = :userIds[0] limit 1];
        if(!userList.isempty()){
            assignPG(userList[0].Id,userList[0].Core_User_Geo__c); 
            AssigneeDetails details = new AssigneeDetails();
            details.assigneeId = userList[0].Id;
            details.email = userList[0].Email;            
            result.add(details);
        }         
    } catch (Exception ex) { Core_Log_Entry.logEntryWithException(ORIGIN, PROJECT, SCOPE, SEVERITY, '', '', '', 'checkDDRPS', '', ex);
    }   
    return result; 
}

@future
public static void assignPG(Id userId,string UserRegion) {
    List<SObject> pgpsInsertResults = new List<SObject>();
     List<Database.SaveResult> insertResults = new List<Database.SaveResult>();
    try{
         if (userId != null && !String.isBlank(UserRegion)) {
        String correctGroupName = regionToGroupMap.get(UserRegion);
        List<GroupMember> existingGroups = [SELECT Id, Group.DeveloperName FROM GroupMember WHERE UserOrGroupId = :userId];
        Set<String> existingGroupNames = new Set<String>();       
        for (GroupMember gm : existingGroups) {
            existingGroupNames.add(gm.Group.DeveloperName);
        }
        Group groupe = [SELECT Id FROM Group WHERE DeveloperName = :correctGroupName LIMIT 1];

        if (existingGroupNames.isEmpty() || (!existingGroupNames.isempty() && !existingGroupNames.contains('Core_DDR_Access_WW') && !existingGroupNames.contains(correctGroupName))) {
            GroupMember gm = new GroupMember(UserOrGroupId = userId, GroupId = groupe.Id);
            //Database.SaveResult insertPG = Database.insert(gm,false);
            pgpsInsertResults.add(gm);
        }
    }
        List<PermissionSetAssignment> DDRPS = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSet.Label = 'DDR Internal Users' AND AssigneeId = :userId LIMIT 1];  
        if (DDRPS.isEmpty()) {
            PermissionSet ddrPermissionSet = [SELECT Id FROM PermissionSet WHERE Label = 'DDR Internal Users' LIMIT 1];
            PermissionSetAssignment newPermSetAssignment = new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = ddrPermissionSet.Id);
            //Database.SaveResult insertPS = Database.insert(newPermSetAssignment,false);
            pgpsInsertResults.add(newPermSetAssignment);
        }
    if (!pgpsInsertResults.isEmpty()) {
        insertResults = Database.insert(pgpsInsertResults, false);
    }
    createLogEntriesForDLPM(insertResults, 'PCC_DDRL5ProductMapping_TriggerHandler.assignPG', 'Error in assignment of DDR PG&PS');    
    }catch(Exception ex){Core_Log_Entry.logEntryWithException(ORIGIN, PROJECT, SCOPE, SEVERITY, '', '', '', 'assignPG', '', ex);} 
}
    
}