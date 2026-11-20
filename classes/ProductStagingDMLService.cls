/***************************************************************************************************************************
 * Class: ProductStagingDMLService
 * Purpose: Handles DML operations for Product_Inbound_Staging__c records
 *          (Single Responsibility: Only manages persistence of staging records)
 ****************************************************************************************************************************/
public class ProductStagingDMLService {

    public void upsertStagingRecords(List<Product_Inbound_Staging__c> listPis, String ipassLoadId) {
        if (listPis == null || listPis.isEmpty()) {
            return;
        }

        if (listPis.size() > 9995) {
            Database.executeBatch(new InsertDeltaProductsBatch(listPis, ipassLoadId), 2000);
        } else {
            Schema.SobjectField externalId;
            /*if(Test.isRunningTest()){
                externalId = Product_Inbound_Staging__c.Fields.Name;
            }else{
                externalId = Product_Inbound_Staging__c.Fields.Core_Unique_ID__c;
            }*/
            Database.saveResult[] listResult = Database.Insert(listPis, false);
            logErrors(listResult);
            Product_ProcessInboundStagingRecords.processInboundStagingRecords(new List<String>{ipassLoadId});
        }
    }

    /**
     * Upserts staging records without triggering downstream inbound-staging processing. Used by
     * chunk reprocessing so each page is persisted with bounded heap; the load is processed once
     * at the end of the run.
     */
    public void upsertStagingRecordsOnly(List<Product_Inbound_Staging__c> listPis, String ipassLoadId) {
        if (listPis == null || listPis.isEmpty()) {
            return;
        }
        Schema.SobjectField externalId;
        /*if(Test.isRunningTest()){
            externalId = Product_Inbound_Staging__c.Fields.Name;
        }else{
            externalId = Product_Inbound_Staging__c.Fields.Core_Unique_ID__c;
        }*/
        Database.saveResult[] listResult = Database.Insert(listPis, false);
        logErrors(listResult);
    }

    private void logErrors(Database.saveResult[] listResult) {
        List<Database.Error> listError = new List<Database.Error>();
        for (Database.saveResult dsr : listResult) {
            if (!dsr.isSuccess()) {
                listError.addAll(dsr.getErrors());
            }
        }
        if (!listError.isEmpty()) {
            UCD_ACM_Logger.error('ProductStagingDMLService', 'upsertStagingRecords', 'Upsert errors: ' + String.valueOf(listError.size()) + listError[0], null);
            UCD_ACM_Logger.setLogDetails();
        }
    }
}