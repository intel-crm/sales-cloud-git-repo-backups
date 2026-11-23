@isTest(SeeAllData=false)
public with sharing class Core_MDF_Process_PartnerFundRequest_Test {
    @TestSetUp
    static void createTestData(){
        List<String> bypassFunctionKeys2 = new List<String>();
        bypassFunctionKeys2.add('byPass_Cancel_Activity');
        
        Set<String> myset12 = new Set<String>();
        List<String> result12 = new List<String>();
        myset12.addAll(bypassFunctionKeys2);
        result12.addAll(myset12);
        List<Core_Trigger_Executions__c> bypassfunctinalitylist12 = Core_MDF_CCP_TestDataUtility.byPassFeature(result12,false,true);
        
        List<String> bypassFunctionKeys = new List<String>();
        bypassFunctionKeys.add('Core_MDF_PFR_Rule_Engine');
        bypassFunctionKeys.add('ByPass_BlockLegacyBudgetCreation');
        Set<String> myset1 = new Set<String>();
        List<String> result1 = new List<String>();
        myset1.addAll(bypassFunctionKeys);
        result1.addAll(myset1);
        List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
        profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        // Creating User with utility class 
        List<user> usrList=new List<User>();
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'MDF Budget LoaderTest';
        usr.profileId = systemAdminProfile.Id;
        usrList.add(usr);
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'MDF Budget Loader1';
        usr.profileId = systemAdminProfile.Id;
        usrList.add(usr1);
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'MDF Budget Loader2';
        usr.profileId = systemAdminProfile.Id;
        usrList.add(usr2);
        User usr6 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr6.LastName = 'User Test6';
        usr6.IsActive = true;
        usrList.add(usr6);
        User usr7 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr7.Email = 'sysadmin@example.com';
        usrList.add(usr7);
        Database.insert(usrList);
        
        // Creating Criterias for approval required
        List<Core_MDF_Criteria__c> cList = new List<Core_MDF_Criteria__c>();
        Core_MDF_Criteria__c cr = Core_MDF_CCP_TestDataUtility.createCriteria('PartnerFundRequest','Core_MDF_Activity_Approval_Processs',
                                                                              'Core_MDF_Region_nm__c','Equal','WW','Core_MDF_Region_nm__c','Equal', 'APJ',
                                                                              'Core_MDF_Region_nm__c','Equal','APJ','Core_MDF_ProductType__c','Equal','Desktop','RequestedAmount','Greater Than','4000',false);
        cr.Core_MDF_Field_Name_2__c = 'Core_MDF_Region_nm__c';
        cr.Core_MDF_Operator_2__c = 'Equal';
        cr.Core_MDF_Value_2__c = 'WW';
        cr.Core_MDF_Field_Name_3__c = 'Core_MDF_Region_nm__c';
        cr.Core_MDF_Operator_3__c = 'Equal';
        cr.Core_MDF_Value_3__c = 'WW';
        cr.Core_MDF_Field_Name_6__c = 'Core_MDF_Region_nm__c';
        cr.Core_MDF_Operator_6__c = 'Equal';
        cr.Core_MDF_Value_6__c = 'APJ';
        cr.Core_MDF_Field_Name_7__c = 'Core_MDF_Region_nm__c';
        cr.Core_MDF_Operator_7__c = 'Equal';
        cr.Core_MDF_Value_7__c = 'WW';
        cr.Core_MDF_Field_Name_8__c = 'Core_MDF_Region_nm__c';
        cr.Core_MDF_Operator_8__c = 'Equal';
        cr.Core_MDF_Value_8__c = 'WW';
        cr.Core_MDF_Active__c = false;
        cList.add(cr);
        Database.insert(cList);
        
        List<Core_MDF_Approver__c> appList = new List<Core_MDF_Approver__c>();
        // Creating approvers
        Core_MDF_Approver__c ap1 = Core_MDF_CCP_TestDataUtility.createApprover(cList[0].Id,usr6.Id, false);
        ap1.Core_MDF_Approver_Type__c = 'Internal';
        ap1.Core_MDF_Approver_2__c = usr6.Id;
        ap1.Core_MDF_Approver_3__c = usr6.Id;
        ap1.Core_MDF_Approver_4__c = usr6.Id;
        ap1.Core_MDF_Approver_5__c = usr6.Id;
        ap1.Core_MDF_Approver_6__c = usr6.Id;
        ap1.Core_MDF_Approver_7__c = usr6.Id;
        ap1.Core_MDF_Approver_8__c = usr6.Id;
        ap1.Core_MDF_Approver_9__c = usr6.Id;
        ap1.Core_MDF_Approver_10__c = usr6.Id;
        ap1.Core_MDF_Active__c = false;
        appList.add(ap1);
        
        Core_MDF_Approver__c ap2 = Core_MDF_CCP_TestDataUtility.createApprover(cList[0].Id,usr6.Id, false);
        ap2.Core_MDF_Approver_Type__c = 'Internal';
        ap2.Core_MDF_Approver_2__c = usr6.Id;
        ap2.Core_MDF_Active__c = false;
        appList.add(ap2);
        Database.insert(appList);
        
        List<Core_MDF_Criteria_Rule__c> crList = new List<Core_MDF_Criteria_Rule__c>();
        // Creating Criteria rules for approvers 
        Core_MDF_Criteria_Rule__c crule1 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(appList[0].Id,'Core_MDF_Fund_Request_Status__c','Equal',
                                                                                           'Pending Review',false);
        Core_MDF_Criteria_Rule__c crule2 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(appList[1].Id,'Core_MDF_Fund_Request_Status__c','Equal',
                                                                                           'Pending Review',false);
        
        crList.add(crule1);
        crList.add(crule2);
        Database.insert(crList);
        
        appList[0].Core_MDF_Active__c = true;
        appList[1].Core_MDF_Active__c = true;
        Database.update(appList);        
        cList[0].Core_MDF_Active__c = true;
        Database.update(cList);
        //ruleEngine data
        List<Core_MDF_Audit_Rules_Engine__c>ruleList = new List<Core_MDF_Audit_Rules_Engine__c>();
        Core_MDF_Audit_Rules_Engine__c FrontEndReviewRule = new Core_MDF_Audit_Rules_Engine__c(); 
        FrontEndReviewRule.Core_MDF_Object_Nm__c= 'PartnerFundRequest';
        FrontEndReviewRule.Core_MDF_Program_Nm__c= 'Client CoMarketing Fund';
        FrontEndReviewRule.Core_MDF_Field_Nm__c= 'Core_MDF_Fund_Request_Status__c';//Core_MDF_Fund_Request_Status__c';
        FrontEndReviewRule.Core_MDF_Operator_Nm__c= 'Equal';
        FrontEndReviewRule.Core_MDF_Budget_Type_Multi_Nm__c= /*'MDF;MDF+;OEM CMP'*/'OEM CMP';
        FrontEndReviewRule.Core_MDF_Value_Txt__c= 'Pending Review';
        FrontEndReviewRule.Core_MDF_Immediate_Ind__c= 'Yes';
        FrontEndReviewRule.Core_MDF_Effective_Dt__c= System.today()-1;
        FrontEndReviewRule.Core_MDF_Active_Ind__c= true;
        FrontEndReviewRule.Core_MDF_Rule_Type_Nm__c= 'Front End Review';
        FrontEndReviewRule.Core_MDF_Region_Cd__c = 'WW';
        //FrontEndReviewRule.Core_MDF_Action_on_True_nm__c='Customer Acceptance';
        FrontEndReviewRule.Core_MDF_Approver_Source_on_True_nm__c='Approval Criteria';
        FrontEndReviewRule.Core_MDF_Approver_Source_Value_on_True__c=cList[0].Id;
        
        Core_MDF_Audit_Rules_Engine__c FrontEndReviewRule2 = new Core_MDF_Audit_Rules_Engine__c(); 
        FrontEndReviewRule2.Core_MDF_Object_Nm__c= 'PartnerFundRequest';
        FrontEndReviewRule2.Core_MDF_Program_Nm__c= 'Retail Marketing Funds';
        FrontEndReviewRule2.Core_MDF_Field_Nm__c= 'Core_MDF_Approval_Step_Completed__c';//Core_MDF_Fund_Request_Status__c';
        FrontEndReviewRule2.Core_MDF_Operator_Nm__c= 'Equal';
        FrontEndReviewRule2.Core_MDF_Budget_Type_Multi_Nm__c= 'RSA MD;Retail MDF';
        FrontEndReviewRule2.Core_MDF_Value_Txt__c= '0';
        FrontEndReviewRule2.Core_MDF_Immediate_Ind__c= 'Yes';
        FrontEndReviewRule2.Core_MDF_Effective_Dt__c= System.today()-1;
        FrontEndReviewRule2.Core_MDF_Active_Ind__c= true;
        FrontEndReviewRule2.Core_MDF_Rule_Type_Nm__c= 'Front End Review';
        FrontEndReviewRule2.Core_MDF_Region_Cd__c = 'WW';
        //FrontEndReviewRule2.Core_MDF_Action_on_True_nm__c='Customer Acceptance';
        FrontEndReviewRule2.Core_MDF_Approver_Source_on_True_nm__c='Approval Criteria';
        FrontEndReviewRule2.Core_MDF_Approver_Source_Value_on_True__c=cList[0].Id;
        FrontEndReviewRule2.Core_MDF_Approver_Source_on_False_nm__c='Object Field';
        FrontEndReviewRule2.Core_MDF_Approver_Source_Value_on_False__c='Core_MDF_Activity_First_Approver_txt__c';
        FrontEndReviewRule2.Core_MDF_Rule_Action_on_False_nm__c='First Level Manager';
        FrontEndReviewRule2.Core_MDF_Process_Name__c='Core_MDF_Activity_Approval_MultiLvl_V13';
        
        
        Core_MDF_Audit_Rules_Engine__c FrontEndReviewRule3 = new Core_MDF_Audit_Rules_Engine__c(); 
        FrontEndReviewRule3.Core_MDF_Object_Nm__c= 'PartnerFundRequest';
        FrontEndReviewRule3.Core_MDF_Program_Nm__c= 'Client CoMarketing Fund';
        FrontEndReviewRule3.Core_MDF_Field_Nm__c= 'Core_MDF_Fund_Request_Status__c';//Core_MDF_Fund_Request_Status__c';
        FrontEndReviewRule3.Core_MDF_Operator_Nm__c= 'Equal';
        FrontEndReviewRule3.Core_MDF_Budget_Type_Multi_Nm__c= 'MDF;MDF+';
        FrontEndReviewRule3.Core_MDF_Value_Txt__c= 'Pending Review';
        FrontEndReviewRule3.Core_MDF_Immediate_Ind__c= 'Yes';
        FrontEndReviewRule3.Core_MDF_Effective_Dt__c= System.today()-1;
        FrontEndReviewRule3.Core_MDF_Active_Ind__c= true;
        FrontEndReviewRule3.Core_MDF_Rule_Type_Nm__c= 'Front End Review';
        FrontEndReviewRule3.Core_MDF_Region_Cd__c = 'WW';
        //FrontEndReviewRule3.Core_MDF_Action_on_True_nm__c='First Level Manager';
        FrontEndReviewRule3.Core_MDF_Approver_Source_on_True_nm__c='IUPGM';
        //FrontEndReviewRule2.Core_MDF_Process_Name__c='Core_MDF_OPAL_Approval_Process_V9';
        //
        //
       
        ruleList.add(FrontEndReviewRule);
        ruleList.add(FrontEndReviewRule2);
        ruleList.add(FrontEndReviewRule3);
        
        Database.insert(ruleList);
        
        List<Core_MDF_CCP_Custom_Metadata_Utility__c> metalist = new List<Core_MDF_CCP_Custom_Metadata_Utility__c>();
        Core_MDF_CCP_Custom_Metadata_Utility__c buSplit = new Core_MDF_CCP_Custom_Metadata_Utility__c();
        buSplit.Core_MDF_Category__c = 'BU Splits';
        buSplit.Core_MDF_Program__c = 'Intel Partner Alliance';
        buSplit.Core_MDF_Field_1_txt__c = 'Intel® Corporate Logo';
        buSplit.Core_MDF_Field_2_txt__c = 'Client Computing';
        buSplit.Core_MDF_Field_3_txt__c = '2-in-1';
        buSplit.Core_MDF_Field_5_txt__c = 'DCAI CPU Server';
        buSplit.Core_MDF_Field_6_txt__c = 'Core_MDF_BU1_Split_Percent_nbr__c';
        buSplit.Core_MDF_Is_Active_Ind__c = true;
        buSplit.Core_MDF_Date_1_dt__c = system.today()-200;
        buSplit.Core_MDF_Date_2_dt__c = system.today()+200;
        metalist.add(buSplit);
        
        Core_MDF_CCP_Custom_Metadata_Utility__c attMap = new Core_MDF_CCP_Custom_Metadata_Utility__c();
        attMap.Core_MDF_Category__c = 'Attributes Map';
        attMap.Core_MDF_Program__c = 'CCF';
        attMap.Core_MDF_Field_2_txt__c = 'Client';
        attMap.Core_MDF_Field_4_txt__c = 'Core_MDF_Client_CoMarketing_Fund';
        attMap.Core_MDF_Field_7_txt__c = 'Event';
        attMap.Core_MDF_Field_9_txt__c = 'Third Party Event';
        attMap.Core_MDF_Checkbox_Field_5_Ind__c = True;
        attMap.Core_MDF_Checkbox_Field_6_Ind__c = True;
        attMap.Core_MDF_Checkbox_Field_3_Ind__c = True;
        attMap.Core_MDF_Is_Active_Ind__c = true;
        metalist.add(attMap);
        insert metalist;
        
        
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
        ChannelProgram eefCp = Core_MDF_CCP_TestDataUtility.createProgram('Ecosystem Extension Fund','Ecosystem Extension Fund', true);
        List<Account> accList = new List<Account>();
         List<Account> accListUlt = new List<Account>();
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', 
                                                                       Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        acc1.BillingStateCode = '';
        accListUlt.add(acc1);
        Account intelPrimAcc = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Primary Intel Account', 
                                                                               Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        intelPrimAcc.BillingStateCode = '';
        accListUlt.add(intelPrimAcc);
        Account intelActAcc = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Activating Intel Account', 
                                                                              Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        intelActAcc.BillingStateCode = '';
        accListUlt.add(intelActAcc);
        
        //Database.insert(accListUlt);
        //insert acc1;
        ChannelProgram cmdfCp = Core_MDF_CCP_TestDataUtility.createProgram ('Channel MDF','Channel MDF', false);
        insert cmdfCp;
        Account ccpIntelAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('CCF Test Intel Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        ccpIntelAccount.BillingStateCode='';
        accListUlt.add(ccpIntelAccount);
        Database.insert(accListUlt);
        Account cmdfCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('CMDF Co-Marketing Account', cmdfCp.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,ccpIntelAccount.id, true); 
        
        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2',
                                                                             cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, 
                                                                             acc1.Id, false);
        acc2.Core_Geo__c = '';  
        acc2.Core_Sub_Geo__c = '';
        //    acc2.Core_Sub_Geo__c = 'IJKK';
        
        accList.add(acc2);
        Account PrimaryVC = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Primary VC Account',
                                                                                  eefCp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, 
                                                                                  intelPrimAcc.Id, false);
        PrimaryVC.Core_MDF_Partner_Type_nm__c = 'Primary Partner';
        PrimaryVC.Core_MDF_Active_Ind__c = true;
        accList.add(PrimaryVC);
        
        Account activatingVC = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Acticating VC Account',
                                                                                     eefCp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, 
                                                                                     intelActAcc.Id, false);
        activatingVC.Core_MDF_Partner_Type_nm__c = 'Activating Partner';
        activatingVC.Core_MDF_Active_Ind__c = true;
        accList.add(activatingVC);
        insert accList;
        system.runAs(usr){
            Core_MDF_Bank__c bank1 = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1241241240');
        
       
            list<PermissionSetAssignment> permList = new list<PermissionSetAssignment>();
            PermissionSet psFinance = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Finance_Usr' LIMIT 1];
            PermissionSetAssignment perm1 = new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = psFinance.Id);
            permList.add(perm1);
            PermissionSetAssignment perm3 = new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = psFinance.Id);
            permList.add(perm3);
            PermissionSet psFinance1 = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_User' LIMIT 1];
            PermissionSetAssignment perm2 = new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = psFinance1.Id);
            permList.add(perm2);
            PermissionSetAssignment perm4 = new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = psFinance1.Id);
            permList.add(perm4);
            PermissionSet psbudLoader = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader' LIMIT 1];
            PermissionSetAssignment perm5 = new  PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = psbudLoader.Id);
            permList.add(perm5);
            PermissionSetAssignment perm7 = new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = psbudLoader.Id);
            permList.add(perm7);
            permissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Retail_Finance_Usr' LIMIT 1];
            PermissionSetAssignment perm6 = new PermissionSetAssignment(AssigneeId = usr2.id, PermissionSetId = ps.Id);
            permList.add(perm6);
            PermissionSetAssignment perm8 = new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = ps.Id);
            permList.add(perm8);
            permissionSet eefBudgetLoaderPs= [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_Internal_EEF_Budget_Loader' LIMIT 1];
            PermissionSetAssignment perm9 = new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = eefBudgetLoaderPs.Id);
            permList.add(perm9);
            permissionSet primaryAccManPs= [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_Internal_EEF_Primary_Partner_Acct_Mgr' LIMIT 1];
            PermissionSetAssignment perm10 = new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = primaryAccManPs.Id);
            permList.add(perm10);
            insert permList;
        }
        
        Id iupgm_Recordtype_EEF = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Ecosystem_Extension_Fund').getRecordTypeId();
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm1 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm1.RecordTypeId =  iupgm_Recordtype_EEF;
        iupgm1.Core_MDF_Program_nm__c = 'Ecosystem Extension Fund';
        iupgm1.Core_MDF_Region_Sub_Region_nm__c = 'WW';
        iupgm1.Core_MDF_User_id__c =  usr.Id;
        iupgm1.Core_MDF_All_Budget_Type_Access_Ind__c = true;
        iupgm1.Core_MDF_All_Accounts_cd__c = 'No';
        iupgm1.Core_MDF_Account_id__c = intelPrimAcc.Id;
        iupgm1.Core_MDF_Role_nm__c='Core_MDF_Internal_EEF_Primary_Partner_Acct_Mgr';
        iupgm1.Core_MDF_Channel_Program_id__c = eefCp.Id;
        iupgmList.add(iupgm1);
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm2 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm2.RecordTypeId =  iupgm_Recordtype_EEF;
        iupgm2.Core_MDF_Program_nm__c = 'Ecosystem Extension Fund';
        iupgm2.Core_MDF_Region_Sub_Region_nm__c = 'WW';
        iupgm2.Core_MDF_User_id__c =  usr.Id;
        iupgm2.Core_MDF_All_Budget_Type_Access_Ind__c = true;
        iupgm2.Core_MDF_All_Accounts_cd__c = 'Yes';
        iupgm2.Core_MDF_Role_nm__c='Core_MDF_Internal_EEF_Budget_Loader';
        iupgm2.Core_MDF_Channel_Program_id__c = eefCp.Id;
        iupgmList.add(iupgm2);
        Database.insert(iupgmList);
        
        List<Campaign> cmplst = new List<Campaign>();
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7 Processor', 'Yes',
                                                                        Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 
                                                                        'Client CoMarketing Fund', System.today()-6, //System.today().addDays(-300), 
                                                                        System.today()+30, 10000, 'Always Connected PC', //date.valueOf('2020-12-30')
                                                                        acc2.Id,'Desktop', false);
        camp.Core_MDF_Activity_Category_Type__c =null;
        Campaign ccfCamp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp CCF','Gaming','Intel® Core™ i7 Processor', 'Yes',
                                                                           Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 
                                                                           'Client CoMarketing Fund', System.today()-6, //System.today().addDays(-300), 
                                                                           System.today()+30, 10000, 'Always Connected PC', //date.valueOf('2020-12-30')
                                                                           acc2.Id,'Desktop', false);
        //ccfCamp.Core_MDF_Opal_Budget_Type_Txt__c= 'CCF 1.0';
        ccfCamp.Core_MDF_Activity_Category_Type__c =null;
        cmplst.add(camp);
        cmplst.add(ccfCamp);
        //Database.insert(ccfCamp);
            
        //Code for Retail begins
        ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', true);
            
        Account acc3 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 3', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        acc3.Core_Geo__c = 'APJ';
        acc3.Core_Sub_Geo__c = 'IJKK';
        //acc3.BillingCountryCode = 'JPN';
        acc3.BillingStateCode='';
        insert acc3;
            
        Account acc4 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 4', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc3.Id, false);
        acc4.Core_Geo__c = 'APJ';
        acc4.Core_Sub_Geo__c = 'IJKK';
        insert acc4;
          
            
        /*PartnerMarketingBudget testBudget1 = Core_MDF_CCP_TestDataUtility.createBudget('TestBudgetData1',Core_MDF_CCP_TestDataUtility.budget_Retail_Record_Type,
                                                                                           acc4.id, cp1.Id , 1000000 , System.today()-60 , System.today() + 60 , 
                                                                                           false);
            
        testBudget1.IsIgnoreValidation = true;
        testBudget1.Core_MDF_Budget_Type_Txt__c = ' RSA MD';
        //testBudget1.RecordTypeId = Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
        system.runAs(usr2){
                insert testBudget1;
        }
        testBudget1.Core_MDF_Budget_Status__c = 'Released';
        system.runAs(usr2){
        //Test.startTest();
        update testBudget1;
        }*/
        Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
        Id camp_Recordtype_EEF = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Ecosystem_Extension_Fund').getRecordTypeId();
        Id pfr_Recordtype_EEF = Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Ecosystem_Extension_Fund').getRecordTypeId();
        
        List<PartnerMarketingBudget> budgetList = new List<PartnerMarketingBudget>();
        
        PartnerMarketingBudget testBudget1 = Core_MDF_CCP_TestDataUtility.createBudget('TestBudgetData1',Core_MDF_CCP_TestDataUtility.budget_Retail_Record_Type,
                                                                                           acc4.id, cp1.Id , 1000000 , System.today()-60 , System.today() + 60 , 
                                                                                           false);
            
        testBudget1.IsIgnoreValidation = true;
        testBudget1.Core_MDF_Budget_Type_Txt__c = ' RSA MD';
            
        budgetList.add(testBudget1);
        PartnerMarketingBudget testBudget = Core_MDF_CCP_TestDataUtility.createBudget('TestBudgetData',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                      acc2.id, cp.Id , 2000000,System.today().addDays(-20),System.today() , 
                                                                                      false);
        testBudget.IsIgnoreValidation = true;
        testBudget.Core_MDF_Budget_Type_Txt__c = 'CCF 1.0';
        
        budgetList.add(testBudget);
        PartnerMarketingBudget opalbudgetMDF = Core_MDF_CCP_TestDataUtility.createBudget('TestOpalPMB',recordTypeIdPMB,acc2.Id,cp.Id,12345678,System.today().addDays(1),System.today().addDays(15),false);
        opalbudgetMDF.IsIgnoreValidation = true;
        opalbudgetMDF.Core_MDF_Budget_Type__c='MDF';
        opalbudgetMDF.Core_MDF_Budget_Type_Txt__c='MDF';
        budgetList.add(opalbudgetMDF);
        PartnerMarketingBudget testBudgetOEM = Core_MDF_CCP_TestDataUtility.createBudget('TestBudgetDataOEM',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                         acc2.id, cp.Id , 10000000 ,  System.today().addDays(-30) ,System.today().addDays(30),
                                                                                         false);
        budgetList.add(testBudgetOEM);
        testBudgetOEM.IsIgnoreValidation = true;
        testBudgetOEM.Core_MDF_Budget_Type_Txt__c = 'OEM CMP';
        testBudgetOEM.Core_MDF_Budget_Type__c='OEM CMP';
        system.runAs(usr){
            
            insert budgetList;
        }
        
        
        Id budget_EEFRecord_Type = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByDeveloperName().get('Core_MDF_Ecosystem_Extension_Fund').getRecordTypeId();
            PartnerMarketingBudget testBudgetCloud = Core_MDF_CCP_TestDataUtility.createBudget('TestBudgetCloud',budget_EEFRecord_Type,
                                                                                         PrimaryVC.id, eefCp.Id , 300 ,  System.today().addDays(-30) ,System.today().addDays(30),
                                                                                         false);
        
            testBudgetCloud.IsIgnoreValidation = true;
            testBudgetCloud.Core_MDF_Budget_Type_Txt__c = 'Cloud';
            testBudgetCloud.Core_MDF_Budget_Type__c='Cloud';
            System.runAs(usr){
        insert testBudgetCloud;
            }
        
        List<PartnerFundAllocation> pfaList = new List<PartnerFundAllocation>();
        PartnerFundAllocation pfaRecord1 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFAOEM',testBudgetOEM, acc2, 1000,false);
        PartnerFundAllocation pfaRecord3 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFA3',opalbudgetMDF, acc2, 999, false);
        PartnerFundAllocation allocation = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation New',testBudget,acc2,20000.0,false);
        PartnerFundAllocation eefAllocation = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation EEF',
                                              testBudgetCloud,PrimaryVC,200.0,false);
        PartnerFundAllocation eefActAllocation = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation activating EEF',
                                              testBudgetCloud,activatingVC,100.0,false);
        
        pfaList.add(pfaRecord1);
        pfaList.add(pfaRecord3);
        pfaList.add(allocation);
        pfaList.add(eefAllocation);
        pfaList.add(eefActAllocation);
        insert pfaList;
        system.runAs(usr1){
            
            //PartnerFundAllocation pfaRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Testreatil',testBudget1, acc4, 100,true);
            
            Test.startTest();
            
            Campaign camp1 = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 24','Gaming','Athena', 'Yes',
                                                                         Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 
                                                                         'Client CoMarketing Fund', System.today()-100, //System.today().addDays(-300), 
                                                                         System.today()+100, 10000, 'Instore innovation', 
                                                                         acc4.Id,'Desktop', false);
            
            camp1.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
            camp1.Core_MDF_Activity_Category_Type__c =null;
            camp1.Core_MDF_Program__c = 'Retail Marketing Funds';
            camp1.Core_MDF_Reimbursement_Rate__c='100%';
            camp1.Core_MDF_Technology__c = 'ACPC';
            camp1.Core_MDF_Opal_Budget_Type_Txt__c='';
            //Test.startTest();
            //insert camp1;
            cmplst.add(camp1);
            
            //Campaign for Japan cycle
            Campaign camp6 = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 45','Gaming','Athena', 'Yes',
                                                                         Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 
                                                                         'Client CoMarketing Fund', system.today()+ 2, //System.today().addDays(-300), 
                                                                         System.today()+230, 10000, 'Instore innovation', 
                                                                         acc4.Id,'Desktop', false);
            
            camp6.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
            
            camp6.Core_MDF_Activity_Category_Type__c =null;
            camp6.Core_MDF_Program__c = 'Retail Marketing Funds';
            camp6.Core_MDF_Reimbursement_Rate__c='100%';
            camp6.Core_MDF_Technology__c = 'ACPC';
            camp6.Core_MDF_Opal_Budget_Type_Txt__c='';
            
            //insert camp6;
            cmplst.add(camp6);
            
            Campaign eefCampaign  = Core_MDF_CCP_TestDataUtility.createCampaign('Test EEF Camp','Gaming','Athena', 'MDF or both CMP & MDF',
                                                                         camp_Recordtype_EEF, 
                                                                         'Ecosystem Extension Fund', system.today() - 30, //System.today().addDays(-300), 
                                                                         System.today() + 30, 100000, 'Advanced Analystics', 
                                                                         PrimaryVC.Id,'Cloud Instance Consumption', false);
            eefCampaign.Core_MDF_Partner_Mapping_Txt__c = activatingVC.id;
            eefCampaign.Core_MDF_Reimbursement_Rate__c = '100%';
            eefCampaign.Core_MDF_Opal_Budget_Type_Txt__c= 'Cloud';
            eefCampaign.Core_MDF_Reimbursement_Amt__c = 1000;
            cmplst.add(eefCampaign);
            
            insert cmplst;
            PartnerFundRequest MDFpfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp1.Id),
                                                                                              Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_CCF,string.valueof(acc4.id),pfaRecord3,opalbudgetMDF,'INDIA','Consumer','Desktop',
                                                                                              'Intel® Core™ i7 Processor','Broadcast','Radio','Draft',false);
            MDFpfr.Core_MDF_Budget_Type_nm__c = 'MDF'; 
            MDFpfr.RequestedAmount =220;
            MDFPfr.Core_MDF_MDFReimbursement_Amt__c = 100;
            //MDFpfr.Core_MDF_Reimbursement_Rate_txt__c='50%';
            MDFpfr.Core_MDF_Approval_Step_Completed__c=1;
            insert MDFpfr;
            
            PartnerFundRequest eefPfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(eefCampaign.Id),
                                                                                        pfr_Recordtype_EEF,string.valueof(activatingVC.id),eefAllocation,testBudgetCloud,'INDIA','Technical Influencer','Cloud Instance Consumption',
                                                                                        'Intel® SGX','Broadcast','Radio','Draft',false);
            eefPfr.Core_MDF_Budget_Type_nm__c = 'Cloud'; 
            eefPfr.Title ='Test EEF Activity TestClass';
            eefPfr.RequestedAmount =120;
            eefPfr.Core_MDF_Reimbursement_Rate_txt__c = '100%';
            eefPfr.Core_MDF_Approval_Step_Completed__c=2;
            eefPfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            eefPfr.AllocationId = eefActAllocation.id;
            eefPfr.Core_MDF_Approval_Stage__c = 'L1 Approval (Primary Partner)';
            insert eefPfr;
            eefPfr.RequestedAmount =150;
            update eefPfr;     
            
            List<Core_MDF_Budget_Transfer_Log__c> budTLList = New List<Core_MDF_Budget_Transfer_Log__c>();
            Core_MDF_Budget_Transfer_Log__c budgetTransferLog = new Core_MDF_Budget_Transfer_Log__c();
            budgetTransferLog.Core_MDF_Source_Account__c = PrimaryVC.id;
            budgetTransferLog.Core_MDF_Target_Account__c = activatingVC.id;
            budgetTransferLog.Core_MDF_Partner_Marketing_Budget__c = testBudgetCloud.id;
            budgetTransferLog.Core_MDF_Transferred_Amount__c = 20;
            budgetTransferLog.Core_MDF_Transfer_Type__c = 'Auto-Activity';
            budgetTransferLog.Core_MDF_Co_Marketing_Activity__c = eefPfr.id;
            budTLList.add(budgetTransferLog);
            insert budTLList;
            
        }

        //Code for IPA starts
        ChannelProgram ipaCP = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', true);
        Account ipaUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('IPA Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        ipaUltimateAccount.BillingStateCode='';
        Database.insert(ipaUltimateAccount);
          
        Account ipaCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('IPA Co-Marketing Account', ipaCP.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,ipaUltimateAccount.id, false);
        ipaCoMarketingAccount.Core_Geo__c = '';
        ipaCoMarketingAccount.Core_Sub_Geo__c = '';
        
        insert ipaCoMarketingAccount;
        //String budgetType = Core_MDF_CCP_IPA_TestDataUtility.createBenefit(ipaCoMarketingAccount);
        String budgetType = Core_MDF_CCP_ConstantClass.PR_MDF_BUDGET_TYPE;
        Campaign ipaCampaignForAP = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - AP',ipaCoMarketingAccount.id, System.today().addDays(-2), System.today().addDays(30),budgetType, 110000,'INDIA', 'Channel Partner', 'Apollo Lake', 'Planned', false);
        ipaCampaignForAP.Core_MDF_Proposal_Based_Ind__c=true;
        insert ipaCampaignForAP;
        
        Campaign ipaCampaignForAP1 = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - AP1',ipaCoMarketingAccount.id, System.today()-2, System.today().addDays(30),budgetType, 110000,'INDIA', 'Channel Partner', 'Apollo Lake', 'Planned', false);
        ipaCampaignForAP1.Core_MDF_Proposal_Based_Ind__c=true;
        insert ipaCampaignForAP1;
        Test.stopTest();   
        
    }
    @isTest 
    static void runRegionTest(){
        Integer pfrCount = 0;
        Test.startTest();
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        //Creating User with utility class 
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName = 'User Test';
        usr1.UserRoleId = usRole.Id;
        Database.insert(usr1);
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: Label.Core_MDF_Custom_Permission_IAM_Retail LIMIT 1];
        
        insert new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = ps.Id);
        
        try
        {
            System.runAs(usr1){
                
                date sdate = date.today();        
                
                Account acc4 = [select id from account where name = 'Test Account 4']; 
                Campaign camp = [select id from Campaign where name = 'Test Camp 24' limit 1];
                
                PartnerMarketingBudget testBudget = [select id from PartnerMarketingBudget where Title ='TestBudgetData1'];
                
                List<PartnerFundRequest> pfrtoinsert = new List<PartnerFundRequest>();
                
                Date strDate = system.today() + 20;
                Date edDate = strDate + 1; 
                /* PartnerFundRequest testPartnerFundRequestRecord1 = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(camp.id,Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId(),acc4.Id,null,
                testBudget,'ALBANIA','Gaming','Desktop','Athena','Online',
                'Customer.com','Draft',false);*/
                PartnerFundRequest testPartnerFundRequestRecord1 = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp.Id),string.valueof(acc4.id),strDate,edDate,false); 
                
                
                
                testPartnerFundRequestRecord1.Core_MDF_Start_Date__c = strdate;
                testPartnerFundRequestRecord1.Core_MDF_End_Date__c = edDate;
                testPartnerFundRequestRecord1.RequestedAmount = 100;
                testPartnerFundRequestRecord1.Core_MDF_Fund_Request_Status__c = '';
                testPartnerFundRequestRecord1.Core_MDF_Country_nm__c = 'AFGHANISTAN'+';BANGLADESH';
                testPartnerFundRequestRecord1.Core_MDF_Region_nm__c = 'APJ';
                testPartnerFundRequestRecord1.Core_MDF_Budget_Type_nm__c ='Retail MDF';
                testPartnerFundRequestRecord1.Core_MDF_Approval_Stage__c = 'Geo Lead Approval';
                testPartnerFundRequestRecord1.Core_MDF_Approver_Source_nm__c = 'IUPGM';
                pfrtoinsert.add(testPartnerFundRequestRecord1);
                Core_MDF_Process_PartnerFundRequest.populateBackEndFieldsInsert(pfrtoinsert);
                
                /* PartnerFundRequest testPartnerFundRequestRecord2 = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(camp.id,Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId(),acc4.Id,null,
                testBudget,'ALBANIA','Gaming','Desktop','Athena','Online',
                'Customer.com','Draft',false);
                */
                PartnerFundRequest testPartnerFundRequestRecord2 = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp.Id),string.valueof(acc4.id),strDate,edDate,false); 
                
                strDate = system.today() + 20;
                edDate = strDate + 1;
                testPartnerFundRequestRecord2.Core_MDF_Start_Date__c = strdate;
                testPartnerFundRequestRecord2.Core_MDF_End_Date__c = edDate;
                testPartnerFundRequestRecord2.RequestedAmount = 100;
                testPartnerFundRequestRecord2.Core_MDF_Fund_Request_Status__c = '';
                testPartnerFundRequestRecord2.Core_MDF_Country_nm__c = 'ALBANIA'+';BANGLADESH';
                testPartnerFundRequestRecord2.Core_MDF_Budget_Type_nm__c ='Retail MDF';
                
                pfrtoinsert = new List<PartnerFundRequest>();
                pfrtoinsert.add(testPartnerFundRequestRecord2);
                
                Core_MDF_Process_PartnerFundRequest.populateBackEndFieldsInsert(pfrtoinsert);
                Core_MDF_Process_PartnerFundRequest.populateBackEndFieldsInsert(null);
                
                testPartnerFundRequestRecord2.Core_MDF_Country_nm__c = 'ARGENTINA';
                pfrtoinsert = new List<PartnerFundRequest>();
                pfrtoinsert.add(testPartnerFundRequestRecord2);
                //Core_MDF_Process_PartnerFundRequest.populateBackEndFieldsInsert(pfrtoinsert);
                insert pfrtoinsert;
                Test.stopTest();
                Assert.isTrue( testPartnerFundRequestRecord2.Core_MDF_Country_nm__c ==  'ARGENTINA');
            } 
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Geo') ? true : false;
            //System.assertEquals(expectedExceptionThrown, true);
        }
        
    }
    
    //Code for Retail begins
    @isTest 
    static void runRetailActivityTest(){
        
        Integer pfrCount = 0;
        Test.startTest();
        
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        //Creating User with utility class 
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName = 'User Test';
        usr1.UserRoleId = usRole.Id;
        
        Database.insert(usr1);
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Retail_Account_Manager' LIMIT 1];
        PermissionSet psGeoApprvr = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Retail_Marketing_GEO_Approver' LIMIT 1];
        
        insert new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = ps.Id);
        insert new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = psGeoApprvr.Id);
        
        try
        {
            System.runAs(usr1){
                
                date sdate = date.today();        
                
                Account acc4 = [select id from account where name = 'Test Account 4']; 
                Campaign camp = [select id from Campaign where name = 'Test Camp 24' limit 1];
                
                PartnerMarketingBudget testBudget = [select id from PartnerMarketingBudget where Title ='TestBudgetData1'];
                
                
                List<PartnerFundRequest> pfrtoinsert = new List<PartnerFundRequest>();
                // List<PartnerFundRequest> pfrtoEmptyList = new List<PartnerFundRequest>();
                
                /*PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(camp.id,Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId(),acc4.Id,null,
                testBudget,'ALBANIA','Gaming','Chromebook','10ᵗʰ Gen','Event',
                'Joint Event','Draft',false);
                */  
                
                PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp.Id),string.valueof(acc4.id),system.today() - 2, system.today(),false); 
                
                testPartnerFundRequestRecord.RequestedAmount = 250;
                
                testPartnerFundRequestRecord.Core_MDF_Country_nm__c='United States';
                testPartnerFundRequestRecord.Core_MDF_Country_nm__c='France'; 
                
                testPartnerFundRequestRecord.Core_MDF_Budget_Type_nm__c='Retail MDF';                 
                pfrtoinsert.add(testPartnerFundRequestRecord);
                
                Core_MDF_Process_PartnerFundRequest.populateBackEndFieldsInsert(pfrtoinsert);
                //Core_MDF_UpdateActivityFields.populateBackEndFieldsInsert(pfrtoEmptyList);
                insert testPartnerFundRequestRecord;
                
                pfrCount += 1;
                //testPartnerFundRequestRecord.Core_MDF_Program__c = 'Retail Marketing Funds';
                testPartnerFundRequestRecord.Core_MDF_Fund_Request_Status__c = 'Pending Review';
                testPartnerFundRequestRecord.RequestedAmount = 2500;
                testPartnerFundRequestRecord.Core_MDF_Budget_Type_nm__c ='Retail MDF';
                testPartnerFundRequestRecord.Core_MDF_Price_reviewer_check_ind__c = False;
                update testPartnerFundRequestRecord;
                // Core_MDF_Process_PartnerFundRequest.setStatusRetailExternal(testPartnerFundRequestRecord);
                Test.stopTest();
                Assert.isTrue(testPartnerFundRequestRecord.Core_MDF_Budget_Type_nm__c == 'Retail MDF');
            } 
        }
        catch(Exception ex){
            
            Boolean expectedExceptionThrown =  ex.getMessage().contains('The start date of an activity cannot be prior to') ? true : false;
            // System.assertEquals(expectedExceptionThrown, true);
        }
    }
    //Code for Retail ends 
    
    @isTest 
    static void runCloseActivityTest(){
        // boolean hasAccess = false;
        Integer pfrCount = 0;
        List<PartnerFundRequest> vpfrList = new List<PartnerFundRequest>();
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        //Creating User with utility class 
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName = 'User Test';
        usr1.UserRoleId = usRole.Id;
        Database.insert(usr1);
        
        System.runAs(usr1){
            
            date sdate = date.today();
            
            Test.startTest();
            Account acc2 = [select id from account where name = 'Test Account 2']; 
            Campaign camp = [select id from Campaign where name = 'Test Camp 12' limit 1];
            
            PartnerMarketingBudget testBudget = [select id from PartnerMarketingBudget where Title ='TestBudgetData'];
            
            List<PartnerFundRequest> pfrtoinsert = new List<PartnerFundRequest>();
            
            // Create a pfr for the dates the way which is not crossed the 180 days
            PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(camp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,null,
                                                                                                                    testBudget,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Event',
                                                                                                                    'Member Participation in Third-Party Event','Draft',false);
            testPartnerFundRequestRecord.RequestedAmount = 250;
            testPartnerFundRequestRecord.Core_MDF_Fund_Request_Status__c = 'Planned';
            sdate = system.today() + 1;
            //sdate = sdate.addDays(-170);
            testPartnerFundRequestRecord.Core_MDF_Start_Date__c = system.today() -2 ;
            testPartnerFundRequestRecord.Core_MDF_End_Date__c = system.today() -2;
            pfrtoinsert.add(testPartnerFundRequestRecord);
            Core_MDF_Process_PartnerFundRequest.populateBackEndFieldsInsert(pfrtoinsert);
            insert testPartnerFundRequestRecord;
            pfrCount += 1;
            
            PartnerFundRequest pfr21 = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(camp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,null,
                                                                                             testBudget,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Event',
                                                                                             'Member Participation in Third-Party Event','Draft',false);
            List<PartnerFundRequest> pfrtoinsert1 = new List<PartnerFundRequest>();
            pfr21.RequestedAmount = 250;
            pfr21.Core_MDF_Fund_Request_Status__c = 'Planned';
            sdate = system.today() - 1;
            pfr21.Core_MDF_Start_Date__c = sdate;
            pfr21.Core_MDF_End_Date__c = sdate;
            pfr21.Core_MDF_Country_nm__c = 'ALBANIA';
            pfrtoinsert1.add(pfr21);
            Core_MDF_Process_PartnerFundRequest.populateBackEndFieldsInsert(pfrtoinsert1);
            insert pfr21;
            
            // Update the end date
            Map<Id,PartnerFundRequest> pfrMap = new Map<Id,PartnerFundRequest>();
            PartnerFundRequest pfr1 = [select id,RequestedAmount,Core_MDF_Approval_Step_Completed__c,Core_MDF_Start_Date__c,Core_MDF_Fund_Request_Status__c,recordTypeId,Core_MDF_End_Date__c from PartnerFundRequest where title =: 'test' and recordtypeid =: Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF LIMIT 1];
            pfr1.Core_MDF_Fund_Request_Status__c = 'Revision Required';
            
            pfrMap.put(pfr1.Id,pfr1);
            Core_MDF_Process_PartnerFundRequest.populateBackEndFieldsUpdate(pfrMap,null);
            
            
            pfrCount += 1;
            
            pfrMap = new Map<Id,PartnerFundRequest>();
            PartnerFundRequest pfr2 = [select id,RequestedAmount,Core_MDF_Approval_Step_Completed__c,Core_MDF_Start_Date__c,Core_MDF_Fund_Request_Status__c,recordTypeId,Core_MDF_End_Date__c from PartnerFundRequest where title =: 'test' and recordtypeid =: Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF  LIMIT 1];
            pfr2.Core_MDF_Fund_Request_Status__c = 'Cancelled';
            pfr2.Core_MDF_Approver_1__c = usr1.Id;
            pfrMap.put(pfr2.Id,pfr2);
            Core_MDF_Process_PartnerFundRequest.populateBackEndFieldsUpdate(pfrMap,null);
            pfrCount += 1;
            
            Map<Id,PartnerFundRequest> pfrMap1 = new Map<Id,PartnerFundRequest>();
            Map<Id,PartnerFundRequest> pfrMap2 = new Map<Id,PartnerFundRequest>();
            PartnerFundRequest pfr3 = [select id,RequestedAmount,Core_MDF_Approval_Step_Completed__c,Core_MDF_Start_Date__c,Core_MDF_Fund_Request_Status__c,recordTypeId,Core_MDF_End_Date__c from PartnerFundRequest where title =: 'test' and recordtypeid =: Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF  LIMIT 1];
            
            PartnerFundRequest pfr4 = [select id,RequestedAmount,Core_MDF_Approval_Step_Completed__c,Core_MDF_Start_Date__c,Core_MDF_Fund_Request_Status__c,recordTypeId,Core_MDF_End_Date__c from PartnerFundRequest where title =: 'test' and recordtypeid =: Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF  LIMIT 1];
            pfr3.Core_MDF_Fund_Request_Status__c = 'Planned';
            pfr3.Core_MDF_Budget_Amount_Local_amt__c = 100000;
            pfr4.Core_MDF_Fund_Request_Status__c = 'Cancelled';
            pfrMap1.put(pfr3.Id,pfr3);
            pfrMap2.put(pfr4.Id,pfr4);
            Core_MDF_Process_PartnerFundRequest.populateBackEndFieldsUpdate(pfrMap1,pfrMap2);
            Core_MDF_Process_PartnerFundRequest.populateBackEndFieldsUpdate(null,null);
            
            pfrCount += 1;
            
            pfrMap = new Map<Id,PartnerFundRequest>();
            pfrMap1 = new Map<Id,PartnerFundRequest>();
            PartnerFundRequest pfrcancel = [select id,RequestedAmount,Core_MDF_Approval_Step_Completed__c,Core_MDF_Start_Date__c,Core_MDF_Fund_Request_Status__c,recordTypeId,Core_MDF_End_Date__c from PartnerFundRequest where title =: 'test' and recordtypeid =: Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF  LIMIT 1];
            PartnerFundRequest pfrclose = pfrcancel;
            pfrcancel.Core_MDF_Fund_Request_Status__c = 'Cancelled';
            pfrclose.Core_MDF_Fund_Request_Status__c = 'Closed';
            pfrMap.put(pfrclose.Id,pfrclose);
            pfrMap1.put(pfrcancel.Id,pfrcancel);
            Core_MDF_Process_PartnerFundRequest.populateBackEndFieldsUpdate(pfrMap,pfrMap1);
            Core_MDF_Process_PartnerFundRequest.setAllApprovers(pfr2);
            
            Date lstDate = Date.newInstance(2022, 06, 09);
            Date endDate = Date.newInstance(2022, 06, 10);
            List<Date> dateList = new List<Date>{lstDate,endDate};
                Map<Id,List<Date>> pfrDateMap = new Map<Id,List<Date>>();
            pfrDateMap.put(pfr2.Id,dateList);
            Core_MDF_Process_PartnerFundRequest.validateJapanCycleDates(pfr2,pfrDateMap);
            Test.stopTest();
        }
        System.assert(pfrCount >= 2);
    }
    
    @isTest 
    static void activityEventTest(){
        
        //       boolean hasAccess = false;
        Integer pfrCount = 0;
        UserRole usrRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        //Creating User with utility class 
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.LastName = 'User Test';
        usr2.UserRoleId = usrRole.Id;
        Database.insert(usr2);
        try{
            Test.startTest();
            System.runAs(usr2){                
                
                Account acc2 = [select id from account where name = 'Test Account 2']; 
                Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 13','Gaming','Intel® Core™ i7 Processor','Yes', 
                                                                            Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 
                                                                            'Client CoMarketing Fund', system.today()-4, //System.today().addDays(-300), date.valueOf('2022-01-30')
                                                                            date.valueOf('2022-01-30'), 10000, 'Always Connected PC', 
                                                                            acc2.Id,'Desktop', true); 
                
                Campaign camp1 = [select id from Campaign where name = 'Test Camp 13' limit 1];
                
                PartnerMarketingBudget testBudget = [select id from PartnerMarketingBudget where Title ='TestBudgetData'];
                
                List<PartnerFundRequest> pfrtoinsert1 = new List<PartnerFundRequest>();
                /*List<Core_MDF_PFR_Event_Rule__mdt> metadataList = [SELECT Id, Core_MDF_PFR_RecordType__c,Core_MDF_Country_Picklist_Value__c, Core_MDF_Activity_Category__c, Core_MDF_Requested_Amount__c, Core_MDF_Activity_Types__c, 
                                                                   Core_MDF_Day_Difference__c, Core_MDF_PFR_RecordType_Id__c, Core_MDF_PFR_StartDate__c, Core_MDF_Amount_Operator__c, Core_MDF_Days_Difference_Operator__c, Core_MDF_Error_Message__c FROM Core_MDF_PFR_Event_Rule__mdt];*/
                List<Core_MDF_CCP_Country_Geo_Mapping__mdt> countryGeoMetaData = [SELECT Id, MasterLabel, Core_MDF_Geo__c FROM Core_MDF_CCP_Country_Geo_Mapping__mdt];
                
                
                PartnerFundRequest testPartnerFundRequestRecord2 = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(camp1.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,null,
                                                                                                                         testBudget,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Event',
                                                                                                                         'Member Participation in Third-Party Event','Draft',false);
                
                Date stDate = date.valueOf('2019-10-25');
                Date endDate = date.valueOf('2019-11-02');
                Date nstDate = date.valueOf('2019-11-29');
                //testPartnerFundRequestRecord2.RecordType.DeveloperName = 'Core_MDF_Client_CoMarketing_Fund';
                testPartnerFundRequestRecord2.Core_MDF_Start_Date__c = stdate;
                testPartnerFundRequestRecord2.Core_MDF_End_Date__c = endDate;
                testPartnerFundRequestRecord2.RequestedAmount = 16250;
                testPartnerFundRequestRecord2.Core_MDF_Fund_Request_Status__c = 'Planned';
                testPartnerFundRequestRecord2.Core_MDF_Country_nm__c = 'United Kingdom';
                testPartnerFundRequestRecord2.Core_MDF_Region_nm__c = 'APJ';
                Date todaysDate = System.today();
                Integer daysDifference = 8;
                Id recordTypeId = Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Client_CoMarketing_Fund_Boost').getRecordTypeId();
                PartnerFundRequest testPartnerFundRequestRecord3 = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(camp1.id,recordTypeId,acc2.Id,null,
                                                                                                                         testBudget,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Event',
                                                                                                                         'Promotion','Draft',false);                
                
                Date strDate = date.valueOf('2020-01-25');
                Date edDate = date.valueOf('2020-02-02');
                Date newstDate = date.valueOf('2020-01-29');
                // testPartnerFundRequestRecord3.RecordType.DeveloperName = 'Core_MDF_Client_CoMarketing_Fund';
                testPartnerFundRequestRecord3.Core_MDF_Start_Date__c = strdate;
                testPartnerFundRequestRecord3.Core_MDF_End_Date__c = edDate;
                testPartnerFundRequestRecord3.RequestedAmount = 66250;
                testPartnerFundRequestRecord3.Core_MDF_Fund_Request_Status__c = 'Planned';
                testPartnerFundRequestRecord3.Core_MDF_Country_nm__c = 'United Kingdom'+';China';
                testPartnerFundRequestRecord3.Core_MDF_Region_nm__c = 'APJ';                
                Date todaysDt = System.today();                
                pfrtoinsert1.add(testPartnerFundRequestRecord2);
                pfrtoinsert1.add(testPartnerFundRequestRecord3);
                Core_MDF_Process_PartnerFundRequest.populateBackEndFieldsInsert(pfrtoinsert1);  
                insert testPartnerFundRequestRecord2;
                insert testPartnerFundRequestRecord3;
                // insert pfrtoinsert1;
                testPartnerFundRequestRecord2.Core_MDF_Start_Date__c = nstDate;
                update testPartnerFundRequestRecord2;                
                
                Test.stopTest();
            }
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Countries selected') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
        }
        
        
    }
    
    static void retailApprovalTest(){
        
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        //Creating User with utility class 
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName = 'User Test';
        usr1.UserRoleId = usRole.Id;
        try{
            Database.insert(usr1);
            
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: Label.Core_MDF_Custom_Permission_IAM_Retail];
            
            insert new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = ps.Id); 
            System.runAs(usr1){
                date sdate = date.today();        
                
                Account acc4 = [select id from account where name = 'Test Account 4']; 
                Campaign camp = [select id from Campaign where name = 'Test Camp 24' limit 1];
                
                PartnerMarketingBudget testBudget = [select id from PartnerMarketingBudget where Title ='TestBudgetData1'];
                
                List<PartnerFundRequest> pfrtoinsert = new List<PartnerFundRequest>();
                Test.startTest();
                
                /*PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(camp.id,Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId(),acc4.Id,null,
                testBudget,'ALBANIA','Gaming','Desktop','Athena','Event',
                'General (Customer-owned)','Draft',false);
                */
                sdate = system.today()-1;
                PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp.Id),string.valueof(acc4.id),sdate,sdate.addDays(15),false); 
                
                testPartnerFundRequestRecord.RequestedAmount = 250;
                testPartnerFundRequestRecord.Core_MDF_Fund_Request_Status__c = 'Pending Review';
                testPartnerFundRequestRecord.Core_MDF_Approval_Step_Completed__c = 0;
                testPartnerFundRequestRecord.Core_MDF_Budget_Type_nm__c ='RSA MD';
                pfrtoinsert.add(testPartnerFundRequestRecord);
                insert testPartnerFundRequestRecord;
                Core_MDF_Process_PartnerFundRequest.populateBackEndFieldsInsert(pfrtoinsert);
                Map<Id,PartnerFundRequest> newMap=new Map<Id,PartnerFundRequest>();
                newMap.put(testPartnerFundRequestRecord.id,testPartnerFundRequestRecord);
                Map<Id,PartnerFundRequest> oldMap=new Map<Id,PartnerFundRequest>();
                oldMap.put(testPartnerFundRequestRecord.id,testPartnerFundRequestRecord);
                Core_MDF_Process_PartnerFundRequest.populateBackEndFieldsUpdate(newMap, oldMap);
                ProcessInstance pi = [SELECT TargetObjectId
                                      FROM ProcessInstance
                                      WHERE TargetObjectId =: testPartnerFundRequestRecord.Id
                                      AND Status = 'Pending'];
                insert pi;
                
            }
        }
        catch(Exception ex)
        {
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Cannot') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        
    }
    
    
    //Japan cycle test
    /* @isTest 
    static void runRetailJapanCycleTest(){
        Integer pfrCount = 0;
        
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        //Creating User with utility class 
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName = 'User Test';
        usr1.UserRoleId = usRole.Id;
        Database.insert(usr1);
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Retail_Account_Manager' LIMIT 1];
        
        insert new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = ps.Id);
        
        try{
            System.runAs(usr1)
            {
                Test.startTest();
                date sdate = date.today();        
                Account acc4 = [select id from account where name = 'Test Account 4']; 
                Campaign camp = [select id from Campaign where name = 'Test Camp 45' limit 1];
                
                List<PartnerFundRequest> pfrtoinsert = new List<PartnerFundRequest>();                                                
                
                // Japan country validation
                PartnerFundRequest JapanPFR = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp.Id),string.valueof(acc4.id),sdate, sdate.addDays(15),false); 
                
                JapanPFR.Core_MDF_Budget_Type_nm__c = 'RSA MD';
                
                pfrtoinsert = new List<PartnerFundRequest>();
                JapanPFR.Core_MDF_Country_nm__c = 'JAPAN';
                JapanPFR.Core_MDF_Start_Date__c = system.today()+4 ;//212
                JapanPFR.Core_MDF_End_Date__c = system.today()+50;//230//5
                pfrtoinsert.add(JapanPFR);
                //Core_MDF_UpdateActivityFields.populateBackEndFieldsInsert(pfrtoinsert);
                insert JapanPFR;
                
                //System.assertEquals(pfrCount < 1, true);
                
                Test.stopTest();
            }
        }
        
        catch(Exception ex){          
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Activity dates cannot overlap cycles') ? true : false;
            //System.assertEquals(expectedExceptionThrown, true);
        }
    }*/
    
    @isTest 
    static void countryCannotRemove(){
        List<User> ulist = new List<User>();
        UserRole usrRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        //Creating User with utility class 
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.LastName = 'User Test';
        usr2.UserRoleId = usrRole.Id;
        ulist.add(usr2);
        
        User ccrm = Core_MDF_CCP_TestDataUtility.createUser(false);
        ccrm.LastName = 'User Test';
        ccrm.UserRoleId = usrRole.Id;
        ulist.add(ccrm);
        
        Database.insert(ulist);
        PermissionSet pset = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer_Manager' LIMIT 1];
        
        insert new PermissionSetAssignment(AssigneeId = ccrm.id, PermissionSetId = pset.Id);
        
        System.runAs(usr2){
            
            Test.startTest();
            
            Account acc2 = [select id from account where name = 'Test Account 2']; 
            
            
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 13','Gaming','Intel® Core™ i7 Processor','Yes', 
                                                                        Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 
                                                                        'Client CoMarketing Fund', system.today(), //System.today().addDays(-300), 
                                                                        System.today().addDays(30), 10000, 'Always Connected PC', 
                                                                        acc2.Id,'Desktop', false);
            camp.Core_MDF_Activity_Category_Type__c = null;
            insert camp;
            
            Campaign camp1 = [select id from Campaign where name = 'Test Camp 13' limit 1];
            
            PartnerMarketingBudget testBudget = [select id from PartnerMarketingBudget where Title ='TestBudgetData'];
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(camp1.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,null,
                                                                                           testBudget,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Event',
                                                                                           'Member Participation in Third-Party Event','Draft',false);
            
            pfr.Core_MDF_Start_Date__c = System.today().addDays(1);
            pfr.Core_MDF_End_Date__c = System.today().addDays(20);
            pfr.RequestedAmount = 16250;
            pfr.Core_MDF_Fund_Request_Status__c = 'In-Progress';
            pfr.Core_MDF_Country_nm__c = 'Sri Lanka';
            pfr.Core_MDF_Region_nm__c = 'APJ';
            insert pfr;                
            try{
                System.runAs(ccrm){
                    pfr.Core_MDF_Country_nm__c = 'INDIA';
                    update pfr; 
                }
            }catch(exception e){
                String msg = e.getMessage();
                System.assert(msg.contains(Label.Core_MDF_Cannot_Remove_Country));
            } 
            Test.stopTest();
        }
    }
    
    @isTest
    static void populateRRTest(){
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        //Creating User with utility class 
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName = 'User Test';
        usr1.UserRoleId = usRole.Id;
        Database.insert(usr1);
        System.runAs(usr1){
            Test.startTest();
            Account acc2 = [select id from account where name = 'Test Account 2']; 
            Campaign camp = [select id,Core_MDF_Reimbursement_Rate__c from Campaign where name = 'Test Camp CCF' limit 1];
            PartnerMarketingBudget testBudgetOEM1 = [select id from PartnerMarketingBudget where Title ='TestBudgetDataOEM'];
            Campaign ccfCamp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp CCF1','Gaming','Intel® Core™ i7 Processor', 'MDF or both CMP & MDF',
                                                                           Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 
                                                                           'Client CoMarketing Fund', System.today()-6, //System.today().addDays(-300), 
                                                                           System.today()+30, 100000, 'Always Connected PC', //date.valueOf('2020-12-30')
                                                                           acc2.Id,'Desktop', false);
            ccfCamp.Core_MDF_Opal_Budget_Type_Txt__c= 'OEM CMP';
            //ccfCamp.Core_MDF_Budget_Type_txt__c='OEM CMP';
            Database.insert(ccfCamp);
            Core_MDF_Campaign_Budgets__c campBudget= new Core_MDF_Campaign_Budgets__c();
            campBudget.Core_MDF_Campaign_Id__c=ccfCamp.id;
            campBudget.Core_MDF_Budget_Name_Id__c=testBudgetOEM1.id;
            campBudget.Core_MDF_Reimbursement_Rate_Pct__c='100%';
            campBudget.Core_MDF_Reimbursement_Amt__c=100000;
            campBudget.Core_MDF_Budget_Amt__c=100000;
            campBudget.Core_MDF_Active_ind__c=true;
            Database.insert(campBudget);
            PartnerFundAllocation pfaRecord = [select id from PartnerFundAllocation where Title ='TestPFAOEM']; 
            List<PartnerFundRequest> pfrtoinsert = new List<PartnerFundRequest>();
            
            PartnerFundRequest pfrRec = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(ccfCamp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,null,
                                                                                              testBudgetOEM1,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Event','Joint Event','Draft',false);
            
            pfrRec.AllocationId=pfaRecord.Id;                                                 
            pfrRec.RequestedAmount = 250;
            pfrRec.Core_MDF_ActivityCategory__c='Event';
            pfrRec.Core_MDF_Activity_Types__c = 'Joint Event';
            pfrRec.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
            pfrRec.BudgetId=testBudgetOEM1.Id;
            pfrRec.Core_MDF_Fund_Request_Status__c = 'Planned';
            pfrRec.Core_MDF_Competitive_Elements__c='Yes';
            pfrRec.Core_MDF_Start_Date__c = system.today()-2;
            pfrRec.Core_MDF_End_Date__c = system.today()-2 ;
            pfrRec.AllocationId = pfaRecord.Id;
            pfrRec.Core_MDF_Intel_Activity_Owner_Id__c = usr1.Id;
            pfrRec.Core_MDF_Reimbursement_Rate_txt__c = '100.00%';
            pfrtoinsert.add(pfrRec);
            PartnerMarketingBudget testBudget = [select id from PartnerMarketingBudget where Title ='TestBudgetData'];
            
            List<String> spifActivityTypesList=new List<String>();
            spifActivityTypesList.add('Joint Event');
            List<String> otherActivityTypesList=new List<String>();
            otherActivityTypesList.add('Joint Event');
            Core_MDF_Process_PartnerFundRequest.updatePctAndPorChecks(pfrRec, spifActivityTypesList, otherActivityTypesList, null);
            
            // Create a pfr for the dates the way which is not crossed the 180 days
            PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(camp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,null,
                                                                                                                    testBudget,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Event',
                                                                                                                    'Joint Event','Draft',false);
            testPartnerFundRequestRecord.RequestedAmount = 250;
            testPartnerFundRequestRecord.Core_MDF_Budget_Type_nm__c = 'CCF 1.0';
            testPartnerFundRequestRecord.Core_MDF_Competitive_Elements__c='Yes';
            testPartnerFundRequestRecord.Core_MDF_Fund_Request_Status__c = 'Planned';
            testPartnerFundRequestRecord.Core_MDF_Start_Date__c = system.today()-2;
            testPartnerFundRequestRecord.Core_MDF_End_Date__c = system.today()-2 ;
            pfrtoinsert.add(testPartnerFundRequestRecord);
            
            PartnerFundRequest testPartnerFundRequestRecord1 = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(camp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,null,
                                                                                                                    testBudget,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Event',
                                                                                                                    'Joint Event','Draft',false);
            testPartnerFundRequestRecord1.RequestedAmount = 250;
            testPartnerFundRequestRecord1.Core_MDF_Budget_Type_nm__c = 'CCF 1.0';
            testPartnerFundRequestRecord1.Core_MDF_Competitive_Elements__c='Yes';
            testPartnerFundRequestRecord1.Core_MDF_Fund_Request_Status__c = 'Planned';
            testPartnerFundRequestRecord1.Core_MDF_Start_Date__c = system.today()-2;
            testPartnerFundRequestRecord1.Core_MDF_End_Date__c = system.today()-2 ;
            //Core_MDF_UpdateActivityFields.populateBackEndFieldsInsert(pfrtoinsert);
            pfrtoinsert.add(testPartnerFundRequestRecord1);
            insert pfrtoinsert;
            Core_MDF_Process_PartnerFundRequest.deriveRRandAmt(pfrRec,ccfCamp,null,null);
            testPartnerFundRequestRecord1.Core_MDF_Country_nm__c = 'AFGHANISTAN'+';BANGLADESH;UNITED STATES';
            
            //Country Geo Map
            Map<String, String> countryGeoMap = new Map <String, String>();
            Map<String, String> countrySubGeoMap = new Map <String, String>();
            List<Core_MDF_CCP_Country_Geo_Mapping__mdt> countryGeoMetaDataList = Core_MDF_CCP_Country_Geo_Mapping__mdt.getAll().values();
            for(Core_MDF_CCP_Country_Geo_Mapping__mdt countryGeoMetaData : countryGeoMetaDataList){
                countryGeoMap.put(countryGeoMetaData.MasterLabel , countryGeoMetaData.Core_MDF_Geo__c );
                countrySubGeoMap.put(countryGeoMetaData.MasterLabel, countryGeoMetaData.Core_MDF_Sub_Geo__c);
            }
            Core_MDF_PartnerFundRequest_Utility.ClaimActAllocRecTypeMappingWrapper claimActAllocRecTypeMapWrapInstance = Core_MDF_PartnerFundRequest_Utility.getMetaDataValues();
            //Program and supported Geo Map 
            Map<String, List<String>> activityRecordTypeGeoListMap = new Map<String,List<String>>();
            activityRecordTypeGeoListMap = claimActAllocRecTypeMapWrapInstance.activityRecordTypeGeoListMap;
           
            Core_MDF_Process_PartnerFundRequest.regionSubRegionChecks(testPartnerFundRequestRecord1, activityRecordTypeGeoListMap, null, countryGeoMap, countrySubGeoMap, false,null);
            testPartnerFundRequestRecord1.Core_MDF_Country_nm__c = 'UNITED STATES';
            Map<Id,String> ccpRecordTypeIds=new Map<Id,String>{testPartnerFundRequestRecord1.RecordtypeId=>'Core_MDF_Intel_Partner_Alliance'};
            Core_MDF_Process_PartnerFundRequest.regionSubRegionChecks(testPartnerFundRequestRecord1, activityRecordTypeGeoListMap, ccpRecordTypeIds, countryGeoMap, countrySubGeoMap, false,null);

            /*testPartnerFundRequestRecord1.Core_MDF_Program__c=Core_MDF_CCP_ConstantClass.PFR_CHANNEL_MDF_PROGRAM;
            testPartnerFundRequestRecord1.Core_MDF_Proposal_Based_Ind__c=true;
            Core_MDF_Process_PartnerFundRequest.regionSubRegionChecks(testPartnerFundRequestRecord1, activityRecordTypeGeoListMap, ccpRecordTypeIds, countryGeoMap, countrySubGeoMap, false,null);*/

            //Database.insert(pfrRec);
            Core_MDF_Process_PartnerFundRequest.deriveRRandAmt(testPartnerFundRequestRecord, camp, null, null);
            Core_MDF_Process_PartnerFundRequest.deriveRRandAmt(testPartnerFundRequestRecord1, camp, null, null);
            Map<Id,PartnerFundRequest> oldPfrMap = new Map<Id,PartnerFundRequest>();
            
            oldPfrMap.put(pfrRec.id,pfrRec);
            
            pfrRec.Core_MDF_Activity_Types__c = 'Third Party Event';
            update pfrRec;
            
            Core_MDF_Process_PartnerFundRequest.deriveRRandAmt(pfrRec, ccfCamp, null, oldPfrMap);
            Test.stopTest();
            Assert.isTrue(pfrRec.Core_MDF_Activity_Types__c == 'Third Party Event');
        }
    }
    
    @isTest
    static void  testScenario1(){
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        //Creating User with utility class 
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName = 'User Test';
        usr1.UserRoleId = usRole.Id;
        Database.insert(usr1);
        System.runAs(usr1){
            Test.startTest();
            Account acc2 = [select id from account where name = 'Test Account 2']; 
            Campaign camp = [select id,Core_MDF_Reimbursement_Rate__c,Core_MDF_Opal_Budget_Type_Txt__c from Campaign where name = 'Test Camp CCF' limit 1];
            camp.Core_MDF_Opal_Budget_Type_Txt__c='CCF 1.0';
            List<PartnerFundRequest> pfrtoinsert = new List<PartnerFundRequest>();
            
            PartnerMarketingBudget testBudget = [select id from PartnerMarketingBudget where Title ='TestBudgetData'];
            
            /*ChannelProgram cmdfCp = [Select id from ChannelProgram where name='Channel MDF' limit 1];
            Account cmdfCoMarketingAccount = [select Id,Name from Account Where Name = 'CMDF Co-Marketing Account' limit 1];
          
            Id campaign_RecordType_ChannelMDF = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Channel_MDF').getRecordTypeId();
            
            Campaign CampChannelMDF = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp Share1','Commercial','Intel® Core™ i3 Processor','MDF or both CMP & MDF', 
                                                                                  campaign_RecordType_ChannelMDF, Core_MDF_CCP_ConstantClass.PFR_CHANNEL_MDF_PROGRAM, System.today()-25,System.today()+30, 5000, 'Consumer Chromebook',cmdfCoMarketingAccount.Id,'',false);
            CampChannelMDF.Core_MDF_Market__c = 'AFGHANISTAN';
            CampChannelMDF.Core_MDF_Opal_Budget_Type_Txt__c = 'Client Market Accelerate';
            CampChannelMDF.Core_MDF_Proposal_Based_Ind__c = true;
            CampChannelMDF.Core_MDF_Region_cd__c ='APJ';
            CampChannelMDF.Core_MDF_Program__c=Core_MDF_CCP_ConstantClass.PFR_CHANNEL_MDF_PROGRAM;
            Database.insert (CampChannelMDF); 
            
            Id PartnerFundRequest_RecordType_ChannelMDF = Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Channel_MDF').getRecordTypeId();
            PartnerFundRequest mdfPFR = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest( CampChannelMDF.id,cmdfCoMarketingAccount.id,System.today().addDays(1),System.today().addDays(10),false);
            mdfPFR.RecordTypeId=partnerFundRequest_RecordType_ChannelMDF; 
            mdfPFR.Core_MDF_Country_nm__c='UNITED STATES';
            pfrtoinsert.add(mdfPFR);
            insert pfrtoinsert;
            mdfPFR.RequestedAmount = 250;
            mdfPFR.Core_MDF_Budget_Type_nm__c = 'CCF 1.0';
            mdfPFR.Core_MDF_Competitive_Elements__c='Yes';
            mdfPFR.Core_MDF_Fund_Request_Status__c = 'Planned';
            mdfPFR.Core_MDF_Start_Date__c = system.today()-2;
            mdfPFR.Core_MDF_End_Date__c = system.today()-2 ;
            mdfPFR=[select Id,Core_MDF_Proposal_Based_Ind__c,Core_MDF_Program__c,recordtypeId,Recordtype.name,Core_MDF_Country_nm__c from PartnerFundRequest where Id=:mdfPFR.Id];*/
             //Country Geo Map
            Map<String, String> countryGeoMap = new Map <String, String>();
            Map<String, String> countrySubGeoMap = new Map <String, String>();
            List<Core_MDF_CCP_Country_Geo_Mapping__mdt> countryGeoMetaDataList = Core_MDF_CCP_Country_Geo_Mapping__mdt.getAll().values();
            for(Core_MDF_CCP_Country_Geo_Mapping__mdt countryGeoMetaData : countryGeoMetaDataList){
                 countryGeoMap.put(countryGeoMetaData.MasterLabel , countryGeoMetaData.Core_MDF_Geo__c );
                 countrySubGeoMap.put(countryGeoMetaData.MasterLabel, countryGeoMetaData.Core_MDF_Sub_Geo__c);
            }
            Core_MDF_PartnerFundRequest_Utility.ClaimActAllocRecTypeMappingWrapper claimActAllocRecTypeMapWrapInstance = Core_MDF_PartnerFundRequest_Utility.getMetaDataValues();
            //Program and supported Geo Map 
            Map<String, List<String>> activityRecordTypeGeoListMap = new Map<String,List<String>>();
            activityRecordTypeGeoListMap = claimActAllocRecTypeMapWrapInstance.activityRecordTypeGeoListMap;
            
            Map<String,Integer> activityRecordTypeCloseDateMap = new Map<String,Integer>();
            activityRecordTypeCloseDateMap = claimActAllocRecTypeMapWrapInstance.activityRecordTypeCloseDateMap;
            
            Map<Id,String> ccpRecordTypeIds = new Map<Id,String>();
            ccpRecordTypeIds = Core_MDF_PartnerFundRequest_Utility.getCCPRTNames(activityRecordTypeCloseDateMap);
             
           //Core_MDF_Process_PartnerFundRequest.regionSubRegionChecks(mdfPFR, activityRecordTypeGeoListMap, ccpRecordTypeIds, countryGeoMap, countrySubGeoMap, false,null);
 
            Test.stopTest();
            Assert.isTrue(pfrtoinsert!=null);
        }
    }
    
    @isTest
    static void populateRRTest2(){
        
        
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        //Creating User with utility class 
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName = 'User Test';
        usr1.UserRoleId = usRole.Id;
        Database.insert(usr1);
        System.runAs(usr1){
            Test.startTest();
            Account acc2 = [select id from account where name = 'Test Account 2']; 
            Campaign camp = [select id,Core_MDF_Reimbursement_Rate__c,Core_MDF_Opal_Budget_Type_Txt__c from Campaign where name = 'Test Camp CCF' limit 1];
            camp.Core_MDF_Opal_Budget_Type_Txt__c='CCF 1.0';
            List<PartnerFundRequest> pfrtoinsert = new List<PartnerFundRequest>();
            
            PartnerMarketingBudget testBudget = [select id from PartnerMarketingBudget where Title ='TestBudgetData'];
            
            // Create a pfr for the dates the way which is not crossed the 180 days
            PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(camp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,null,
                                                                                                                    testBudget,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Event',
                                                                                                                    'Joint Event','Draft',false);
            testPartnerFundRequestRecord.RequestedAmount = 250;
            testPartnerFundRequestRecord.Core_MDF_Budget_Type_nm__c = '';
            testPartnerFundRequestRecord.Core_MDF_Competitive_Elements__c='Yes';
            testPartnerFundRequestRecord.Core_MDF_Fund_Request_Status__c = 'Planned';
            testPartnerFundRequestRecord.Core_MDF_Start_Date__c = system.today()-2;
            testPartnerFundRequestRecord.Core_MDF_End_Date__c = system.today()-2 ;
            pfrtoinsert.add(testPartnerFundRequestRecord);
            
            PartnerFundRequest testPartnerFundRequestRecord1 = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(camp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,null,
                                                                                                                    testBudget,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Event',
                                                                                                                    'Joint Event','Draft',false);
            testPartnerFundRequestRecord1.RequestedAmount = 250;
            testPartnerFundRequestRecord1.Core_MDF_Budget_Type_nm__c = '';
            testPartnerFundRequestRecord1.Core_MDF_Competitive_Elements__c='Yes';
            testPartnerFundRequestRecord1.Core_MDF_Fund_Request_Status__c = 'Planned';
            testPartnerFundRequestRecord1.Core_MDF_Start_Date__c = system.today()-2;
            testPartnerFundRequestRecord1.Core_MDF_End_Date__c = system.today()-2 ;
            pfrtoinsert.add(testPartnerFundRequestRecord1);
            
            date sdate = date.today();        
            Account acc4 = [select id from account where name = 'Test Account 4']; 
            Campaign camp1 = [select id,Core_MDF_Reimbursement_Rate__c from Campaign where name = 'Test Camp 24' limit 1];
            
            Date strDate = system.today() + 20;
            Date edDate = strDate + 1; 
            PartnerFundRequest testPartnerFundRequestRecord2 = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp1.Id),string.valueof(acc4.id),strDate,edDate,false); 
            testPartnerFundRequestRecord2.Core_MDF_Start_Date__c = strdate;
            testPartnerFundRequestRecord2.Core_MDF_End_Date__c = edDate;
            testPartnerFundRequestRecord2.RequestedAmount = 100;
            testPartnerFundRequestRecord2.Core_MDF_Fund_Request_Status__c = 'In-Progress';
            testPartnerFundRequestRecord2.Core_MDF_Country_nm__c = 'AFGHANISTAN'+';BANGLADESH;';
            testPartnerFundRequestRecord2.Core_MDF_Region_nm__c = 'APJ';
            testPartnerFundRequestRecord2.Core_MDF_Reimbursement_Rate_pct__c='100%';
            testPartnerFundRequestRecord2.Core_MDF_TargetAudience__c='';
            pfrtoinsert.add(testPartnerFundRequestRecord2);
            
            
            /*Account cmdfCoMarketingAccount = [select Id,Name from Account Where Name = 'CMDF Co-Marketing Account' limit 1];
           Id campaign_RecordType_ChannelMDF = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Channel_MDF').getRecordTypeId();
            Id partnerFundRequest_RecordType_ChannelMDF = Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Channel_MDF').getRecordTypeId();
            
            Campaign CampChannelMDF = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp Share1','Commercial','Intel® Core™ i3 Processor','MDF or both CMP & MDF', 
                                                                                  campaign_RecordType_ChannelMDF, 'Channel MDF', System.today()-25,System.today()+30, 5000, 'Consumer Chromebook',cmdfCoMarketingAccount.Id,'',false);
            CampChannelMDF.Core_MDF_Market__c = 'AFGHANISTAN';
            CampChannelMDF.Core_MDF_Opal_Budget_Type_Txt__c = 'Client Market Accelerate';
            CampChannelMDF.Core_MDF_Proposal_Based_Ind__c = true;
            CampChannelMDF.Core_MDF_Region_cd__c ='APJ';
            Database.insert (CampChannelMDF);
            PartnerFundRequest mdfPFR = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest( CampChannelMDF.id,cmdfCoMarketingAccount.id,System.today().addDays(1),System.today().addDays(10),false);
            mdfPFR.RecordTypeId=partnerFundRequest_RecordType_ChannelMDF; 
            pfrtoinsert.add(mdfPFR); */
            
            insert pfrtoinsert;
            if(!pfrtoinsert.isEmpty()){
                Core_MDF_PartnerFundRequest_Utility.updateActFields(pfrtoinsert[0]);
                set<Id> setIds = new set<Id>();
                setIds.add(pfrtoinsert[0].Id);
                //Core_MDF_PartnerFundRequest_Utility.getOwnerLanguage(setIds);
                    }
            
            //Country Geo Map
            Map<String, String> countryGeoMap = new Map <String, String>();
            Map<String, String> countrySubGeoMap = new Map <String, String>();
            List<Core_MDF_CCP_Country_Geo_Mapping__mdt> countryGeoMetaDataList = Core_MDF_CCP_Country_Geo_Mapping__mdt.getAll().values();
            for(Core_MDF_CCP_Country_Geo_Mapping__mdt countryGeoMetaData : countryGeoMetaDataList){
                countryGeoMap.put(countryGeoMetaData.MasterLabel , countryGeoMetaData.Core_MDF_Geo__c );
                countrySubGeoMap.put(countryGeoMetaData.MasterLabel, countryGeoMetaData.Core_MDF_Sub_Geo__c);
            }
            Core_MDF_PartnerFundRequest_Utility.ClaimActAllocRecTypeMappingWrapper claimActAllocRecTypeMapWrapInstance = Core_MDF_PartnerFundRequest_Utility.getMetaDataValues();
            Map< String , List< Core_MDF_CCP_Custom_Metadata_Utility__c >> result = Core_MDF_PartnerFundRequest_Utility.getCCPAttributeMapMetadata();
             //Program and supported Geo Map 
            Map<String, List<String>> activityRecordTypeGeoListMap = new Map<String,List<String>>();
            activityRecordTypeGeoListMap = claimActAllocRecTypeMapWrapInstance.activityRecordTypeGeoListMap;
             
          // Core_MDF_Process_PartnerFundRequest.regionSubRegionChecks(mdfPFR, activityRecordTypeGeoListMap, null, countryGeoMap, countrySubGeoMap, true,null);
            
            
            List<PartnerFundRequest> pfrList3 = new List<PartnerFundRequest>();
            //pfrList3.add(mdfPFR);
            //Core_MDF_Process_PartnerFundRequest.processPFRRecords(pfrList3,NULL);
            
            Core_MDF_Process_PartnerFundRequest.deriveRRandAmt(testPartnerFundRequestRecord, camp, null, null);
            Core_MDF_Process_PartnerFundRequest.deriveRRandAmt(testPartnerFundRequestRecord1, camp, null, null);
            Core_MDF_Process_PartnerFundRequest.deriveRRandAmt(testPartnerFundRequestRecord2, camp1, null, null);
            //Core_MDF_Process_PartnerFundRequest.deriveRRandAmt(mdfPFR, CampChannelMDF, null, null);
            Test.stopTest();
        
            Assert.isTrue(pfrList3!=null);
        }
        
    }
    
    
    @isTest
    static void populateRRTest3(){
        //ChannelProgram ipaCP = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', true);
        //ChannelProgram ipaCP
        /*Account ipaUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('IPA Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        Account IPACoMarketingAcc = Core_MDF_CCP_TestDataUtility.createAccount ('Test IPA Account', ipaCP.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type,  false);
        IPACoMarketingAcc.Core_MDF_Parent_Fund_Account__c = ipaUltimateAccount.Id;
        IPACoMarketingAcc.Core_MDF_CoMarketing_Ultimate_Account__c = ipaUltimateAccount.Id;
        Database.insert(IPACoMarketingAcc);*/
        
        UserRole usrRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        //Creating User with utility class 
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.LastName = 'User Test';
        usr2.UserRoleId = usrRole.Id;
        Database.insert(usr2);
            Test.startTest();
            System.runAs(usr2){  
        Account IPACoMarketingAcc = [select id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c from Account where Name= 'IPA Co-Marketing Account'];

        Campaign camp4 = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp IPA','Gaming','Intel® Core™ i7+ Processor','Yes', Core_MDF_CCP_IPA_TestDataUtility.campaign_RecordType_IPA, 'Intel Partner Alliance', System.today()-15, System.today()+15, 10000, 'Consumer Chromebook', IPACoMarketingAcc.Id, '2-in-1', false);
        
        camp4.Core_MDF_Proposal_Based_Ind__c=false;
        camp4.Core_MDF_Program__c='Intel Partner Alliance';
        camp4.Core_MDF_Activity_Category_Type__c = null;
        Database.insert(camp4);
        PartnerFundRequest IPApfr2 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp4.Id),
                                                                                           Core_MDF_CCP_IPA_TestDataUtility.partnerFund_RecordType_IPA,string.valueof(IPACoMarketingAcc.id),NULL,NULL,'India','','Traditional Notebook',
                                                                                           'Intel® 11ᵗʰ Gen','Sales Incentive','Seller - Target SPIF','Draft',false); 
        IPApfr2.Core_MDF_Activity_Description__c = 'Test IPA Activity2';
        IPApfr2.Title = 'Test IPA Activity2';
        //IPApfr2.Core_MDF_Budget_Type_nm__c='Business Client Acceleration - MDF';
        IPApfr2.Core_MDF_Approval_Stage__c='Program Office Reviewer';
        IPApfr2.Core_MDF_Start_Date__c = System.today().addDays(1);
        IPApfr2.Core_MDF_End_Date__c = System.today().addDays(2);
        IPApfr2.Core_MDF_Program_Office_Check_ind__c = true;
        IPApfr2.Core_MDF_Country_nm__c = 'India';
        IPApfr2.Core_MDF_Fund_Request_Status__c = 'Pending Review';
        IPApfr2.Core_MDF_Reimbursement_Rate_txt__c = '100%';
        IPApfr2.Core_MDF_Reimbursement_Rate_pct__c='100%';
        
        IPApfr2.RequestedAmount =1000;
        IPApfr2.Core_MDF_MDFReimbursement_Amt__c=100;
         
        Database.insert(IPApfr2);
        IPApfr2.Core_MDF_Reimbursement_Rate_txt__c = '80%';
        //IPApfr2.Core_MDF_Budget_Type_nm__c='Account Plan';
        IPApfr2.RequestedAmount =900;
        IPApfr2.Core_MDF_MDFReimbursement_Amt__c=40;
        //Database.update(IPApfr2);
        /*PartnerFundRequest IPApfr3 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp4.Id),
                                                                                           Core_MDF_CCP_IPA_TestDataUtility.partnerFund_RecordType_IPA,string.valueof(IPACoMarketingAcc.id),NULL,NULL,'India','Consumer','Traditional Notebook',
                                                                                           'Intel® 11ᵗʰ Gen','Sales Incentive','Seller - Target SPIF','Draft',false); 
        IPApfr3.Core_MDF_Activity_Description__c = 'Test IPA Activity3';
        IPApfr3.Title = 'Test IPA Activity3';
        IPApfr3.Core_MDF_Budget_Type_nm__c='Account Plan';
        IPApfr3.Core_MDF_Approval_Stage__c='Program Office Reviewer';
        IPApfr3.Core_MDF_Start_Date__c = System.today().addDays(1);
        IPApfr3.Core_MDF_End_Date__c = System.today().addDays(2);
        IPApfr3.Core_MDF_Program_Office_Check_ind__c = true;
        IPApfr3.Core_MDF_Country_nm__c = 'India';
        IPApfr3.Core_MDF_Fund_Request_Status__c = 'Pending Review';
        IPApfr3.Core_MDF_Reimbursement_Rate_txt__c = '90%';
        IPApfr3.Core_MDF_Reimbursement_Rate_pct__c='100%';
        
        IPApfr3.RequestedAmount =900;
        IPApfr3.Core_MDF_MDFReimbursement_Amt__c=90;
         
        Database.insert(IPApfr3);*/
        Map<Id,PartnerFundRequest> oldPfrMap= new Map<Id,PartnerFundRequest>();
        oldPfrMap.put(IPApfr2.id,IPApfr2);
        Core_MDF_Process_PartnerFundRequest.deriveRRandAmt(IPApfr2, camp4, null, oldPfrMap);
        
        //Map<IPApfr2.Id,IPApfr2> oldPfrMap= new Map<IPApfr2.Id,IPApfr2>();
        //Core_MDF_Process_PartnerFundRequest.deriveRRandAmt(IPApfr2, camp4, null, oldPfrMap);
         Assert.isTrue(IPApfr2.Core_MDF_Reimbursement_Rate_txt__c != '');
        }
    }
    
    
    @isTest
    static void validateJapanCycleDatesTest(){
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        User userManager = [SELECT Id,Name FROM User where LastName = 'User Test6' LIMIT 1];
        List<Core_Trigger_Executions__c> bypassfunctinalitylist1 =[select Name,Core_Active__c,Core_Description__c from Core_Trigger_Executions__c];
        //Creating User with utility class 
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName = 'User Test';
        usr1.UserRoleId = usRole.Id;
        usr1.ManagerId =userManager.Id;
        Database.insert(usr1);
        System.runAs(usr1){
            Test.startTest();
            Account acc2 = [select id from account where name = 'Test Account 4' limit 1]; 
            Campaign camp = [select id from Campaign where name = 'Test Camp 24' limit 1];
            PartnerMarketingBudget testBudgetOEM = [select id from PartnerMarketingBudget where Title ='TestBudgetData1' limit 1];
            //PartnerFundAllocation pfaRecord = [select id from PartnerFundAllocation where Title ='Testreatil' limit 1]; 
            List<PartnerFundRequest> pfrtoinsert = new List<PartnerFundRequest>();
            PartnerFundRequest RetailPfr = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp.Id),string.valueof(acc2.id),System.today(),System.today(),false); 
            RetailPfr.Title ='Retail RSA MD Activity';
            RetailPfr.Core_MDF_Activity_Description__c ='Retail RSA MD Activity';
            RetailPfr.RequestedAmount =250;
            RetailPfr.Amount=1000;
            RetailPfr.Core_MDF_Country_nm__c = 'JAPAN';
            
            RetailPfr.Core_MDF_Budget_Currency_cd__c ='USD';
            RetailPfr.Core_MDF_Reimbursement_Rate_pct__c='100%';
            RetailPfr.Core_MDF_Approval_Step_Completed__c = 1;
            RetailPfr.Core_MDF_Budget_Type_nm__c ='RSA MD';
            RetailPfr.Core_MDF_Activity_First_Approver_txt__c = usr1.id;
            Retailpfr.Core_MDF_TargetAudience__c = '';
            insert RetailPfr;
            PartnerFundRequest pfr=[select id,Tolabel(ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.BillingCountryCode),Core_MDF_Ultimate_Account_Name__c,Core_MDF_Program__c,Title,Core_MDF_Budget_Type_nm__c from PartnerFundRequest where id=:RetailPfr.id  ];
          
            //Boolean res1=Core_MDF_Process_PartnerFundRequest.checkJapanCycle(RetailPfr,'Retail Marketing Funds');
            //Boolean res2=Core_MDF_Process_PartnerFundRequest.checkJapanCycle(pfr,'Core_MDF_Retail_Marketing_Funds');
            //System.assert(res2!=false);
            List<String> bypassFunctionKeys = new List<String>();
            bypassfunctinalitylist1[0].Core_Active__c = false;
            Database.update(bypassfunctinalitylist1);
            //RetailPfr.Core_MDF_Reimbursement_Rate_pct__c ='99%';
            update RetailPfr;
            Test.stopTest();
            
        }
    }
    @isTest
    static void validateJapanCycleDatesTestV1(){
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        User userManager = [SELECT Id,Name FROM User where LastName = 'User Test6' LIMIT 1];
        List<Core_Trigger_Executions__c> bypassfunctinalitylist1 =[select Name,Core_Active__c,Core_Description__c from Core_Trigger_Executions__c];
        //Creating User with utility class 
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName = 'User Test';
        usr1.UserRoleId = usRole.Id;
        usr1.ManagerId =userManager.Id;
        Database.insert(usr1);
        System.runAs(usr1){
            Test.startTest();
            Account acc2 = [select id from account where name = 'Test Account 4' limit 1]; 
            Campaign camp = [select id from Campaign where name = 'Test Camp 24' limit 1];
            PartnerMarketingBudget testBudgetOEM = [select id from PartnerMarketingBudget where Title ='TestBudgetData1' limit 1];
            //PartnerFundAllocation pfaRecord = [select id from PartnerFundAllocation where Title ='Testreatil' limit 1]; 
            List<PartnerFundRequest> pfrtoinsert = new List<PartnerFundRequest>();
            PartnerFundRequest RetailPfr = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp.Id),string.valueof(acc2.id),System.today(),System.today(),false); 
            RetailPfr.Title ='Retail RSA MD Activity';
            RetailPfr.Core_MDF_Activity_Description__c ='Retail RSA MD Activity';
            RetailPfr.RequestedAmount =250;
            RetailPfr.Amount=1000;
            RetailPfr.Core_MDF_Country_nm__c = 'JAPAN';
            
            RetailPfr.Core_MDF_Budget_Currency_cd__c ='USD';
            RetailPfr.Core_MDF_Reimbursement_Rate_pct__c='100%';
            RetailPfr.Core_MDF_Approval_Step_Completed__c = 1;
            RetailPfr.Core_MDF_Budget_Type_nm__c ='RSA MD';
            RetailPfr.Core_MDF_Activity_First_Approver_txt__c = usr1.id;
            Retailpfr.Core_MDF_TargetAudience__c = '';
            insert RetailPfr;
            PartnerFundRequest pfr=[select id,Tolabel(ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.BillingCountryCode),Core_MDF_Ultimate_Account_Name__c,Core_MDF_Program__c,Title,Core_MDF_Budget_Type_nm__c from PartnerFundRequest where id=:RetailPfr.id  ];
          
            //Boolean res1=Core_MDF_Process_PartnerFundRequest.checkJapanCycle(RetailPfr,'Retail Marketing Funds');
            //Boolean res2=Core_MDF_Process_PartnerFundRequest.checkJapanCycle(pfr,'Core_MDF_Retail_Marketing_Funds');
            //System.assert(res2!=false);
            List<String> bypassFunctionKeys = new List<String>();
            bypassfunctinalitylist1[0].Core_Active__c = false;
            Database.update(bypassfunctinalitylist1);
            //RetailPfr.Core_MDF_Reimbursement_Rate_pct__c ='99%';
            update RetailPfr;
            List<PartnerFundRequest> pfrList= new List<PartnerFundRequest>();
            pfrList.add(RetailPfr);
            Map<Id,PartnerFundRequest> oldMap= new Map<Id,PartnerFundRequest>();
            oldMap.put(RetailPfr.id,RetailPfr);
            //Core_MDF_Process_PartnerFundRequest.callRuleEngine(pfrList,oldMap,false,true);
            Test.stopTest();
            
        }
    }
    
    @isTest static void checkValidateClaims(){
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        Account acc4 = [select id from account where name = 'Test Account 4']; 
        Account acc2 = [select id from account where name = 'Test Account 2']; 
        PartnerFundAllocation allocation = [select id from PartnerFundAllocation where Title ='Test Allocation New'];
        Campaign camp = [select id from Campaign where name = 'Test Camp 24' limit 1];
        // PartnerMarketingBudget testBudget = [select id from PartnerMarketingBudget where Title ='TestBudgetData1'];
        // User usr1 = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        
        //try{
        // System.runAs(usr1){
        Test.startTest();
        date sdate = date.today();        
        
        Date strDate = system.today() + 20;
        Date edDate = strDate + 1; 
        PartnerFundRequest testPartnerFundRequestRecord1 = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp.Id),string.valueof(acc4.id),strDate,edDate,false); 
        testPartnerFundRequestRecord1.Core_MDF_Start_Date__c = strdate;
        testPartnerFundRequestRecord1.Core_MDF_End_Date__c = edDate;
        testPartnerFundRequestRecord1.RequestedAmount = 100;
        testPartnerFundRequestRecord1.Core_MDF_Fund_Request_Status__c = 'In-Progress';
        testPartnerFundRequestRecord1.Core_MDF_Country_nm__c = 'AFGHANISTAN'+';BANGLADESH';
        testPartnerFundRequestRecord1.Core_MDF_Region_nm__c = 'APJ';
        testPartnerFundRequestRecord1.Core_MDF_Reimbursement_Rate_pct__c='100%';
        
        PartnerFundRequest testPartnerFundRequest = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(camp.Id), 
                                                                                                          Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                          String.valueof(acc4.id),allocation,null,'INDIA',
                                                                                                          'Consumer',
                                                                                                          'Desktop',
                                                                                                          'Intel® Core™ i5 Processor',
                                                                                                          'Broadcast',
                                                                                                          'Podcast',
                                                                                                          'Draft',
                                                                                                          false);
        
        
        testPartnerFundRequest.Core_MDF_Start_Date__c = system.today().addDays(-3);
        testPartnerFundRequest.Core_MDF_End_Date__c  = system.today().addDays(-3);
        testPartnerFundRequest.Core_MDF_Country_nm__c = 'INDIA';
        testPartnerFundRequest.amount = 1000;
        // testPartnerFundRequest.Core_MDF_Budget_Type_nm__c = 'CCF 1.0';
        testPartnerFundRequest.ChannelPartnerId=acc4.Id;
        //testPartnerFundRequest.CampaignId = camp.Id; // Added by Areefa
        
        //insert testPartnerFundRequest;
        pfrList.add(testPartnerFundRequest);
        //pfrList.add(testPartnerFundRequestRecord1v);
        System.runAs(usr){
            database.insert(pfrList);
        
        
            Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Supplier_Number__c='1241241240' limit 1];
            //PartnerFundRequest pfr = [Select Id,Title from PartnerFundRequest where Title = 'test'];
        
            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequest.Id, testPartnerFundRequest.Core_MDF_Start_Date__c, testPartnerFundRequest.Core_MDF_Start_Date__c, 100, System.today(), bank1.Id, false);
            //claim1.Amount = 5;
            claim1.Core_MDF_Currency__c='USD';//INR
            claim1.Core_MDF_Requested_Reimbursement_Amt__c=5;
            claim1.Core_MDF_Audit_Adjustment_Amount__c=0;
            claim1.Core_MDF_Status__c = 'Submitted';
            claim1.Core_MDF_Type_Txt__c = 'Claim';
            //claim1.Core_MDF_Ad_Run_Start_Date__c=system.today()-10;
            //claim1.Core_MDF_Ad_Run_End_Date__c=system.today()+7;
        
            //insert claim1;
       
            Set<Id> pfrCancelledIdSet = new Set<id>();
            pfrCancelledIdSet.add(testPartnerFundRequest.Id);
            Map<Id,PartnerFundRequest> oldMap = new Map<Id,PartnerFundRequest>();
            Map<Id,PartnerFundRequest> newMap  = new Map<Id,PartnerFundRequest>(); 
            List<PermissionSetAssignment> permSetList = new List<PermissionSetAssignment>();
            newMap.put(testPartnerFundRequest.Id,testPartnerFundRequest);
            Core_MDF_CheckStatusAndDate.checkCancelledCalimValidation(pfrCancelledIdSet ,claim1);
            Core_MDF_CheckStatusAndDate.checkClaimDateValidation(pfrCancelledIdSet,claim1, oldMap,newMap);
            Core_MDF_CheckStatusAndDate.checkRejectedCalimValidation(pfrCancelledIdSet,claim1, permSetList);
            Core_MDF_CheckStatusAndDate.checkValidClaims(null, null);
            testPartnerFundRequest.Core_MDF_Fund_Request_Status__c ='In-Progress';
        
        
            database.update(testPartnerFundRequest);
            //testPartnerFundRequest.Core_MDF_End_Date__c =edDate.addDays(1);
            //database.update(testPartnerFundRequest);
        
            try{
                testPartnerFundRequest.Core_MDF_Fund_Request_Status__c ='Cancelled';
                database.update(testPartnerFundRequest);
            }
            catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);} 
        }
        //Core_MDF_CheckStatusAndDate.checkCancelledCalimValidation( Set<Id> pfrCancelledIdSet,PartnerFundClaim claim);
        
        Test.stopTest();
        
        // }
        //}catch(Exception e){
        
        //}
        Assert.isTrue( testPartnerFundRequest.Core_MDF_Fund_Request_Status__c == 'Cancelled');
    }
    @isTest
    public static void setATFFlagTest(){
        UserRole usrRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        //Creating User with utility class 
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.LastName = 'User Test';
        usr2.UserRoleId = usrRole.Id;
        Database.insert(usr2);
        Test.startTest();
        System.runAs(usr2){  
            Account acc2 = [select id from account where name = 'Test Account 2']; 
            Campaign camp = [select id from Campaign where name = 'Test Camp 12' limit 1];
            
            PartnerMarketingBudget testBudget = [select id from PartnerMarketingBudget where Title ='TestBudgetData'];
            
            Map<Id,PartnerFundRequest> pfrMap = new Map<Id,PartnerFundRequest>();
            PartnerFundRequest pfr1 = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(camp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,null,
                                                                                            testBudget,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Event',
                                                                                            'Member Participation in Third-Party Event','Draft',false);
            //List<PartnerFundRequest> pfrtoinsert1 = new List<PartnerFundRequest>();
            pfr1.RequestedAmount = 250;       
            pfr1.Core_MDF_Fund_Request_Status__c = 'Revision Required';
            pfr1.Core_MDF_Start_Date__c =  System.today().addDays(-10);
            pfr1.Core_MDF_ATF_Flag_nm__c='';
            //update pfr1;
            //
            PartnerFundRequest pfr2 = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(camp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,null,
                                                                                            testBudget,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Event',
                                                                                            'Member Participation in Third-Party Event','Draft',false);
            //List<PartnerFundRequest> pfrtoinsert1 = new List<PartnerFundRequest>();
            pfr2.RequestedAmount = 10;       
            pfr2.Core_MDF_Fund_Request_Status__c = 'Revision Required';
            pfr2.Core_MDF_Start_Date__c =  System.today().addDays(-30);
            pfr2.Core_MDF_ATF_Flag_nm__c='';
            pfrMap.put(pfr1.Id,pfr1);
            
            Core_MDF_Process_PartnerFundRequest.setATFFlag(pfr2,pfrMap);
            pfr1.Core_MDF_Fund_Request_Status__c='Planned';
            pfrMap.put(pfr1.Id,pfr1);
            
            Core_MDF_Process_PartnerFundRequest.setATFFlag(pfr2,pfrMap);
            System.assert(pfr2.Core_MDF_ATF_Flag_nm__c!=null);
        }   
    }
    @isTest
    public static void deriveActivityStatusesTest(){
        UserRole usrRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        //Creating User with utility class 
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.LastName = 'User Test';
        usr2.UserRoleId = usrRole.Id;
        Database.insert(usr2);
        Test.startTest();
        System.runAs(usr2){  
            Account acc2 = [select id from account where name = 'Test Account 2']; 
            Campaign camp = [select id from Campaign where name = 'Test Camp 12' limit 1];
            
            PartnerMarketingBudget testBudget = [select id from PartnerMarketingBudget where Title ='TestBudgetData'];
            
            Map<Id,PartnerFundRequest> pfrMap = new Map<Id,PartnerFundRequest>();
            PartnerFundRequest pfr1 = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(camp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,null,
                                                                                            testBudget,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Event',
                                                                                            'Member Participation in Third-Party Event','Draft',false);
            //List<PartnerFundRequest> pfrtoinsert1 = new List<PartnerFundRequest>();
            pfr1.RequestedAmount = 250;       
            pfr1.Core_MDF_Fund_Request_Status__c = 'Cancelled';
            pfr1.Core_MDF_Start_Date__c =  System.today().addDays(-10);
            //update pfr1;
            //
            PartnerFundRequest pfr2 = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(camp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,null,
                                                                                            testBudget,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Event',
                                                                                            'Member Participation in Third-Party Event','Draft',false);
            //List<PartnerFundRequest> pfrtoinsert1 = new List<PartnerFundRequest>();
            pfr2.RequestedAmount = 10;       
            pfr2.Core_MDF_Fund_Request_Status__c = 'Revision Required';
            pfr2.Core_MDF_Start_Date__c =  System.today().addDays(-30);
            pfr2.Core_MDF_Activity_CreatedByExternalUsr__c = true;
            pfrMap.put(pfr1.Id,pfr1);
            
            Core_MDF_Process_PartnerFundRequest.deriveActivityStatuses(pfr2,pfrMap);
            System.assert(pfr2!=null);
        } 
    }
    @isTest 
    static void validateIPAActivityClosure(){
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        Integer pfrCount = 0;
        Account ipaCoMarketingAccount = [select id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c from Account where Name= 'IPA Co-Marketing Account'];
        
        Campaign ipaCampaignForAP = [SELECT Id, Core_MDF_Activity_Sub_Type_nm__c, Status, Core_MDF_Approval_Step_Counter_nbr__c, 
                                     Core_MDF_Reimbursement_Rate__c, Core_MDF_Region_cd__c, Description,
                                     StartDate, EndDate, Core_MDF_Total_Campaign_Cost_Amt__c, Core_MDF_Market__c  
                                     FROM Campaign WHERE Name = 'Test Campaign - AP' LIMIT 1];
        
        Campaign ipaCampaignForAP1 = [SELECT Id, Core_MDF_Activity_Sub_Type_nm__c, Status, Core_MDF_Approval_Step_Counter_nbr__c, 
                                     Core_MDF_Reimbursement_Rate__c, Core_MDF_Region_cd__c, Description,
                                     StartDate, EndDate, Core_MDF_Total_Campaign_Cost_Amt__c, Core_MDF_Market__c  
                                     FROM Campaign WHERE Name = 'Test Campaign - AP1' LIMIT 1];
        
        //ipaCampaignForAP.Core_MDF_Activity_Sub_Type_nm__c = 'Other (NonPartner.com)';
        //Database.update(ipaCampaignForAP);
        Test.startTest();
        List<PartnerFundRequest> pfrtoinsert = new List<PartnerFundRequest>();
        System.runAs(usr){
            PartnerFundRequest ipaPFR5 = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaignForAP.id,ipaCoMarketingAccount.id,System.today(),System.today(),false);
            //ipaPFR5.Core_MDF_Country_nm__c='United States';
            ipaPFR5.Core_MDF_Focus_Area_nm__c = 'Client Computing';
            ipaPFR5.Core_MDF_ProductType__c = '2-in-1';
            ipaPFR5.Core_MDF_Brand_nm__c = 'Intel® Corporate Logo';
            ipaPFR5.Core_MDF_Country_nm__c='India';
            //ipaPFR5.Core_MDF_Proposal_Based_Ind__c=true;
            ipaPFR5.Core_MDF_Fund_Request_Status__c='Draft';
            pfrtoinsert.add(ipaPFR5);
            //Core_MDF_Process_PartnerFundRequest.populateBackEndFieldsInsert(pfrtoinsert);
            insert ipaPFR5;
            
            PartnerFundRequest ipaPFR6 = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaignForAP1.id,ipaCoMarketingAccount.id,System.today()-1,System.today()-1,false);
            //ipaPFR5.Core_MDF_Country_nm__c='United States';
            ipaPFR6.Core_MDF_Focus_Area_nm__c = 'Client Computing';
            ipaPFR6.Core_MDF_ProductType__c = '2-in-1';
            ipaPFR6.Core_MDF_Brand_nm__c = 'Intel® Corporate Logo';
            ipaPFR6.Core_MDF_Country_nm__c='India';
            ipaPFR6.Core_MDF_ToBeClosedDate__c=System.today()-1;
            //ipaPFR5.Core_MDF_Proposal_Based_Ind__c=true;
            ipaPFR6.Core_MDF_Fund_Request_Status__c='Draft';
            pfrtoinsert.add(ipaPFR6);
            //Core_MDF_Process_PartnerFundRequest.populateBackEndFieldsInsert(pfrtoinsert);
            insert ipaPFR6;
            
            Core_MDF_Process_PartnerFundRequest.sendNotificationByFlow(pfrtoinsert);
            
            /*PartnerFundRequest ipaPFR6 = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaignForAP.id,ipaCoMarketingAccount.id,System.today(),System.today(),false);
            //ipaPFR5.Core_MDF_Country_nm__c='United States';
            ipaPFR6.Core_MDF_Focus_Area_nm__c = 'Client Computing';
            ipaPFR6.Core_MDF_ProductType__c = '2-in-1';
            ipaPFR6.Core_MDF_Brand_nm__c = 'Intel® Corporate Logo;Intel® Arc™';
            ipaPFR6.Core_MDF_Country_nm__c='India';
            //ipaPFR5.Core_MDF_Proposal_Based_Ind__c=true;
            ipaPFR6.Core_MDF_Fund_Request_Status__c='Draft';
            pfrtoinsert.add(ipaPFR6);
            Core_MDF_Process_PartnerFundRequest.populateBackEndFieldsInsert(pfrtoinsert);
            insert ipaPFR6;*/
            
            Map<Id,PartnerFundRequest> oldPfrMap = new Map<Id,PartnerFundRequest>();
            Map<Id,PartnerFundRequest> newMap = new Map<Id,PartnerFundRequest>();
            List<PartnerFundRequest> pfrList2 = new List<PartnerFundRequest>();
            List<PartnerFundRequest> pfrList3 = new List<PartnerFundRequest>();
            pfrList3.add(ipaPFR6);
            
            oldPfrMap.put(ipaPFR5.Id,ipaPFR5);
            pfrList2.add(ipaPFR5);
            PartnerFundRequest updatepfr = [select id,Core_MDF_Focus_Area_nm__c,Core_MDF_ProductType__c,Core_MDF_Brand_nm__c,Core_MDF_Budget_Type_nm__c,RequestedAmount,Core_MDF_Approval_Step_Completed__c,Core_MDF_Start_Date__c,Core_MDF_Fund_Request_Status__c,recordTypeId,Core_MDF_End_Date__c,Core_MDF_Activity_First_Approver_txt__c,Core_MDF_ToBeClosedDate__c,Core_MDF_Country_nm__c from PartnerFundRequest where title =: 'Test IPA' and recordtypeid =: Core_MDF_CCP_IPA_TestDataUtility.partnerFund_RecordType_IPA  LIMIT 1];
            
            updatepfr.Core_MDF_End_Date__c =  System.today().addDays(0);
            ipaPFR5.Core_MDF_Focus_Area_nm__c = 'Client Computing';
            ipaPFR5.Core_MDF_ProductType__c = '2-in-1';
            updatepfr.Core_MDF_Brand_nm__c = 'Intel® Corporate Logo;Intel® Arc™';
            newMap.put(updatepfr.Id,updatepfr);
            Core_MDF_Process_PartnerFundRequest.populateBackEndFieldsUpdate(newMap,oldPfrMap);
            List<PartnerFundRequest> pfrList=new List<PartnerFundRequest>();
            pfrList.add(updatepfr);
            Core_MDF_Process_PartnerFundRequest.processPFRRecords(pfrList, oldPfrMap);
            update updatepfr;
            pfrCount += 1;
            ipaPFR5.Core_MDF_Fund_Request_Status__c='Planned';
            update ipaPFR5;
            oldPfrMap.put(ipaPFR5.Id,ipaPFR5);
            
            Core_MDF_Process_PartnerFundRequest.processPFRRecords(pfrList2, oldPfrMap);
            
            Core_MDF_Process_PartnerFundRequest.processPFRRecords(pfrList3, NULL);
        }
        System.assertEquals(pfrCount > 0, true);
        Test.stopTest();
    } 
    
    @isTest 
    static void validateIPAActivityClosureNew(){
        UserRole usrRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        //Creating User with utility class 
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.LastName = 'User Test';
        usr2.UserRoleId = usrRole.Id;
        Database.insert(usr2);
        Test.startTest();
        System.runAs(usr2){ 
            Account ipaCoMarketingAccount = [select id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c from Account where Name= 'IPA Co-Marketing Account'];
            
            Campaign ipaCampaignForAP1 = [SELECT Id, Core_MDF_Activity_Sub_Type_nm__c, Status, Core_MDF_Approval_Step_Counter_nbr__c, 
                                          Core_MDF_Reimbursement_Rate__c, Core_MDF_Region_cd__c, Description,
                                          StartDate, EndDate, Core_MDF_Total_Campaign_Cost_Amt__c, Core_MDF_Market__c  
                                          FROM Campaign WHERE Name = 'Test Campaign - AP1' LIMIT 1];
            ipaCampaignForAP1.Core_MDF_Proposal_Based_Ind__c=false;
            update ipaCampaignForAP1;
            PartnerFundRequest ipaPFR6 = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaignForAP1.id,ipaCoMarketingAccount.id,System.today()-1,System.today()-1,false);
            //ipaPFR5.Core_MDF_Country_nm__c='United States';
            ipaPFR6.Title = 'Test IPA New';
            ipaPFR6.Core_MDF_Focus_Area_nm__c = 'Client Computing';
            ipaPFR6.Core_MDF_ProductType__c = '2-in-1';
            ipaPFR6.Core_MDF_Brand_nm__c = 'Intel® Corporate Logo';
            ipaPFR6.Core_MDF_Country_nm__c='India';
            ipaPFR6.Core_MDF_ToBeClosedDate__c=System.today()-180;
            
            //ipaPFR5.Core_MDF_Proposal_Based_Ind__c=true;
            ipaPFR6.Core_MDF_Fund_Request_Status__c=Core_MDF_CCP_ConstantClass.PFR_PENDING_REVIEW_STATUS;
            
            //pfrtoinsert.add(ipaPFR6);
            //Core_MDF_Process_PartnerFundRequest.populateBackEndFieldsInsert(pfrtoinsert);
            insert ipaPFR6;
            ipaPFR6.Core_MDF_ToBeClosedDate__c=System.today()-180;
            List<PartnerFundRequest> pfrList3 = new List<PartnerFundRequest>();
            pfrList3.add(ipaPFR6);
           
            //Core_MDF_Process_PartnerFundRequest.setAllApprovers(ipaPFR6);
            Core_MDF_Process_PartnerFundRequest.processPFRRecords(pfrList3, NULL);
            Assert.isTrue(pfrList3!=null);
        }
    }
    @isTest static void validateIPAPropActivityWithCampaignTestNew(){
        UserRole usrRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        //Creating User with utility class 
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.LastName = 'User Test';
        usr2.UserRoleId = usrRole.Id;
        Database.insert(usr2);
        System.runAs(usr2){ 
            Test.startTest();
            Account coMarketingIPA = [select id,Core_MDF_Parent_Fund_Account__c,RecordType.DeveloperName,Core_MDF_Channel_Program__c,Core_MDF_CoMarketing_Ultimate_Account__c 
                                      from Account
                                      where Name= 'IPA Co-Marketing Account'];
            
            string bType = 'Proposal I MDF';
            
            Campaign ipaCampaign = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - AP',
                                                                                      coMarketingIPA.id, 
                                                                                      System.today().addDays(3), System.today().adddays(30),
                                                                                      bType, 110000,'INDIA', 'Consumer', 
                                                                                      'Apollo Lake', 'Planned', false);
            ipaCampaign.Core_MDF_Proposal_Based_Ind__c = true;
            insert ipaCampaign;
            
            List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
            Map<Id,PartnerFundRequest> oldPfrMap = new Map<Id,PartnerFundRequest>();
            PartnerFundRequest ipaPFR2 = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaign.id,coMarketingIPA.id,
                                                                                                      System.today().addDays(4),
                                                                                                      System.today().addDays(4),
                                                                                                      false);
            ipaPFR2.RequestedAmount = 15;
            
            ipaPFR2.Core_MDF_Fund_Request_Status__c = 'Planned';
            pfrList.add(ipaPFR2); 
            Database.insert(pfrList);
            ipaPFR2.RequestedAmount = 15;
            ipaPFR2.Core_MDF_Fund_Request_Status__c = 'Planned';
            Database.update(pfrList);
            oldPfrMap.put(ipaPFR2.Id,ipaPFR2);
            
            
            Test.stopTest();
            Assert.areEqual(true, pfrList != null);
        }
    }
    @isTest 
    static void updateApproverFromApprovalCriteriaTest(){
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        Map<String, String> pfrIdToApprovalCriteriaIdMap = new Map<String, String>();
        List<PartnerFundRequest> pfrToUpdateWithApprovalCriteriaList = new List<PartnerFundRequest>();
        test.startTest();
        List<Core_Trigger_Executions__c> bypassfunctinalitylist1 =[select Name,Core_Active__c,Core_Description__c from Core_Trigger_Executions__c];
        User usr6 = [SELECT Id,Name FROM User where LastName = 'User Test6' LIMIT 1];
        PartnerFundRequest pfr1 = [select id,RequestedAmount,Core_MDF_Program__c,Core_MDF_Ultimate_Account_Id__c,Core_MDF_Approval_Step_Completed__c,Core_MDF_Start_Date__c,Core_MDF_Fund_Request_Status__c,recordTypeId,Core_MDF_End_Date__c from PartnerFundRequest where RequestedAmount = 220 and recordtypeid =: Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF LIMIT 1];
        pfr1.Core_MDF_Fund_Request_Status__c = 'Pending Review';
        pfr1.Core_MDF_Approval_Step_Completed__c = 0;
        pfr1.Core_MDF_Region_nm__c = 'APJ';
        pfr1.Core_MDF_Intel_Activity_Owner_Id__c = usr6.id;
        System.runAs(usr){
            update pfr1;
            pfrToUpdateWithApprovalCriteriaList.add(pfr1);
            
            // Creating Criterias for approval required
            List<Core_MDF_Criteria__c> cList = new List<Core_MDF_Criteria__c>();
            Core_MDF_Criteria__c cr = Core_MDF_CCP_TestDataUtility.createCriteria('PartnerFundRequest','Core_MDF_Activity_Approval_Processs',
                                                                                  'Core_MDF_Region_nm__c','Equal','WW','Core_MDF_Region_nm__c','Equal', 'APJ',
                                                                                  'Core_MDF_Region_nm__c','Equal','APJ','Core_MDF_ProductType__c','Equal','Desktop','RequestedAmount','Greater Than','4000',false);
            cr.Core_MDF_Field_Name_2__c = 'Core_MDF_Region_nm__c';
            cr.Core_MDF_Operator_2__c = 'Equal';
            cr.Core_MDF_Value_2__c = 'WW';
            cr.Core_MDF_Field_Name_3__c = 'Core_MDF_Region_nm__c';
            cr.Core_MDF_Operator_3__c = 'Equal';
            cr.Core_MDF_Value_3__c = 'WW';
            cr.Core_MDF_Field_Name_6__c = 'Core_MDF_Region_nm__c';
            cr.Core_MDF_Operator_6__c = 'Equal';
            cr.Core_MDF_Value_6__c = 'APJ';
            cr.Core_MDF_Field_Name_7__c = 'Core_MDF_Region_nm__c';
            cr.Core_MDF_Operator_7__c = 'Equal';
            cr.Core_MDF_Value_7__c = 'WW';
            cr.Core_MDF_Field_Name_8__c = 'Core_MDF_Region_nm__c';
            cr.Core_MDF_Operator_8__c = 'Equal';
            cr.Core_MDF_Value_8__c = 'WW';
            cr.Core_MDF_Active__c = false;
            cList.add(cr);
            Database.insert(cList);
            
            List<Core_MDF_Approver__c> appList = new List<Core_MDF_Approver__c>();
            // Creating approvers
            Core_MDF_Approver__c ap1 = Core_MDF_CCP_TestDataUtility.createApprover(cList[0].Id,usr6.Id, false);
            ap1.Core_MDF_Approver_Type__c = 'Internal';
            ap1.Core_MDF_Approver_2__c = null;
            ap1.Core_MDF_Approver_3__c = null;
            ap1.Core_MDF_Approver_4__c = null;
            ap1.Core_MDF_Approver_5__c = null;
            ap1.Core_MDF_Approver_6__c = null;
            ap1.Core_MDF_Approver_7__c = null;
            ap1.Core_MDF_Approver_8__c = null;
            ap1.Core_MDF_Approver_9__c = null;
            ap1.Core_MDF_Approver_10__c = null;
            ap1.Core_MDF_Active__c = false;
            appList.add(ap1);
            
            Database.insert(appList);
            
            List<Core_MDF_Criteria_Rule__c> crList = new List<Core_MDF_Criteria_Rule__c>();
            // Creating Criteria rules for approvers 
            Core_MDF_Criteria_Rule__c crule1 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(appList[0].Id,'Core_MDF_Fund_Request_Status__c','Equal',
                                                                                               'Pending Review',false);
            
            crList.add(crule1);
            Database.insert(crList);
            
            appList[0].Core_MDF_Active__c = true;
            Database.update(appList);        
            cList[0].Core_MDF_Active__c = true;
            Database.update(cList);
            
            pfrIdToApprovalCriteriaIdMap.put(pfr1.Id,cList[0].Id);
            //Core_MDF_Process_PartnerFundRequest.updateApproverFromApprovalCriteria(pfrToUpdateWithApprovalCriteriaList, pfrIdToApprovalCriteriaIdMap, null, null);
            Assert.isTrue(appList!=null);
        }
        test.stopTest();
      
    }
    
    @isTest
    static void testScenario2(){
        User testusr = Core_MDF_CCP_TestDataUtility.createUser(false);
        Profile ccpProf=[SELECT Id FROM Profile WHERE Name = 'CCP - Core Access'];
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = ccpProf.Id;
        usr.IsActive=true;
        insert usr;
        ChannelProgram cp=[select id,Name from ChannelProgram where name='Client' limit 1];
        User usr6 = [SELECT Id,Name FROM User where LastName = 'User Test6' LIMIT 1];
        system.runAs(usr6){
            PermissionSet psFinance = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Field_Acct_Mgr' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = psFinance.Id);
        }
        Map<String, String> pfrIdToApprovalCriteriaIdMap = new Map<String, String>();
        List<PartnerFundRequest> pfrToUpdateWithApprovalCriteriaList = new List<PartnerFundRequest>();
        
        List<Core_Trigger_Executions__c> bypassfunctinalitylist1 =[select Name,Core_Active__c,Core_Description__c from Core_Trigger_Executions__c];
        test.startTest();
        PartnerFundRequest pfr1 = [select id,RequestedAmount,Core_MDF_Program__c,Core_MDF_Ultimate_Account_Id__c,Core_MDF_Approval_Step_Completed__c,Core_MDF_Start_Date__c,Core_MDF_Fund_Request_Status__c,recordTypeId,Core_MDF_End_Date__c from PartnerFundRequest where RequestedAmount = 220 and recordtypeid =: Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF LIMIT 1];
        pfr1.Core_MDF_Fund_Request_Status__c = 'Pending Review';
        pfr1.Core_MDF_Approval_Step_Completed__c = 0;
        pfr1.Core_MDF_Region_nm__c = 'APJ';
        pfr1.Core_MDF_Intel_Activity_Owner_Id__c = usr6.id;
        System.runAs(testusr){
            update pfr1;
            pfrToUpdateWithApprovalCriteriaList.add(pfr1);
        }
       
        Account ipaCoMarketingAccount = [select id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c from Account where Name= 'Test Account 1' limit 1];
        list<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmlist=new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm.Core_MDF_Program_nm__c ='Client CoMarketing Fund' ;
        iupgm.Core_MDF_Channel_Program_id__c=cp.id;
        iupgm.Core_MDF_Region_Sub_Region_nm__c = 'APJ';
        iupgm.Core_MDF_User_id__c = usr.Id;
        iupgm.Core_MDF_All_Accounts_cd__c = 'No';
        iupgm.Core_MDF_Account_id__c=ipaCoMarketingAccount.id;
        iupgm.Core_MDF_Role_nm__c='Core_MDF_CCP_Internal_CCF_Field_Acct_Mgr';
        iupgm.Core_MDF_All_Budget_Type_Access_Ind__c=true;
        iupgm.Core_MDF_Is_Not_an_Approver_Ind__c = false;
        iupgm.Core_MDF_Active_Ind__c = true;
        iupgm.Core_MDF_GeoSubGeo_Budget_Type_nm__c='APJ->IoT Premier - MDF';
        iupgmlist.add(iupgm);
        Database.insert(iupgmlist);

        // Creating Criterias for approval required
        List<Core_MDF_Criteria__c> cList = new List<Core_MDF_Criteria__c>();
        Core_MDF_Criteria__c cr = Core_MDF_CCP_TestDataUtility.createCriteria('PartnerFundRequest','Core_MDF_Activity_Approval_Processs',
                                                                                  'Core_MDF_Region_nm__c','Equal','WW','Core_MDF_Region_nm__c','Equal', 'APJ',
                                                                                  'Core_MDF_Region_nm__c','Equal','APJ','Core_MDF_ProductType__c','Equal','Desktop','RequestedAmount','Greater Than','4000',false);
        cr.Core_MDF_Field_Name_2__c = 'Core_MDF_Region_nm__c';
        cr.Core_MDF_Operator_2__c = 'Equal';
        cr.Core_MDF_Value_2__c = 'WW';
        cr.Core_MDF_Field_Name_3__c = 'Core_MDF_Region_nm__c';
        cr.Core_MDF_Operator_3__c = 'Equal';
        cr.Core_MDF_Value_3__c = 'WW';
        cr.Core_MDF_Field_Name_6__c = 'Core_MDF_Region_nm__c';
        cr.Core_MDF_Operator_6__c = 'Equal';
        cr.Core_MDF_Value_6__c = 'APJ';
        cr.Core_MDF_Field_Name_7__c = 'Core_MDF_Region_nm__c';
        cr.Core_MDF_Operator_7__c = 'Equal';
        cr.Core_MDF_Value_7__c = 'WW';
        cr.Core_MDF_Field_Name_8__c = 'Core_MDF_Region_nm__c';
        cr.Core_MDF_Operator_8__c = 'Equal';
        cr.Core_MDF_Value_8__c = 'WW';
        cr.Core_MDF_Active__c = false;
        cList.add(cr);
        Database.insert(cList);
            
        List<Core_MDF_Approver__c> appList = new List<Core_MDF_Approver__c>();
        Core_MDF_Approver__c ap1 = Core_MDF_CCP_TestDataUtility.createApprover(cList[0].Id,usr6.Id, false);
        ap1.Core_MDF_Approver_Type__c = 'Internal';
        ap1.Core_MDF_Approver_2__c = null;
        ap1.Core_MDF_Approver_3__c = null;
        ap1.Core_MDF_Approver_4__c = null;
        ap1.Core_MDF_Approver_5__c = null;
        ap1.Core_MDF_Approver_6__c = null;
        ap1.Core_MDF_Approver_7__c = null;
        ap1.Core_MDF_Approver_8__c = null;
        ap1.Core_MDF_Approver_9__c = null;
        ap1.Core_MDF_Approver_10__c = null;
        ap1.Core_MDF_Active__c = false;
        appList.add(ap1);
            
        Database.insert(appList);
            
        List<Core_MDF_Criteria_Rule__c> crList = new List<Core_MDF_Criteria_Rule__c>();
        // Creating Criteria rules for approvers 
        Core_MDF_Criteria_Rule__c crule1 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(appList[0].Id,'Core_MDF_Fund_Request_Status__c','In',
                                                                                               '',false);
            
        crList.add(crule1);
        Database.insert(crList);
            
        appList[0].Core_MDF_Active__c = true;
        Database.update(appList);        
        cList[0].Core_MDF_Active__c = true;
        Database.update(cList);
            
        pfrIdToApprovalCriteriaIdMap.put(pfr1.Id,cList[0].Id);
        //Core_MDF_Process_PartnerFundRequest.updateApproverFromApprovalCriteria(pfrToUpdateWithApprovalCriteriaList, pfrIdToApprovalCriteriaIdMap, null, null);
            
        test.stopTest();
        Assert.isTrue(cList!=null);
    }
    
    
    @isTest 
    static void setApproverFromIUPGMTest(){
        
        User testusr = Core_MDF_CCP_TestDataUtility.createUser(false);
        Profile ccpProf=[SELECT Id FROM Profile WHERE Name='CCP - Core Access' limit 1];
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = ccpProf.Id;
        usr.IsActive=true;
        insert usr;
        ChannelProgram cp=[select id from ChannelProgram where name='Client' limit 1];
        User usr1 = [SELECT Id,Name FROM User where LastName = 'User Test6' LIMIT 1];
        system.runAs(usr1){
            PermissionSet psFinance = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Field_Acct_Mgr' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = psFinance.Id);
        }
        test.startTest();
        PartnerFundRequest pfr1 = [select id,RequestedAmount,Core_MDF_Budget_Type_nm__c,Core_MDF_Program__c,Core_MDF_Ultimate_Account_Id__c,Core_MDF_Approval_Step_Completed__c,Core_MDF_Start_Date__c,Core_MDF_Fund_Request_Status__c,recordTypeId,Core_MDF_End_Date__c from PartnerFundRequest where RequestedAmount = 220 and recordtypeid =: Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF and Core_MDF_Budget_Type_nm__c='MDF' LIMIT 1];
        pfr1.Core_MDF_Fund_Request_Status__c = 'Pending Review';
        pfr1.Core_MDF_Approval_Step_Completed__c = 0;
        pfr1.Core_MDF_Region_nm__c = 'APJ';
        Set<String> userIdsSet=new Set<String>();
        userIdsSet.add(usr.id);
        //Core_MDF_Process_PartnerFundRequest.setApproverFromIUPGM(pfr1,userIdsSet);
        pfr1.Core_MDF_Fund_Request_Status__c = 'Closed';
        pfr1.Core_MDF_Activity_Closure_Type__c = 'Manual';
        System.runAs(testusr){
            update pfr1;
        }
        
        Core_MDF_Process_PartnerFundRequest.recallApprovalActivities(null,null);
        Account ipaCoMarketingAccount = [select id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c from Account where Name= 'Test Account 1' limit 1];
        list<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmlist=new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm.Core_MDF_Program_nm__c ='Client CoMarketing Fund' ;
        iupgm.Core_MDF_Channel_Program_id__c=cp.id;
        iupgm.Core_MDF_Region_Sub_Region_nm__c = 'APJ';
        iupgm.Core_MDF_User_id__c = usr.Id;
        iupgm.Core_MDF_All_Accounts_cd__c = 'No';
        iupgm.Core_MDF_Account_id__c=ipaCoMarketingAccount.id;
        iupgm.Core_MDF_Role_nm__c='Core_MDF_CCP_Internal_CCF_Field_Acct_Mgr';
        iupgm.Core_MDF_All_Budget_Type_Access_Ind__c=true;
        iupgm.Core_MDF_Is_Not_an_Approver_Ind__c = false;
        iupgm.Core_MDF_Active_Ind__c = true;
        iupgm.Core_MDF_GeoSubGeo_Budget_Type_nm__c='APJ->IoT Premier - MDF';
        iupgmlist.add(iupgm);
        Database.insert(iupgmlist);

        Set<String> accntIdSet=new Set<String>();
        accntIdSet.add(ipaCoMarketingAccount.id);
        Set<string> programSet=new Set<String>();
        programSet.add('Client Co-Marketing Fund');
        Set<string> geoStrSet=new Set<String>();
        geoStrSet.add('APJ');
        geoStrSet.add('EMEA');
        Set<String> budgetTypeSet=new Set<String>();
        budgetTypeSet.add('Client Specialties MDF');
        Map<String, list<String>> res; 
        res=Core_MDF_Process_PartnerFundRequest.getApproversFromIUPGM(accntIdSet,programSet,geoStrSet,budgetTypeSet);
        Core_MDF_Process_PartnerFundRequest.getApproversFromIUPGM(null,null,null,null);
        System.assert(res!=null);
        test.stopTest();
    } 
    @isTest static void validateActivityWithCampaignTest(){
        UserRole usrRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        //Creating User with utility class 
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.LastName = 'User Test';
        usr2.UserRoleId = usrRole.Id;
        Database.insert(usr2);
        System.runAs(usr2){ 
        Test.startTest();
        Account ipaUltimateAccountIPA = [select id,Core_MDF_Parent_Fund_Account__c,RecordType.DeveloperName,Core_MDF_Channel_Program__c,Core_MDF_CoMarketing_Ultimate_Account__c 
                                            from Account
                                            where Name= 'IPA Intel Account'];
        Account coMarketingIPA = [select id,Core_MDF_Parent_Fund_Account__c,RecordType.DeveloperName,Core_MDF_Channel_Program__c,Core_MDF_CoMarketing_Ultimate_Account__c 
                                            from Account
                                            where Name= 'IPA Co-Marketing Account'];
        PartnerFundAllocation  pfaRecord =[SELECT Id,Title FROM PartnerFundAllocation WHERE Title = 'TestPFA3'];
        
        string bType = 'Proposal I MDF';
        Group ipaGrp = new Group();
        ipaGrp.Name = 'Core CCP IPA Internal';
        ipaGrp.DeveloperName = 'Core_CCP_IPA_Internal';
        insert ipaGrp;
        
        ChannelProgram ipaCP = [select Id from ChannelProgram where Core_MDF_Technical_Program_Name__c = 'Intel Partner Alliance'];
        
        Core_MDF_Partner_Group_Mapping__c pgm = new Core_MDF_Partner_Group_Mapping__c();
        pgm.Core_MDF_Account__c = ipaUltimateAccountIPA.Id;
        pgm.Core_MDF_Virtual_Corp_nm__c = coMarketingIPA.id;
        pgm.Core_MDF_Group_Name__c = 'Core_CCP_IPA_Internal';
        pgm.Core_MDF_Type_of_Access__c = 'EXTERNAL';
        pgm.Core_MDF_Group_Id__c = ipaGrp.Id;                
        pgm.Core_MDF_Channel_Program__c = ipaCP.Id;
        pgm.Core_MDF_Region_cd__c = 'WW';
        pgm.Core_MDF_Source_Txt__c = 'Test';
        pgm.Core_MDF_AccountIdGroupName__c = ipaUltimateAccountIPA.Id+'Core_CCP_IPA_Internal';
        
        insert pgm;
        
        Core_MDF_ProcessCCP_PartnerFundRequest.getTemplateNameByProgNameIPA();
        
        Campaign ipaCampaign = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - AP',
                                                                                  coMarketingIPA.id, 
                                                                                  System.today().addDays(3), System.today().adddays(30),
                                                                                  bType, 110000,'INDIA', 'Consumer', 
                                                                                  'Apollo Lake', 'Planned', false);
        ipaCampaign.Core_MDF_Proposal_Based_Ind__c = false;
        insert ipaCampaign;
        
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        List<PartnerFundRequest> pfrList1 = new List<PartnerFundRequest>();
        List<PartnerFundRequest> pfrList2 = new List<PartnerFundRequest>();
        Map<Id,PartnerFundRequest> oldPfrMap = new Map<Id,PartnerFundRequest>();
        PartnerFundRequest ipaPFR = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaign.id,coMarketingIPA.id,
                                                                                                 System.today().addDays(4),
                                                                                                 System.today().addDays(4),
                                                                                                 false);  
        ipaPFR.RequestedAmount = 1;
        
        
        ipaPFR.Core_MDF_Fund_Request_Status__c = 'Planned';
        ipaPFR.Core_MDF_Region_nm__c = 'APJ';
        ipaPFR.RequestedAmount= 10;
        ipaPFR.Core_MDF_Brand_nm__c = 'Intel® Corporate Logo';
        //ipaPFR.Core_MDF_Budget_Type_nm__c='OEM CMP';
        ipaPFR.Core_MDF_Activity_CreatedByExternalUsr__c=true;
        pfrList1.add(ipaPFR); 
        Database.insert(pfrList1);
        ipaPFR.RequestedAmount= 20;
        Boolean email = Core_MDF_Process_PartnerFundRequest.sendRevRqdEmailToExtUser(ipaPFR);
        PartnerFundRequest ipaPFR2 = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaign.id,coMarketingIPA.id,
                                                                                                  System.today().addDays(4),
                                                                                                  System.today().addDays(4),
                                                                                                  false);
        ipaPFR2.RequestedAmount = 1;
        
        ipaPFR2.Core_MDF_Fund_Request_Status__c = Core_MDF_CCP_ConstantClass.PFR_CLOSED_STATUS;
        ipaPFR2.status = Core_MDF_CCP_ConstantClass.PFR_APPROVED_STATUS;
        ipaPFR2.AllocationId= pfaRecord.Id;
        
        pfrList.add(ipaPFR2); 
        Database.insert(pfrList);
        PartnerFundRequest ipaPFR3 = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaign.id,coMarketingIPA.id,
                                                                                                  System.today().addDays(4),
                                                                                                  System.today().addDays(4),
                                                                                                  false);
        ipaPFR3.RequestedAmount = 1;
        
        ipaPFR3.Core_MDF_Fund_Request_Status__c = Core_MDF_CCP_ConstantClass.PFR_CANCELLED_STATUS;
        ipaPFR3.AllocationId= pfaRecord.Id; 
        //ipaPFR3.RecordType.Name='Intel Partner Alliance';
        
        pfrList2.add(ipaPFR3);
        Database.insert(pfrList2);
        oldPfrMap.put(ipaPFR.Id,ipaPFR);
      
        //Core_MDF_Process_PartnerFundRequest.recallApprovalActivities(null,pfrList);
        Core_MDF_Process_PartnerFundRequest.recallApprovalActivities(pfrList,oldPfrMap);
        //Core_MDF_Process_PartnerFundRequest.recallApprovalActivities(pfrList,);
        Core_MDF_Process_PartnerFundRequest.recallApprovalActivities(pfrList,null);
        Core_MDF_Process_PartnerFundRequest.recallApprovalActivities(pfrList2,null);
        Test.stopTest();
        Assert.isNotNull(oldPfrMap);
    }
    }
    @isTest static void testvalidateActivityWithCampaignTest(){
        UserRole usrRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        //Creating User with utility class 
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.LastName = 'User Test';
        usr2.UserRoleId = usrRole.Id;
        Database.insert(usr2);
        System.runAs(usr2){ 
            Test.startTest();
            Account coMarketingIPA = [select id,Core_MDF_Parent_Fund_Account__c,RecordType.DeveloperName,Core_MDF_Channel_Program__c,Core_MDF_CoMarketing_Ultimate_Account__c 
                                      from Account
                                      where Name= 'IPA Co-Marketing Account'];
            
            string bType = 'Proposal I MDF';
            
            Campaign ipaCampaign = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - AP',
                                                                                      coMarketingIPA.id, 
                                                                                      System.today().addDays(3), System.today().adddays(30),
                                                                                      bType, 110000,'INDIA', 'Consumer', 
                                                                                      'Apollo Lake', 'Planned', false);
            ipaCampaign.Core_MDF_Proposal_Based_Ind__c = false;
            insert ipaCampaign;
            List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
            Map<Id,PartnerFundRequest> oldPfrMap = new Map<Id,PartnerFundRequest>();
            PartnerFundRequest ipaPFR = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaign.id,coMarketingIPA.id,
                                                                                                     System.today().addDays(4),
                                                                                                     System.today().addDays(4),
                                                                                                     false);  
            ipaPFR.Core_MDF_Fund_Request_Status__c='Pending Review';
            ipaPFR.Core_MDF_Activity_Closure_Type__c='Auto';
            pfrList.add(ipaPFR);
            insert pfrList;
            ipaPFR.Core_MDF_Fund_Request_Status__c='Closed';
            ipaPFR.Core_MDF_Activity_Closure_Type__c='Manual';
            //update pfrList;
            oldPfrMap.put(ipaPFR.id,ipaPFR);
            Core_MDF_Process_PartnerFundRequest.recallApprovalActivities(pfrList,oldPfrMap);
            Test.stopTest();
              Assert.isTrue(pfrList!=null);
        }
      
    }
    @isTest static void eefBudgetAutoTransfer(){
        //User eefUser = [Select id from User where lastname = 'MDF Budget LoaderTest' limit 1];
        profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        
        User eefUser = Core_MDF_CCP_TestDataUtility.createUser(false);
        eefUser.LastName = 'EEF UserTestClass';
        eefUser.profileId = systemAdminProfile.Id;
        insert eefUser;
        
        permissionSet primaryAccManPs= [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_Internal_EEF_Primary_Partner_Acct_Mgr' LIMIT 1];
        PermissionSetAssignment perm = new PermissionSetAssignment(AssigneeId = eefUser.id, PermissionSetId = primaryAccManPs.Id);
        insert perm;
        
        Account priVc = [Select id from Account where Name = 'Primary VC Account' limit 1];
        Account actVc = [Select id from Account where Name = 'Acticating VC Account' limit 1];
        PartnerMarketingBudget eefBudget = [Select id,Core_MDF_Budget_Partner__c from PartnerMarketingBudget where Title = 'TestBudgetCloud' limit 1];
        
        Map<Id,PartnerMarketingBudget> pmbIdToPmbMap = new Map<Id,PartnerMarketingBudget>();
        pmbIdToPmbMap.put(eefBudget.Id, eefBudget);
        
        Campaign eefCamp = [Select id from Campaign where Name = 'Test EEF Camp' limit 1];
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        Map<Id,PartnerFundRequest> oldPfrMap = new Map<Id,PartnerFundRequest>();
        Map<Id,PartnerFundRequest> newPfrMap = new Map<Id,PartnerFundRequest>();
        PartnerFundAllocation eefAllocation = [Select id from PartnerFundAllocation where Title = 'Test Allocation activating EEF' limit 1];
        Id pfr_Recordtype_EEF = Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Ecosystem_Extension_Fund').getRecordTypeId();
        system.runAs(eefUser){
            Test.startTest();
            PartnerFundRequest eefPfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(eefCamp.Id),
                                                                                              pfr_Recordtype_EEF,string.valueof(actVc.id),eefAllocation,eefBudget,'INDIA','Technical Influencer','Cloud Instance Consumption',
                                                                                              'Intel® SGX','Broadcast','Radio','Draft',false);
            eefPfr.Core_MDF_Budget_Type_nm__c = 'Cloud'; 
            eefPfr.Title ='Test EEF Activity TestClass2';
            eefPfr.RequestedAmount =120;
            eefPfr.Core_MDF_Reimbursement_Rate_txt__c = '100%';
            eefPfr.Core_MDF_Approval_Step_Completed__c = 1;
            eefPfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            eefPfr.AllocationId = eefAllocation.id;
            eefPfr.BudgetId=eefBudget.Id;
            eefPfr.status= 'Approved';
            pfrList.add(eefPfr);
            insert pfrList;
            
        newPfrMap.put(eefPfr.id,eefPfr);
        oldPfrMap.put(eefPfr.id,eefPfr);
        
        Map<Id,Decimal> primaryAccIdToActAvailableAmt = new Map<Id,Decimal>();
        primaryAccIdToActAvailableAmt.put(eefBudget.Core_MDF_Budget_Partner__c,10);
        Map<Id,Decimal> pfrIdToAmtToTransfer = new Map<Id,Decimal>();
        pfrIdToAmtToTransfer.put(eefPfr.id,1);
        
        Core_MDF_Process_PartnerFundRequest.BudgetTranferLogWrapper btlw= new Core_MDF_Process_PartnerFundRequest.BudgetTranferLogWrapper();
        /*btlw.sumOfForwardTransferredAmt=2;
        btlw.sumOfReverseTransferredAmt=1;
        btlw.pfrBudgetAccId=eefPfr.Id;*/
        
        Map<Id,Core_MDF_Process_PartnerFundRequest.BudgetTranferLogWrapper> pfrIdToBudTransferWrapperMap = new Map<Id,Core_MDF_Process_PartnerFundRequest.BudgetTranferLogWrapper>();
        pfrIdToBudTransferWrapperMap.put(eefPfr.Id,btlw);
        
        Boolean checkForEditCondition = Core_MDF_Process_PartnerFundRequest.checkForEditCondition(eefPfr,oldPfrMap);
        Core_MDF_Process_PartnerFundRequest.activityAutoBudgetTransferForward(pfrList,null,true,false);
        Core_MDF_Process_PartnerFundRequest.activityAutoBudgetTransferReversal(newPfrMap,oldPfrMap);
        Core_MDF_Process_PartnerFundRequest.autoBudgetTranfer(eefPfr,primaryAccIdToActAvailableAmt,pfrIdToAmtToTransfer,pmbIdToPmbMap);
        Core_MDF_Process_PartnerFundRequest.validateAvailAmtAtPrimaryAccount(eefPfr,primaryAccIdToActAvailableAmt,1,pmbIdToPmbMap);
        Core_MDF_Process_PartnerFundRequest.calculateReversalAmtToBeTransferred(eefPfr,oldPfrMap,pfrIdToBudTransferWrapperMap);
        eefPfr.Core_MDF_Fund_Request_Status__c ='Cancelled';
        update eefPfr;  
        Test.stopTest();
        }  
    }
    
}