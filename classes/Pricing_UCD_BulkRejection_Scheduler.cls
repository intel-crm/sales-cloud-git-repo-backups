/**
 * @description       : 
 * @author            : Bharath Chandrashekar
 * @group             : 
 * @last modified on  : 01-20-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class Pricing_UCD_BulkRejection_Scheduler implements Schedulable{
    public void execute(SchedulableContext sc) {
        Pricing_UCD_IQR_BulkAutoRejection_Batch ucdBatch = new Pricing_UCD_IQR_BulkAutoRejection_Batch();
        database.executeBatch(ucdBatch, Integer.valueof(Label.Pricing_UCD_Bulk_Auto_Reject_Batch_Size));

        Pricing_IntegrationInboundRetryBatch integrationInboundRetryBatch = new Pricing_IntegrationInboundRetryBatch();
        Database.executeBatch(integrationInboundRetryBatch, Integer.valueof(Label.Pricing_IntegrationRetryBatchSize));

        Pricing_QuoteLetterGenerate_Batch PricingQuoteLetterGenerateBatch = new Pricing_QuoteLetterGenerate_Batch();
        Database.executeBatch(PricingQuoteLetterGenerateBatch, Integer.valueof(Label.Pricing_QuoteLetterGenerate_BatchSize));
    }
}