Public class Product_insStgngRcrdsBatch_IPS implements Database.Batchable<sObject>{
    
    public Integer count;
    public List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();       
    public list<Core_Products_Staging__c> masterList = new list<Core_Products_Staging__c>();
    public list<Core_Products_Staging__c> dummymasterList = new list<Core_Products_Staging__c>();
    public Map<integer,Product_ProcessInboundStagingRecords.InputWrapper> inputWrapperMap = new Map<integer,Product_ProcessInboundStagingRecords.InputWrapper>();
    public Boolean vplchInd ;
    public string ipaasId ;
    public Set<String> opnIDs = new Set<String>();
    
    public List<Core_Products_Staging__c> stagingRecordsImported = new List<Core_Products_Staging__c>();
    public List<Core_Products_Staging__c> stagingRecordsToInsert= new List<Core_Products_Staging__c>();
    public List<Core_Products_Staging__c> stagingRecordsIpsVplch = new List<Core_Products_Staging__c>();
    public List<Core_Log_Entry__c> captureQueryErr = new List<Core_Log_Entry__c>();
    public String ipaasLoadId;
    
    public Product_insStgngRcrdsBatch_IPS(Integer i,list<Core_Products_Staging__c> masterListinb,Map<Integer,Product_ProcessInboundStagingRecords.InputWrapper> inputWrapperMap, Boolean vplchInd, string ipaasId, Set<String> opnLst){
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
                for(Core_Products_Staging__c stageRec : stagingRecordsImported){
                    if(stageRec.Core_Product_Org__c=='IPS' && stageRec.Core_Hierarchy_ID__c=='59'){
                        stagingRecordsIpsVplch.add(stageRec);
                    }
                    else{
                        stagingRecordsToInsert.add(stageRec);
                    }
                }

                Database.SaveResult [] results= Database.insert(stagingRecordsToInsert,false);
                Database.UpsertResult [] results1;
                if(!stagingRecordsIpsVplch.isEmpty()){
                    results1 = Database.upsert(stagingRecordsIpsVplch,Core_Products_Staging__c.Unique_Value__c, false); 
                }
                
                //insert stagingRecordsImported;
                for(Database.SaveResult sr : results ) {
                    if(!sr.isSuccess()){
                        logEntries.add(new Core_Log_Entry__c(Core_Details__c = sr.getErrors()[0].getMessage(),Core_XID__c = ipaasLoadId,Core_Message__c = 'Core_Products_Staging__c insert '+sr.getErrors()[0].getMessage(),Core_Severity__c = 'High',Core_Project__c='Product',Core_Origin__c='Product_insStgngRcrdsBatch',Core_When__c = System.now(),Core_sObjectId__c = sr.getId()));                    
                    }
                }
                for(Database.UpsertResult sr : results1 ) {
                    if(!sr.isSuccess()){
                        logEntries.add(new Core_Log_Entry__c(Core_Details__c = sr.getErrors()[0].getMessage(),Core_XID__c = ipaasLoadId,Core_Message__c = 'Core_Products_Staging__c upsert '+sr.getErrors()[0].getMessage(),Core_Severity__c = 'High',Core_Project__c='Product',Core_Origin__c='Product_insStgngRcrdsBatch',Core_When__c = System.now(),Core_sObjectId__c = sr.getId()));                    
                    }
                }
                system.debug('logEntries >>'+logEntries);
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