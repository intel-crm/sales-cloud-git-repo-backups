@isTest
public class PSG_CreatePRIDQueueable_Test {
    /*
    @testSetup static void testSetup(){
        SBQQ.TriggerControl.disable();
        Test.startTest();
        Account dc = PSG_Test_Utility.createDirectAccount();
        System.assert(dc!=null, 'Account');
        Account ac=PSG_Test_Utility.createAccount();
        ac.Core_Direct_Pricing_Parent_Id__c=dc.id;
        ac.Core_Direct_Legal_Parent_Id__c=dc.id;
        update ac;
        Contact con = PSG_Test_Utility.createContact(ac.Id);
        List<Account> accLst = PSG_Test_Utility.createRegionBasedAccount();
        Contact con1 = PSG_Test_Utility.createContactWithEmail(accLst[0].Id,'FirstName2@intel.com');
        Opportunity opp = PSG_Test_Utility.createOpportunity(ac.Id);
        Opportunity opp1 = PSG_Test_Utility.createOpportunity(ac.Id);
        List<core_cpq_bm_assignment_config__c> approverList = PSG_Test_Utility.createApprvRecord(dc.Id);
        PriceBook2 pb = PSG_Test_Utility.createPriceBook('apj');
        Test.stopTest();
    }
	public static testmethod void createQuoteRecords(){
        SBQQ.TriggerControl.disable();
        list<User> sosUser = PSG_Test_Utility.createDistyUser();
        PriceBook2 pb = [SELECT id FROM Pricebook2 limit 1];
        list<Opportunity> opp = [Select Id,AccountId FROM Opportunity limit 2];
        List<SBQQ__Quote__c> quoteList = new list<SBQQ__Quote__c>();
        Account accLst = [SELECT ID from Account limit 1];
        Contact con = [SELECT Id from Contact limit 1];
        List<Account> accs=[SELECT Id from Account where RecordType.Name='Intel Account' limit 10];
        List<Account> accsToUpdate=new List<Account>();
        Id recordtypeId=[SELECT Id,name,developername from RecordType where sobjecttype='Account' and Developername='Core_Direct_Account' LIMIT 1].Id;
        System.RunAs(sosUser[0]){
            System.assert(!sosUser.isEmpty(), 'Account');
            Account a1=PSG_Test_Utility.createDirectAccount();
            a1.RecordTypeId=recordtypeId;
            a1.Core_Direct_Account_Type_Nm__c='End Customer Parent';
            a1.Core_Is_Pricing_Parent_ChkBox__c=true;
            a1.Core_Direct_Account_Active_Ind__c=true;
            update a1;
            Test.startTest();
            Account a2=PSG_Test_Utility.createDirectAccount();
            a2.RecordTypeId=recordtypeId;
            a2.Core_Direct_Account_Type_Nm__c='End Customer Parent';
            a2.Core_Is_Pricing_Parent_ChkBox__c=true;
            a2.Core_Direct_Legal_Parent_Id__c=a1.Id;
            a2.Core_Direct_Account_Active_Ind__c=true;
            update a2;
            for(Integer i=0;i<1;i++){
                accs[i].Core_PSG_Account__c=true;
                accs[i].Core_Direct_Pricing_Parent_Id__c=a2.id;
                accs[i].Core_Direct_Legal_Parent_Id__c=a1.Id;
                accsToUpdate.add(accs[i]);
            }
            update accsToUpdate;
            SBQQ__Quote__C quote = PSG_Test_Utility.createQuoteRecord(accsToUpdate[0].id, opp[0].id);
            System.enqueueJob(new PSG_CreatePRIDQueueable(quote.Id));
            Test.stopTest();
        }
    }
    */
}