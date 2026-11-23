/****************************************************************************************************************************************
* Class Name        : Core_MDF_Claim_Score_Notify_Batch
* Test Class Name   : Core_MDF_Claim_Score_Notify_Batch_Test
* Description       : To Notify Intel Owner on Claim Score Completion.
* Developer         : Shiva
*****************************************************************************************************************************************/
public without sharing class Core_MDF_Claim_Score_Notify_Batch implements Database.Batchable<sObject>,Database.Stateful {
    
    Public static List<string> Intel_Owner_Based_Notification_Prog = Core_MDF_CCP_ConstantClass.Intel_Owner_Based_Notification_Prog;
    Public static List<string> IUPGM_Based_Notification_Prog =Core_MDF_CCP_ConstantClass.IUPGM_Based_Notification_Prog ;
    Public static List<String> Notification_Enabled_Program = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Claim_Score_Notification').split(',');	
    Public Set<Id> usersToSendMail = new Set<Id>();
    Public static string AUDIT_CLOSED =Core_MDF_CCP_ConstantClass.AUDIT_CLOSED;
    
    Public static string REVIEW_COMPLETED =Core_MDF_CCP_ConstantClass.REVIEW_COMPLETED ;  
    Public string DAYS_FILTER = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Claim_Score_Notification_Days');	
    
    /*Start method - To get Case Records*/
    public Database.QueryLocator start(Database.BatchableContext bc){
        
        string query = 'SELECT Id,Core_MDF_Claim_Lookup_Id__c,Core_MDF_Channel_Program_txt__c,RecordType.Name,Core_MDF_Claim_Lookup_Id__r.Request.Core_MDF_Intel_Activity_Owner_Id__c,Core_MDF_Claim_Lookup_Id__r.Request.Core_MDF_Ultimate_Account_Id__c,' +
            'Core_MDF_Claim_Lookup_Id__r.Request.Core_MDF_Budget_Type_nm__c,Core_MDF_Claim_Lookup_Id__r.Request.Core_MDF_Primary_Intel_Owner_Id__c,Core_MDF_Claim_Lookup_Id__r.Request.Core_MDF_Primary_Intel_Owner_Id__r.IsActive, Core_MDF_Claim_Lookup_Id__r.Request.Core_MDF_Intel_Activity_Owner_Id__r.IsActive, ' +
            'Core_MDF_Claim_Lookup_Id__r.Request.Core_MDF_Primary_Intel_Owner_Id__r.Partner_License_Reclaimed__c, Core_MDF_Claim_Lookup_Id__r.Request.Core_MDF_Intel_Activity_Owner_Id__r.Partner_License_Reclaimed__c, ' +
            'Core_MDF_Claim_Lookup_Id__r.Request.ChannelPartnerId '+
            'FROM Case '+
            'WHERE RecordType.Name =: AUDIT_CLOSED AND Core_MDF_Status__c =: REVIEW_COMPLETED ' + 
            'AND Core_MDF_Channel_Program_txt__c IN:Notification_Enabled_Program AND Core_MDF_Claim_Lookup_Id__r.Core_MDF_Legacy_Claim_Ind__c = False '+
            'AND ' + DAYS_FILTER;
        
        return Database.getQueryLocator(query);
    }   
    /*Execute Method*/
    public void execute(Database.BatchableContext bc, List<Case> caseList) {
        
        Set<Id> userIdSet = new Set<Id>();
        Set<Id> accIdSet = new Set<Id>();
        Set<string> progSetInt = new Set<string>();
        Set<string> progBudgetTypeKeySet = new Set<string>();
        
        
        try{
            for(Case caseRec : caseList) {
                Core_MDF_ScheduledNotificationHandler.InputWrapper resultWrap = getRecordDetails(caseRec);
                if(!resultWrap.accountIdSet.isEmpty()){
                    userIdSet.addAll(resultWrap.userId);
                    accIdSet.addAll(resultWrap.accountIdSet);
                    progBudgetTypeKeySet.addAll(resultWrap.progBTSet);
                    progSetInt.addAll(resultWrap.programSetInt); 
                }
            }
            
            Core_MDF_ScheduledNotificationHandler.InputWrapper inputWrap = new Core_MDF_ScheduledNotificationHandler.InputWrapper();
            inputWrap.userId = userIdSet;
            inputWrap.accountIdSet = accIdSet;
            inputWrap.progBTSet = progBudgetTypeKeySet;
            inputWrap.programSetInt = progSetInt;
            inputWrap.isNotifyInternalUsers = true;
            inputWrap.isNotifyExternalUsers = false;
            if(!accIdSet.isEmpty()){
                Core_MDF_ScheduledNotificationHandler.ResultWrapper resultWrap = Core_MDF_ScheduledNotificationHandler.getUsersToSendMail(inputWrap);
                if(!resultWrap.internalUsers.isEmpty()){
                    usersToSendMail.addAll(resultWrap.internalUsers);
                }
            }
        } 
        Catch(Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
        }    
    }
    
    
    /*Finish Method - To notify Account managers*/
    public void finish(Database.BatchableContext bc) {
        String caseObjForEmailPreferences = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EmailPreferenceObject_Case');
        if(usersToSendMail != null && usersToSendMail.size() > 0){
        //calling batch to send email and log entries 
        Core_MDF_Email_NotificationLoggingBatch emailNotifyLogBatch = new Core_MDF_Email_NotificationLoggingBatch(usersToSendMail,null,Core_MDF_CCP_ConstantClass.ClaimScore_Notification,caseObjForEmailPreferences);
        // custom metadata with batch size value 
        Integer batchSize = Core_MDF_CustomLabelConfig.getIntegerValues('Core_MDF_ClaimScore_NotifyLogBatchSize');
        Id batchInstanceId = Database.executeBatch(emailNotifyLogBatch,batchSize);
        }
    }
    
    /*Method to give required parameters to inputwrapper from case records*/
    Public static Core_MDF_ScheduledNotificationHandler.InputWrapper getRecordDetails(Case caseRec ) {
        Set<Id> userIdSet = new Set<Id>();
        Set<Id> accIdSet = new Set<Id>();
        Set<string> progSetInt = new Set<string>();
        Set<string> progBudgetTypeKeySet = new Set<string>();
        string prog = caseRec.Core_MDF_Channel_Program_txt__c;
        Core_MDF_ScheduledNotificationHandler.InputWrapper inputWrap = new Core_MDF_ScheduledNotificationHandler.InputWrapper();
       
        if(Intel_Owner_Based_Notification_Prog.contains(prog) && caseRec.Core_MDF_Claim_Lookup_Id__c != null && caseRec.Core_MDF_Claim_Lookup_Id__r.Request.Core_MDF_Intel_Activity_Owner_Id__c != NULL && (caseRec.Core_MDF_Claim_Lookup_Id__r.Request.Core_MDF_Intel_Activity_Owner_Id__r.IsActive || caseRec.Core_MDF_Claim_Lookup_Id__r.Request.Core_MDF_Intel_Activity_Owner_Id__r.Partner_License_Reclaimed__c)) {
            progBudgetTypeKeySet.add(prog + caseRec.Core_MDF_Claim_Lookup_Id__r.Request.Core_MDF_Budget_Type_nm__c);
            userIdSet.add(caseRec.Core_MDF_Claim_Lookup_Id__r.Request.Core_MDF_Intel_Activity_Owner_Id__c);
            accIdSet.add(Id.valueOf(caseRec.Core_MDF_Claim_Lookup_Id__r.Request.Core_MDF_Ultimate_Account_Id__c));
            progSetInt.add(prog);
        } else if(prog=='Ecosystem Extension Fund' && Intel_Owner_Based_Notification_Prog.contains(prog) && caseRec.Core_MDF_Claim_Lookup_Id__c != null && caseRec.Core_MDF_Claim_Lookup_Id__r.Request.Core_MDF_Primary_Intel_Owner_Id__c != NULL && (caseRec.Core_MDF_Claim_Lookup_Id__r.Request.Core_MDF_Primary_Intel_Owner_Id__r.IsActive || caseRec.Core_MDF_Claim_Lookup_Id__r.Request.Core_MDF_Primary_Intel_Owner_Id__r.Partner_License_Reclaimed__c)) {
            progBudgetTypeKeySet.add(prog + caseRec.Core_MDF_Claim_Lookup_Id__r.Request.Core_MDF_Budget_Type_nm__c);
            userIdSet.add(caseRec.Core_MDF_Claim_Lookup_Id__r.Request.Core_MDF_Intel_Activity_Owner_Id__c);
            accIdSet.add(Id.valueOf(caseRec.Core_MDF_Claim_Lookup_Id__r.Request.Core_MDF_Ultimate_Account_Id__c));
            progSetInt.add(prog);
        }
        else if (IUPGM_Based_Notification_Prog.contains(prog) && caseRec.Core_MDF_Claim_Lookup_Id__c != null){
            Id accId = (prog =='Retail Marketing Funds')? caseRec.Core_MDF_Claim_Lookup_Id__r.Request.ChannelPartnerId:
            Id.valueOf(caseRec.Core_MDF_Claim_Lookup_Id__r.Request.Core_MDF_Ultimate_Account_Id__c);
            accIdSet.add(accId);
            progBudgetTypeKeySet.add(prog);
            progSetInt.add(prog);
        }
        
        inputWrap.userId = userIdSet;
        inputWrap.accountIdSet = accIdSet;
        inputWrap.progBTSet = progBudgetTypeKeySet;
        inputWrap.programSetInt = progSetInt;
        
        return inputWrap;
    }
    
    
}