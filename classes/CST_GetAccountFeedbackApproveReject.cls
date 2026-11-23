public with sharing class CST_GetAccountFeedbackApproveReject {
     @Invocablemethod(label='fetchAccountFeedbackAcceptReject')

    public static List<List<SPM_Account_Feedback__c>> fetchAccountFeedbackAcceptReject(List<List<Id>> customerIdSet){
     
        system.debug('Customer id set is:'+customerIdSet);
        Set<Id> custIds = new Set<Id>();
        List<SPM_Account_Feedback__c> accountFeedbackList = new List<SPM_Account_Feedback__c>();
        List<List<SPM_Account_Feedback__c>> opAccountFeedbackList = new List<List<SPM_Account_Feedback__c>>(); 
        
       for(List<Id> innerList : customerIdSet) {
        for(Id id : innerList) {
                custIds.add(id); 
            }
        }
         system.debug('Inside custidsis:'+custIds);
        
        accountFeedbackList =[SELECT Id,Name,CRM_CST_VP_Feedback__c,CRM_CST_CM_Feedback__c,CRM_CST_GM_Feedback__c,Account_ID__r.VP__c,Account_ID__r.GM__c FROM SPM_Account_Feedback__c WHERE Account_ID__r.SPM_Customer_ID__c IN: custIds];
        system.debug('AccFeedbackList is:'+accountFeedbackList);
        
        opAccountFeedbackList.add(accountFeedbackList);
        system.debug('OPLIST IS:'+opAccountFeedbackList);
		return opAccountFeedbackList;
    }
}