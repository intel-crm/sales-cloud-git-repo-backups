/****************************************************************************************************************************************
* Class Name  : PCC_PartnerLedPriceMappingBatch 
* Version     : 1.0 
* Created Date:  01-08-2024
* Modification Log :
* Developer                   Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
Aravind                       01-08-2024         Created
*****************************************************************************************************************************************/
public with sharing class PCC_PartnerLedPriceMappingBatch implements Database.Batchable<sObject>{

      public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'Select Id,PCC_Material_Master__c from PCC_ParnterLed_Price__c';
        return Database.getQueryLocator( query );
    }
    
    public void execute(Database.BatchableContext BC, List<PCC_ParnterLed_Price__c> priceData){
        Set<String> mmIds = new Set<String>();
        Map<String,Product_MM_Attribute_Mapping__c> attributeMap = new  Map<String,Product_MM_Attribute_Mapping__c>();

        for (PCC_ParnterLed_Price__c pp : priceData) {
            mmIds.add(pp.PCC_Material_Master__c);
        }

        for (Product_MM_Attribute_Mapping__c mmRec: [Select Id,Name,L4_Product__c,L5_Product__c FROM Product_MM_Attribute_Mapping__c WHERE Name in: mmIds and IsActive__c = true]) {
            attributeMap.put(mmRec.Name,mmRec);
        }

        for (PCC_ParnterLed_Price__c pp : priceData) {
           if (attributeMap.containsKey(pp.PCC_Material_Master__c)) {
                pp.PCC_Product_MM_Attribute_Mapping__c = attributeMap.get(pp.PCC_Material_Master__c).Id;
                pp.PCC_L4_Product__c = attributeMap.get(pp.PCC_Material_Master__c).L4_Product__c;
                pp.PCC_L5_Product__c = attributeMap.get(pp.PCC_Material_Master__c).L5_Product__c;
           }
        }
        
        Database.update(priceData,false);

    }
    // Finish method
    public void finish(Database.BatchableContext BC){

    }
}