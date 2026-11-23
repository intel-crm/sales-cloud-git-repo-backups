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
        
        System.runAs(userList[0]){
            
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
            ChannelProgram ccfCp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', false);
            cpList.add(ccfCp);
            ChannelProgram dcfCp = Core_MDF_CCP_TestDataUtility.createProgram ('Data Center Co-Marketing Fund','Data Center CoMarketing Fund', false);
            cpList.add(dcfCp);
            
            insert cpList;
            
            Account coMarketingAccCCF = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Acc CCF', cpList[0].Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, accntList[0].Id, FALSE);
            Account coMarketingAccDCF = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Acc DCF', cpList[1].Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, accntList[0].Id, FALSE);
            Account coMarketingAccCCF2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Acc CCF 2', cpList[0].Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, accntList[0].Id, FALSE);
            accntList = new List<Account>();
            accntList.add(coMarketingAccCCF);
            accntList.add(coMarketingAccDCF);
            accntList.add(coMarketingAccCCF2);
            
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
            Core_Entitlement__c entitlementCCF = Core_MDF_CCP_TestDataUtility.createEntitlement('CCF Account Budget Administrator', agsRoleList[0].Id,'Consolidated Co-marketing Platform','CCF Account Budget Administrator', erpmEngagementList[0].Id, true,'Client Co-Marketing Fund (CCF)',false);
            Core_Entitlement__c entitlementDCF = Core_MDF_CCP_TestDataUtility.createEntitlement('DCF Account Budget Administrator', agsRoleList[1].Id,'Consolidated Co-marketing Platform','DCF Account Budget Administrator', erpmEngagementList[1].Id, true,'Data Center Co-Marketing Fund (DCF)',false);
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
            
            
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 13','Gaming','Intel® Core™ i7 Processor', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today()-10, System.today().addDays(30), 10000, 'Always Connected PC', coMarketingAccCCF.Id,'Desktop', true); 
            
            PartnerMarketingBudget budget = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget New',Core_MDF_CCP_TestDataUtility.budget_Record_Type,coMarketingAccCCF.Id,cpList[0].Id,10000,System.today() -20,System.today().addDays(40), true);
            
            
            Test.stopTest();
            Core_MDF_Bank__c bank1 = Core_MDF_CCP_TestDataUtility.createBank(acc.Id, 'Core_MDF_Client_CoMarketing_Fund;Core_MDF_Data_Center_CoMarketing_Fund', TRUE,'1231231230');
            /*bank1.Core_MDF_Program__c = 'Core_MDF_Client_CoMarketing_Fund;Core_MDF_Data_Center_CoMarketing_Fund';
            update(bank1);
            
            bank1.OwnerId = paymentAdminUserRecord.Id;
            update bank1;
            
            bank1.Core_MDF_Bank_Location__c = 'IN';
            update bank1;*/
            
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
            pfr.Core_MDF_Start_Date__c = system.today()-10;
            pfr.Core_MDF_End_Date__c  = system.today()+10;
            pfr.Amount = 0;
            insert pfr;
            
            List<Core_MDF_Account_Bank_Mapping__c> abmList = new List<Core_MDF_Account_Bank_Mapping__c>();
            Core_MDF_Account_Bank_Mapping__c abmCCF1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(coMarketingAccCCF.Id, bank1.Id, FALSE);
            Core_MDF_Account_Bank_Mapping__c abmCCF2 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(coMarketingAccCCF2.Id, bank1.Id, FALSE);
            Core_MDF_Account_Bank_Mapping__c abmDCF  = Core_MDF_CCP_TestDataUtility.createAccountBankMap(coMarketingAccDCF.Id, bank1.Id, FALSE);
            abmList.add(abmCCF1);
            abmList.add(abmCCF2);
            abmList.add(abmDCF);
            Database.insert(abmList);
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
                System.assert(bankRec.Core_MDF_Bank_Status__c == 'Active'); 
            }catch(Exception e){
                System.assert(bankRec.Core_MDF_Ineffective_Selection_ind__c == TRUE);  
            }
            
            bankRec.Core_MDF_Program__c = 'Core_MDF_Data_Center_CoMarketing_Fund';
            try{
                update(bankRec);
                System.assert(bankRec.Core_MDF_Program__c == 'Core_MDF_Data_Center_CoMarketing_Fund');  
            }catch(Exception e){
                System.assert(bankRec.Core_MDF_Program__c == 'Core_MDF_Client_CoMarketing_Fund;Core_MDF_Data_Center_CoMarketing_Fund');  
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
                System.assert(bankRec.Core_MDF_Bank_Status__c == 'Active'); 
            }catch(Exception e){
                System.assert(bankRec.Core_MDF_Ineffective_Selection_ind__c == TRUE);  
            }
        }
        Core_MDF_Account_Bank_Mapping__c abmCCF1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(testCMAccount.Id, bankRec.Id, FALSE);
        abmCCF1.Core_MDF_Active_ind__c = TRUE;
        Database.insert(abmCCF1);
        
        PartnerFundRequest pfr = [Select Id FROM PartnerFundRequest WHERE Title = 'test' LIMIT 1];
        
        PartnerFundClaim newClaim = new PartnerFundClaim();
        newClaim = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', 
                                                            Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, 
                                                            System.today(), System.today(), 122, 
                                                            System.today(), bankRec.Id, false);
        newClaim.Core_MDF_Status__c = 'Submitted';
        newClaim.Core_MDF_Currency__c = 'USD';
        newClaim.Core_MDF_Taxes_Local__c = 0;
        Database.insert(newClaim);
        
        System.runAs(paymentAdmin){
            bankRec.Core_MDF_Program__c = 'Core_MDF_Data_Center_CoMarketing_Fund';
            try{
                update(bankRec);
                System.assert(bankRec.Core_MDF_Program__c == 'Core_MDF_Data_Center_CoMarketing_Fund');  
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
        ChannelProgram cp = [SELECT Id FROM ChannelProgram WHERE Name = 'Client Co-Marketing Fund' LIMIT 1];
        
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
                System.assert(bankRec.Core_MDF_Bank_Status__c == 'Active'); 
            }catch(Exception e){
                System.assert(bankRec.Core_MDF_Ineffective_Selection_ind__c == TRUE);  
            }
        }
        Core_MDF_Account_Bank_Mapping__c abmCCF1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(testCMAccount.Id, bankRec.Id, FALSE);
        abmCCF1.Core_MDF_Active_ind__c = TRUE;
        Database.insert(abmCCF1);
        
        PartnerFundRequest pfr = [Select Id, Core_MDF_Activity_Number__c FROM PartnerFundRequest WHERE Title = 'test' LIMIT 1];
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
        Database.insert(esc1);
        
        System.runAs(paymentAdmin){
            bankRec.Core_MDF_Ineffective_Selection_ind__c = true;
            try{
                update bankRec;
            }catch(Exception e){
                Boolean expectedBankEscaltionErrorThrown =  e.getMessage().contains('This bank has active escalations associated to it and cannot be inactivated') ? true : false;
                System.AssertEquals(expectedBankEscaltionErrorThrown, true);
            } 
            Test.stopTest();
        }
    }
    
    @isTest 
    static void logErrorinLogObjectWithReasonTest(){     
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
        
        acctList.add(testIntelAccount);
        acctList.add(testAccount2);
        String errortext = 'Test';
        Core_MDF_CCP_UtilityClass.updateListAndLogErrors(acctList,errortext);
        Core_MDF_CCP_UtilityClass.logErrorinLogObject(errortext, 'Test');
        system.assert(testIntelAccount.id!=Null);
        Core_MDF_BankServiceHandler.logErrorinLogObjectWithReason(errortext,'parsing exception'); 
        /*String s;
        try {
            s.toLowerCase();
        }
        catch(Exception e){
            String errorString = Core_MDF_CCP_UtilityClass.getErrorDetails(e);
            Core_MDF_BankServiceHandler.logErrorinLogObjectWithReason(errorString,'parsing exception');                
        }*/
        Test.stopTest();
    }
    /****************************************************************************************************************************************
    Method Name:                                   testROSharing
    Description:                                   Check the Geo based sharing for RO
    Added By:                                      Accenture – NZ  4/19/2020
    Modified By:                  Date:            Changes: 
    Accenture – NZ           NZ  4/19/2020      Created.
    *****************************************************************************************************************************************/       
    /*@isTest static void testROSharing(){
        Account testIntelAccount = [Select Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        test.startTest();
        
        Core_MDF_Bank__c bankRec = Core_MDF_CCP_TestDataUtility.createBank(testIntelAccount.Id, 'Core_MDF_Client_CoMarketing_Fund;Core_MDF_Data_Center_CoMarketing_Fund', TRUE,'1231277000');
            
        Core_MDF_ProgramGeoGroupMap__mdt metaRec = [SELECT Core_MDF_Group_Name__c, Core_MDF_Group_Name_RO__c, Core_MDF_Program__c,Core_MDF_Region__c,Core_MDF_Sub_Region__c
                                                     From Core_MDF_ProgramGeoGroupMap__mdt
                                                     WHERE Core_MDF_Region__c = : 'APJ'
                                                     AND Core_MDF_Program__c = : 'Client Co-Marketing Fund'];
                
        Boolean isAPJShared = false;*/
        
        /*for(PartnerFundRequestShare pfrShareList : [SELECT ParentId, Id, UserOrGroupId, UserOrGroup.Name, RowCause, AccessLevel
                                                    FROM PartnerFundRequestShare 
                                                    WHERE parentId = :pfr.Id]){
            System.debug('NZ-->groupRORWIdSet: '+groupRORWIdSet);
            System.debug('NZ-->pfrShareList.UserOrGroup.Name: '+pfrShareList.UserOrGroupId);
            System.debug('NZ-->pfrShareList.UserOrGroup.Name: '+pfrShareList.UserOrGroup.Name);
            String grpName = '';
            Group grp = [SELECT Id, Name, DeveloperName
                         FROM Group 
                         WHERE /*Id = :pfrShareList.UserOrGroupId Name = :'Core_MDF_Int_CCF_APJ' LIMIT 1];
            System.debug('NZ-->grp: '+grp   );
            if(groupRORWIdSet.contains(grp.Name)){
                   readOnlyShareFlag = true;                                            
            }
       }*/
        /*try{
         List<Core_MDF_Bank__Share> bankShareList = [SELECT ParentId, UserOrGroupId, UserOrGroup.Name 
                                                       FROM Core_MDF_Bank__Share 
                                                       WHERE parentId = :bankRec.Id];
        for(Core_MDF_Bank__Share shareRec : bankShareList)
        {
            System.debug('NZ-->shareRec.UserOrGroup.Name: '+shareRec.UserOrGroup.Name);
            System.debug('NZ-->metaRec.Core_MDF_Group_Name__c: '+metaRec.Core_MDF_Group_Name__c);
            if(shareRec.UserOrGroup.Name.equals(metaRec.Core_MDF_Group_Name__c)){
                isAPJShared = true;
            }
        }
        if(!isAPJShared){
            System.debug('NZ-->readOnlyShareFlag: '+isAPJShared);
            System.assert(isAPJShared);
        }
        
   
        test.stopTest();
        }catch(Exception e){
            System.debug('Error');
        }
        
    } */
    
}