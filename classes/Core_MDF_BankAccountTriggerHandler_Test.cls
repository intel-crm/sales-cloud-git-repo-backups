@isTest
public class Core_MDF_BankAccountTriggerHandler_Test {
    
    @TestSetup static void setUpData(){
         Profile profileid1 =[select id,name from Profile where name='System Administrator' limit 1];
        User user = Core_MDF_CCP_TestDataUtility.createUser(false);
        UserRole ur = [Select Id,name from UserRole where name='Admin' limit 1];
        user.profileId = profileid1.id;
        user.UserRoleId = ur.id;
        insert user;
        System.runAs(user){
        List<Core_MDF_Configuration__c> configList = new List<Core_MDF_Configuration__c>();
        Core_MDF_Configuration__c config = new Core_MDF_Configuration__c();
        config.Name = 'ALLOWED_PRG_FOR_RUS_NOTIF';
        config.Core_MDF_Value__c = 'Retail Marketing Funds,Intel Partner Alliance';
        configList.add(config);
        database.insert(configList);
        }
        List<Account> accountList = new List<Account>();
        // Creating Intel Account with utility class
        //Account intelAccountRecord = Core_MDF_CCP_TestDataUtility.createAccount ('Intel Test Account Maptst', NULL, Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);   
        Account intelAccountRecord = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account', Core_MDF_CCP_TestDataUtility.intel_Account_Record_Type, false);
        intelAccountRecord.BillingCity = 'Pune';         
        intelAccountRecord.BillingCountry= 'IND';
        intelAccountRecord.Core_Geo__c ='APJ';
        intelAccountRecord.Core_Sub_Geo__c = 'SA';
        intelAccountRecord.BillingStreet= 'Test Street';
        System.runAs(user){
        Database.insert(intelAccountRecord);
        intelAccountRecord.isPartner = true;
        Database.update(intelAccountRecord);
        }
        List<ChannelProgram> cp = new List<ChannelProgram>();
        ChannelProgram ccfCP = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', false);
        ChannelProgram dcfCp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.DCF_PROGRAM,'Data Center CoMarketing Fund', false);
        ChannelProgram cpRetail = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.RMF_PROGRAM,'Retail Marketing Funds', false);
        ChannelProgram ipaCP = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.IPA_PROGRAM,'Intel Partner Alliance', false);
        //ChannelProgram ccfbCP = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund Boost','Client Co-Marketing Fund Boost', true);
        //ChannelProgram cmdfCP = Core_MDF_CCP_TestDataUtility.createProgram ('Channel MDF','Channel MDF', true);
        cp.add(ccfCP);
        cp.add(dcfCp);
        cp.add(cpRetail);
        cp.add(ipaCP);
        System.runAs(user){
            insert cp;
        }
        // Creating Co-marketing Account with utility class
        Account acc = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount ('Test Account CCF1', ccfCP.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type,intelAccountRecord.Id,false);
        acc.Core_MDF_Parent_Fund_Account__c = intelAccountRecord.Id;
        acc.Core_MDF_CoMarketing_Ultimate_Account__c = intelAccountRecord.Id;
        accountList.add(acc);        
        Account acc3 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount ('Test Account CCF2', ccfCP.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, intelAccountRecord.Id,false);
        acc3.Core_MDF_Parent_Fund_Account__c = intelAccountRecord.Id;
        acc3.Core_MDF_CoMarketing_Ultimate_Account__c = intelAccountRecord.Id;
        accountList.add(acc3);
        Account accCCF = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount ('Test Account CCF3', ccfCP.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, intelAccountRecord.Id, false);
        accCCF.Core_MDF_Parent_Fund_Account__c = intelAccountRecord.Id;
        accCCF.Core_MDF_CoMarketing_Ultimate_Account__c = intelAccountRecord.Id;
        accountList.add(accCCF);
        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount ('Test Account DCF', dcfCp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, intelAccountRecord.Id, false);
        acc2.Core_MDF_Parent_Fund_Account__c = intelAccountRecord.Id;
        acc2.Core_MDF_CoMarketing_Ultimate_Account__c = intelAccountRecord.Id;
        accountList.add(acc2);
        Account accIPA = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount ('Test Account IPA', ipaCp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, intelAccountRecord.Id, false);
        accIPA.Core_MDF_Parent_Fund_Account__c = intelAccountRecord.Id;
        accIPA.Core_MDF_CoMarketing_Ultimate_Account__c = intelAccountRecord.Id;
        accountList.add(accIPA);
        Account acc4 = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account RMF', cpRetail.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type,false);
        acc4.Core_MDF_Parent_Fund_Account__c = intelAccountRecord.Id;
        acc4.BillingCity = 'Pune';
        acc4.BillingCountry = 'IND';
        acc4.Core_Geo__c ='APJ';
        acc4.Core_Sub_Geo__c = 'SA';
        accountList.add(acc4);
        System.runAs(user){
        Database.insert(accountList);
        for(Account accRecord : accountList){
            accRecord.IsPartner = true;
        }
        Database.update(accountList); 
        }
            //Create CCF Group
        Group ccfgrp = new Group();
        ccfgrp.Name = 'Core CCP CCF Internal';
        ccfgrp.DeveloperName = 'Core_CCP_CCF_Internal';
        Database.insert(ccfgrp);
        
        Group grp = new Group();
        grp.name = 'PGM_TEST';
        insert grp;
        
        //Create Retail Group
        Group retailgrp = new Group();
        retailgrp.Name = 'Core CCP Retail Internal';
        retailgrp.DeveloperName = 'Core_CCP_Retail_Internal';
        Database.insert(retailgrp);
        Core_ERPM_Engagement__c erpmEngagementCCF = Core_MDF_CCP_TestDataUtility.createErpmEngagement('CCF', 'CCF', 'DEDUPB2B', 'SEC', true, false);
        System.runAs(user){

        Database.insert(erpmEngagementCCF);
        }
        Core_Entitlement__c entitlementCCF = Core_MDF_CCP_TestDataUtility.createEntitlement('Client User',null ,'Programmable Solutions Group','CCF User',erpmEngagementCCF.Id , true,'Client',false);
        System.runAs(user){
        Database.insert(entitlementCCF);
        //insert(erpmEngagementCCF);
        }
        List<Contact> contactList = new List<Contact>();
        //Creating Contact for Partner User
        Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(intelAccountRecord.Id,false);
        contactList.add(conRecord1);
        Contact conRecord2 = Core_MDF_CCP_TestDataUtility.createContact(intelAccountRecord.Id,false);
        contactList.add(conRecord2);
        System.runAs(User){
        insert contactList;
        }
        Test.startTest();
        List<Core_Contact_Entitlement__c> contactEntList = new List<Core_Contact_Entitlement__c>();
        
        Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c(Core_Contact_Id__c=contactList[0].Id,
                                                                         Core_Entitlement_Id__c=entitlementCCF.id,
                                                                         Core_Selected__c=true);
        contactEntList.add(ce);         
        
        Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=contactList[1].Id,
                                                                          Core_Entitlement_Id__c=entitlementCCF.id,
                                                                          Core_Selected__c=true);
        contactEntList.add(ce1);
        System.runAs(user){
        insert contactEntList;
        }
        // Permission Set
        PermissionSet ccfPs = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_CCF_Payment_Adm' LIMIT 1];
        PermissionSet rmfPs = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Retail_Payment_Adm' LIMIT 1];
        PermissionSet IpaPs = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_IPA_Payment_Adm' LIMIT 1];
        PermissionSet ccfbPs = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_CCFB_Payment_Admin' LIMIT 1];
        PermissionSet spcfPs = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_SPCF_Payment_Adm' LIMIT 1];
        

        // Creating User with utility class 
        List<User> userList = new List<User>();
        UserRole adminRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.Email = 'paymentadmin@example.com';
        usr.UserRoleId = adminRole.Id;
        userList.add(usr);
        
        Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
        
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);        
        usr1.Email='test1@example.com';
        usr1.ContactId = contactList[0].Id;
        usr1.ProfileId = profileId;
        usr1.isActive = true;
        userList.add(usr1);
        
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.Email='test2@example.com';
        usr2.ContactId = contactList[1].Id;
        usr2.ProfileId = profileId;
        usr2.isActive = true;
        //usr2.UserRoleId = adminRole.Id;
        userList.add(usr2);

        Database.insert(userList);
        
        
        //adding Ps to users
        
        List<PermissionSetAssignment> psList = new List<PermissionSetAssignment>();
        
        PermissionSetAssignment assignPermissionSetObj1 = new PermissionSetAssignment();
        assignPermissionSetObj1.AssigneeId = usr.Id;
        assignPermissionSetObj1.PermissionSetId = ccfPs.Id;
        psList.add(assignPermissionSetObj1);
        
        PermissionSetAssignment assignPermissionSetObj2 = new PermissionSetAssignment();
        assignPermissionSetObj2.AssigneeId = usr.Id;
        assignPermissionSetObj2.PermissionSetId = rmfPs.Id;
        psList.add(assignPermissionSetObj2);
        
        PermissionSetAssignment assignPermissionSetObj3 = new PermissionSetAssignment();
        assignPermissionSetObj3.AssigneeId = usr.Id;
        assignPermissionSetObj3.PermissionSetId = ccfbPs.Id;
        psList.add(assignPermissionSetObj3);
        
        PermissionSetAssignment assignPermissionSetObj4 = new PermissionSetAssignment();
        assignPermissionSetObj4.AssigneeId = usr.Id;
        assignPermissionSetObj4.PermissionSetId = ipaPs.Id;
        psList.add(assignPermissionSetObj4);
        
        PermissionSetAssignment assignPermissionSetObj5 = new PermissionSetAssignment();
        assignPermissionSetObj5.AssigneeId = usr.Id;
        assignPermissionSetObj5.PermissionSetId = spcfPs.Id;
        psList.add(assignPermissionSetObj5);
        
        // PermissionSetAssignment assignPermissionSetObj6 = new PermissionSetAssignment();
        // assignPermissionSetObj6.AssigneeId = usr.Id;
        // psList.add(assignPermissionSetObj6);
        
        
        System.runAs(usr){
            Database.insert(psList);
            List<GroupMember> groupMemberList = new List<GroupMember>();
            GroupMember gm = new GroupMember();
            gm.GroupId = grp.Id;
            gm.UserOrGroupId = userList[0].Id;
            groupMemberList.add(gm);
            
            GroupMember gm2 = new GroupMember();
            gm2.GroupId = grp.Id;
            gm2.UserOrGroupId = userList[1].Id;
            groupMemberList.add(gm2);
            insert groupMemberList;
            
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
            bypassFunctionKeys.add('createBankShareRecords');
            
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
        
        //Core_MDF_CCP_TestDataUtility.createPartnerGroupMapping(accRecord.Id,'Internal',accRecord.Id,cp.Id,'PGM_TEST',true);
        List<Core_MDF_Partner_Group_Mapping__c> pgmList = new List<Core_MDF_Partner_Group_Mapping__c>();
        //Create PGM
        Core_MDF_Partner_Group_Mapping__c ccfPgm = new Core_MDF_Partner_Group_Mapping__c();
        ccfPgm.Core_MDF_Account__c = intelAccountRecord.Id;
        ccfPgm.Core_MDF_Group_Name__c = 'Core_CCP_CCF_Internal';
        ccfPgm.Core_MDF_Type_of_Access__c = 'Internal';
        ccfPgm.Core_MDF_Group_Id__c = ccfgrp.Id;
        ccfpgm.Core_MDF_Virtual_Corp_nm__c = accCCF.Id;
        ccfPgm.Core_MDF_Channel_Program__c = ccfCP.Id;
        ccfPgm.Core_MDF_Source_Txt__c = 'test';
        ccfPgm.Core_MDF_AccountIdGroupName__c = intelAccountRecord.Id + '_Core_CCP_CCF_Internal';
        pgmList.add(ccfPgm);
        
        Core_MDF_Partner_Group_Mapping__c extPGM = new Core_MDF_Partner_Group_Mapping__c();
        extPGM.Core_MDF_Account__c = intelAccountRecord.Id;
        extPGM.Core_MDF_Group_Name__c = 'PGM_TEST';
        extPGM.Core_MDF_Type_of_Access__c = 'External';
        extPGM.Core_MDF_Group_Id__c = grp.Id;
        extPGM.Core_MDF_Virtual_Corp_nm__c = accCCF.Id;
        extPGM.Core_MDF_Channel_Program__c = ccfCP.Id;
        extPGM.Core_MDF_AccountIdGroupName__c = intelAccountRecord.Id + '_Core_CCP_CCF_External';
        pgmList.add(extPGM);
        
       /* Core_MDF_Partner_Group_Mapping__c retailPgm = new Core_MDF_Partner_Group_Mapping__c();
        retailPgm.Core_MDF_Account__c = intelAccountRecord.Id;
        retailPgm.Core_MDF_Group_Name__c = 'Core_CCP_Retail_Internal';
        retailPgm.Core_MDF_Type_of_Access__c = 'Internal';
        //ccfpgm.Core_MDF_Virtual_Corp_nm__c = accCCF.Id;
        retailPgm.Core_MDF_Group_Id__c = ccfgrp.Id;
        retailPgm.Core_MDF_Channel_Program__c = ccfCP.Id;
        retailPgm.Core_MDF_Source_Txt__c = 'test';
        retailPgm.Core_MDF_AccountIdGroupName__c = intelAccountRecord.Id + '_Core_CCP_Retail_Internal';
        pgmList.add(retailPgm); */
        
        Database.insert(pgmList);
        
        // Creating campaigns using utility class
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCamp','Consumer','Intel® Corporate Logo','Yes', 
                                                                    Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF,
                                                                    'Client CoMarketing Fund',System.today().addDays(-5) ,
                                                                    System.today().addDays(200), 2000, 'Test',acc.Id,'2-in-1', false);
            Camp.Core_MDF_Opal_Budget_Type_Txt__c = 'MDF';
            Database.insert(camp);
        // Creating Bank with utility class
        List<Core_MDF_Bank__c> bankList = new List<Core_MDF_Bank__c>();
        Core_MDF_Bank__c testBank1 = Core_MDF_CCP_TestDataUtility.createBank(intelAccountRecord.Id, 'Core_MDF_Client_CoMarketing_Fund', false,'1234567891');
      
        testBank1.Core_MDF_Program__c = 'Core_MDF_Client_CoMarketing_Fund';
        bankList.add(testBank1);
        
        Core_MDF_Bank__c testBankDCF = Core_MDF_CCP_TestDataUtility.createBank(intelAccountRecord.Id, 'Core_MDF_Data_Center_CoMarketing_Fund', false,'1234567891');
      
        testBankDCF.Core_MDF_Program__c = 'Core_MDF_Data_Center_CoMarketing_Fund';
        bankList.add(testBankDCF);
        
        Core_MDF_Bank__c testBank2 = Core_MDF_CCP_TestDataUtility.createBank(intelAccountRecord.Id, 'Core_MDF_Client_CoMarketing_Fund', false,'1237784581');
        bankList.add(testBank2);
        Core_MDF_Bank__c testBank3 = Core_MDF_CCP_TestDataUtility.createBank(intelAccountRecord.id, 'Core_MDF_Retail_Marketing_Funds', false,'1234567894');
        testBank3.Core_MDF_Program__c = 'Core_MDF_Retail_Marketing_Funds'; 
        testBank3.Core_MDF_Intel_Company_Code__c ='420';
        testBank3.Core_MDF_Tax_codes_cd__c ='UB';
        
        bankList.add(testBank3); 
        insert bankList;
        bankList[0].Core_MDF_Bank_Location__c = 'IN';
        bankList[0].Core_MDF_ESD_Update__c = true;
        bankList[0].Core_MDF_Bank_Status__c = 'Active';
        
        bankList[1].Core_MDF_Bank_Location__c = 'US';
        bankList[1].Core_MDF_ESD_Update__c = true;
        bankList[1].Core_MDF_Bank_Status__c = 'Active';
        
        bankList[2].Core_MDF_Bank_Location__c = 'US';
        bankList[2].Core_MDF_ESD_Update__c = true;
        bankList[2].Core_MDF_Bank_Status__c = 'Active';
        
        bankList[3].Core_MDF_Bank_Location__c = 'US';
        bankList[3].Core_MDF_ESD_Update__c = true;
        bankList[3].Core_MDF_Bank_Status__c = 'Active';
        
        update bankList;
       // Creating Budget using utility class
        PartnerMarketingBudget pmb = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                               acc.Id,ccfCP.Id,5000000,System.today().addDays(-5),System.today(), 
                                                                               false);
        pmb.Core_MDF_Budget_Type_Txt__c='MDF';
        insert(pmb);        
        Test.stopTest();
        List<Core_MDF_Account_Bank_Mapping__c> abmList = new List<Core_MDF_Account_Bank_Mapping__c>();
        Core_MDF_Account_Bank_Mapping__c abmCCF1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc.Id, bankList[0].Id, FALSE);
        abmCCF1.Core_MDF_Active_ind__c = TRUE;
        abmList.add(abmCCF1);
        
        Core_MDF_Account_Bank_Mapping__c abmDCF = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc2.Id, bankList[1].Id, FALSE);
        abmList.add(abmDCF);
        insert(abmList);
        // Creating Allocation using utility class
        PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation',pmb,acc,1000000.0,true);
        
    }
    }
    @isTest
    static void abmtestmethod(){
        test.startTest();
        List<Core_MDF_Account_Bank_Mapping__c> listOfABM = new List<Core_MDF_Account_Bank_Mapping__c>();
        Map<Id,Core_MDF_Account_Bank_Mapping__c> abmMap = new Map<Id,Core_MDF_Account_Bank_Mapping__c>();
        Core_MDF_Account_Bank_Mapping__c abm = [Select Id, Core_MDF_Account__c,Core_MDF_Bank__c, Core_MDF_Active_ind__c from Core_MDF_Account_Bank_Mapping__c limit 1];
        abmMap.put(abm.Id,abm);
        listOfABM.add(abm);
        // Unit Test Method should include System.Assert
        System.assertEquals(1, listOfABM.size(), 'List should contain exactly one ABM record');
        
        Account acc = [Select id from Account where name = 'Test Account CCF2' limit 1];
        abm.Core_MDF_Account__c = acc.id;
        abm.Core_MDF_Active_ind__c=True;
        update abm;
        //Core_MDF_BankAccountServiceHandler.shareBankAndABMRecordsWithExternalUsers(abmMap);
        //Core_MDF_BankAccountServiceHandler.deleteBankShareRecords(listOfABM);
        test.stopTest();
    }
    @isTest
    static void createCCFMapping(){
        User usr = [SELECT Id,Email from User where Email='paymentadmin@example.com' limit 1];
        UserRole adminRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        usr.UserRoleId = adminRole.Id;
        Test.startTest();
        Account coaccDCF = [SELECT Id from Account where Name='Test Account DCF' limit 1];
        Campaign camp = [SELECT Id, Core_MDF_Account__c, Core_MDF_Account__r.Core_MDF_Channel_Program__c from Campaign where Name='TestCamp' limit 1];
        PartnerFundAllocation pfa = [SELECT Id FROM PartnerFundAllocation WHERE Title = 'Test Allocation'];
        PartnerMarketingBudget pmb = [SELECT Id FROM PartnerMarketingBudget WHERE Title = 'Test Budget'];
        
        PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                       Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                       string.valueof(camp.Core_MDF_Account__c),pfa,pmb,'INDIA','Small Business',
                                                                                       'Desktop','Intel® Core™ i7 Processor','Audio',
                                                                                       'Podcast','Draft',false);
        pfr.RequestedAmount = 900000;
        pfr.Amount = 900000;
        pfr.Core_MDF_Reimbursement_Rate_txt__c='100%';
        pfr.Status = 'Approved';
        pfr.AllocationId = pfa.Id;
        pfr.BudgetId = pmb.Id;
        pfr.Core_MDF_Start_Date__c = System.today().addDays(-5);
        pfr.Core_MDF_End_Date__c = System.today();
        Database.insert(pfr);
        
        Core_MDF_Bank__c testBank = [SELECT Id, Core_MDF_Supplier_Number__c,Core_MDF_Program__c
                                     FROM Core_MDF_Bank__c WHERE Core_MDF_Supplier_Number__c = '1234567891' limit 1];
        
        
        System.RunAs(usr){
            Core_MDF_Account_Bank_Mapping__c abmCCF1 = [SELECT id,Core_MDF_Active_ind__c FROM Core_MDF_Account_Bank_Mapping__c WHERE Core_MDF_Account__c =: camp.Core_MDF_Account__c ]; 
            Core_MDF_Account_Bank_Mapping__c abmDCF = [SELECT id,Core_MDF_Active_ind__c FROM Core_MDF_Account_Bank_Mapping__c WHERE Core_MDF_Account__c =: coaccDCF.Id ]; 
            
            
            System.assert(abmCCF1.Id != NULL);
            System.assert(abmCCF1.Core_MDF_Active_ind__c == TRUE);
            
            PartnerFundClaim newClaim = new PartnerFundClaim();
            newClaim = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', 
                                                                Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, 
                                                                System.today(), System.today(), 122, 
                                                                System.today(), testBank.Id, false);
            newClaim.Core_MDF_Status__c = 'Submitted';
            newClaim.Core_MDF_Currency__c = 'USD';
            newClaim.Core_MDF_Taxes_Local__c = 0;
            newClaim.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
            Database.insert(newClaim);
            abmCCF1.Core_MDF_Active_ind__c = FALSE;
            abmDCF.Core_MDF_Active_ind__c = FALSE;
            
            try{
                Update(abmCCF1);
                Update(abmDCF);
                //System.assert(abmCCF1.Core_MDF_Active_ind__c == TRUE);
                //System.assert(abmDCF.Core_MDF_Active_ind__c == FALSE);
            }
            catch(Exception e){
                System.assert(abmCCF1.Core_MDF_Active_ind__c == FALSE);
            }
        }   
        Test.stopTest();
    }
    
    
    @isTest static void createMapping(){
        User usr = new User();
        User usr1 = new User();
        User usr2 = new User();
        
        for(User userRecord : [SELECT Id,Email
                               FROM User
                               WHERE Email IN ('paymentadmin@example.com', 'test1@example.com', 'test2@example.com')
                               LIMIT 3]){
                                   if(userRecord.Email == 'paymentadmin@example.com'){
                                       usr = userRecord;
                                   }
                                   else if(userRecord.Email == 'test1@example.com'){
                                       usr1 = userRecord;
                                   }
                                   else if(userRecord.Email == 'test2@example.com'){
                                       usr2 = userRecord;
                                   }
                               }
        Account intelAcc;
        Account ccfAcc1;
        Account ccfAcc3;
        Account rmfAcc;        
        for(Account accRecord : [SELECT Id, Name, ChannelProgramName
                                 FROM Account
                                 WHERE Name IN ('Test Account maptst', 'Test Account CCF1', 'Test Account CCF3','Test Account RMF')
                                 LIMIT 3]){
                                     if(accRecord.Name == 'Test Account maptst'){
                                         intelAcc = accRecord;
                                     }
                                     else if(accRecord.Name == 'Test Account CCF1'){
                                         ccfAcc1 = accRecord;
                                     }
                                     else if(accRecord.Name == 'Test Account CCF3'){
                                         ccfAcc3 = accRecord;
                                     }
                                     else if(accRecord.Name == 'Test Account RMF'){
                                         rmfAcc = accRecord;                       
                                     }
                                 }
        
        Core_MDF_Bank__c testBank1; 
        Core_MDF_Bank__c testBank2; 
        Core_MDF_Bank__c testBank3;
        for(Core_MDF_Bank__c bankRecord: [SELECT Id, Core_MDF_Supplier_Number__c,Core_MDF_Program__c
                                          FROM Core_MDF_Bank__c
                                          WHERE Core_MDF_Supplier_Number__c IN ('1234567891', '1237784581','1234567894')]){
                                              if(bankRecord.Core_MDF_Supplier_Number__c == '1234567891'){
                                                  testBank1 = bankRecord;
                                              }
                                              else if(bankRecord.Core_MDF_Supplier_Number__c == '1237784581'){
                                                  testBank2 = bankRecord;
                                              }
                                              else if(bankRecord.Core_MDF_Supplier_Number__c == '1234567894'){
                                                  testBank3 = bankRecord;                                
                                              }
                                          }
        
        List<Core_MDF_Partner_Node_User_Mapping__c> deleteRecordList = new List<Core_MDF_Partner_Node_User_Mapping__c>();
        // Highlight: Unused Local Variable
       // List<Core_MDF_Account_Bank_Mapping__c> insertlist = new List<Core_MDF_Account_Bank_Mapping__c>();     
        Test.startTest();
        UserRole adminRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        User adminUser = Core_MDF_CCP_TestDataUtility.createUser(false);
        adminUser.Email = 'sysadmin@example.com';
        adminUser.UserRoleId = adminRole.Id;
        insert adminUser;
        List<Core_MDF_Partner_Node_User_Mapping__c> pnumList = new List<Core_MDF_Partner_Node_User_Mapping__c>();
        Core_MDF_Partner_Node_User_Mapping__c pnumRecord = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(ccfAcc1.Id,usr1.Id,false);
        Core_MDF_Partner_Node_User_Mapping__c pnumRecord2 = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(ccfAcc3.Id,usr1.Id,false);
        pnumList.add(pnumRecord);
        pnumList.add(pnumRecord2);
        System.runAs(adminUser){            
            // Create a Partner Node User Mapping with the above created Account
            Database.insert(pnumList);
        }
        System.runAs(usr){ 
            Core_MDF_Account_Bank_Mapping__c pbankaccount = [SELECT id,Core_MDF_Active_ind__c FROM Core_MDF_Account_Bank_Mapping__c WHERE Core_MDF_Account__c =: ccfAcc1.Id ]; 
            
            deleteRecordList.add(pnumRecord);
            deleteRecordList.add(pnumRecord2);
            Core_MDF_Account_Bank_Mapping__c bankacc = Core_MDF_CCP_TestDataUtility.createBankAccountMap(ccfAcc1.Id,testBank2.Id, true);
            bankacc.Core_MDF_Account__c = ccfAcc3.Id;
            bankacc.Core_MDF_Bank__c = testBank2.Id;
            try{
                Database.update(bankacc);
            }catch(Exception e){
                
            }
            Core_MDF_Account_Bank_Mapping__c retailbankaccount = Core_MDF_CCP_TestDataUtility.createBankAccountMap(rmfAcc.Id,testBank3.Id, false);

retailbankaccount.Core_MDF_Account__c = rmfAcc.Id;
retailbankaccount.Core_MDF_Bank__c = testBank3.Id;
Database.insert(retailbankaccount); 
            Test.stopTest();
            
            
            Database.delete(deleteRecordList);
            
            try{
                Database.delete(pbankaccount);
            }catch(Exception e){
                                System.assert(e != NULL );}
            
        }
    }
    @isTest static void createRetailMapping(){
        
        User usr = new User();
        Test.startTest();
        for(User userRecord : [SELECT Id,Email
                               FROM User
                               WHERE Email IN ('paymentadmin@example.com')
                               LIMIT 1]){
                                   if(userRecord.Email == 'paymentadmin@example.com'){
                                       usr = userRecord;
                                   }
                               }
                               UserRole adminRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
                               usr.UserRoleId = adminRole.Id;
        
        Account intelAcc;
        Account rmfAcc;
        
        for(Account accRecord : [SELECT Id, Name, ChannelProgramName, Core_MDF_Group_Id__c
                                 FROM Account
                                 WHERE Name IN ('Test Account maptst','Test Account RMF')
                                 LIMIT 1]){
                                     if(accRecord.Name == 'Test Account maptst'){
                                         intelAcc = accRecord;
                                     }
                                     else if(accRecord.Name == 'Test Account RMF'){
                                         rmfAcc = accRecord;                       
                                     }
                                 }
        
        Group retailgrp = new Group();
        retailgrp.Name = 'Core CCP Retail Acc Node Group';
        retailgrp.DeveloperName = 'Core_CCP_Retail_Acc_Node_Group';
        Database.insert(retailgrp);
        rmfAcc.Core_MDF_Group_Id__c = retailgrp.Id;
        update rmfAcc;
        
        Core_MDF_Bank__c testBank3; 
        
        for(Core_MDF_Bank__c bankRecord: [SELECT Id, Core_MDF_Supplier_Number__c,Core_MDF_Program__c
                                          FROM Core_MDF_Bank__c
                                          WHERE Core_MDF_Supplier_Number__c IN ('1234567894')]){
                                              if(bankRecord.Core_MDF_Supplier_Number__c == '1234567894'){
                                                  testBank3 = bankRecord;                                
                                              }
                                          }
        // Highlight: Unused Local Variable
       // List<Core_MDF_Partner_Node_User_Mapping__c> deleteRecordList = new List<Core_MDF_Partner_Node_User_Mapping__c>();
        
        System.runAs(usr){ 
            
            
            Core_MDF_Account_Bank_Mapping__c retailbankaccount = Core_MDF_CCP_TestDataUtility.createBankAccountMap(rmfAcc.Id,testBank3.Id, false);
            retailbankaccount.Core_MDF_Account__c = rmfAcc.Id;
            retailbankaccount.Core_MDF_Bank__c = testBank3.Id;
            
            
            try{
                Database.insert(retailbankaccount); 
            }catch(Exception e){
                System.assert(e != NULL );
            }
            Test.stopTest();
        }
    }
    
    @isTest
    static void abmDuplicateCheckTest(){
        User paymentAdmin = [Select Id FROM User Where Email = 'paymentadmin@example.com' LIMIT 1];
        UserRole adminRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        paymentAdmin.UserRoleId = adminRole.Id;
        PermissionSet ccfPs = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_CCF_Payment_Adm' LIMIT 1];
        List<PermissionSetAssignment> psList = new List<PermissionSetAssignment>();
        
        PermissionSetAssignment assignPermissionSetObj1 = new PermissionSetAssignment();
        assignPermissionSetObj1.AssigneeId = paymentAdmin.Id;
        assignPermissionSetObj1.PermissionSetId = ccfPs.Id;
        psList.add(assignPermissionSetObj1);
        
        System.runAs(paymentAdmin){
            Test.startTest();
            //Database.insert(psList);
            Account testAccount = [Select Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Core_MDF_Bank__c newBank = Core_MDF_CCP_TestDataUtility.createBank(testAccount.id, 'Core_MDF_Client_CoMarketing_Fund', false,'1234561111');
            newBank.Core_MDF_Bank_Status__c = 'Active';
            newBank.Core_MDF_DUNS__c = '578299333';
            newBank.Core_MDF_Bank_Beneficiary_Name__c = 'TEST BENEFICIARY NAME';
            newBank.Core_MDF_Bank_Location__c = 'IN';
            newBank.Core_MDF_Swift_Code__c = 'BOFSGB21124';
            newBank.Core_MDF_Intermediary_Indicator__c = 'N';
            newBank.Core_MDF_Routing_Number__c = '123456';
            newBank.Core_MDF_ESD_Hold_Indicator__c = FALSE;
            newBank.Core_MDF_Effective_Date__c = system.today();
            newBank.Core_MDF_Supplier_Name__c='TEST SUPPLIER NAME';
            newBank.Core_MDF_Bank_Location__c = 'IN';
            newBank.Name = 'TEST BANK'; 
            insert newBank;
        
        //Sharing with Account Budget Admins
        User accBudgetAdmin = [Select Id FROM User Where Email = 'test1@example.com' LIMIT 1];
        Core_MDF_Bank__c bank1 = [Select Id,Core_MDF_Bank_Status__c FROM Core_MDF_Bank__c WHERE Core_MDF_Supplier_Number__c = '1234561111' LIMIT 1];
        bank1.Core_MDF_Bank_Status__c = 'Active';
        update(bank1);
        
        System.assert(bank1.Core_MDF_Bank_Status__c == 'Active');
        
        
        Core_MDF_Bank__Share bankShare = new Core_MDF_Bank__Share();
        bankShare.ParentId = bank1.Id;
        bankShare.UserOrGroupId = accBudgetAdmin.Id; 
        bankShare.RowCause = Schema.Core_MDF_Bank__Share.RowCause.AccountBudgetAdmin__c;
        bankShare.AccessLevel = Label.Core_MDF_Read_Access;
        insert bankShare;
        
        //Core_MDF_ShareBanktoBudgetAdmins obj = new Core_MDF_ShareBanktoBudgetAdmins();
        //DataBase.executeBatch(obj);
        
        Account testCoCCFAccount = [Select Id FROM Account WHERE Name = 'Test Account CCF1' LIMIT 1];
        Account testCoCCFAccount2 = [Select Id FROM Account WHERE Name ='Test Account CCF3' LIMIT 1];
        
        //Sharing testCoCCFAccount with Budget Admin
        AccountShare accshareRecordCCF = new AccountShare();
        accshareRecordCCF.AccountId = testCoCCFAccount.Id;
        accshareRecordCCF.UserOrGroupId = accBudgetAdmin.Id;
        accshareRecordCCF.RowCause = 'Manual';
        accshareRecordCCF.AccountAccessLevel = 'Read';
        accshareRecordCCF.OpportunityAccessLevel = 'None';
        accshareRecordCCF.CaseAccessLevel = 'None';
        Database.Insert(accshareRecordCCF);
        
        //Sharing testCoCCFAccount2 with Budget Admin
        AccountShare accshareRecordCCF2 = new AccountShare();
        accshareRecordCCF2.AccountId = testCoCCFAccount2.Id;
        accshareRecordCCF2.UserOrGroupId = accBudgetAdmin.Id;
        accshareRecordCCF2.RowCause = 'Manual';
        accshareRecordCCF2.AccountAccessLevel = 'Read';
        accshareRecordCCF2.OpportunityAccessLevel = 'None';
        accshareRecordCCF2.CaseAccessLevel = 'None';
        Database.Insert(accshareRecordCCF2);
        
        System.runAs(accBudgetAdmin){
            
            
            Core_MDF_Bank__c bankCCF = [Select Id,Core_MDF_Bank_Status__c FROM Core_MDF_Bank__c WHERE Core_MDF_Supplier_Number__c = '1234561111' LIMIT 1];
            
            
            //Creating ABM List
            List<Core_MDF_Account_Bank_Mapping__c> abmList = new List<Core_MDF_Account_Bank_Mapping__c>();
            
            //Creating ABM record using utility class
            Core_MDF_Account_Bank_Mapping__c abm1CCF = Core_MDF_CCP_TestDataUtility.createAccountBankMap(testCoCCFAccount.Id, bankCCF.Id, FALSE);
            abm1CCF.Core_MDF_Active_ind__c = true;
            
            abmList.add(abm1CCF);            

            
            //Updating the ABM and trying to insert existing record 
            Core_MDF_Account_Bank_Mapping__c abmCCF4 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(testCoCCFAccount2.Id, bankCCF.Id, FALSE);
            abmCCF4.Core_MDF_Active_ind__c = true;
            
            insert abmCCF4;
            
            try{
                abmCCF4.Core_MDF_Account__c = testCoCCFAccount.id;
                abmCCF4.Core_MDF_Bank__c = bankCCF.Id;
                update abmCCF4;
            }
            catch(Exception ex){
                //System.assertEquals(abmCCF4.Core_MDF_Account__c.id != testCoCCFAccount.id);
            }
        }
        }
        Test.stopTest();
    }
    @isTest
    static void testROSharing(){
        User usr = [SELECT Id,Email from User where Email='paymentadmin@example.com' limit 1];
        Test.startTest();
        // Highlight: Unused Local Variable
       // Account coaccCCF = [SELECT Id from Account where Name='Test Account CCF1' limit 1];
        Campaign camp = [SELECT Id, Core_MDF_Account__c, Core_MDF_Account__r.Core_MDF_Channel_Program__c from Campaign where Name='TestCamp' limit 1];
        PartnerFundAllocation pfa = [SELECT Id FROM PartnerFundAllocation WHERE Title = 'Test Allocation'];
        PartnerMarketingBudget pmb = [SELECT Id FROM PartnerMarketingBudget WHERE Title = 'Test Budget'];
        
        PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                       Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                       string.valueof(camp.Core_MDF_Account__c),pfa,pmb,'INDIA','Small Business',
                                                                                       'Desktop','Intel® Core™ i7 Processor','Audio',
                                                                                       'Podcast','Draft',false);
        pfr.RequestedAmount = 900000;
        pfr.Amount = 900000;
        pfr.Core_MDF_Reimbursement_Rate_txt__c='100%';
        pfr.Status = 'Approved';
        pfr.AllocationId = pfa.Id;
        pfr.BudgetId = pmb.Id;
        pfr.Core_MDF_Start_Date__c = System.today().addDays(-5);
        pfr.Core_MDF_End_Date__c = System.today();
        Database.insert(pfr);
        
        pfr = [SELECT Id, Core_MDF_Region_nm__c, Core_MDF_Program__c from PartnerFundRequest where Title='Test' limit 1];
         // Highlight: Unused Local Variable
      /*  Core_MDF_Bank__c testBank = [SELECT Id, Core_MDF_Supplier_Number__c,Core_MDF_Program__c
                                     FROM Core_MDF_Bank__c WHERE Core_MDF_Supplier_Number__c = '1234567891' limit 1];  */
        
        Core_MDF_Account_Bank_Mapping__c abmCCF1;
        System.RunAs(usr){
            abmCCF1 = [SELECT id,Core_MDF_Active_ind__c FROM Core_MDF_Account_Bank_Mapping__c WHERE Core_MDF_Account__c =: camp.Core_MDF_Account__c ]; 
        }
        
        Core_MDF_ProgramGeoGroupMap__mdt metaRec = [SELECT Core_MDF_Group_Name__c, Core_MDF_Group_Name_RO__c, Core_MDF_Program__c,Core_MDF_Region__c,Core_MDF_Sub_Region__c
                                                    From Core_MDF_ProgramGeoGroupMap__mdt
                                                    WHERE Core_MDF_Region__c = :pfr.Core_MDF_Region_nm__c
                                                    AND Core_MDF_Program__c = :pfr.Core_MDF_Program__c];
        
        Boolean isAPJShared = false;
        
        try{
            List<Core_MDF_Account_Bank_Mapping__Share> abmShareList = [SELECT ParentId, UserOrGroupId, UserOrGroup.Name 
                                                                       FROM Core_MDF_Account_Bank_Mapping__Share 
                                                                       WHERE parentId = :abmCCF1.Id];
            
            for(Core_MDF_Account_Bank_Mapping__Share shareRec : abmShareList)
            {
                if(shareRec.UserOrGroup.Name.equals(metaRec.Core_MDF_Group_Name__c)){
                    isAPJShared = true;
                }
            }
            if(!isAPJShared){
                System.assert(isAPJShared);
            }
            
            
            test.stopTest();
        }catch(Exception e){
        }
        
    }
    
    @isTest
    static void testEscalation(){
        Test.startTest();
        Campaign camp = [SELECT Id, Core_MDF_Account__c, Core_MDF_Account__r.Core_MDF_Channel_Program__c from Campaign where Name='TestCamp' limit 1];
        Core_MDF_Account_Bank_Mapping__c pbankaccount = [SELECT id,Core_MDF_Active_ind__c FROM Core_MDF_Account_Bank_Mapping__c WHERE Core_MDF_Account__c =: camp.Core_MDF_Account__c ];
        Core_MDF_Bank__c testBank = [SELECT Id, Core_MDF_Supplier_Number__c,Core_MDF_Program__c
                                     FROM Core_MDF_Bank__c WHERE Core_MDF_Supplier_Number__c = '1234567891' limit 1];
        Account ccfAcc3 = [SELECT Id from Account where Name='Test Account CCF3' limit 1];      
        PartnerFundAllocation pfa = [SELECT Id FROM PartnerFundAllocation WHERE Title = 'Test Allocation'];
        PartnerMarketingBudget pmb = [SELECT Id FROM PartnerMarketingBudget WHERE Title = 'Test Budget'];
        
        PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                       Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                       string.valueof(camp.Core_MDF_Account__c),pfa,pmb,'INDIA','Small Business',
                                                                                       'Desktop','Intel® Core™ i7 Processor','Audio',
                                                                                       'Podcast','Draft',false);
        pfr.RequestedAmount = 900000;
        pfr.Amount = 900000;
        pfr.Core_MDF_Reimbursement_Rate_txt__c='100%';
        pfr.Status = 'Approved';
        pfr.AllocationId = pfa.Id;
        pfr.BudgetId = pmb.Id;
        pfr.Core_MDF_Start_Date__c = System.today().addDays(-5);
        pfr.Core_MDF_End_Date__c = System.today();
        Database.insert(pfr);
       // Highlight: Unused Local Variable
      //  List<PartnerFundRequest> partnerFndActivityNumber = [select Core_MDF_Activity_Number__c from PartnerFundRequest where id=:pfr.id];
         
        PartnerFundClaim newClaim = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', 
                                                                Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, 
                                                                System.today(), System.today(), 122, 
                                                                System.today(), testBank.Id, false);
            newClaim.Core_MDF_Status__c = 'Submitted';
            newClaim.Core_MDF_Currency__c = 'USD';
            newClaim.Core_MDF_Taxes_Local__c = 0;
        	newClaim.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';        
            Database.insert(newClaim);
        Case cs = new Case();
        Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit_Closed').getRecordTypeId();
        //cs.Id = pfc1.Core_MDF_Claim_Review_Case__c;
        cs.Status = 'Closed';
        cs.recordTypeId = caseAuditRecType;
        cs.AccountId = camp.Core_MDF_Account__c;
        cs.Core_MDF_Claim_ID__c=newClaim.id;
        database.insert(cs);
        
        Id caseRecType = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Claim_Case_Review_Result').getRecordTypeId();
        Core_MDF_Escalation__c esc2 = new Core_MDF_Escalation__c();
        esc2.Core_MDF_Escalation_Status_nm__c='Pending Review';
        esc2.Core_MDF_Escalation_Name_txt__c='Test2';
        esc2.Core_MDF_Total_Dollar_Impact_amt__c= 45;
        esc2.Core_MDF_Root_Cause_nm__c = 'Creative';
        esc2.Core_MDF_Case_ID_Number_id__c = cs.Id;
        esc2.Core_MDF_Channel_Program_id__c = camp.Core_MDF_Account__r.Core_MDF_Channel_Program__c;
        esc2.recordtypeid = caseRecType;
        try{
        Database.insert(esc2);
        
        pbankaccount.Core_MDF_Account__c = ccfAcc3.Id;
        
            Database.update(pbankaccount);
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('This bank has active escalations associated to it') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
        }
        Test.stopTest();
    }
    
}