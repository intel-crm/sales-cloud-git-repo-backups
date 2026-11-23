/****************************************************************************************************************************************
* Class Name        : Core_MDF_PIC_Completion_NotifyBatch
* Test Class Name   : Core_MDF_PIC_Completion_NotifyBatch_Test
* Created Date      : 02/12/2023
* Description       : To Notify Intel Owner on Pic Completion and CCF/DCF Claim Submitter on Pic Pass
* Developer         : Keerthi
* Updated                        : Date                                developer                                      description
                                                                          01/03/2024                   Aditya                                Updated Finish method to call Core_MDF_Email_NotificationLoggingBatch for sending email and logging
*****************************************************************************************************************************************/
public without sharing class Core_MDF_PIC_Completion_NotifyBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    Public static List<string> Intel_Owner_Based_Notification_Prog = Core_MDF_CCP_ConstantClass.Intel_Owner_Based_Notification_Prog;
    Public static List<string> IUPGM_Based_Notification_Prog =Core_MDF_CCP_ConstantClass.IUPGM_Based_Notification_Prog ;
    Public static List<String>  Notification_Enabled_Program = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PIC_Completion_Notification').split(',');  
    
    Set<Id> internalUserIds = new Set<Id>();
    Set<Id> externalUserIds = new Set<Id>();
    Public string cancelledStatus = Core_MDF_CCP_ConstantClass.CANCELLED_STATUS;
    Public string DAYS_FILTER = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PIC_Completion_Notify_Days');              
    public Database.Querylocator start(Database.BatchableContext bc) {
        String query ='SELECT Id,Core_MDF_Claim_ID_id__c, Core_MDF_Review_Date_dt__c,Core_MDF_Claim_ID_id__r.Core_MDF_Status__c,Core_MDF_EndTime_dtm__c,'+
            'Core_MDF_Claim_ID_id__r.Request.Core_MDF_Intel_Activity_Owner_Id__c,Core_MDF_Claim_ID_id__r.Request.Core_MDF_Primary_Intel_Owner_Id__c,Core_MDF_Claim_ID_id__r.Request.Core_MDF_Primary_Intel_Owner_Id__r.IsActive,Core_MDF_Claim_ID_id__r.Core_MDF_Program__c,Core_MDF_Claim_ID_id__r.Core_MDF_Ultimate_Account_ID__c,'+
            'Core_MDF_Claim_ID_id__r.Request.Core_MDF_Program__c,Core_MDF_Claim_ID_id__r.ChannelPartnerId,Core_MDF_Claim_ID_id__r.Core_MDF_Budget_Type_Nm__c,'+
            'Core_MDF_Claim_ID_id__r.Core_MDF_PIC_Review_Completed__c,Core_MDF_Claim_ID_id__r.Request.Core_MDF_Intel_Activity_Owner_Id__r.IsActive,Core_MDF_Claim_ID_id__r.Request.ChannelPartnerId, '+
            'Core_MDF_Claim_ID_id__r.Request.Core_MDF_Intel_Activity_Owner_Id__r.Partner_License_Reclaimed__c,Core_MDF_Claim_ID_id__r.Request.Core_MDF_Primary_Intel_Owner_Id__r.Partner_License_Reclaimed__c ' +
            'FROM Core_MDF_PIC_Review__c '+
            'WHERE Core_MDF_Claim_ID_id__r.Core_MDF_Status__c !=:cancelledStatus '+
            'AND Core_MDF_Claim_ID_id__r.Request.Core_MDF_Program__c IN:Notification_Enabled_Program '+ ' AND Core_MDF_AI_PIC_Review_Ind__c = false '+
            'AND '+DAYS_FILTER ;
        return Database.getQueryLocator(query);
        
    }
    /*Execute Method*/
    Public void execute(Database.BatchableContext bc,List<Core_MDF_PIC_Review__c> picReviewData) {
        Set<Id> intelOwnerSet= new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        Set<String> progSetInt = new Set<String>();
        Set<String> progSetExt = new Set<String>();
        Set<string> progBudgetTypeKeySet = new Set<string>();
        Set<Id> accountNodeIdSet = new Set<Id>();
        try{
            for(Core_MDF_PIC_Review__c picReviewRecord:picReviewData) {
                Core_MDF_ScheduledNotificationHandler.InputWrapper singleRecordWrap = getRecordDetails(picReviewRecord);
                if((!singleRecordWrap.programSetInt.isEmpty()||!singleRecordWrap.programSetExt.isEmpty())) {
                    intelOwnerSet.addAll(singleRecordWrap.userId);
                    accountIds.addAll(singleRecordWrap.accountIdSet);
                    progSetInt.addAll(singleRecordWrap.programSetInt);
                    progSetExt.addAll(singleRecordWrap.programSetExt);
                    progBudgetTypeKeySet.addAll(singleRecordWrap.progBTSet);
                    accountNodeIdSet.addAll(singleRecordWrap.channelPartnerIdSet);
                    
                }
            }
            Core_MDF_ScheduledNotificationHandler.InputWrapper inputWrap = new Core_MDF_ScheduledNotificationHandler.InputWrapper();
            inputWrap.userId = intelOwnerSet;
            inputWrap.accountIdSet = accountIds;
            inputWrap.progBTSet = progBudgetTypeKeySet;
            inputWrap.programSetInt = progSetInt;
            inputWrap.programSetExt = progSetExt;
            inputWrap.isNotifyInternalUsers = true;
            inputWrap.isNotifyExternalUsers = !accountNodeIdSet.isEmpty() ? TRUE : FALSE;
            inputWrap.channelPartnerIdSet = !accountNodeIdSet.isEmpty() ? accountNodeIdSet : new Set<Id>();
            Core_MDF_ScheduledNotificationHandler.ResultWrapper resultWrap = Core_MDF_ScheduledNotificationHandler.getUsersToSendMail(inputWrap);
            if(!resultWrap.internalUsers.isEmpty()) {
                internalUserIds.addAll(resultWrap.internalUsers);
            }
            if(!resultWrap.externalUsers.isEmpty()) {
                externalUserIds.addAll(resultWrap.externalUsers);
            }   
        }catch(Exception ex) {
           Core_MDF_CCP_UtilityClass.logError(ex);
        }
    }
    /*To Notify Intel owners and External CCF/DCF Claim Submitter*/
    Public void finish(Database.BatchableContext bc) {
        String claimObjForEmailPreferences = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EmailPreferenceObjectClaim');
        if((internalUserIds != null && internalUserIds.size() > 0) || (externalUserIds != null && externalUserIds.size() > 0)){
            //calling batch to send email and log entries      
            Core_MDF_Email_NotificationLoggingBatch emailNotifyLogBatch = new Core_MDF_Email_NotificationLoggingBatch(internalUserIds,externalUserIds,Core_MDF_CCP_ConstantClass.PIC_Completed_Notification,claimObjForEmailPreferences);
            // custom metadata with batch size value 
            Integer batchSize = Core_MDF_CustomLabelConfig.getIntegerValues('Core_MDF_PIC_NotifyLogBatchSize');
            Id batchInstanceId = Database.executeBatch(emailNotifyLogBatch,batchSize); 
               }
    }
    
    /*Method to get details from incoming pic review record and creating a wrapper */
    Public static Core_MDF_ScheduledNotificationHandler.InputWrapper getRecordDetails(Core_MDF_PIC_Review__c picReviewRecord) {
        Set<Id> intelOwnerSet= new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        Set<String> progSetInt = new Set<String>();
        Set<String> progsetExt = new Set<String>();
        Set<string> progBudgetTypeKeySet = new Set<string>();
        Set<Id> accountNodeIdSet = new Set<Id>();
        Core_MDF_ScheduledNotificationHandler.InputWrapper inputWrap = new Core_MDF_ScheduledNotificationHandler.InputWrapper();
        string prog = picReviewRecord.Core_MDF_Claim_ID_id__r.Core_MDF_Program__c;
        
        if(Intel_Owner_Based_Notification_Prog.contains(prog) && (picReviewRecord.Core_MDF_Claim_ID_id__r.Request.Core_MDF_Intel_Activity_Owner_Id__c !=null && (picReviewRecord.Core_MDF_Claim_ID_id__r.Request.Core_MDF_Intel_Activity_Owner_Id__r.IsActive || picReviewRecord.Core_MDF_Claim_ID_id__r.Request.Core_MDF_Intel_Activity_Owner_Id__r.Partner_License_Reclaimed__c))){
            
            String progBTKey = prog + picReviewRecord.Core_MDF_Claim_ID_id__r.Core_MDF_Budget_Type_Nm__c;
            progSetInt.add(prog);
            accountIds.add(Id.valueOf(picReviewRecord.Core_MDF_Claim_ID_id__r.Core_MDF_Ultimate_Account_ID__c));
            intelOwnerSet.add( picReviewRecord.Core_MDF_Claim_ID_id__r.Request.Core_MDF_Intel_Activity_Owner_Id__c);
            progBudgetTypeKeySet.add(progBTKey);
            
        } else if(IUPGM_Based_Notification_Prog.contains(prog)) {
            Id accIds = (prog =='Retail Marketing Funds')? picReviewRecord.Core_MDF_Claim_ID_id__r.Request.ChannelPartnerId:
            Id.valueOf(picReviewRecord.Core_MDF_Claim_ID_id__r.Core_MDF_Ultimate_Account_ID__c);
            accountIds.add(accIds);
            progBudgetTypeKeySet.add(prog);
            progSetInt.add(prog);
        }
        if(picReviewRecord.Core_MDF_Claim_ID_id__r.Core_MDF_PIC_Review_Completed__c) {
            accountNodeIdSet.add(picReviewRecord.Core_MDF_Claim_ID_id__r.ChannelPartnerId);
            progSetExt.add(prog);
        }
        
        
        inputWrap.userId = intelOwnerSet;
        inputWrap.accountIdSet = accountIds;
        inputWrap.progBTSet = progBudgetTypeKeySet;
        inputWrap.programSetInt = progSetInt;
        inputWrap.programSetExt = progSetExt ;
        inputWrap.channelPartnerIdSet = accountNodeIdSet ;
        
        return inputWrap;
    }
    
    
}