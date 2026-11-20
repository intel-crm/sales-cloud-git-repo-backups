Public with sharing class Product_insStgngRcrdsBatch implements Database.Batchable<sObject>{
    
    public Integer count;
    public list<Core_Products_Staging__c> masterList = new list<Core_Products_Staging__c>();
    public list<Core_Products_Staging__c> dummymasterList = new list<Core_Products_Staging__c>();
    public Map<integer,Product_ProcessInboundStagingRecords.InputWrapper> inputWrapperMap = new Map<integer,Product_ProcessInboundStagingRecords.InputWrapper>();
    public Boolean vplchInd ;
    public string ipaasId ;
    public Set<String> opnIDs = new Set<String>();
    
    public List<Core_Products_Staging__c> stagingRecordsImported = new List<Core_Products_Staging__c>();
    public List<Core_Log_Entry__c> captureQueryErr = new List<Core_Log_Entry__c>();
    public String ipaasLoadId;
    
    public Product_insStgngRcrdsBatch(Integer i,list<Core_Products_Staging__c> masterListinb,Map<Integer,Product_ProcessInboundStagingRecords.InputWrapper> inputWrapperMap, Boolean vplchInd, string ipaasId, Set<String> opnLst){
        this.count = i;
        this.inputWrapperMap = inputWrapperMap ;
        this.vplchInd = vplchInd;
        this.opnIDs = opnLst;  
        this.stagingRecordsImported=masterListinb;
        this.ipaasLoadId=ipaasId;
    }
    public List<sObject> start(Database.BatchableContext bc) {
        return stagingRecordsImported;
    }
    
    public void execute(Database.BatchableContext BC, List<Core_Products_Staging__c> stagingRecordsImported){
        //upsert the data received
        try{
            if(!stagingRecordsImported.isEmpty()){
                Database.SaveResult [] insertStagingRecords= Database.insert(stagingRecordsImported,false); 
            }
        }catch(Exception ex){
            Product_Utility.createLogEntryAndNotifyUser(ex.getMessage(),ipaasId,'Product_insStgngRcrdsBatch',null,null);
        }
    }
    public void finish(Database.BatchableContext BC){
        stagingRecordsImported.clear();    
        count = count +1;
        if(count <= inputWrapperMap.keySet().size() ){  
            System.enqueueJob(new Product_stageQueueable(count,masterList,inputWrapperMap,vplchInd,ipaasLoadId,opnIDs));
        }
        else if(count >  inputWrapperMap.keySet().size()  ){ 
            Database.executeBatch(new Product_upsertProduct2Records(ipaasId),Product_Staging_StaticConstants.Product_UpsertProduct2BatchSize);                      
        }     
    }
}