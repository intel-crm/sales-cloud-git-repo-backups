//Added by Gopi(Agate Team) as a part Suppress Email functionality from Userstory TWC729-174
public with sharing class PRM_Email_Handler_Utility {
    public static Final String ORIGIN  = 'PRM_Email_Handler_Utility';
    public static Final String SEVERITY  = 'Critical';
    public static Final String PROJECT  = 'IPA';
    public static Final String ERROR  = System.label.PRM_Log_Entry_Error_Object_Level;
    public static Final String DETAILS  = System.label.PRM_Log_Entry_Details_Object_Level;
    public static final String SYM_SEMICOL = ';';
    public static String logEntryMsgString='';
    public static Boolean checkForEmailSupression(Id conId, String Event){
        Boolean supressEmail = false;
        System.debug('Entered checkForEmailSupression method');
        //System.debug('Email Parameter'+Email);
        System.debug('Event Parameter'+Event);
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
            if(emailHandlerRecordsToUpdate!=null && !emailHandlerRecordsToUpdate.isEmpty() ){ 
              //  List<Database.SaveResult> results = Database.update(emailHandlerRecordsToUpdate,false);
               List<Database.SaveResult> results = Database.update(emailHandlerRecordsToUpdate,false);

               // PRM_DMLUtility.doupdate(emailHandlerRecordsToUpdate, 'PRM_Email_Handler__c', 'PRM_Email_Handler_Utility.checkForEmailSupression');
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
            List<Database.SaveResult> results = Database.update(emailHandlerList,false);
        }
    }
}