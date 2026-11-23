@isTest
public class Retail_CPQ_QuoteLineBusinessLogic_Test {
    @isTest
    private static void quotelineLogic(){
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
        // Test.startTest();
         q.RecordTypeId =  PSG_Utility.getRecordTypeId('SBQQ__Quote__c', label.Retail_CPQ_Quote_Save_RecordType);
         insert q;
         quoteList.add(q);
        List< Product2> rsaproducts =Retail_CPQ_TestDataSetup.createRSAproducts();
        insert rsaproducts;
        List<SBQQ__QuoteLine__c> qlList = New List <SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c ql = Retail_CPQ_TestDataSetup.createQuoteLineRSA();
         ql.RecordTypeId =  PSG_Utility.getRecordTypeId('SBQQ__QuoteLine__c', 'Retail_Quote_Line_Base_RSA');
       //ql.RecordTypeId ='0122D000002WBBDQA4';
        ql.SBQQ__Product__c=rsaproducts[0].Id;
        ql.SBQQ__Quote__c=q.Id;
       
        insert ql;
        //qlList.add(ql); 
        Id qlId= ql.Id;
        Test.startTest();
        qlList = [select id,Name,SBQQ__Product__c,SBQQ__Quantity__c,SBQQ__Quote__c from SBQQ__QuoteLine__c where Id=:qlId];
	 Retail_CPQ_QuoteLineBusinessLogic.afterInsertUpdateOperations(qlList,true,null,null);
	 Test.stopTest();
         
     /*   SBQQ__DiscountSchedule__c ds = Retail_CPQ_TestDataSetup.creatediscountschedule();
	ds.Name='DS-123';
	 ds.SBQQ__Quote__c = ql.SBQQ__Quote__c;
     ds.SBQQ__QuoteLine__c =ql.Id;
       // ql.SBQQ__DiscountSchedule__c= ds.Id;
	 insert ds;
        system.debug('DS inserted');
        SBQQ__DiscountTier__c dt1 = Retail_CPQ_TestDataSetup.creatediscounttier();
	dt1.SBQQ__Schedule__c=ds.Id;
      //  ql.SBQQ__DiscountTier__c= dt1.Id;
        insert dt1;
        qlList.add(ql); 
        system.debug('DT inserted');
        system.debug('QL list is '+qlList);
     Test.startTest();
	 Retail_CPQ_QuoteLineBusinessLogic.afterInsertUpdateOperations(qlList,true,null,null);
	 Test.stopTest();
       //  Retail_CPQ_QuoteBusinessLogic.updateQuotefields(quoteList);
        // Test.stopTest(); 
        // //0122D000002WBBDQA4
       
      //  SBQQ__Quote__c q1=[select id from SBQQ__Quote__c where name='Q-11957' ];
        //quotelist.add(q1);
        //system.debug('Quote  list is '+quotelist);
        //*/
        }

}