@isTest
public class Core_BUMapping_Retry_Test {
    
    static testMethod void BuMappingRetry() {
        
        SObjectType r = ((SObject)Type.forName('Schema','Account').newInstance()).getSObjectType();
        Id recTypeId = r.getDescribe().getRecordTypeInfosByDeveloperName().get(Label.Pricing_Tender_Account_RecordType_IntelAccount).getRecordTypeId();
        
        Account testAcct = Core_Test_Utility.createAccount(1)[0];
        testAcct.RecordTypeId = recTypeId;
        testAcct.Core_Sales_Groups__c = 'Americas Brazil Sales Group';
        testAcct.Industry = 'Agriculture';
        testAcct.Core_Sub_Industry__c = 'Forestry';
        insert testAcct;
        
        // Simple test data
        Opportunity testOpp = Core_Test_Utility.createOpportunity(1)[0];
        testOpp.AccountId = testAcct.Id;
        insert testOpp;
        
        List<Product2> testProducts = Core_Test_Utility.createProduct(3);
        insert testProducts;
        
        List<PricebookEntry> testPBEs = Core_Test_Utility.createPriceBookEntry(3, testProducts, Test.getStandardPricebookId());
        insert testPBEs;
        
        // Insert these in a specific order that we can rely on, since we can only sort by ID value when querying them from the
        // opportunity product history object later (can't sort on Description or any other attribute)
        OpportunityLineItem testOppLineItem;
        testOppLineItem = new OpportunityLineItem(OpportunityId=testOpp.Id, PricebookEntryId=testPBEs[0].Id,
                                                  Description='Test 11', UnitPrice=11, Quantity=11,
                                                  Core_Loss_Cancel_Reason__c=null, Core_Status__c='Pending');
        insert testOppLineItem;
        List<ID> explst = new List<ID>();
        List<Core_Exceptions__c> ExceptionsLst = new List<Core_Exceptions__c>();
        Core_Exceptions__c excep=new Core_Exceptions__c();
        excep.Core_Class_Name__c='Core_OpportunityLineItem_BatchClass';
        excep.Core_Method_Name__c=' Execute method ';
        excep.Core_Record_Id__c=testOppLineItem.Id;
        excep.Core_Retry_Counter__c=1;
        excep.Core_Method_Name__c='Retry Method';
        excep.Core_Exception__c='Record Lock Exception';
        excep.Core_Status__c='Failed';
        excep.Core_Next_Scheduled_Run__c=System.now().addSeconds(60);
        insert excep;
        ExceptionsLst.add(excep);
        explst.add(excep.Id);
        Core_BUMapping_Retry.RetryFailedRecords(explst);
        Core_BUMapping_Retry.UpdateLogEntryRecordCounter(ExceptionsLst,'Record Lock Issue');
        List<OpportunityLineItem> oliList = [Select id from OpportunityLineItem where Core_BU_Mapping_record__c<>null limit 1];
        system.assertEquals(oliList.isEmpty(),True);
    }
    
    
}