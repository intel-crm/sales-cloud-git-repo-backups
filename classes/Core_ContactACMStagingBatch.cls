public with sharing class Core_ContactACMStagingBatch implements Database.Batchable<sObject> ,Database.Stateful {
    
    private List<Core_ACM_Contact_Staging__c> sucesssResponseACMStagingList = new List<Core_ACM_Contact_Staging__c>();
    private Set<Id> failedACMStagingSet = new Set<Id>();
    private Set<Id> failedACMStagingIdSet = new Set<Id>();
    private Set<Id> SuccessfulACMStagingIdSet = new Set<Id>();
    private Integer retryCounter;
    private List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
    private Map<Id,Core_ACM_Contact_Staging__c> allACMContactStaging = new Map<Id,Core_ACM_Contact_Staging__c>();
    
    public Core_ContactACMStagingBatch() {
        this.retryCounter = 0;
    }
    public Core_ContactACMStagingBatch(Set<Id> failedACMStagingIdSet,Integer retryCounter){
        this.failedACMStagingIdSet = failedACMStagingIdSet;
        this.retryCounter = retryCounter + 1;
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        if(failedACMStagingIdSet.size()>0){
            return Database.getQueryLocator([SELECT id,ContactId__c,Contact_Action_Reference__c,Core_Action__c,Core_Status__c,Status_Details__c,Core_Retry_Counter__c FROM Core_ACM_Contact_Staging__c WHERE Id IN:failedACMStagingIdSet ]);
        }else{
            return Database.getQueryLocator([SELECT id,ContactId__c,Contact_Action_Reference__c,Core_Action__c,Core_Status__c,Status_Details__c,Core_Retry_Counter__c FROM Core_ACM_Contact_Staging__c WHERE Core_Status__c = 'NEW']);
        }
    }
    
    public void execute(Database.BatchableContext BC, List<Core_ACM_Contact_Staging__c> mergeRec){
        if(mergeRec.size()>0){
            Set<Id> ACMContactStagingIdSet = new Set<Id>();
            for(Core_ACM_Contact_Staging__c contact : mergeRec){
                try{
                    if(contact.Core_Action__c == 'CM' && contact.ContactId__c != null){
                        ACMContactStagingIdSet.add(contact.ContactId__c);
                        allACMContactStaging.put(contact.ContactId__c,contact);
                    }
                    /*Map<String, Set<id>> relatedObjectResults = ACM_DeleteDupsOnContactMergeHandler.deleteRelatedRecords(ACMContactStagingIdSet);
if(relatedObjectResults.get('Failed') != null){
failedACMStagingSet.addAll(relatedObjectResults.get('Failed'));
}
if(relatedObjectResults.get('Success') != null){
SuccessfulACMStagingIdSet.addAll(relatedObjectResults.get('Success'));
}
Map<String, Set<id>> projectSupportResults = ACM_DeleteDupsOnContactMergeHandler.deleteDupsOnPrmrSupportProjMem(ACMContactStagingIdSet);
if(projectSupportResults.get('Failed') != null){
failedACMStagingSet.addAll(projectSupportResults.get('Failed'));
}
if(projectSupportResults.get('Success') != null){
SuccessfulACMStagingIdSet.addAll(projectSupportResults.get('Success'));
}*/
                    
                    Map<String, Set<id>> partnerRequestresults = ACM_DeleteDupsOnContactMergeHandler.deleteDupsOnPrtnrCommEnrmntReq(ACMContactStagingIdSet);
                    if(partnerRequestresults.get('Failed') != null){
                        failedACMStagingSet.addAll(partnerRequestresults.get('Failed'));
                    }
                    if(partnerRequestresults.get('Success') != null){
                        SuccessfulACMStagingIdSet.addAll(partnerRequestresults.get('Success'));
                    }
                    
                    Map<String, Set<id>> inquiryResults = ACM_DeleteDupsOnContactMergeHandler.deleteDupsOnInquiry(ACMContactStagingIdSet);
                    if(inquiryResults.get('Failed') != null){
                        failedACMStagingSet.addAll(inquiryResults.get('Failed'));
                    }
                    if(inquiryResults.get('Success') != null){
                        SuccessfulACMStagingIdSet.addAll(inquiryResults.get('Success'));
                    }
                    
                    Map<String, Set<id>> subscriptionResults = ACM_DeleteDupsOnContactMergeHandler.deleteDupsOnContSubscription(ACMContactStagingIdSet);
                    if(subscriptionResults.get('Failed') != null){
                        failedACMStagingSet.addAll(subscriptionResults.get('Failed'));
                    }
                    if(subscriptionResults.get('Success') != null){
                        SuccessfulACMStagingIdSet.addAll(subscriptionResults.get('Success'));
                    }
                    
                    Map<String, Set<id>> engagementResults = ACM_DeleteDupsOnContactMergeHandler.deleteDupsOnContEngagement(ACMContactStagingIdSet);
                    if(engagementResults.get('Failed') != null){
                        failedACMStagingSet.addAll(engagementResults.get('Failed'));
                    }
                    if(engagementResults.get('Success') != null){
                        SuccessfulACMStagingIdSet.addAll(engagementResults.get('Success'));
                    }
                    
                    
                }catch(Exception e){
                    logEntries.add(new Core_Log_Entry__c(Core_Message__c = e.getMessage(), Core_Origin__c='Core_ContactACMStagingBatch', Core_Severity__c='High', Core_When__c=System.Now(), Core_Project__c = 'Sales Evolve'));
                }
            }
            
        }
    }
    
    public void finish(Database.BatchableContext BC){
        List<Core_ACM_Contact_Staging__c> failedStaging = new List<Core_ACM_Contact_Staging__c>();
        List<Core_ACM_Contact_Staging__c> successStaging = new List<Core_ACM_Contact_Staging__c>();
        
        if(SuccessfulACMStagingIdSet.size()>0){
            for(Id success :SuccessfulACMStagingIdSet){
                successStaging.add(updateACMStage(allACMContactStaging.get(success).Id,'COMPLETED'));
            }
            update successStaging;
        }
        if(failedACMStagingSet.size()>0){
            for(Id failed : failedACMStagingSet){
                failedStaging.add(updateACMStage(allACMContactStaging.get(failed).Id,'FAILED'));
                failedACMStagingIdSet.add(allACMContactStaging.get(failed).Id);
            }
            update failedStaging;
            // Retry Will be Processed From Here Upto 3 Times
            if(retryCounter < 3){
                Core_ContactACMStagingBatch MergeBatch = new Core_ContactACMStagingBatch(failedACMStagingIdSet,retryCounter);
                Database.ExecuteBatch(MergeBatch,5);
            }
        }
        if(logEntries.size()>0){
            insert logEntries;
        }
        
    }
    private static Core_ACM_Contact_Staging__c updateACMStage(Id stagId, String Status){
        Core_ACM_Contact_Staging__c staging = new Core_ACM_Contact_Staging__c();
        staging.Id = stagId;
        staging.Core_Status__c = Status;
        return staging;
    }
}