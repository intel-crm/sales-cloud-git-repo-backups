@isTest(SeeAllData = false)
public class Core_MDF_UpdateClaimOnBankHold_Test {
    
    // test method for data setup
    @TestSetup 
    static void setUpData(){
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        // Creating User with utility class 
        User testUser = Core_MDF_CCP_TestDataUtility.createUser(false);
        testUser.LastName = 'Test User';
        testUser.UserRoleId = usRole.Id;
        Database.insert(testUser);
        
        System.runAs(testUser){
            List<ChannelProgram> cpList = new List<ChannelProgram>();
            List<Account> accountList = new List<Account>();
            
            ChannelProgram ccpCP = Core_MDF_CCP_TestDataUtility.createProgram('Client Co-Marketing Fund', 'Client CoMarketing Fund', false);
            cpList.add(ccpCP); 
            Database.insert(cpList);
            Account ccpIntelAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('CCF Test Intel Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);            
            Account ccpCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('CCF Co-Marketing Account', ccpCP.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,ccpIntelAccount.id, false);
            accountList.add(ccpCoMarketingAccount);
            Database.insert(accountList);
            PartnerMarketingBudget pbm = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget MDF', Core_MDF_CCP_TestDataUtility.budget_Record_Type, ccpCoMarketingAccount.Id, ccpCP.Id, 30000, System.today().addDays(-5), System.today().addDays(50), false);
            pbm.Core_MDF_Budget_Type_Txt__c = 'MDF';
            pbm.Core_MDF_Budget_Status__c = 'Released';
            Database.insert(pbm);
            Date startDate1 = Date.newInstance(2021, 6, 1);
            Date endDate1 = Date.newInstance(2021, 6, 30);
            Campaign ccfOpalCampaign = Core_MDF_CCP_TestDataUtility.createCampaign('CCF Opal Campaign','Gaming','Intel® Core™ i7+ Processor','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', startDate1,endDate1 , 10000, 'Consumer Chromebook', ccpCoMarketingAccount.Id, '2-in-1', false);
            ccfOpalCampaign.Core_MDF_Supports_legacy_program__c = 'yes';
            ccfOpalCampaign.Core_MDF_Opal_Budget_Type_Txt__c = 'CCF 1.0';
            ccfOpalCampaign.StartDate = startDate1;
            ccfOpalCampaign.EndDate = endDate1;
            Database.insert(ccfOpalCampaign);
            //Create retail bank using utility class
            List<Core_MDF_Bank__c> bankList = new List<Core_MDF_Bank__c>();
            
            Core_MDF_Bank__c indiaBank = Core_MDF_CCP_TestDataUtility.createBank(ccpIntelAccount.Id, 'CCF', false,'1231231230');
            indiaBank.Core_MDF_Bank_Status__c = 'Active';
            indiaBank.Core_MDF_Program__c='Core_MDF_Data_Center_CoMarketing_Fund;Core_MDF_Client_CoMarketing_Fund';
            bankList.add(indiaBank);
            
            Database.insert(bankList);
            //Create ABM record using utility class
            Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(ccpCoMarketingAccount.Id,indiaBank.Id,false);
            insert abm1;
            
            List<PartnerFundRequest> testPartnerFundRequestRecordList = new List<PartnerFundRequest>();
            // Creating Activity with budget using utility class
            PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(ccfOpalCampaign.Id),
                                                                                                                          Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                                          string.valueof(ccpCoMarketingAccount.id),
                                                                                                                          NULL,NULL,'ALBANIA','Consumer',
                                                                                                                          'Desktop','Intel® Corporate Logo',
                                                                                                                          'Event','Channel Partner Owned Event',
                                                                                                                          'Draft',false);
            
            testPartnerFundRequestRecord.RequestedAmount=10;
            testPartnerFundRequestRecord.Core_MDF_Fund_Request_Status__c = 'Revision Required';
            testPartnerFundRequestRecord.Core_MDF_Start_Date__c = system.today();
            testPartnerFundRequestRecord.Core_MDF_End_Date__c = system.today();
            //test code begins
            testPartnerFundRequestRecord.Core_MDF_Budget_Type_nm__c = 'CCF 1.0';
            //test code ends
            testPartnerFundRequestRecordList.add(testPartnerFundRequestRecord);
            
            
            
            database.insert(testPartnerFundRequestRecordList);
            
            Core_MDF_Configuration__c config = new Core_MDF_Configuration__c();
            config.Core_MDF_Value__c = 'MDF,MDF+';
            config.Name = 'BUDGET_TYPE_CLAIM_BANK_HIDE';
            insert config;
            
            List<PartnerFundClaim> claimsToBeInserted = new List<PartnerFundClaim>();
            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today(), System.today(), 500.00, System.today(), indiaBank.Id, false);
            claim1.Core_MDF_Currency__c = 'USD';
            claim1.Core_MDF_Campaign_Id__c= ccfOpalCampaign.id;
            claimsToBeInserted.add(claim1);
            
            PartnerFundClaim claim2 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim2', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today(), System.today(), 500.00, System.today(), indiaBank.Id, false);
            claimsToBeInserted.add(claim2); 
            database.insert(claimsToBeInserted);
        } 
    }
    
    @isTest static void validateClaimInsertBatch(){ 
        
        Test.startTest();
        
        Core_MDF_Bank__c indiaBank = [Select ID,Core_MDF_Hold_Payments_from_AP_file_ind__c from Core_MDF_Bank__c where name='retailBank' limit 1];
        indiaBank.Core_MDF_Hold_Payments_from_AP_file_ind__c = 'yes';
        database.update(indiaBank);
        Test.stopTest();
        PartnerFundClaim newClaim1 = [Select Id,Core_MDF_Status__c from PartnerFundClaim where Title = 'Test Claim' limit 1];
        System.assertEquals('Hold', newClaim1.Core_MDF_Status__c);
        
        
    }
}