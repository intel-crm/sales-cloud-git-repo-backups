@isTest(SeeAllData=false) 
public class Core_MDF_Claim_Utility_Test {

    @isTest static void validatereleaseHold()
    {
         //Test.startTest();
            List<Core_MDF_Currency_Exchange_Rates__c> newValues = new List<Core_MDF_Currency_Exchange_Rates__c>();
            Core_MDF_Currency_Exchange_Rates__c record1 = new Core_MDF_Currency_Exchange_Rates__c();
            record1.Name= 'ZMK';
            record1.Core_MDF_Exchange_Rate__c = 0.0000850159;
            record1.Core_MDF_Market_Date__c =System.today();
            record1.Core_MDF_Intel_WW__c = Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
            record1.Core_MDF_Unique_Key__c = 'ZMK'+Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
            newValues.add(record1);
            
            Core_MDF_Currency_Exchange_Rates__c record2 = new Core_MDF_Currency_Exchange_Rates__c();
            record2.Name= 'INR';
            record2.Core_MDF_Exchange_Rate__c = 1;
            record2.Core_MDF_Market_Date__c =System.today();
            record2.Core_MDF_Intel_WW__c = Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
            record2.Core_MDF_Unique_Key__c = 'INR'+Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
            newValues.add(record2); 
            
            Core_MDF_Currency_Exchange_Rates__c record3 = new Core_MDF_Currency_Exchange_Rates__c();
            record3.Name= 'USD';
            record3.Core_MDF_Exchange_Rate__c = 1;
            record3.Core_MDF_Market_Date__c =System.today();
            record3.Core_MDF_Intel_WW__c = Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
            record3.Core_MDF_Unique_Key__c = 'USD'+Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
            newValues.add(record3); 
            database.insert(newValues);
        
        List<Account> toBeUpdated = new List<Account>();
        
        // Creating channel program with utility class
        ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
        
        // Creating Account with utility class
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        
        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, true);
        
        Account acc3 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 3', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc2.Id, true);
        
    
        // Updating Accounts 
        acc1.isPartner = true;
        acc2.isPartner = true;
        acc3.isPartner = true;
        toBeUpdated.add(acc1);
        toBeUpdated.add(acc2);
        toBeUpdated.add(acc3);
        Database.update(toBeUpdated);
        
        PartnerMarketingBudget pbm = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget 2', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, acc2.Id, cp1.Id, 200000, System.today(),System.today().addDays(15), true);
        
        PartnerFundAllocation pfaRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test PFA', pbm, acc2, 30000, true);
    
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = systemAdminProfile.Id;
        Database.insert(usr);
        
        System.runAs(usr){
            
           
            pbm.IsIgnoreValidation = true;
            update pbm;
            
            PartnerFundAllocation pfa = [Select id, Amount from PartnerFundAllocation where BudgetId =: pbm.Id and Title='Test PFA' limit 1];
            System.debug('pfa here');
            System.debug(pfa.Id);
            System.debug(pfaRecord.Id);
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7 Processor', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today(), System.today().addDays(15), 10000, 'Always Connected PC', acc2.Id,'Desktop', true);
            
            PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(camp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,pfa,pbm,'INDIA','Consumer','Desktop','Intel® Corporate Logo','Broadcast','Podcast','Draft',true);
          //  testPartnerFundRequestRecord.Status = 'Approved';
          //  update testPartnerFundRequestRecord;
            
            
            
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1231231230');
            //Core_MDF_Account_Bank_Mapping__c accountBankMap = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc2.Id, bank.Id, true);
            //Test.stopTest(); 
            List<PartnerFundClaim> claimList1 = new List<PartnerFundClaim>();
            //Test.startTest();
            //PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today(), System.today(), 90000.00, System.today(), bank.Id, true);
            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today(), System.today(), 50000.00, System.today(), bank.Id, true);
            claim1.Core_MDF_Audit_Hold__c = true;
            claim1.Status= 'Submitted';
            claim1.Core_MDF_Status__c = 'Hold';
            claim1.Core_MDF_Claim_Previous_Status__c = 'Payment Due';
            Test.startTest();
            update claim1;
            claimList1.add(claim1);
            List<String> releaseReason = new List<String>();
            releaseReason.add(Label.Core_MDF_Audit_Hold);
            Core_MDF_Claim_Utility.releaseHold(claimList1,releaseReason);
            PartnerFundClaim claim = [SELECT Id, Status, Core_MDF_Status__c, Core_MDF_Audit_Hold__c, Core_MDF_ESD_Hold__c, Core_MDF_Claim_Previous_Status__c FROM PartnerFundClaim where Id = :claim1.Id];
            
            System.assertEquals(false, claim.Core_MDF_Audit_Hold__c);
            System.assertEquals('Approved', claim.Status);
            System.assertEquals('Payment Due', claim.Core_MDF_Status__c);
            System.assertEquals('Hold', claim.Core_MDF_Claim_Previous_Status__c);
            
            List<PartnerFundClaim> claimList2 = new List<PartnerFundClaim>();
            PartnerFundClaim claim2 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today(), System.today(), 500.00, System.today(), bank.Id, true);
            claim2.Core_MDF_ESD_Hold__c = true;
            claim2.Status= 'Submitted';
            claim2.Core_MDF_Status__c = 'Hold';
            claim2.Core_MDF_Claim_Previous_Status__c = 'Payment Due';
            update claim2;
            claimList2.add(claim2);
            List<String> releaseReason2 = new List<String>();
            releaseReason2.add(Label.Core_MDF_ESD_Hold);
            Core_MDF_Claim_Utility.releaseHold(claimList2,releaseReason2);
            PartnerFundClaim claim02 = [SELECT Id, Status, Core_MDF_Status__c, Core_MDF_Audit_Hold__c, Core_MDF_ESD_Hold__c, Core_MDF_Claim_Previous_Status__c FROM PartnerFundClaim where Id = :claim2.Id];
            
            System.assertEquals(false, claim02.Core_MDF_Audit_Hold__c);
            System.assertEquals('Approved', claim02.Status);
            System.assertEquals('Payment Due', claim02.Core_MDF_Status__c);
            System.assertEquals('Hold', claim02.Core_MDF_Claim_Previous_Status__c);
            
            List<PartnerFundClaim> claimList3 = new List<PartnerFundClaim>();
            PartnerFundClaim claim3 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today(), System.today(), 500.00, System.today(), bank.Id, true);
            claim3.Core_MDF_Audit_Hold__c = true;
            claim3.Core_MDF_ESD_Hold__c = true;
            claim3.Status= 'Submitted';
            claim3.Core_MDF_Status__c = 'Hold';
            claim3.Core_MDF_Claim_Previous_Status__c = 'Submitted';
            update claim3;
            claimList3.add(claim3);
            List<String> releaseReason3 = new List<String>();
            releaseReason3.add(Label.Core_MDF_Audit_Hold);
            Core_MDF_Claim_Utility.releaseHold(claimList3,releaseReason3);
            system.debug('dummy');
            PartnerFundClaim claim03 = [SELECT Id, Status, Core_MDF_Status__c, Core_MDF_Audit_Hold__c, Core_MDF_ESD_Hold__c, Core_MDF_Claim_Previous_Status__c FROM PartnerFundClaim where Id = :claim3.Id];
            
            System.assertEquals(false, claim03.Core_MDF_Audit_Hold__c);
            System.assertEquals('Submitted', claim03.Status);
            System.assertEquals('Hold', claim03.Core_MDF_Status__c);
            System.assertEquals('Submitted', claim03.Core_MDF_Claim_Previous_Status__c);
            
            List<PartnerFundClaim> claimList4 = new List<PartnerFundClaim>();
            PartnerFundClaim claim4 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today(), System.today(), 500.00, System.today(), bank.Id, true);
            claim4.Core_MDF_Audit_Hold__c = true;
            claim4.Core_MDF_ESD_Hold__c = true;
            claim4.Status= 'Submitted';
            claim4.Core_MDF_Status__c = 'Hold';
            claim4.Core_MDF_Claim_Previous_Status__c = 'Payment Due';
            update claim4;
            claimList4.add(claim4);
            List<String> releaseReason4 = new List<String>();
            releaseReason4.add(Label.Core_MDF_Audit_Hold);
            releaseReason4.add(Label.Core_MDF_ESD_Hold);
            Core_MDF_Claim_Utility.releaseHold(claimList4,releaseReason4);
            PartnerFundClaim claim04 = [SELECT Id, Status, Core_MDF_Status__c, Core_MDF_Audit_Hold__c, Core_MDF_ESD_Hold__c, Core_MDF_Claim_Previous_Status__c FROM PartnerFundClaim where Id = :claim4.Id];
            
            System.assertEquals(false, claim04.Core_MDF_Audit_Hold__c);
            System.assertEquals('Approved', claim04.Status);
            System.assertEquals('Payment Due', claim04.Core_MDF_Status__c);
            System.assertEquals('Hold', claim04.Core_MDF_Claim_Previous_Status__c);
            
            PartnerFundClaim claim05 = [SELECT Id, Status, Core_MDF_Status__c, Core_MDF_Audit_Hold__c, Core_MDF_ESD_Hold__c, Core_MDF_Claim_Previous_Status__c FROM PartnerFundClaim where Id = :claim4.Id];
            claim05.Core_MDF_Status__c = Label.Core_MDF_Status_Paid;
            update claim05;
            
            PartnerFundClaim claim06 = [SELECT Id, Status, Core_MDF_Status__c, Core_MDF_Audit_Hold__c, Core_MDF_ESD_Hold__c, Core_MDF_Claim_Previous_Status__c FROM PartnerFundClaim where Id = :claim4.Id];
            claim06.Core_MDF_Status__c = Label.Core_MDF_Status_Denied;
            update claim06;
            Test.stopTest(); 
            
        }
        
    }
}