/****************************************************************************************************************************************
* Class Name        : Core_MDF_Paid_Claims_Notify_Batch
* Test Class Name   : Core_MDF_Paid_Claims_Notify_Batch_Test
* Description       : To Notify Intel Owner on Claim Score Completion.
* Developer         : Mohit
*****************************************************************************************************************************************/
public without sharing class Core_MDF_Paid_Claims_Notify_Batch implements Database.Batchable<sObject>,Database.Stateful {
    
    Public static List<string> Owner_Based_Notification_Prog = Core_MDF_CCP_ConstantClass.Intel_Owner_Based_Notification_Prog;
    Public static List<string> IUPGM_Based_Notification_Prog = new List<string>{'Retail Marketing Funds','Intel Partner Alliance'};
    Public static List<String> Notification_Enabled_Program = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Paid_Claims_Notifications').split(',');
    Public string LAST_RECOVERY = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Last_Recovery_Date');
    Public string PAYMENT_MADE_DATE = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Payment_Made_Date');
    Set<Id> internalUserIds = new Set<Id>();
    Set<Id> externalUserIds = new Set<Id>();
    Public static String PAID_CLAIMS = Core_MDF_CCP_ConstantClass.PAID_CLAIMS;
    Public static String TYPE_CLAIM = Core_MDF_CCP_ConstantClass.TYPE_CLAIM;
    /*Start Method - To get Data*/
    public Database.QueryLocator start(Database.BatchableContext bc){
        
        string query = 'Select id,ChannelPartnerId,Amount,Core_MDF_Status__c,Core_MDF_Program__c,RecordType.Name,Core_MDF_Payment_Made_Dt__c,Core_MDF_Total_Claim_Recovery_Amount__c,Request.ChannelPartnerId, '+
                       'Request.Core_MDF_Ultimate_Account_Id__c,Request.Core_MDF_Primary_Intel_Owner_Id__c,Request.Core_MDF_Intel_Activity_Owner_Id__r.IsActive,Request.Core_MDF_Primary_Intel_Owner_Id__r.IsActive,Request.Core_MDF_Intel_Activity_Owner_Id__c,Request.Core_MDF_Budget_Type_nm__c, ' +
                       'Request.Core_MDF_Intel_Activity_Owner_Id__r.Partner_License_Reclaimed__c,Request.Core_MDF_Primary_Intel_Owner_Id__r.Partner_License_Reclaimed__c ' +
                       'FROM PartnerFundClaim ' +
                       'Where Core_MDF_Program__c IN:Notification_Enabled_Program AND Core_MDF_Status__c =: PAID_CLAIMS AND '+
                       '((Amount > 0 AND ' + PAYMENT_MADE_DATE + ') OR (Amount = 0 AND '+ LAST_RECOVERY +' AND Core_MDF_Total_Claim_Recovery_Amount__c > 0)) AND '+
                       'Core_MDF_Legacy_Claim_Ind__c = false AND Core_MDF_Type_Txt__c =: TYPE_CLAIM ';
        
        return Database.getQueryLocator(query);
    }
    /*Execute Method*/
    public void execute(Database.BatchableContext bc, List<PartnerFundClaim> claimList){
        Set<Id> userIdSet = new Set<Id>();
        Set<Id> cpIdSet = new Set<Id>();
        Set<Id> accIdSet = new Set<Id>();
        Set<String> progSetInt = new Set<String>();
        Set<String> progSetExt = new Set<String>();
        Set<string> progBudgetTypeKeySet = new Set<string>();
        
        
        try{
            for(PartnerFundClaim claimRec : claimList) {
                Core_MDF_ScheduledNotificationHandler.InputWrapper resultWrap = getRecordDetails(claimRec);
                if(!resultWrap.programSetInt.isEmpty()||!resultWrap.programSetExt.isEmpty() ){
                    userIdSet.addAll(resultWrap.userId);
                    accIdSet.addAll(resultWrap.accountIdSet);
                    progBudgetTypeKeySet.addAll(resultWrap.progBTSet);
                    progSetInt.addAll(resultWrap.programSetInt);
                    progSetExt.addAll(resultWrap.programSetExt);
                    cpIdSet.addAll(resultWrap.channelPartnerIdSet);
                }
            }
            
            
            Core_MDF_ScheduledNotificationHandler.InputWrapper inputWrap = new Core_MDF_ScheduledNotificationHandler.InputWrapper();
            inputWrap.userId = userIdSet;
            inputWrap.channelPartnerIdSet = cpIdSet;
            inputWrap.accountIdSet = accIdSet;
            inputWrap.progBTSet = progBudgetTypeKeySet;
            inputWrap.programSetInt = progSetInt;
            inputWrap.programSetExt = progSetExt;
            inputWrap.isNotifyInternalUsers = true;
            inputWrap.isNotifyExternalUsers = true;
            if(!accIdSet.isEmpty()){
                Core_MDF_ScheduledNotificationHandler.ResultWrapper resultWrap = Core_MDF_ScheduledNotificationHandler.getUsersToSendMail(inputWrap);
                if(!resultWrap.internalUsers.isEmpty()){
                    internalUserIds.addAll(resultWrap.internalUsers);
                    
                }
                if(!resultWrap.externalUsers.isEmpty()) {
                    externalUserIds.addAll(resultWrap.externalUsers);
                }
            } 
            
        }    
        Catch(Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
        }    
    }       
    /*To send Emails for Internal Account Managers and External Claim submitter on paid Claims*/ 
    public void finish(Database.BatchableContext bc){
        String claimObjForEmailPreferences = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EmailPreferenceObjectClaim');
        if((internalUserIds != null && internalUserIds.size() > 0) || (externalUserIds != null && externalUserIds.size() > 0)){
            //calling batch to send email and log entries     
            Core_MDF_Email_NotificationLoggingBatch emailNotifyLogBatch = new Core_MDF_Email_NotificationLoggingBatch(internalUserIds,externalUserIds,Core_MDF_CCP_ConstantClass.Paid_Claims_Notification,claimObjForEmailPreferences);
            // custom metadata with batch size value 
            Integer batchSize = Core_MDF_CustomLabelConfig.getIntegerValues('Core_MDF_PaidClaim_NotifyLogBatchSize');
            Id batchInstanceId = Database.executeBatch(emailNotifyLogBatch,batchSize);
        }      
    }
    /*To return values from claim records for to create wrapper instance*/
    Public static Core_MDF_ScheduledNotificationHandler.InputWrapper getRecordDetails(PartnerFundClaim claimRec) {
        Set<Id> userIdSet = new Set<Id>();
        Set<Id> accIdSet = new Set<Id>();
        Set<Id> claimIdSet = new Set<Id>();
        Set<string> progSetInt = new Set<string>();
        Set<string> progSetExt = new Set<string>();
        Set<string> progBudgetTypeKeySet = new Set<string>();
        Set<Id> cpIdSet = new Set<Id>();
        string prog = claimRec.Core_MDF_Program__c;
        Core_MDF_ScheduledNotificationHandler.InputWrapper inputWrap = new Core_MDF_ScheduledNotificationHandler.InputWrapper();
       
        if(isValidClaimRecord(claimRec)){
               
                if(Owner_Based_Notification_Prog.contains(prog) && claimRec.Request.Core_MDF_Intel_Activity_Owner_Id__c != NULL && (claimRec.Request.Core_MDF_Intel_Activity_Owner_Id__r.IsActive || claimRec.Request.Core_MDF_Intel_Activity_Owner_Id__r.Partner_License_Reclaimed__c)) {
                    progBudgetTypeKeySet.add(prog + claimRec.Request.Core_MDF_Budget_Type_nm__c);
                    userIdSet.add(claimRec.Request.Core_MDF_Intel_Activity_Owner_Id__c);
                    accIdSet.add(Id.valueOf(claimRec.Request.Core_MDF_Ultimate_Account_Id__c));
                    progSetInt.add(prog); 
                    cpIdSet.add(claimRec.ChannelPartnerId); 
                }
                else if (IUPGM_Based_Notification_Prog.contains(prog))
                {
                    
                    Id accId = (prog =='Retail Marketing Funds')? claimRec.Request.ChannelPartnerId:
                                                                  Id.valueOf(claimRec.Request.Core_MDF_Ultimate_Account_Id__c);
                    accIdSet.add(accId);
                    progBudgetTypeKeySet.add(prog);
                    progSetInt.add(prog);   
                    cpIdSet.add(claimRec.ChannelPartnerId); 
                }
                if(claimRec.request.Core_MDF_Intel_Activity_Owner_Id__c == NULL){
                    cpIdSet.add(claimRec.ChannelPartnerId);  
                    progSetExt.add(prog);   
                }
                
                
                inputWrap.userId = userIdSet;
                inputWrap.accountIdSet = accIdSet;
                inputWrap.progBTSet = progBudgetTypeKeySet;
                inputWrap.programSetInt = progSetInt;
                 inputWrap.programSetExt = progSetExt;
                inputWrap.channelPartnerIdSet = cpIdSet;
            }        
             
        return inputWrap;   
    } 
    /*To Return Required Claim Records*/
    public static boolean isValidClaimRecord(PartnerFundClaim claimRec ) {
    boolean recResult = false ;
        if((claimRec.Core_MDF_Payment_Made_Dt__c != NULL && claimRec.Amount > 0) || (claimRec.Core_MDF_Payment_Made_Dt__c == NULL && claimRec.Amount == 0 && claimRec.Core_MDF_Total_Claim_Recovery_Amount__c > 0)){
           recResult = true;
        }
    return recResult ;
    }
}