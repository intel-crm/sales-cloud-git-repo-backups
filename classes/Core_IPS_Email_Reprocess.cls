global class Core_IPS_Email_Reprocess {
/***************************************************************************************************
* Apex Class Name: Core_IPS_Email_Reprocess 
* Version     : 1.0 
* Created Date: 4th Dec 2015
* Function    : Email Reprocessing
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S     12/04/2015              Created
****************************************************************************************************/
/**************************************************************************************************
* Method name  : ReprocessExtDownloadNotifEmail
* Description  : Reprocess External Download Notification Emails
*                Processes entries from Core_IPS_Email_Log__c
* Return Type  : String
* Parameters   : List<Id> RecordIds
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S     12/04/2015              Created
****************************************************************************************************/
    WebService static String ReprocessExtDownloadNotifEmail(Id[] RecordIds){
        Set<ID> TargetObjectIDSet = new Set<ID>();
        List<Core_IPS_Email_Log__c> EmailLogLst = new List<Core_IPS_Email_Log__c>();
        Map<Id,String> FailedContactIdErrMsgMap = new Map<Id,String>();
        List<Core_IPS_Email_Log__c> ToBeUpdatedEmailLst = new List<Core_IPS_Email_Log__c>();
        List<Core_IPS_Email_Log__c> ToBeDeletedEmailLst = new List<Core_IPS_Email_Log__c>();
        Integer RecordsProcessed = 0;
        Integer RecordsError = 0;
        Integer RecordsSuccess = 0;
        Boolean SaveAsActivityFlag = false;
        Boolean AllOrNoneFlag = false;
        
        try {
            Core_IPS_ExtDownNotif_Email_Settings__c ExtSettingSaveAsActivity  = Core_IPS_ExtDownNotif_Email_Settings__c.getValues('SaveAsActivity');
            Core_IPS_ExtDownNotif_Email_Settings__c ExtSettingAllOrNone  = Core_IPS_ExtDownNotif_Email_Settings__c.getValues('AllOrNone');
            if(ExtSettingSaveAsActivity != null){
                SaveAsActivityFlag = boolean.valueof(ExtSettingSaveAsActivity.Core_Value__c);
            }          
            if(ExtSettingAllOrNone != null){
                AllOrNoneFlag = boolean.valueof(ExtSettingAllOrNone.Core_Value__c);
            }            
            //Number of Records Processed
            RecordsProcessed = RecordIds.size();
            //Get Error entries 
            //FLS check added-Venugopal
            if(Core_IPS_Email_Log__c.SObjectType.getDescribe().isAccessible()){
                                        EmailLogLst = [select Id, Core_TargetObjectId__c, Core_TemplateID__c, Core_WhatId__c, Core_OrgWideEmailAddressId__c
                                                       from Core_IPS_Email_Log__c where id in :RecordIds and Core_Project__c = 'IPS' and 
                                                       Core_ApplicationArea__c = 'IPS External Download Notification' and Core_Status__c = 'Error'];
            }
            //Get TargetObjectId's
            if (EmailLogLst != null && EmailLogLst.size() > 0) {
                for (Core_IPS_Email_Log__c EmailLogObject : EmailLogLst){
                    TargetObjectIDSet.add(EmailLogObject.Core_TargetObjectId__c);   
                } 
            }
            //Get Id's 
            if(TargetObjectIDSet != null && TargetObjectIDSet.size()> 0 ){
                //Stash for Re-send
                for(Core_IPS_Email_Log__c EmailLogObject : EmailLogLst) {             
                    Core_EmailUtil.to(EmailLogObject.Core_TargetObjectId__c)
                        .templateId(EmailLogObject.Core_TemplateID__c)
                        .whatId(EmailLogObject.Core_WhatId__c)
                        .orgWideEmailAddressId(EmailLogObject.Core_OrgWideEmailAddressId__c)
                        //.replyTo('donotreply@ips.intel.com')
                        .saveAsActivity(SaveAsActivityFlag)
                        .stashForBulk(); 
                } 
                //Send Email
                Core_EmailUtil.sendBulkEmail(AllOrNoneFlag);
                //Check results
                //Get Any Errors
                for (Messaging.SendEmailResult sendEmailResult : Core_EmailUtil.last_sendEmail_result) {
                    if(!sendEmailResult.isSuccess()){
                        RecordsError = ++RecordsError;
                        for (Messaging.Sendemailerror sendEmailError : sendEmailResult.getErrors()){
                            FailedContactIdErrMsgMap.put(sendEmailError.TargetObjectId,sendEmailError.Message);                    
                        }
                    } else {
                        RecordsSuccess = ++RecordsSuccess;
                    }              
                }                       
                //Now Compare
                for (Core_IPS_Email_Log__c EmailLogObject : EmailLogLst){
                    //Any occurance of TargetObjectId will keep the related records in log
                    //No way to track the related File object -> unless we use batch to send single Email at a time
                    if(FailedContactIdErrMsgMap.get(EmailLogObject.Core_TargetObjectId__c)!= null){
                        //Build ToBeUpdated
                        Core_IPS_Email_Log__c EmailUpdObj = new Core_IPS_Email_Log__c(Id = EmailLogObject.Id); 
                        String ErrorMsg;
                        if (FailedContactIdErrMsgMap.get(EmailLogObject.Core_TargetObjectId__c) != null && 
                            FailedContactIdErrMsgMap.get(EmailLogObject.Core_TargetObjectId__c) != ''){
                                ErrorMsg = FailedContactIdErrMsgMap.get(EmailLogObject.Core_TargetObjectId__c);
                                If (ErrorMsg.length() > 255){
                                    ErrorMsg = ErrorMsg.substring(0,255);    
                                } 
                            }             
                        EmailUpdObj.Core_Message__c  = ErrorMsg;
                        ToBeUpdatedEmailLst.add(EmailUpdObj);   
                    } else {
                        //Build ToBeDeleted
                        Core_IPS_Email_Log__c EmailUpdObj = new Core_IPS_Email_Log__c(Id = EmailLogObject.Id); 
                        ToBeDeletedEmailLst.add(EmailUpdObj);  
                    }
                }
                //DB Updates
                if (ToBeUpdatedEmailLst != null && ToBeUpdatedEmailLst.size() > 0) {
                    update ToBeUpdatedEmailLst;
                }
                //DB Deletes
                if (ToBeDeletedEmailLst != null && ToBeDeletedEmailLst.size() > 0) {
                    /*US1038991 - 07/08/2021 - Vishal - FLS Check for security vulnerability --*/
                    if (Core_IPS_Email_Log__c.sObjectType.getDescribe().isDeletable()) {    
                         delete ToBeDeletedEmailLst;
                    }
                }
            }    
            return 'Records Processed: ' + RecordsProcessed + '\nSuccess Count: ' + 
                RecordsSuccess + '\nError Count: ' + RecordsError + '\nSuccess Records will be removed from this list.\nCheck Message field for latest error while re-sending';
        } catch(Exception e) {
            return 'Records Processed: ' + RecordsProcessed + '\nSuccess Count: ' + 
                RecordsSuccess + '\nError Count: ' + RecordsError + '\nSystem Exception: '+ e.getMessage();
            
        }
    }    
    
}