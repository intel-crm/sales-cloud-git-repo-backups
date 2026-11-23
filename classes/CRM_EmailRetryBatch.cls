global class CRM_EmailRetryBatch implements Database.Batchable<SObject>, Database.Stateful {
	public static final String FROM_EMAIL_ADDRESS = System.Label.Core_SetFromEmailAddress;
    public static final Integer MAX_RETRY_ATTEMPTS = 3;
    
     global Database.QueryLocator start(Database.BatchableContext bc) {
          return Database.getQueryLocator([SELECT Id,Name,Email_Template_ID__c,Email_Template_Name__c,PRM_EmailContent__c,PRM_User__c FROM PRM_EmailLog__c WHERE PRM_Type__c = 'CRM' AND CreatedDate = TODAY
                                          /*AND (PRM_Permanent_Failure__c = false OR PRM_Permanent_Failure__c = null)
                                          AND (PRM_Email_Status__c!= 'Success' OR PRM_Email_Status__c != null)
                                          AND (PRM_Retry_Count__c < :MAX_RETRY_ATTEMPTS OR PRM_Retry_Count__c = null)*/]);
     }
     global void execute(Database.BatchableContext bc, List<PRM_EmailLog__c> emailLogList) {
         // Send email
        List<Messaging.SingleEmailMessage> retryMailList = new List<Messaging.SingleEmailMessage>();
        List<PRM_EmailLog__c> emailLogsToUpdate = new List<PRM_EmailLog__c>();
        Map<Integer,PRM_EmailLog__c> indexToEmailLogMap = new Map<Integer,PRM_EmailLog__c>();
         
        system.debug('APEX EXECUTE EMAIL RETRY'+emailLogList);
        if(emailLogList.size()>0){
            for(PRM_EmailLog__c mailLog:emailLogList){
                
                /*if(mailLog.PRM_Retry_Count__c == null) {
                    mailLog.PRM_Retry_Count__c = 1;
                } else {
                    mailLog.PRM_Retry_Count__c += 1;
                }*/
               
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setTemplateId(mailLog.Email_Template_ID__c);
                email.setOrgWideEmailAddressId(FROM_EMAIL_ADDRESS);
                email.setToAddresses(new String[] {'devix.sinduja@intel.com'});
                email.setSaveAsActivity(false);
                email.setSubject('Opportunity SLA Breach Notification');
                email.setHtmlBody(mailLog.PRM_EmailContent__c);
                retryMailList.add(email);
                
                indexToEmailLogMap.put(retryMailList.size() - 1, mailLog);
                emailLogsToUpdate.add(mailLog);
           }    
     	}
        
        // Send emails
        Messaging.SendEmailResult[] retryResults = Messaging.sendEmail(retryMailList);
       
        /*if(!retryMailList.isEmpty()) {
            Messaging.SendEmailResult[] emailResults = Messaging.sendEmail(retryMailList, false);
            for(Integer i = 0; i < emailResults.size(); i++){
                PRM_EmailLog__c currentEmailLog = indexToEmailLogMap.get(i);
                Messaging.SendEmailResult result = emailResults[i];
                
                if(result.isSuccess()){
                    currentEmailLog.PRM_Email_Status__c = 'Success';
                    currentEmailLog.PRM_Permanent_Failure__c = false;
                }
                else{
                    if(currentEmailLog.PRM_Retry_Count__c <= 3){
                        currentEmailLog.PRM_Email_Status__c = 'Failure';
                        currentEmailLog.PRM_Permanent_Failure__c = true;
                    }
                    //Still have retries left
                    else{
                        currentEmailLog.PRM_Email_Status__c = null; // Will be processed again
                        currentEmailLog.PRM_Permanent_Failure__c = false;
                    }
                }
                
            }
        }*/
         try{
             update emailLogsToUpdate;
         }catch(Exception e){
             
         }
        
     }
    global void finish(Database.BatchableContext bc) {
       Integer remaningEntries = [SELECT COUNT() FROM PRM_EmailLog__c WHERE PRM_Type__c = 'CRM' AND CreatedDate = TODAY
                                 /*AND (PRM_Email_Status__c != 'Success' AND PRM_Email_Status__c != 'Failure')
                                 AND (PRM_Permanent_Failure__c = false OR PRM_Permanent_Failure__c = null)
                                 AND PRM_Retry_Count__c < :MAX_RETRY_ATTEMPTS*/];
        
        // Auto-schedule next batch run if there are remaining retries
        if(remaningEntries>0){
            System.debug('Scheduling next retry batch in 30 minutes');
            // Schedule next run in 30 minutes
            Datetime nextRun = System.now().addMinutes(30);
            String cronExp = nextRun.second() + ' ' + nextRun.minute() + ' ' + nextRun.hour() + 
                           ' ' + nextRun.day() + ' ' + nextRun.month() + ' ? ' + nextRun.year();
            
            // Uncomment below line for  auto-scheduling
            // System.schedule('CRM Email Retry Batch - ' + System.now(), cronExp, new CRM_EmailRetrySchedulable());
        }
    }
}