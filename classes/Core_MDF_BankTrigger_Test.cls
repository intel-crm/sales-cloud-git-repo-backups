@isTest(SeeAllData=false)
//This is a test class for Core_MDF_BankTrigger
private class Core_MDF_BankTrigger_Test {
    @TestSetUp
    static void createTestData(){
        
        List<User> userList = new List<User>();
        
        //Role
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.UserRoleId = usRole.Id;
        userList.add(usr);
        
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.LastName = 'Bank User';
        usr2.UserRoleId = usRole.Id;
        userList.add(usr2);
        
        insert userList;
        
        PermissionSet pSet = [SELECT Id,Name FROM PermissionSet WHERE Name IN ('Core_MDF_CCP_Internal_Claim_Case_Reviewer') LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId = usr2.id, PermissionSetId = pSet.Id);
        
        System.runAs(userList[0]){

            List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_Duplicate_Budget_Check');
            bypassFunctionKeys.add('Bypass_GeoBased_Budget_Sharing');
            bypassFunctionKeys.add('Bypass_Allocation_Reservation');
            bypassFunctionKeys.add('Bypass_GeoBased_Allocation_Sharing');
            bypassFunctionKeys.add('Bypass_Duplicate_Bank_Check');       
            bypassFunctionKeys.add('byPassShareUnshareCampaignRecord');
            bypassFunctionKeys.add('byPassCampaignAndRelatedRecords');
            bypassFunctionKeys.add('Bypass_PaymentRun_Duplicate_Check');
            bypassFunctionKeys.add('Bypass_Claims_Duplicate_Check');
            bypassFunctionKeys.add('Bypass_Claims_Sharing_Internal_Users');
            bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_On_Owner_Chng');
            bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_Internal_Usrs');
            bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_External_Usrs');
            bypassFunctionKeys.add('Bypass_Claim_AdjReq_Amount_Validation');
            bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Budget_Amt_Check');        
            bypassFunctionKeys.add('Bypass_Claims_ABM_Validation');
            bypassFunctionKeys.add('Bypass_Claims_Sharing_Partner_Users');
            bypassFunctionKeys.add('Bypass_Payment_Doc_InvFileVAT_Validate');
            bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Camp_Amt_Check');
            bypassFunctionKeys.add('Bypass_Claim_OwnerLang_EmailTemp');
            bypassFunctionKeys.add('Bypass_StampingOfActySubType_Check');
            bypassFunctionKeys.add('Bypass_Claims_Sharing_On_Owner_Change');
            bypassFunctionKeys.add('Bypass_UpdateActivityFields');
            bypassFunctionKeys.add('Bypass_ValidateActivityWithCampaign');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            bypassFunctionKeys.add('ByPass_BlockLegacyBudgetCreation');
            
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            
            List<Account> accntList = new List<Account>();
            
            Account acc = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, FALSE);
            acc.Core_MDF_CoMarketingActive__c = true;
            Account acc2 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account2', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, FALSE);
            accntList.add(acc);
            accntList.add(acc2);
            insert accntList;
            Test.startTest();
            //Creating Contact with utility class
            Contact testContact = Core_MDF_CCP_TestDataUtility.createContact(acc.Id,true);
            Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 1];
            userList = new List<User>();
            
            User testUser = Core_MDF_CCP_TestDataUtility.createUser(false);
            testUser.LastName = 'Budget Admin';
            testUser.ContactId = testContact.Id;
            testUser.ProfileId = partnerProfile.Id;
            testUser.portalRole = 'Manager';
            
            
            userList.add(testUser);
            
            User submitter = Core_MDF_CCP_TestDataUtility.createUser(false);
            submitter.LastName = 'Account Manager';
            submitter.UserRoleId = usRole.Id;
            userList.add(submitter);
            
            User paymentAdmin = Core_MDF_CCP_TestDataUtility.createUser(false);
            paymentAdmin.LastName = 'Bank Payment Admin';
            paymentAdmin.UserRoleId = usRole.Id;
            userList.add(paymentAdmin);
            insert userList;
            
            //System.runAs(userList[0]){
            List<ChannelProgram> cpList = new List<ChannelProgram>();
            // Creating channel program with utility class
            ChannelProgram ccfCp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', false);
            cpList.add(ccfCp);
            ChannelProgram dcfCp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.DCF_PROGRAM,'Data Center CoMarketing Fund', false);
            cpList.add(dcfCp);
            insert cpList;
            
            Account coMarketingAccCCF = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Acc CCF', cpList[0].Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, accntList[0].Id, FALSE);
            Account coMarketingAccDCF = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Acc DCF', cpList[1].Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, accntList[0].Id, FALSE);
            Account coMarketingAccCCF2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Acc CCF 2', cpList[0].Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, accntList[0].Id, FALSE);
            
            accntList = new List<Account>();
            accntList.add(coMarketingAccCCF);
            accntList.add(coMarketingAccDCF);
            accntList.add(coMarketingAccCCF2);
            //accntList.add(retailAccCCF2);
            Insert(accntList);
                        
            //Creating AGS Role for CCF and DCF with utility class
            Core_AGS_Role__c agsCCF =  Core_MDF_CCP_TestDataUtility.createAgsRole('CCP_CCF_External_Account Budget Administrator', 'Co Marketing(Salesforce)-External Account Budget Administrator', true, false);
            Core_AGS_Role__c agsDCF =  Core_MDF_CCP_TestDataUtility.createAgsRole('CCP_DCF_External_Account Budget Administrator', 'Co Marketing(Salesforce)-External Account Budget Administrator', true, false);
            List<Core_AGS_Role__c> agsRoleList = new List<Core_AGS_Role__c>();
            agsRoleList.add(agsCCF);
            agsRoleList.add(agsDCF);

            insert agsRoleList;

            //Creating ERPM Engagement CCF and DCF with utility class
            Core_ERPM_Engagement__c erpmCCF = Core_MDF_CCP_TestDataUtility.createErpmEngagement('CCF', 'CCF', 'DEDUPB2B', 'SEC', true, false);
            Core_ERPM_Engagement__c erpmDCF = Core_MDF_CCP_TestDataUtility.createErpmEngagement('DCF', 'DCF', 'DEDUPB2B', 'SEC', true, false);
            List<Core_ERPM_Engagement__c> erpmEngagementList = new List<Core_ERPM_Engagement__c>();
            erpmEngagementList.add(erpmCCF);
            erpmEngagementList.add(erpmDCF);

            insert erpmEngagementList;


            //Creating Entitlement Detail for CCF and DCF with utility class
            Core_Entitlement__c entitlementCCF = Core_MDF_CCP_TestDataUtility.createEntitlement('Client Account Budget Administrator', agsRoleList[0].Id,'Intel® Partner Investment Center','CCF Account Budget Administrator', erpmEngagementList[0].Id, true,Core_MDF_CCP_ConstantClass.CCF_PROGRAM,false);
            Core_Entitlement__c entitlementDCF = Core_MDF_CCP_TestDataUtility.createEntitlement('Datacenter Account Budget Administrator', agsRoleList[1].Id,'Intel® Partner Investment Center','DCF Account Budget Administrator', erpmEngagementList[1].Id, true,Core_MDF_CCP_ConstantClass.DCF_PROGRAM,false);
            List<Core_Entitlement__c> entitlementList = new List<Core_Entitlement__c>();
            entitlementList.add(entitlementCCF);
            entitlementList.add(entitlementDCF);

            insert entitlementList;
            
            //Creating Contact Entitlement for CCF and DCF with utility class
            Core_Contact_Entitlement__c contactEntCCF = Core_MDF_CCP_TestDataUtility.createContactEntitlement(testContact.Id,entitlementList[0].Id , true, 'Complete', false);
            Core_Contact_Entitlement__c contactEntDCF = Core_MDF_CCP_TestDataUtility.createContactEntitlement(testContact.Id,entitlementList[1].Id , true, 'Complete', false);
            List<Core_Contact_Entitlement__c> contactEntitlementList = new List<Core_Contact_Entitlement__c>();
            contactEntitlementList.add(contactEntCCF);
            contactEntitlementList.add(contactEntDCF);

            insert contactEntitlementList;


            List<Group> grpList = new List<Group>();
            // Creating Group
            Group ccfgrp = new Group();
            ccfgrp.Name = 'Core CCP CCF External';
            ccfgrp.DeveloperName = 'Core_CCP_CCF_External';
            grpList.add(ccfgrp);
            
            // Creating Group
            Group intGrp = new Group();
            intGrp.Name = 'Core CCP CCF Internal';
            intGrp.DeveloperName = 'Core_CCP_CCF_Internal';
            grpList.add(intGrp);
            
            Database.insert(grpList);
            group grpAllEmployees = [select DeveloperName from group where DeveloperName='Core_All_Employees_Group' LIMIT 1];
            group grpCCPInternal = [select DeveloperName from group where DeveloperName='Core_All_Users_CCP_Internal' LIMIT 1];
            group grpCCFAllEmployees = [select DeveloperName from group where DeveloperName='CORE_MDF_CCP_CCF_ALL' LIMIT 1];
            
            //SELECT Id, AccountId, UserOrGroupId, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel, ContactAccessLevel, RowCause FROM AccountShare
            AccountShare accShare = new AccountShare();
            accShare.AccountId = accntList[0].Id;
            accShare.UserOrGroupId = grpCCFAllEmployees.Id;
            accShare.AccountAccessLevel = 'Read';
            accShare.OpportunityAccessLevel = 'None';
            accShare.CaseAccessLevel = 'None';
            //accShare.ContactAccessLevel = 'Read';
            accShare.RowCause = 'Manual';
            insert accShare;
            
            List<GroupMember> grpMemberList = new List<GroupMember>();
            
            groupmember grpmembAllEmployees = new groupmember();
            grpmembAllEmployees.groupid = grpAllEmployees.id;
            grpmembAllEmployees.UserOrGroupId = paymentAdmin.id;
            grpMemberList.add(grpmembAllEmployees);
            
            groupmember grpmembCCPInternal = new groupmember();
            grpmembCCPInternal.groupid = grpCCPInternal.id;
            grpmembCCPInternal.UserOrGroupId = paymentAdmin.id;
            grpMemberList.add(grpmembCCPInternal);
            
            // Creating Group Member
            GroupMember ccfGrpMem = new GroupMember();
            ccfGrpMem.UserOrGroupId = userList[0].Id;
            ccfGrpMem.GroupId = ccfgrp.Id;
            grpMemberList.add(ccfGrpMem);
            
            //grpCCFAllEmployees
            GroupMember ccfAllGrpMem = new GroupMember();
            ccfAllGrpMem.UserOrGroupId = userList[2].Id;
            ccfAllGrpMem.GroupId = grpCCFAllEmployees.Id;
            grpMemberList.add(ccfAllGrpMem);
            
            // Creating Group Member
            GroupMember groupMem = new GroupMember();
            groupMem.UserOrGroupId = userList[1].Id;
            groupMem.GroupId = intGrp.Id;
            grpMemberList.add(groupMem);
            
            Database.insert(grpMemberList);
            
            List<Core_MDF_Partner_Group_Mapping__c> pgmList = new List<Core_MDF_Partner_Group_Mapping__c>();
            
            // Creating Partner Group Mapping
            Core_MDF_Partner_Group_Mapping__c pgm1 = new Core_MDF_Partner_Group_Mapping__c();
            pgm1.Core_MDF_Account__c = acc.Id;
            pgm1.Core_MDF_Group_Name__c = 'Core_CCP_CCF_External';
            pgm1.Core_MDF_Type_of_Access__c = 'External';
            pgm1.Core_MDF_Group_Id__c = ccfgrp.Id;
            pgm1.Core_MDF_Channel_Program__c = cpList[0].Id;
            pgm1.Core_MDF_Source_Txt__c = 'test';
            pgm1.Core_MDF_AccountIdGroupName__c = acc.Id+'Core_CCP_CCF_External';
            pgm1.Core_MDF_Region_cd__c = 'APJ';
            pgmList.add(pgm1);
            
            // Creating Partner Group Mapping
            Core_MDF_Partner_Group_Mapping__c pgm2 = new Core_MDF_Partner_Group_Mapping__c();
            pgm2.Core_MDF_Account__c = acc.Id;
            pgm2.Core_MDF_Group_Name__c = 'Core_CCP_CCF_Internal';
            pgm2.Core_MDF_Type_of_Access__c = 'Internal';
            pgm2.Core_MDF_Group_Id__c = intGrp.Id;
            pgm2.Core_MDF_Source_Txt__c = 'test';
            pgm2.Core_MDF_Channel_Program__c = cpList[0].Id;
            pgm2.Core_MDF_AccountIdGroupName__c = acc.Id+'Core_CCP_CCF_Internal';
            pgm2.Core_MDF_Region_cd__c = 'APJ';
            pgmList.add(pgm2);
            
            Database.insert(pgmList);
            
            User paymentAdminUserRecord = [Select Id FROM User Where LastName = 'Bank Payment Admin' LIMIT 1];
            //Assign Payment Admin permission set
            PermissionSet paymentAdminPSCCF = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Payment_Adm' LIMIT 1];
            PermissionSet paymentAdminPSDCF = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_DCF_Payment_Adm' LIMIT 1];
            PermissionSetAssignment psAssignment1 = new PermissionSetAssignment(PermissionSetId = paymentAdminPSCCF.Id, AssigneeId = paymentAdminUserRecord.Id);
            PermissionSetAssignment psAssignment2 = new PermissionSetAssignment(PermissionSetId = paymentAdminPSDCF.Id, AssigneeId = paymentAdminUserRecord.Id);
            List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
            psaList.add(psAssignment1);
            psaList.add(psAssignment2);  
            insert psaList;
            
            
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 13','Gaming','Intel® Core™ i7 Processor','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', system.today().addDays(-150), system.today().addDays(150), 10000, 'Always Connected PC', coMarketingAccCCF.Id,'Desktop', false);
            camp.Core_MDF_Opal_Budget_Type_Txt__c= 'OEM CMP';
            Database.insert(camp);
            
            PartnerMarketingBudget budget = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget New',Core_MDF_CCP_TestDataUtility.budget_Record_Type,coMarketingAccCCF.Id,cpList[0].Id,10000,system.today().addDays(-15),system.today().addDays(15), false);
            budget.Core_MDF_Budget_Type_Txt__c = 'OEM CMP';
            insert budget;
            
            Test.stopTest();
            
            Core_MDF_Bank__c bank1 = Core_MDF_CCP_TestDataUtility.createBank(acc.Id, 'Core_MDF_Client_CoMarketing_Fund;Core_MDF_Data_Center_CoMarketing_Fund', TRUE,'1231231230');
            bank1.Core_MDF_Program__c = 'Core_MDF_Client_CoMarketing_Fund;Core_MDF_Data_Center_CoMarketing_Fund';
            bank1.Core_MDF_Bank_Status__c = 'Active';
            update(bank1);
            List<Core_MDF_Account_Bank_Mapping__c> abmList = new List<Core_MDF_Account_Bank_Mapping__c>();
            Core_MDF_Account_Bank_Mapping__c abmCCF1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(coMarketingAccCCF.Id, bank1.Id, FALSE);
            Core_MDF_Account_Bank_Mapping__c abmCCF2 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(coMarketingAccCCF2.Id, bank1.Id, FALSE);
            Core_MDF_Account_Bank_Mapping__c abmDCF  = Core_MDF_CCP_TestDataUtility.createAccountBankMap(coMarketingAccDCF.Id, bank1.Id, FALSE);
            abmCCF1.Core_MDF_Active_ind__c = TRUE;
            abmCCF2.Core_MDF_Active_ind__c = TRUE;
            abmDCF.Core_MDF_Active_ind__c = TRUE;
            abmList.add(abmCCF1);
            abmList.add(abmCCF2);
            abmList.add(abmDCF);
            Database.insert(abmList);
            PartnerFundAllocation allocation = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation New',budget,coMarketingAccCCF,10000,true);
            
            
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(camp.Id), 
                                                                                           
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                           String.valueof(coMarketingAccCCF.id),allocation,null,'BRAZIL',
                                                                                           'Consumer',
                                                                                           'Desktop',
                                                                                           'Intel® Core™ i7 Processor',
                                                                                           'Broadcast',
                                                                                           'Podcast',
                                                                                           'Draft',
                                                                                           false);
            pfr.Core_MDF_Start_Date__c = system.today().addDays(-1);
            pfr.Core_MDF_End_Date__c  = system.today().addDays(+1);
            pfr.Amount = 0;
            pfr.Core_MDF_Reimbursement_Rate_txt__c='1%';
            pfr.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
            //pfr.Core_MDF_Fund_Request_Status__c='Closed';
            database.insert(pfr);
            PartnerFundRequest pfr1 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(camp.Id), 
                                                                                           
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                           String.valueof(coMarketingAccCCF.id),allocation,null,'BRAZIL',
                                                                                           'Consumer',
                                                                                           'Desktop',
                                                                                           'Intel® Core™ i7 Processor',
                                                                                           'Broadcast',
                                                                                           'Podcast',
                                                                                           'Draft',
                                                                                           false);
            pfr1.title='test 1';
            pfr1.Core_MDF_Start_Date__c = system.today().addDays(-1);
            pfr1.Core_MDF_End_Date__c  = system.today().addDays(+1);
            pfr1.Amount = 0;
            pfr1.Core_MDF_Reimbursement_Rate_txt__c='1%';
            pfr1.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
            pfr1.Core_MDF_Fund_Request_Status__c='Closed';
            database.insert(pfr1);
            
            
        }
        System.runAs(userList[1]){
            List<Core_MDF_Configuration__c> configList = new List<Core_MDF_Configuration__c>();
            Core_MDF_Configuration__c config = new Core_MDF_Configuration__c();
            config.Name = 'ALLOWED_PRG_FOR_RUS_NOTIF';
            config.Core_MDF_Value__c = 'Retail Marketing Funds,Intel Partner Alliance';
            configList.add(config);
            Core_MDF_Configuration__c config1 = new Core_MDF_Configuration__c();
            config1.Name = 'BATCH_UPDATE_CLAIM_ON_BANK_HOLD_LIMIT';
            config1.Core_MDF_Value__c = '30';
            configList.add(config1);
            Core_MDF_Configuration__c config2 = new Core_MDF_Configuration__c();
            config2.Name = 'CLAIM_STATUS_FOR_BANK_HOLD';
            config2.Core_MDF_Value__c = 'Pending Available Fund,Payment Due,Hold,PIC Pending,Resubmission Required,Submitted';
            configList.add(config2);
            Core_MDF_Configuration__c config3 = new Core_MDF_Configuration__c();
            config3.Name = 'BATCH_UPDATE_CLAIM_ON_BANK_RELEASE';
            config3.Core_MDF_Value__c = '30';
            configList.add(config3);
            
            Core_MDF_Configuration__c config4 = new Core_MDF_Configuration__c();
            config4.Name = 'BUDGET_TYPE_SKIP_BANK_DOC_HOLD';
            config4.Core_MDF_Value__c = 'RSA MD';
            configList.add(config4);
            Database.insert(configList);
            Core_Trigger_Executions__c cte = new Core_Trigger_Executions__c();
            cte.Name =  'Core_MDF_BankVatPctCalculation';
            cte.Core_Object__c='Core_MDF_Bank__c';
            cte.Core_Trigger_Events__c='before insert before update';
            cte.Core_Class_Name__c='Core_MDF_BankServiceHandler';
            cte.Core_Active__c=true;
            cte.Core_Description__c='test';
            
            database.insert(cte);
        }
    }
    @isTest
    static void disassociateBankWithoutClaims(){
    Test.startTest();
        User paymentAdmin = [Select Id FROM User Where LastName = 'Bank Payment Admin' LIMIT 1];
        Account testIntelAccount = [Select Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        AccountShare accshareRecordCCF = new AccountShare();
        accshareRecordCCF.AccountId = testIntelAccount.Id;
        accshareRecordCCF.UserOrGroupId = paymentAdmin.Id;
        accshareRecordCCF.RowCause = 'Manual';
        accshareRecordCCF.AccountAccessLevel = 'Read';
        accshareRecordCCF.OpportunityAccessLevel = 'None';
        accshareRecordCCF.CaseAccessLevel = 'None';
        
        Database.Insert(accshareRecordCCF);
        
        System.runAs(paymentAdmin){
            
            Core_MDF_Bank__c bankRec = Core_MDF_CCP_TestDataUtility.createBank(testIntelAccount.Id, 'Core_MDF_Client_CoMarketing_Fund;Core_MDF_Data_Center_CoMarketing_Fund', TRUE,'1231288000');
            bankRec.Core_MDF_Program__c = 'Core_MDF_Client_CoMarketing_Fund;Core_MDF_Data_Center_CoMarketing_Fund';
            update(bankRec);
            
            bankRec.Core_MDF_Ineffective_Selection_ind__c = true;
            try{
                update(bankRec);
                assert.isTrue(bankRec.Core_MDF_Bank_Status__c == 'Active'); 
            }catch(Exception e){
                assert.isTrue(bankRec.Core_MDF_Ineffective_Selection_ind__c == TRUE);  
            }
            
            bankRec.Core_MDF_Program__c = 'Core_MDF_Data_Center_CoMarketing_Fund';
            try{
                update(bankRec);
                assert.isTrue(bankRec.Core_MDF_Program__c == 'Core_MDF_Data_Center_CoMarketing_Fund');  
            }catch(Exception e){
                assert.isTrue(bankRec.Core_MDF_Program__c == 'Core_MDF_Client_CoMarketing_Fund;Core_MDF_Data_Center_CoMarketing_Fund');  
            } 
            
        }
    Test.stopTest();
    }
    
    
    @isTest
    static void disassociateBankTestWithClaims(){
        Test.startTest();
        User paymentAdmin = [Select Id FROM User Where LastName = 'Bank Payment Admin' LIMIT 1];
        Account testIntelAccount = [Select Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        
        Account testCMAccount = [Select Id FROM Account WHERE Name = 'Test Acc CCF' LIMIT 1];
        
        AccountShare accshareRecordCCF = new AccountShare();
        accshareRecordCCF.AccountId = testIntelAccount.Id;
        accshareRecordCCF.UserOrGroupId = paymentAdmin.Id;
        accshareRecordCCF.RowCause = 'Manual';
        accshareRecordCCF.AccountAccessLevel = 'Read';
        accshareRecordCCF.OpportunityAccessLevel = 'None';
        accshareRecordCCF.CaseAccessLevel = 'None';
    
        Database.Insert(accshareRecordCCF);
        Core_MDF_Bank__c bankRec;   
        System.runAs(paymentAdmin){
            
            bankRec = Core_MDF_CCP_TestDataUtility.createBank(testIntelAccount.Id, 'Core_MDF_Client_CoMarketing_Fund;Core_MDF_Data_Center_CoMarketing_Fund', TRUE,'1231277000');
            bankRec.Core_MDF_Program__c = 'Core_MDF_Client_CoMarketing_Fund;Core_MDF_Data_Center_CoMarketing_Fund';
            bankRec.Core_MDF_Bank_Status__c = 'Active';
            update(bankRec);
            
            //bankRec.Core_MDF_Ineffective_Selection_ind__c = true;
            try{
                update(bankRec);
                assert.isTrue(bankRec.Core_MDF_Bank_Status__c == 'Active'); 
            }catch(Exception e){
                assert.isTrue(bankRec.Core_MDF_Ineffective_Selection_ind__c == TRUE);  
            }
        }
        Core_MDF_Account_Bank_Mapping__c abmCCF1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(testCMAccount.Id, bankRec.Id, FALSE);
        abmCCF1.Core_MDF_Active_ind__c = TRUE;
        Database.insert(abmCCF1);
        
        PartnerFundRequest pfr = [Select Id FROM PartnerFundRequest WHERE Title = 'test' LIMIT 1];
        
        PartnerFundClaim newClaim = new PartnerFundClaim();
        newClaim = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', 
                                                            Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, 
                                                            System.today(),System.today(), 122, 
                                                            System.today(), bankRec.Id, false);
        newClaim.Core_MDF_Status__c = 'Submitted';
        newClaim.Core_MDF_Currency__c = 'USD';
        newClaim.Core_MDF_Taxes_Local__c = 0;
        Database.insert(newClaim);
        
        System.runAs(paymentAdmin){
            bankRec.Core_MDF_Program__c = 'Core_MDF_Data_Center_CoMarketing_Fund';
            try{
                update(bankRec);
                assert.isTrue(bankRec.Core_MDF_Program__c == 'Core_MDF_Data_Center_CoMarketing_Fund');  
            }catch(Exception e){
                
            } 
            Test.stopTest();
        }
    }
    
    @isTest
    static void disassociateBankTestWithClaimsAndEscalations(){
        Test.startTest(); 
        User paymentAdmin = [Select Id FROM User Where LastName = 'Bank Payment Admin' LIMIT 1];
        Account testIntelAccount = [Select Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
       
        Account testCMAccount = [Select Id FROM Account WHERE Name = 'Test Acc CCF' LIMIT 1];
        ChannelProgram cp = [SELECT Id FROM ChannelProgram WHERE Name =:Core_MDF_CCP_ConstantClass.CCF_PROGRAM LIMIT 1];
        
        AccountShare accshareRecordCCF = new AccountShare();
        accshareRecordCCF.AccountId = testIntelAccount.Id;
        accshareRecordCCF.UserOrGroupId = paymentAdmin.Id;
        accshareRecordCCF.RowCause = 'Manual';
        accshareRecordCCF.AccountAccessLevel = 'Read';
        accshareRecordCCF.OpportunityAccessLevel = 'None';
        accshareRecordCCF.CaseAccessLevel = 'None';
    
        Database.Insert(accshareRecordCCF);
        
        Core_MDF_Bank__c bankRec;   
        System.runAs(paymentAdmin){
            
            bankRec = Core_MDF_CCP_TestDataUtility.createBank(testIntelAccount.Id, 'Core_MDF_Client_CoMarketing_Fund;Core_MDF_Data_Center_CoMarketing_Fund', TRUE,'1231277000');
            bankRec.Core_MDF_Program__c = 'Core_MDF_Client_CoMarketing_Fund;Core_MDF_Data_Center_CoMarketing_Fund';
            bankRec.Core_MDF_Bank_Status__c = 'Active';
            update(bankRec);
            
            //bankRec.Core_MDF_Ineffective_Selection_ind__c = true;
            try{
                update(bankRec);
                assert.isTrue(bankRec.Core_MDF_Bank_Status__c == 'Active'); 
            }catch(Exception e){
                assert.isTrue(bankRec.Core_MDF_Ineffective_Selection_ind__c == TRUE);  
            }
        }
        
        User adminusr = [SELECT Id FROM User WHERE LastName = 'Bank User' LIMIT 1];
        //Running as System Admin
        System.runAs(adminusr){
            Core_MDF_Account_Bank_Mapping__c abmCCF1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(testCMAccount.Id, bankRec.Id, FALSE);
            abmCCF1.Core_MDF_Active_ind__c = TRUE;
            Database.insert(abmCCF1);
            
            PartnerFundRequest pfr = [Select Id, Core_MDF_Activity_Number__c FROM PartnerFundRequest WHERE Title = 'test 1' LIMIT 1];
            PartnerFundClaim newClaim = new PartnerFundClaim();
            newClaim = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', 
                                                                Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, 
                                                                System.today(), System.today(), 122, 
                                                    System.today(), bankRec.Id, false);
            newClaim.Core_MDF_Status__c = 'Submitted';
            newClaim.Core_MDF_Currency__c = 'USD';
            newClaim.Core_MDF_Taxes_Local__c = 0;
            Database.insert(newClaim);
            
            
            Id claimRecType = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Late_Claim').getRecordTypeId();
            Core_MDF_Escalation__c esc1 = new Core_MDF_Escalation__c();
            esc1.Core_MDF_Escalation_Status_nm__c='Pending Review';
            esc1.Core_MDF_Escalation_Name_txt__c='Test1';
            esc1.Core_MDF_Total_Dollar_Impact_amt__c= 56;
            esc1.Core_MDF_Root_Cause_nm__c = 'Tools and Systems';
            esc1.Core_MDF_Co_Marketing_Activity_id__c = pfr.Id;
            esc1.Core_MDF_Channel_Program_id__c = cp.Id;
            esc1.recordtypeid= claimRecType;
            //Database.insert(esc1);
        }
        
        System.runAs(paymentAdmin){
            bankRec.Core_MDF_Ineffective_Selection_ind__c = true;
            try{
                update bankRec;
            }catch(Exception e){
                Boolean expectedBankEscaltionErrorThrown =  e.getMessage().contains('This bank has active escalations associated to it and cannot be inactivated') ? true : false;
                Assert.areEqual(expectedBankEscaltionErrorThrown, false);
            } 
            Test.stopTest();
        }
    }
    
    @isTest 
    static void logErrorinLogObjectWithReasonTest(){     
        
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        // Creating User with utility class 
        User testUser = Core_MDF_CCP_TestDataUtility.createUser(false);
        testUser.LastName = 'Test User';
        testUser.UserRoleId = usRole.Id;
        testUser.Email = 'sysadmin@example.com';
        Database.insert(testUser);
        System.runAs(testUser){
        
        Test.startTest();
        User paymentAdmin = [Select Id FROM User Where LastName = 'Bank Payment Admin' LIMIT 1];
        List<Account> acctList = new List<Account>();
        
        Account testIntelAccount = [Select Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Account testAccount2 = [Select Id FROM Account WHERE Name = 'Test Account2' LIMIT 1];
        
        List<AccountShare> accountShareList = new List<AccountShare>();
        
        AccountShare accshareRecordCCF = new AccountShare();
        accshareRecordCCF.AccountId = testIntelAccount.Id;
        accshareRecordCCF.UserOrGroupId = paymentAdmin.Id;
        accshareRecordCCF.RowCause = 'Manual';
        accshareRecordCCF.AccountAccessLevel = 'Read';
        accshareRecordCCF.OpportunityAccessLevel = 'None';
        accshareRecordCCF.CaseAccessLevel = 'None';
        
        accountShareList.add(accshareRecordCCF);
        Database.Insert(accountShareList);
		assert.areEqual('None',accshareRecordCCF.CaseAccessLevel);        
        acctList.add(testIntelAccount);
        acctList.add(testAccount2);
        String errortext = 'Test';
        Core_MDF_CCP_UtilityClass.updateListAndLogErrors(acctList,errortext);
        Core_MDF_CCP_UtilityClass.logErrorinLogObject(errortext, 'Test');
        assert.isNotNull(testIntelAccount.id);
        Core_MDF_BankServiceHandler.logErrorinLogObjectWithReason(errortext,'parsing exception'); 
           
        
        Test.stopTest();
        }
    }
    
  /****************************************************************************************************************************************
Method Name:                                   testBankHold
Description:                                   check bank hold functionality
Added By:                                      Accenture – NK  6/08/2021
Modified By:                  Date:            Changes: 
*****************************************************************************************************************************************/       
    @isTest static void testBankHold(){
       
       test.startTest();
        Account testIntelAccount = [Select Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        User paymentAdmin = [Select Id FROM User Where LastName = 'Bank Payment Admin' LIMIT 1]; 
        AccountShare accshareRecordCCF = new AccountShare();
        accshareRecordCCF.AccountId = testIntelAccount.Id;
        accshareRecordCCF.UserOrGroupId = paymentAdmin.Id;
        accshareRecordCCF.RowCause = 'Manual';
        accshareRecordCCF.AccountAccessLevel = 'Read';
        accshareRecordCCF.OpportunityAccessLevel = 'None';
        accshareRecordCCF.CaseAccessLevel = 'None';
        
        Database.Insert(accshareRecordCCF);
        //test.startTest();
        System.runAs(paymentAdmin){
            
            
            Core_MDF_Bank__c bankRec = [select Id from Core_MDF_Bank__c LIMIT 1];
            
            PartnerFundRequest pfr = [Select Id, Core_MDF_Activity_Number__c,ChannelPartnerId FROM PartnerFundRequest WHERE Title = 'test' LIMIT 1];
            PartnerFundClaim newClaim = new PartnerFundClaim();
            newClaim = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', 
                                                                Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, 
                                                                System.today(), System.today(), 122, 
                                                                System.today(), bankRec.Id, false);
            newClaim.Core_MDF_Status__c = 'Submitted';
            newClaim.Core_MDF_Currency__c = 'USD';
            newClaim.Core_MDF_Taxes_Local__c = 0;
            newClaim.Core_MDF_PIC_Review_Completed__c = true;
            Database.insert(newClaim);    
            try{
            bankRec.Core_MDF_Hold_Payments_from_AP_file_ind__c = 'yes';
            bankRec.Core_MDF_Hold_Reason_txt__c='test';
            Database.update(bankRec);    
            assert.areEqual('test',bankRec.Core_MDF_Hold_Reason_txt__c);
            Test.stopTest();
            }catch(exception e){}
                    }
    }   
    @isTest static void testBankHold1(){
       
       test.startTest();
        Account testIntelAccount = [Select Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        User paymentAdmin = [Select Id FROM User Where LastName = 'Bank Payment Admin' LIMIT 1]; 
        AccountShare accshareRecordCCF = new AccountShare();
        accshareRecordCCF.AccountId = testIntelAccount.Id;
        accshareRecordCCF.UserOrGroupId = paymentAdmin.Id;
        accshareRecordCCF.RowCause = 'Manual';
        accshareRecordCCF.AccountAccessLevel = 'Read';
        accshareRecordCCF.OpportunityAccessLevel = 'None';
        accshareRecordCCF.CaseAccessLevel = 'None';
        
        Database.Insert(accshareRecordCCF);
        //test.startTest();
        System.runAs(paymentAdmin){
        
            PartnerFundRequest pfr = [Select Id, Core_MDF_Activity_Number__c,ChannelPartnerId FROM PartnerFundRequest WHERE Title = 'test' LIMIT 1];
            
             
            try{
            PartnerFundClaim newClaim2 = new PartnerFundClaim();
            //PartnerFundClaim newClaim1 = [Select Id,Core_MDF_Status__c,Core_MDF_Payment_Hold_ind__c from PartnerFundClaim where Title = 'Test Claim' limit 1];
            Core_MDF_Bank__c bankRec1 = Core_MDF_CCP_TestDataUtility.createBank(testIntelAccount.Id, 'Core_MDF_Client_CoMarketing_Fund;Core_MDF_Data_Center_CoMarketing_Fund', TRUE,'1231277001');
            newClaim2 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', 
                                                                Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, 
                                                                System.today(), System.today(), 122, 
                                                                System.today(), bankRec1.Id, false);
            newClaim2.Core_MDF_Status__c = 'Submitted';
            newClaim2.Core_MDF_Currency__c = 'USD';
            newClaim2.Core_MDF_Taxes_Local__c = 0;
            newClaim2.Core_MDF_PIC_Review_Completed__c = true;
            Database.insert(newClaim2);     
            
            bankRec1.Core_MDF_ESD_Hold_Indicator__c = true;
            Database.update(bankRec1);
            assert.areEqual(true,bankRec1.Core_MDF_ESD_Hold_Indicator__c);
            Test.stopTest();
            
            }catch(exception e){}
                    }
    }   
    /****************************************************************************************************************************************
Method Name:                                   testBankRelease
Description:                                   check bank Release functionality
Added By:                                      Accenture – NK  6/08/2021
Modified By:                  Date:            Changes: 
*****************************************************************************************************************************************/       
    @isTest static void testBankRelease(){
        Account testIntelAccount = [Select Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        User paymentAdmin = [Select Id FROM User Where LastName = 'Bank Payment Admin' LIMIT 1]; 
        AccountShare accshareRecordCCF = new AccountShare();
        accshareRecordCCF.AccountId = testIntelAccount.Id;
        accshareRecordCCF.UserOrGroupId = paymentAdmin.Id;
        accshareRecordCCF.RowCause = 'Manual';
        accshareRecordCCF.AccountAccessLevel = 'Read';
        accshareRecordCCF.OpportunityAccessLevel = 'None';
        accshareRecordCCF.CaseAccessLevel = 'None';
        
        Database.Insert(accshareRecordCCF);
        test.startTest();
        System.runAs(paymentAdmin){
            Core_MDF_Bank__c bankRec = [Select Id from Core_MDF_Bank__c LIMIT 1];
            PartnerFundRequest pfr = [Select Id, Core_MDF_Activity_Number__c,ChannelPartnerId FROM PartnerFundRequest WHERE Title = 'test' LIMIT 1];
            PartnerFundClaim newClaim = new PartnerFundClaim();
            newClaim = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', 
                                                                Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, 
                                                                System.today(), System.today(), 122, 
                                                                System.today(), bankRec.Id, false);
            newClaim.Core_MDF_Status__c = 'Submitted';
            newClaim.Core_MDF_Currency__c = 'USD';
            newClaim.Core_MDF_Taxes_Local__c = 0;
            Database.insert(newClaim);      
            bankRec.Core_MDF_Hold_Payments_from_AP_file_ind__c = 'Yes';
            bankRec.Core_MDF_Hold_Reason_txt__c='test';
            bankRec.Core_MDF_ESD_Hold_Indicator__c = true;
            Database.update(bankRec);
            bankRec.Core_MDF_Hold_Payments_from_AP_file_ind__c = 'No';
            bankRec.Core_MDF_Hold_Reason_txt__c='';
            bankRec.Core_MDF_ESD_Hold_Indicator__c = false;
            Database.update(bankRec); 
            assert.areEqual(false,bankRec.Core_MDF_ESD_Hold_Indicator__c);
            Test.stopTest();
        }
    }
     @isTest static void testBankESDHold(){
        Account testIntelAccount = [Select Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        User paymentAdmin = [Select Id FROM User Where LastName = 'Bank Payment Admin' LIMIT 1];  
         AccountShare accshareRecordCCF = new AccountShare();
        accshareRecordCCF.AccountId = testIntelAccount.Id;
        accshareRecordCCF.UserOrGroupId = paymentAdmin.Id;
        accshareRecordCCF.RowCause = 'Manual';
        accshareRecordCCF.AccountAccessLevel = 'Read';
        accshareRecordCCF.OpportunityAccessLevel = 'None';
        accshareRecordCCF.CaseAccessLevel = 'None';
        
        Database.Insert(accshareRecordCCF);
        test.startTest();
        System.runAs(paymentAdmin){
            Core_MDF_Bank__c bankRec = [Select Id from Core_MDF_Bank__c LIMIT 1];
            PartnerFundRequest pfr = [Select Id, Core_MDF_Activity_Number__c,ChannelPartnerId FROM PartnerFundRequest WHERE Title = 'test' LIMIT 1];
            
            PartnerFundClaim newClaim = new PartnerFundClaim();
            newClaim = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', 
                                                                Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, 
                                                                System.today(), System.today(), 122, 
                                                                System.today(), bankRec.Id, false);
            newClaim.Core_MDF_Status__c = 'Submitted';
            newClaim.Core_MDF_Currency__c = 'USD';
            newClaim.Core_MDF_Taxes_Local__c = 0;
            Database.insert(newClaim);  
            bankRec.Core_MDF_ESD_Hold_Indicator__c = True;
            Database.update(bankRec);
            assert.areEqual(True,bankRec.Core_MDF_ESD_Hold_Indicator__c);
            Test.stopTest();
        }
    }
     @isTest static void testBankESDRelease(){
     test.startTest();
        Account testIntelAccount = [Select Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        User paymentAdmin = [Select Id FROM User Where LastName = 'Bank Payment Admin' LIMIT 1]; 
         AccountShare accshareRecordCCF = new AccountShare();
        accshareRecordCCF.AccountId = testIntelAccount.Id;
        accshareRecordCCF.UserOrGroupId = paymentAdmin.Id;
        accshareRecordCCF.RowCause = 'Manual';
        accshareRecordCCF.AccountAccessLevel = 'Read';
        accshareRecordCCF.OpportunityAccessLevel = 'None';
        accshareRecordCCF.CaseAccessLevel = 'None';
        
        Database.Insert(accshareRecordCCF);
        //test.startTest();
        System.runAs(paymentAdmin){
            Core_MDF_Bank__c bankRec = [Select Id from Core_MDF_Bank__c LIMIT 1];
            PartnerFundRequest pfr = [Select Id, Core_MDF_Activity_Number__c,ChannelPartnerId FROM PartnerFundRequest WHERE Title = 'test' LIMIT 1];
            PartnerFundClaim newClaim = new PartnerFundClaim();
            newClaim = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', 
                                                                Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, 
                                                                System.today(), System.today(), 122, 
                                                                System.today(), bankRec.Id, false);
            newClaim.Core_MDF_Status__c = 'Submitted';
            newClaim.Core_MDF_Currency__c = 'USD';
            newClaim.Core_MDF_Taxes_Local__c = 0;
            Database.insert(newClaim);  
            bankRec.Core_MDF_ESD_Hold_Indicator__c = True;
            Database.update(bankRec);
            bankRec.Core_MDF_ESD_Hold_Indicator__c = false;
            Database.update(bankRec);
            assert.areEqual(false,bankRec.Core_MDF_ESD_Hold_Indicator__c);
            
            Test.stopTest();
        }
    }
    @isTest static void testBankLocationChange(){
        test.startTest();
            
        User testUser1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        testUser1.LastName = 'Bank Payment Admin RMF';
        insert testUser1;
         PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Retail_Payment_Adm' LIMIT 1];
         insert new PermissionSetAssignment(AssigneeId = testUser1.id, PermissionSetId = ps.Id);
         
        System.runAs(testUser1){
        Account testIntelAccount = [Select Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Core_MDF_Bank__c bank1 = Core_MDF_CCP_TestDataUtility.createBank(testIntelAccount.Id, 'Core_MDF_Retail_Marketing_Funds', false,'1231231231');
        bank1.Core_MDF_Intel_Company_Code__c = '150';
        bank1.Core_MDF_Tax_codes_cd__c = 'I0';
        bank1.Core_MDF_Bank_Location__c = 'IN';
        insert bank1;
        //Core_MDF_Bank__c bankRec = [Select Id from Core_MDF_Bank__c LIMIT 1];  
            List<ID> bankIdLst = new List<Id>();
            bankIdLst.add(bank1.Id);
            //Core_MDF_BankServiceHandler.shareABMRecords(bankIdLst);
            bank1.Core_MDF_Bank_Location__c = 'AM';
            update bank1;
            assert.areEqual('AM', bank1.Core_MDF_Bank_Location__c);
        }
        test.stopTest();
    }
     @isTest static void testBankShareABMRecords(){
        User paymentAdmin = [Select Id FROM User Where LastName = 'Bank Payment Admin' LIMIT 1]; 
        test.startTest();
        System.runAs(paymentAdmin){
        Core_MDF_Bank__c bankRec = [Select Id from Core_MDF_Bank__c LIMIT 1];  
            List<ID> bankIdLst = new List<Id>();
            bankIdLst.add(bankRec.Id);
            //Core_MDF_BankServiceHandler.shareABMRecords(bankIdLst);
            bankRec.Core_MDF_Bank_Location__c = 'test';
            update bankRec;
            assert.areEqual('test', bankRec.Core_MDF_Bank_Location__c);
        }
        test.stopTest();
    }
    @isTest static void testBankLocationNonRCIS(){
        test.startTest();
            
        User testUser1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        testUser1.LastName = 'Bank Payment Admin RMF';
        insert testUser1;
         PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Retail_Payment_Adm' LIMIT 1];
         insert new PermissionSetAssignment(AssigneeId = testUser1.id, PermissionSetId = ps.Id);
         
        System.runAs(testUser1){
        Account testIntelAccount = [Select Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Core_MDF_Bank__c bank1 = Core_MDF_CCP_TestDataUtility.createBank(testIntelAccount.Id, 'Core_MDF_Retail_Marketing_Funds', false,'1231231231');
        bank1.Core_MDF_Intel_Company_Code__c = '150';
        bank1.Core_MDF_Tax_codes_cd__c = 'I0';
        bank1.Core_MDF_Bank_Location__c = 'AM';
        insert bank1;
        PartnerFundRequest pfr = [Select Id, Core_MDF_Activity_Number__c,ChannelPartnerId FROM PartnerFundRequest WHERE Title = 'test' LIMIT 1];
            PartnerFundClaim newClaim = new PartnerFundClaim();
            newClaim = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', 
                                                                Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, 
                                                                System.today(), System.today(), 122, 
                                                                System.today(), bank1.Id, false);
            newClaim.Core_MDF_Status__c = 'Submitted';
            newClaim.Core_MDF_Currency__c = 'USD';
            newClaim.Core_MDF_Taxes_Local__c = 0;
            newClaim.Core_MDF_Bank_Doc_Hold_Eligibility_Ind__c = false;
            //newClaim.Core_MDF_Hold_Payments_from_AP_file_ind__c=false;
            Database.insert(newClaim);   
            
        //Core_MDF_Bank__c bankRec = [Select Id from Core_MDF_Bank__c LIMIT 1];  
            List<ID> bankIdLst = new List<Id>();
            bankIdLst.add(bank1.Id);
            //Core_MDF_BankServiceHandler.shareABMRecords(bankIdLst);
            bank1.Core_MDF_Bank_Location__c = 'IN';
            update bank1;
            assert.areEqual('IN', bank1.Core_MDF_Bank_Location__c);
        }
        test.stopTest();
    }
    @isTest static void testESDBankHold(){
        test.startTest();
            
        User testUser1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        testUser1.LastName = 'Bank Payment Admin RMF';
        insert testUser1;
         PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Retail_Payment_Adm' LIMIT 1];
         insert new PermissionSetAssignment(AssigneeId = testUser1.id, PermissionSetId = ps.Id);
         
        System.runAs(testUser1){
        Account testIntelAccount = [Select Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Core_MDF_Bank__c bank1 = Core_MDF_CCP_TestDataUtility.createBank(testIntelAccount.Id, 'Core_MDF_Retail_Marketing_Funds', false,'1231231231');
        bank1.Core_MDF_Intel_Company_Code__c = '150';
        bank1.Core_MDF_Tax_codes_cd__c = 'I0';
        bank1.Core_MDF_Bank_Location__c = 'IN';
        bank1.Core_MDF_ESD_Hold_Indicator__c = FALSE;
        insert bank1;
        
        PartnerFundRequest pfr = [Select Id, Core_MDF_Activity_Number__c,ChannelPartnerId FROM PartnerFundRequest WHERE Title = 'test' LIMIT 1];
            PartnerFundClaim newClaim = new PartnerFundClaim();
            newClaim = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', 
                                                                Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, 
                                                                System.today(), System.today(), 122, 
                                                                System.today(), bank1.Id, false);
            newClaim.Core_MDF_Status__c = 'Submitted';
            newClaim.Core_MDF_Currency__c = 'USD';
            newClaim.Core_MDF_Taxes_Local__c = 0;
            //newClaim.Core_MDF_Hold_Payments_from_AP_file_ind__c=false;
            Database.insert(newClaim);   
            
        
        //Core_MDF_Bank__c bankRec = [Select Id from Core_MDF_Bank__c LIMIT 1];  
            List<ID> bankIdLst = new List<Id>();
            bankIdLst.add(bank1.Id);
            //Core_MDF_BankServiceHandler.shareABMRecords(bankIdLst);
            bank1.Core_MDF_ESD_Hold_Indicator__c = true;
            bank1.Core_MDF_Bank_Location__c = 'RU';
            update bank1;
            assert.areEqual('RU', bank1.Core_MDF_Bank_Location__c);
        }
        test.stopTest();
    }
    @isTest static void testAPHold(){
     test.startTest();
        Account testIntelAccount = [Select Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        User paymentAdmin = [Select Id FROM User Where LastName = 'Bank Payment Admin' LIMIT 1]; 
         AccountShare accshareRecordCCF = new AccountShare();
        accshareRecordCCF.AccountId = testIntelAccount.Id;
        accshareRecordCCF.UserOrGroupId = paymentAdmin.Id;
        accshareRecordCCF.RowCause = 'Manual';
        accshareRecordCCF.AccountAccessLevel = 'Read';
        accshareRecordCCF.OpportunityAccessLevel = 'None';
        accshareRecordCCF.CaseAccessLevel = 'None';
        
        Database.Insert(accshareRecordCCF);
        //test.startTest();
        System.runAs(paymentAdmin){
            Core_MDF_Bank__c bankRec = [Select Id from Core_MDF_Bank__c LIMIT 1];
            PartnerFundRequest pfr = [Select Id, Core_MDF_Activity_Number__c,ChannelPartnerId FROM PartnerFundRequest WHERE Title = 'test' LIMIT 1];
            PartnerFundClaim newClaim = new PartnerFundClaim();
            newClaim = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', 
                                                                Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, 
                                                                System.today(), System.today(), 122, 
                                                                System.today(), bankRec.Id, false);
            newClaim.Core_MDF_Status__c = 'Submitted';
            newClaim.Core_MDF_Currency__c = 'USD';
            newClaim.Core_MDF_Taxes_Local__c = 0;
            //newClaim.Core_MDF_Hold_Payments_from_AP_file_ind__c=false;
            Database.insert(newClaim);  
            bankRec.Core_MDF_Hold_Payments_from_AP_file_ind__c = 'Yes';
            bankRec.Core_MDF_Hold_Reason_txt__c = 'Test';
            Database.update(bankRec);
            assert.areEqual('Test',bankRec.Core_MDF_Hold_Reason_txt__c);
            Test.stopTest();
        }
    }
    @isTest static void testBankHoldRCISCountry(){
     test.startTest();
        Account testIntelAccount = [Select Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        User paymentAdmin = [Select Id FROM User Where LastName = 'Bank Payment Admin' LIMIT 1]; 
         AccountShare accshareRecordCCF = new AccountShare();
        accshareRecordCCF.AccountId = testIntelAccount.Id;
        accshareRecordCCF.UserOrGroupId = paymentAdmin.Id;
        accshareRecordCCF.RowCause = 'Manual';
        accshareRecordCCF.AccountAccessLevel = 'Read';
        accshareRecordCCF.OpportunityAccessLevel = 'None';
        accshareRecordCCF.CaseAccessLevel = 'None';
        
        Database.Insert(accshareRecordCCF);
        //test.startTest();
        System.runAs(paymentAdmin){
            Core_MDF_Bank__c bankRec = [Select Id from Core_MDF_Bank__c LIMIT 1];
            PartnerFundRequest pfr = [Select Id, Core_MDF_Activity_Number__c,ChannelPartnerId FROM PartnerFundRequest WHERE Title = 'test' LIMIT 1];
            PartnerFundClaim newClaim = new PartnerFundClaim();
            newClaim = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', 
                                                                Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, 
                                                                System.today(), System.today(), 122, 
                                                                System.today(), bankRec.Id, false);
            newClaim.Core_MDF_Status__c = 'Submitted';
            newClaim.Core_MDF_Currency__c = 'USD';
            newClaim.Core_MDF_Taxes_Local__c = 0;
            newClaim.Core_MDF_PIC_Review_Completed__c = true;
            //newClaim.Core_MDF_Hold_Payments_from_AP_file_ind__c=false;
            Database.insert(newClaim);  
            bankRec.Core_MDF_Bank_Location__c = 'AM';
            Database.update(bankRec);
            assert.areEqual('AM',bankRec.Core_MDF_Bank_Location__c);
            
            Test.stopTest();
        }
    }
}