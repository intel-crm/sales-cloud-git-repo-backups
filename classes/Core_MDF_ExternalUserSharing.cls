/****************************************************************************************************************************************
 * Class Name        : Core_MDF_ExternalUserSharing
 * Created Date      : 09-11-2019
 * Modification Log
 * Developer            Date               Description
 * ---------------------------------------------------------------------------------------------------------------------------------------
   Accenture - Jayesh   09/11/2019         It is batch class which shares User record with respective external group when
                                           they are active from inactive state
   Accenture - Varun    16/07/2020         Calling PNUM delete batch from finish
 *****************************************************************************************************************************************/
public without sharing class Core_MDF_ExternalUserSharing implements Database.Batchable<sObject>, Database.Stateful {

    public Map<Id, String> errorMap = new Map<Id, String>();
    public Map<Id, String> successMap = new Map<Id, String>();
    public Set<String> userOrGroupIdSet;
    public List<UserShare> userShareListToBeDeleted;
    public Integer counter;
    public Boolean forErrorRecordProcess = false;
    public List<Core_MDF_Partner_Node_User_Mapping__c> pnumListToBeUpdated = new List<Core_MDF_Partner_Node_User_Mapping__c>();
    public static Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    Set<Id> groupIds = new Set<Id>();
    
    Set<Id> groupIdForPnumDeleteCheck = new Set<Id>();    
    
    public Core_MDF_ExternalUserSharing(Boolean forErrorRecordProcess, Set<String> userOrGroupIdSet) {        
        this.forErrorRecordProcess = forErrorRecordProcess;
        if(userOrGroupIdSet != null) {
            this.userOrGroupIdSet = userOrGroupIdSet;
            counter = 1;
        } else {
            this.userOrGroupIdSet = new Set<String>();
            counter = 1; }

    }

    // Constructor when batch called from the Schedulable context
    public Core_MDF_ExternalUserSharing(Boolean forErrorRecordProcess, Set<String> userOrGroupIdSet, Integer counter) {        
        this.forErrorRecordProcess = forErrorRecordProcess;
        if(userOrGroupIdSet != null) {
            this.userOrGroupIdSet = userOrGroupIdSet;
            this.counter = counter;
        } else {
            this.userOrGroupIdSet = new Set<String>();
            this.counter = counter; }

    }

    public Core_MDF_ExternalUserSharing(Boolean forErrorRecordProcess, List<UserShare> userShareList) {
        this.forErrorRecordProcess = forErrorRecordProcess;
        if(userShareList != null) {
            this.userShareListToBeDeleted = userShareList;
            this.userOrGroupIdSet = new Set<String>();
            counter = 1;
        } else {
            this.userShareListToBeDeleted = new List<UserShare>();
            this.userOrGroupIdSet = new Set<String>();
            counter = 1; }

    }
    /*****************************************************************************************************
     Method Name :   start
     @return     :   List of partner group mapping object records
     @parameters :   Database.BatchableContext
     Description :   It fetches all object data of PGM for External Groups
     Added By    :   Accenture - JV
     Modified By :
     ******************************************************************************************************/

    public Database.QueryLocator start(Database.BatchableContext bc) {
        try{
            // Find ALl the External Group Id List
            for (Core_MDF_Partner_Group_Mapping__c pgm :[SELECT Id, Core_MDF_Account__c, Core_MDF_Account__r.RecordType.Name, 
                                                         Core_MDF_Group_Id__c, Core_MDF_Channel_Program__r.Name, Core_MDF_Type_of_Access__c 
                                                         FROM Core_MDF_Partner_Group_Mapping__c 
                                                         WHERE Core_MDF_Type_of_Access__c = 'External' and Core_MDF_Inactive_Ind__c = false]) {
                groupIds.add(pgm.Core_MDF_Group_Id__c);
                // contains external group ids from the group
            }
            String strQuery = '';
            if(forErrorRecordProcess && userOrGroupIdSet != null && !userOrGroupIdSet.isEmpty()) {
                strQuery = 'SELECT Id, groupId, group.Name, UserOrGroupId FROM GroupMember WHERE GroupId IN:groupIds AND UserOrGroupId IN: userOrGroupIdSet';
                //strQuery = 'SELECT Id, groupId, group.Name, UserOrGroupId FROM GroupMember WHERE UserOrGroupId IN:userOrGroupIdSet';
            } else {
                strQuery = 'SELECT Id, groupId, UserOrGroupId FROM GroupMember WHERE GroupId IN:groupIds';
            }

            return Database.getQueryLocator(strQuery);

        } catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e);
            return NULL; }
    }

    /********************************************************************************************************
     Method Name :   execute
     @return     :   void
     @parameters :   Database.BatchableContext,
     Description :   Creates a bank to user list map which is shared with respective banks
     Added By    :   Accenture - JV
     Modified By :
     **********************************************************************************************************/

    public void execute(Database.BatchableContext bc, List<GroupMember> scope) {


        try{
            Map<Id, List<Id>> userorgroupIdtoGroupIdListMap = new Map<Id, List<Id>>();
            Set<Id> inactiveUserIds = new Set<Id>();
            Map<Id, Boolean> userToActiveFlagMap = new Map<Id, Boolean>();
            List<Id> userIdsFromGroupMember = new List<Id>();            
            
            for(GroupMember gm :scope) {                
                userIdsFromGroupMember.add(gm.UserOrGroupId);
                groupIdForPnumDeleteCheck.add(gm.GroupId);
            }

            for(User u :[SELECT Id, IsActive FROM User WHERE ID IN :userIdsFromGroupMember]) {
                userToActiveFlagMap.put(u.Id, u.IsActive);
            }

            // Find all the group members belonging to the extrernal group id list
            for(GroupMember gm :scope) {

                // Prepare  Map the User – List<Group> Where User is Active & Set<User> where User = InActive
                if(String.valueOf(gm.UserOrGroupId).startsWith('00G') || (String.valueOf(gm.UserOrGroupId).startsWith('005') && userToActiveFlagMap.get(gm.UserOrGroupId))) {
                    if(userorgroupIdtoGroupIdListMap.containsKey(gm.UserOrGroupId)) {
                        userorgroupIdtoGroupIdListMap.get(gm.UserOrGroupId).add(gm.groupId);
                    } else {
                        userorgroupIdtoGroupIdListMap.put(gm.UserOrGroupId, new List<Id>{ gm.groupId });
                    }
                } else if(!userToActiveFlagMap.get(gm.UserOrGroupId)) {
                    inactiveUserIds.add(gm.UserOrGroupId); }
            }

            Map<Id, List<Id>> userIdToGroupIdListMap = new Map<Id, List<Id>>();
            //Find the Existing UserShare entries
            for(UserShare ushare :[SELECT Id, UserId, UserOrGroupId,UserOrGroup.Name FROM UserShare WHERE UserId IN :userorgroupIdtoGroupIdListMap.keySet()]) {
                if(userIdToGroupIdListMap.containsKey(ushare.userId)) {
                    userIdToGroupIdListMap.get(ushare.userId).add(ushare.UserOrGroupId);
                } else {
                    userIdToGroupIdListMap.put(ushare.userId, new List<Id>{ ushare.UserOrGroupId });
                }
            }

            // Create the Missing UserShare Entries
            List<Id> userIdList = new List<Id>();
            List<UserShare> userShareRecordsTobeCreated = new List<UserShare>();

            for(User u :[SELECT Id FROM User WHERE Id IN :userorgroupIdtoGroupIdListMap.keySet()]) {

                if(userIdToGroupIdListMap.containsKey(u.Id)) {
                    for(Id groupId :userorgroupIdtoGroupIdListMap.get(u.Id)) {
                        if(!userIdToGroupIdListMap.get(u.Id).contains(groupId)) {
                            userIdList.add(u.Id);
                            userShareRecordsTobeCreated.add(new UserShare(UserId = u.Id, UserOrGroupId = groupId, UserAccessLevel = 'Read', RowCause = Schema.UserShare.RowCause.Manual));
                        }
                    }
                }
            }
            //Delete all UserShare part of Set<User> wher Reason = Manual
            List<UserShare> ushareRecordsToBeDeleted = new List<UserShare>();
            for(UserShare usharetobedeleted :[SELECT ID, UserOrGroupId FROM UserShare WHERE(UserId IN :inactiveUserIds) AND UserOrGroupId IN :groupIds AND RowCause = :Schema.UserShare.RowCause.Manual LIMIT 10000]) {
                ushareRecordsToBeDeleted.add(usharetobedeleted);
            }
            if(ushareRecordsToBeDeleted != null && ushareRecordsToBeDeleted.size() > 0) {
                // Delete the user share records
                Database.DeleteResult [] drList = Database.delete(ushareRecordsToBeDeleted, false);
                Integer index = 0;
                // Iterate through each returned result
                for(Database.DeleteResult dr :drList) {
                    if(dr.isSuccess()) {
                        successMap.put(dr.getId(), 'Deleted');
                    } else {
                        String errMsg = dr.getErrors() [0].getMessage();
                        errorMap.put(ushareRecordsToBeDeleted [index].Id, errMsg);
                        userOrGroupIdSet.add(ushareRecordsToBeDeleted [index].UserOrGroupId);
                    }
                    index++;
                }
            }
            if(userShareRecordsTobeCreated != null && userShareRecordsTobeCreated.size() > 0) {
                // Insert the user share records
                Database.SaveResult [] srList = Database.insert(userShareRecordsTobeCreated, false);
                Integer index = 0;
                // Iterate through each returned result
                for(Database.SaveResult sr :srList) {
                    if(sr.isSuccess()) {
                        successMap.put(sr.getId(), 'Created');
                    } else {
                        errorMap.put(userShareRecordsTobeCreated [index].Id, sr.getErrors() [0].getMessage());
                        userOrGroupIdSet.add(userShareRecordsTobeCreated [index].UserOrGroupId);
                    }
                    index++;
                }
            }


            // Update the PNUM Entries
            if(userIdList != NULL && userIdList.size() > 0) {

                pnumListToBeUpdated  = [Select Id, Core_MDF_User__c, Core_MDF_Account__c
                                        FROM Core_MDF_Partner_Node_User_Mapping__c
                                        WHERE Core_MDF_User__c = :userIdList
                                        AND Core_MDF_User__r.IsActive = TRUE
                                       and Core_MDF_Active_Ind__c = true];

            }
        } catch(Exception e) {Core_MDF_CCP_UtilityClass.logError(e); }
    }

    /*****************************************************************************************************
     Method Name :   finish
     @return     :   void
     @parameters :   Database.BatchableContext
     Description :
     Added By    :   Accenture - JV
     Modified By :                        Date:09/17/2019                     Changes:None
     ******************************************************************************************************/
    public void finish(Database.BatchableContext bc) {

        try {
            Boolean pnumSwitch =false;
            if(mapFunctionalityNameTriggerExecution.containsKey('pnumUpdateIndicator') &&
            mapFunctionalityNameTriggerExecution.get('pnumUpdateIndicator').Core_Active__c){pnumSwitch = true;}
            
            // Update the relevant PNUM records
            if(pnumSwitch && pnumListToBeUpdated != NULL && pnumListToBeUpdated.size() > 0) {

             Database.SaveResult [] srList = Database.Update(pnumListToBeUpdated, false);
             Integer index = 0;
             // Iterate through each returned result
             for(Database.SaveResult sr :srList) {
             if(sr.isSuccess()) {
             successMap.put(sr.getId(), 'Updated');
             } else {
             errorMap.put(pnumListToBeUpdated [index].Id, sr.getErrors() [0].getMessage());
             userOrGroupIdSet.add(pnumListToBeUpdated [index].Core_MDF_User__c);
             }
             index++;
             }
             }            

            if(userShareListToBeDeleted != null && userShareListToBeDeleted.size() > 0) {
                // Delete the user share records
                Database.DeleteResult [] drList = Database.delete(userShareListToBeDeleted, false);
                Integer index = 0;
                // Iterate through each returned result
                for(Database.DeleteResult dr :drList) {
                    if(dr.isSuccess()) {
                        successMap.put(dr.getId(), 'Deleted');
                    } else {
                        String errMsg = dr.getErrors() [0].getMessage();
                        errorMap.put(userShareListToBeDeleted [index].Id, errMsg);
                        userOrGroupIdSet.add(userShareListToBeDeleted [index].UserOrGroupId);
                    }
                    index++;
                }
            }
            
            Boolean pnumDeleteSwitch =false;
            if(mapFunctionalityNameTriggerExecution.containsKey('callPnumDeleteBatch') &&
               mapFunctionalityNameTriggerExecution.get('callPnumDeleteBatch').Core_Active__c){pnumDeleteSwitch = true;}
            
            if(pnumDeleteSwitch && groupIdForPnumDeleteCheck != NULL && groupIdForPnumDeleteCheck.size() > 0) {
                Id batchInstanceId = Database.executeBatch(new Core_MDF_DeletePNUM_Batch(groupIdForPnumDeleteCheck));
            }
            
            
            Boolean retrySwitch =false;
            if(mapFunctionalityNameTriggerExecution.containsKey('externalUserSharingJobRetry') &&
            mapFunctionalityNameTriggerExecution.get('externalUserSharingJobRetry').Core_Active__c){retrySwitch = true;}
            
            //Retry Error Records And Send an email to the User after your batch completes
            if(!errorMap.isEmpty() && counter != 3) {
                if(retrySwitch){
                    // call Schedulable class starting from now till 3 hours
                    counter++;
                    Core_MDF_ExternalUserSharingSchedulable schedulableInstance = new Core_MDF_ExternalUserSharingSchedulable(userOrGroupIdSet, counter);
                    
                    Integer nextHour = (System.now().hour() +1) > 23 ? 23 : (System.now().hour() +1);
                        
                    //Seconds    Minutes    Hours    Day Of Month    Month    Day Of Week     Year
                    String timeOfExecution = 0 + ' ' + System.now().minute() + ' ' + nextHour + ' ' + System.now().day() + '-' + System.now().day() + ' ' + System.now().month() + '  ? ' + System.now().year();
                    
                    //Schedule job
                    String jobId = System.schedule('ExternalUserSharingJobRetry:' + System.now() + ':' + counter, timeOfExecution, schedulableInstance);
                }
                reportBatchErrorDetails(errorMap, bc);
                reportBatchSuccessDetails(successMap, bc);
            } else if(!successMap.isEmpty()) {
                reportBatchSuccessDetails(successMap, bc);
            }

        } catch(Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e); }
    }

    public void reportBatchErrorDetails(Map<Id, String> reportDetails, Database.BatchableContext bc) {

        //Send an email to the User after your batch completes
        if(!reportDetails.isEmpty()) {
            AsyncApexJob a = [SELECT id, ApexClassId, 
                              JobItemsProcessed, TotalJobItems, 
                              NumberOfErrors, CreatedBy.Email
                              FROM AsyncApexJob
                              WHERE id = :bc.getJobId()];
            String body = 'Your batch job '
            + 'ExternalUserSharingBatch '
            + 'has finished. \n'
            + 'There were '
            + reportDetails.size() + ' errors. Please find the error list attached to the Email.';

            // Creating the CSV file
            String finalstr = 'Id, Error \n';
            String subject = 'UserShare - Apex Batch Error List';
            String attName = 'UserShare Error.csv';
            for(Id id :reportDetails.keySet()) {
                string err = reportDetails.get(id);
                // SObject so = IdToSObjectMap.get(id);
                //string recordString = '"'+id+'","'+so.Name+'","'+err+'"\n';
                string recordString = '"' + id + '","' + err + '"\n';
                finalstr = finalstr + recordString;
            }



            // Define the email
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

            // Create the email attachment
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(attName);
            efa.setBody(Blob.valueOf(finalstr));

            // Sets the paramaters of the email
            email.setSubject(subject);
            email.setToAddresses(new String [] {
                                 Label.Core_MDF_CCP_Support_Email });
            email.setPlainTextBody(body);
            email.setFileAttachments(new Messaging.EmailFileAttachment [] {
                                     efa});
            email.setOrgWideEmailAddressId(Label.Core_MDF_OrgWideId);//17001

            // Sends the email
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage [] {
                                                                 email});
        }
    }
    public void reportBatchSuccessDetails(Map<Id, String> reportDetails, Database.BatchableContext bc) {

        //Send an email to the User after your batch completes
        if(!reportDetails.isEmpty()) {
            AsyncApexJob a = [SELECT id, ApexClassId, 
                              JobItemsProcessed, TotalJobItems, 
                              NumberOfErrors, CreatedBy.Email
                              FROM AsyncApexJob
                              WHERE id = :bc.getJobId()];
            String body = 'Your batch job '
            + 'ExternalUserSharingBatch '
            + 'has finished. \n'
            + 'There were '
            + reportDetails.size() + ' records sucessfully processed. Please find the success list attached to the Email.';

            // Creating the CSV file
            String finalstr = 'Id, Success \n';
            String subject = 'UserShare - Apex Batch Success List';
            String attName = 'UserShare Success.csv';
            for(Id id :reportDetails.keySet()) {
                string successmsg = reportDetails.get(id);
                string recordString = '"' + id + '","' + successmsg + '"\n';
                finalstr = finalstr + recordString;
            }
            // Define the email
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

            // Create the email attachment
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(attName);
            efa.setBody(Blob.valueOf(finalstr));

            // Sets the paramaters of the email
            email.setSubject(subject);
            email.setToAddresses(new String [] {
                                 Label.Core_MDF_CCP_Support_Email });
            email.setPlainTextBody(body);
            email.setFileAttachments(new Messaging.EmailFileAttachment [] {
                                     efa});
            email.setOrgWideEmailAddressId(Label.Core_MDF_OrgWideId);//17001

            // Sends the email
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage [] {
                                                                 email});
        }
    }    
}