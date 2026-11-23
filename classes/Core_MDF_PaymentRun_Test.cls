/****************************************************************************************************************************************
* Class Name  : Core_MDF_PaymentRun_Test
* Version     : 1.0 
* Created Date: 22-Jan-2019
* Modification Log :
* Developer                        Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture- AD          22/Jan/2019                    Created to test payment batch job
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
private class Core_MDF_PaymentRun_Test
{
    @TestSetup static void setUpData(){ 
        List<Contact> contactList = new List<Contact>();
        List<User> userList = new List<User>();
        List<ChannelProgram> channelProgramList = new List<ChannelProgram>();
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        List<PartnerFundClaim> claimListToBeProcessed = new List<PartnerFundClaim>();
        List<PartnerFundAllocation> pfaList = new List<PartnerFundAllocation>();        
        List<Group> groupList = new List<Group>();
        
        /*Account accRecord = Core_MDF_CCP_TestDataUtility.createAccount ('Intel Test Account ', NULL, Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);   
        accRecord.BillingCity = 'Test City';         
        accRecord.BillingCountry= 'AUS';
        accRecord.BillingStreet= 'Test Street';
        Database.insert(accRecord);   */

        // Creating Intel Account with utility class
        Account dellCorpAccount = Core_MDF_CCP_TestDataUtility.createAccount ('Dell Corporation', NULL,Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);   
        dellCorpAccount.BillingCity = 'Test City';         
        dellCorpAccount.BillingCountry= 'AUS';
        dellCorpAccount.BillingStreet= 'Test Street';
        Database.insert(dellCorpAccount); 
        //dellCorpAccount.IsPartner = true;
        //Database.update(dellCorpAccount);
        
        
        //Creating Contact for Partner User
        Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(dellCorpAccount.Id,false);
        contactList.add(conRecord1);
        Contact conRecord2 = Core_MDF_CCP_TestDataUtility.createContact(dellCorpAccount.Id,false);
        contactList.add(conRecord2);
        
        database.insert(contactList);
        
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.Email = 'sysadmin@example.com';
        userList.add(usr);
        
        Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
        Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
        PermissionSet progAdmPS = [Select Id from PermissionSet where name='Core_MDF_CCP_Internal_Program_Adm' LIMIT 1]; 
        PermissionSet clmCaseUsr = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Claim_Case_Reviewer' LIMIT 1];
        PermissionSet clmSubmitterUser = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_External_Claim_Submitter' LIMIT 1];
        
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);        
        usr1.Email='test1@example.com';
        usr1.ContactId = conRecord1.Id;
        usr1.ProfileId = profileId;
        usr1.isActive = true;
        userList.add(usr1);
        
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.Email='testPayment@example.com';
        usr2.LastName='ProgAdmUser';
        usr2.profileId = ccpCoreProfile.Id;
        usr2.IsActive = true;
        userList.add(usr2); 
        
        User usr3 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr3.Email='testreviewer@example.com';
        usr3.LastName='ClaimCaseUser';
        usr3.profileId = ccpCoreProfile.Id;
        usr3.IsActive = true;
        userList.add(usr3);
        
        User usr4 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr4.Email='testreviewer2@example.com';
        usr4.LastName='ClaimSubmitter';
        usr4.ContactId = conRecord2.Id;
        usr4.profileId = profileId;
        usr4.IsActive = true;
        userList.add(usr4);
        
        database.insert(userList); 
        
        List<PermissionSetAssignment> permSetAssgnLst = new List<PermissionSetAssignment>();
        
        PermissionSetAssignment assignPermissionSetObj = new PermissionSetAssignment();
        assignPermissionSetObj.AssigneeId = usr2.Id;
        assignPermissionSetObj.PermissionSetId = progAdmPS.Id;
        permSetAssgnLst.add(assignPermissionSetObj);
        
        PermissionSetAssignment assignPermissionSetObj1 = new PermissionSetAssignment();
        assignPermissionSetObj1.AssigneeId = usr3.Id;
        assignPermissionSetObj1.PermissionSetId = clmCaseUsr.Id;
        permSetAssgnLst.add(assignPermissionSetObj1);
        
        PermissionSetAssignment assignPermissionSetObj2 = new PermissionSetAssignment();
        assignPermissionSetObj2.AssigneeId = usr4.Id;
        assignPermissionSetObj2.PermissionSetId = clmSubmitterUser.Id;
        permSetAssgnLst.add(assignPermissionSetObj2);
        
        system.runAs(usr){
            Database.insert(permSetAssgnLst);
        }
        
        // Creating Groups for PGM
        Group grp = new Group();
        grp.name = 'PGM_TEST';
        groupList.add(grp);
        
        Group grp1 = new Group();
        grp1.name = 'PGM_TEST1';
        groupList.add(grp1);
        
        Group grp2 = new Group();
        grp2.name = 'PGM_TEST2';
        groupList.add(grp2);
        
        Database.insert(groupList);
        
        List<UserShare> usList = new List<UserShare>();
        UserShare us1 = new UserShare(UserId = usr3.Id, UserOrGroupId = grp.Id, RowCause = 'Manual', UserAccessLevel = 'Read');
        UserShare us2 = new UserShare(UserId = usr3.Id, UserOrGroupId = grp1.Id, RowCause = 'Manual', UserAccessLevel = 'Read');
        UserShare us3 = new UserShare(UserId = usr3.Id, UserOrGroupId = grp2.Id, RowCause = 'Manual', UserAccessLevel = 'Read');
        UserShare us4 = new UserShare(UserId = usr2.Id, UserOrGroupId = grp.Id, RowCause = 'Manual', UserAccessLevel = 'Read');
        UserShare us5 = new UserShare(UserId = usr2.Id, UserOrGroupId = grp1.Id, RowCause = 'Manual', UserAccessLevel = 'Read');
        UserShare us6 = new UserShare(UserId = usr2.Id, UserOrGroupId = grp2.Id, RowCause = 'Manual', UserAccessLevel = 'Read');
        usList.add(us1);
        usList.add(us2);
        usList.add(us3);
        usList.add(us4);
        usList.add(us5);
        usList.add(us6);
        Database.insert(usList);
        
        // Adding Users in group
        List<GroupMember> gmList = new List<GroupMember>();
        GroupMember gm = new GroupMember();
        gm.GroupId = grp.Id;
        gm.UserOrGroupId = usr3.Id;
        GroupMember gm1 = new GroupMember();
        gm1.GroupId = grp1.Id;
        gm1.UserOrGroupId = usr3.Id;
        GroupMember gm2 = new GroupMember();
        gm2.GroupId = grp2.Id;
        gm2.UserOrGroupId = usr3.Id;
        GroupMember gm3 = new GroupMember();
        gm3.GroupId = grp.Id;
        gm3.UserOrGroupId = usr2.Id;
        GroupMember gm4 = new GroupMember();
        gm4.GroupId = grp1.Id;
        gm4.UserOrGroupId = usr2.Id;
        GroupMember gm5 = new GroupMember();
        gm5.GroupId = grp2.Id;
        gm5.UserOrGroupId = usr2.Id;
        gmList.add(gm);
        gmList.add(gm1);
        gmList.add(gm2);
        gmList.add(gm3);
        gmList.add(gm4);
        gmList.add(gm5);
        system.runAs(usr){
            insert gmList;
        }
        
        // Creating Channel program
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', false);
        channelProgramList.add(cp);
        ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Data Center Co-Marketing Fund','Data Center CoMarketing Fund', false);
        channelProgramList.add(cp1);
        
        database.insert(channelProgramList);
        
        // Creating Intel Account with utility class
        /* Account dellCorpAccount = Core_MDF_CCP_TestDataUtility.createAccount ('Dell Corporation', cp.Id,Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);   
        dellCorpAccount.BillingCity = 'Test City';         
        dellCorpAccount.BillingCountry= 'AUS';
        dellCorpAccount.BillingStreet= 'Test Street';
        Database.insert(dellCorpAccount); 
        //dellCorpAccount.IsPartner = true;
        //Database.update(dellCorpAccount); */
        
        // Creating Co-marketing Account with utility class
        Account dellCCFVirtualCorp = Core_MDF_CCP_TestDataUtility.createAccount ('Dell CCF Virtual Corp', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        dellCCFVirtualCorp.Core_MDF_Parent_Fund_Account__c = dellCorpAccount.Id;
        dellCCFVirtualCorp.Core_MDF_CoMarketingActive__c = true;
        Database.insert(dellCCFVirtualCorp);
        
        //Core_MDF_CCP_TestDataUtility.createPartnerGroupMapping(dellCorpAccount.Id,'Internal',accRecord.Id,cp.Id,'Test_PGM',true);  
        List<Core_MDF_Partner_Group_Mapping__c> pgmList = new List<Core_MDF_Partner_Group_Mapping__c>();
        Core_MDF_Partner_Group_Mapping__c pgm = new Core_MDF_Partner_Group_Mapping__c();
        pgm.Core_MDF_Account__c = dellCorpAccount.Id;
        pgm.Core_MDF_Group_Name__c = 'PGM_TEST_Group2';
        pgm.Core_MDF_Type_of_Access__c = 'Internal';
        pgm.Core_MDF_Group_Id__c = grp.Id;                
        pgm.Core_MDF_Channel_Program__c = cp.Id;
        pgm.Core_MDF_Region_cd__c='WW';
        pgm.Core_MDF_Source_Txt__c = 'test';
        pgm.Core_MDF_AccountIdGroupName__c = dellCorpAccount.Id+'PGM_TEST_Group2';
        pgmList.add(pgm);
        //database.insert(pgm);
        
        Core_MDF_Partner_Group_Mapping__c pgm1 = new Core_MDF_Partner_Group_Mapping__c();
        pgm1.Core_MDF_Account__c = dellCorpAccount.Id;
        pgm1.Core_MDF_Group_Name__c = 'PGM_TEST_Group1';
        pgm1.Core_MDF_Type_of_Access__c = 'Internal';
        pgm1.Core_MDF_Group_Id__c = grp1.Id;                
        pgm1.Core_MDF_Channel_Program__c = cp.Id;
        pgm1.Core_MDF_Region_cd__c='EMEA';
        pgm1.Core_MDF_Source_Txt__c = 'test';
        pgm1.Core_MDF_AccountIdGroupName__c =dellCorpAccount.Id+'PGM_TEST_Group1';
        pgmList.add(pgm1);
        //database.insert(pgm1);
        
        Core_MDF_Partner_Group_Mapping__c pgm2 = new Core_MDF_Partner_Group_Mapping__c();
        pgm2.Core_MDF_Account__c = dellCorpAccount.Id;
        pgm2.Core_MDF_Group_Name__c = 'PGM_TEST5';
        pgm2.Core_MDF_Type_of_Access__c = 'Internal';
        pgm2.Core_MDF_Group_Id__c = grp2.Id;                
        pgm2.Core_MDF_Channel_Program__c = cp.Id;
        pgm2.Core_MDF_Region_cd__c='ASMO';
        pgm2.Core_MDF_Source_Txt__c = 'test';
        pgm2.Core_MDF_AccountIdGroupName__c =dellCorpAccount.Id+'PGM_TEST5';
        pgmList.add(pgm2);
        database.insert(pgmList);
        
        List<Account> accList = new List<Account>();
        Account dellCCFAPAC = Core_MDF_CCP_TestDataUtility.createAccount ('Dell CCF APAC', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type,  false);
        dellCCFAPAC.Core_MDF_Parent_Fund_Account__c = dellCCFVirtualCorp.Id;
        dellCCFAPAC.Core_MDF_CoMarketingActive__c = true;
        accList.add(dellCCFAPAC);
        //Database.insert(dellCCFAPAC);
        
        Account dellCCFAPACIndia = Core_MDF_CCP_TestDataUtility.createAccount ('Dell CCF APAC India', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        dellCCFAPACIndia.Core_MDF_Parent_Fund_Account__c = dellCCFVirtualCorp.Id;
        dellCCFAPACIndia.Core_MDF_Auto_Transfer_Account__c = dellCCFVirtualCorp.ID;
        dellCCFAPACIndia.Core_MDF_Enabled_Auto_Transfer__c = True;
        dellCCFAPACIndia.Core_MDF_CoMarketingActive__c = true;
        accList.add(dellCCFAPACIndia);
        Database.insert(accList);
        
        Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(dellCCFAPACIndia.Id, usr1.Id, true);
        
        Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
        // Create PMB for the above Account 
        PartnerMarketingBudget  pmbRecord = Core_MDF_CCP_TestDataUtility.createBudget('Dell PMB',RecordTypeIdPMB,dellCCFVirtualCorp.Id,cp.Id,1000000,System.today().addDays(-15),System.today().addDays(15),false);
        pmbRecord.IsIgnoreValidation = true;
        Database.insert(pmbRecord);
        
        // Create PFA records for the above accounts :
        PartnerFundAllocation pfaDellCCFVirtualCorp = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('pfaDellCCFVirtualCorp',pmbRecord, dellCCFVirtualCorp, 100000,false);
        pfaList.add(pfaDellCCFVirtualCorp);
        PartnerFundAllocation pfaDellCCFIndia = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('pfaDellCCFIndia',pmbRecord, dellCCFAPACIndia, 10000,false);
        pfaList.add(pfaDellCCFIndia);
        
        database.insert(pfaList);
        //Creating Bank
        Core_MDF_Bank__c indiaBank = Core_MDF_CCP_TestDataUtility.createBank(dellCorpAccount.Id, 'CCF', false,'1231231230');
        indiaBank.Core_MDF_Bank_Status__c = 'Active';
        indiaBank.Core_MDF_Program__c='Core_MDF_Data_Center_CoMarketing_Fund;Core_MDF_Client_CoMarketing_Fund';
        Database.insert(indiaBank);
        
         //creating ABM for bank1
        Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(dellCCFAPACIndia.Id,indiaBank.Id,true);
        
        Test.startTest();
        //Creating campaign
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7+ Processor', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today().addDays(-10), System.today().addDays(10), 10000, 'Consumer Chromebook', dellCCFVirtualCorp.Id, '2-in-1', true); 
                
        //Creating Partner fund Request for each Geo 
        PartnerFundRequest indiaActivity = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                 string.valueof(dellCCFAPACIndia.id),pfaDellCCFIndia,pmbRecord,
                                                                                                 'BRAZIL','Consumer','Desktop','Intel® Core™ i5 Processor','Broadcast','Podcast','Draft'
                                                                                                 ,false);
        indiaActivity.Title = 'indiaActivity';
        indiaActivity.Core_MDF_Activity_Description__c = 'indiaActivity';
        indiaActivity.Core_MDF_Start_Date__c = System.today().addDays(-5);
        indiaActivity.Core_MDF_End_Date__c = System.today().addDays(5);
        indiaActivity.RequestedAmount = 100;
        indiaActivity.amount = 0;
        indiaActivity.Core_MDF_Channel_Partner_Led__c = True;
        pfrList.add(indiaActivity);
        PartnerFundRequest indiaActivity1= Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                 string.valueof(dellCCFAPACIndia.id),pfaDellCCFIndia,pmbRecord,
                                                                                                 'SINGAPORE','Consumer','Desktop','Intel® Core™ i5 Processor','Broadcast','Podcast','Draft'
                                                                                                 ,false);
        indiaActivity1.Title = 'indiaActivity1';
        indiaActivity1.Core_MDF_Activity_Description__c = 'indiaActivity';
        indiaActivity1.Core_MDF_Start_Date__c = System.today().addDays(-5);
        indiaActivity1.Core_MDF_End_Date__c = System.today().addDays(5);
        indiaActivity1.RequestedAmount = 100;
        indiaActivity1.amount = 0;
        indiaActivity1.Core_MDF_Channel_Partner_Led__c = True;
        pfrList.add(indiaActivity1);
        PartnerFundRequest indiaActivity2= Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                 string.valueof(dellCCFAPACIndia.id),pfaDellCCFIndia,pmbRecord,
                                                                                                 'EGYPT','Consumer','Desktop','Intel® Core™ i5 Processor','Broadcast','Podcast','Draft'
                                                                                                 ,false);
        indiaActivity2.Title = 'indiaActivity2';
        indiaActivity2.Core_MDF_Activity_Description__c = 'indiaActivity';
        indiaActivity2.Core_MDF_Start_Date__c = System.today().addDays(-5);
        indiaActivity2.Core_MDF_End_Date__c = System.today().addDays(5);
        indiaActivity2.RequestedAmount = 100;
        indiaActivity2.amount = 0;
        indiaActivity2.Core_MDF_Channel_Partner_Led__c = True;
        pfrList.add(indiaActivity2);
        PartnerFundRequest indiaActivity3 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                  string.valueof(dellCCFAPACIndia.id),pfaDellCCFIndia,pmbRecord,
                                                                                                  'MACAU','Consumer','Desktop','Intel® Core™ i5 Processor','Broadcast','Podcast','Draft'
                                                                                                  ,false);
        indiaActivity3.Title = 'indiaActivity3';
        indiaActivity3.Core_MDF_Activity_Description__c = 'indiaActivity';
        indiaActivity3.Core_MDF_Start_Date__c = System.today().addDays(-5);
        indiaActivity3.Core_MDF_End_Date__c = System.today().addDays(5);
        indiaActivity3.RequestedAmount = 100;
        indiaActivity3.amount = 0;
        indiaActivity3.Core_MDF_Channel_Partner_Led__c = True;
        pfrList.add(indiaActivity3);
        Database.insert(pfrList);
        system.debug('pfrList'+pfrList);
        //Creating Claims for each Geo
        PartnerFundClaim indiaClaim = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                               indiaActivity.Id, 
                                                                               indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                                               101, 
                                                                               indiaActivity.Core_MDF_Start_Date__c, indiaBank.ID, false);
        indiaClaim.Core_MDF_Currency__c = 'USD';
        claimListToBeProcessed.add(indiaClaim);
        
        PartnerFundClaim indiaClaim2 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim2', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                indiaActivity1.Id, 
                                                                                indiaActivity1.Core_MDF_Start_Date__c, indiaActivity1.Core_MDF_Start_Date__c, 
                                                                                100, 
                                                                                indiaActivity1.Core_MDF_Start_Date__c, indiaBank.ID, false);
        
        
        indiaClaim2.Core_MDF_Currency__c = 'USD';
        
        claimListToBeProcessed.add(indiaClaim2);
        
        PartnerFundClaim indiaClaim3 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim3',Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                indiaActivity2.Id, 
                                                                                indiaActivity2.Core_MDF_Start_Date__c, indiaActivity2.Core_MDF_Start_Date__c, 
                                                                                100, 
                                                                                indiaActivity2.Core_MDF_Start_Date__c, indiaBank.ID, false);
        
        
        indiaClaim3.Core_MDF_Currency__c = 'USD';
        
        claimListToBeProcessed.add(indiaClaim3);
        
        PartnerFundClaim indiaClaim4 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim4', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                indiaActivity3.Id, 
                                                                                indiaActivity3.Core_MDF_Start_Date__c, indiaActivity3.Core_MDF_Start_Date__c, 
                                                                                100, 
                                                                                indiaActivity3.Core_MDF_Start_Date__c, indiaBank.ID, false);
        
        
        indiaClaim4.Core_MDF_Currency__c = 'USD';
        
        claimListToBeProcessed.add(indiaClaim4);
        
        Database.insert(claimListToBeProcessed);
        
        system.debug('claimListToBeProcessed::'+claimListToBeProcessed);
        
        Core_MDF_CCP_TestDataUtility.createTriggerExecutionRecords();
        
        Core_MDF_CCP_TestDataUtility.insertCurrencyExchangeRates();
        
        Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount aObj = new Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount();
        Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount bObj = new Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount();
        Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount cObj = new Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount();
        List<Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount> listvar = new List<Core_MDF_CCP_Multicurrency.getExchangeRateAndAmount>();
        
        aObj.inputCurrency ='ZMK';
        aObj.inputAmount = 250.00;
        aObj.inputDate= System.today();
        bObj.inputCurrency ='INR';
        bObj.inputAmount = 350.00;
        bObj.inputDate= System.today();
        cObj.inputCurrency ='USD';
        cObj.inputAmount = 350.00;
        cObj.inputDate= System.today();
        listvar.add(aObj);
        listvar.add(bObj);
        listvar.add(cObj);
        Core_MDF_CCP_Multicurrency.getUSDExchangeRateBasedOnDate(listvar);
        
        Core_Trigger_Executions__c setting = new Core_Trigger_Executions__c();
        setting.Core_Active__c = false;
        setting.Core_Class_Name__c = 'Core_MDF_AdjustmentClaimOffsetProcess';
        setting.Core_Description__c = 'Demo Description';
        setting.Core_Object__c = 'Core_MDF_Payment_Run__c';
        setting.Core_Trigger_Events__c = 'after insert';
        setting.name = 'Core_MDF_AdjustmentClaimOffsetProcess';
        insert setting;
        Test.stopTest();
        
    }
    // Test method to test scheduling and file generation functionality Payments Process 
    @isTest static void testPaymentRunSchOnCreate(){
        Test.startTest();
        
        List<Core_MDF_Payment_Run__c> paymentRunList = new List<Core_MDF_Payment_Run__c>();
        ChannelProgram cp = [SELECT ID From ChannelProgram where Name = 'Client Co-Marketing Fund'];
        ChannelProgram cp1 = [SELECT ID From ChannelProgram where Name = 'Data Center Co-Marketing Fund'];
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User payAdmUser = [SELECT Id,Email from User where Email='testPayment@example.com' limit 1];
        
        System.runAs(payAdmUser){
            Core_MDF_Payment_Run__c payRunRecord = new Core_MDF_Payment_Run__c();
            payRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(2);
            payRunRecord.Core_MDF_Geo_Txt__c = 'ASMO';
            payRunRecord.Core_MDF_Program_Id__c  = cp.Id;
            paymentRunList.add(payRunRecord);
        }
        
        System.runAs(sysAdminUser){ 
            Core_MDF_Payment_Run__c payRunRecord1 = new Core_MDF_Payment_Run__c();
            payRunRecord1.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(2);
            payRunRecord1.Core_MDF_Geo_Txt__c = 'ASMO';
            payRunRecord1.Core_MDF_Program_Id__c  = cp1.Id;
            paymentRunList.add(payRunRecord1);
            Database.insert(paymentRunList);
            System.assertNotEquals(payRunRecord1.Id,null);
        }
        Test.stopTest();
    }
    // Test method to test offset Adjustment
    @isTest static void testAdjustmentActiveFalse(){
        Test.startTest();
        ChannelProgram cp = [SELECT ID From ChannelProgram where Name = 'Client Co-Marketing Fund'];
        ChannelProgram cp1 = [SELECT ID From ChannelProgram where Name = 'Data Center Co-Marketing Fund'];
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User claimCaseUser = [SELECT Id,Email from User where Email='testreviewer@example.com' limit 1];
        
        
        
        User payAdmUser = [SELECT Id,Email from User where Email='testPayment@example.com' limit 1];
        PartnerFundClaim claim1 =[SELECT Id,Core_MDF_Status__c from PartnerFundClaim where Title ='India Claim3'limit 1];
        
        System.runAs(claimCaseUser){
            Core_MDF_Adjustment_Request__c adjustment1 = new Core_MDF_Adjustment_Request__c();          
            adjustment1.Core_MDF_Reference_Claim_Nbr__c = claim1.Id;
            adjustment1.Core_MDF_Amount_Amt__c = 10;
            adjustment1.Core_MDF_Reason_Cd__c = 'Claim Review Results (Negative)';
            Database.insert(adjustment1);
        }
       
        System.runAs(sysAdminUser){  
            Core_MDF_Payment_Run__c payRunRecord = new Core_MDF_Payment_Run__c();
            payRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(2);
            payRunRecord.Core_MDF_Geo_Txt__c = 'EMEA';
            payRunRecord.Core_MDF_Program_Id__c  = cp.Id;
            Database.insert(payRunRecord);
            System.assertNotEquals(payRunRecord.Id,null);

            Core_MDF_Payment_Run__c payRunRecord1 = new Core_MDF_Payment_Run__c();
            payRunRecord1.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(2);
            payRunRecord1.Core_MDF_Geo_Txt__c = 'EMEA';
            payRunRecord1.Core_MDF_Program_Id__c  = cp1.Id;
            Database.insert(payRunRecord1);
            System.assertNotEquals(payRunRecord1.Id,null);
        }
        Test.stopTest(); 
    }
    // Test method to test offset Adjustment
    @isTest static void testAdjustmentEqualClaimAndActiveTrue(){
        Test.startTest();
        ChannelProgram cp = [SELECT ID From ChannelProgram where Name = 'Client Co-Marketing Fund'];
        ChannelProgram cp1 = [SELECT ID From ChannelProgram where Name = 'Data Center Co-Marketing Fund'];
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User claimCaseUser = [SELECT Id,Email from User where Email='testreviewer@example.com' limit 1];
        PartnerFundClaim claim2 =[SELECT Id,Core_MDF_Status__c from PartnerFundClaim where Title ='India Claim2'limit 1];
        User payAdmUser = [SELECT Id,Email from User where Email='testPayment@example.com' limit 1];
        
        System.runAs(claimCaseUser){
            Core_MDF_Adjustment_Request__c adjustment1 = new Core_MDF_Adjustment_Request__c();          
            adjustment1.Core_MDF_Reference_Claim_Nbr__c = claim2.Id;
            adjustment1.Core_MDF_Amount_Amt__c = 25;
            adjustment1.Core_MDF_Reason_Cd__c = 'Claim Review Results (Negative)';
            Database.insert(adjustment1); 
        }
        System.runAs(sysAdminUser){
            Core_MDF_Payment_Run__c payRunRecord = new Core_MDF_Payment_Run__c();
            payRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(2);
            payRunRecord.Core_MDF_Geo_Txt__c = 'APJ';
            payRunRecord.Core_MDF_Program_Id__c  = cp.Id;
            Database.insert(payRunRecord);
            System.assertNotEquals(payRunRecord.Id,null);
            
            Core_MDF_Payment_Run__c payRunRecord1 = new Core_MDF_Payment_Run__c();
            payRunRecord1.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(2);
            payRunRecord1.Core_MDF_Geo_Txt__c = 'APJ';
            payRunRecord1.Core_MDF_Program_Id__c  = cp1.Id;
            Database.insert(payRunRecord1);
            System.assertNotEquals(payRunRecord1.Id,null);
        }        
        Test.stopTest();      
    }
    // Test method to test offset Adjustment
    @isTest static void testAdjustmentGreaterthanClaim(){
        Test.startTest(); 
        ChannelProgram cp = [SELECT ID From ChannelProgram where Name = 'Client Co-Marketing Fund'];
        ChannelProgram cp1 = [SELECT ID From ChannelProgram where Name = 'Data Center Co-Marketing Fund'];
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User claimCaseUser = [SELECT Id,Email from User where Email='testreviewer@example.com' limit 1];
        PartnerFundClaim claim3 =[SELECT Id,Core_MDF_Status__c from PartnerFundClaim where Title ='India Claim4'limit 1];
        User payAdmUser = [SELECT Id,Email from User where Email='testPayment@example.com' limit 1];
        
        System.runAs(claimCaseUser){  
            Core_MDF_Adjustment_Request__c adjustment1 = new Core_MDF_Adjustment_Request__c();          
            adjustment1.Core_MDF_Reference_Claim_Nbr__c = claim3.Id;
            adjustment1.Core_MDF_Amount_Amt__c = 25;
            adjustment1.Core_MDF_Reason_Cd__c = 'Claim Review Results (Negative)';
            Database.insert(adjustment1);
        }
        System.runAs(sysAdminUser){
            Core_MDF_Payment_Run__c payRunRecord = new Core_MDF_Payment_Run__c();
            payRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(2);
            payRunRecord.Core_MDF_Geo_Txt__c = 'PRC';
            payRunRecord.Core_MDF_Program_Id__c  = cp.Id;
            Database.insert(payRunRecord);
            System.assertNotEquals(payRunRecord.Id,null);

            Core_MDF_Payment_Run__c payRunRecord1 = new Core_MDF_Payment_Run__c();
            payRunRecord1.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(2);
            payRunRecord1.Core_MDF_Geo_Txt__c = 'PRC';
            payRunRecord1.Core_MDF_Program_Id__c  = cp1.Id;
            Database.insert(payRunRecord1);
            System.assertNotEquals(payRunRecord1.Id,null);
        }
        Test.stopTest();      
    }
    // Test method to test offset Adjustment
    @isTest static void testAdjustmentLessthanClaim(){
        Test.startTest();
        ChannelProgram cp = [SELECT ID From ChannelProgram where Name = 'Client Co-Marketing Fund'];
        ChannelProgram cp1 = [SELECT ID From ChannelProgram where Name = 'Data Center Co-Marketing Fund'];
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User extUser = [SELECT Id,Email from User where Email='test1@example.com' limit 1];
        User payAdmUser = [SELECT Id,Email from User where Email='testPayment@example.com' limit 1];
        User claimCaseUser = [SELECT Id,Email from User where Email='testreviewer@example.com' limit 1];
        
        PartnerFundRequest indiaActivity = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title='indiaActivity' limit 1];
        
        Core_MDF_Bank__c indiaBank = [Select ID from Core_MDF_Bank__c limit 1];
        
        List<PartnerFundClaim> claimListToBeProcessed = new List<PartnerFundClaim>();
         
        PartnerFundClaim indiaClaim = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                               indiaActivity.Id, 
                                                                               indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                                               101, 
                                                                               indiaActivity.Core_MDF_Start_Date__c, indiaBank.ID, false);
        indiaClaim.Core_MDF_Currency__c = 'USD';
        PartnerFundClaim indiaClaim2 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                indiaActivity.Id, 
                                                                                indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                                                100, 
                                                                                indiaActivity.Core_MDF_Start_Date__c, indiaBank.ID, false);
        
        
        indiaClaim2.Core_MDF_Currency__c = 'USD';
        PartnerFundClaim indiaClaim3 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                indiaActivity.Id, 
                                                                                indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                                                100, 
                                                                                indiaActivity.Core_MDF_Start_Date__c, indiaBank.ID, false);
        indiaClaim3.Core_MDF_Currency__c = 'USD';
        
        claimListToBeProcessed.add(indiaClaim);
        claimListToBeProcessed.add(indiaClaim2);
        claimListToBeProcessed.add(indiaClaim3);
        System.runAs(sysAdminUser){
            Database.insert(claimListToBeProcessed);
        }
        System.runAs(claimCaseUser){
            Core_MDF_Adjustment_Request__c adjustment1 = new Core_MDF_Adjustment_Request__c();          
            adjustment1.Core_MDF_Reference_Claim_Nbr__c = indiaClaim3.Id;
            adjustment1.Core_MDF_Amount_Amt__c = 10;
            adjustment1.Core_MDF_Reason_Cd__c = 'Claim Review Results (Negative)';
            
            Database.insert(adjustment1);
        }
        System.runAs(sysAdminUser){
            Core_Trigger_Executions__c setting = new Core_Trigger_Executions__c();
            setting.Core_Active__c = true;
            setting.Core_Class_Name__c = 'Core_MDF_AdjustmentClaimOffsetProcess';
            setting.Core_Description__c = 'Demo Description';
            setting.Core_Object__c = 'Core_MDF_Payment_Run__c';
            setting.Core_Trigger_Events__c = 'after insert';
            setting.name = 'Core_MDF_AdjustmentClaimOffsetProcess';
            insert setting;
        }
        System.runAs(sysAdminUser){
            List<Core_MDF_Payment_Run__c> payRunList = new List<Core_MDF_Payment_Run__c>();
            Core_MDF_Payment_Run__c payRunRecord = new Core_MDF_Payment_Run__c();
            payRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(2);
            payRunRecord.Core_MDF_Geo_Txt__c = 'ASMO';
            payRunRecord.Core_MDF_Program_Id__c  = cp.Id;
            payRunList.add(payRunRecord);
            //Database.insert(payRunRecord);
            

            Core_MDF_Payment_Run__c payRunRecord1 = new Core_MDF_Payment_Run__c();
            payRunRecord1.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(2);
            payRunRecord1.Core_MDF_Geo_Txt__c = 'ASMO';
            payRunRecord1.Core_MDF_Program_Id__c  = cp1.Id;
            payRunList.add(payRunRecord1);
            Database.insert(payRunList);
            System.assertNotEquals(payRunRecord1.Id,null);
            System.assertNotEquals(payRunRecord.Id,null); 
        }
        Test.stopTest();      
    }
    // Test method to test Exception Handling In case of any errors during Payments Process 
    @isTest  
    static void testPaymentRunSchOnCreateError(){ 
        Test.startTest();
        ChannelProgram cp1 = [SELECT ID From ChannelProgram where Name = 'Data Center Co-Marketing Fund'];
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User extUser = [SELECT Id,Email from User where Email='test1@example.com' limit 1];
        User payAdmUser = [SELECT Id,Email from User where Email='testPayment@example.com' limit 1];
        User claimCaseUser = [SELECT Id,Email from User where Email='testreviewer@example.com' limit 1];
        
        
        PartnerFundRequest indiaActivity = [SELECT Id,RecordTypeId,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title='indiaActivity' limit 1];
        indiaActivity.RecordTypeId = Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_DCF;
        update indiaActivity;
        
        Core_MDF_Bank__c indiaBank = [Select ID,Core_MDF_Program__c from Core_MDF_Bank__c limit 1];
        //indiaBank.Core_MDF_Program__c = 'Core_MDF_Data_Center_CoMarketing_Fund';
        //update indiaBank;
        
        List<PartnerFundClaim> claimListToBeProcessed = new List<PartnerFundClaim>();
         
        System.runAs(sysAdminUser){
            PartnerFundClaim indiaClaim = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_DCF, 
                                                                                   indiaActivity.Id, 
                                                                                   indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                                                   101, 
                                                                                   indiaActivity.Core_MDF_Start_Date__c, indiaBank.ID, false);
            indiaClaim.Core_MDF_Currency__c = 'USD';
            indiaClaim.Core_MDF_Sub_Region_Cd__c = 'LAR';
            PartnerFundClaim indiaClaim2 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_DCF, 
                                                                                    indiaActivity.Id, 
                                                                                    indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                                                    100, 
                                                                                    indiaActivity.Core_MDF_Start_Date__c, indiaBank.ID, false);
            indiaClaim2.Core_MDF_Currency__c = 'USD';
            
            claimListToBeProcessed.add(indiaClaim);
            claimListToBeProcessed.add(indiaClaim2);
            
            Database.insert(claimListToBeProcessed);
            
            Core_MDF_Payment_Run__c payRunRecord = new Core_MDF_Payment_Run__c();
            payRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(2);
            payRunRecord.Core_MDF_Geo_Txt__c = 'ASMO';
            payRunRecord.Core_MDF_Program_Id__c  = cp1.Id;
            Database.insert(payRunRecord); 
            payRunRecord.Core_MDF_Program_Id__c= null;
            Database.update(payRunRecord);
            Core_MDF_Payment_Run__c uptdPrun = [Select Core_MDF_ErrorDetails_Txt__c From Core_MDF_Payment_Run__c where Id =: payRunRecord.Id LIMIT 1];
            System.assertNotEquals(uptdPrun.Core_MDF_ErrorDetails_Txt__c,'');
            
            Core_MDF_Payment_Run__c payRunRecord1 = new Core_MDF_Payment_Run__c();
            payRunRecord1.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(20);
            payRunRecord1.Core_MDF_Geo_Txt__c = 'ASMO';
            payRunRecord1.Core_MDF_Program_Id__c  = cp1.Id;
            Database.insert(payRunRecord1);
            payRunRecord1.Core_MDF_ScheduleRun_Dtm__c = DateTime.Now().addMinutes(10);
            Database.update(payRunRecord1);
            Database.delete(payRunRecord1);
        }  
        Test.stopTest();      
    }
    
    // Test method for restrict upload content file  
    @isTest  
    static void testRestrictUploadPaymentFile(){
        Core_MDF_Payment_Run__c payRunRecord = new Core_MDF_Payment_Run__c();
        try{
            Test.startTest();
            ChannelProgram cp = [SELECT ID From ChannelProgram where Name = 'Client Co-Marketing Fund'];
            User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
            User payAdmUser = [SELECT Id,Email from User where Email='testPayment@example.com' limit 1];
            User claimCaseUser = [SELECT Id,Email from User where Email='testreviewer@example.com' limit 1];
            
            PartnerFundRequest indiaActivity = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title='indiaActivity' limit 1];
            
            Core_MDF_Bank__c indiaBank = [Select ID from Core_MDF_Bank__c limit 1];
             
            System.runAs(claimCaseUser){
                PartnerFundClaim indiaClaim = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                       indiaActivity.Id, 
                                                                                       indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                                                       101, 
                                                                                       indiaActivity.Core_MDF_Start_Date__c, indiaBank.ID, false);
                indiaClaim.Core_MDF_Currency__c = 'USD';
                Database.insert(indiaClaim);
            }
            System.runAs(payAdmUser){
                payRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(2);
                payRunRecord.Core_MDF_Geo_Txt__c = 'ASMO';
                payRunRecord.Core_MDF_Program_Id__c  = cp.Id;
                Database.insert(payRunRecord);
            } 
            //Test.stopTest();
            System.runAs(sysAdminUser){
                String finalCsvStringWithHeader = 'Functionality Name \n' + 'Payment \n';
                blob csvBlob = Blob.valueOf(finalCsvStringWithHeader);
                String csvBinaryFile = EncodingUtil.base64Encode(csvBlob);
                
                ContentVersion contentVersion = new ContentVersion();
                contentVersion.ContentLocation = 'S';
                contentVersion.PathOnClient = 'Payment.csv';
                contentVersion.Title = 'Payment';
                contentVersion.VersionData = EncodingUtil.base64Decode(csvBinaryFile);
                insert contentVersion;
                
                Id contentDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVersion.Id].ContentDocumentId;
                
                ContentDocumentLink contentDocLink = new ContentDocumentLink();
                contentDocLink.ContentDocumentId = contentDocId;
                contentDocLink.LinkedEntityId = payRunRecord.Id;
                contentDocLink.ShareType = 'V';
                insert contentDocLink;                
            }
            Test.stopTest();
        }catch(Exception e){
            System.assertNotEquals(null,e);
        }
    }
    

    // Test method to test offset Adjustment with Payment Due claims only
    @isTest static void testAdjustmentGreaterthanPDClaim(){
        Test.startTest(); 
        ChannelProgram cp = [SELECT ID From ChannelProgram where Name = 'Client Co-Marketing Fund'];
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User payAdmUser = [SELECT Id,Email from User where Email='testPayment@example.com' limit 1];
        User claimCaseUser = [SELECT Id,Email from User where Email='testreviewer@example.com' limit 1];
        
        PartnerFundRequest indiaActivity = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title='indiaActivity' limit 1];
        
        Core_MDF_Bank__c indiaBank = [Select ID from Core_MDF_Bank__c limit 1];
        
        List<PartnerFundClaim> claimListToBeProcessed = new List<PartnerFundClaim>();
        List<PartnerFundClaim> claimListToBeUpdated = new List<PartnerFundClaim>();
        //PD Claim - Amount - 5000
        
        PartnerFundClaim indiaClaim = Core_MDF_CCP_TestDataUtility.createClaim('India Claim New', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                               indiaActivity.Id, 
                                                                               indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                                               10000, 
                                                                               indiaActivity.Core_MDF_Start_Date__c, indiaBank.ID, false);
        indiaClaim.Core_MDF_Currency__c = 'USD';
        indiaClaim.Core_MDF_Taxes_Local__c = 0;
        //PAF Claim  - Amount - 11000
        PartnerFundClaim indiaClaim2 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim New 1', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                indiaActivity.Id, 
                                                                                indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                                                22000, 
                                                                                indiaActivity.Core_MDF_Start_Date__c, indiaBank.ID, false);
        
        
        indiaClaim2.Core_MDF_Currency__c = 'USD';        
        indiaClaim2.Core_MDF_Taxes_Local__c = 0;
        
        claimListToBeProcessed.add(indiaClaim);
        claimListToBeProcessed.add(indiaClaim2);
        System.runAs(sysAdminUser){
            Database.insert(claimListToBeProcessed);
        }
        PartnerFundClaim pfc = [Select Id, Amount,Core_MDF_Status__c from PartnerFundClaim where Title = 'India Claim New'];
        pfc.Core_MDF_Status__c = 'Payment Due';
        PartnerFundClaim pfc1 = [Select Id, Amount,Core_MDF_Status__c from PartnerFundClaim where Title = 'India Claim New 1'];
        pfc1.Core_MDF_Status__c = 'Pending Available Fund';
        claimListToBeUpdated.add(pfc);
        claimListToBeUpdated.add(pfc1);
         System.runAs(sysAdminUser){
            Database.update(claimListToBeUpdated);
        }
        System.runAs(claimCaseUser){
            Core_MDF_Adjustment_Request__c adjustment1 = new Core_MDF_Adjustment_Request__c();          
            adjustment1.Core_MDF_Reference_Claim_Nbr__c = indiaClaim.Id;
            adjustment1.Core_MDF_Amount_Amt__c = 10;
            adjustment1.Core_MDF_Reason_Cd__c = 'Claim Review Results (Negative)';
            
            Database.insert(adjustment1);
        }
        System.runAs(sysAdminUser){
            Core_Trigger_Executions__c setting = new Core_Trigger_Executions__c();
            setting.Core_Active__c = true;
            setting.Core_Class_Name__c = 'Core_MDF_AdjustmentClaimOffsetProcess';
            setting.Core_Description__c = 'Demo Description';
            setting.Core_Object__c = 'Core_MDF_Payment_Run__c';
            setting.Core_Trigger_Events__c = 'after insert';
            setting.name = 'Core_MDF_AdjustmentClaimOffsetProcess';
            insert setting;
        }
        System.runAs(sysAdminUser){
            Core_MDF_Payment_Run__c payRunRecord = new Core_MDF_Payment_Run__c();
            payRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(2);
            payRunRecord.Core_MDF_Geo_Txt__c = 'ASMO';
            payRunRecord.Core_MDF_Program_Id__c  = cp.Id;
            Database.insert(payRunRecord);
            System.assertNotEquals(payRunRecord.Id,null);
        }
        Test.stopTest();    
    }
}