/**
* @description       : We have created a Batchable class to Update Status to Denied based on Expiry date.
* @author            : Priyanka Mishra
* @group             : Software & Services
* @last modified on  : 08-30-2024
* @last modified by  : Priyanka Mishra
**/

global class Pricing_sw_QuoteExpiryBatch implements Database.Batchable<SObject>, Database.Stateful,Schedulable {

    Map<Id, SBQQ__Quote__c> quoteToUpdateMap = new Map<Id, SBQQ__Quote__c>();

    public Database.QueryLocator start(Database.BatchableContext BC) { 
        return Database.getQueryLocator([
            SELECT Id, Name, Pricing_SW_Expiry_Date__c, SBQQ__Primary__c, SBQQ__Status__c, ApprovalStatus__c, OwnerId 
            FROM SBQQ__Quote__c
            WHERE Pricing_Quote_Program_Nm__c = :Label.Pricing_Program_Code_Software
                AND SBQQ__Primary__c = true
                AND ApprovalStatus__c = 'Approved'
                AND SBQQ__Status__c = 'Approved'
                AND Pricing_SW_Expiry_Date__c <= :Date.today() //.addDays(-5)
        ]);
    }

public void execute(Database.BatchableContext BC, List<SObject> records){
   
    try{
        for (SBQQ__Quote__c quote : (List<SBQQ__Quote__c>)records){
            // Update status to 'Denied'
            quote.SBQQ__Status__c = 'Denied';
            quoteToUpdateMap.put(quote.Id, quote);
        }        
        if (!quoteToUpdateMap.isEmpty()) {
            SBQQ.TriggerControl.disable();
            Database.update(quoteToUpdateMap.values(), false);
            SBQQ.TriggerControl.enable();
        }          
    }catch(exception ex) {
        Pricing_Tender_Utility.logErrorPricingSW(ex);
    }    
}
public void finish(Database.BatchableContext BC){ 

}
public void execute(SchedulableContext SC) {
    Database.executeBatch(new Pricing_sw_QuoteexpiryBatch(),integer.valueof(Label.Pricing_Sw_Exprixy_BatchSize));
}
}