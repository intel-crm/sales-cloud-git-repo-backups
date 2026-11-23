@isTest
public class Retail_CPQ_QuoteBusinessLogic_Test {
    @isTest
     private static void quoteLogic(){
         List<SBQQ__Quote__c> quoteList = New List <SBQQ__Quote__c>();
     Account acc = Retail_CPQ_TestDataSetup.createAccount();
         acc.Core_MDF_CoMarketingActive__c = true;
     insert acc;
         System.debug('account inserted');
      Core_MDF_Bank__c bank = Retail_CPQ_TestDataSetup.createBankRecord();
         bank.Core_MDF_Account__c = acc.id;
         insert bank ;
         
         SBQQ__Quote__c q = Retail_CPQ_TestDataSetup.createQuoteRecord();
         q.core_cpq_Account__c = acc.id;
         Test.startTest();
         q.RecordTypeId =  PSG_Utility.getRecordTypeId('SBQQ__Quote__c', label.Retail_CPQ_Quote_Save_RecordType);
         insert q;
         quoteList.add(q);
         Retail_CPQ_QuoteBusinessLogic.updateQuotefields(quoteList);
         Test.stopTest();
     }
}