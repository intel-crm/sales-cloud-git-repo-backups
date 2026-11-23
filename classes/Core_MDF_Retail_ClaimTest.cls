@isTest(SeeAllData=false)
public class Core_MDF_Retail_ClaimTest {
//New:Areefa

    @TestSetUp
    static void createTestData() {

        List<User> userList = new List<User>();
        //Role
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        User testUser = Core_MDF_CCP_TestDataUtility.createUser(true);
        testUser.UserRoleId = usRole.Id;
        update testUser;
        
        User usr3 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr3.Email = 'sysadmin@example.com';
        database.insert(usr3);
        
        System.runAs(testUser){

            ChannelProgram retailCP = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', true);
        
            Account retailIntelAcc = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Retail Intel Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            retailIntelAcc.Core_Geo__c = 'APJ';
            insert retailIntelAcc;
            
            Account masterAcc = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Master Account', retailCP.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, retailIntelAcc.Id, false);
            masterAcc.Core_Geo__c = 'APJ';
            masterAcc.Core_Sub_Geo__c = 'IJKK';
            insert masterAcc;

            PartnerMarketingBudget retailBudget = Core_MDF_CCP_TestDataUtility.createBudget('TestBudgetData1',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
            masterAcc.id, retailCP.Id , 10000 , System.today()-60 , System.today() + 60 , false);
            retailBudget.IsIgnoreValidation = true;
            insert retailBudget;
            retailBudget.Core_MDF_Budget_Status__c = 'Released';
            update retailBudget;
            
            //allocation
            PartnerFundAllocation allocation = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation New',retailBudget,masterAcc,200.0,true);
        
                
            Profile ccpCoreAccessProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
            Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' limit 1];
            PermissionSet aacntMngrPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Retail_Account_Manager' LIMIT 1];
            PermissionSet extApprPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_External_Activity_Approver' LIMIT 1];

            Contact con  = Core_MDF_CCP_TestDataUtility.createContact(retailIntelAcc.Id, true);
            User usrBudgetAdmin = Core_MDF_CCP_TestDataUtility.createUser(false);
            usrBudgetAdmin.LastName = 'Budget Admin';
            usrBudgetAdmin.ContactId = con.Id;
            usrBudgetAdmin.ProfileId = partnerProfile.Id;
            usrBudgetAdmin.portalRole = 'Manager';
            usrBudgetAdmin.email = 'ccfextapprover@example.com';
            userList.add(usrBudgetAdmin);
            //Database.insert(usrBudgetAdmin);
            
            User ccfaccntmngr = Core_MDF_CCP_TestDataUtility.createUser(false);
            ccfaccntmngr.Email = 'ccfaccntmngr@example.com';
            ccfaccntmngr.Profile = ccpCoreAccessProfile;
            userList.add(ccfaccntmngr);
            //Database.insert(ccfaccntmngr);

            Database.insert(userList);

            PermissionSetAssignment assignPermissionSetObj = new PermissionSetAssignment();
            assignPermissionSetObj.AssigneeId = ccfaccntmngr.Id;
            assignPermissionSetObj.PermissionSetId = aacntMngrPS.Id;
            Database.insert(assignPermissionSetObj);

            Campaign retailCampaign = Core_MDF_CCP_TestDataUtility.createCampaign('Test Retail Camp 1','Mainstream Consumer - Knowledge','10ᵗʰ Gen Core', ' ',
                                                                     Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 
                                                                     'Retail_Marketing_Funds', System.today()+1,
                                                                     System.today()+300, 10000, 'Instore merchandise', 
                                                                     masterAcc.Id,'2-in-1', false);
        
            retailCampaign.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
            retailCampaign.Core_MDF_Activity_Category_Type__c =null;
            retailCampaign.Core_MDF_Program__c = 'Retail Marketing Funds';
            retailCampaign.Core_MDF_Reimbursement_Rate__c='100%';
            retailCampaign.Core_MDF_Technology__c = 'Intel vPro®';
            retailCampaign.Core_MDF_Budget_Type_txt__c ='Retail MDF';
            insert retailCampaign;
            
            List<Core_MDF_Bank__c> listBank = new List<Core_MDF_Bank__c>();            
            
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(retailIntelAcc.Id, 'Core_MDF_Retail_Marketing_Funds', false,'1231231230');
            bank.Core_MDF_Bank_Alias_Name__c='Test';
            bank.Core_MDF_Bank_Status__c ='Active';
            bank.Core_MDF_Intel_Company_Code__c = '150';
            bank.Core_MDF_Currency_cd__c = 'USD';
            bank.Core_MDF_Payment_Currency_Cd__c = 'USD';
            bank.Core_MDF_Tax_codes_cd__c = 'I0';
            bank.Core_MDF_Bank_Status__c = 'Active';   
            bank.Core_MDF_Supplier_Country_txt__c = 'US';  
            bank.Core_MDF_Supplier_City_txt__c = 'New York';  
            bank.Core_MDF_Supplier_Region_txt__c = 'New York';  
            bank.Core_MDF_Supplier_Postal_Code_cd__c = '728378';  
            system.debug('bank' +bank);
            Database.insert(bank);        
            
            //Do Account Bank Mapping for 'bank' and ABM is applicaple only for "Retail MDF" record type
            Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(masterAcc.Id,bank.Id,true);
            
            Core_MDF_CCP_TestDataUtility.createPartnerGroupMapping(retailIntelAcc.Id,'Internal',retailIntelAcc.Id,retailCP.Id,'PGM_TEST',true);
            
            Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(masterAcc.Id, usrBudgetAdmin.Id, true);
            
            
        }
        User usr = [select id,email from User where email='ccfaccntmngr@example.com' limit 1];
        PartnerFundRequest pfr = new PartnerFundRequest();
        Test.startTest(); 
        System.runAs(usr){
            Campaign camp = [select id,Name from Campaign WHERE Name = 'Test Retail Camp 1' LIMIT 1];
            Account accCoMarketing = [select id from Account WHERE Name = 'Test Master Account'];
            pfr = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(string.valueof(camp.id),Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,string.valueof(accCoMarketing.id),null,null,'UNITED STATES','Mainstream Consumer - Knowledge','2-in-1','10ᵗʰ Gen Core','Sales Readiness','Collateral - Ad- Magazine/ Newspaper (Print)','Draft',false);
            pfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            pfr.Title = 'Test Retail Activity';
            pfr.Core_MDF_Activity_Description__c = 'Test Retail Activity';
            //pfr.Core_MDF_Budget_Type_txt__c ='Retail MDF';
            pfr.Core_MDF_Channel_Partner_Led__c = false;
            pfr.Core_MDF_Budget_Amount_Local_amt__c=100;
            pfr.Core_MDF_Budget_Currency_cd__c='USD';
            pfr.Core_MDF_Estimated_Ad_Size_nbr__c=5;
            pfr.Core_MDF_Magazine_Newspaper_txt__c='Magazine';
            pfr.Core_MDF_Start_Date__c = System.today();
            pfr.Core_MDF_End_Date__c = System.today();
            insert pfr;
        }
        Test.stopTest();        
    }   
    
    /* @isTest
    static void testRetailMDFSaveClaimSuccessMethod()
    {
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
            test.startTest();
            Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='Test' limit 1];
            PartnerFundRequest pfr = [Select Id,Title,Core_MDF_Reimbursement_Rate__c from PartnerFundRequest where Title = 'Test Retail Activity'];
            system.debug('pfr.Core_MDF_Reimbursement_Percent__c::'+pfr.Core_MDF_Reimbursement_Rate__c);
            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Retail Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfr.Id, System.today().addDays(20), System.today().addDays(20), 50.00, System.today().addDays(20), bank1.Id, false);
            claim1.Core_MDF_Type_Txt__c ='Claim';
            claim1.Core_MDF_Currency__c='USD';
            claim1.Core_MDF_Country_Location_nm__c= 'AFGHANISTAN'; 
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
            String res = Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList);            
            System.assertEquals(claim1.ID,res);            
            test.stopTest();
        }
    }*/
    
    @isTest
    static void testRetailMDFRussiaBankDocHold(){
        
        Account acc = [Select Id, BillingCountry from Account where Name ='Test Retail Intel Account' limit 1];
        acc.BillingCountry = 'RUS';
        update acc;
        Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='Test' limit 1];
        test.starttest();
        PartnerFundRequest pfr = [Select Id,Title,Core_MDF_Reimbursement_Rate__c from PartnerFundRequest where Title = 'Test Retail Activity'];
        PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Retail Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, false);
        claim1.Core_MDF_Type_Txt__c ='Claim';
        claim1.Core_MDF_Currency__c='USD';
        claim1.Core_MDF_Country_Location_nm__c= 'AFGHANISTAN'; 
        claim1.Core_MDF_To_Be_Audited_Ind__c = true;
        list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
        //String res = Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList);            
        //System.assertEquals(claim1.ID,res);            
        test.stopTest();
    }

}