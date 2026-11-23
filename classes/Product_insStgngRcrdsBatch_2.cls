Public class Product_insStgngRcrdsBatch_2 implements Database.Batchable<sObject>{
    
    public Integer count;
    public list<Core_Products_Staging__c> masterList = new list<Core_Products_Staging__c>();
    public list<Core_Products_Staging__c> dummymasterList = new list<Core_Products_Staging__c>();
    public Map<integer,string> vphProductNumberMap = new Map<integer,string>();
    public Boolean vplchInd ;
    public string ipaasId ;
    public Set<String> opnIDs = new Set<String>();

    public List<Core_Products_Staging__c> stagingRecordsImported = new List<Core_Products_Staging__c>();
    public List<Core_Log_Entry__c> captureQueryErr = new List<Core_Log_Entry__c>();
    public String ipaasLoadId;
    public Boolean bypass;
    /*
    public Product_insStgngRcrdsBatch_2(Integer i,list<Core_Products_Staging__c> masterListinb,Map<integer,string> numberMap, Boolean vplchInd, string ipaasId, Set<String> opnLst,Boolean bypass){
        this.count = i;
        this.vphProductNumberMap = numberMap ;
        this.vplchInd = vplchInd;
        this.opnIDs = opnLst;  
        this.stagingRecordsImported=masterListinb;
        this.ipaasLoadId=ipaasId;
    }   
    */ 
    public Product_insStgngRcrdsBatch_2(list<Core_Products_Staging__c> masterListinb, String ipaasId,Boolean bypass, Integer count){
        this.stagingRecordsImported=masterListinb;
        this.ipaasLoadId=ipaasId;        
        this.bypass = bypass;
        this.count = count;
    }
    public List<sObject> start(Database.BatchableContext bc) {
        System.debug('--------- inside start method ---------');
        return stagingRecordsImported;
    }
    
    public void execute(Database.BatchableContext BC, List<Core_Products_Staging__c> stagingRecordsImported){
        System.debug('--------- inside execute method ---------');
        system.debug('stagingRecordsImported cnt-----'+ stagingRecordsImported.size());
        //system.debug('The current count is  -----'+ count); 
        //system.debug('The current product is  -----'+ vphProductNumberMap.get(count));  
        system.debug('The start time of insert Staging batch >>>  -----'+ System.now());  
                
        if(!stagingRecordsImported.isEmpty()){
            Database.SaveResult [] insertStagingRecords= Database.insert(stagingRecordsImported,false);              
        }
    }
    public void finish(Database.BatchableContext BC){
        System.debug('--------- inside finish method ---------');
        stagingRecordsImported.clear();
        bypass = false;
        System.enqueueJob(new Product_stageQueueable_Parent(count+1,masterList,vphProductNumberMap,vplchInd,ipaasId,opnIDs,bypass));
    }
}