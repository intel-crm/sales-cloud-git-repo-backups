public with sharing class Core_ContactGECBatch implements Database.Batchable<sObject> ,Database.Stateful,Database.AllowsCallouts {
    
    private String agsEndPointURL;
    private String agsAccessToken;
    private List<Core_Contact_GEC_Staging__c> sucessResponseGECStagingList = new List<Core_Contact_GEC_Staging__c>();
    private Map<Id,Core_Contact_GEC_Staging__c> failedGECStagingMap = new Map<Id,Core_Contact_GEC_Staging__c>();
    private Set<Id> failedGECStagingIdSet = new Set<Id>();
    private Integer retryCounter;
    private List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
    
    public Core_ContactGECBatch() {
        this.retryCounter = 0;
    }
    public Core_ContactGECBatch(Set<Id> failedGECStagingIdSet,Integer retryCounter){
        this.failedGECStagingIdSet = failedGECStagingIdSet;
        this.retryCounter = retryCounter + 1;
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        if(failedGECStagingIdSet.size()>0){
            return Database.getQueryLocator([SELECT id,Core_Contact_ID__c,Core_Status__c,Core_Contact_WWID__c,Core_GEC_Blocked__c,Core_GEC_Blocked_Reason__c,Core_Response__c,Core_GEC_Retry_Counter__c FROM Core_Contact_GEC_Staging__c WHERE Id IN:failedGECStagingIdSet]);
        }else{
            return Database.getQueryLocator([SELECT id,Core_Contact_ID__c,Core_Status__c,Core_Contact_WWID__c,Core_GEC_Blocked__c,Core_GEC_Blocked_Reason__c,Core_Response__c,Core_GEC_Retry_Counter__c FROM Core_Contact_GEC_Staging__c WHERE Core_Status__c = 'New' LIMIT :Integer.valueOf(System.Label.Core_ContactGECBatch_LIMIT)]);
        }
    }
    
    public void execute(Database.BatchableContext BC, List<Core_Contact_GEC_Staging__c> gecRec){
        if(gecRec.size()>0){
            
            for(Core_Contact_GEC_Staging__c gec : gecRec){
                try{
                    String ContactJSONRes= Core_ContactGEC_Service.ContactGECJSON(gec.Core_Contact_WWID__c,gec.Core_GEC_Blocked_Reason__c,gec.Core_GEC_Blocked__c,gec.Core_Contact_ID__c);
                    HttpResponse response = Core_ContactGEC_Service.SendGECInfoTOAGS(gec,ContactJSONRes);
                    if(response != null && response.getStatusCode() == 200){
                        sucessResponseGECStagingList.add(updateGecStagingRecord(gec.Id,'Successful',response.getBody(),ContactJSONRes,retryCounter));
                    }else{
                        if(response == null){
                            failedGECStagingMap.put(gec.Id,updateGecStagingRecord(gec.Id,'Failed','Timed Out',ContactJSONRes,retryCounter));
                        }else{
                            String responseMessage = response.getStatusCode() == 400 ?(String)((Map<String, Object>)((List<Object>)((Map<String, Object>)JSON.deserializeUntyped(response.getBody())).get('Errors'))[0]).get('message') : '';
                            if(responseMessage == 'User Not Found'){
                                sucessResponseGECStagingList.add(updateGecStagingRecord(gec.Id,'Failed',response.getBody(),ContactJSONRes,retryCounter));
                            }else{
                                failedGECStagingMap.put(gec.Id,updateGecStagingRecord(gec.Id,'Failed',response.getBody(),ContactJSONRes,retryCounter));
                            }
                        }
                    }
                    
                }catch(Exception e){
                    logEntries.add(new Core_Log_Entry__c(Core_Message__c = e.getMessage(), Core_Origin__c='Core_ContactGECBatch', Core_Severity__c='High', Core_When__c=System.Now(), Core_Project__c = 'Sales Evolve'));
                }
            }
        }
    }
    
    public void finish(Database.BatchableContext BC){
        if(sucessResponseGECStagingList.size()>0){
            update sucessResponseGECStagingList;
        }
        if(failedGECStagingMap.size()>0){
            update failedGECStagingMap.values();
            // Retry Will be Processed From Here Upto 3 Times
            if(retryCounter < 3){
                Core_ContactGECBatch GECBatch = new Core_ContactGECBatch(failedGECStagingMap.keySet(),retryCounter);
                Database.ExecuteBatch(GECBatch,5);
            }
        }
        if(logEntries.size()>0){
            insert logEntries;
        }
        
    }
    private static Core_Contact_GEC_Staging__c updateGecStagingRecord(Id gecStagingId,String status,String response,String ContactJSONRes, Integer gecRetryCounter){
        return new Core_Contact_GEC_Staging__c(Id = gecStagingId,Core_Status__c=status,Core_GEC_Retry_Counter__c = gecRetryCounter,
                                               Core_Payload__c=ContactJSONRes,Core_Response__c=response);   
    }
    
}