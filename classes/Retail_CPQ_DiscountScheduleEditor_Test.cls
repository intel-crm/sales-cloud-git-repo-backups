@isTest
public class Retail_CPQ_DiscountScheduleEditor_Test {
	@TestSetup
    public static void setUpData(){
         SBQQ.TriggerControl.disable();       
        List<SBQQ__Quote__c> quoteList = New List <SBQQ__Quote__c>();
        Account acc = Retail_CPQ_TestDataSetup.createAccount();
        acc.Core_MDF_CoMarketingActive__c = true;
        insert acc;
        System.debug('account inserted');
        Core_MDF_Bank__c bank = Retail_CPQ_TestDataSetup.createBankRecord();
        bank.Core_MDF_Account__c = acc.id;
        insert bank ;
        SBQQ__Quote__c q = Retail_CPQ_TestDataSetup.createQuoteRecord();
         List< Product2> rsaproducts =Retail_CPQ_TestDataSetup.createRSAproducts();
        q.core_cpq_Account__c = acc.id;
        // Test.startTest();
        q.RecordTypeId =  PSG_Utility.getRecordTypeId('SBQQ__Quote__c', label.Retail_CPQ_Quote_Save_RecordType);
        insert q;
        SBQQ__QuoteLine__c ql = Retail_CPQ_TestDataSetup.createQuoteLineRSA();
        ql.RecordTypeId =  PSG_Utility.getRecordTypeId('SBQQ__QuoteLine__c', 'Retail_Quote_Line_Base_RSA');
        ql.SBQQ__Product__c=rsaproducts[0].Id;
        ql.SBQQ__Quote__c=q.Id;
       
        insert ql;
        
        SBQQ__DiscountSchedule__c ds = Retail_CPQ_TestDataSetup.creatediscountschedule();
        ds.Name='DS-123';
        ds.SBQQ__Quote__c = ql.SBQQ__Quote__c;
        ds.SBQQ__QuoteLine__c =ql.Id;
        ql.SBQQ__DiscountSchedule__c= ds.Id;
        insert ds;
        system.debug('DS inserted');
        SBQQ__DiscountTier__c dt1 = Retail_CPQ_TestDataSetup.creatediscounttier();
        dt1.SBQQ__Schedule__c=ds.Id;
        ql.SBQQ__DiscountTier__c= dt1.Id;
        insert dt1;
        
    }
    @isTest
    public static void testCreateDiscountSchedule(){
         SBQQ.TriggerControl.disable();       
        List<SBQQ__QuoteLine__c> lstquoteLineList=[Select Id from SBQQ__QuoteLine__c];
        List < SBQQ__DiscountTier__c > tierLst = [Select Id from SBQQ__DiscountTier__c];
        Retail_CPQ_DiscountScheduleEditor.fetchDisconuntTiers(lstquoteLineList[0].Id);
        Retail_CPQ_DiscountScheduleEditor.addNewTier(lstquoteLineList[0].Id,tierLst);
        
        Retail_CPQ_DiscountScheduleEditor.updateTiers(lstquoteLineList[0].Id,tierLst);
        Retail_CPQ_DiscountScheduleEditor.deleteRecord(tierLst[0].Id);
    }    

}