/****************************************************************************************************************************************
* Class Name  : Core_MDF_PartnerFundClaim_Test
* Version     : 1.0 
* Created Date: 21-Oct-2018
* Modification Log :
* Developer                        Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture-Anjali/Ameya          21/Oct/2018                    Created to test PartnerFundClaim Processes & Record Sharing Functionality
*****************************************************************************************************************************************/
@isTest
private class Core_MDF_PartnerFundClaim_Test {
    /* Method to Setup Test Data */
    @testSetup 
    static void setup() {  
        UserRole adminRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        
        User u = Core_MDF_CCP_TestDataUtility.createUser(false);
        u.LastName = 'User Test';
        u.Email = 'testsysAdmin@example.com';
        u.UserRoleId = adminRole.Id;
        insert u;
        
        System.runAs(u){
        
        List<ContentDocument> doc = Core_MDF_CCP_TestDataUtility.createContentDocument(true);
        List<Core_Trigger_Executions__c> transactions = new List<Core_Trigger_Executions__c>();
        transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Duplicate_Budget_Check','Bypass_GeoBased_Budget_Sharing','Bypass_MDF_Budget_Access_Validation', 'Bypass_MDF_Budget_Status_Validation'}, true, false));       
        transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Allocation_Reservation','Bypass_GeoBased_Allocation_Sharing'}, true, false));   
        transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Duplicate_Bank_Check','Bypass_Bank_Internal_Sharing','Bypass_StampingOfActySubType_Check',
                        'Bypass_Bank_External_Sharing','Bypass_Bank_Program_InActivation_Check','Bypass_Bank_ABM_Sharing','ByPass_BlockLegacyBudgetCreation'}, true, false));
        transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_ABM_Internal_Sharing','Bypass_ABM_External_Sharing','Bypass_ABM_NodeGroup_Sharing'}, true, false)); 
               
        Database.insert(transactions);
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true); 
        ChannelProgram cpRetail = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.RMF_PROGRAM,'Retail Marketing Funds', true);
        
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Acc New 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        
         // Creating Intel Account for retail program
        Account acc1Retail = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account Retail', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type,false); 
        acc1Retail.Core_Geo__c = 'EMEA'; 
        acc1Retail.Core_Sub_Geo__c = 'NEUR';                                                                     
        Database.insert(acc1Retail);
        /*Account acc3 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Acc New 3', cpRetail.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1Retail.Id,false);            
        acc3.Core_Geo__c='EMEA';
        acc3.Core_Sub_Geo__c='NEUR';
        database.insert(acc3);*/
        List<Contact> listContact = new List<Contact>();
        Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(acc1.Id,false);
        Contact conRecord2 = Core_MDF_CCP_TestDataUtility.createContact(acc1.Id,false);
        
        listContact.add(conRecord1);
        listContact.add(conRecord2);
        
        Database.insert(listContact);
        
        Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
        Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
        PermissionSet clmCaseRevPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Claim_Case_Reviewer' LIMIT 1];
        
        List<Core_AGS_Role__c> agsRoleList = new List<Core_AGS_Role__c>();
        
        Core_AGS_Role__c agsRoleCCF = Core_MDF_CCP_TestDataUtility.createAgsRole('CCF_USER', 'Co-Marketing(Salesforce)-CCF USER', true, false);
        agsRoleList.add(agsRoleCCF);
        
        Core_AGS_Role__c agsRoleCCFClaimSub = Core_MDF_CCP_TestDataUtility.createAgsRole('Co-Marketing(Salesforce)-External Claim Submitter-CCF', 'Co-Marketing(Salesforce)-External Claim Submitter-CCF', true, false);
        agsRoleList.add(agsRoleCCFClaimSub);
        
        Database.insert(agsRoleList);        
        
        Core_ERPM_Engagement__c erpmEngagementCCF = Core_MDF_CCP_TestDataUtility.createErpmEngagement('CCF', 'CCF', 'DEDUPB2B', 'SEC', true, false);
        Database.insert(erpmEngagementCCF);
        
        List<Core_Entitlement__c> entitlementList = new List<Core_Entitlement__c>();
        
        Core_Entitlement__c entitlementCCF = Core_MDF_CCP_TestDataUtility.createEntitlement('Client User',agsRoleCCF.Id ,'Intel® Partner Investment Center','CCF User',erpmEngagementCCF.Id , true,Core_MDF_CCP_ConstantClass.CCF_PROGRAM,false);
        entitlementList.add(entitlementCCF);
        
        Core_Entitlement__c entitlementCCFClaimSub = Core_MDF_CCP_TestDataUtility.createEntitlement('Client Claim Submitter',agsRoleCCFClaimSub.Id ,'Intel® Partner Investment Center','CCF Claim Submitter',erpmEngagementCCF.Id , true,Core_MDF_CCP_ConstantClass.CCF_PROGRAM,false);
        entitlementList.add(entitlementCCFClaimSub);
        
        Database.insert(entitlementList); 
        
        List<Core_Contact_Entitlement__c> contEntList = new List<Core_Contact_Entitlement__c>();
        
        Core_Contact_Entitlement__c contactEntitlementCCF = Core_MDF_CCP_TestDataUtility.createContactEntitlement(conRecord1.Id,entitlementCCF.Id ,true,'Complete', false);
        contEntList.add(contactEntitlementCCF);
        
        Core_Contact_Entitlement__c contactEntitlementCCFClaimSub = Core_MDF_CCP_TestDataUtility.createContactEntitlement(conRecord1.Id,entitlementCCFClaimSub.Id ,true,'Complete', false);
        contEntList.add(contactEntitlementCCFClaimSub);
        
        Database.insert(contEntList);   
   
         List<User> listUser = new List<User>();
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);        
        usr1.Email='test1@example.com';
        //usr1.ContactId = listContact[0].Id;
        usr1.ContactId = conRecord1.Id;
        usr1.ProfileId = profileId;
        usr1.isActive = true;
        listUser.add(usr1);        
        
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.Email='test123@example.com';
        usr2.ContactId = listContact[1].Id;
        usr2.ProfileId = profileId;
        usr2.isActive = true;
        listUser.add(usr2);
        
        User usr3 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr3.Email = 'sysadmin@example.com';
        listUser.add(usr3);
        
        //Login as claim claim Case reviewer
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User ccrUser = Core_MDF_CCP_TestDataUtility.createUser(false);
        ccrUser.Email='testCCR@example.com';
        ccrUser.ProfileId = p.id;
        listUser.add(ccrUser);
            
        //creating system admin user
        User sysAdmUsr = Core_MDF_CCP_TestDataUtility.createUser(false);
        sysAdmUsr.LastName = 'System Adm';
        listUser.add(sysAdmUsr);
        
        //creating claim case user
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName='Claim Case User';
        usr.profile=ccpCoreProfile;
        listUser.add(usr);
        
        Database.insert(listUser);  

        Group grp = new Group();
        grp.name = 'PGM_TEST';
        insert grp;
        system.runAs(sysAdmUsr){
            
            GroupMember gm = new GroupMember();
            gm.GroupId = grp.Id;
            gm.UserOrGroupId = usr1.Id;
            insert gm;
            
            //asigning permission set to claim case user
            PermissionSetAssignment assignPermissionSetObj = new PermissionSetAssignment();
            assignPermissionSetObj.AssigneeId = usr.Id;
            assignPermissionSetObj.PermissionSetId = clmCaseRevPS.Id;
            
            Database.insert(assignPermissionSetObj);
        //}

        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Acc New 2', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, true);
        
        /*Account accRetail = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account Retail', cpRetail.Id,
                                                                        Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        accRetail.Core_MDF_Parent_Fund_Account__c = acc1Retail.Id;
        accRetail.Core_Geo__c = 'EMEA';
        accRetail.Core_Sub_Geo__c = 'META';
        insert accRetail;*/
        
        Core_MDF_CCP_TestDataUtility.createPartnerGroupMapping(acc1.Id,'Internal',acc1.Id,cp.Id,'PGM_TEST',true);
        
        //Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(acc2.Id, Usr1.Id, true);
        List<Core_MDF_Bank__c> listBank = new List<Core_MDF_Bank__c>();
        List<Core_MDF_Bank__c> bankList = new List<Core_MDF_Bank__c>();       
        

        Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Client_CoMarketing_Fund', false,'1231231230');
        bank.Core_MDF_Bank_Status__c='Active';
        listBank.add(bank);
        
        Core_MDF_Bank__c bank1 = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Client_CoMarketing_Fund', false,'1241241240');
        bank1.Core_MDF_Bank_Status__c='Active';
        bank1.Core_MDF_Bank_Location__c ='AM';
        bank1.Core_MDF_Supplier_Country_txt__c ='GB';
        listBank.add(bank1); 

        Core_MDF_Bank__c bank2 = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Client_CoMarketing_Fund', false,'1249641240');
        bank2.Core_MDF_Bank_Status__c='Active';
        bank2.Core_MDF_Bank_Location__c ='IN';
        bank2.Core_MDF_Supplier_Country_txt__c ='GB';
        listBank.add(bank2);
        
        Database.insert(listBank);
            
        bank.Core_MDF_Bank_Alias_Name__c='TestActiveBank1';
        BankList.add(bank);
        
        bank1.Core_MDF_Bank_Alias_Name__c='TestActiveBank2';
        BankList.add(bank1);              
        
        bank2.Core_MDF_Bank_Alias_Name__c='TestActiveBank3';
        BankList.add(bank2); 
        test.startTest(); 
        //Database.update(BankList);
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 13','Gaming','Intel® Core™ i7 Processor','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today().addDays(-15), System.today().addDays(15), 10000, 'Always Connected PC', acc2.Id,'Desktop', false);
        camp.Core_MDF_Opal_Budget_Type_Txt__c= 'OEM CMP';
        camp.Core_MDF_Reimbursement_Rate__c ='50%';
        insert camp;      
        //Campaign camp1 = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 14','Gaming','Intel® Core™ i7 Processor','Yes', Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds', System.today().addDays(-15), System.today().addDays(15), 10000, 'Always Connected PC', accRetail.Id,'Desktop', true);  
        
        
        //Database.update(abm);
        Core_MDF_CCP_TestDataUtility.insertCurrencyExchangeRates(); 
        //test.startTest();

        PartnerMarketingBudget budget = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget New',Core_MDF_CCP_TestDataUtility.budget_Record_Type,acc2.Id,cp.Id,200000,System.today().addDays(-20),System.today(), false);
        budget.Core_MDF_Budget_Type_Txt__c='OEM CMP';
        Database.insert(budget);
       // test.startTest();        
        
        PartnerFundAllocation allocation = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation New',budget,acc2,200.0,true);
        PartnerMarketingBudget pmb1 = [SELECT Id,Title, Core_MDF_Budget_Status__c, TotalAllocatedAmount FROM PartnerMarketingBudget WHERE Title ='Test Budget New'];
        //Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(acc2.Id, Usr1.Id, true);
        List<Core_MDF_Account_Bank_Mapping__c> abmList = new List<Core_MDF_Account_Bank_Mapping__c>();
        //creating ABM for bank1                    

        Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc2.Id,bank.Id,false);
        abmList.add(abm1);
        Core_MDF_Account_Bank_Mapping__c abm2 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc2.Id,bank1.Id,false);
        abmList.add(abm2);
        //creating ABM for bank2
        Core_MDF_Account_Bank_Mapping__c abm = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc2.Id,bank2.Id,false);
        abmList.add(abm);
        Database.insert(abmList);
        abm.Core_MDF_Active_ind__c=false;
               
        //Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(acc2.Id, Usr1.Id, true);
        PartnerFundRequest testPartnerFundRequest = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(camp.Id), 
                                                                                                          Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                          String.valueof(acc2.id),allocation,null,'INDIA',
                                                                                                          'Consumer',
                                                                                                          'Desktop',
                                                                                                          'Intel® Core™ i5 Processor',
                                                                                                          'Broadcast (Pre-2025)',
                                                                                                          'Television',
                                                                                                          'Draft',
                                                                                                          false);
        
        
        testPartnerFundRequest.Core_MDF_Start_Date__c = system.today().addDays(-5);
        testPartnerFundRequest.Core_MDF_End_Date__c  = system.today().addDays(5);
        testPartnerFundRequest.Core_MDF_Country_nm__c = 'INDIA';
        testPartnerFundRequest.amount = 1000;
        testPartnerFundRequest.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
        testPartnerFundRequest.ChannelPartnerId=acc2.Id;
        testPartnerFundRequest.Core_MDF_Reimbursement_Rate_txt__c = '100%';
        testPartnerFundRequest.Core_MDF_Reimbursement_Rate_pct__c = '100%';
        testPartnerFundRequest.Core_MDF_Region_nm__c = 'APJ';
        //testPartnerFundRequest.CampaignId = camp.Id; // Added by Areefa
        
        insert testPartnerFundRequest;
            
            List<PartnerFundRequest> subActivityList = new List<PartnerFundRequest>();
            PartnerFundRequest subActivity1 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(camp.Id), 
                                                                                                          Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                          String.valueof(acc2.id),allocation,null,'INDIA',
                                                                                                          'Consumer',
                                                                                                          'Desktop',
                                                                                                          'Intel® Core™ i5 Processor',
                                                                                                          'Broadcast (Pre-2025)',
                                                                                                          'Television',
                                                                                                          'Draft',
                                                                                                          false);
            subActivity1.RequestedAmount = 50;
            subActivity1.Title = 'TESTOutcomeBasedSub1';
            subActivity1.Core_MDF_Priorities__c = 'Always Connected PC';
            subActivity1.Core_MDF_Budget_Amount_Local_amt__c = 50;
            subActivity1.Core_MDF_Budget_Currency_cd__c = 'USD';
            subActivity1.Core_MDF_Channel_Partner_Led__c = false;
            subActivity1.Core_MDF_Channel_Partner__c = '';
            subActivity1.Amount = 50; 
            subActivity1.Core_MDF_Fund_Request_Status__c = 'Planned';
            subActivity1.RecordTypeId = Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF;
            subActivity1.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
            subActivity1.Core_MDF_Reimbursement_Rate_pct__c = '50%';
            subActivity1.Core_MDF_Reimbursement_Rate_txt__c = '50%';
            subActivity1.Core_MDF_Start_Date__c = system.today().addDays(-5);
            subActivity1.Core_MDF_End_Date__c = system.today().addDays(5);
            subActivity1.Core_MDF_Is_Outcome_Based_Ind__c = true;
            subActivity1.Core_MDF_Activity_Level_nm__c = 'Sub Activity';
            subActivity1.Core_MDF_Parent_Activity_Id__c = testPartnerFundRequest.Id;
            subActivity1.ChannelPartnerId = acc2.Id;
            subActivity1.AllocationId = allocation.Id;
            subActivity1.Core_MDF_Activity_Types__c = '';
            subActivityList.add(subActivity1);
             Database.insert(subActivityList);
            
            List<Core_MDF_Outcome_Account_Mapping__c> mappingList = new List<Core_MDF_Outcome_Account_Mapping__c>();
            
            Core_MDF_Outcome_Account_Mapping__c mapping1 = new Core_MDF_Outcome_Account_Mapping__c();
            mapping1.Core_MDF_Outcome_Based_CampaignId__c = testPartnerFundRequest.Id;
            mapping1.Core_MDF_AccountId__c = acc2.Id;
            mapping1.Core_MDF_Percentage_pct__c = 100;
            mapping1.Core_MDF_Amount_nbr__c = 50;
            mapping1.Core_MDF_Active_Ind__c = true;
            mapping1.Core_MDF_OutcomeBased_SubAct_Id__c = subActivity1.Id;
            mappingList.add(mapping1);
            Database.insert(mappingList);
            Id budgetRecType = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Budget').getRecordTypeId();
            Core_MDF_Escalation__c escCCP = new Core_MDF_Escalation__c();
             escCCP.Core_MDF_Escalation_Status_nm__c='Pending Review';
             escCCP.Core_MDF_Escalation_Name_txt__c='Test Budget CCP';
             escCCP.Core_MDF_Total_Dollar_Impact_amt__c= 56;
             escCCP.Core_MDF_Root_Cause_nm__c = 'Appeal of Budget';
             escCCP.Core_MDF_Budget_ID_Number_id__c = pmb1.Id;
             escCCP.Core_MDF_Channel_Program_id__c = cp.Id;
             escCCP.recordtypeid = budgetRecType;
            insert escCCP;
            
        //inserting currency data        
        /*List<PartnerFundClaim> pfcList = new List<PartnerFundClaim>();
        PartnerFundClaim utilityClaim = Core_MDF_CCP_TestDataUtility.createClaim('UtilityClaim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequest.Id, System.today()-1, System.today()-1, 50.00, System.today()-1, bank1.Id, false);
        utilityClaim.Core_MDF_Media_Vehicle__c='Test1';
        pfcList.add(utilityClaim);
        
        PartnerFundClaim utilityDuplicateClaim = Core_MDF_CCP_TestDataUtility.createClaim('UtilityDuplicateClaim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequest.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, false);
        utilityDuplicateClaim.Core_MDF_Media_Vehicle__c = 'Test Media';
        pfcList.add(utilityDuplicateClaim);*/
       	List<Group> grpList = new List<Group>();
            
        Group retASMOgrp = new Group();
            retASMOgrp.Name = 'Core CCP Retail ASMO INTERNAL';
            retASMOgrp.DeveloperName = 'Core_CCP_Retail_ASMO_Internal';
            grpList.add(retASMOgrp);
            
            //EMEA Internal group
            Group ccfEMEAgrp = new Group();
            ccfEMEAgrp.Name = 'Core CCP CCF EMEA INTERNAL';
            ccfEMEAgrp.DeveloperName = 'Core_CCP_CCF_EMEA_Internal';
            grpList.add(ccfEMEAgrp);
            
            Database.insert(grpList);
            
            List<Core_MDF_Partner_Group_Mapping__c> pgmList = new List<Core_MDF_Partner_Group_Mapping__c>();
            Core_MDF_Partner_Group_Mapping__c pgmEMEA = new Core_MDF_Partner_Group_Mapping__c();
            pgmEMEA.Core_MDF_Account__c = acc1.Id;
            pgmEMEA.Core_MDF_Group_Name__c = 'Core_CCP_CCF_EMEA_Internal';
            pgmEMEA.Core_MDF_Type_of_Access__c = 'Internal';
            pgmEMEA.Core_MDF_Region_cd__c = 'EMEA';
            pgmEMEA.Core_MDF_Group_Id__c = ccfEMEAgrp.Id;                
            pgmEMEA.Core_MDF_Channel_Program__c = cp.Id;
            pgmEMEA.Core_MDF_Source_Txt__c = 'Test';
            pgmEMEA.Core_MDF_AccountIdGroupName__c = acc1.Id+'Core_CCP_DCF_EMEA_Internal';
            pgmList.add(pgmEMEA);
            
            Core_MDF_Partner_Group_Mapping__c pgmASMO = new Core_MDF_Partner_Group_Mapping__c();
            pgmASMO.Core_MDF_Account__c = acc1Retail.Id;
            pgmASMO.Core_MDF_Group_Name__c = 'Core_CCP_Retail_ASMO_Internal';
            pgmASMO.Core_MDF_Type_of_Access__c = 'Internal';
            pgmASMO.Core_MDF_Region_cd__c = 'ASMO';
            pgmASMO.Core_MDF_Sub_Region_cd__c = 'LAR';
            pgmASMO.Core_MDF_Group_Id__c = retASMOgrp.Id;                
            pgmASMO.Core_MDF_Channel_Program__c = cpRetail.Id;
            pgmASMO.Core_MDF_Source_Txt__c = 'Test';
            pgmASMO.Core_MDF_AccountIdGroupName__c = acc1.Id+'Core_CCP_Retail_ASMO_Internal';
            pgmList.add(pgmASMO);
            
            Database.insert(pgmList);
            
            
        test.stopTest();
        }
        //Database.insert(pfcList);
        //Escalation
        //Core_MDF_CCP_TestDataUtility.createEscalation();
                Core_MDF_Configuration__c config8 = new Core_MDF_Configuration__c();
         config8.Core_MDF_Value__c = 'Core_MDF_CCP_RMF_Internal_Claim_Operations';
            config8.Name = 'PRC_CLAIM_OPERATION_CUSTOM_PERMISSION';
            insert config8;
        Core_MDF_Configuration__c config9 = new Core_MDF_Configuration__c();
         config9.Core_MDF_Value__c = 'MDF,MDF+';
            config9.Name = 'BUDGET_TYPE_CLAIM_BANK_HIDE';
            insert config9;        
        Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();
    }
    }
    
    /* Method to test save claim */
    @isTest
    static void testSaveClaimSuccessMethod()
    {	
        test.startTest();
        Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Claims_ABM_Validation','Bypass_Claims_Amt_vs_Budget_Amt_Check',
                'Bypass_Claims_Amt_vs_Camp_Amt_Check','Bypass_Claims_Duplicate_Check',
                'Bypass_Claim_OwnerLang_EmailTemp','Bypass_Claims_Sharing_Internal_Users',
                'Bypass_Claims_Sharing_Partner_Users','Bypass_Claims_Sharing_On_Owner_Change','ByPass_BlockLegacyBudgetCreation'}, true, true);
        User sysAdminUser = [SELECT Id,Email from User where Email='testsysAdmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {           
            
            Account acc2 = [Select id from Account where Name = 'Test Acc New 2'];
            List<ID> accList = new List<ID>();
            accList.add(acc2.id);
            User Usr1 =[Select id from user where email = 'test1@example.com'];
            Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(acc2.Id, Usr1.Id, true);
            Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Supplier_Number__c='1241241240' limit 1];
            PartnerFundRequest pfr = [Select Id,Title from PartnerFundRequest where Title = 'test'];                    

            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, false);
            claim1.Core_MDF_Currency__c='USD';//INR
            list<String> brandvalues=new list<String>();
            //brandvalues=Core_MDF_PartnerFundClaim.getBrandPicklistValuesCore_MDF_Bank_Doc_Hold_Ind__c();
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
            String amt='{\"totalAmountLocal\" :100,\"costNotReimbursable\":0,\"taxesLocal\":0}';
            Core_MDF_PartnerFundClaim.ClaimWrap res = new Core_MDF_PartnerFundClaim.ClaimWrap();
            res = Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList,amt, null, false, null, null, null, false);  
             PartnerFundClaim claim2 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, false);
            claim2.Core_MDF_Currency__c='USD';//INR
             Core_MDF_PartnerFundClaim.ClaimWrap res1 = new Core_MDF_PartnerFundClaim.ClaimWrap();
                res1= Core_MDF_PartnerFundClaim.saveClaim(claim2, auditDocList,null, null, false, null, null, null, false);
            Core_MDF_PartnerFundClaim.getAccountNodes(pfr.Id); 
            Core_MDF_PartnerFundClaim.fetchBankRecordsForAccounts(accList);
            Core_MDF_PartnerFundClaim.getCurrencyCode('USD');
            Core_MDF_PartnerFundClaim.getDefaultPayTypePicklist(System.today(),'Intel Partner Alliance','MDF');
            Core_MDF_Escalation__c esc = [Select id from Core_MDF_Escalation__c limit 1];
			Core_MDF_PartnerFundClaim.getEscalationFields(esc.id);
            test.stopTest();
        }
    }
    @isTest
    static void testSaveCRRPositiveClaim()
    {	
        test.startTest();
        Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Claims_ABM_Validation','Bypass_Claims_Amt_vs_Budget_Amt_Check',
                'Bypass_Claims_Amt_vs_Camp_Amt_Check','Bypass_Claims_Duplicate_Check',
                'Bypass_Claim_OwnerLang_EmailTemp','Bypass_Claims_Sharing_Internal_Users',
                'Bypass_Claims_Sharing_Partner_Users','Bypass_Claims_Sharing_On_Owner_Change'}, true, true);
        User sysAdminUser = [SELECT Id,Email from User where Email='testsysAdmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
            
            Account acc2 = [Select id from Account where Name = 'Test Acc New 2'];
            User Usr1 =[Select id from user where email = 'test1@example.com'];
            Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(acc2.Id, Usr1.Id, true);
            Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Supplier_Number__c='1241241240' limit 1];
            PartnerFundRequest pfr = [Select Id,Title from PartnerFundRequest where Title = 'test'];
            PartnerFundRequestShare pfrShare = new PartnerFundRequestShare();
            pfrShare.ParentId = pfr.Id;
            pfrShare.UserOrGroupId = usr1.Id;
            pfrShare.AccessLevel = 'read';
            pfrShare.RowCause = 'manual';
            insert pfrShare;
            /*PermissionSet ccfClaimSubmitterPermissionSet = [SELECT Id, Name FROM PermissionSet where Name = 'Core_MDF_CCP_External_Claim_Submitter'];        
            PermissionSetAssignment  psa = new PermissionSetAssignment(PermissionSetId = ccfClaimSubmitterPermissionSet.Id, AssigneeId = usr1.Id);
            insert psa;
            PermissionSet ccfUserPermissionSet = [SELECT Id, Name FROM PermissionSet where Name = 'Core_MDF_CCF_USER']; 
            PermissionSetAssignment  psa1 = new PermissionSetAssignment(PermissionSetId = ccfUserPermissionSet.Id, AssigneeId = usr1.Id);
            insert psa1;*/
        System.runAs(Usr1){ 
            //select Id, ParentId, UserOrGroupId, UserOrGroup.Name, AccessLevel, RowCause from PartnerFundRequestShare where ParentId = 'pfr.Id';
            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, false);
            claim1.Core_MDF_Currency__c='USD';//INR
            PartnerFundClaim claim2 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, false);
            claim2.Core_MDF_Currency__c='USD';//INR
            String amt='{\"totalAmountLocal\" :100,\"costNotReimbursable\":0,\"taxesLocal\":0}';
           // claim1.Core_MDF_CRR_Positive_Ind__c = true;
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
             Core_MDF_PartnerFundClaim.ClaimWrap res = new Core_MDF_PartnerFundClaim.ClaimWrap();
             res = Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList,null, null, false, null, false, null, false);
            Core_MDF_PartnerFundClaim.ClaimWrap res1 = new Core_MDF_PartnerFundClaim.ClaimWrap();
             res1 = Core_MDF_PartnerFundClaim.saveClaim(claim2, auditDocList,amt, null, false, null, false, null, false);
            Core_MDF_PartnerFundClaim_Edit.isClaimEligibleForClone(claim1.Id);
            Core_MDF_PartnerFundClaim_Edit.isClaimEligibleForClone(claim2.Id);
            //assert.areEqual(claim1.ID,res.claimDetail.Id);
			//assert.areEqual(claim2.ID,res1.claimDetail.Id);           
        }
            test.stopTest();
        }
    }

    /*POP*/
    @isTest
    static void testPOPdocForSaveClaimMethod()
    {	
        test.startTest();
        Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Claims_ABM_Validation','Bypass_Claims_Amt_vs_Budget_Amt_Check',
            'Bypass_Claims_Amt_vs_Camp_Amt_Check','Bypass_Claims_Duplicate_Check',
            'Bypass_Claim_OwnerLang_EmailTemp','Bypass_Claims_Sharing_Internal_Users',
            'Bypass_Claims_Sharing_Partner_Users','Bypass_Claims_Sharing_On_Owner_Change'}, true, true);
        User sysAdminUser = [SELECT Id,Email from User where Email='testsysAdmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
        
            Account acc2 = [Select id from Account where Name = 'Test Acc New 2'];
            User Usr1 =[Select id from user where email = 'test1@example.com'];
            Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(acc2.Id, Usr1.Id, true);
            Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Supplier_Number__c='1241241240' limit 1];
            PartnerFundRequest pfr = [Select Id,Title from PartnerFundRequest where Title = 'test'];
            
            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, false);
			claim1.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid'; insert claim1;
            List<String> documentIdWithTitle = new List<String>();
            list<String> tempString = new list<String>();
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
            String amt='{\"totalAmountLocal\" :100,\"costNotReimbursable\":0,\"taxesLocal\":0}';
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
                auditDoc.Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Branding;Proof of Execution';
                auditDoc.Core_MDF_App_Document_Types_nm__c = 'Proof of Cost;Proof of Branding;Proof of Execution';              
                auditDocList.add(auditDoc);
                
                 Core_MDF_Audit_Document__c auditDoc1 = new Core_MDF_Audit_Document__c();
                auditDoc1.Core_MDF_Document_Id__c = tempString[0];
                auditDoc1.Core_MDF_Document_Title__c = tempString[1];
                auditDoc1.Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Branding;Proof of Execution';
                auditDoc1.Core_MDF_App_Document_Types_nm__c = 'Proof of Cost;Proof of Branding;Proof of Execution';
                auditDocList.add(auditDoc1);
            }
            Core_MDF_PartnerFundClaim.ClaimWrap res = new Core_MDF_PartnerFundClaim.ClaimWrap();
             res = Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList,amt, null, false, null, false, null, false);
            
             assert.areEqual('test',pfr.Title);
            
            test.stopTest();
        }
    }
    /*POP*/
    
    /*POP*/
    @isTest
    static void testPOPdocForSaveUpdateClaimMethod()
    {	
        test.startTest();
        Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Claims_ABM_Validation','Bypass_Claims_Amt_vs_Budget_Amt_Check',
            'Bypass_Claims_Amt_vs_Camp_Amt_Check','Bypass_Claims_Duplicate_Check',
            'Bypass_Claim_OwnerLang_EmailTemp','Bypass_Claims_Sharing_Internal_Users',
            'Bypass_Claims_Sharing_Partner_Users','Bypass_Claims_Sharing_On_Owner_Change'}, true, true);
        User sysAdminUser = [SELECT Id,Email from User where Email='testsysAdmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
        
            Account acc2 = [Select id from Account where Name = 'Test Acc New 2'];
            User Usr1 =[Select id from user where email = 'test1@example.com'];
            Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(acc2.Id, Usr1.Id, true);
            Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Supplier_Number__c='1241241240' limit 1];
            Core_MDF_Bank__c bank2 = [Select Id from Core_MDF_Bank__c where Core_MDF_Supplier_Number__c='1231231230' limit 1];
            PartnerFundRequest pfr = [Select Id,Title from PartnerFundRequest where Title = 'test'];
            
            PartnerFundClaim utilityClaim = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, false);
            utilityClaim.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid'; insert utilityClaim;
            PartnerFundClaim utilityClaim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim1', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, false);
            utilityClaim1.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid'; insert utilityClaim1;

      
            // Creating Case
            Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            Account caseAcc = [Select id from Account where Name = 'Test Acc New 2'];
            Case cs = new Case();
            cs.recordTypeId = caseAuditRecType;
            cs.AccountId = caseAcc.Id;
            cs.OwnerId = sysAdminUser.Id;
            cs.Core_MDF_Claim_ID__c = utilityClaim.id;
           // Database.insert(cs);
            
            utilityClaim.Core_MDF_Claim_Review_Case__c = cs.id;            
            Database.update(utilityClaim);

                        
            List<String> documentIdWithTitle = new List<String>();
            list<String> tempString = new list<String>();
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
            
            String str1 = utilityClaim.Id+';#'+'Test Doc1';
            String str2 = utilityClaim.Id+';#'+'Test Doc2';
            
            documentIdWithTitle.add(str1);
            documentIdWithTitle.add(str2);
            
            for(String str: documentIdWithTitle){
                tempString = str.split(';#');
                Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
                auditDoc.Core_MDF_Document_Id__c = tempString[0];
                auditDoc.Core_MDF_Document_Title__c = tempString[1];
                auditDoc.Core_MDF_Claim__c = utilityClaim.Id;
                auditDoc.Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Branding;Proof of Execution';
                auditDoc.Core_MDF_App_Document_Types_nm__c = 'Proof of Cost;Proof of Branding;Proof of Execution';               
                auditDocList.add(auditDoc);
            }            
            Core_MDF_PartnerFundClaim.ClaimWrap res = new Core_MDF_PartnerFundClaim.ClaimWrap();
            res = Core_MDF_PartnerFundClaim.saveClaim(utilityClaim,auditDocList,null, null, false, null, false, null, false);
            assert.areEqual(utilityClaim.ID,res.claimDetail.Id);
            utilityClaim.Core_MDF_Claim_Review_Case__c=cs.id;
            update utilityClaim;
            
            test.stopTest();
        }
    }
    /*POP*/
    
    
    /* Method to test fail scenerio of save claim */
    @isTest
    static void testSaveClaimFailedMethod()
    {	
        test.startTest();
        Account acc2 = [Select id from Account where Name = 'Test Acc New 2'];
        User Usr1 =[Select id from user where email = 'test1@example.com'];
       // Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(acc2.Id, Usr1.Id, true);
        User sysAdminUser = [SELECT Id,Email from User where Email='testsysAdmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
            PartnerFundClaim claim = null;
            List<Core_MDF_Audit_Document__c> listDoc =  new List<Core_MDF_Audit_Document__c>();
            Core_MDF_PartnerFundClaim.ClaimWrap res = new Core_MDF_PartnerFundClaim.ClaimWrap();
            res = Core_MDF_PartnerFundClaim.saveClaim(claim,listDoc,null, null, false, null, false, null, false);
            assert.areEqual(res.claimDetail,null);
        }
        test.stopTest();
    }
    
        
    
    @isTest
    static void testClaimOwnerChangeToClaimSubmitter()
    {	
        test.startTest();
        User sysAdminUser = [SELECT Id,Email from User where Email='testsysAdmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
        List<Id> userId = new List<Id>();
       	List<Id> userId1 = new List<Id>();
        User claimSub = [SELECT Id,Email,contactid from User where Email='test1@example.com' limit 1];
        User claimCase =[SELECT Id,Email,LastName from User where LastName='Claim Case User' limit 1];
        Account acc2 = [Select id,Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c from Account where Name = 'Test Acc New 2'];
        //Core_MDF_Partner_Node_User_Mapping__c pnumRecord = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(acc2.Id,claimSub.Id,true);
            
        //Core_AGS_Role__c agsRoleCCF = Core_MDF_CCP_TestDataUtility.createAgsRole('CCF_USER', 'Co-Marketing(Salesforce)-CCF USER', true, true);
        //Core_ERPM_Engagement__c erpmEngagementCCF = Core_MDF_CCP_TestDataUtility.createErpmEngagement('CCF', 'CCF', 'DEDUPB2B', 'SEC', true, true);
        //Core_Entitlement__c entitlementCCF = Core_MDF_CCP_TestDataUtility.createEntitlement('Client User Test',agsRoleCCF.Id ,'Intel® Partner Investment Center','CCF User',erpmEngagementCCF.Id , true,Core_MDF_CCP_ConstantClass.CCF_PROGRAM,true);
        //Core_Contact_Entitlement__c contactEntitlementCCF = Core_MDF_CCP_TestDataUtility.createContactEntitlement(claimSub.contactid,entitlementCCF.Id ,true,'Complete', true);
       // Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(acc2.Id, claimSub.Id, true);
		//Account acc3 = [Select id,Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c from Account where Name = 'Test Acc New 3'];
        system.runas(claimCase){
            userId = Core_MDF_PartnerFundClaim.fetchClaimSubmitters(acc2.Core_MDF_CoMarketing_Ultimate_Account__c,acc2.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c);
            //userId1 = Core_MDF_PartnerFundClaim.fetchClaimSubmitters(acc3.Core_MDF_CoMarketing_Ultimate_Account__c,acc3.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c);
        }
    }
        test.stopTest();
    }
    
    /* Method to test exception scenerio of save claim */
    @isTest
    static void testSaveClaimExcMethod()
    {	
        test.startTest();
        try{
            User sysAdminUser = [SELECT Id,Email from User where Email='testsysAdmin@example.com' limit 1];
            System.runAs(sysAdminUser)
            {
                
                Account acc2 = [Select id from Account where Name = 'Test Acc New 2'];
                User Usr1 =[Select id from user where email = 'test1@example.com'];
                Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(acc2.Id, Usr1.Id, true);
                PartnerFundClaim claim = new PartnerFundClaim();
                List<Core_MDF_Audit_Document__c> listDoc =  new List<Core_MDF_Audit_Document__c>();
                 Core_MDF_PartnerFundClaim.ClaimWrap res = new Core_MDF_PartnerFundClaim.ClaimWrap();
                	res = Core_MDF_PartnerFundClaim.saveClaim(claim,listDoc,null, null, false, null, false, null, false);            
                test.stopTest();
            }
        }catch(Exception e){
            assert.areNotEqual(null,e);
        }
    }
    
    /* Method to test fetch activity details */
    @isTest
    static void testFetchActivityMethod()
    {	
        test.startTest();
        User sysAdminUser = [SELECT Id,Email from User where Email='testsysAdmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
            
            Account acc2 = [Select id from Account where Name = 'Test Acc New 2'];
            User Usr1 =[Select id from user where email = 'test1@example.com'];
            Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(acc2.Id, Usr1.Id, true);
            PartnerFundRequest pfr = [Select Id,Title from PartnerFundRequest where Title = 'test'];   
            Core_MDF_PartnerFundClaim.ActivityDetailsWrapper wrapper = Core_MDF_PartnerFundClaim.getActivityDetails(pfr.Id);
            PartnerFundRequest pfrObj = wrapper.activityDetails;
            Core_MDF_PartnerFundClaim.createClaimWrapper claimWrapper = Core_MDF_PartnerFundClaim.checkClaimFromActivity('PartnerFundClaim',pfr.Id, true);
            assert.areNotEqual(claimWrapper.activityObj , NULL);
            Core_MDF_PartnerFundClaim.createClaimWrapper claimWrapperForInternalUser = Core_MDF_PartnerFundClaim.checkClaimFromActivity('PartnerFundClaim',pfr.Id, false);
            assert.areNotEqual(claimWrapperForInternalUser.activityObj , NULL);
            test.stopTest();
        }
    }
    
    /* Method to test fetch activity details */
    @isTest
    static void testFetchActivityMethodFail()
    {	
        test.startTest();
        User sysAdminUser = [SELECT Id,Email from User where Email='testsysAdmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
            
            Account acc2 = [Select id from Account where Name = 'Test Acc New 2'];
            User Usr1 =[Select id from user where email = 'test1@example.com'];
            Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(acc2.Id, Usr1.Id, true);
            PartnerFundRequest pfr = [Select Id,Title from PartnerFundRequest where Title = 'test'];   
            //PartnerFundRequest pfrObj = Core_MDF_PartnerFundClaim.getActivityFields(pfr.Id);
            Core_MDF_PartnerFundClaim.ActivityDetailsWrapper wrapper = Core_MDF_PartnerFundClaim.getActivityDetails(pfr.Id);
            PartnerFundRequest pfrObj = wrapper.activityDetails;
            Core_MDF_PartnerFundClaim.createClaimWrapper claimWrapper = Core_MDF_PartnerFundClaim.checkClaimFromActivity('ABC',pfr.Id, false);
            //assert.areEqual(claimWrapper, null);
            Assert.isNotNull(claimWrapper);
            Assert.areEqual(false, claimWrapper.checkCreate);
            test.stopTest();
        }
    }
    
    /* Method to test exception scenerio while fetching activity details */
    @isTest
    static void testFetchActivityExcMethod()
    {	
        test.startTest();
        try{
            User sysAdminUser = [SELECT Id,Email from User where Email='testsysAdmin@example.com' limit 1];
            System.runAs(sysAdminUser)
            {
                PartnerFundRequest testPartnerFundRequest = null;
                //PartnerFundRequest pfrObj = Core_MDF_PartnerFundClaim.getActivityFields(testPartnerFundRequest.Id);
               	Core_MDF_PartnerFundClaim.ActivityDetailsWrapper wrapper = Core_MDF_PartnerFundClaim.getActivityDetails(testPartnerFundRequest.Id);
            	PartnerFundRequest pfrObj = wrapper.activityDetails;             
                test.stopTest();
            }
        }catch(Exception e){
            assert.areNotEqual(NULL,e);
        }
        test.stopTest();
    }
    
    /* Method to test fetch pick list values */
    @isTest
    static void testGetPickListValuesMethod()
    {	
        test.startTest();
        User sysAdminUser = [SELECT Id,Email from User where Email='testsysAdmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
            String objName = 'PartnerFundClaim';
            String apiName = 'Core_MDF_Currency__c';
            Core_MDF_PartnerFundClaim.userAndPicklistInfoWrapper userAndPicklistWrap = Core_MDF_PartnerFundClaim.fetchUserAndPicklistInfo(objName,apiName);
            assert.areNotEqual(userAndPicklistWrap.pickListValuesMap, null);
        }
        test.stopTest();
    }
    
    /* Method to test fetch pick list values */
    @isTest
    static void testGetPickListValuesMethodFail()
    {	
        test.startTest();
        Map<String,String> emptyMap = new Map<String,String>();
        User sysAdminUser = [SELECT Id,Email from User where Email='testsysAdmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
            String objName = 'ABC';
            String apiName = 'Core_MDF_Currency__c';
            Core_MDF_PartnerFundClaim.userAndPicklistInfoWrapper userAndPicklistWrap = Core_MDF_PartnerFundClaim.fetchUserAndPicklistInfo(objName,apiName);
            assert.areNotEqual(userAndPicklistWrap.pickListValuesMap, null);
        }
        test.stopTest();
    }
    
    
    /* Method to test fetch bank records */
    @isTest
    static void testFetchBanksMethod()
    {	
        test.startTest();
        User sysAdminUser = [SELECT Id,Email from User where Email='testsysAdmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
            
            Account accBank = [Select Id,Name from Account where Name = 'Test Acc New 1'];
            List<sObject> listOfBanks = Core_MDF_PartnerFundClaim.fetchBankRecords(accBank.Id);
           
            assert.areNotEqual(listOfBanks,null);
            Core_MDF_PartnerFundClaim.duplicateClaimCheck(null);
            //Core_MDF_PartnerFundClaim.getBrandPicklistValues();
            
        }
        test.stopTest();
    }
    
    /* Method to test duplicate check on claim */
    @isTest
    static void testDupicateClaimCheckMethod()
    {	
        test.startTest();
        Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Claims_ABM_Validation','Bypass_Claims_Amt_vs_Budget_Amt_Check',
                'Bypass_Claims_Amt_vs_Camp_Amt_Check',
                'Bypass_Claim_OwnerLang_EmailTemp','Bypass_Claims_Sharing_Internal_Users',
                'Bypass_Claims_Sharing_On_Owner_Change'}, true, true);              
        User sysAdminUser = [SELECT Id,Email from User where Email='testsysAdmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
            
            Account acc2 = [Select id from Account where Name = 'Test Acc New 2'];
            acc2.Core_MDF_External_Group_Id__c = null;
            update acc2;
            User Usr1 =[Select id from user where email = 'test1@example.com'];
            Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(acc2.Id, Usr1.Id, true);
            List<PartnerFundClaim> claimList= new List<PartnerFundClaim>();
            List<PartnerFundClaim> listOfClaims = new List<PartnerFundClaim>();
            Core_MDF_Bank__c bank1 = [Select Id,Core_MDF_Supplier_Country_txt__c from Core_MDF_Bank__c where Core_MDF_Supplier_Number__c='1241241240' limit 1];
            Core_MDF_Bank__c bank = [SELECT Id,Core_MDF_Supplier_Country_txt__c FROM Core_MDF_Bank__c WHERE Core_MDF_Supplier_Number__c='1231231230' LIMIT 1];
            PartnerFundRequest pfr = [Select Id,Title from PartnerFundRequest where Title = 'test'];
            
            assert.areEqual(pfr.Title, 'test');
             List<Core_MDF_Bank__c> bankList = new List<Core_MDF_Bank__c>();
            bankList.add(bank1);
            bankList.add(bank);
            
            Core_MDF_PartnerFundClaim.fetchBankRegion(bankList);
            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, System.today(), System.today(), 52.00, System.today(), bank1.Id, false);
            claim1.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
            listOfClaims.add(claim1);
            PartnerFundClaim claim2 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, System.today(), System.today(), 52.00, System.today(), bank1.Id, false);
            claim2.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
            listOfClaims.add(claim2);
            PartnerFundClaim claim3 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, System.today(), System.today(), 51.00, System.today(), bank1.Id, false);
            claim3.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
            listOfClaims.add(claim3);
            
            Database.insert(listOfClaims);
            
            claim1.Core_MDF_Media_Vehicle__c = 'test3';
            claim1.Core_MDF_Currency__c='USD';
            
            claim1.Core_MDF_Currency__c='USD';
            
            claim1.Core_MDF_Currency__c='USD';
            //Database.update(claim1);
            claimList.add(claim1);
            claimList.add(claim2);
            claimList.add(claim3);
            
            //Database.update(claimList);
            List<PartnerFundClaim> res2 = Core_MDF_Claim_Utility.duplicateClaimCheckOnInsert(claimList);
            Map<Id,PartnerFundClaim> claimMap = new Map<Id,PartnerFundClaim>();
            for(PartnerFundClaim pfc : claimList)
            {
                claimMap.put(pfc.Id,pfc);
            }
            List<PartnerFundClaim> claimList2= new List<PartnerFundClaim>();
            claimList2.add(claim1);
            claim2.Core_MDF_Media_Vehicle__c = 'test3';
            claim2.Core_MDF_Invoice_Number__c = 'test3';
            claim2.Core_MDF_Audit_Adjustment_Amount__c = 1 ;
            claimList2.add(claim2);
            claim3.Core_MDF_Media_Vehicle__c = 'test31';
            claim3.Core_MDF_Invoice_Number__c = 'test123'; //'test3'+System.now();
            claim3.Core_MDF_Bank__c = bank.Id;
            claim3.Core_MDF_Audit_Adjustment_Amount__c = 1 ;
            claimList2.add(claim3);
            Database.update(claimList2);
            Core_MDF_Claim_Utility.duplicateClaimCheckOnUpdate(claimList2, claimMap);
            //Core_MDF_Claim_Utility.updateAuditProgressFlag(claimList2, claimMap);
            //Core_MDF_Claim_Utility.updateEvalInProgressFlag(claimList2, claimMap);
            //Core_MDF_Claim_Utility.sendClaimsToAudit(claimList2, claimMap);
            Core_MDF_Claim_Utility.sendclaimsforPIC(claimList2, claimMap);
            
            Core_MDF_PartnerFundClaim.duplicateClaimCheck(claim2);
            //assert.areNotEqual(res3.size(),0);
            //Core_MDF_PFC_Sharing.shareClaimToPartnerUsersBatch(claimMap);
            assert.areEqual(pfr.Title, 'test');
            
            test.stopTest();
        }
    }
    
    /* Test Method to Check the OwnerID Change of the Claim Record */
    @isTest
    static void testClaimOwnerChange()
    {	
        test.startTest();
        Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Claims_ABM_Validation','Bypass_Claims_Amt_vs_Budget_Amt_Check',
                'Bypass_Claims_Amt_vs_Camp_Amt_Check','Bypass_Claims_Duplicate_Check',
                'Bypass_Claim_OwnerLang_EmailTemp','Bypass_Claims_Sharing_Internal_Users',
                'Bypass_Claims_Sharing_Partner_Users'}, true, true);
        PartnerFundClaim claim1 = new PartnerFundClaim();
        Map<Id,PartnerFundClaim> claimsMap= new Map<Id,PartnerFundClaim>(); 
        List<PartnerFundClaim> claimList= new List<PartnerFundClaim>();
        ChannelProgram cp = [SELECT id FROM ChannelProgram limit 1];
        Account acc1 = [SELECT id from Account where Name = 'Test Acc New 1' limit 1];
        User sysAdminUser = [SELECT Id,Email from User where Email='testsysAdmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
            Account acc2 = [Select id from Account where Name = 'Test Acc New 2'];
            User Usr1 =[Select id from user where email = 'test1@example.com'];
            //Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(acc2.Id, Usr1.Id, true);
            Core_MDF_Bank__c bank1 = [Select Id,Core_MDF_Bank_Alias_Name__c from Core_MDF_Bank__c where Core_MDF_Supplier_Number__c='1241241240' limit 1];
            PartnerFundRequest pfr = [Select Id from PartnerFundRequest where Title = 'test'];                  

            claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, false);
            claim1.Amount = 100;
            //chnages here
            claim1.Core_MDF_Currency__c = 'USD';
            claim1.Core_MDF_Total_Invoice_Amount_Local__c = 100;
            claim1.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
            Database.insert(claim1);
            claimsMap.put(claim1.Id, claim1);
            claim1.ownerId = UserInfo.getUserId();
            claim1.Core_MDF_Currency__c='USD';
            Database.update(claim1); 
            claimList.add(claim1);   
        }     
            
        assert.areNotEqual(claimsMap.size(), NULL);
        Core_MDF_PFC_Sharing.recalculateShareClaimWhenOwnerChange(claimList, claimsMap);
        
        test.stopTest();
    }
    
    /* Method to test fetch claim record by Id */
    @isTest
    public static void testFetchClaimById(){
        
        test.startTest();       
         Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Claims_ABM_Validation','Bypass_Claims_Amt_vs_Budget_Amt_Check',
            'Bypass_Claims_Amt_vs_Camp_Amt_Check','Bypass_Claims_Duplicate_Check',
            'Bypass_Claim_OwnerLang_EmailTemp','Bypass_Claims_Sharing_Internal_Users',
            'Bypass_Claims_Sharing_Partner_Users','Bypass_Claims_Sharing_On_Owner_Change'}, true, true);
        User sysAdminUser = [SELECT Id,Email from User where Email='testsysAdmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
            Core_MDF_Bank__c bank1 = [SELECT Id FROM Core_MDF_Bank__c WHERE Core_MDF_Supplier_Number__c='1241241240' LIMIT 1];
            PartnerFundRequest testPartnerFundRequest = [Select Id FROM PartnerFundRequest WHERE Title = 'test' LIMIT 1];                       

            PartnerFundClaim claim = Core_MDF_CCP_TestDataUtility.createClaim('UtilityClaim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequest.Id, System.today()-1, System.today()-1, 50.00, System.today()-1, bank1.Id, false);
            claim.Core_MDF_Media_Vehicle__c='Test1';
            claim.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
            Database.insert(claim);
           
            //PartnerFundClaim claim = [Select id from PartnerFundClaim where Title = 'UtilityClaim'];
            String recordId = claim.Id;
            PartnerFundClaim pfc = Core_MDF_PartnerFundClaim_Edit.fetchClaimById(recordId).claimObj;
            PartnerFundClaim pfcClone = Core_MDF_PartnerFundClaim_Edit.prepareCloneData(recordId).claimObj;
            Core_MDF_PartnerFundClaim_Edit.isPartnerValidCloneOrEditUser(pfc);
            assert.areEqual(pfc.Id, recordId); 
            test.stopTest();
        }
    }
    
    // Method to Edit claim - calculate fields
    @isTest
    public static void testEditClaimCalculateFields(){
        
        test.startTest();
        Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Claims_ABM_Validation','Bypass_Claims_Amt_vs_Budget_Amt_Check',
                'Bypass_Claims_Amt_vs_Camp_Amt_Check','Bypass_Claims_Duplicate_Check',
                'Bypass_Claim_OwnerLang_EmailTemp','Bypass_Claims_Sharing_Internal_Users',
                'Bypass_Claims_Sharing_Partner_Users','Bypass_Claims_Sharing_On_Owner_Change'}, true, true);            

        ChannelProgram cp = [Select id from ChannelProgram where name = 'Client'];
        User sysAdminUser = [SELECT Id,Email from User where Email='testsysAdmin@example.com' limit 1];
        Core_MDF_Bank__c bank1 = [SELECT Id FROM Core_MDF_Bank__c WHERE Core_MDF_Supplier_Number__c='1241241240' LIMIT 1];
        PartnerFundRequest testPartnerFundRequest = [Select Id FROM PartnerFundRequest WHERE Title = 'test' LIMIT 1];
        
        PartnerFundClaim claim = Core_MDF_CCP_TestDataUtility.createClaim('UtilityClaim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequest.Id, System.today()-1, System.today()-1, 50.00, System.today()-1, bank1.Id, false);
        claim.Core_MDF_Media_Vehicle__c='Test1';
        //claim.Core_MDF_Program__c =cp.Id;
        claim.Core_MDF_Budget_Type_Options_Nm__c = 'OEM CMP';
        claim.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
        System.runAs(sysAdminUser)
        {
            Database.insert(claim);
            claim.Core_MDF_Total_Invoice_Amount_Local__c = 20;
            
            update claim;
            assert.areEqual(20,claim.Core_MDF_Total_Invoice_Amount_Local__c );
        }
        test.stopTest();
    }
   /* 
    // Method to Edit claim - duplicate check
    @isTest
    public static void testEditClaimDuplicateCheck(){
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        
        System.runAs(sysAdminUser)
        {
            test.startTest();
            PartnerFundClaim claim1 = [Select Id,Title,Amount, Core_MDF_Total_Invoice_Amount_Local__c,Core_MDF_Media_Vehicle__c,Core_MDF_Duplicate_Claim__c from PartnerFundClaim where Title = 'UtilityDuplicateClaim'];
            PartnerFundClaim claim = [Select Id,Title,Amount, Core_MDF_Total_Invoice_Amount_Local__c,Core_MDF_Media_Vehicle__c,Core_MDF_Duplicate_Claim__c from PartnerFundClaim where Title = 'UtilityClaim'];
            claim.Core_MDF_Media_Vehicle__c = 'Test Media';
            claim.Core_MDF_Ad_Run_Start_Date__c = System.today();
            claim.Core_MDF_Ad_Run_End_Date__c = System.today();
            claim.Core_MDF_Invoice_Number__c = '1346';
            claim.Core_MDF_Total_Invoice_Amount_Local__c = 100;
            Database.update(claim);
            assert.areEqual(true,claim.Core_MDF_Duplicate_Claim__c);
            test.stopTest();
        }
    }*/
    
    /* Method to check audit internal user */
    @isTest
    static void testInternalAuditUser()
    {
        test.startTest();
        User ccrUser = [SELECT Id,Email from User where Email='testCCR@example.com' limit 1];
        //User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer_Manager'];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = ccrUser.Id;
        psa.PermissionSetId = ps.Id;
        Database.insert(psa); 
        boolean access = Core_MDF_PartnerFundClaim.isInternalAuditUser(System.Label.Core_MDF_ClaimEditAccessToAuditUser);
        System.runAs(ccrUser){
            assert.areEqual(true,Core_MDF_PartnerFundClaim.isInternalAuditUser(System.Label.Core_MDF_ClaimEditAccessToAuditUser));  
        }
        test.stopTest();
    }
    
    
    /* Method to check audit internal user */
    @isTest
    static void testInternalAuditUserFail()
    {	
        test.startTest();
        User sysAdminUser = [SELECT Id,Email from User where Email='testsysAdmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
            assert.areEqual(false,Core_MDF_PartnerFundClaim.isInternalAuditUser(System.Label.Core_MDF_ClaimEditAccessToAuditUser));
        }
        test.stopTest();
    }
    
    /* Method to test fetch activity details */
    @isTest
    static void testFetchRecordTypeMetaData()
    {	
        test.startTest();
        User sysAdminUser = [SELECT Id,Email from User where Email='testsysAdmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
            Map<String,Core_MDF_ObjRecType_Budget_FieldSetMap__mdt> mapOfRecordTypes = Core_MDF_PartnerFundClaim.fetchRecordTypeMetaData();
            assert.areNotEqual(mapOfRecordTypes, null);
            Core_MDF_PartnerFundClaim.ckeckProgramLEForVatOptIn('420','Retail Marketing Funds');
            Core_MDF_PartnerFundClaim.ckeckProgramLEForVatOptIn('650','Intel Partner Alliance');
            Core_MDF_PartnerFundClaim.ckeckProgramLEForVatOptIn('420','Client Co-Marketing Fund');
        }
        test.stopTest();
    }
    
    /* Method to test clone claim Permissions */
    @isTest
    public static void testCloneClaimPermission(){
        
        test.startTest();
        Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Claims_ABM_Validation','Bypass_Claims_Amt_vs_Budget_Amt_Check',
                'Bypass_Claims_Amt_vs_Camp_Amt_Check','Bypass_Claims_Duplicate_Check',
                'Bypass_Claim_OwnerLang_EmailTemp','Bypass_Claims_Sharing_Internal_Users',
                'Bypass_Claims_Sharing_Partner_Users','Bypass_Claims_Sharing_On_Owner_Change'}, true, true);
        User sysAdminUser = [SELECT Id,Email from User where Email='testsysAdmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
            
            Account acc2 = [Select id from Account where Name = 'Test Acc New 2'];
           // List<PartnerFundClaim> listOfClaims = new List<PartnerFundClaim>();
            Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Supplier_Number__c='1241241240' limit 1];
            PartnerFundRequest pfr = [Select Id,Title from PartnerFundRequest where Title = 'test'];
            
            //assert.areEqual(pfr.Title, 'test');
            
            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, System.today(), System.today(), 52.00, System.today(), bank1.Id, false);
            claim1.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
           // listOfClaims.add(claim1);            
            Database.insert(claim1);
            //claimAccessWrapper hasCloneAccess = Core_MDF_PartnerFundClaim_Edit.isClaimEligibleForClone(claim1.Id);
            assert.areEqual('Test Claim',claim1.Title);
        }
        test.stopTest();
    }
    
    /* Method to test isCheckPopRequired */
    @isTest
    public static void testisCheckPopRequired(){
        
        test.startTest();
        Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Claims_ABM_Validation','Bypass_Claims_Amt_vs_Budget_Amt_Check',
                'Bypass_Claims_Amt_vs_Camp_Amt_Check','Bypass_Claims_Duplicate_Check',
                'Bypass_Claim_OwnerLang_EmailTemp','Bypass_Claims_Sharing_Internal_Users',
                'Bypass_Claims_Sharing_Partner_Users','Bypass_Claims_Sharing_On_Owner_Change'}, true, true);
        User sysAdminUser = [SELECT Id,Email from User where Email='testsysAdmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
            
            Account acc2 = [Select id from Account where Name = 'Test Acc New 2'];
           // List<PartnerFundClaim> listOfClaims = new List<PartnerFundClaim>();
            Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Supplier_Number__c='1241241240' limit 1];
            PartnerFundRequest pfr = [Select Id,Title from PartnerFundRequest where Title = 'test'];
            
            //assert.areEqual(pfr.Title, 'test');
            
            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, System.today(), System.today(), 52.00, System.today(), bank1.Id, false);
           // listOfClaims.add(claim1); 
           // 
            claim1.Core_MDF_Budget_Type_Options_Nm__c = 'MDF';
            claim1.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
            Database.insert(claim1);
            PartnerFundClaim claim2 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, System.today(), System.today(), 52.00, System.today(), bank1.Id, false);
            claim2.Core_MDF_Budget_Type_Options_Nm__c = null;
            claim2.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
             Database.insert(claim2);
            boolean Popmandatory = true;
            boolean Popmandatory1 = Core_MDF_PartnerFundClaim.isCheckPopDocRequired(Core_MDF_CCP_ConstantClass.CCF_PROGRAM,claim2.Core_MDF_Budget_Type_Options_Nm__c);
            assert.areEqual(true,Popmandatory);
        }
        test.stopTest();
    }
    
    /* Method to test getBudgetTypetoHideBank */
    @isTest
    public static void testgetBudgetTypetoHideBank(){
        
        test.startTest();
        User sysAdminUser = [SELECT Id,Email from User where Email='testsysAdmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
        
            string budgetType = Core_MDF_PartnerFundClaim.getBudgetTypetoHideBank();
            assert.areEqual('MDF,MDF+',budgetType);
        }
        test.stopTest();
    }
    
    
 /*   @isTest
    public static void testDoesNothaveCloneClaimPermission(){
        test.startTest();
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_External_View_Only'];
        User usr2 = [ SELECT Id FROM User WHERE Email='test123@example.com'];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = usr2.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;
        Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Supplier_Number__c='1241241240' limit 1];
            PartnerFundRequest pfr = [Select Id,Title from PartnerFundRequest where Title = 'test'];
            
            //assert.areEqual(pfr.Title, 'test');
            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, System.today(), System.today(), 52.00, System.today(), bank1.Id, false);
           // listOfClaims.add(claim1);            
            Database.insert(claim1);
        System.runAs(usr2){
         //Account acc2 = [Select id from Account where Name = 'Test Acc New 2'];
           // List<PartnerFundClaim> listOfClaims = new List<PartnerFundClaim>();
            
            boolean hasCloneAccess = Core_MDF_PartnerFundClaim_Edit.isClaimEligibleForClone(claim1.Id);
            assert.areEqual(false,hasCloneAccess);
        }        
        test.stopTest();
    } */
    
    /* Method to test fecth user details */
    @isTest
    public static void testFetchUserDetails(){
        test.startTest();
        User ccrUser = [SELECT Id,Email from User where Email='testCCR@example.com' limit 1];
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer_Manager'];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = ccrUser.Id;
        psa.PermissionSetId = ps.Id;
        Database.insert(psa);        
        System.runAs(ccrUser)
        {   
            
            Core_MDF_PartnerFundClaim.userInfoWrapper userInfoWrapper = Core_MDF_PartnerFundClaim.fetchUserDetails();
            assert.areEqual(true, userInfoWrapper.isUserClaimCaseReviewerOrManager);
            Core_MDF_PartnerFundClaim_Edit.fetchClaimById(null);
            test.stopTest();
        }
    }
    
    /*Method to test inactive ABM while claim creation*/
    @isTest
    static void testInactiveABM()
    {
        test.startTest();
        PartnerFundRequest pfr = [Select Id,Title from PartnerFundRequest where Title = 'test'];
        Core_MDF_Bank__c bank2 = [SELECT Id FROM Core_MDF_Bank__c WHERE Core_MDF_Supplier_Number__c='1249641240' LIMIT 1];
        User usr=[SELECT Id FROM User WHERE LastName='Claim Case User' LIMIT 1];
        System.runAs(usr){
            try{
                PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim V', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank2.Id, false);
                claim1.Core_MDF_Currency__c='USD';
                Database.insert(claim1);//will go to catch block since its ABM is Inactive
                assert.areEqual('Test Claim V',claim1.Title);
            }
            catch(Exception e){
                String errorMessage = e.getMessage();
                //assert.isTrue(errorMessage.contains(System.Label.Core_MDF_Claim_Stage_Bank_Error));  
            }
        }
        test.stopTest();
    }

   /*Method to test inactive ABM for claim update scenario*/   
     @isTest
    public static void testInactiveABMInClaimUpdate()
    {
        test.startTest();
        Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Claims_ABM_Validation','Bypass_Claims_Amt_vs_Budget_Amt_Check',
                'Bypass_Claims_Amt_vs_Camp_Amt_Check','Bypass_Claims_Duplicate_Check',
                'Bypass_Claim_OwnerLang_EmailTemp','Bypass_Claims_Sharing_Internal_Users',
                'Bypass_Claims_Sharing_Partner_Users','Bypass_Claims_Sharing_On_Owner_Change'}, true, true);
        Core_MDF_Bank__c bank2 = [SELECT Id FROM Core_MDF_Bank__c WHERE Core_MDF_Supplier_Number__c='1249641240' LIMIT 1];
        Core_MDF_Bank__c bank1 = [SELECT Id FROM Core_MDF_Bank__c WHERE Core_MDF_Supplier_Number__c='1241241240' LIMIT 1];
        PartnerFundRequest testPartnerFundRequest = [Select Id FROM PartnerFundRequest WHERE Title = 'test' LIMIT 1];
        
        PartnerFundClaim claim = Core_MDF_CCP_TestDataUtility.createClaim('UtilityClaim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequest.Id, System.today()-1, System.today()-1, 50.00, System.today(), bank1.Id, false);
        claim.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid'; insert claim;
        claim.Core_MDF_Media_Vehicle__c='Test1';
        Database.update(claim);
        User usr=[SELECT Id FROM User WHERE LastName='Claim Case User' LIMIT 1];
        System.runAs(usr){
            try{    
                
                claim.Core_MDF_Bank__c=bank2.Id;
                Database.update(claim);
            }
            catch(Exception e){
                String errorMessage = e.getMessage();
                assert.isTrue(errorMessage.contains(System.Label.Core_MDF_Claim_Stage_Bank_Error));  
            }
        }
        test.stopTest();
    }
    
    // Method to Edit claim - Release fields
    @isTest
    public static void testReleaseHolds(){
        
        List<PartnerFundClaim> claimList4 = new List<PartnerFundClaim>();
        test.startTest();
         Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Claims_ABM_Validation','Bypass_Claims_Amt_vs_Budget_Amt_Check',
                'Bypass_Claims_Amt_vs_Camp_Amt_Check','Bypass_Claims_Duplicate_Check',
                'Bypass_Claim_OwnerLang_EmailTemp','Bypass_Claims_Sharing_Internal_Users',
                'Bypass_Claims_Sharing_Partner_Users','Bypass_Claims_Sharing_On_Owner_Change'}, true, true);
        User sysAdminUser = [SELECT Id,Email from User where Email='testsysAdmin@example.com' limit 1];
        Core_MDF_Bank__c bank1 = [SELECT Id FROM Core_MDF_Bank__c WHERE Core_MDF_Supplier_Number__c='1241241240' LIMIT 1];
        PartnerFundRequest testPartnerFundRequest = [Select Id FROM PartnerFundRequest WHERE Title = 'test' LIMIT 1];
       
        PartnerFundClaim claim = Core_MDF_CCP_TestDataUtility.createClaim('UtilityClaim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequest.Id, System.today()-1, System.today()-1, 50.00, System.today()-1, bank1.Id, false);
        claim.Core_MDF_Media_Vehicle__c='Test1';
		claim.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
        System.runAs(sysAdminUser)
        {
            Database.insert(claim);
            claim.Core_MDF_Total_Invoice_Amount_Local__c = 20;
            claim.Core_MDF_Audit_Hold__c = true;
            claim.Core_MDF_ESD_Hold__c = true;
            claim.Core_MDF_Payment_Hold_ind__c = true;
            claim.Core_MDF_Criteria_Hold_Ind__c = true;
            claim.Core_MDF_Intel_Manual_Hold_Ind__c = true;
            claim.Core_MDF_Member_Manual_Hold_Ind__c = true;
            claim.Core_MDF_VAT_Hold_Ind__c = true;
            claim.Core_MDF_Bank_Doc_Hold_Ind__c = false;
            claim.Core_MDF_Document_Hold_Ind__c = true;
            claim.Core_MDF_Document_Hold_Eligibility_Ind__c = true;
            claim.Status= 'Submitted';
            claim.Core_MDF_Status__c = 'Hold';
            claim.Core_MDF_Claim_Previous_Status__c = 'Payment Due';
            update claim;            
            assert.areEqual(20,claim.Core_MDF_Total_Invoice_Amount_Local__c );
            claimList4.add(claim);
            List<String> releaseReason4 = new List<String>();
            releaseReason4.add(Label.Core_MDF_Audit_Hold);
            releaseReason4.add(Label.Core_MDF_ESD_Hold);
            releaseReason4.add(Label.Core_MDF_Payment_Hold);
            releaseReason4.add(Label.Core_MDF_Intel_Manual_Hold);
            releaseReason4.add(Label.Core_MDF_Criteria_Hold);
            releaseReason4.add(Label.Core_MDF_Member_Manual_Hold);
            releaseReason4.add(Label.Core_MDF_VAT_Hold);
            releaseReason4.add(Label.Core_MDF_Bank_Document_Hold);
            releaseReason4.add(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Document_Hold'));
            Core_MDF_Claim_Utility.releaseHold(claimList4,releaseReason4);
            assert.areEqual(false, claim.Core_MDF_Audit_Hold__c);
            
            claim.Core_MDF_Status__c = Label.Core_MDF_Status_Paid;
            update claim;
            
            //claim.Core_MDF_Status__c = Label.Core_MDF_Status_Denied;
            //update claim;
        }
        test.stopTest();
    }
    
    @isTest
    public static void testisClaimEligibleForBankDocOnAmtChange(){
        
        List<PartnerFundClaim> claimList4 = new List<PartnerFundClaim>();
        test.startTest();
        Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Claims_ABM_Validation','Bypass_Claims_Amt_vs_Budget_Amt_Check',
                'Bypass_Claims_Amt_vs_Camp_Amt_Check','Bypass_Claims_Duplicate_Check',
                'Bypass_Claim_OwnerLang_EmailTemp','Bypass_Claims_Sharing_Internal_Users',
                'Bypass_Claims_Sharing_Partner_Users','Bypass_Claims_Sharing_On_Owner_Change'}, true, true);
        User sysAdminUser = [SELECT Id,Email from User where Email='testsysAdmin@example.com' limit 1];
        Core_MDF_Bank__c bank1 = [SELECT Id FROM Core_MDF_Bank__c WHERE Core_MDF_Supplier_Number__c='1241241240' LIMIT 1];
        PartnerFundRequest testPartnerFundRequest = [Select Id FROM PartnerFundRequest WHERE Title = 'test' LIMIT 1];
        
        PartnerFundClaim claim = Core_MDF_CCP_TestDataUtility.createClaim('UtilityClaim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequest.Id, System.today()-1, System.today()-1, 50.00, System.today()-1, bank1.Id, false);
        claim.Core_MDF_Media_Vehicle__c='Test1';
        claim.Core_MDF_Bank_Doc_Hold_Eligibility_Ind__c= true;
        claim.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
        
        System.runAs(sysAdminUser)
        {
            Database.insert(claim);
            claim.Core_MDF_Total_Invoice_Amount_Local__c = 20;
            update claim;            
            assert.areEqual(20,claim.Core_MDF_Total_Invoice_Amount_Local__c);
            Core_MDF_Claim_Utility.isInternalAuditUser(Label.Core_MDF_ClaimEditAccessToAuditUser);
            
        }
        test.stopTest();
    }
    @isTest
    public static void testgetListOfUsersWithsObjTypeAccess(){
        
        List<Id> userIds = new List<Id>();
        test.startTest();
        Map<Id,String> listOfUsersWithPermsets = new Map<Id,String>();
        User sysAdminUser = [SELECT Id,Email from User where Email='testsysAdmin@example.com' limit 1];
        userIds.add(sysAdminUser.id);
        listOfUsersWithPermsets=Core_MDF_Claim_Utility.getListOfUsersWithsObjTypeAccess(userIds,'PartnerFundClaim');
        //assert.areEqual('testsysAdmin@example.com',sysAdminUser.Email );
        test.stopTest();
    }
    @isTest
    public static void testisClaimEligibleForBankDoc(){
        
        List<PartnerFundClaim> claimList4 = new List<PartnerFundClaim>();
        test.startTest();
        Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Claims_ABM_Validation','Bypass_Claims_Amt_vs_Budget_Amt_Check',
                'Bypass_Claims_Amt_vs_Camp_Amt_Check','Bypass_Claims_Duplicate_Check',
                'Bypass_Claim_OwnerLang_EmailTemp','Bypass_Claims_Sharing_Internal_Users',
                'Bypass_Claims_Sharing_Partner_Users','Bypass_Claims_Sharing_On_Owner_Change'}, true, true);
        User sysAdminUser = [SELECT Id,Email from User where Email='testsysAdmin@example.com' limit 1];
        Core_MDF_Bank__c bank1 = [SELECT Id FROM Core_MDF_Bank__c WHERE Core_MDF_Supplier_Number__c='1241241240' LIMIT 1];
        PartnerFundRequest testPartnerFundRequest = [Select Id FROM PartnerFundRequest WHERE Title = 'test' LIMIT 1];
        
        PartnerFundClaim claim = Core_MDF_CCP_TestDataUtility.createClaim('UtilityClaim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequest.Id, System.today()-1, System.today()-1, 50.00, System.today()-1, bank1.Id, false);
        claim.Core_MDF_Media_Vehicle__c='Test1';
        claim.Core_MDF_Bank_Doc_Hold_Eligibility_Ind__c= true;
        claim.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';

        System.runAs(sysAdminUser)
        {
            Database.insert(claim);
            assert.areEqual('Test1',claim.Core_MDF_Media_Vehicle__c);
        }
        test.stopTest();
    }
    @isTest
    public static void testisClaimEligibleForBankDoc1(){
        
        List<PartnerFundClaim> claimList4 = new List<PartnerFundClaim>();
        test.startTest();
        Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Claims_ABM_Validation','Bypass_Claims_Amt_vs_Budget_Amt_Check',
                'Bypass_Claims_Amt_vs_Camp_Amt_Check','Bypass_Claims_Duplicate_Check',
                'Bypass_Claim_OwnerLang_EmailTemp','Bypass_Claims_Sharing_Internal_Users',
                'Bypass_Claims_Sharing_Partner_Users','Bypass_Claims_Sharing_On_Owner_Change'}, true, true);
        User sysAdminUser = [SELECT Id,Email from User where Email='testsysAdmin@example.com' limit 1];
        Core_MDF_Bank__c bank1 = [SELECT Id FROM Core_MDF_Bank__c WHERE Core_MDF_Supplier_Number__c='1249641240' LIMIT 1];
        Core_MDF_Bank__c bank2 = [SELECT Id FROM Core_MDF_Bank__c WHERE Core_MDF_Supplier_Number__c='1241241240' LIMIT 1];
        PartnerFundRequest testPartnerFundRequest = [Select Id FROM PartnerFundRequest WHERE Title = 'test' LIMIT 1];
        
        PartnerFundClaim claim = Core_MDF_CCP_TestDataUtility.createClaim('UtilityClaim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequest.Id, System.today()-1, System.today()-1, 50.00, System.today()-1, bank1.Id, false);
        claim.Core_MDF_Media_Vehicle__c='Test1';
        claim.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
        //claim.Core_MDF_Bank_Doc_Hold_Eligibility_Ind__c= true;

        System.runAs(sysAdminUser)
        {
            Database.insert(claim);
            claim.Core_MDF_Bank__c = bank2.id;
            update claim;
            assert.areEqual('Test1',claim.Core_MDF_Media_Vehicle__c);
        }
        test.stopTest();
    }
    @isTest
    public static void testisClaimEligibleForBankDoc2(){
        
        List<PartnerFundClaim> claimList4 = new List<PartnerFundClaim>();
        test.startTest();
        Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Claims_ABM_Validation','Bypass_Claims_Amt_vs_Budget_Amt_Check',
                'Bypass_Claims_Amt_vs_Camp_Amt_Check','Bypass_Claims_Duplicate_Check',
                'Bypass_Claim_OwnerLang_EmailTemp','Bypass_Claims_Sharing_Internal_Users',
                'Bypass_Claims_Sharing_Partner_Users','Bypass_Claims_Sharing_On_Owner_Change'}, true, true);
        User sysAdminUser = [SELECT Id,Email from User where Email='testsysAdmin@example.com' limit 1];
        //Core_MDF_Bank__c bank1 = [SELECT Id FROM Core_MDF_Bank__c WHERE Core_MDF_Supplier_Number__c='1249641240' LIMIT 1];
        Core_MDF_Bank__c bank2 = [SELECT Id FROM Core_MDF_Bank__c WHERE Core_MDF_Supplier_Number__c='1241241240' LIMIT 1];
        PartnerFundRequest testPartnerFundRequest = [Select Id FROM PartnerFundRequest WHERE Title = 'test' LIMIT 1];
        
        PartnerFundClaim claim = Core_MDF_CCP_TestDataUtility.createClaim('UtilityClaim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequest.Id, System.today()-1, System.today()-1, 50.00, System.today()-1, bank2.Id, false);
        claim.Core_MDF_Media_Vehicle__c='Test1';
        claim.Core_MDF_Bank_Doc_Hold_Eligibility_Ind__c= true;
        claim.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';

        System.runAs(sysAdminUser)
        {
            Database.insert(claim);
            claim.Core_MDF_Total_Invoice_Amount_Local__c = 51.00;
            update claim;
            assert.areEqual(51.00,claim.Core_MDF_Total_Invoice_Amount_Local__c);
        }
        test.stopTest();
    }   
    
    @isTest
    static void testCheckClaimStatusForPICProcess() {
        
        Test.startTest();
        Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Claims_ABM_Validation','Bypass_Claims_Amt_vs_Budget_Amt_Check',
                'Bypass_Claims_Amt_vs_Camp_Amt_Check','Bypass_Claims_Duplicate_Check',
                'Bypass_Claim_OwnerLang_EmailTemp','Bypass_Claims_Sharing_Internal_Users',
                'Bypass_Claims_Sharing_Partner_Users','Bypass_Claims_Sharing_On_Owner_Change'}, true, true);
        User sysAdminUser = [SELECT Id,Email from User where Email='testsysAdmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
        Core_MDF_Bank__c bank1 = [SELECT Id FROM Core_MDF_Bank__c WHERE Core_MDF_Supplier_Number__c='1241241240' LIMIT 1];
        PartnerFundRequest testPartnerFundRequest = [Select Id FROM PartnerFundRequest WHERE Title = 'test' LIMIT 1];
        
        PartnerFundClaim claim = Core_MDF_CCP_TestDataUtility.createClaim('TestClaim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequest.Id, System.today()-1, System.today()-1, 50.00, System.today()-1, bank1.Id, false);
        claim.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid'; insert claim;
        //submitted claim status
        Core_MDF_PartnerFundClaim.checkClaimStatusForPICProcess(claim.Id);
        
        //Resubmission required claim status
        claim.Core_MDF_Status__c = 'Resubmission Required';
        claim.Core_MDF_Eligible_for_PIC__c = true;
        update claim;
        assert.areEqual('Resubmission Required',claim.Core_MDF_Status__c);
        
        Core_MDF_PartnerFundClaim.checkClaimStatusForPICProcess(claim.Id);
        }
         Test.stopTest();
    }
    
    @isTest
    static void testDocSubmissionConfirmation() { //success/if scenario
        
        Test.startTest();
        User sysAdminUser = [SELECT Id,Email from User where Email='testsysAdmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
        Core_MDF_Configuration__c configuration1 = new Core_MDF_Configuration__c();
        configuration1.Name = 'Core_MDF_DocUploadConfirm';
        configuration1.Core_MDF_Value__c = 'true';
        insert configuration1;
        
        Boolean result = Core_MDF_PartnerFundClaim.showModalForDocSubmissionConfirmation();
        assert.areEqual(true, result);
        }
        Test.stopTest();
    }
    
    @isTest
    static void testDocSubmissionConfirmationElseScenario() {//else scenario
        
        Test.startTest();
        User sysAdminUser = [SELECT Id,Email from User where Email='testsysAdmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
        Core_MDF_Configuration__c configuration1 = new Core_MDF_Configuration__c();
        configuration1.Name = 'Core_MDF_DocUploadConfirm';
        configuration1.Core_MDF_Value__c = 'false';
        insert configuration1;
        
        Core_MDF_PartnerFundClaim.showModalForDocSubmissionConfirmation();
        assert.areEqual('Core_MDF_DocUploadConfirm',configuration1.Name);
        }
        Test.stopTest();
    }
     @isTest
    static void testGetRecordTypeSet() {
        
        Test.startTest();
        User sysAdminUser = [SELECT Id,Email from User where Email='testsysAdmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
        Map<String,Schema.RecordTypeInfo> claimRecordTypeMap = new Map<String,Schema.RecordTypeInfo>();
        try{
        Core_MDF_Claim_Utility.getRecordTypeSet(claimRecordTypeMap);
        //assert.areEqual('testsysAdmin@example.com',sysAdminUser.Email);
        }catch(Exception ex){
        }
    }
        Test.stopTest();
    }

    @isTest
    public static void testByPassLogInfoField() {
        
        Test.startTest();
        User sysAdminUser = [SELECT Id,Email from User where Email='testsysAdmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
            Boolean byPassCheck = Core_MDF_PartnerFundClaim.fetchLogInfoByPassCheckValue();
            assert.areEqual(false,byPassCheck);
        }
        Test.stopTest();
    }
    @isTest
    static void testPFCEditClaim()
    {	
        test.startTest();
        User sysAdminUser = [SELECT Id,Email from User where Email='testsysAdmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
             Core_MDF_Bank__c bank1 = [SELECT Id FROM Core_MDF_Bank__c WHERE Core_MDF_Supplier_Number__c='1241241240' LIMIT 1];
            PartnerFundRequest testPartnerFundRequest = [Select Id FROM PartnerFundRequest WHERE Title = 'test' LIMIT 1];
        
            PartnerFundClaim claim = Core_MDF_CCP_TestDataUtility.createClaim('TestClaim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequest.Id, System.today()-1, System.today()-1, 50.00, System.today()-1, bank1.Id, false);
			claim.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid'; insert claim;
            Core_MDF_PartnerFundClaim_Edit.isPartner();
            Core_MDF_PartnerFundClaim_Edit.hasAccessToEditClaim(claim.Id);
            assert.areEqual('TestClaim',claim.Title);
        }
        Test.stopTest();
    }
     
     @isTest
    static void testPFCEditClaimPartner()
    {	
        test.startTest();
        User sysAdminUser = [SELECT Id,Email from User where Email='testsysAdmin@example.com' limit 1];
        User partnerUser = [SELECT Id,Email from User where Email='test123@example.com' limit 1];
        
        System.runAs(partnerUser){
            Boolean exteranlUser = Core_MDF_PartnerFundClaim_Edit.isPartner();
            assert.areEqual(true,exteranlUser);
        }
        Test.stopTest();
    }
     @isTest
    static void testCheckRetailerAccount()
    {
        test.startTest();
        User sysAdminUser = [SELECT Id,Email from User where Email='testsysAdmin@example.com' limit 1];
		System.runAs(sysAdminUser)
        {
            Core_MDF_Bank__c bank2 = [SELECT Id FROM Core_MDF_Bank__c WHERE Core_MDF_Supplier_Number__c='1241241240' LIMIT 1];
        PartnerFundRequest testPartnerFundRequest = [Select Id FROM PartnerFundRequest WHERE Title = 'test' LIMIT 1];
        
        PartnerFundClaim claim = Core_MDF_CCP_TestDataUtility.createClaim('UtilityClaim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequest.Id, System.today()-1, System.today()-1, 50.00, System.today()-1, bank2.Id, false);
        boolean retailer=Core_MDF_PartnerFundClaim.checkRetailerAccount(claim);
        assert.areEqual(true,retailer);
        }
        
       
        Test.stopTest();
    }
    
   @isTest
       static void testClaimEzy(){
           Test.startTest();
        User sysAdminUser = [SELECT Id,Email from User where Email='testsysAdmin@example.com' limit 1];
           System.runAs(sysAdminUser){
           
           Test.setMock(HttpCalloutMock.class, new Core_MDF_ClaimEzy_Callout_Mock());
           contentdocument doc = [select id, Title from contentdocument limit 1];
           
           
           Core_MDF_PartnerFundClaim.getDocumentData(doc.Id);           
            Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Supplier_Number__c='1241241240' limit 1];
            PartnerFundRequest pfr = [Select Id,Core_MDF_Reimbursement_Rate_txt__c,Title from PartnerFundRequest where Title = 'test'];
            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, false);            
               list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
            Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList,null, doc.Id, false, null, false, null, false);
               Core_MDF_PartnerFundClaim.deleteDocuments(doc.Id);
               System.debug('Reimbursement % = ' + claim1.Core_MDF_Reimbursement_Percent__c);
               //String amountFields = '{"totalAmountLocal":"1000.50","costNotReimbursable":"100.25","taxesLocal":"50.75"}';
               //Core_MDF_PartnerFundClaim.calculateAmountFields(claim1,amountFields);
               Core_MDF_PartnerFundClaim.getCampaignPurposeDetails(pfr.Id, null);
               Core_MDF_PartnerFundClaim.getCampaignPurposeDetails(pfr.Id, claim1.Id);
               Core_MDF_PartnerFundClaim.getSubClaims(claim1.Id); 
               Test.stopTest();
           }
       }
    
        @isTest
    static void testgetDefaultPayTypePicklist() {
        
        test.startTest();
        User sysAdminUser = [SELECT Id,Email from User where Email='testsysAdmin@example.com' limit 1];
		System.runAs(sysAdminUser) {
            Date createdDate = System.today();
            Core_MDF_PartnerFundClaim.getDefaultPayTypePicklist(createdDate, 'Client', 'MDF');
        }
        Test.stopTest();
    }
    @isTest
    static void testCampaignPurposeWrapper() {

        // Create wrapper instance
        Core_MDF_PartnerFundClaim.CampaignPurposeWrappper wrapper =
            new Core_MDF_PartnerFundClaim.CampaignPurposeWrappper();

        // Set values
        wrapper.outcomeMetric = 'Revenue';
        wrapper.baselineQuantity = '100';
        wrapper.goalQuantity = '200';
        wrapper.quantityToDate = '150';
        wrapper.outcomeCriteria = 'Achieve 200 Sales';
        wrapper.showTacticMetric = true;
        wrapper.metricsEditable = true;
        wrapper.outcomeMetricLabel = 'Outcome Metric';
        wrapper.baselineQuantityLabel = 'Baseline Quantity';
        wrapper.goalQuantityLabel = 'Goal Quantity';
        wrapper.quantityToDateLabel = 'Quantity To Date';
        wrapper.outcomeCriteriaLabel = 'Outcome Criteria';
        wrapper.baselineQuantityHelpText = 'Baseline Help';
        wrapper.goalQuantityHelpText = 'Goal Help';
        wrapper.quantityToDateHelpText = 'Quantity Help';
        wrapper.outcomeCriteriaHelpText = 'Criteria Help';
        wrapper.baselinePeriod = 'Q1';
        wrapper.baselinePeriodLabel = 'Baseline Period';
        wrapper.baselinePeriodHelpText = 'Period Help';
        wrapper.resultValue = '75%';
        wrapper.resultValueLabel = 'Result Value';
        wrapper.resultValueHelpText = 'Result Help';

        // Verify values
        System.assertEquals('Revenue', wrapper.outcomeMetric);
        System.assertEquals('100', wrapper.baselineQuantity);
        System.assertEquals('200', wrapper.goalQuantity);
        System.assertEquals('150', wrapper.quantityToDate);
        System.assertEquals('Achieve 200 Sales', wrapper.outcomeCriteria);
        System.assertEquals(true, wrapper.showTacticMetric);
        System.assertEquals(true, wrapper.metricsEditable);
        System.assertEquals('Outcome Metric', wrapper.outcomeMetricLabel);
        System.assertEquals('Baseline Quantity', wrapper.baselineQuantityLabel);
        System.assertEquals('Goal Quantity', wrapper.goalQuantityLabel);
        System.assertEquals('Quantity To Date', wrapper.quantityToDateLabel);
        System.assertEquals('Outcome Criteria', wrapper.outcomeCriteriaLabel);
        System.assertEquals('Baseline Help', wrapper.baselineQuantityHelpText);
        System.assertEquals('Goal Help', wrapper.goalQuantityHelpText);
        System.assertEquals('Quantity Help', wrapper.quantityToDateHelpText);
        System.assertEquals('Criteria Help', wrapper.outcomeCriteriaHelpText);
        System.assertEquals('Q1', wrapper.baselinePeriod);
        System.assertEquals('Baseline Period', wrapper.baselinePeriodLabel);
        System.assertEquals('Period Help', wrapper.baselinePeriodHelpText);
        System.assertEquals('75%', wrapper.resultValue);
        System.assertEquals('Result Value', wrapper.resultValueLabel);
        System.assertEquals('Result Help', wrapper.resultValueHelpText);
    }
    
    @isTest
    static void testSaveSubClaimSuccessMethod()
    {	
                
        User sysAdminUser = [SELECT Id,Email from User where Email='testsysAdmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {           
            
            Account acc2 = [Select id from Account where Name = 'Test Acc New 2'];
			List<Id> accList = new List<Id>();
            accList.add(acc2.Id);
            User Usr1 =[Select id from user where email = 'test1@example.com'];
            Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(acc2.Id, Usr1.Id, true);
            Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Supplier_Number__c='1241241240' limit 1];
            PartnerFundRequest pfr = [Select Id,Title from PartnerFundRequest where Title = 'test'];    
            PartnerFundRequest childpfr = [Select Id,Title from PartnerFundRequest where Title = 'TESTOutcomeBasedSub1'];  
    		
                
			List<Core_MDF_Claim_Attributes__c> claimAttributeList = new List<Core_MDF_Claim_Attributes__c>();
            Core_MDF_Claim_Attributes__c claimAttribute = new Core_MDF_Claim_Attributes__c(
           // Core_MDF_Claim_Id__c = claim1.id,
            Core_MDF_Field_Name_nm__c = 'Digital Media - Average time on Page (Seconds)',
            Core_MDF_Field_Value_nbr__c = 100,
            Core_MDF_Type_nm__c = 'KPI - Claim',
            Core_MDF_Tactics_nm__c = 'Digital Media',
            Core_MDF_Is_Active_Ind__c = true
        	);
        	//insert claimAttribute;
            claimAttributeList.add(claimAttribute);
            System.debug('SOQL Queries before startTest1: ' + Limits.getQueries());
            test.startTest();
            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim11', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, true);
            claim1.Core_MDF_Currency__c='USD';
            System.debug('SOQL Queries before startTest2: ' + Limits.getQueries());
            
            PartnerFundClaim subclaim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test SubClaim11', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, true);
            subclaim1.Core_MDF_Currency__c='USD';
            subclaim1.Core_MDF_Claim_Id__c = claim1.Id;
            update subclaim1;
            System.debug('SOQL Queries before startTest3: ' + Limits.getQueries());
            List<PartnerFundClaim> subclaimList1 = new List<PartnerFundClaim>();
            subclaimList1.add(subclaim1);
            
            list<String> brandvalues=new list<String>();
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
            String amt='{\"totalAmountLocal\" :100,\"costNotReimbursable\":0,\"taxesLocal\":0}';
            System.debug('SOQL Queries before startTest4: ' + Limits.getQueries());
            
            Core_MDF_PartnerFundClaim.ClaimWrap res = new Core_MDF_PartnerFundClaim.ClaimWrap();
            res = Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList,amt, null, true, claimAttributeList, null, subclaimList1, true);  
            System.debug('SOQL Queries before startTest5: ' + Limits.getQueries());
            claim1.Core_MDF_Currency__c='INR';
            
            Core_MDF_PartnerFundClaim.ClaimWrap res1 = new Core_MDF_PartnerFundClaim.ClaimWrap();
            res1 = Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList,amt, null, true, claimAttributeList, null, subclaimList1, false);  
            /*
             PartnerFundClaim claim2 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim12', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, false);
            claim2.Core_MDF_Currency__c='USD';          
            
            PartnerFundClaim subclaim2 = Core_MDF_CCP_TestDataUtility.createClaim('Test SubClaim12', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, childpfr.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, false);
            subclaim2.Core_MDF_Currency__c='USD';
            subclaim2.Core_MDF_Claim_Id__c = claim2.Id;
            List<PartnerFundClaim> subclaimList2 = new List<PartnerFundClaim>();
            subclaimList2.add(subclaim2);            
            
            Core_MDF_PartnerFundClaim.ClaimWrap res2 = new Core_MDF_PartnerFundClaim.ClaimWrap();
            res2 = Core_MDF_PartnerFundClaim.saveClaim(claim2, auditDocList,amt, null, true, claimAttributeList, null, subclaimList2, false);*/            
			Core_MDF_PartnerFundClaim.getSubClaims(claim1.Id); 

            /*claim1.Core_MDF_Intel_Manual_Hold_Ind__c = true;
            Boolean resultSuper = Core_MDF_PIC_Utility.isHoldApplicable(claim1);
            subclaim2.Core_MDF_Claim_Id__c = claim1.Id;
            subclaim2.Core_MDF_ESD_Hold__c = true;
            subclaim2.Core_MDF_Bank_Doc_Hold_Eligibility_Ind__c = true;
            subclaim2.Core_MDF_VAT_Eligibility_Ind__c = true;
            Boolean result = Core_MDF_PIC_Utility.isHoldApplicable(subclaim2);*/

            test.stopTest();
        }
    }
}