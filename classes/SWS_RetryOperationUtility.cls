public without sharing class SWS_RetryOperationUtility {
    private static final Integer MAX_RETRIES = 3;
    public static final String LOG_ENTRY_ORIGIN = 'SWS_RetryOperationUtility';
    private static final String LOG_ENTRY_SCOPE = 'Failed to update record after retry';
    private static final String LOG_ENTRY_SEVERITY = 'Medium';
    public static List<Database.SaveResult> results;
    
    public SWS_RetryOperationUtility(List<sObject> recordList) {
        performUpdateRecursive(recordList, 0);
    }
    
    private static void performUpdateRecursive(List<sObject> recordList, Integer retryCount) {
        String retryList = SWS_Core_CRM_Labels__c.getValues('RetryError') != null ? SWS_Core_CRM_Labels__c.getValues('RetryError').SWS_Value__c : '';
        String errorStatusCode = '';
        Boolean updateSuccess = true;
        results = Database.update(recordList, false);
        for (Integer i = 0; i < results.size(); i++) {
            Database.SaveResult sr = results[i];
            if (!sr.isSuccess()) {
                updateSuccess = false;
                errorStatusCode = SWS_Utility.getErrorAsString(sr.getErrors(),LOG_ENTRY_ORIGIN);
            }
        }
        
        if (updateSuccess) {
            return;
        } else if (retryList.contains(errorStatusCode) && retryCount < MAX_RETRIES) {
            retryCount++;
            performUpdateRecursive(recordList, retryCount);
        }
        
        if (retryCount == 2) {
            SWS_Utility.createCoreLogEntry(LOG_ENTRY_ORIGIN, 'performUpdateRecursive', LOG_ENTRY_SCOPE, '', null, 'SWS_Cloud_Credit_Request__c', LOG_ENTRY_SEVERITY, (String) recordList[0].get('Id'));
            SWS_SendEmailController.retryUpdateFailed = true;
            EmailTemplate template = SWS_SendEmailController.getEmailTemplate('SWS_FailedToUpdateRecord');
            Messaging.SingleEmailMessage sendEmail = SWS_SendEmailController.getRenderEmailContent(template.Id, null);
            String body = sendEmail.getHtmlBody();
            body = body.replace('[Insert Record ID]',(String) recordList[0].get('Id')).replace('[Insert Error Message]',retryList).replace('[Insert Timestamp]',String.valueOf(System.now()));
            sendEmail.setHtmlBody(body);
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{sendEmail});
        }
    }   
}