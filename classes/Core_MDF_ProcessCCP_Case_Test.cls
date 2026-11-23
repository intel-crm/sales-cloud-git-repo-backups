/****************************************************************************************************************************************
* Class Name  : Core_MDF_ProcessCCP_Case_Test 
* Version     : 1.0 
* Created Date: 04-02-2019
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Shridhar K      04/02/2019                   Created Core_MDF_ProcessCCP_Case_Test to test Core_MDF_ProcessCCP_Case
* Intel - NP(11630236)		  01/08/2019				   Added code to increase coverage for preventing Case status change if Checklist is incomplete
* Intel - NP(11630236)		  27/08/2019                   Created list to update common objects instead of individual inserts				  
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
private class Core_MDF_ProcessCCP_Case_Test {
    
    @TestSetUp
    static void createTestData() {
        
        List<User> userList = new List<User>();
        //Role
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        User testUser = Core_MDF_CCP_TestDataUtility.createUser(true);
        testUser.UserRoleId = usRole.Id;
        update testUser;
        Map<String,PermissionSet> permissionSetMap = new Map<String,PermissionSet>();
        Map<String,Id> profileMap = new Map<String,Id>();
        
        for(Profile prfl:[SELECT Id,Name FROM Profile WHERE Name IN ('System Administrator','CCP - Core Access','Partner')]) {
            profileMap.put(prfl.Name,prfl.Id);
        }
        
        for(PermissionSet pSet:[SELECT Id,Name FROM PermissionSet WHERE Name IN ('Core_MDF_CCP_Internal_Retail_Account_Manager', 'Core_MDF_CCP_Internal_Claim_Case_Reviewer', 'Core_MDF_CCP_External_Activity_Approver')]) {
            permissionSetMap.put(pSet.Name,pSet);
        }
        //   Profile sysAdminProfile = profileMap.get('System Administrator');
        
        User usrs = Core_MDF_CCP_TestDataUtility.createUser(false);
        usrs.Email = 'sysadmin@example.com';
        usrs.LastName = 'System Adm';
        usrs.ProfileId = profileMap.get('System Administrator');
        usrs.isActive = true;
        database.insert(usrs);
        
        //       Profile ccpCoreProfile = profileMap.get('CCP - Core Access');
        PermissionSet clmCaseRevPS = permissionSetMap.get('Core_MDF_CCP_Internal_Claim_Case_Reviewer');
        User claimCase = Core_MDF_CCP_TestDataUtility.createUser(false);
        claimCase.Email = 'clmcase@example.com';
        claimCase.ProfileId = profileMap.get('CCP - Core Access');
        insert claimCase;
        PermissionSetAssignment assignPermissionSetObjCCR = new PermissionSetAssignment();
        assignPermissionSetObjCCR.AssigneeId = claimCase.Id;
        assignPermissionSetObjCCR.PermissionSetId = clmCaseRevPS.Id;
        Database.insert(assignPermissionSetObjCCR);
        
        PermissionSet claimCaseReviewerPS = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer' LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId = usrs.id, PermissionSetId = claimCaseReviewerPS.Id);

        
        
        System.runAs(testUser){
            List<Core_Trigger_Executions__c> transactions = new List<Core_Trigger_Executions__c>();
            transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Duplicate_Budget_Check','Bypass_GeoBased_Budget_Sharing','Bypass_MDF_Budget_Access_Validation','Bypass_MDF_Budget_Status_Validation'}, true, false));       
            transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Allocation_Reservation','Bypass_GeoBased_Allocation_Sharing'}, true, false));   
            transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Duplicate_Bank_Check','Bypass_Bank_Internal_Sharing',
                'Bypass_Bank_External_Sharing','Bypass_Bank_Program_InActivation_Check','Bypass_Bank_ABM_Sharing','BypassRetailMDFBudgetValidation'}, true, false));
            transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_ABM_Internal_Sharing','Bypass_ABM_External_Sharing','Bypass_ABM_NodeGroup_Sharing'}, true, false));                 
            Database.insert(transactions);
            
            ChannelProgram retailCP = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', true);
            
            Account retailIntelAcc = Core_MDF_CCP_TestDataUtility.createAccount('Test Retail Intel Account',retailCP.id, Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            retailIntelAcc.Core_Geo__c = 'APJ';
            retailIntelAcc.BillingCountry ='RUS';
            retailIntelAcc.BillingCity = 'Test City'; 
            retailIntelAcc.BillingStreet= 'Test Street';
            retailIntelAcc.BillingState= 'MOS';
            insert retailIntelAcc;
            
            Account masterAcc = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Master Account', retailCP.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, retailIntelAcc.Id, false);
            masterAcc.Core_Geo__c = 'APJ';
            //masterAcc.Core_Sub_Geo__c = 'IJKK';
            insert masterAcc;
            
            //Creating Contact for Partner User
            Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(retailIntelAcc.Id,true);
            
            // Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
            User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);        
            usr1.Email='test1@example.com';
            usr1.ContactId = conRecord1.Id;
            usr1.ProfileId = profileMap.get('Partner');
            usr1.isActive = true;
            Database.insert(usr1);
            
            PartnerMarketingBudget retailBudget = Core_MDF_CCP_TestDataUtility.createRetailBudget('TestBudgetData1',Core_MDF_CCP_TestDataUtility.budget_Retail_Record_Type,
                                                                                                  masterAcc.id, retailCP.Id , 200000 , System.today()-6 , System.today()+301 , false,'Retail MDF');
            retailBudget.IsIgnoreValidation = true;
            insert retailBudget;
            
            //allocation
            PartnerFundAllocation allocation = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation New',retailBudget,masterAcc,99999.0,true);
            
            //update allocation;
            
            PermissionSet aacntMngrPS = permissionSetMap.get('Core_MDF_CCP_Internal_Retail_Account_Manager');
            PermissionSet extApprPS = permissionSetMap.get('Core_MDF_CCP_External_Activity_Approver');
            
            Contact con  = Core_MDF_CCP_TestDataUtility.createContact(retailIntelAcc.Id, true);
            User usrBudgetAdmin = Core_MDF_CCP_TestDataUtility.createUser(false);
            usrBudgetAdmin.LastName = 'Budget Admin';
            usrBudgetAdmin.ContactId = con.Id;
            usrBudgetAdmin.ProfileId = profileMap.get('Partner');
            usrBudgetAdmin.portalRole = 'Manager';
            usrBudgetAdmin.email = 'ccfextapprover@example.com';
            usrBudgetAdmin.isActive = true;
            userList.add(usrBudgetAdmin);
            
            User ccfaccntmngr = Core_MDF_CCP_TestDataUtility.createUser(false);
            ccfaccntmngr.Email = 'ccfaccntmngr@example.com';
            ccfaccntmngr.ProfileId = profileMap.get('CCP - Core Access');
            userList.add(ccfaccntmngr);
            
            Database.insert(userList);
            
            PermissionSetAssignment assignPermissionSetObj = new PermissionSetAssignment();
            assignPermissionSetObj.AssigneeId = ccfaccntmngr.Id;
            assignPermissionSetObj.PermissionSetId = aacntMngrPS.Id;
            Database.insert(assignPermissionSetObj);
            
            Database.update(retailBudget);
            PartnerMarketingBudget budget1 = [Select TotalAllocatedAmount from PartnerMarketingBudget where id = :retailBudget.Id];
            
            Campaign retailCampaign = Core_MDF_CCP_TestDataUtility.createCampaign('Test Retail Camp 1','Business','Intel® 10ᵗʰ Gen', 'MDF or both CMP & MDF',
                                                                                  Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 
                                                                                  'Retail_Marketing_Funds', System.today()-2,
                                                                                  System.today()+100, 100000, 'Instore merchandise', 
                                                                                  masterAcc.Id,'All-in-One Desktop', false);
            
            retailCampaign.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
            retailCampaign.Core_MDF_Activity_Category_Type__c =null;
            retailCampaign.Core_MDF_Program__c = 'Retail Marketing Funds';
            retailCampaign.Core_MDF_Reimbursement_Rate__c='100%';
            retailCampaign.Core_MDF_Technology__c = 'Wifi6';
            retailCampaign.Core_MDF_Budget_Type_txt__c ='Retail MDF';
            retailCampaign.Core_MDF_Opal_Budget_Type_Txt__c = 'Retail MDF';
            //retailCampaign.Core_MDF_Program_Type__c = 'Non Opal';
            retailCampaign.Core_MDF_Budget_Amount_amt__c=100000;
            
            insert retailCampaign;            
            
            List<Core_MDF_Bank__c> listBank = new List<Core_MDF_Bank__c>();            
            
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(retailIntelAcc.Id, 'Core_MDF_Retail_Marketing_Funds', false,'1231231230');
            bank.Core_MDF_Bank_Alias_Name__c='Test';
            bank.Core_MDF_Bank_Status__c ='Active';  
            bank.Core_MDF_Intel_Company_Code__c = '420';     
            bank.Core_MDF_Tax_codes_cd__c = 'UB';
            bank.Core_MDF_VAT_pct__c ='10';
            
            listBank.add(bank);
            Core_MDF_Bank__c bank1 = Core_MDF_CCP_TestDataUtility.createBank(retailIntelAcc.Id, 'Core_MDF_Retail_Marketing_Funds', false,'1281211130');
            bank1.Core_MDF_Bank_Alias_Name__c='Test1';
            bank1.Core_MDF_Bank_Status__c ='Active';  
            bank1.Core_MDF_Intel_Company_Code__c = '420';     
            bank1.Core_MDF_Tax_codes_cd__c = 'UB';
            bank1.Core_MDF_VAT_pct__c ='0';
            
            listBank.add(bank1);
            Database.insert(listBank);
            //Do Account Bank Mapping for 'bank' and ABM is applicaple only for "Retail MDF" record type
            Test.startTest();
            //Core_MDF_Account_Bank_Mapping__c abm1 = 
            Core_MDF_CCP_TestDataUtility.createAccountBankMap(masterAcc.Id,bank.Id,true);
            //Core_MDF_Account_Bank_Mapping__c abm2 = 
            Core_MDF_CCP_TestDataUtility.createAccountBankMap(masterAcc.Id,bank1.Id,true);
            
          Group ccfgrp = new Group();
        ccfgrp.Name = 'Core CCP CCF Internal';
        ccfgrp.DeveloperName = 'Core_CCP_CCF_Internal';
        Database.insert(ccfgrp);
            
            
            
            Account accCCF = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount ('Test Account CCF3', retailCP.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, masterAcc.Id, false);
        accCCF.Core_MDF_Parent_Fund_Account__c = masterAcc.Id;
        accCCF.Core_MDF_CoMarketing_Ultimate_Account__c = retailIntelAcc.Id;
            accCCF.Core_Geo__c = 'APJ';
        Database.insert(accCCF);
            
            Core_MDF_Partner_Group_Mapping__c ccfPgm = new Core_MDF_Partner_Group_Mapping__c();
        ccfPgm.Core_MDF_Account__c = masterAcc.Id;
        ccfPgm.Core_MDF_Group_Name__c = 'PGM_Retail_TEST';
        ccfPgm.Core_MDF_Type_of_Access__c = 'Internal';
        ccfPgm.Core_MDF_Group_Id__c = ccfgrp.Id;
        ccfpgm.Core_MDF_Virtual_Corp_nm__c = accCCF.Id;
        ccfPgm.Core_MDF_Channel_Program__c = retailCP.Id;
        ccfPgm.Core_MDF_Source_Txt__c = 'test';
        ccfPgm.Core_MDF_AccountIdGroupName__c = masterAcc.Id + '_Core_CCP_CCF_Internal';
        insert ccfPgm;
            //Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(masterAcc.Id, usrBudgetAdmin.Id, true);
            
            //Addeed by Areefa
            List<Core_Trigger_Executions__c> executionClaimVat = new List<Core_Trigger_Executions__c>();
            Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution = new Core_Trigger_Executions__c();
            claimFunctionalityNameTriggerExecution.Core_Active__c = true;
            claimFunctionalityNameTriggerExecution.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
            claimFunctionalityNameTriggerExecution.Core_Trigger_Events__c = 'before insert,after update';
            claimFunctionalityNameTriggerExecution.Core_Object__c = 'PartnerFundClaim';
            claimFunctionalityNameTriggerExecution.Name = 'enableClaimsVATEligible';
            claimFunctionalityNameTriggerExecution.Core_Description__c = 'description';
            executionClaimVat.add(claimFunctionalityNameTriggerExecution);
            
            Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution1 = new Core_Trigger_Executions__c();
            claimFunctionalityNameTriggerExecution1.Core_Active__c = true;
            claimFunctionalityNameTriggerExecution1.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
            claimFunctionalityNameTriggerExecution1.Core_Trigger_Events__c = 'before insert,after update';
            claimFunctionalityNameTriggerExecution1.Core_Object__c = 'PartnerFundClaim';
            claimFunctionalityNameTriggerExecution1.Name = 'enableClaimsVatAfterInsert';
            claimFunctionalityNameTriggerExecution1.Core_Description__c = 'description';
            executionClaimVat.add(claimFunctionalityNameTriggerExecution1);
            
            Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution2 = new Core_Trigger_Executions__c();
            claimFunctionalityNameTriggerExecution2.Core_Active__c = true;
            claimFunctionalityNameTriggerExecution2.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
            claimFunctionalityNameTriggerExecution2.Core_Trigger_Events__c = 'before insert,after update';
            claimFunctionalityNameTriggerExecution2.Core_Object__c = 'PartnerFundClaim';
            claimFunctionalityNameTriggerExecution2.Name = 'enableClaimsVatAfterUpdate';
            claimFunctionalityNameTriggerExecution2.Core_Description__c = 'description';
            executionClaimVat.add(claimFunctionalityNameTriggerExecution2);
            
            Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution3 = new Core_Trigger_Executions__c();
            claimFunctionalityNameTriggerExecution3.Core_Active__c = true;
            claimFunctionalityNameTriggerExecution3.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
            claimFunctionalityNameTriggerExecution3.Core_Trigger_Events__c = 'before insert,after update';
            claimFunctionalityNameTriggerExecution3.Core_Object__c = 'PartnerFundClaim';
            claimFunctionalityNameTriggerExecution3.Name = 'enableClaimVatBeforeUpdate';
            claimFunctionalityNameTriggerExecution3.Core_Description__c = 'description';
            executionClaimVat.add(claimFunctionalityNameTriggerExecution3);
            
            Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution6 = new Core_Trigger_Executions__c();
            claimFunctionalityNameTriggerExecution6.Core_Active__c = true;
            claimFunctionalityNameTriggerExecution6.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
            claimFunctionalityNameTriggerExecution6.Core_Trigger_Events__c = 'after insert, after update';
            claimFunctionalityNameTriggerExecution6.Core_Object__c = 'PartnerFundClaim';
            claimFunctionalityNameTriggerExecution6.Name = 'checkAndSendClaimsForPIC';
            claimFunctionalityNameTriggerExecution6.Core_Description__c = 'description';
            executionClaimVat.add(claimFunctionalityNameTriggerExecution6);
            
            Database.insert(executionClaimVat); 
            Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();
            
        }
        
        PartnerMarketingBudget budget1 = [Select id,TotalAllocatedAmount from PartnerMarketingBudget where Title = 'TestBudgetData1'];
        PartnerFundAllocation allocation1 = [Select id, Amount from PartnerFundAllocation where BudgetId = :budget1.Id];
        PartnerFundRequest pfr = new PartnerFundRequest();
        //Test.startTest(); 
        System.runAs(usrs){
            Campaign camp = [select id,Name,Core_MDF_Budget_Amount_amt__c from Campaign WHERE Name = 'Test Retail Camp 1' LIMIT 1];
            Account accCoMarketing = [select id from Account WHERE Name = 'Test Master Account'];
            pfr = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(string.valueof(camp.id),Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,string.valueof(accCoMarketing.id),null,null,'UNITED KINGDOM','Business','All-in-One Desktop','Intel® 10ᵗʰ Gen','Broadcast','Podcast','Draft',false);
            pfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            pfr.Title = 'Test Retail Activity';
            pfr.Core_MDF_Activity_Description__c = 'Test Retail Activity';
            pfr.Core_MDF_Budget_Type_nm__c ='Retail MDF';
            pfr.Core_MDF_Channel_Partner_Led__c = false;
            pfr.Core_MDF_Budget_Amount_Local_amt__c=10;
            pfr.Core_MDF_Budget_Currency_cd__c='USD';
            pfr.Core_MDF_Estimated_Ad_Size_nbr__c=1;
            pfr.Core_MDF_Magazine_Newspaper_txt__c='Magazine';
            pfr.Core_MDF_Start_Date__c = System.today().addDays(-2);
            pfr.Core_MDF_End_Date__c = System.today()+4;
            pfr.Core_MDF_Reimbursement_Rate_pct__c='100%'; 
            pfr.Core_MDF_Reimbursement_Rate_txt__c='100%';
            pfr.Core_MDF_Budget_Type_nm__c = 'Retail MDF';
            pfr.BudgetId = budget1.Id;
            pfr.AllocationId = allocation1.Id;
            pfr.status = 'Approved';
            pfr.Core_MDF_Fund_Request_Status__c = 'Planned';
            pfr.Amount=1;
            insert pfr;
        }
        Test.stopTest();        
    }
    
    /****************************************************************************************************************************************
    Method Name:                                             testCaseReviewCheck
    @return  :                                               Void
    @parameters:                                             --
    Description:                                             This method is created to check case review check
    Added By:                                                Accenture – Shridhar K -  04/02/2019
    Modified By:                  Date:                      Changes: 
    Accenture – Shridhar K        04/02/2019                 Created. 
    *****************************************************************************************************************************************/  
    @isTest static void testCaseReviewCheck() { 
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 50000];
        List<Account> accList = new List<Account>(); 
        List<Contact> conList = new List<Contact>(); 
        List<Case> caseList = new List<Case>();
        List<User> usList = new List<User>();
        // Creating User with utility class 
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName = 'User Test1';
        usr1.UserRoleId = usRole.Id;
        usList.add(usr1);
        
        System.runAs(usr1){
            // Creating channel program with utility class
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Datacenter','Data Center CoMarketing Fund', true);
            ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Client','Client CoMarketing Fund', true);
            
            // Creating IntelAccount with utility class
            Account intAcc = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', 
                                                                              Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type,true);
            //intAcc.Core_Account_Type__c = 'Reseller';
            //intAcc.Core_Sales_Groups__c = 'Automotive Sales Group';
            //intAcc.Industry = 'Food & Beverage';
            
            //Database.insert(intAcc);
            
            // Creating Co-marketing Account with utility class
            Account dcfAcc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing DCF Test Account', 
                                                                         cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            dcfAcc.Core_MDF_Parent_Fund_Account__c = intAcc.Id;
            accList.add(dcfAcc);
            //Database.insert(dcfAcc);
            Account ccfAcc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing CCF Test Account', 
                                                                         cp1.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            ccfAcc.Core_MDF_Parent_Fund_Account__c = intAcc.Id;
            accList.add(ccfAcc);
            Database.insert(accList);
            
            // Creating Contact with utility class
            Contact con = Core_MDF_CCP_TestDataUtility.createContact (intAcc.Id, false);
            con.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            conList.add(con);
            Contact con1 = Core_MDF_CCP_TestDataUtility.createContact (intAcc.Id, false);
            con1.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            conList.add(con1);
            Contact con2 = Core_MDF_CCP_TestDataUtility.createContact (intAcc.Id, false);
            con2.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            conList.add(con2);
            Database.insert(conList);
            Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 1];
            Profile coreAccessProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
            
            // Creating User with utility class 
            
            List<User> usrList = new List<User>();
            User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr2.LastName = 'User Test2';
            usr2.ProfileId = partnerProfile.Id;
            usr2.ContactId = con.Id;
            usrList.add(usr2);
            
            User usr3 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr3.LastName = 'User Test3';
            usr3.ProfileId = partnerProfile.Id;
            usr3.ContactId = con1.Id;
            usrList.add(usr3);
            
            User usr4 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr4.LastName = 'User Test3';
            usr4.ProfileId = partnerProfile.Id;
            usr4.ContactId = con2.Id;
            usrList.add(usr4);
            
            User usr5 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr5.LastName = 'User Test4';
            usr5.ProfileId = coreAccessProfile.Id;
            usrList.add(usr5);
            
            User usr6 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr6.LastName = 'User Test4';
            usr6.ProfileId = coreAccessProfile.Id;
            usrList.add(usr6);
            
            User usr7 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr7.LastName = 'User Test4';
            usr7.ProfileId = coreAccessProfile.Id;
            usrList.add(usr7);  
            
            Database.insert(usrList);
            
            PermissionSet reviewerPer = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Claim_Case_Reviewer' LIMIT 1];
            PermissionSet reviewerManagerPer = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Claim_Case_Reviewer_Manager' LIMIT 1]; 
            
            //Below lines of code added by Shridhar 01/08/2019
            //Assign claim submitter permissio set
            PermissionSet claimSubmitterPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_External_Claim_Submitter' LIMIT 1];
            list<PermissionSetAssignment> psaList = new list<PermissionSetAssignment>(); 
            PermissionSetAssignment psa1 = new PermissionSetAssignment(PermissionSetId = claimSubmitterPS.Id, AssigneeId = usr2.Id);
            PermissionSetAssignment psa2 = new PermissionSetAssignment(PermissionSetId = claimSubmitterPS.Id, AssigneeId = usr3.Id);
            PermissionSetAssignment psa3 = new PermissionSetAssignment(PermissionSetId = claimSubmitterPS.Id, AssigneeId = usr4.Id);
            PermissionSetAssignment psa4 = new PermissionSetAssignment(PermissionSetId = reviewerPer.Id, AssigneeId = usr5.Id);
            PermissionSetAssignment psa5 = new PermissionSetAssignment(PermissionSetId = reviewerManagerPer.Id, AssigneeId = usr6.Id);

            psaList.add(psa1);
            psaList.add(psa2);
            psaList.add(psa3);
            psaList.add(psa4);
            psaList.add(psa5); 
            Database.insert(psaList);
            
            // Creating Case
            Map<Id,Case> oldMap = new Map<Id,Case>();
            Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            Case cs = new Case();
            cs.recordTypeId = caseAuditRecType;
            cs.AccountId = dcfAcc.Id;
            cs.OwnerId = usr2.Id;
            cs.Core_MDF_Claim_ID__c='text';
            cs.Origin ='Manual Selection';
            cs.Core_MDF_Region_SubRegion_txt__c  = 'EMEA - CEE';
            caseList.add(cs);
            
            Case cs1 = new Case();
            cs1.recordTypeId = caseAuditRecType;
            cs1.AccountId = ccfAcc.Id;
            cs1.OwnerId = usr3.Id;
              cs1.Origin ='Manual Selection';
            cs1.Core_MDF_Claim_ID__c='text1';
            cs1.Core_MDF_Region_SubRegion_txt__c  = 'EMEA - CEE';
            cs1.Core_MDF_Review_Case_Status__c = 'Review Completed';
            cs1.Core_MDF_Claim_Review_Closure_Note__c = 'Closed';
            caseList.add(cs1);
            
            Case cs2 = new Case();
            cs2.recordTypeId = caseAuditRecType;
            cs2.AccountId = ccfAcc.Id;
            cs2.OwnerId = usr3.Id;
              cs2.Origin ='Manual Selection';
            cs2.Core_MDF_Claim_ID__c='text1';
            cs2.Core_MDF_Region_SubRegion_txt__c  = 'EMEA - CEE';
            cs2.Core_MDF_Review_Case_Status__c = 'Review Completed';
            cs2.Core_MDF_Claim_Review_Closure_Note__c = 'Closed';
            caseList.add(cs2);
            Database.insert(caseList);
            
            for(Case caseRec:[select id,Core_MDF_Review_Case_Status__c,Core_MDF_Claim_Review_Closure_Note__c,Core_MDF_Internal_Case_Closure_Notes__c,Core_MDF_Data_Entry_Correction__c,
                              Core_MDF_Data_Entry_Correction_Cd__c,Core_MDF_Data_Correction_Note_Txt__c,Core_MDF_More_Documentation_Required__c,Core_MDF_ReasonForMoreDocumentation__c
                              from case]){
                oldMap.put(caseRec.id,caseRec);
            }
            
            // updating the below fields
            cs2.Core_MDF_Claim_Review_Closure_Note__c = 'Test';
            cs2.Core_MDF_Internal_Case_Closure_Notes__c = 'Test';
            cs2.Core_MDF_Data_Entry_Correction__c = true;
            cs2.Core_MDF_Data_Entry_Correction_Cd__c = 'Media Vehicle';
            cs2.Core_MDF_Data_Correction_Note_Txt__c = 'test';
            cs2.Core_MDF_More_Documentation_Required__c = true;
            cs2.Core_MDF_ReasonForMoreDocumentation__c = 'test';
            Database.update(cs2);
            
            //Populating Reviewer as Core_MDF_Claim_Case_Reviewer_Lookup__c
            cs1.Core_MDF_Claim_Case_Reviewer_Lookup__c = usr5.Id;
            Database.SaveResult srRes = Database.update(cs1,false);
            System.assertEquals(true,srRes.isSuccess());
            
            //Populating Reviewer Manager as Core_MDF_Claim_Case_Reviewer_Lookup__c
            cs1.Core_MDF_Claim_Case_Reviewer_Lookup__c = usr6.Id;
            Database.saveResult srRes1 = Database.update(cs1,false);
            System.assertEquals(true,srRes1.isSuccess());
            
            /*
            //Populating other than Reviewer and Reviewer Manager Core_MDF_Claim_Case_Reviewer_Lookup__c
            cs1.Core_MDF_Claim_Case_Reviewer_Lookup__c = usr7.Id;
            Database.saveResult srRes2 = Database.update(cs1,false);
            System.assertEquals(false,srRes2.isSuccess());*/
            
            //Updating Case as Compliant
            cs1.Core_MDF_Review_Case_Status__c = 'Compliant';
            Database.saveResult srRes3 = Database.update(cs1,false);
            
            //Covering exception
            Core_MDF_ProcessCCP_Case.caseReviewerCheck(null,null,true,false);
            
            
            Core_MDF_ProcessCCP_Case.caseReviewerCheck(caseList, oldMap, true, false);
            Core_MDF_ProcessCCP_Case.caseReviewerCheck(caseList, oldMap, false, true);
            
            //covering for data entry correction changes:US526998,US527005:Added by Ealisha
            cs.Core_MDF_Claim_Case_Reviewer_Lookup__c = usr6.Id;
            cs.Core_MDF_Data_Entry_Correction__c = true;
            cs.Core_MDF_Data_Entry_Correction_Cd__c = 'Media Vehicle';
            cs.Core_MDF_Data_Correction_Note_Txt__c = 'test';
            Database.update(cs);
            Case csAfterUpdate = [Select Core_MDF_Data_Entry_CorrectionReason_Txt__c from Case where
                                 Core_MDF_Data_Entry_Correction__c = true and 
                                 Core_MDF_Data_Entry_Correction_Cd__c = 'Media Vehicle' and
                                 Core_MDF_Data_Correction_Note_Txt__c = 'test' limit 1];
            //System.assertEquals('Media Vehicle^ test',csAfterUpdate.Core_MDF_Data_Entry_CorrectionReason_Txt__c);
            //
            set<id> caseSet = new set<id>();
            caseSet.add(csAfterUpdate.id);
            Core_MDF_ProcessCCP_Case.validateChecklistCompletion(caseSet);
        }    
    }
    
    @isTest
    static void testcaseReviewResultupdatesonVAT()
    {
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' and LastName = 'System Adm' limit 1];
        User paymentUser = [SELECT Id,Email from User where Email='clmcase@example.com' limit 1];
        PartnerFundClaim claimins, claimins2;
        Core_MDF_Claim_VAT_Info__c vatInfo, vatInfo2;
        Case cs ;
        List<PartnerFundClaim> pfclist;
        System.runAs(sysAdminUser)
        {
            test.startTest();
            Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='Test' limit 1];
            PartnerFundRequest pfr = [Select Id,Title,Core_MDF_Reimbursement_Rate__c from PartnerFundRequest where Title = 'Test Retail Activity'];
            PartnerFundClaim claim2 = Core_MDF_CCP_TestDataUtility.createClaim('Test Retail Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfr.Id, System.today().addDays(-2), System.today().addDays(-2), 50.00, System.today().addDays(-2), bank1.Id, false);
            claim2.Core_MDF_Type_Txt__c ='Claim';
            claim2.Core_MDF_Currency__c='USD';
            claim2.Core_MDF_Country_Location_nm__c= 'UNITED KINGDOM'; 
            claim2.Core_MDF_VAT_Opt_In__c = 'Service Invoice to Intel (VAT may apply)';
            claim2.Core_MDF_VAT_Eligibility_Ind__c= true ; 
            claim2.Core_MDF_VAT_Hold_Ind__c = true;
            claim2.Core_MDF_Status__c = 'Hold';
            claim2.Core_MDF_Bank_Doc_Hold_Eligibility_Ind__c=true;
            claim2.Core_MDF_FlaggedForBankDocHold_Ind__c=false;
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
            Core_MDF_PartnerFundClaim.ClaimWrap res = new Core_MDF_PartnerFundClaim.ClaimWrap();
            res = Core_MDF_PartnerFundClaim.saveClaim(claim2, auditDocList,null, null);
            
            //String res = Core_MDF_PartnerFundClaim.saveClaim(claim2, auditDocList);  
            
            claimins = [select id,Core_MDF_VAT_Eligibility_Ind__c,Core_MDF_Status__c,Core_MDF_Audit_Hold__c from PartnerFundClaim where id =: res.claimDetail.id limit 1];
            claimins.Core_MDF_Status__c = 'Hold';
            Database.update(claimins);
            pfclist= new List<PartnerFundClaim>();
            pfclist.add(claim2);
            Core_MDF_Claim_VAT_Process.updateclaimVATInfo(pfclist);
            // Read the VAT Invoice record
            vatInfo = [select id from Core_MDF_Claim_VAT_Info__c where Core_MDF_Claim_Id__c = : res.claimDetail.id limit 1];
            vatInfo.Core_MDF_VAT_Invoice_Number_Txt__c = 'VATINV001';
            Database.update(vatInfo);
            // Creating Case
            Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            Account caseAcc = [Select id from Account where Name = 'Test Master Account'];
            cs = new Case();
            cs.recordTypeId = caseAuditRecType;
            cs.AccountId = caseAcc.Id;
            cs.OwnerId = sysAdminUser.Id;
            cs.Core_MDF_Region_SubRegion_txt__c = 'APAC';
            cs.Origin='Manual Selection';
            cs.Core_MDF_Claim_ID__c = claim2.Id;
            Database.insert(cs);
            
            Core_MDF_Scorecard__c scoreCard = new Core_MDF_Scorecard__c();
            scoreCard.Core_MDF_Case_Id__c = cs.id;
            scoreCard.Core_MDF_Attribution_Nbr__c ='1';
            scoreCard.Core_MDF_Attribution_PV_Ind__c= 'M';
            scoreCard.Core_MDF_Engagement_Nbr__c = '1';
            scoreCard.Core_MDF_Engagement_PV_Ind__c = 'M';
            scoreCard.Core_MDF_POP__c='1';
            scoreCard.Core_MDF_POP_PV_Ind__c = 'M';
            Database.insert(scoreCard);
            
            cs.Core_MDF_Status__c = 'Under Review';
            Database.update(cs);
            
            claim2.Core_MDF_Claim_Review_Case__c = cs.id;
            claim2.Core_MDF_Audit_Hold__c = true;
            claim2.Core_MDF_Status__c = 'Hold';            
            Database.update(claim2);
            
            
            List<String> documentIdWithTitle = new List<String>();
            list<String> tempString = new list<String>();
            list<Core_MDF_Audit_Document__c> auditDocList2 = new list<Core_MDF_Audit_Document__c>();
            
            String str1 = claim2.Id+';#'+'Test Doc1';
            String str2 = claim2.Id+';#'+'Test Doc2';
            
            documentIdWithTitle.add(str1);
            documentIdWithTitle.add(str2);
            
            for(String str: documentIdWithTitle){
                tempString = str.split(';#');
                Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
                auditDoc.Core_MDF_Document_Id__c = tempString[0];
                auditDoc.Core_MDF_Document_Title__c = tempString[1];
                auditDoc.Core_MDF_Claim__c = claim2.Id;
                auditDoc.Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Branding;Proof of Execution';
                auditDoc.Core_MDF_App_Document_Types_nm__c = 'Proof of Cost;Proof of Branding;Proof of Execution';               
                auditDocList2.add(auditDoc);
            }            
            Core_MDF_PartnerFundClaim.ClaimWrap saveClaim1  = new Core_MDF_PartnerFundClaim.ClaimWrap();
            saveClaim1  = Core_MDF_PartnerFundClaim.saveClaim(claim2, auditDocList,null,null);
            
        }
            //String saveClaim1 = Core_MDF_PartnerFundClaim.saveClaim(claim2,auditDocList2);
        CaseShare cshare = new CaseShare(UserOrGroupId = paymentUser.Id, CaseAccessLevel = 'Edit', CaseId = cs.Id, RowCause = 'Manual' );
        insert cshare;
        system.runAs(paymentUser){
            Case csNew = [Select RecordType.DeveloperName, Id from Case where id = :cs.Id];
            Id caseAuditClosedRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            csNew.Core_MDF_Adjustment_Amount_USD_Amt__c=50;
            csNew.Core_MDF_Claim_Conversion_Exchange_Rate__c = 1;
            csNew.Core_MDF_Reimbursement_Rate__c = 50;
            csNew.Core_MDF_Requested_Amount_USD_Amt__c = 50;
            //csNew.Core_MDF_Review_Case_Status__c ='Review Completed';
            csNew.Core_MDF_Scorecard_Score_Nbr__c=0;
            csNew.Core_MDF_Checklist_Completion__c=100;
            
            Core_MDF_Claim_Case_Checklist__c checklistRecord = new Core_MDF_Claim_Case_Checklist__c();
            checklistRecord.Core_MDF_Case_ID__c = csNew.id;
            checklistRecord.Core_MDF_Checklist_Status__c = 'Non-Compliant';
            checklistRecord.Core_MDF_Impact_Amount__c = 20;
            checklistRecord.Core_MDF_Completion_Percentage__c = 100;
            insert checklistRecord;
            
            //Core_MDF_Scorecard__c sc = new Core_MDF_Scorecard__c(Core_MDF_Case_Id__c = csNew.Id);
            //insert sc;
            
            Id caseAuditClosedRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit_Closed').getRecordTypeId();
            csNew.Status = 'Closed';
            csNew.RecordTypeId = caseAuditClosedRecordTypeId;
            csNew.Core_MDF_Review_Case_Status__c ='Review Completed';
            Database.update(csNew);
            
            
            Core_MDF_ProcessCCP_Case.createRecoveryDashboardRecords(new List<Case>{csNew});
            Core_MDF_Vat_Utility.caseReviewResultupdatesonVAT(pfclist,'Compliant');
            Assert.areEqual(csNew.Core_MDF_Requested_Amount_USD_Amt__c,50);
            }
            
    }
    
    @isTest
	static void testGetPreviousQuarter() {
    	Test.startTest();
    
    	String result = Core_MDF_ProcessCCP_Case.getPreviousQuarter('Q2 2024');
    	System.assertEquals('Q1 2024', result, 'Failed: Expected Q1 2024');
    
    	Test.stopTest();
	}
}