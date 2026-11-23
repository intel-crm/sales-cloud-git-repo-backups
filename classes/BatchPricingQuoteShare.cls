public without sharing class BatchPricingQuoteShare  implements Database.Batchable<sObject>{
    public List<Id> quoteIds;
    
    public Database.querylocator start(Database.BatchableContext bc){
        Set<Id> recordTypeId = new Set<Id>();
        recordTypeId.add(Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c', Label.Pricing_Tender_Quote_RecordType_Edit));
        recordTypeId.add(Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c', Label.Pricing_Tender_Quote_RecordType_ReadOnly));
        recordTypeId.add(Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c', Label.Pricing_Tender_Quote_RecordType_Create));
        recordTypeId.add(Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c', Label.Pricing_Tender_Quote_RecordType_Submitted));
        recordTypeId.add(Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c', Label.Pricing_Small_Volume_Quote_Create));
        //recordTypeId.add(Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c', Label.Pricing_SSD_Quote_Create));
        //recordTypeId.add(Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c', Label.Pricing_PMem_Quote_Create));
        return Database.getQueryLocator([SELECT Id, SBQQ__Account__c from SBQQ__Quote__c WHERE Id IN:quoteIds and RecordTypeId IN : recordTypeId]);
    }
    public void execute(Database.BatchableContext bc, List<sObject> scope){
        try{
               Set<Id> ids = new Set <Id>();
               QuoteBusinessLogic.shareQuotes(scope);
        }catch(exception ex){Pricing_Tender_Utility.logError(ex);}
    }
    public void finish(Database.BatchableContext bc){
          // Get the batch job information
          AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
          FROM AsyncApexJob WHERE Id =:bc.getJobId()];
          // In future send email to L2 regarding batch status ??
    }
}