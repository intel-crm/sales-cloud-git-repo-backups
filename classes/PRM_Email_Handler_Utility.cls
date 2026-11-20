//Added by Gopi(Agate Team) as a part Suppress Email functionality from Userstory TWC729-174
public with sharing class PRM_Email_Handler_Utility {

    public static Boolean checkForEmailSupression(Id conId, String Event){
        Boolean supressEmail = false;
        List<PRM_Email_Handler__c> emailHandlerRecordsToUpdate = new List<PRM_Email_Handler__c>();
        List<PRM_Email_Handler__c> emailHandlerRequests = new List<PRM_Email_Handler__c>();
        emailhandlerRequests = [SELECT Id,PRM_Contact__c,PRM_Email_Id__c,PRM_Email_Handler_Status__c,PRM_Event__c,PRM_Suppress_Email__c,PRM_Email_Suppressed_Time__c 
                               From PRM_Email_Handler__c Where PRM_Contact__c=:conId order by CreatedDate DESC LIMIT 1];
        if(emailhandlerRequests!=null && !emailhandlerRequests.isEmpty()){
            for(PRM_Email_Handler__c emailRequest:emailhandlerRequests){
                if(emailRequest.PRM_Suppress_Email__c==true && emailRequest.PRM_Email_Handler_Status__c =='Requested For Suppression' && emailRequest.PRM_Event__c ==Event){
                    supressEmail=true;                    
                    emailRequest.PRM_Email_Handler_Status__c ='Completed';
                    emailRequest.PRM_Email_Suppressed_Time__c =datetime.now();
                    emailHandlerRecordsToUpdate.add(emailRequest);
                }
            }
            System.debug('emailHandlerRecordsToUpdate'+emailHandlerRecordsToUpdate);
            System.debug('emailHandlerRecordsToUpdate size===?'+emailHandlerRecordsToUpdate.size());
            if(emailHandlerRecordsToUpdate!=null && !emailHandlerRecordsToUpdate.isEmpty()){
                //List<Database.SaveResult> results = 
                    Database.update(emailHandlerRecordsToUpdate,false);
            }
        }
        return supressEmail;
    }
    
    public static Map<Id,PRM_Email_Handler__c>returnContactSupressionMap(Set<Id> acctId, String Event){
        Map<Id,PRM_Email_Handler__c> contactSuppressionMap = new Map<Id,PRM_Email_Handler__c>();
        for(PRM_Email_Handler__c emailLog: [SELECT Id,PRM_Contact__c,PRM_Email_Id__c,PRM_Email_Handler_Status__c,PRM_Event__c,PRM_Suppress_Email__c,PRM_Email_Suppressed_Time__c From PRM_Email_Handler__c Where PRM_Contact__r.AccountId IN: acctId and PRM_Contact__r.Core_Do_Not_Contact__c=false and PRM_Email_Handler_Status__c ='Requested For Suppression' and PRM_Event__c =:Event]){
            contactSuppressionMap.put(emailLog.PRM_Contact__c,emailLog);
        }
        return contactSuppressionMap;
    }
    
    public static void updateEmailHandlerDetails(List<PRM_Email_Handler__c> emailHandlerList){
        if(emailHandlerList!=null && !emailHandlerList.isEmpty()){
            //List<Database.SaveResult> results = 
                Database.update(emailHandlerList,false);
        }
    }
}