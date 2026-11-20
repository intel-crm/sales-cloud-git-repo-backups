/***************************************************************************************************************************
Apex Class Name  : InsertDeltaProductsBatch
Author And Date  : Rohit Podder, 20 MAR 2026
Function         : This class is for inserting Product Inbound Staging records received from ProcessDeltaProductsQueueable 
				   class if the record count is more than 10k
****************************************************************************************************************************/
public class InsertDeltaProductsBatch implements Database.batchable<Product_Inbound_Staging__c> {
    List<Product_Inbound_Staging__c> listPis;
    String ipassLoadId;
    
    Public InsertDeltaProductsBatch (List<Product_Inbound_Staging__c> listPis, String ipassLoadId) {
        this.listPis = listPis;
        this.ipassLoadId = ipassLoadId;
    }
    
    Public Iterable<Product_Inbound_Staging__c> start(Database.BatchableContext bc) {
        return listPis;
    }
    
    public void execute(Database.BatchableContext bc, List<Product_Inbound_Staging__c> listPisToInsertUpsert) {
        DataBase.Error[] listError = new List<DataBase.Error>();
        Schema.SObjectField externalId = Product_Inbound_Staging__c.Fields.Core_Unique_ID__c;
        DataBase.UpsertResult[] listResult = DataBase.upsert(listPisToInsertUpsert, externalId, false);
       
        for (DataBase.UpsertResult dsr : listResult) {
            if (!dsr.isSuccess()) {
                listError.addAll(dsr.getErrors());
            }
        }
        if (!listError.isEmpty() && listError.size() > 0) {
            UCD_ACM_Logger.error('InsertDeltaProductsBatch','execute','Message: '+ listError.toString() ,null);
            UCD_ACM_Logger.setLogDetails();
        }                
    }
    
    public void finish(Database.BatchableContext bc) {
        Product_ProcessInboundStagingRecords.processInboundStagingRecords(new List<String>{ipassLoadId});       
    }    
}