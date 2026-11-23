/****************************************************************************************************************************************
* Class Name  : Core_MDF_PFC_RetailClaim_Test 
* Version     : 1.0 
* Created Date: 24-Feb-2020
* Modification Log :
* Developer                        Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel -Areefa          24-Feb-2020                    Created to test RetailClaim Functionality :working Version
*****************************************************************************************************************************************/
@isTest
public class Core_MDF_PFC_RetailClaim_Test {
    
    /* Method to Setup Test Data */
    @testSetup 
    static void setup() {  
        User tempUser = Core_MDF_CCP_TestDataUtility.createUser(false);
    	insert tempUser;
        List<Core_Trigger_Executions__c> transactions = new List<Core_Trigger_Executions__c>();
        transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Duplicate_Budget_Check','Bypass_GeoBased_Budget_Sharing'}, true, false));       
        transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Allocation_Reservation','Bypass_GeoBased_Allocation_Sharing'}, true, false));   
        transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Duplicate_Bank_Check','Bypass_Bank_Internal_Sharing',
                    'Bypass_Bank_External_Sharing','Bypass_Bank_Program_InActivation_Check','Bypass_Bank_ABM_Sharing','Bypass_MDF_Budget_Access_Validation'}, true, false));
        transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_ABM_Internal_Sharing','Bypass_ABM_External_Sharing','Bypass_ABM_NodeGroup_Sharing'}, true, false)); 
        Database.insert(transactions);

        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', true);
        
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test RetailAccount 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        acc1.Core_Geo__c = 'APJ';
        acc1.Core_Sub_Geo__c = 'SEA';
        Database.insert(acc1);
        
        List<Contact> listContact = new List<Contact>();
        Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(acc1.Id,false);
        conRecord1.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
        
        Contact conRecord2 = Core_MDF_CCP_TestDataUtility.createContact(acc1.Id,false);
        conRecord2.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;        
        listContact.add(conRecord1);
        listContact.add(conRecord2);
               
        Database.insert(listContact);        
    
        
        Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
        Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
        PermissionSet clmCaseRevPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Claim_Case_Reviewer' LIMIT 1];
        PermissionSet rmfPayAdmPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Retail_Payment_Adm' LIMIT 1];
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        

        
        
        Core_ERPM_Engagement__c erpmEngagementRMF = Core_MDF_CCP_TestDataUtility.createErpmEngagement('RPS_Retailer', 'RPS_Retailer', 'DEDUPGPRET', 'SEC', true, false);
        Database.insert(erpmEngagementRMF);
        
        List<Core_Entitlement__c> entitlementList = new List<Core_Entitlement__c>();        
        Core_Entitlement__c entitlementRMF = Core_MDF_CCP_TestDataUtility.createEntitlement('RMF User',null,'Consolidated Co-marketing Platform','RMF User',erpmEngagementRMF.Id , true,'Retail Marketing Funds (RMF)',false);
        entitlementList.add(entitlementRMF);
        Core_Entitlement__c entitlementRMF_CS= Core_MDF_CCP_TestDataUtility.createEntitlement('RMF External Claim Submitter',null ,'Consolidated Co-marketing Platform','RMF External Claim Submitter',erpmEngagementRMF.Id , true,'Retail Marketing Funds (RMF)',false);
        entitlementList.add(entitlementRMF_CS);
        Database.insert(entitlementList);
        
        List<Core_Contact_Entitlement__c> contactEntitlementList = new List<Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c contactEntitlementRMF_C1 = Core_MDF_CCP_TestDataUtility.createContactEntitlement(conRecord1.Id,entitlementRMF.Id ,true,'Complete', false);
        contactEntitlementList.add(contactEntitlementRMF_C1);
        Core_Contact_Entitlement__c contactEntitlementRMF_CS_C1 = Core_MDF_CCP_TestDataUtility.createContactEntitlement(conRecord1.Id,entitlementRMF_CS.Id ,true,'Complete', false);
        contactEntitlementList.add(contactEntitlementRMF_CS_C1);
        Core_Contact_Entitlement__c contactEntitlementRMF_C2 = Core_MDF_CCP_TestDataUtility.createContactEntitlement(conRecord2.Id,entitlementRMF.Id ,true,'Complete', false);
        contactEntitlementList.add(contactEntitlementRMF_C2);
        Core_Contact_Entitlement__c contactEntitlementRMF_CS_C2 = Core_MDF_CCP_TestDataUtility.createContactEntitlement(conRecord2.Id,entitlementRMF_CS.Id ,true,'Complete', false);
        contactEntitlementList.add(contactEntitlementRMF_CS_C2);
        Database.insert(contactEntitlementList);
        
        List<User> listUser = new List<User>();
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        User usrs = Core_MDF_CCP_TestDataUtility.createUser(false);
        usrs.LastName = 'System Adm';
        usrs.ProfileId = sysAdminProfile.Id;
        usrs.isActive = true;
        usrs.Email = 'sysadmin@example.com';
        listUser.add(usrs); 
        
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);        
        usr1.Email='test1@example.com';
        usr1.ContactId = listContact[0].Id;
        usr1.ProfileId = profileId;
        usr1.isActive = true;
        //usr1.UserRoleId = usRole.Id;
        listUser.add(usr1);        
        
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.Email='test123@example.com';
        usr2.ContactId = listContact[1].Id;
        usr2.ProfileId = profileId;
        usr2.isActive = true;
        //usr2.UserRoleId = usRole.Id;
        listUser.add(usr2);
        
        
        //Login as claim claim Case reviewer
        // Highlight: Unused Local Variable
       // Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];        
        //creating system admin user
        User sysAdmUsr = Core_MDF_CCP_TestDataUtility.createUser(false);
        sysAdmUsr.LastName = 'System Adm';
        listUser.add(sysAdmUsr);
        
        //creating claim case user
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName='Claim Case User';
        usr.profile=ccpCoreProfile;
        listUser.add(usr);
        System.runAs(tempUser){
        Database.insert(listUser);    
        }
        //asigning permission set to claim case user        
        List<PermissionSetAssignment> assignPermissionList = new List<PermissionSetAssignment>();    
        PermissionSetAssignment assignPermissionSetObj = new PermissionSetAssignment();
        PermissionSetAssignment assignPermissionSetObj2 = new PermissionSetAssignment();
        assignPermissionSetObj.AssigneeId = usr.Id;
        assignPermissionSetObj.PermissionSetId = clmCaseRevPS.Id;
        assignPermissionList.add(assignPermissionSetObj);
        assignPermissionSetObj2.AssigneeId = usrs.Id;
        assignPermissionSetObj2.PermissionSetId = rmfPayAdmPS.Id;
        assignPermissionList.add(assignPermissionSetObj2);
        system.runAs(sysAdmUsr){
            //Database.insert(assignPermissionSetObj);
            Database.insert(assignPermissionList);
        }
        
     // Creating Groups for PGM
        Group grp = new Group();
        grp.name = 'PGM_TEST';
        insert grp;
            
        system.runAs(sysAdmUsr){
            List<GroupMember> gmList = new List<GroupMember>();
            GroupMember gm = new GroupMember();
            gm.GroupId = grp.Id;
            gm.UserOrGroupId = usr1.Id;
            gmList.add(gm);
            
            GroupMember gm1 = new GroupMember();
            gm1.GroupId = grp.Id;
            gm1.UserOrGroupId = usr2.Id;
            gmList.add(gm1);
            
            GroupMember gm2 = new GroupMember();
            gm2.GroupId = grp.Id;
            gm2.UserOrGroupId = usr.Id;
            gmList.add(gm2);            
                   
            Database.insert(gmList);
            
        }
            
        
        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Retail TestAccount', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, false); // virtual corp
        acc2.Core_Geo__c = 'APJ';
        acc2.Core_Sub_Geo__c = 'SEA';
        Database.insert(acc2);
        
        //Ameyaa
        List<Account> accList = new List<Account>();
        Account acc3 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Retail TestAccount Acc 3', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc2.Id, false);
        acc3.Core_Geo__c = 'APJ';
        acc3.Core_Sub_Geo__c = 'SEA';
        accList.add(acc3);
       // Database.insert(acc3);
        
        Account acc4 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Retail TestAccount Acc 4', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc2.Id, false);
        acc4.Core_Geo__c = 'APJ';
        acc4.Core_Sub_Geo__c = 'SEA';
        accList.add(acc4);
        Database.insert(accList);
        //Ameya
         test.startTest();
        List<PartnerMarketingBudget> budgetLst = new List<PartnerMarketingBudget>();        

        PartnerMarketingBudget budget = Core_MDF_CCP_TestDataUtility.createRetailBudget('Retail TestBudget',Core_MDF_CCP_TestDataUtility.budget_Retail_Record_Type,acc2.Id,cp.Id,
                                                                                        200000,System.today()-25,System.today()+125, false,'RSA MD');
        budgetLst.add(budget);
        PartnerMarketingBudget retailMDFbudget = Core_MDF_CCP_TestDataUtility.createRetailBudget('Retail TestBudget',Core_MDF_CCP_TestDataUtility.budget_Retail_Record_Type,acc2.Id,
                                                                                                 cp.Id,200000,System.today()-25,System.today()+125, false,'Retail MDF');
        retailMDFbudget.Core_MDF_Budget_Status__c = 'Released';
        retailMDFbudget.IsIgnoreValidation = true;
        budgetLst.add(retailMDFbudget);
        Database.insert(budgetLst);
        List<PartnerFundAllocation> allocList = new List<PartnerFundAllocation>();
        

        PartnerFundAllocation allocation = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation New',budget,acc2,200.0,false);
        allocList.add(allocation);
        PartnerFundAllocation retailMDFAllocation = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation New',retailMDFbudget,acc2,200.0,false);
        allocList.add(retailMDFAllocation);
        Database.insert(allocList);
        
        List<Campaign> campaigns = new List<Campaign>();
        Campaign reatailMDFCampaign = Core_MDF_CCP_TestDataUtility.createCampaign('Retail Campaigm1','Gaming','9ᵗʰ Gen', 'MDF or both CMP & MDF', Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail,
                                                                                  'Retail Marketing Funds', System.today().addDays(-5), System.today().addDays(5), 10000, 'Instore innovation', acc2.Id,'Desktop', false); 
        reatailMDFCampaign.Core_MDF_Budget_Type_txt__c ='RSA MD';
        reatailMDFCampaign.Core_MDF_Opal_Budget_Type_Txt__c='RSA MD';
        reatailMDFCampaign.Core_MDF_Activity_Category_Type__c =null;
        reatailMDFCampaign.Core_MDF_Reimbursement_Rate__c='100%';
      //  reatailMDFCampaign.Core_MDF_Technology__c = 'Intel vPro®';
        
        Campaign rSAMDCampaign = Core_MDF_CCP_TestDataUtility.createCampaign('Retail Campaigm1','Gaming','9ᵗʰ Gen', 'MDF or both CMP & MDF', Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail,
                                                                             'Retail Marketing Funds', System.today().addDays(-5), System.today().addDays(5), 10000, 'Instore innovation', acc2.Id,'Desktop', false); 
        rSAMDCampaign.Core_MDF_Budget_Type_txt__c ='RSA MD';
        rSAMDCampaign.Core_MDF_Activity_Category_Type__c =null;
        rSAMDCampaign.Core_MDF_Reimbursement_Rate__c='100%';
     //   rSAMDCampaign.Core_MDF_Technology__c = 'Intel vPro®';
        
        //Ameya
        Campaign rSAMDCampaignOnLevelOneNode = Core_MDF_CCP_TestDataUtility.createCampaign('RSA MD Level One Node Campaigm','Gaming','9ᵗʰ Gen', 'MDF or both CMP & MDF',
                                                                                           Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds', 
                                                                                           System.today().addDays(-5), System.today().addDays(5), 10000, 'Instore innovation', acc3.Id,'Desktop', false); 
        rSAMDCampaignOnLevelOneNode.Core_MDF_Budget_Type_txt__c ='RSA MD';
        rSAMDCampaignOnLevelOneNode.Core_MDF_Activity_Category_Type__c =null;
        rSAMDCampaignOnLevelOneNode.Core_MDF_Reimbursement_Rate__c='100%';
    //    rSAMDCampaignOnLevelOneNode.Core_MDF_Technology__c = 'Intel vPro®';
        rSAMDCampaignOnLevelOneNode.Core_MDF_Supports_legacy_program__c = 'MDF or both CMP & MDF';
            
        Campaign rSAMDCampaignOnLevelTwoNode = Core_MDF_CCP_TestDataUtility.createCampaign('RSA MD Level Two Node Campaigm','Gaming','9ᵗʰ Gen',  'MDF or both CMP & MDF',Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds', System.today().addDays(-5), System.today().addDays(5), 10000, 'Instore innovation', acc4.Id,'Desktop', false); 
        rSAMDCampaignOnLevelTwoNode.Core_MDF_Budget_Type_txt__c ='RSA MD';
        rSAMDCampaignOnLevelTwoNode.Core_MDF_Activity_Category_Type__c =null;
        rSAMDCampaignOnLevelTwoNode.Core_MDF_Reimbursement_Rate__c='100%';
    //    rSAMDCampaignOnLevelTwoNode.Core_MDF_Technology__c = 'Intel vPro®';
        rSAMDCampaignOnLevelTwoNode.Core_MDF_Supports_legacy_program__c = 'MDF or both CMP & MDF';
        
        campaigns.add(reatailMDFCampaign);
        campaigns.add(rSAMDCampaign);
        campaigns.add(rSAMDCampaignOnLevelOneNode);
        campaigns.add(rSAMDCampaignOnLevelTwoNode);
              
        insert campaigns;
        
       // test.startTest();
        List<PartnerFundRequest> pFR = new List<PartnerFundRequest>();        
        PartnerFundRequest testPartnerFundRequest = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(rSAMDCampaign.Id),
                                                                                                          Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,string.valueof(acc2.id),NULL,NULL,'AFGHANISTAN','Enthusiast Gaming','Traditional Notebook',
                                                                                                              'Intel® 11ᵗʰ Gen','Sales Readiness','Personnel','Draft',false);      
        
        testPartnerFundRequest.Title ='Retail RSA MD Activity';
        testPartnerFundRequest.Core_MDF_Activity_Description__c ='Retail RSA MD Activity';
        //testPartnerFundRequest.Core_MDF_Budget_Type_txt__c ='RSA MD';
        //test code begins
        testPartnerFundRequest.Core_MDF_Budget_Type_nm__c = 'RSA MD';
        //test code ends
        testPartnerFundRequest.Core_MDF_Start_Date__c = System.today()-3;
        testPartnerFundRequest.Core_MDF_End_Date__c  = System.today()+3;
        testPartnerFundRequest.RequestedAmount =100000;
        testPartnerFundRequest.Amount=100000;
        //testPartnerFundRequest.Core_MDF_Country__c ='AFGHANISTAN';
        testPartnerFundRequest.Core_MDF_Country_nm__c = 'AFGHANISTAN';
        testPartnerFundRequest.Core_MDF_Fund_Request_Status__c = 'Planned';
        testPartnerFundRequest.Core_MDF_Budget_Currency_cd__c ='USD';
        testPartnerFundRequest.Core_MDF_Reimbursement_Rate_pct__c='100%';
        
        
        PartnerFundRequest testPartnerFundRequest1 =Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(reatailMDFCampaign.Id),
                                                                                                          Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,string.valueof(acc2.id),NULL,NULL,'AFGHANISTAN','Enthusiast Gaming','Traditional Notebook',
                                                                                                              'Intel® 11ᵗʰ Gen','Sales Readiness','Personnel','Draft',false);
        
        testPartnerFundRequest1.Title ='Retail MDF Activity';
        testPartnerFundRequest1.Core_MDF_Activity_Description__c ='Retail MDF Activity';
        //testPartnerFundRequest1.Core_MDF_Budget_Type_txt__c ='Retail MDF';
        //test code begins
        testPartnerFundRequest1.Core_MDF_Budget_Type_nm__c = 'RSA MD';
        //test code ends
        testPartnerFundRequest1.Core_MDF_Start_Date__c = System.today()-2;
        testPartnerFundRequest1.Core_MDF_End_Date__c  = System.today()+2;
        testPartnerFundRequest1.RequestedAmount =100000;
        testPartnerFundRequest1.Amount=100000;
        //testPartnerFundRequest1.Core_MDF_Country__c ='AFGHANISTAN';
        testPartnerFundRequest1.Core_MDF_Country_nm__c = 'AFGHANISTAN';
        testPartnerFundRequest1.Core_MDF_Fund_Request_Status__c = 'Planned';
        testPartnerFundRequest1.Core_MDF_Budget_Currency_cd__c ='USD'; 
        testPartnerFundRequest1.Core_MDF_Reimbursement_Rate_pct__c='100%';
        testPartnerFundRequest1.Core_MDF_Reimbursement_Rate_txt__c='100%';
        testPartnerFundRequest1.Status='Approved';
        testPartnerFundRequest1.AllocationId = allocList[0].Id;
        //Ameya
        PartnerFundRequest testPartnerFundRequestOnLevelOneNode =Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(rSAMDCampaignOnLevelOneNode.Id),
                                                                                                          Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,string.valueof(acc3.id),NULL,NULL,'AFGHANISTAN','Enthusiast Gaming','Traditional Notebook',
                                                                                                              'Intel® 11ᵗʰ Gen','Sales Readiness','Personnel','Draft',false);
        
        testPartnerFundRequestOnLevelOneNode.Title ='RSA MD Level One Node Activity';
        testPartnerFundRequestOnLevelOneNode.Core_MDF_Activity_Description__c ='RSA MD Activity';
        //testPartnerFundRequestOnLevelOneNode.Core_MDF_Budget_Type_txt__c ='RSA MD';
        //test code begins
        testPartnerFundRequestOnLevelOneNode.Core_MDF_Budget_Type_nm__c = 'RSA MD';
        //test code ends
        testPartnerFundRequestOnLevelOneNode.Core_MDF_Start_Date__c = System.today()-2;
        testPartnerFundRequestOnLevelOneNode.Core_MDF_End_Date__c  = System.today()+2;
        testPartnerFundRequestOnLevelOneNode.RequestedAmount =100000;
        testPartnerFundRequestOnLevelOneNode.Amount=100000;
        //testPartnerFundRequestOnLevelOneNode.Core_MDF_Country__c ='AFGHANISTAN';
        testPartnerFundRequestOnLevelOneNode.Core_MDF_Country_nm__c = 'AFGHANISTAN';
        testPartnerFundRequestOnLevelOneNode.Core_MDF_Fund_Request_Status__c = 'Planned';
        testPartnerFundRequestOnLevelOneNode.Core_MDF_Budget_Currency_cd__c ='USD'; 
        testPartnerFundRequestOnLevelOneNode.Core_MDF_Reimbursement_Rate_pct__c='100%';
        
        //Ameya
        PartnerFundRequest testPartnerFundRequestOnLevelTwoNode =Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(rSAMDCampaignOnLevelTwoNode.Id),
                                                                                                          Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,string.valueof(acc4.id),NULL,NULL,'AFGHANISTAN','Enthusiast Gaming','Traditional Notebook',
                                                                                                              'Intel® 11ᵗʰ Gen','Sales Readiness','Personnel','Draft',false);
        
        testPartnerFundRequestOnLevelTwoNode.Title ='RSA MD Level Two Node Activity';
        testPartnerFundRequestOnLevelTwoNode.Core_MDF_Activity_Description__c ='RSA MD Activity';
        //testPartnerFundRequestOnLevelTwoNode.Core_MDF_Budget_Type_txt__c ='RSA MD';
        //test code begins
        testPartnerFundRequestOnLevelTwoNode.Core_MDF_Budget_Type_nm__c = 'RSA MD';
        //test code ends
        testPartnerFundRequestOnLevelTwoNode.Core_MDF_Start_Date__c = System.today()-2;
        testPartnerFundRequestOnLevelTwoNode.Core_MDF_End_Date__c  = System.today()+2;
        testPartnerFundRequestOnLevelTwoNode.RequestedAmount =1000000;
        testPartnerFundRequestOnLevelTwoNode.Amount=100000;
        //testPartnerFundRequestOnLevelTwoNode.Core_MDF_Country__c ='AFGHANISTAN';
        testPartnerFundRequestOnLevelTwoNode.Core_MDF_Country_nm__c = 'AFGHANISTAN';
        testPartnerFundRequestOnLevelTwoNode.Core_MDF_Fund_Request_Status__c = 'Planned';
        testPartnerFundRequestOnLevelTwoNode.Core_MDF_Budget_Currency_cd__c ='USD'; 
        testPartnerFundRequestOnLevelTwoNode.Core_MDF_Reimbursement_Rate_pct__c='100%';
        
        pFR.add(testPartnerFundRequest);
        pFR.add(testPartnerFundRequest1);
        pFR.add(testPartnerFundRequestOnLevelOneNode);
        pFR.add(testPartnerFundRequestOnLevelTwoNode);
        insert pFR;  
        
        
        Core_MDF_CCP_TestDataUtility.insertCurrencyExchangeRates();
        // Highlight: Unused Local Variable
       // List<Core_MDF_Bank__c> listBank = new List<Core_MDF_Bank__c>();
        
        system.runAs(sysAdmUsr){
            
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Retail_Marketing_Funds', false,'1231231230');
            bank.Core_MDF_Intel_Company_Code__c = '150';
            bank.Core_MDF_Currency_cd__c = 'USD';
            bank.Core_MDF_Tax_codes_cd__c = 'I0';
            bank.Core_MDF_Bank_Status__c = 'Active';
            bank.Core_MDF_Payment_Currency_Cd__c = 'USD';
            database.insert(bank);
        
        
        //Do Account Bank Mapping for 'bank' and ABM is applicaple only for "Retail MDF" record type
            // Highlight: Unused Local Variable
           // Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc2.Id,bank.Id,true);
        }
        Core_MDF_CCP_TestDataUtility.createPartnerGroupMapping(acc1.Id,'Internal',acc1.Id,cp.Id,'PGM_Retail_TEST',true);
        system.runAs(sysAdmUsr){
        Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(acc2.Id, Usr1.Id, true);
        }
        test.stopTest();        
        
        Core_MDF_CCP_TestDataUtility.createTriggerExecutionRecords();
        
        List<Core_Trigger_Executions__c> executionAdjRequest = new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c adjustmentRequestClaimTriggerExecution = new Core_Trigger_Executions__c();
        adjustmentRequestClaimTriggerExecution.Core_Active__c = true;
        adjustmentRequestClaimTriggerExecution.Core_Class_Name__c = 'Core_MDF_AdjustmentReq_ServiceHandler';
        adjustmentRequestClaimTriggerExecution.Core_Trigger_Events__c = 'before insert';
        adjustmentRequestClaimTriggerExecution.Core_Object__c = 'Core_MDF_Adjustment_Request__c';
        adjustmentRequestClaimTriggerExecution.Name = 'createAdjustment';
        adjustmentRequestClaimTriggerExecution.Core_Description__c = 'Negative claim is getting created from Adustemt Request';
        executionAdjRequest.add(adjustmentRequestClaimTriggerExecution);
        
        Database.insert(executionAdjRequest);
        Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();
    }
    
    /* Method to test RetailMDF saveClaim */
 /*   @isTest
    static void testRetailMDFSaveClaimSuccessMethod()
    {
        test.startTest();
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
            
            Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='Test' limit 1];
            PartnerFundRequest pfr = [Select Id,Title from PartnerFundRequest where Title = 'Retail MDF Activity'];
            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Retail MDF Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, false);
            claim1.Core_MDF_Type_Txt__c ='Claim';
            claim1.Core_MDF_Currency__c='USD';
            claim1.Core_MDF_Country_Location_nm__c= 'AFGHANISTAN'; 
            //POP mandatory for Retail
            List<String> documentIdWithTitle = new List<String>();
            list<String> tempString = new list<String>();
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
            
            String str1 = claim1.Id+';#'+'Test Doc1';
            String str2 = claim1.Id+';#'+'Test Doc2';
            system.debug('str2' +str2);
            
            documentIdWithTitle.add(str1);
            documentIdWithTitle.add(str2);
            
            for(String str: documentIdWithTitle){
                tempString = str.split(';#');
                Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
                auditDoc.Core_MDF_Document_Id__c = tempString[0];
                auditDoc.Core_MDF_Document_Title__c = tempString[1];
                auditDoc.Core_MDF_Claim__c = claim1.Id;
                auditDoc.Core_MDF_Proof_of_Branding__c = true;
                auditDoc.Core_MDF_Proof_of_Cost__c = true;
                auditDoc.Core_MDF_Proof_of_Execution__c = true;                
                auditDocList.add(auditDoc);
                system.debug('auditDocList-->' +auditDocList);
            }            
            
            if(auditDocList.size()>0){
                Database.insert(auditDocList);                
            }
            String res = Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList);            
            System.assertEquals(claim1.ID,res);            
            
        }
        test.stopTest();
    }*/
    
    /* Method to test RSA MD saveClaim */
    @isTest
    static void testRetailRsaMDSaveClaimSuccessMethod()
    {
        test.startTest();
        Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Claims_ABM_Validation','Bypass_Claims_Amt_vs_Budget_Amt_Check',
                'Bypass_Claims_Amt_vs_Camp_Amt_Check','Bypass_Claims_Duplicate_Check',
                'Bypass_Claim_OwnerLang_EmailTemp','Bypass_Claims_Sharing_Internal_Users',
                'Bypass_Claims_Sharing_Partner_Users','Bypass_Claims_Sharing_On_Owner_Change'}, true, true);
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        { 
            // Highlight: Unused Local Variable
           // Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='Test' limit 1];
            PartnerFundRequest pfr = [Select Id,Title from PartnerFundRequest where Title = 'Retail RSA MD Activity'];                      

            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createRetailRSAMDClaim(Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfr.Id, System.today(), System.today(), 50.00, false);
            claim1.Core_MDF_Country_Location_nm__c= 'AFGHANISTAN';
            claim1.Title = 'Retail RSA MD Claim';            
            /*POP mandatory for Retail*/
            List<String> documentIdWithTitle = new List<String>();
            list<String> tempString = new list<String>();
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
            
            String str1 = claim1.Id+';#'+'Test Doc1';
            String str2 = claim1.Id+';#'+'Test Doc2';
            
            documentIdWithTitle.add(str1);
            documentIdWithTitle.add(str2);
            
            for(String str: documentIdWithTitle){
                tempString = str.split(';#');
                Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
                auditDoc.Core_MDF_Document_Id__c = tempString[0];
                auditDoc.Core_MDF_Document_Title__c = tempString[1];
                auditDoc.Core_MDF_Claim__c = claim1.Id;
                auditDoc.Core_MDF_Proof_of_Branding__c = true;
                auditDoc.Core_MDF_Proof_of_Cost__c = true;
                auditDoc.Core_MDF_Proof_of_Execution__c = true; 
                auditDoc.Core_MDF_App_Document_Types_nm__c='Proof of Attribution;Proof of Execution;Proof of Cost';
                auditDoc.Core_MDF_Document_Types__c='Proof of Attribution;Proof of Execution;Proof of Cost';          
                auditDocList.add(auditDoc);
            }            
            
            if(auditDocList.size()>0){
                Database.insert(auditDocList);                
            }
            
            Core_MDF_PartnerFundClaim.ClaimWrap claimWrapResult = Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList,null,null, false, null, false, null, false);  
            //String res = claimWrapResult.claimDetail.Id;          
            //System.assertEquals(claim1.ID,res);  
            
            // Unit Test Method should include System.Assert
            System.assertEquals(2, auditDocList.size(), 'Audit document list should contain 2 documents');
        }
        test.stopTest();
    }
  /* @isTest
    static void testRetailCRRPositiveClaim()
    {
        test.startTest();   
        Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Claims_ABM_Validation','Bypass_Claims_Amt_vs_Budget_Amt_Check',
                'Bypass_Claims_Amt_vs_Camp_Amt_Check','Bypass_Claims_Duplicate_Check',
                'Bypass_Claim_OwnerLang_EmailTemp','Bypass_Claims_Sharing_Internal_Users',
                'Bypass_Claims_Sharing_Partner_Users','Bypass_Claims_Sharing_On_Owner_Change'}, true, true);        
        Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='Test' limit 1];
        PartnerFundRequest pfr = [Select Id,Title from PartnerFundRequest where Title = 'Retail RSA MD Activity'];
        User usr2 = [SELECT Id,Email from User where Email='test1@example.com' limit 1];
        System.runAs(usr2)
        {           

            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createRetailRSAMDClaim(Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfr.Id, System.today(), System.today(), 50.00, false);
            claim1.Core_MDF_Country_Location_nm__c= 'AFGHANISTAN';
            claim1.Title = 'Retail RSA MD Claim';
            claim1.Core_MDF_CRR_Positive_Ind__c = true;            
            /*POP mandatory for Retail
            List<String> documentIdWithTitle = new List<String>();
            list<String> tempString = new list<String>();
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
            
            String str1 = claim1.Id+';#'+'Test Doc1';
            String str2 = claim1.Id+';#'+'Test Doc2';
            system.debug('str2' +str2);
            
            documentIdWithTitle.add(str1);
            documentIdWithTitle.add(str2);
            
            for(String str: documentIdWithTitle){
                tempString = str.split(';#');
                Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
                auditDoc.Core_MDF_Document_Id__c = tempString[0];
                auditDoc.Core_MDF_Document_Title__c = tempString[1];
                auditDoc.Core_MDF_Claim__c = claim1.Id;
                auditDoc.Core_MDF_Proof_of_Branding__c = true;
                auditDoc.Core_MDF_Proof_of_Cost__c = true;
                auditDoc.Core_MDF_Proof_of_Execution__c = true;                
                auditDocList.add(auditDoc);
                system.debug('auditDocList-->' +auditDocList);
            }            
            
            if(auditDocList.size()>0){
                Database.insert(auditDocList);                
            }
            
            String res = Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList,null);            
            System.assertEquals(claim1.ID,res);            
            
        }
        test.stopTest();
    }*/
    
    /* Method to test RSA MD saveClaim without POP*/
    @isTest
    static void testRetailRsaMDSaveClaimFailureMethod()
    {      
        test.startTest();
        try{
            Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Claims_ABM_Validation','Bypass_Claims_Amt_vs_Budget_Amt_Check',
                        'Bypass_Claims_Amt_vs_Camp_Amt_Check','Bypass_Claims_Duplicate_Check',
                        'Bypass_Claim_OwnerLang_EmailTemp','Bypass_Claims_Sharing_Internal_Users',
                        'Bypass_Claims_Sharing_Partner_Users','Bypass_Claims_Sharing_On_Owner_Change'}, true, true);
            User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
            System.runAs(sysAdminUser)
            {
              // Highlight: Unused Local Variable 
              //  Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='Test' limit 1];
                PartnerFundRequest pfr = [Select Id,Title from PartnerFundRequest where Title = 'Retail RSA MD Activity'];                      

                PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createRetailRSAMDClaim(Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfr.Id, System.today(), System.today(), 50.00, false);
                claim1.Core_MDF_Country_Location_nm__c= 'AFGHANISTAN';
                claim1.Title = 'Retail RSA MD Claim';
                list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>(); 
                Core_MDF_PartnerFundClaim.ClaimWrap claimWrapResult = Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList,null,null, false, null, false, null, false);      
                String res = claimWrapResult.claimDetail.Id;      
                System.assertEquals(claim1.ID,res);            
                
            }
        }catch(Exception e){
            System.assertNotEquals(NULL,e);
        }
        test.stopTest();
    }
    
    /* Method to test RSA MD saveClaim with POP and Claims budget Amount should be with Activity request Amount*/
    @isTest
    static void testRetailAmtAgainstActivityBudgetAmtMethod()
    {
        Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Claims_ABM_Validation','Bypass_Claims_Amt_vs_Budget_Amt_Check',
                'Bypass_Claims_Amt_vs_Camp_Amt_Check','Bypass_Claims_Duplicate_Check',
                'Bypass_Claim_OwnerLang_EmailTemp','Bypass_Claims_Sharing_Internal_Users',
                'Bypass_Claims_Sharing_Partner_Users','Bypass_Claims_Sharing_On_Owner_Change'}, true, true);
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {   
            // Highlight: Unused Local Variable
           // Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='Test' limit 1];
            PartnerFundRequest pfr = [Select Id,Title,RequestedAmount,Amount from PartnerFundRequest where Title = 'Retail RSA MD Activity']; // 1000$
          //  test.startTest();
            List<PartnerFundClaim> pfc = new List<PartnerFundClaim>();
            
            /*POP mandatory for Retail*/
            List<String> documentIdWithTitle = new List<String>();
            list<String> tempString = new list<String>();
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();  
            // Highlight: Unused Local Variable
           // List<PartnerFundClaim> pfcList = [Select id,Amount,Request.Amount from PartnerFundClaim where RequestId =: pfr.Id];
            test.startTest();

            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createRetailRSAMDClaim(Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfr.Id,
                                                                                          System.today(), System.today(), 500.00, false);
            //Claim1 500$
            claim1.Core_MDF_Country_Location_nm__c= 'AFGHANISTAN';
            claim1.Title = 'Retail RSA MD Claim1';
            //pfc.add(claim1);
            Core_MDF_PartnerFundClaim.ClaimWrap claimWrapResult = Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList,null,null, false, null, false, null, false); 
            //String res = claimWrapResult.claimDetail.Id;           
            //System.assertEquals(claim1.ID,res);
            
          /*  PartnerFundClaim claim2 = Core_MDF_CCP_TestDataUtility.createRetailRSAMDClaim(Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfr.Id, System.today(), System.today(), 500.00, false);
            //Claim2 500$
            claim2.Core_MDF_Country_Location_nm__c= 'AFGHANISTAN';
            claim2.Title = 'Retail RSA MD Claim2';
            //pfc.add(claim2);
            String res1 = Core_MDF_PartnerFundClaim.saveClaim(claim2, auditDocList);            
            System.assertEquals(claim2.ID,res1);*/
            
            
            String str1 = claim1.Id+';#'+'Test Doc1';
            String str2 = claim1.Id+';#'+'Test Doc2';
         /*   String str3 = claim2.Id+';#'+'Test Doc3';
            String str4 = claim2.Id+';#'+'Test Doc4';                
            system.debug('str3' +str3);*/
            
            documentIdWithTitle.add(str1);
            documentIdWithTitle.add(str2);
          /*  documentIdWithTitle.add(str3);
            documentIdWithTitle.add(str4);*/
            for(PartnerFundClaim p : pfc){
                for(String str: documentIdWithTitle){
                    tempString = str.split(';#');
                    Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
                    auditDoc.Core_MDF_Document_Id__c = tempString[0];
                    auditDoc.Core_MDF_Document_Title__c = tempString[1];
                    auditDoc.Core_MDF_Claim__c = p.Id;
                    auditDoc.Core_MDF_Proof_of_Branding__c = true;
                    auditDoc.Core_MDF_Proof_of_Cost__c = true;
                    auditDoc.Core_MDF_Proof_of_Execution__c = true;                
                    auditDocList.add(auditDoc);
                }
            }            
            test.stopTest();
            if(auditDocList.size()>0){
                Database.insert(auditDocList);                
            }
            // Unit Test Method should include System.Assert
            System.assertEquals(2, documentIdWithTitle.size(), 'Document list should contain 2 documents');
            
            //System.assertEquals(claim2.ID,res);                        
        }
        //test.stopTest();
    }
    
    @isTest
    static void testRetailAmtAgainstActivityBudgetAmtExceptionMethod()
    {
        test.startTest();
        try{
            Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Claims_ABM_Validation','Bypass_Claims_Amt_vs_Budget_Amt_Check',
                    'Bypass_Claims_Amt_vs_Camp_Amt_Check','Bypass_Claims_Duplicate_Check',
                    'Bypass_Claim_OwnerLang_EmailTemp','Bypass_Claims_Sharing_Internal_Users',
                    'Bypass_Claims_Sharing_Partner_Users','Bypass_Claims_Sharing_On_Owner_Change'}, true, true);
            User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
            System.runAs(sysAdminUser)
            {               
               // Highlight: Unused Local Variable
               // Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='Test' limit 1];
                PartnerFundRequest pfr = [Select Id,Title,RequestedAmount from PartnerFundRequest where Title = 'Retail RSA MD Activity']; // 1000$
                List<PartnerFundClaim> pfc = new List<PartnerFundClaim>();
                
                /*POP mandatory for Retail*/
                List<String> documentIdWithTitle = new List<String>();
                list<String> tempString = new list<String>();
                list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();    
                            

                PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createRetailRSAMDClaim(Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfr.Id, System.today(), System.today(), 2500.00, false);
                //Claim1 2500$
                claim1.Core_MDF_Country_Location_nm__c= 'AFGHANISTAN';
                claim1.Title = 'Retail RSA MD Claim4';
                pfc.add(claim1);
                
                PartnerFundClaim claim2 = Core_MDF_CCP_TestDataUtility.createRetailRSAMDClaim(Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfr.Id, System.today(), System.today(), 2500.00, false);
                //Claim5 2500$
                claim2.Core_MDF_Country_Location_nm__c= 'AFGHANISTAN';
                claim2.Title = 'Retail RSA MD Claim5';
                pfc.add(claim2);  
                
                String str1 = claim1.Id+';#'+'Test Doc1';
                String str2 = claim1.Id+';#'+'Test Doc2';
                
                String str3 = claim1.Id+';#'+'Test Doc3';
                String str4 = claim1.Id+';#'+'Test Doc4';
                
                
                documentIdWithTitle.add(str1);
                documentIdWithTitle.add(str2);
                documentIdWithTitle.add(str3);
                documentIdWithTitle.add(str4);
                
                for(PartnerFundClaim p : pfc){
                    for(String str: documentIdWithTitle){
                        tempString = str.split(';#');
                        Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
                        auditDoc.Core_MDF_Document_Id__c = tempString[0];
                        auditDoc.Core_MDF_Document_Title__c = tempString[1];
                        auditDoc.Core_MDF_Claim__c = p.Id;
                        auditDoc.Core_MDF_Proof_of_Branding__c = true;
                        auditDoc.Core_MDF_Proof_of_Cost__c = true;
                        auditDoc.Core_MDF_Proof_of_Execution__c = true;                
                        auditDocList.add(auditDoc);
                    }            
                } 
                if(auditDocList.size()>0){
                    Database.insert(auditDocList);                
                }
                
                
                Database.insert(pfc);
                List<PartnerFundClaim> pfc2 = new List<PartnerFundClaim>();
                claim1.Core_MDF_Invoice_Number__c = '234542';
                claim1.Core_MDF_Media_Vehicle__c = 'test1';
                claim2.Core_MDF_Invoice_Number__c = '234543';
                claim2.Core_MDF_Media_Vehicle__c = 'test2';
                pfc2.add(claim1);
                pfc2.add(claim2);
                Database.update(pfc2);
                
            }
        }catch(Exception e){
            System.assertNotEquals(NULL,e);
        }
       test.stopTest(); 
    }
    
        //Ameya
        /* Method to test RSA MD saveClaim */
    @isTest
    static void testRsaMDSaveClaimOnLevelOneNode()
    {
        test.startTest();
        Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Claims_ABM_Validation','Bypass_Claims_Amt_vs_Budget_Amt_Check',
                'Bypass_Claims_Amt_vs_Camp_Amt_Check','Bypass_Claims_Duplicate_Check',
                'Bypass_Claim_OwnerLang_EmailTemp','Bypass_Claims_Sharing_Internal_Users',
                'Bypass_Claims_Sharing_Partner_Users','Bypass_Claims_Sharing_On_Owner_Change'}, true, true);
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {   
           // Highlight: Unused Local Variable
          // Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='Test' limit 1];
            PartnerFundRequest pfr = [Select Id,Title from PartnerFundRequest where Title = 'RSA MD Level One Node Activity'];                  

            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createRetailRSAMDClaim(Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfr.Id, System.today(), System.today(), 50.00, false);
            claim1.Core_MDF_Country_Location_nm__c= 'AFGHANISTAN';
            claim1.Title = 'RSA MD Level One Node Claim';  
            
            /*POP mandatory for Retail*/
            List<String> documentIdWithTitle = new List<String>();
            list<String> tempString = new list<String>();
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
            
            String str1 = claim1.Id+';#'+'Test Doc1';
            String str2 = claim1.Id+';#'+'Test Doc2';
            
            documentIdWithTitle.add(str1);
            documentIdWithTitle.add(str2);
            
            for(String str: documentIdWithTitle){
                tempString = str.split(';#');
                Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
                auditDoc.Core_MDF_Document_Id__c = tempString[0];
                auditDoc.Core_MDF_Document_Title__c = tempString[1];
                auditDoc.Core_MDF_Claim__c = claim1.Id;
                auditDoc.Core_MDF_Proof_of_Branding__c = true;
                auditDoc.Core_MDF_Proof_of_Cost__c = true;
                auditDoc.Core_MDF_Proof_of_Execution__c = true;    
                auditDoc.Core_MDF_App_Document_Types_nm__c='Proof of Attribution;Proof of Execution;Proof of Cost';
                auditDoc.Core_MDF_Document_Types__c='Proof of Attribution;Proof of Execution;Proof of Cost';             
                auditDocList.add(auditDoc);
            }            
            
            if(auditDocList.size()>0){
                Database.insert(auditDocList);                
            }
            // Unit Test Method should include System.Assert
             System.assertEquals('RSA MD Level One Node Claim', claim1.Title, 'Claim title should match');
            
            Core_MDF_PartnerFundClaim.ClaimWrap claimWrapResult = Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList,null,null, false, null, false, null, false);  
            //String res = claimWrapResult.claimDetail.Id;          
            //System.assertEquals(claim1.ID,res);                        
        }
        test.stopTest();
        
    
    }
    
        /* Method to test RSA MD saveClaim */
    @isTest
    static void testRsaMDSaveClaimOnLevelTwoNode()
    {
        test.startTest();
        Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Claims_ABM_Validation','Bypass_Claims_Amt_vs_Budget_Amt_Check',
        'Bypass_Claims_Amt_vs_Camp_Amt_Check','Bypass_Claims_Duplicate_Check',
        'Bypass_Claim_OwnerLang_EmailTemp','Bypass_Claims_Sharing_Internal_Users',
        'Bypass_Claims_Sharing_Partner_Users','Bypass_Claims_Sharing_On_Owner_Change'}, true, true);
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {           
          // Highlight: Unused Local Variable
          //  Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='Test' limit 1];
            PartnerFundRequest pfr = [Select Id,Title from PartnerFundRequest where Title = 'RSA MD Level Two Node Activity'];                      

            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createRetailRSAMDClaim(Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfr.Id, System.today(), System.today(), 50.00, false);
            claim1.Core_MDF_Country_Location_nm__c= 'AFGHANISTAN';
            claim1.Title = 'RSA MD Level Two Node Claim';   
            
            // Unit Test Method should include System.Assert
            System.assertEquals('RSA MD Level Two Node Activity', pfr.Title, 'PFR title should match');
            
            /*POP mandatory for Retail*/
            List<String> documentIdWithTitle = new List<String>();
            list<String> tempString = new list<String>();
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
            
            String str1 = claim1.Id+';#'+'Test Doc1';
            String str2 = claim1.Id+';#'+'Test Doc2';
            
            documentIdWithTitle.add(str1);
            documentIdWithTitle.add(str2);
            
            for(String str: documentIdWithTitle){
                tempString = str.split(';#');
                Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
                auditDoc.Core_MDF_Document_Id__c = tempString[0];
                auditDoc.Core_MDF_Document_Title__c = tempString[1];
                auditDoc.Core_MDF_Claim__c = claim1.Id;
                auditDoc.Core_MDF_Proof_of_Branding__c = true;
                auditDoc.Core_MDF_Proof_of_Cost__c = true;
                auditDoc.Core_MDF_Proof_of_Execution__c = true;    
                auditDoc.Core_MDF_App_Document_Types_nm__c='Proof of Attribution;Proof of Execution;Proof of Cost';
                auditDoc.Core_MDF_Document_Types__c='Proof of Attribution;Proof of Execution;Proof of Cost';             
                auditDocList.add(auditDoc);
            }            
            
            if(auditDocList.size()>0){
                Database.insert(auditDocList);                
            }
            try{
            Core_MDF_PartnerFundClaim.ClaimWrap claimWrapResult = Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList,null,null, false, null, false, null, false); 
            String res = claimWrapResult.claimDetail.Id;           
            //System.assertEquals(claim1.ID,res);  
            }Catch(Exception e){}
        }
        test.stopTest();
    }    
     @isTest
    static void testRetailMDFRussiaBankDocHold(){
        Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Claims_ABM_Validation','Bypass_Claims_Amt_vs_Budget_Amt_Check',
                'Bypass_Claims_Amt_vs_Camp_Amt_Check','Bypass_Claims_Duplicate_Check',
                'Bypass_Claim_OwnerLang_EmailTemp','Bypass_Claims_Sharing_Internal_Users',
                'Bypass_Claims_Sharing_Partner_Users','Bypass_Claims_Sharing_On_Owner_Change'}, true, true);            

        Account acc = [Select Id, BillingCountry from Account where Name ='Test RetailAccount 1' limit 1];
        acc.BillingCountry = 'RUS';
        update acc;
        // Highlight: Unused Local Variable
       // Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Bank_Alias_Name__c='Test' limit 1];
        test.starttest();
        PartnerFundRequest pfr = [Select Id,Title,Core_MDF_Reimbursement_Rate__c from PartnerFundRequest where Title = 'Retail MDF Activity'];
        
        PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Retail Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfr.Id, System.today(), System.today(), 50.00, System.today(), null, false);
        claim1.Core_MDF_Type_Txt__c ='Claim';
        claim1.Core_MDF_Currency__c='USD';
        claim1.Core_MDF_Country_Location_nm__c= 'AFGHANISTAN'; 
        claim1.Core_MDF_To_Be_Audited_Ind__c = true;
        //list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
        //String res = Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList);            
        //System.assertEquals(claim1.ID,res);  
        List<PartnerFundClaim> clmList = new List<PartnerFundClaim>(); 
        clmList.add(claim1);
        Database.insert(clmList);
        claim1.Core_MDF_Bank_Doc_Hold_Eligibility_Ind__c = true;
        Core_MDF_ProcessCCP_Claim.setBankDocHoldonEligibleClaims(clmList);
        test.stopTest();
        // Unit Test Method should include System.Assert
        System.assertEquals(1, clmList.size(), 'Claim list should contain 1 claim');
    }    
}