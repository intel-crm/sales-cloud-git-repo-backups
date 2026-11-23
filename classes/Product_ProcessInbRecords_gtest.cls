public class Product_ProcessInbRecords_gtest {
    @InvocableMethod(label = 'Invoke inbound staging processing' description = 'Process the Product_Inbound_Staging Records')
    public static void processInboundStagingRecords(list<string> Ids){  
        // Changed the method name and description
        list<Core_Products_Staging__c> inbMasterList = new  list<Core_Products_Staging__c>();
        set<string> epmIdSet = new set<string>();
        map<integer,string> vphProductNumberMap = new map<integer,string>();
        Integer vphCount = 1;
        Integer IntialCount = 1;   //Intially set to 1. The count will increase on completion of each queueble job.
        Boolean vplchInd = false; 
        String ipaasId;            
        Set<String> opnIDs = new Set<String>();
        Boolean bypass;
        
        if(!Ids.IsEmpty() && Ids != null){
            ipaasId = Ids[0];  //This is a unique load id which we get in every payload from Mule.
        }        
        if(string.isNotBlank(ipaasId)){
            for(AggregateResult inbRcrd: [select level_1_epm_id__c, count(id) from Product_Inbound_Staging__c where iPaaS_Load_ID__c = :ipaasId and Core_Hierarchy_ID__c = '43' and level_1_epm_id__c='98836' group by level_1_epm_id__c]){
                if(string.isNotBlank((string)inbRcrd.get('level_1_epm_id__c'))  ){
                    vphProductNumberMap.put(vphCount,(string)inbRcrd.get('level_1_epm_id__c') );
                    system.debug('vphProductNumberMap is .get() >>'+vphProductNumberMap.get(vphCount));
                    vphCount = vphCount + 1;                    
                }
            }
            if(vphProductNumberMap.size() == 0){
                vplchInd = true;
            }
        }
        // Invoking the Queueable job by passing only the level  Epm Ids
        if (vphProductNumberMap.size() > 0  || vplchInd == true ){
            system.debug('Inside execute queueable job '); 
            System.enqueueJob(new Product_stageQueueable_Parent(IntialCount,inbMasterList,vphProductNumberMap,vplchInd, ipaasId,opnIDs,bypass));
        }        
    }
}