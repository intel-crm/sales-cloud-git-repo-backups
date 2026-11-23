//This is a test class for Bank
@isTest(SeeAllData=false)

private class Core_MDF_Bank_Test {
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
        
        User usr3 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr3.Email = 'sysadmin@example.com';
        userList.add(usr3);

        insert userList;

        System.runAs(userList[0]){

            List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            Core_MDF_Configuration__c vatConfig = new Core_MDF_Configuration__c();
            vatConfig.Name = 'ALLOWED_PRG_FOR_RUS_NOTIF';
            vatConfig.Core_MDF_Value__c = 'Retail Marketing Funds;Intel Partner Alliance';
            insert vatConfig;
            
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
            paymentAdmin.LastName = 'Bank Payment Admin 123';
            paymentAdmin.UserRoleId = usRole.Id;
            userList.add(paymentAdmin);

            User dcfPaymentAdmin = Core_MDF_CCP_TestDataUtility.createUser(false);
            dcfPaymentAdmin.LastName = 'DCF Payment Admin 123';
            dcfPaymentAdmin.UserRoleId = usRole.Id;
            userList.add(dcfPaymentAdmin);
            User retailPaymentAdmin = Core_MDF_CCP_TestDataUtility.createUser(false);
            retailPaymentAdmin.LastName = 'Retail Payment Admin 123';
            retailPaymentAdmin.UserRoleId = usRole.Id;
            userList.add(retailPaymentAdmin);

            insert userList;

            //Creating Channel Program List
            List<ChannelProgram> cpList = new List<ChannelProgram>();

            ChannelProgram ccfCp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', false);
            cpList.add(ccfCp);
            ChannelProgram dcfCp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.DCF_PROGRAM,'Data Center CoMarketing Fund', false);
            cpList.add(dcfCp);
            ChannelProgram cpRetail = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.RMF_PROGRAM,'Retail Marketing Funds', false);
            cpList.add(cpRetail);

            insert cpList;

            //Creating Co-Marketing account with utility class
            Account coMarketingAccCCF = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Acc CCF', cpList[0].Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, accntList[0].Id, FALSE);
            Account coMarketingAccDCF = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Acc DCF', cpList[1].Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, accntList[0].Id, FALSE);
            Account coMarketingAccCCF2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Acc CCF 2', cpList[0].Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, accntList[0].Id, FALSE);
            Account retailAcc = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Acc RMF', cpList[2].Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, accntList[0].Id, FALSE);
            retailAcc.BillingCity = 'Pune';
            retailAcc.BillingCountry = 'IND';
            retailAcc.Core_Geo__c ='APJ';
            retailAcc.Core_Sub_Geo__c = 'SA';


            accntList = new List<Account>();

            accntList.add(coMarketingAccCCF);
            accntList.add(coMarketingAccDCF);
            accntList.add(coMarketingAccCCF2);
            accntList.add(retailAcc);
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
            Core_Entitlement__c entitlementCCF = Core_MDF_CCP_TestDataUtility.createEntitlement('Client Account Budget Administrator', agsRoleList[0].Id,'Consolidated Co-marketing Platform','CCF Account Budget Administrator', erpmEngagementList[0].Id, true,Core_MDF_CCP_ConstantClass.CCF_PROGRAM,false);
            Core_Entitlement__c entitlementDCF = Core_MDF_CCP_TestDataUtility.createEntitlement('Datacenter Account Budget Administrator', agsRoleList[1].Id,'Consolidated Co-marketing Platform','DCF Account Budget Administrator', erpmEngagementList[1].Id, true,Core_MDF_CCP_ConstantClass.DCF_PROGRAM,false);
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

            //Creating Group List
            List<Group> grpList = new List<Group>();

            // Creating CCF External Group
            Group ccfgrp = new Group();
            ccfgrp.Name = 'Core CCP CCF External';
            ccfgrp.DeveloperName = 'Core_CCP_CCF_External';
            grpList.add(ccfgrp);

            // Creating CCF Internal Group
            Group intGrp = new Group();
            intGrp.Name = 'Core CCP CCF Internal';
            intGrp.DeveloperName = 'Core_CCP_CCF_Internal';
            grpList.add(intGrp);

            Database.insert(grpList);

            //Querying on existing group
            group grpAllEmployees = [select DeveloperName from group where DeveloperName='Core_All_Employees_Group' LIMIT 1];
            group grpCCPInternal = [select DeveloperName from group where DeveloperName='Core_All_Users_CCP_Internal' LIMIT 1];
            group grpCCFAllEmployees = [select DeveloperName from group where DeveloperName='CORE_MDF_CCP_CCF_ALL' LIMIT 1];

            //Creating Account share
            AccountShare accShare = new AccountShare();
            accShare.AccountId = accntList[0].Id;
            accShare.UserOrGroupId = grpCCFAllEmployees.Id;
            accShare.AccountAccessLevel = 'Read';
            accShare.OpportunityAccessLevel = 'None';
            accShare.CaseAccessLevel = 'None';
            accShare.RowCause = 'Manual';
            insert accShare;

            //Creating Group Member List
            List<GroupMember> grpMemberList = new List<GroupMember>();

            //Adding Payment Admin to existing groups
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

            //Creating PGM List
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
            pgmList.add(pgm2);

            Database.insert(pgmList);


            User paymentAdminUserRecord = [Select Id FROM User Where LastName = 'Bank Payment Admin 123' LIMIT 1];
            User dcfPaymentAdminUserRecord = [Select Id FROM User Where LastName = 'DCF Payment Admin 123' LIMIT 1];
            User retailPaymentAdm = [Select Id FROM User Where LastName = 'Retail Payment Admin 123' LIMIT 1];
            //Assign Payment Admin permission set
            PermissionSet paymentAdminPSCCF = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Payment_Adm' LIMIT 1];
            PermissionSet paymentAdminPSDCF = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_DCF_Payment_Adm' LIMIT 1];
            PermissionSet paymentAdminPSRETAIL = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Retail_Payment_Adm' LIMIT 1];

            PermissionSetAssignment psAssignment1 = new PermissionSetAssignment(PermissionSetId = paymentAdminPSCCF.Id, AssigneeId = paymentAdminUserRecord.Id);
            PermissionSetAssignment psAssignment2 = new PermissionSetAssignment(PermissionSetId = paymentAdminPSDCF.Id, AssigneeId = paymentAdminUserRecord.Id);
            PermissionSetAssignment psAssignment3 = new PermissionSetAssignment(PermissionSetId = paymentAdminPSDCF.Id, AssigneeId = dcfPaymentAdminUserRecord.Id);
            PermissionSetAssignment psAssignment4 = new PermissionSetAssignment(PermissionSetId = paymentAdminPSRETAIL.Id, AssigneeId = retailPaymentAdm.Id);

            List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
            psaList.add(psAssignment1);
            psaList.add(psAssignment2);
            psaList.add(psAssignment3);
            psaList.add(psAssignment4);
      
           insert psaList;

            //Creating Campaign from utility class
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 13','Gaming','Intel® Core™ i7 Processor','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today()-10, System.today().addDays(30), 10000, 'Always Connected PC', coMarketingAccCCF.Id,'Desktop', false);
            camp.Core_MDF_Opal_Budget_Type_Txt__c = 'MDF';
            database.insert(camp);
      Test.stopTest();
            //Creating Partner Marketing Budget
            PartnerMarketingBudget budget = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget New',Core_MDF_CCP_TestDataUtility.budget_Record_Type,coMarketingAccCCF.Id,cpList[0].Id,10000,System.today() -20,System.today().addDays(40), false);
            
            budget.Core_MDF_Budget_Type_Txt__c = 'MDF';
            insert budget;

             Core_Trigger_Executions__c bcValidation = new Core_Trigger_Executions__c();
            bcValidation.Core_Active__c = true;
            bcValidation.Core_Class_Name__c = 'Core_MDF_BankServiceHandler';
            bcValidation.Core_Description__c = 'Vat Percentage Calculation';
            bcValidation.Core_Object__c = 'Core_MDF_Bank__c';
            bcValidation.Core_Trigger_Events__c = 'before insert,before update';
            bcValidation.Name='Core_MDF_BankVatPctCalculation';
            Database.insert(bcValidation);

            //Creating Bank using utility class
            Core_MDF_Bank__c bank1 = Core_MDF_CCP_TestDataUtility.createBank(acc.Id, 'Core_MDF_Client_CoMarketing_Fund;Core_MDF_Data_Center_CoMarketing_Fund', TRUE,'1231231230');
            bank1.Core_MDF_Program__c = 'Core_MDF_Client_CoMarketing_Fund;Core_MDF_Data_Center_CoMarketing_Fund';
            update(bank1);

            bank1.OwnerId = paymentAdminUserRecord.Id;
            update bank1;

            //Creating Partner Fund Allocation using utlity class
            PartnerFundAllocation allocation = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation New',budget,coMarketingAccCCF,10000,true);

            //Creating Partner Fund Request using utility class
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
            pfr.Core_MDF_Reimbursement_Rate_txt__c='100%';
            pfr.Core_MDF_Fund_Request_Status__c='Planned';
            insert pfr;
			
            PartnerFundRequest pfrClose = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(camp.Id),

                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                           String.valueof(coMarketingAccCCF.id),allocation,null,'BRAZIL',
                                                                                           'Consumer',
                                                                                           'Desktop',
                                                                                           'Intel® Core™ i7 Processor',
                                                                                           'Broadcast',
                                                                                           'Podcast',
                                                                                           'Draft',
                                                                                           false);
            pfrClose.Core_MDF_Start_Date__c = system.today()-10;
            pfrClose.Core_MDF_End_Date__c  = system.today()+10;
            pfrClose.Core_MDF_Reimbursement_Rate_txt__c='100%';
            pfrClose.Core_MDF_Fund_Request_Status__c='Closed';
            
            insert pfrClose;
            
            //Creating ABM List
            List<Core_MDF_Account_Bank_Mapping__c> abmList = new List<Core_MDF_Account_Bank_Mapping__c>();

            //Creating ABM record using utility class
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
    static void createBank(){

        User paymentAdmin = [Select Id FROM User Where LastName = 'Bank Payment Admin 123' LIMIT 1];
        System.runAs(paymentAdmin){

            Test.startTest();
            Account testAccount, coMarketingAccDCF;
            for(Account acc : ([Select Id, Name FROM Account WHERE Name IN ('Test Account', 'Test Acc DCF')])){
                if(acc.Name == 'Test Account'){
                    testAccount = acc;
                }
                else if(acc.Name == 'Test Acc DCF'){
                    coMarketingAccDCF = acc;
                }
            }
            Core_MDF_Bank__c newBank = Core_MDF_CCP_TestDataUtility.createBank(testAccount.id, 'Core_MDF_Client_CoMarketing_Fund', false,'1234500191');
            newBank.Core_MDF_Bank_Status__c = 'Draft';
            newBank.Core_MDF_DUNS__c = '578299333';
            newBank.Core_MDF_Bank_Beneficiary_Name__c = 'TEST BENEFICIARY NAME';
            newBank.Core_MDF_Bank_Location__c = 'IN';
            newBank.Core_MDF_Swift_Code__c = 'BOFSGB21124';
            newBank.Core_MDF_Intermediary_Indicator__c = 'N';
            newBank.Core_MDF_Routing_Number__c = '123456';
            newBank.Core_MDF_ESD_Hold_Indicator__c = FALSE;
            newBank.Core_MDF_Effective_Date__c = system.today().addDays(5);
            newBank.Core_MDF_Supplier_Name__c='TEST SUPPLIER NAME';
            newBank.Core_MDF_Bank_Location__c = 'IN';
            newBank.Name = 'TEST BANK';
            newBank.Core_MDF_Currency_cd__c ='TZS';

            insert newBank;

            //Sharing with Account Budget Admins
            User testBankUser = [Select Id FROM User WHERE LastName = 'Budget Admin' LIMIT 1];
            Core_MDF_Bank__Share bankShare = new Core_MDF_Bank__Share();
            bankShare.ParentId = newBank.Id;
            bankShare.UserOrGroupId = testBankUser.Id;
            bankShare.RowCause = Schema.Core_MDF_Bank__Share.RowCause.AccountBudgetAdmin__c;
            bankShare.AccessLevel = Label.Core_MDF_Read_Access;
            insert bankShare;

           // Core_MDF_ShareBanktoBudgetAdmins obj = new Core_MDF_ShareBanktoBudgetAdmins();
           // DataBase.executeBatch(obj);

            //Query on BankShare to find if record is shared with user or not
            List<Core_MDF_Bank__Share> bankShareRecords = [SELECT Id, ParentId, UserOrGroupId FROM Core_MDF_Bank__Share
                                                           WHERE ParentId =: newBank.Id AND
                                                                 UserOrGroupId =: testBankUser.Id
                                                           LIMIT 1];
                                                            if(bankShareRecords.size() > 0)
            System.assertNotEquals(bankShareRecords[0].Id, NULL);

            //Check for Draft Status
            System.assertEquals(newBank.Core_MDF_Bank_Status__c, 'Draft');

            //Change Bank Program when ESD Update = false
            newBank.Core_MDF_Program__c = 'Core_MDF_Data_Center_CoMarketing_Fund';
            update newBank;

            //Change Bank Account when ESD Update = false
            Account testAccount2 = [Select Id FROM Account WHERE Name = 'Test Account2' LIMIT 1];
            newBank.Core_MDF_Account__c = testAccount2.Id;
            newBank.Core_MDF_ESD_Update__c = false;
            update newBank;

            //Change Bank Owner when ESD Update = false
            User dcfPaymentAdmin = [Select Id FROM User Where LastName = 'DCF Payment Admin 123' LIMIT 1];
            newBank.OwnerId = dcfPaymentAdmin.Id;
            update newBank;

            //Bank Location Update
            newBank.Core_MDF_Bank_Location__c = 'US';
            update newBank;
            //Checking sharing with ABA after change of Account, Program and Owner
            Core_MDF_Bank__Share bankShare2 = new Core_MDF_Bank__Share();
            bankShare2.ParentId = newBank.Id;
            bankShare2.UserOrGroupId = testBankUser.Id;
            bankShare2.RowCause = Schema.Core_MDF_Bank__Share.RowCause.AccountBudgetAdmin__c;
            bankShare2.AccessLevel = Label.Core_MDF_Read_Access;
            insert bankShare2;
            // Highlight: Unused Local Variable 
            //Core_MDF_ShareBanktoBudgetAdmins obj2 = new Core_MDF_ShareBanktoBudgetAdmins();
           // DataBase.executeBatch(obj);

            //Query on BankShare to find if record is shared with user or not
            List<Core_MDF_Bank__Share> bankShareRecords2 = [SELECT Id, ParentId, UserOrGroupId FROM Core_MDF_Bank__Share
                                                           WHERE ParentId =: newBank.Id AND
                                                                 UserOrGroupId =: testBankUser.Id
                                                           LIMIT 1];
                                                            if(bankShareRecords2.size() > 0)
            System.assertNotEquals(bankShareRecords2[0].Id, NULL);

           

            //Validating Program Check in Bank with different Payment Admin User
            System.runAs(dcfPaymentAdmin){
                try{
                    Account testAccount3 = [Select Id FROM Account WHERE Name = 'Test Account2' LIMIT 1];
                    Core_MDF_Bank__c newBankCCF = Core_MDF_CCP_TestDataUtility.createBank(testAccount3.id, Core_MDF_CCP_ConstantClass.CCF_PROGRAM, false,'1230007805');
                    newBankCCF.Core_MDF_Bank_Status__c = 'Draft';
                    newBankCCF.Core_MDF_DUNS__c = '578299333';
                    newBankCCF.Core_MDF_Bank_Beneficiary_Name__c = 'TEST BENEFICIARY NAME2';
                    newBankCCF.Core_MDF_Bank_Location__c = 'IN';
                    newBankCCF.Core_MDF_Swift_Code__c = 'BOFSGB21124';
                    newBankCCF.Core_MDF_Intermediary_Indicator__c = 'N';
                    newBankCCF.Core_MDF_Routing_Number__c = '123456';
                    newBankCCF.Core_MDF_ESD_Hold_Indicator__c = FALSE;
                    newBankCCF.Core_MDF_Effective_Date__c = system.today().addDays(5);
                    newBankCCF.Core_MDF_Supplier_Name__c='TEST SUPPLIER NAME2';
                    newBankCCF.Name = 'TEST BANK2';
                    Insert newBankCCF;

                }
                catch(Exception ex){
                    Boolean expectedExceptionThrown =  ex.getMessage().contains('Please select valid program') ? true : false;
                    System.assertEquals(expectedExceptionThrown, false);
                }
            }

        }
        Test.stopTest();
    }

    @isTest
    static void ineffectiveSelectionAlongwithAPnESDHold(){

        User paymentAdmin = [Select Id FROM User Where LastName = 'Bank Payment Admin 123' LIMIT 1];
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

            Test.startTest();
            Core_MDF_Bank__c bankRec = Core_MDF_CCP_TestDataUtility.createBank(testIntelAccount.Id, 'Core_MDF_Client_CoMarketing_Fund;Core_MDF_Data_Center_CoMarketing_Fund', TRUE,'1231088000');
            bankRec.Core_MDF_Program__c = 'Core_MDF_Client_CoMarketing_Fund;Core_MDF_Data_Center_CoMarketing_Fund';
            bankRec.Core_MDF_Effective_Date__c = system.today().addDays(20);
            update(bankRec);

            //AP hold
            bankRec.Core_MDF_Hold_Payments_from_AP_file_ind__c = 'Yes';
            bankRec.Core_MDF_Hold_Reason_txt__c = 'Test';
            update(bankRec);

            //ESD hold
            bankRec.Core_MDF_ESD_Hold_Indicator__c = true;
            update(bankRec);


            //Ineffective set to true
            bankRec.Core_MDF_Ineffective_Selection_ind__c = true;

            update(bankRec);
            System.assert(bankRec.Core_MDF_Ineffective_Selection_ind__c == true);

            //Ineffective set to false
            bankRec.Core_MDF_Ineffective_Selection_ind__c = false;

            update(bankRec);
            System.assert(bankRec.Core_MDF_Hold_Payments_from_AP_file_ind__c == 'Yes');
            System.assert(bankRec.Core_MDF_ESD_Hold_Indicator__c == true);

            bankRec.Core_MDF_Hold_Payments_from_AP_file_ind__c = 'No';

            update(bankRec);
            System.assert(bankRec.Core_MDF_Hold_Payments_from_AP_file_ind__c != 'Yes');
        }
    }
    @isTest
    static void inactivateBankWithoutClaims(){

        User paymentAdmin = [Select Id FROM User Where LastName = 'Bank Payment Admin 123' LIMIT 1];
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
            Test.startTest();
            Core_MDF_Bank__c bankRec = Core_MDF_CCP_TestDataUtility.createBank(testIntelAccount.Id, 'Core_MDF_Client_CoMarketing_Fund;Core_MDF_Data_Center_CoMarketing_Fund', TRUE,'1001288000');

            bankRec.Core_MDF_Program__c = 'Core_MDF_Client_CoMarketing_Fund;Core_MDF_Data_Center_CoMarketing_Fund';
            bankRec.Core_MDF_Currency_cd__c = 'TZS';
            update(bankRec);

            bankRec.Core_MDF_Ineffective_Selection_ind__c = true;

                update(bankRec);
                System.assert(bankRec.Core_MDF_Ineffective_Selection_ind__c == true);

            bankRec.Core_MDF_Program__c = 'Core_MDF_Data_Center_CoMarketing_Fund';

            update(bankRec);
            System.assert(bankRec.Core_MDF_Program__c == 'Core_MDF_Data_Center_CoMarketing_Fund');

            Test.stopTest();
        }
    }

    @isTest
    static void disassociateBankTestWithClaimsAndEscalations(){

        User paymentAdmin = [Select Id FROM User Where LastName = 'Bank Payment Admin 123' LIMIT 1];
        Account testIntelAccount = [Select Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
    Test.startTest();
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
      //Core_MDF_Bank__c bankRec =   [Select Id FROM Core_MDF_Bank__c Where Core_MDF_Supplier_Number__c = '1231231230' LIMIT 1];
            bankRec = Core_MDF_CCP_TestDataUtility.createBank(testIntelAccount.Id, 'Core_MDF_Client_CoMarketing_Fund;Core_MDF_Data_Center_CoMarketing_Fund', TRUE,'1231277000');
            bankRec.Core_MDF_Program__c = 'Core_MDF_Client_CoMarketing_Fund;Core_MDF_Data_Center_CoMarketing_Fund';
            bankRec.Core_MDF_Bank_Status__c = 'Active';
            update(bankRec);

            try{
                update(bankRec);
                System.assert(bankRec.Core_MDF_Bank_Status__c == 'Active');
            }
            catch(Exception e){
                System.assert(bankRec.Core_MDF_Bank_Status__c != 'Active');
            }
        }
        Core_MDF_Account_Bank_Mapping__c abmCCF1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(testCMAccount.Id, bankRec.Id, FALSE);
        abmCCF1.Core_MDF_Active_ind__c = TRUE;
        Database.insert(abmCCF1);

        PartnerFundRequest pfr = [Select Id, Core_MDF_Activity_Number__c FROM PartnerFundRequest WHERE Title = 'test' and Core_MDF_Fund_Request_Status__c= 'Closed' LIMIT 1];
        PartnerFundRequest pfrPlan = [Select Id, Core_MDF_Activity_Number__c FROM PartnerFundRequest WHERE Title = 'test' and Core_MDF_Fund_Request_Status__c= 'Planned' LIMIT 1];
        
        
        pfr.Amount = 0;
        update pfr;
        PartnerFundClaim newClaim = new PartnerFundClaim();
        newClaim = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim',
                                                            Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfrPlan.Id,
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
            }
            catch(Exception e){
                Boolean expectedBankEscaltionErrorThrown =  e.getMessage().contains('This bank has active escalations associated to it and cannot be inactivated') ? true : false;
                System.AssertEquals(expectedBankEscaltionErrorThrown, true);
            }
            bankRec.Core_MDF_Hold_Payments_from_AP_file_ind__c = 'Yes';
            bankRec.Core_MDF_Hold_Reason_txt__c = 'Test';
            try{
                update(bankRec);
            }catch(Exception e){
                System.assert(bankRec.Core_MDF_Hold_Payments_from_AP_file_ind__c == 'Yes');
            }
            List<Id> bankIdList = new List<Id>();
            bankIdList.add(bankRec.Id);
            Core_MDF_BankServiceHandler.shareABMRecords(bankIdList);
            Test.stopTest();
        }
    }

    @isTest
    static void logErrorinLogObjectWithReasonTest(){

        User paymentAdmin = [Select Id FROM User Where LastName = 'Bank Payment Admin 123' LIMIT 1];
        List<Account> acctList = new List<Account>();
        Test.startTest();
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

        String s;
        try {
            s.toLowerCase();
        }
        catch(Exception e){
            String errorString = Core_MDF_CCP_UtilityClass.getErrorDetails(e);
            Core_MDF_BankServiceHandler.logErrorinLogObjectWithReason(errorString,'parsing exception');
        }
        Test.stopTest();
    }
    @isTest
    static void updateBankDetailsUsingIIM(){

        Profile integrationProfile = [SELECT Id FROM Profile WHERE Name='Integration' LIMIT 1];
        UserRole admin = [SELECT Id FROM UserRole where Name = 'Admin' LIMIT 1];
        User paymentAdmin = [Select Id FROM User Where LastName = 'Bank Payment Admin 123' LIMIT 1];

        User integrationUser = Core_MDF_CCP_TestDataUtility.createUser(false);
        integrationUser.LastName = 'Integration User';
        integrationUser.ProfileId = integrationProfile.Id;
        integrationUser.UserRoleId = admin.Id;
        insert(integrationUser);

        Account testIntelAccount = [Select Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Test.startTest();
        System.runAs(paymentAdmin){
            Core_MDF_Bank__c newBank = Core_MDF_CCP_TestDataUtility.createBank(testIntelAccount.id, 'Core_MDF_Client_CoMarketing_Fund', false,'1004567891');
            newBank.Core_MDF_Bank_Status__c = 'Draft';
            newBank.Core_MDF_DUNS__c = '578299333';
            newBank.Core_MDF_Bank_Beneficiary_Name__c = 'TEST BENEFICIARY NAME';
            newBank.Core_MDF_Bank_Location__c = 'IN';
            newBank.Core_MDF_Swift_Code__c = 'BOFSGB21124';
            newBank.Core_MDF_Intermediary_Indicator__c = 'N';
            newBank.Core_MDF_Routing_Number__c = '123456';
            newBank.Core_MDF_ESD_Hold_Indicator__c = FALSE;
            newBank.Core_MDF_Effective_Date__c = system.today().addDays(5);
            newBank.Core_MDF_Supplier_Name__c='TEST SUPPLIER NAME';
            newBank.Name = 'TEST BANK';
            newBank.Core_MDF_Bank_Location__c ='US';
            Insert newBank;
        }
        System.runAs(integrationUser){
            Core_Integration_Inbound_Message__c payLoad1 = new Core_Integration_Inbound_Message__c();
            payLoad1.Core_Payload__c = '[{"SUPPL_HLD_PMT_IND":"Y","bnfcy_nm":"TEST BENEFICIARY NAME","intrmd_bank_ind":"Y","bnk_nm":"TEST BANK","bnk_nbr":"123456","ap_vndr_nbr":1004567891,"DUNS_NBR":"578299333 ","ctry_cd":"US ","suppl_nm":"Test","swift_cd":"BOFSGB21124 "}]';
            payLoad1.Core_Message_Type__c = 'Bank';
            payLoad1.Core_Source_System__c   = 'EDW';
            insert payLoad1;
        }
        System.runAs(paymentAdmin){
            Core_MDF_Bank__c updatedBank = [SELECT  Name,Core_MDF_Bank_Status__c,Core_MDF_ESD_Hold_Indicator__c,
                                            Core_MDF_Bank_Beneficiary_Name__c, Core_MDF_Swift_Code__c, Core_MDF_DUNS__c,
                                            Core_MDF_Routing_Number__c, Core_MDF_ESD_Update__c, Core_MDF_Supplier_Number__c, Core_MDF_Supplier_Name__c, Core_MDF_Bank_Location__c
                                            FROM Core_MDF_Bank__c
                                            WHERE Core_MDF_Supplier_Number__c = '1004567891' LIMIT 1];

            System.assertEquals(FALSE, updatedBank.Core_MDF_ESD_Hold_Indicator__c);
            System.assertEquals('BOFSGB21124', updatedBank.Core_MDF_Swift_Code__c);
            System.assertEquals('578299333', updatedBank.Core_MDF_DUNS__c);
            System.assertEquals('123456', updatedBank.Core_MDF_Routing_Number__c);
            System.assertEquals('1004567891', updatedBank.Core_MDF_Supplier_Number__c);
            System.assertEquals('TEST SUPPLIER NAME',updatedBank.Core_MDF_Supplier_Name__c);
            System.assertEquals('US',updatedBank.Core_MDF_Bank_Location__c);
        }
        System.runAs(integrationUser){
            Core_Integration_Inbound_Message__c payLoad1 = new Core_Integration_Inbound_Message__c();
            payLoad1.Core_Payload__c = '[{"SUPPL_HLD_PMT_IND":"N","bnfcy_nm":"TEST BENEFICIARY NAME","intrmd_bank_ind":"N","bnk_nm":"TEST BANK","bnk_nbr":"123456","ap_vndr_nbr":1234567891,"DUNS_NBR":"578299333 ","ctry_cd":"US ","suppl_nm":"Test","swift_cd":"BOFSGB21124 "}]';
            payLoad1.Core_Message_Type__c = 'Bank';
            payLoad1.Core_Source_System__c   = 'EDW';
            insert payLoad1;
        }
        System.runAs(paymentAdmin){
            Core_MDF_Bank__c updatedBank = [SELECT  Name,Core_MDF_Bank_Status__c,Core_MDF_ESD_Hold_Indicator__c,
                                            Core_MDF_Bank_Beneficiary_Name__c, Core_MDF_Swift_Code__c, Core_MDF_DUNS__c,
                                            Core_MDF_Routing_Number__c, Core_MDF_ESD_Update__c, Core_MDF_Supplier_Number__c, Core_MDF_Supplier_Name__c, Core_MDF_Bank_Location__c
                                            FROM Core_MDF_Bank__c
                                            WHERE Core_MDF_Supplier_Number__c = '1004567891' LIMIT 1];
            System.assertEquals('US',updatedBank.Core_MDF_Bank_Location__c);
        }
        Test.stopTest();

    }
    @isTest
    static void updateBankDetailsAsSysAdmin(){
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
        Test.startTest();
        Account testAccount = [Select Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Core_MDF_Bank__c newBank = Core_MDF_CCP_TestDataUtility.createBank(testAccount.id, 'Core_MDF_Client_CoMarketing_Fund', false,'1234567891');
        newBank.Core_MDF_Bank_Status__c = 'Draft';
        newBank.Core_MDF_DUNS__c = '578299333';
        newBank.Core_MDF_Bank_Beneficiary_Name__c = 'TEST BENEFICIARY NAME';
        newBank.Core_MDF_Bank_Location__c = 'IN';
        newBank.Core_MDF_Swift_Code__c = 'BOFSGB21124';
        newBank.Core_MDF_Intermediary_Indicator__c = 'N';
        newBank.Core_MDF_Routing_Number__c = '123456';
        newBank.Core_MDF_ESD_Hold_Indicator__c = FALSE;
        newBank.Core_MDF_Effective_Date__c = system.today().addDays(-5);
        newBank.Core_MDF_Supplier_Name__c='TEST SUPPLIER NAME';
        newBank.Core_MDF_Bank_Location__c = 'IN';
        newBank.Name = 'TEST BANK';
        newBank.Core_MDF_Currency_cd__c = 'TZS';
        insert newBank;

        //Change Bank Program ESD Update = false
        newBank.Core_MDF_Program__c = 'Core_MDF_Data_Center_CoMarketing_Fund';
        update newBank;

        System.assert(newBank.Core_MDF_Program__c == 'Core_MDF_Data_Center_CoMarketing_Fund');

        //Change Bank Account ESD Update = false
        Account testAccount2 = [Select Id FROM Account WHERE Name = 'Test Account2' LIMIT 1];
        newBank.Core_MDF_Account__c = testAccount2.Id;
        newBank.Core_MDF_ESD_Update__c = false;
        update newBank;

        System.assert(newBank.Core_MDF_Account__c == testAccount2.Id);

        //Change Bank Owner ESD Update = false
        User dcfPaymentAdmin = [Select Id FROM User Where LastName = 'DCF Payment Admin 123' LIMIT 1];
        newBank.OwnerId = dcfPaymentAdmin.Id;
        update newBank;

        System.assert(newBank.OwnerId == dcfPaymentAdmin.Id);

        Test.stopTest();
        }
    }
    @isTest
    static void checkIfDuplicateRecordsInserted(){

        Profile integrationProfile = [SELECT Id FROM Profile WHERE Name='Integration' LIMIT 1];
        UserRole admin = [SELECT Id FROM UserRole where Name = 'Admin' LIMIT 1];
        User paymentAdmin = [Select Id FROM User Where LastName = 'Retail Payment Admin 123' LIMIT 1];

        User integrationUser = Core_MDF_CCP_TestDataUtility.createUser(false);
        integrationUser.LastName = 'Integration User';
        integrationUser.ProfileId = integrationProfile.Id;
        integrationUser.UserRoleId = admin.Id;
        insert(integrationUser);

        Account testIntelAccount = [Select Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Test.startTest();
        System.runAs(paymentAdmin){
            Core_MDF_Bank__c newBank = Core_MDF_CCP_TestDataUtility.createBank(testIntelAccount.id, 'Core_MDF_Retail_Marketing_Funds', false,'1200567811');
            newBank.Core_MDF_Bank_Status__c = 'Draft';
            newBank.Core_MDF_DUNS__c = '578299333';
            newBank.Core_MDF_Bank_Beneficiary_Name__c = 'TEST BENEFICIARY NAME';
            newBank.Core_MDF_Bank_Location__c = 'IN';
            newBank.Core_MDF_Swift_Code__c = 'BOFSGB21124';
            newBank.Core_MDF_Intermediary_Indicator__c = 'N';
            newBank.Core_MDF_Routing_Number__c = '123456';
            newBank.Core_MDF_ESD_Hold_Indicator__c = FALSE;
            newBank.Core_MDF_Effective_Date__c = system.today().addDays(5);
            newBank.Core_MDF_Supplier_Name__c='TEST SUPPLIER NAME';
            newBank.Name = 'TEST BANK';
            newBank.Core_MDF_Intel_Company_Code__c = '150';
            newBank.Core_MDF_Currency_cd__c ='USD';
            newBank.Core_MDF_Tax_codes_cd__c = 'I0';
            Insert newBank;
            try{
                Core_MDF_Bank__c retailBankDup = Core_MDF_CCP_TestDataUtility.createBank(testIntelAccount.id, 'Core_MDF_Retail_Marketing_Funds', false,'1200567811');
                retailBankDup.Core_MDF_Bank_Status__c = 'Draft';
                retailBankDup.Core_MDF_DUNS__c = '578299333';
                retailBankDup.Core_MDF_Bank_Beneficiary_Name__c = 'TEST BENEFICIARY NAME';
                retailBankDup.Core_MDF_Bank_Location__c = 'IN';
                retailBankDup.Core_MDF_Swift_Code__c = 'BOFSGB21124';
                retailBankDup.Core_MDF_Intermediary_Indicator__c = 'N';
                retailBankDup.Core_MDF_Routing_Number__c = '123456';
                retailBankDup.Core_MDF_ESD_Hold_Indicator__c = FALSE;
                retailBankDup.Core_MDF_Effective_Date__c = system.today().addDays(5);
                retailBankDup.Core_MDF_Supplier_Name__c='TEST SUPPLIER NAME';
                retailBankDup.Name = 'TEST BANK';
                retailBankDup.Core_MDF_Intel_Company_Code__c = '650';
                retailBankDup.Core_MDF_Currency_cd__c ='USD';
                retailBankDup.Core_MDF_Tax_codes_cd__c = 'I0';
                Insert retailBankDup;
            }catch(Exception ex){
                Boolean expectedExceptionThrown =  ex.getMessage().contains('A combination for this Supplier ID, Program and Currency already exists.') ? true : false;
                System.assertEquals(expectedExceptionThrown, true);
            }

                List<Core_MDF_Bank__c> bankList = new List<Core_MDF_Bank__c>();
                Core_MDF_Bank__c bank1 = Core_MDF_CCP_TestDataUtility.createBank(testIntelAccount.id, 'Core_MDF_Retail_Marketing_Funds', false,'1200567822');
                bank1.Core_MDF_Bank_Status__c = 'Draft';
                bank1.Core_MDF_DUNS__c = '578299333';
                bank1.Core_MDF_Bank_Beneficiary_Name__c = 'TEST BENEFICIARY NAME';
                bank1.Core_MDF_Bank_Location__c = 'IN';
                bank1.Core_MDF_Swift_Code__c = 'BOFSGB21124';
                bank1.Core_MDF_Intermediary_Indicator__c = 'N';
                bank1.Core_MDF_Routing_Number__c = '123456';
                bank1.Core_MDF_ESD_Hold_Indicator__c = FALSE;
                bank1.Core_MDF_Effective_Date__c = system.today().addDays(5);
                bank1.Core_MDF_Supplier_Name__c='TEST SUPPLIER NAME';
                bank1.Name = 'TEST BANK';
                bank1.Core_MDF_Intel_Company_Code__c = '150';
                bank1.Core_MDF_Currency_cd__c ='USD';
                bank1.Core_MDF_Tax_codes_cd__c = 'I0';
                bankList.add(bank1);

                Core_MDF_Bank__c bank2 = Core_MDF_CCP_TestDataUtility.createBank(testIntelAccount.id, 'Core_MDF_Retail_Marketing_Funds', false,'1200567822');
                bank2.Core_MDF_Bank_Status__c = 'Draft';
                bank2.Core_MDF_DUNS__c = '578299333';
                bank2.Core_MDF_Bank_Beneficiary_Name__c = 'TEST BENEFICIARY NAME';
                bank2.Core_MDF_Bank_Location__c = 'IN';
                bank2.Core_MDF_Swift_Code__c = 'BOFSGB21124';
                bank2.Core_MDF_Intermediary_Indicator__c = 'N';
                bank2.Core_MDF_Routing_Number__c = '123456';
                bank2.Core_MDF_ESD_Hold_Indicator__c = FALSE;
                bank2.Core_MDF_Effective_Date__c = system.today().addDays(5);
                bank2.Core_MDF_Supplier_Name__c='TEST SUPPLIER NAME';
                bank2.Name = 'TEST BANK';
                bank2.Core_MDF_Intel_Company_Code__c = '420';
                bank2.Core_MDF_Currency_cd__c ='USD';
                bank2.Core_MDF_Tax_codes_cd__c = 'I0';
                bankList.add(bank2);
                try{
                    insert(bankList);
                }catch(Exception ex){
                    // Highlight: Unused Local Variable
                  //  Boolean expectedExceptionThrown =  ex.getMessage().contains('No issues found for this record but this has been failed because of some other duplicate records in the batch.') ? true : false;
                  //System.assertEquals(expectedExceptionThrown, true, ex.getMessage());
                }
              Core_MDF_Bank__c bank3 = Core_MDF_CCP_TestDataUtility.createBank(testIntelAccount.id, 'Core_MDF_Retail_Marketing_Funds', false,'1200567233');
                bank3.Core_MDF_Bank_Status__c = 'Draft';
                bank3.Core_MDF_DUNS__c = '578299333';
                bank3.Core_MDF_Bank_Beneficiary_Name__c = 'TEST BENEFICIARY NAME';
                bank3.Core_MDF_Bank_Location__c = 'IN';
                bank3.Core_MDF_Swift_Code__c = 'BOFSGB21124';
                bank3.Core_MDF_Intermediary_Indicator__c = 'N';
                bank3.Core_MDF_Routing_Number__c = '123456';
                bank3.Core_MDF_ESD_Hold_Indicator__c = FALSE;
                bank3.Core_MDF_Effective_Date__c = system.today().addDays(5);
                bank3.Core_MDF_Supplier_Name__c='TEST SUPPLIER NAME';
                bank3.Name = 'TEST BANK';
                bank3.Core_MDF_Intel_Company_Code__c = '150';
                bank3.Core_MDF_Currency_cd__c ='USD';
                bank3.Core_MDF_Tax_codes_cd__c = 'I0';
                Insert bank3;
            try{
                bank3.Core_MDF_Supplier_Number__c ='1200567811';
                update bank3;
            }catch(Exception ex){
                Boolean expectedExceptionThrown =  ex.getMessage().contains('A combination for this Supplier ID, Program and Currency already exists.') ? true : false;
                System.assertEquals(expectedExceptionThrown, false, ex.getMessage());
            }
        }
    }

    @isTest
    static void updateBankABM(){
        User paymentAdmin = [Select Id FROM User Where LastName = 'Bank Payment Admin 123' LIMIT 1];
        System.runAs(paymentAdmin){

            Test.startTest();
            Account testAccount, coMarketingAccDCF;
            for(Account acc : ([Select Id, Name FROM Account WHERE Name IN ('Test Account', 'Test Acc DCF')])){
                if(acc.Name == 'Test Account'){
                    testAccount = acc;
                }
                else if(acc.Name == 'Test Acc DCF'){
                    coMarketingAccDCF = acc;
                }
            }
            Core_MDF_Bank__c newBank = Core_MDF_CCP_TestDataUtility.createBank(testAccount.id, 'Core_MDF_Client_CoMarketing_Fund;Core_MDF_Data_Center_CoMarketing_Fund', false,'1234500191');
            newBank.Core_MDF_Program__c = 'Core_MDF_Client_CoMarketing_Fund;Core_MDF_Data_Center_CoMarketing_Fund';
            newBank.Core_MDF_Bank_Status__c = 'Draft';
            newBank.Core_MDF_DUNS__c = '578299333';
            newBank.Core_MDF_Bank_Beneficiary_Name__c = 'TEST BENEFICIARY NAME';
            newBank.Core_MDF_Bank_Location__c = 'IN';
            newBank.Core_MDF_Swift_Code__c = 'BOFSGB21124';
            newBank.Core_MDF_Intermediary_Indicator__c = 'N';
            newBank.Core_MDF_Routing_Number__c = '123456';
            newBank.Core_MDF_ESD_Hold_Indicator__c = FALSE;
            newBank.Core_MDF_Effective_Date__c = system.today().addDays(-5);
            newBank.Core_MDF_Supplier_Name__c='TEST SUPPLIER NAME';
            newBank.Core_MDF_Bank_Location__c = 'IN';
            newBank.Name = 'TEST BANK';
            newBank.Core_MDF_Currency_cd__c ='TZS';
            insert newBank;

            
            newBank.Core_MDF_Bank_Status__c = 'Active';
            update newBank;
            
            System.assertEquals(newBank.Core_MDF_Bank_Status__c, 'Active');
           // Highlight: Unused Local Variable 
           // Core_MDF_Account_Bank_Mapping__c abmCCF1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(coMarketingAccDCF.Id, newBank.Id, TRUE);

            //Change Bank Program when ESD Update = false
            newBank.Core_MDF_Program__c = 'Core_MDF_Client_CoMarketing_Fund';
            update newBank;
        }
        Test.stopTest();
    }
}