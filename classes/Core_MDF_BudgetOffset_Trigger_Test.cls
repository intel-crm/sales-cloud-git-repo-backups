@isTest
public class Core_MDF_BudgetOffset_Trigger_Test {
    /* Method to Setup Test Data */
    @testSetup 
    static void setup() {  
        
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
        
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Acc New 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        
        // Creating Contact for Partner User
        Contact conRecForPartner = Core_MDF_CCP_TestDataUtility.createContact(acc1.Id,true);
        
        // Creating Admin and Partner Users with utility class 
        User usrAdmin = Core_MDF_CCP_TestDataUtility.createUser(false);
        usrAdmin.Email = 'sysadmin@example.com';
        Database.insert(usrAdmin);
        system.runAs(usrAdmin){
            
            Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
            User usrPartner = Core_MDF_CCP_TestDataUtility.createUser(false);        
            usrPartner.Email='test1@example.com';
            usrPartner.ContactId = conRecForPartner.Id;
            usrPartner.ProfileId = profileId;
            usrPartner.isActive = true;
            Database.insert(usrPartner);
            
            Profile ccpProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access'];
            UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
            User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr1.ProfileId = ccpProfile.Id;
            usr1.Email='test1@intel.com';
            usr1.isActive = true;
            usr1.UserPermissionsMarketingUser=true;
            //  usr1.UserRoleId = usRole.Id;
            Database.insert(usr1);
            
            //Login as claim claim Case reviewer
            Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
            User ccrUser = Core_MDF_CCP_TestDataUtility.createUser(false);
            ccrUser.Email='testCCR@example.com';
            ccrUser.ProfileId = p.id;
            Database.insert(ccrUser);
            
            PermissionSet clmCaseRevPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Claim_Case_Reviewer' LIMIT 1];
            PermissionSetAssignment assignPermissionSetObj = new PermissionSetAssignment();
            assignPermissionSetObj.AssigneeId = ccrUser.Id;
            assignPermissionSetObj.PermissionSetId = clmCaseRevPS.Id;
            Database.insert(assignPermissionSetObj);
        }
        
        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Acc New 2', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, true);
        PartnerMarketingBudget budget = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget New',Core_MDF_CCP_TestDataUtility.budget_Record_Type,acc2.Id,cp.Id,200000,System.today().addDays(-20),System.today().addDays(40), true);
        
        
        PartnerFundAllocation allocation = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation New',budget,acc2,200.0,true);
        
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 13','Gaming','Intel® Core™ i7 Processor', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today().addDays(-15), System.today().addDays(15), 10000, 'Always Connected PC', acc2.Id,'Desktop', true); 
        
        PartnerFundRequest testPartnerFundRequest = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(camp.Id), 
                                                                                                          Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                          String.valueof(acc2.id),allocation,null,'INDIA',
                                                                                                          'Consumer',
                                                                                                          'Desktop',
                                                                                                          'Intel® Core™ i5 Processor',
                                                                                                          'Broadcast',
                                                                                                          'Podcast',
                                                                                                          'Draft',
                                                                                                          false);
        
        
        testPartnerFundRequest.Core_MDF_Start_Date__c = system.today().addDays(-5);
        testPartnerFundRequest.Core_MDF_End_Date__c  = system.today().addDays(5);
        testPartnerFundRequest.Core_MDF_Country_nm__c = 'INDIA';
        insert testPartnerFundRequest;
        //inserting currency data
        
        Core_MDF_CCP_TestDataUtility.insertCurrencyExchangeRates();
        
        List<Core_MDF_Bank__c> listBank = new List<Core_MDF_Bank__c>();
        
        test.startTest();
        Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1231231230');
        bank.Core_MDF_Bank_Alias_Name__c='TestActiveBank1';
        Database.update(bank); 
        
        //creating ABM for bank
        Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc2.Id,bank.Id,true);
        
        PartnerFundClaim pfc = Core_MDF_CCP_TestDataUtility.createClaim('Claim 1', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequest.Id, system.today().addDays(-1), system.today().addDays(-1), 50.00, system.today().addDays(-1), bank.Id, false);
        pfc.Core_MDF_Media_Vehicle__c='Test1';
        Database.insert(pfc);
        
        Core_MDF_Adjustment_Request__c adjReq = Core_MDF_CCP_TestDataUtility.createAdjustmentReq(pfc.Id,'Claim Review Results (Negative)',20,true);
        test.stopTest();
        
        Core_MDF_CCP_TestDataUtility.createTriggerExecutionRecords();
        
    }
    
    /* Method to test budget offset process */
    @isTest
    static void testInsertBudgetOffsetMethod()
    {
        test.startTest();
        User sysAdmin = [Select Id from User where Email='sysadmin@example.com'];
        PartnerFundClaim claim1 = [SELECT Id,Core_MDF_Status__c FROM PartnerFundClaim where Title ='Claim 1'];
        PartnerMarketingBudget budget = [Select Id from PartnerMarketingBudget where title='Test Budget New' Limit 1];
        Core_MDF_Adjustment_Request__c adjReq = [SELECT Id,Core_MDF_Adjustment_Claim_Nbr__c,Core_MDF_Adjustment_Claim_Nbr__r.Amount from Core_MDF_Adjustment_Request__c where Core_MDF_Reference_Claim_Nbr__c=:claim1.Id];
        System.runAs(sysAdmin)
        {
            Core_MDF_Budget_Offset__c budgetOffset = new Core_MDF_Budget_Offset__c();
            budgetOffset.Core_MDF_Budget_Id__c = budget.Id;
            budgetOffset.Core_MDF_Adjustment_Claim_Id__c = adjReq.Core_MDF_Adjustment_Claim_Nbr__c;
            budgetOffset.Core_MDF_Amount__c = adjReq.Core_MDF_Adjustment_Claim_Nbr__r.Amount;
            Database.insert(budgetOffset);  
            
            Core_MDF_Budget_Offset__c budgetOffsetRec = 
                [SELECT Id,Core_MDF_Adjustment_Claim_Id__r.Core_MDF_Status__c from Core_MDF_Budget_Offset__c where Core_MDF_Adjustment_Claim_Id__c=:adjReq.Core_MDF_Adjustment_Claim_Nbr__c];
                system.assertEquals(budgetOffsetRec.Core_MDF_Adjustment_Claim_Id__r.Core_MDF_Status__c, 'Paid');
        }
        test.stopTest();
    }
}