public class CSF_Product_CreateLogEntriesBatch implements Database.Batchable<sObject>,Database.Stateful {
    public string ipaasId;
    public String uniqueKeyValue;
    public String loadIdStr;
    public String uniqueKey;
    Public String query;
    List<Product_Inbound_Staging__c> loadIdList = new List<Product_Inbound_Staging__c>();   
    List<Product_Log_Entry__c> prodLogEntriesList = new List<Product_Log_Entry__c>();
    
    
    public CSF_Product_CreateLogEntriesBatch(String ipaasLoadId){
        prodLogEntriesList = [select Id,EPM_Id__c,Ipaas_LoadId__c,Product_Name__c,Logging_Type__c,Message__c,Method_Name__c,Class_Name__c,Unique_ID__c from Product_Log_Entry__c where Logging_Type__c IN ('OPN_Deactivation', 'Status_Deactivation')];
        this.ipaasId = ipaasLoadId;
        
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        if(!String.isEmpty(ipaasId)){
            query = 'SELECT id,name,core_Logging_Type__c,Core_Hierarchy_ID__c,Core_Product_Name__c,Core_Product_Name_EPM_ID__c,Core_Product_Group_EPM_ID__c,Core_Code_Name_EPM_ID__c,iPaaS_Load_ID__c,Core_Product_Org__c,Core_Unique_ID__c,LastModifiedDate FROM Core_Products_Staging__c WHERE iPaaS_Load_ID__c =: ipaasId AND Core_Product_Org__c=\'Sales\' AND core_Logging_Type__c IN(\'OPN_Deactivation\', \'Status_Deactivation\')';
        }else{
            query = 'SELECT id,name,core_Logging_Type__c,Core_Hierarchy_ID__c,Core_Product_Name__c,Core_Product_Name_EPM_ID__c,Core_Product_Group_EPM_ID__c,Core_Code_Name_EPM_ID__c,iPaaS_Load_ID__c,Core_Product_Org__c,Core_Unique_ID__c,LastModifiedDate FROM Core_Products_Staging__c WHERE Core_Product_Org__c=\'Sales\' AND core_Logging_Type__c IN(\'OPN_Deactivation\', \'Status_Deactivation\')';
        }        
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Core_Products_Staging__c> stgRecords){
        Set<String> logEntryRecSet= new Set<String>();
        Map<String,Core_Products_Staging__c> stgRecMap = new Map<String,Core_Products_Staging__c>();
        Map<String,Product_Log_Entry__c> logEntryRecMap = new Map<String,Product_Log_Entry__c>();
        List<Product_Log_Entry__c> logEntryRecList = new List<Product_Log_Entry__c>();
        String query;
        try{
            
            for(Product_Log_Entry__c logRec:prodLogEntriesList){
                String uniqueKeyStr = logRec.EPM_Id__c+'_'+logRec.Logging_Type__c;
                logEntryRecSet.add(uniqueKeyStr);          
            }            
            for(Core_Products_Staging__c stgRec :stgRecords){
                if(stgRec.core_Logging_Type__c <> null){
                    String uniqueKeyValue = getUniqueKeyValue(stgRec);
                    if(String.isNotBlank(uniqueKeyValue)){
                        uniqueKey=uniqueKeyValue+'_'+stgRec.core_Logging_Type__c;
                        if(!logEntryRecSet.contains(uniqueKey)){                         
                            logEntryRecList.add(new Product_Log_Entry__c(Message__c=uniqueKey,Method_Name__c='execute',Class_Name__c='Product_CreateLogEntriesBatch',Ipaas_LoadId__c=stgRec.iPaaS_Load_ID__c,EPM_Id__c=stgRec.Core_Product_Name_EPM_ID__c,Logging_Type__c=stgRec.core_Logging_Type__c,Product_Name__c=stgRec.Core_Product_Name__c,Unique_ID__c=stgRec.Core_Unique_ID__c ));
                        }
                    }                    
                }                
            }
            
            if(logEntryRecList.size()>0 ){
                Database.insert(logEntryRecList);
            }
        }catch(Exception ex){
            Product_Utility.createLogEntryAndNotifyUser(ex.getMessage(),ipaasId,'Product_CreateLogEntriesBatch',null,null);
        }
    } 
    
    public void finish(Database.BatchableContext BC){
        Database.executeBatch(new Product_MM_Attribute_MappingBatch(ipaasId),2000);
    } 
    
    public static String getUniqueKeyValue(Core_Products_Staging__c stgRec) {
        String uniqueKeyValue;
        if(stgRec.Core_Hierarchy_ID__c == '43'){
            uniqueKeyValue = stgRec.Core_Unique_ID__c <> null ? stgRec.Core_Unique_ID__c : stgRec.Core_Product_Group_EPM_ID__c;                        
        }
        else if(stgRec.Core_Hierarchy_ID__c == '59'){
            uniqueKeyValue = stgRec.Core_Unique_ID__c <> null ? stgRec.Core_Unique_ID__c : stgRec.Core_Code_Name_EPM_ID__c;                        
        } 
        return uniqueKeyValue;
    }	
}