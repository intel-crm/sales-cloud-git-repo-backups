trigger TestingQuoteTrigger  on SBQQ__Quote__c (after update) {
      List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
     for(SBQQ__Quote__c quoteRecord : (List<SBQQ__Quote__c>)Trigger.new){
         //Add opp = null && Program = PSG
       if(quoteRecord.SBQQ__Type__c == 'Amendment' ){
           quoteList.add(quoteRecord);
       }
     }  
    if(quoteList!= null && !quoteList.isEmpty()){
       QuoteRecordUpdate.updateContractforAmendmentQuotes(quoteList);
    }
}