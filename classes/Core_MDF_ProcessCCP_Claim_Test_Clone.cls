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
private class Core_MDF_ProcessCCP_Claim_Test_Clone
{
@TestSetup static void setUpData(){ 
        List<User> userList = new List<User>();
        List<ChannelProgram> channelProgramList = new List<ChannelProgram>();
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        List<PartnerFundClaim> claimListToBeProcessed = new List<PartnerFundClaim>();
        List<PartnerFundAllocation> pfaList = new List<PartnerFundAllocation>();        
        List<Group> groupList = new List<Group>();
        List<Account> comarketingAccountsList = new List<Account>();
        List<PartnerMarketingBudget> pmbList = new List<PartnerMarketingBudget>();
        List<Campaign> campaignList = new List<Campaign>();
        List<Core_MDF_Account_Bank_Mapping__c> accBankMappingList = new List<Core_MDF_Account_Bank_Mapping__c>();
        List<Account> intelAccList = new List<Account>();
        
        Id acctRecord_Type = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
        Account acc = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test IPA Accounttest', acctRecord_Type, false);
        acc.Core_MDF_CoMarketingActive__c = false;
        insert acc;                
    
        System.debug('SetupLimitSoql-AfterOPIDaccount' +Limits.getQueries());
        // Creating Intel Account with utility class
        Account dellCorpAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('Dell Corporation', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        dellCorpAccount.Core_Geo__c = 'EMEA';
        intelAccList.add(dellCorpAccount);
        // Creating Account with utility class
        Account ipaUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test IPA Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        ipaUltimateAccount.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        ipaUltimateAccount.Core_MDF_CoMarketingActive__c = true;
        ipaUltimateAccount.Core_IPA_One_Partner_Id__c=acc.id;
        intelAccList.add(ipaUltimateAccount);
        Database.insert(intelAccList);
        System.debug('SetupLimitSoql-Afterinsert-intelaccount-line43' +Limits.getQueries());
        // Updating Accounts 
        ipaUltimateAccount.isPartner = true;
        Database.update(ipaUltimateAccount);
        System.debug('SetupLimitSoql-AfterUpdate-intelaccount-line47' +Limits.getQueries());
        
        // Creating Contact for Partner User
        Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(dellCorpAccount.Id,false);
        Database.insert(conRecord1);
        System.debug('SetupLimitSoql-AfterInsert-Contact-line47' +Limits.getQueries());
        // Creating a map of PS names and PS
        Map<String,PermissionSet> nameToPerSet = new Map<String,PermissionSet>();
        for(PermissionSet pSet:[SELECT Id,Name FROM PermissionSet WHERE Name IN ('Core_MDF_CCP_Internal_Program_Adm',
                            'Core_MDF_CCP_Internal_Claim_Case_Reviewer',
                            'Core_MDF_CCP_Internal_APJ_User',
                            'Core_MDF_CCP_Internal_Payment_Schedule_Admin',
                            'Core_MDF_CCP_Internal_Retail_Payment_Adm',
                            'Core_MDF_CCP_Internal_IPA_Payment_Adm',
                            'View_All_Data',
                            'Core_MDF_CCP_Internal_CCF_Payment_Adm')]) {
            nameToPerSet.put(pSet.Name,pSet);
        }
        
        // Assigning PS to each variable
        PermissionSet progAdmPS = nameToPerSet.get('Core_MDF_CCP_Internal_Program_Adm');
        PermissionSet clmCaseUsr = nameToPerSet.get('Core_MDF_CCP_Internal_Claim_Case_Reviewer');        
        PermissionSet paymentAdmGeoPS = nameToPerSet.get('Core_MDF_CCP_Internal_APJ_User'); 
        PermissionSet paymentAdmSchedulePS = nameToPerSet.get('Core_MDF_CCP_Internal_Payment_Schedule_Admin'); 
        PermissionSet paymentAdmRMFPS = nameToPerSet.get('Core_MDF_CCP_Internal_Retail_Payment_Adm'); 
        PermissionSet ipaPaymentAdmPS = nameToPerSet.get('Core_MDF_CCP_Internal_IPA_Payment_Adm');
        PermissionSet ccpPSadmin = nameToPerSet.get('Core_MDF_CCP_Internal_CCF_Payment_Adm');
        PermissionSet viewAllDataPS = nameToPerSet.get('View_All_Data');
       
        // Creating a map of profile name and profile Id
        Map<String,Id> profileToId = new Map<String,Id>();
        for(Profile prfl:[SELECT Id,Name FROM Profile WHERE Name IN ('System Administrator','CCP - Core Access')]) {
            profileToId.put(prfl.Name,prfl.Id);
        }
        
        // Creating Users with utility class 
        User sysAdmUsr = Core_MDF_CCP_TestDataUtility.createUser(false);
        sysAdmUsr.Email = 'sysadmin@example.com';
        userList.add(sysAdmUsr);        
        
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false); 
        usr2.Email='testPayment@example.com';
        usr2.LastName='ProgAdmUser';
        usr2.profileId = profileToId.get('CCP - Core Access');
        usr2.IsActive = true;
        userList.add(usr2); 
        
        User usr3 = Core_MDF_CCP_TestDataUtility.createUser(false);  
        usr3.Email='testreviewer@example.com';
        usr3.LastName='ClaimCaseUser';
        usr3.profileId = profileToId.get('CCP - Core Access');
        usr3.IsActive = true;
        userList.add(usr3);
        
        database.insert(userList);
        System.debug('SetupLimitSoql-AfterInsert-UserList-line102' +Limits.getQueries());                
        List<PermissionSetAssignment> permSetAssgnLst = new List<PermissionSetAssignment>();
        
        // Assigning Program Admin PS
        PermissionSetAssignment assignPermissionSetObj = new PermissionSetAssignment();
        assignPermissionSetObj.AssigneeId = usr2.Id;
        assignPermissionSetObj.PermissionSetId = progAdmPS.Id;
        permSetAssgnLst.add(assignPermissionSetObj);
        
        // Assigning CCF Payment Admin PS
        PermissionSetAssignment assignPermissionSetObj2 = new PermissionSetAssignment();
        assignPermissionSetObj2.AssigneeId = usr2.Id;
        assignPermissionSetObj2.PermissionSetId = ccpPSadmin.Id;
        permSetAssgnLst.add(assignPermissionSetObj2);
        
        // Assigning CCP Internal APJ User PS
        PermissionSetAssignment assignGeoPermissionSet = new PermissionSetAssignment();
        assignGeoPermissionSet.AssigneeId = usr2.Id;
        assignGeoPermissionSet.PermissionSetId = paymentAdmGeoPS.Id;
        permSetAssgnLst.add(assignGeoPermissionSet);
        
        // Assigning Payment Admin Schedule PS
        PermissionSetAssignment assignSchedulePermissionSet = new PermissionSetAssignment();
        assignSchedulePermissionSet.AssigneeId = usr2.Id;
        assignSchedulePermissionSet.PermissionSetId = paymentAdmSchedulePS.Id;
        permSetAssgnLst.add(assignSchedulePermissionSet);
        
        // Assigning RMF Payment Admin PS
        PermissionSetAssignment assignRMFPermissionSet = new PermissionSetAssignment();
        assignRMFPermissionSet.AssigneeId = usr2.Id;
        assignRMFPermissionSet.PermissionSetId = paymentAdmRMFPS.Id;
        permSetAssgnLst.add(assignRMFPermissionSet);
        
        // Assigning View All Data PS
        PermissionSetAssignment assignViewAllPermissionSet = new PermissionSetAssignment();
        assignViewAllPermissionSet.AssigneeId = usr2.Id;
        assignViewAllPermissionSet.PermissionSetId = viewAllDataPS.Id;
        permSetAssgnLst.add(assignViewAllPermissionSet);
        
        // Assigning Claim Case Reviewer PS
        PermissionSetAssignment assignPermissionSetObj1 = new PermissionSetAssignment();
        assignPermissionSetObj1.AssigneeId = usr3.Id;
        assignPermissionSetObj1.PermissionSetId = clmCaseUsr.Id;
        permSetAssgnLst.add(assignPermissionSetObj1);        
        
        system.runAs(sysAdmUsr){
            Database.insert(permSetAssgnLst);
            System.debug('SetupLimitSoql-AfterInsert-PSAssignment-line149' +Limits.getQueries());
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
        System.debug('SetupLimitSoql-AfterInsert-GroupList-line166' +Limits.getQueries());
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
        System.debug('SetupLimitSoql-AfterInsert-UserShare-line181' +Limits.getQueries());
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
        system.runAs(sysAdmUsr){
            insert gmList;
            System.debug('SetupLimitSoql-AfterInsert-GroupMember-line210' +Limits.getQueries());
            List<Core_Trigger_Executions__c> triggerExelist = new List<Core_Trigger_Executions__c>();
            Core_Trigger_Executions__c execution1 = new Core_Trigger_Executions__c();
            execution1.Name = 'BypassCampaignBenefitValidation';
            execution1.Core_Active__c = FALSE;
            execution1.Core_Class_Name__c = 'Core_MDF_IPA_Campaign_Functionality';
            execution1.Core_Description__c = 'BypassCampaignBenefitValidation';
            execution1.Core_Object__c = 'Campaign';
            execution1.Core_Trigger_Events__c = 'Before Update,Before Insert';
            triggerExelist.add(execution1);
            
            Core_Trigger_Executions__c setting = new Core_Trigger_Executions__c();
            setting.Core_Active__c = false;
            setting.Core_Class_Name__c = 'Core_MDF_AdjustmentClaimOffsetProcess';
            setting.Core_Description__c = 'Demo Description';
            setting.Core_Object__c = 'Core_MDF_Payment_Run__c';
            setting.Core_Trigger_Events__c = 'after insert';
            setting.name = 'Core_MDF_AdjustmentClaimOffsetProcess';
            triggerExelist.add(setting);
            
            Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution = new Core_Trigger_Executions__c();
            claimFunctionalityNameTriggerExecution.Core_Active__c = true;
            claimFunctionalityNameTriggerExecution.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
            claimFunctionalityNameTriggerExecution.Core_Trigger_Events__c = 'before insert,after update';
            claimFunctionalityNameTriggerExecution.Core_Object__c = 'PartnerFundClaim';
            claimFunctionalityNameTriggerExecution.Name = 'enableClaimsVATEligible';
            claimFunctionalityNameTriggerExecution.Core_Description__c = 'description';
            //Database.insert(claimFunctionalityNameTriggerExecution); 
            triggerExelist.add(claimFunctionalityNameTriggerExecution);
            
            Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution1 = new Core_Trigger_Executions__c();
            claimFunctionalityNameTriggerExecution1.Core_Active__c = true;
            claimFunctionalityNameTriggerExecution1.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
            claimFunctionalityNameTriggerExecution1.Core_Trigger_Events__c = 'before insert,after update';
            claimFunctionalityNameTriggerExecution1.Core_Object__c = 'PartnerFundClaim';
            claimFunctionalityNameTriggerExecution1.Name = 'enableClaimsVatAfterInsert';
            claimFunctionalityNameTriggerExecution1.Core_Description__c = 'description';
            triggerExelist.add(claimFunctionalityNameTriggerExecution1);
            
            Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution2 = new Core_Trigger_Executions__c();
            claimFunctionalityNameTriggerExecution2.Core_Active__c = true;
            claimFunctionalityNameTriggerExecution2.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
            claimFunctionalityNameTriggerExecution2.Core_Trigger_Events__c = 'before insert,after update';
            claimFunctionalityNameTriggerExecution2.Core_Object__c = 'PartnerFundClaim';
            claimFunctionalityNameTriggerExecution2.Name = 'enableClaimsVatAfterUpdate';
            claimFunctionalityNameTriggerExecution2.Core_Description__c = 'description';
            triggerExelist.add(claimFunctionalityNameTriggerExecution2);
            
            Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution3 = new Core_Trigger_Executions__c();
            claimFunctionalityNameTriggerExecution3.Core_Active__c = true;
            claimFunctionalityNameTriggerExecution3.Core_Class_Name__c = 'Core_MDF_PFCServiceHandler';
            claimFunctionalityNameTriggerExecution3.Core_Trigger_Events__c = 'before insert,after update';
            claimFunctionalityNameTriggerExecution3.Core_Object__c = 'PartnerFundClaim';
            claimFunctionalityNameTriggerExecution3.Name = 'enableClaimVatBeforeUpdate';
            claimFunctionalityNameTriggerExecution3.Core_Description__c = 'description';
            triggerExelist.add(claimFunctionalityNameTriggerExecution3);
            
            insert triggerExelist;
            System.debug('SetupLimitSoql-AfterInsert-CustomSettings-line268' +Limits.getQueries());
        }
        
        // Creating Channel program
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', false);
        channelProgramList.add(cp);
        ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Data Center Co-Marketing Fund','Data Center CoMarketing Fund', false);
        channelProgramList.add(cp1);
        ChannelProgram cp2 = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', false);        
        channelProgramList.add(cp2);
        ChannelProgram cp3 = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', false);        
        channelProgramList.add(cp3);
        
        database.insert(channelProgramList);                        
        System.debug('SetupLimitSoql-AfterInsert-ChannelProgram-line283' +Limits.getQueries());
        // Creating Co-marketing Account with utility class
        Account dellCCFVirtualCorp = Core_MDF_CCP_TestDataUtility.createAccount ('Dell CCF Virtual Corp', cp.Id,Core_MDF_CCP_TestDataUtility.account_Record_Type, false);
        dellCCFVirtualCorp.Core_MDF_Parent_Fund_Account__c = dellCorpAccount.Id;
        dellCCFVirtualCorp.Core_MDF_CoMarketing_Ultimate_Account__c = dellCorpAccount.Id;
        comarketingAccountsList.add(dellCCFVirtualCorp);
        
        // Creating Co-marketing Account with utility class
        Account dellRMFVirtualCorp = Core_MDF_CCP_TestDataUtility.createAccount ('Dell RMF Virtual Corp', cp2.Id,Core_MDF_CCP_TestDataUtility.account_Record_Type, false);
        dellRMFVirtualCorp.Core_Geo__c = 'EMEA';
        dellRMFVirtualCorp.Core_MDF_Parent_Fund_Account__c = dellCorpAccount.Id;
        dellRMFVirtualCorp.Core_MDF_CoMarketing_Ultimate_Account__c = dellCorpAccount.Id;
        comarketingAccountsList.add(dellRMFVirtualCorp);
        
        // Creating IPA Virtual corp
        Account ipaCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('IPA Co-Marketing Account', cp3.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,ipaUltimateAccount.id, false);           
        comarketingAccountsList.add(ipaCoMarketingAccount);        
        
        Database.insert(comarketingAccountsList);   
        System.debug('SetupLimitSoql-AfterInsert-CoMarketingAccount-line-301' +Limits.getQueries());
        String budgetType = Core_MDF_CCP_IPA_TestDataUtility.createBenefit(ipaCoMarketingAccount);
        
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
        System.debug('SetupLimitSoql-AfterInsert-PGM-line-340' +Limits.getQueries());           
        //Creating campaign
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7+ Processor','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today().addDays(-10), System.today().addDays(10), 10000, 'Consumer Chromebook', dellCCFVirtualCorp.Id, '2-in-1', false); 
        camp.Core_MDF_Opal_Budget_Type_Txt__c= 'CCF 1.0';
        //camp.Core_MDF_Activity_Category_Type__c= 'Broadcast->Podcast';
        camp.Core_MDF_Activity_Category_Type__c= null;
        campaignList.add(camp);
    
        Campaign retailCampaign = Core_MDF_CCP_TestDataUtility.createCampaign('Retail Campaigm1','Gaming','9ᵗʰ Gen','Yes', Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds', System.today().addDays(-20), System.today().addDays(20), 100000, 'Instore innovation', dellRMFVirtualCorp.Id,'Desktop', false); 
        retailCampaign.Core_MDF_Is_Opal__c='Yes MDF or both CMP & MDF';
        retailCampaign.Core_MDF_Opal_Budget_Type_Txt__c= 'Retail MDF';
        //retailCampaign.Core_MDF_Activity_Category_Type__c =null;
        retailCampaign.Core_MDF_Reimbursement_Rate__c='100%';
        retailCampaign.Core_MDF_Technology__c = 'Intel vPro®';
        campaignList.add(retailCampaign);
        
        Campaign rsaMDCamp = Core_MDF_CCP_TestDataUtility.createCampaign('Retail Campaigm2','Gaming','9ᵗʰ Gen','Yes', Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds', System.today().addDays(-10), System.today().addDays(10), 100000, 'Instore innovation', dellRMFVirtualCorp.Id,'Desktop', false); 
        rsaMDCamp.Core_MDF_Is_Opal__c='Yes MDF or both CMP & MDF';
        rsaMDCamp.Core_MDF_Opal_Budget_Type_Txt__c='RSA MD';
        //rsaMDCamp.Core_MDF_Activity_Category_Type__c =null;
        rsaMDCamp.Core_MDF_Reimbursement_Rate__c='100%';
        rsaMDCamp.Core_MDF_Technology__c = 'Intel vPro®';
        campaignList.add(rsaMDCamp);
        
        Campaign ipaCamp = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test IPA Camp',ipaCoMarketingAccount.Id, System.today(), System.today().addDays(300),budgetType, 1234.00, 'AFGHANISTAN','Consumer','Coffee Lake','Pending Review', false);
        ipaCamp.Core_MDF_Budget_Type_txt__c = budgetType;
        //ipaCamp.Core_MDF_Activity_Category_Type__c = 'Purchase Incentive->Buyer - Bundle Offer';
        ipaCamp.Core_MDF_Reimbursement_Amt__c = 10000;
        campaignList.add(ipaCamp);
        
        //Test.startTest();
        database.insert(campaignList);
        System.debug('SetupLimitSoql-AfterInsert-Campaign-line-369' +Limits.getQueries());            
        // Create PMB for the above Account 
        PartnerMarketingBudget  pmbRecord = Core_MDF_CCP_TestDataUtility.createBudget('Dell PMB',Core_MDF_CCP_TestDataUtility.budget_Record_Type,dellCCFVirtualCorp.Id,cp.Id,1000000,System.today(),System.today().addDays(110),false);
        pmbRecord.IsIgnoreValidation = true;
        pmbRecord.Core_MDF_Budget_Type_Txt__c = 'CCF 1.0';
        pmbList.add(pmbRecord);
    
        PartnerMarketingBudget  pmbRecord1 = Core_MDF_CCP_TestDataUtility.createRetailBudget('Dell RMF PMB',Core_MDF_CCP_TestDataUtility.budget_Retail_Record_Type,dellRMFVirtualCorp.Id,cp2.Id,1000000,System.today().addDays(-15),System.today().addDays(15),false, 'Retail MDF');
        pmbRecord1.IsIgnoreValidation = true;
        pmbRecord1.Core_MDF_Budget_Type_Txt__c = 'Retail MDF';
        pmbList.add(pmbRecord1);
        
        PartnerMarketingBudget  pmbRecord2 = Core_MDF_CCP_TestDataUtility.createRetailBudget('RSABudget',Core_MDF_CCP_TestDataUtility.budget_Retail_Record_Type,dellRMFVirtualCorp.Id,cp2.Id,1000000,System.today().addDays(-15),System.today().addDays(15),false, 'RSA MD');
        pmbRecord2.IsIgnoreValidation = true;
        pmbRecord2.Core_MDF_Budget_Type_Txt__c = 'RSA MD';
        pmbList.add(pmbRecord2);
        
        Database.insert(pmbList);
        System.debug('SetupLimitSoql-AfterInsert-Budget-line-387' +Limits.getQueries());  
        
        // Create PFA records for the above accounts :
        PartnerFundAllocation pfaDellCCFVirtualCorp = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('pfaDellCCFVirtualCorp',pmbRecord, dellCCFVirtualCorp, 100000,false);
        pfaList.add(pfaDellCCFVirtualCorp);
        PartnerFundAllocation retailAlloc = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('retailAlloc',pmbRecord1,dellRMFVirtualCorp,20000.0,false);
        pfaList.add(retailAlloc);
        PartnerFundAllocation rsaMdAlloc = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('RSAMDalloc',pmbRecord2,dellRMFVirtualCorp,20000.0,false);
        pfaList.add(rsaMdAlloc);
        
        database.insert(pfaList);
        System.debug('SetupLimitSoql-AfterAllocation' +Limits.getQueries());
        
        List<Core_MDF_Bank__c> listBank = new List<Core_MDF_Bank__c>();
        //Creating Bank
        Core_MDF_Bank__c indiaBank = Core_MDF_CCP_TestDataUtility.createBank(dellCorpAccount.Id, 'CCF', false,'1231231230');
        indiaBank.Core_MDF_Bank_Status__c = 'Active';
        indiaBank.name = 'Test CCFBank';
        indiaBank.Core_MDF_Program__c='Core_MDF_Data_Center_CoMarketing_Fund;Core_MDF_Client_CoMarketing_Fund';
        indiaBank.Core_MDF_Payment_Currency_Cd__c = 'USD';
        listBank.add(indiaBank);
        Core_MDF_Bank__c retailBank = Core_MDF_CCP_TestDataUtility.createBank(dellCorpAccount.Id, 'Core_MDF_Retail_Marketing_Funds', false,'1231231230');
        retailBank.Core_MDF_Intel_Company_Code__c = '150';
        retailBank.name = 'retailBank';
        retailBank.Core_MDF_Currency_cd__c = 'USD';
        retailBank.Core_MDF_Payment_Currency_Cd__c = 'USD';
        retailBank.Core_MDF_Tax_codes_cd__c = 'I0';
        retailBank.Core_MDF_Bank_Status__c = 'Active';   
        retailBank.Core_MDF_Supplier_Country_txt__c = 'US';  
        retailBank.Core_MDF_Supplier_City_txt__c = 'New York';  
        retailBank.Core_MDF_Supplier_Region_txt__c = 'New York';  
        retailBank.Core_MDF_Supplier_Postal_Code_cd__c = '728378';  
        retailBank.Core_MDF_VAT_pct__c = '10';
        listBank.add(retailBank);
        
        Core_MDF_Bank__c ipaBank = Core_MDF_CCP_TestDataUtility.createBank(ipaUltimateAccount.Id, 'Core_MDF_Intel_Partner_Alliance', false,'1231231230');
        ipaBank.Core_MDF_Intel_Company_Code__c = '150';
        ipaBank.Core_MDF_Currency_cd__c = 'USD';
        ipaBank.Core_MDF_Tax_codes_cd__c = 'UB';
        ipaBank.Core_MDF_Bank_Status__c = 'Active';
        listBank.add(ipaBank);                
        
        System.runAs(sysAdmUsr){
            database.insert(listBank);
        }
        System.debug('SetupLimitSoql-AfterBank' +Limits.getQueries());
        //creating ABM for bank1
        Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(dellCCFVirtualCorp.Id,indiaBank.Id,false);
        accBankMappingList.add(abm1);
        Core_MDF_Account_Bank_Mapping__c abm2 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(dellRMFVirtualCorp.Id,retailBank.Id,false);
        accBankMappingList.add(abm2);
        Core_MDF_Account_Bank_Mapping__c abm3 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(ipaCoMarketingAccount.Id,ipaBank.Id,false);
        accBankMappingList.add(abm3);
       
        database.insert(accBankMappingList);
        System.debug('SetupLimitSoql-AfterAccountBankMapping' +Limits.getQueries());
        //Test.stopTest();
        //Creating Partner fund Request for each Geo 
        PartnerFundRequest indiaActivity = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                 string.valueof(dellCCFVirtualCorp.id),pfaDellCCFVirtualCorp,pmbRecord,
                                                                                                 'BRAZIL','Consumer','Desktop','Intel® Core™ i5 Processor','Broadcast','Podcast','Draft'
                                                                                                 ,false);
        indiaActivity.Title = 'indiaActivity';      
        indiaActivity.Core_MDF_Activity_Description__c = 'indiaActivity';
        //indiaActivity.Core_MDF_Budget_Type_txt__c = 'CCF 1.0';
        indiaActivity.Core_MDF_Budget_Type_nm__c = 'CCF 1.0';
        indiaActivity.BudgetId = pmbRecord.Id;
        indiaActivity.Core_MDF_Start_Date__c = System.today();
        indiaActivity.Core_MDF_End_Date__c = System.today();
        indiaActivity.RequestedAmount = 100;
        indiaActivity.amount = 0;
        indiaActivity.Core_MDF_Channel_Partner_Led__c = True;
        pfrList.add(indiaActivity);
        PartnerFundRequest indiaActivity1= Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                 string.valueof(dellCCFVirtualCorp.id),pfaDellCCFVirtualCorp,pmbRecord,
                                                                                                 'SINGAPORE','Consumer','Desktop','Intel® Core™ i5 Processor','Broadcast','Podcast','Draft'
                                                                                                 ,false);
        indiaActivity1.Title = 'indiaActivity1';
        indiaActivity1.Core_MDF_Activity_Description__c = 'indiaActivity';
        indiaActivity1.BudgetId = pmbRecord.Id;
        //indiaActivity1.Core_MDF_Budget_Type_txt__c = 'CCF 1.0';
        indiaActivity1.Core_MDF_Budget_Type_nm__c = 'CCF 1.0';
        indiaActivity1.Core_MDF_Start_Date__c = System.today();
        indiaActivity1.Core_MDF_End_Date__c = System.today();
        indiaActivity1.RequestedAmount = 100;
        indiaActivity1.amount = 0;
        indiaActivity1.Core_MDF_Channel_Partner_Led__c = True;
        pfrList.add(indiaActivity1);
        PartnerFundRequest indiaActivity2= Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                 string.valueof(dellCCFVirtualCorp.id),pfaDellCCFVirtualCorp,pmbRecord,
                                                                                                 'EGYPT','Consumer','Desktop','Intel® Core™ i5 Processor','Broadcast','Podcast','Draft'
                                                                                                ,false);
        indiaActivity2.Title = 'indiaActivity2';
        indiaActivity2.Core_MDF_Activity_Description__c = 'indiaActivity';
        indiaActivity2.BudgetId = pmbRecord.Id;
        //indiaActivity2.Core_MDF_Budget_Type_txt__c = 'CCF 1.0';
        indiaActivity2.Core_MDF_Budget_Type_nm__c = 'CCF 1.0';
        indiaActivity2.Core_MDF_Start_Date__c = System.today();
        indiaActivity2.Core_MDF_End_Date__c = System.today();
        indiaActivity2.RequestedAmount = 100;
        indiaActivity2.amount = 0;
        indiaActivity2.Core_MDF_Channel_Partner_Led__c = True;
        pfrList.add(indiaActivity2);
        PartnerFundRequest indiaActivity3 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                  string.valueof(dellCCFVirtualCorp.id),pfaDellCCFVirtualCorp,pmbRecord,
                                                                                                  'MACAU','Consumer','Desktop','Intel® Core™ i5 Processor','Broadcast','Podcast','Draft'
                                                                                                  ,false);
        indiaActivity3.Title = 'indiaActivity3';
        indiaActivity3.Core_MDF_Activity_Description__c = 'indiaActivity';
        indiaActivity3.BudgetId = pmbRecord.Id;
        //indiaActivity3.Core_MDF_Budget_Type_txt__c = 'CCF 1.0';
        indiaActivity3.Core_MDF_Budget_Type_nm__c = 'CCF 1.0';
        indiaActivity3.Core_MDF_Start_Date__c = System.today();
        indiaActivity3.Core_MDF_End_Date__c = System.today();
        indiaActivity3.RequestedAmount = 100;
        indiaActivity3.amount = 0;
        indiaActivity3.Core_MDF_Channel_Partner_Led__c = True;
        pfrList.add(indiaActivity3);
        PartnerFundRequest indiaActivity4 = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(retailCampaign.Id),string.valueof(dellRMFVirtualCorp.id),
                            System.today(),System.today(),false);
        indiaActivity4.Title = 'indiaActivity4';
        //indiaActivity4.Core_MDF_Budget_Type_txt__c = 'Retail MDF';
        indiaActivity4.Core_MDF_Budget_Type_nm__c = 'Retail MDF';
        indiaActivity4.Core_MDF_Country_nm__c = 'INDIA';
        indiaActivity4.Core_MDF_Reimbursement_Rate_pct__c = '100%';
        indiaActivity4.RequestedAmount =1000;
        indiaActivity4.Amount=1000;
        indiaActivity4.Core_MDF_Product_Category_txt__c ='Desktop';
        pfrList.add(indiaActivity4);
        
        PartnerFundRequest indiaActivity5 = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(rsaMDCamp.Id),string.valueof(dellRMFVirtualCorp.id),
                            System.today(),System.today(),false);
        indiaActivity5.Title = 'indiaActivity5';
        //indiaActivity5.Core_MDF_Budget_Type_txt__c = 'RSA MD';
        indiaActivity5.Core_MDF_Budget_Type_nm__c = 'RSA MD';
        indiaActivity5.Core_MDF_Country_nm__c = 'INDIA';
        indiaActivity5.Core_MDF_Reimbursement_Rate_pct__c = '100%';
        indiaActivity5.RequestedAmount =1000;
        indiaActivity5.Amount=1000;
        pfrList.add(indiaActivity5);
        Test.startTest();
        Database.insert(pfrList);
        
        System.debug('SetupLimitSoql-AfterActivityInsertion' +Limits.getQueries());
        Test.stopTest();
        
        //Test.stopTest();
        Core_MDF_CCP_TestDataUtility.insertCurrencyExchangeRates();
        Core_MDF_CCP_TestDataUtility.createTriggerExecutionRecords();
        Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();
        Core_MDF_Configuration__c programsApplicableforBuSplit = new Core_MDF_Configuration__c(Name='PROGRAMS_FOR_BU_SPLIT',Core_MDF_Value__c='Intel Partner Alliance',Core_MDF_Category__c='Programs for BU Split');
        insert programsApplicableforBuSplit;
        
        
        System.debug('SetupLimitSoql-SetupFinish' +Limits.getQueries());
        
    }
    
    @isTest static void validateIPAClaim() { 
        User sysAdmUsr = [SELECT Id,Email from User where Email = 'sysadmin@example.com'];

            System.runAs(sysAdmUsr)
            {
                Id pRunRecord_Type = Schema.SObjectType.Core_MDF_Payment_Run__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance_MDF').getRecordTypeId();
                Test.startTest();
                Account ipaCoMarketingAccount =[Select Id from Account where Name = 'IPA Co-Marketing Account' LIMIT 1];
                Campaign ipaCamp  = [Select Id, Name, StartDate,status, EndDate, Description, Core_MDF_Budget__c,Core_MDF_Account__c,Core_MDF_Channel_Program__c,
                                  Core_MDF_Opal_Budget_Type_Txt__c,Core_MDF_Total_Campaign_Cost_Amt__c
                                  from Campaign where Name = 'Test IPA Camp' limit 1];
                
                PartnerFundRequest pfr = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCamp.Id,ipaCoMarketingAccount.Id,System.today(),System.today(),false);
                pfr.Core_MDF_BU_Split__c = 'CCG';
                pfr.Core_MDF_BU1_Split_Percent_nbr__c = 100;
                pfr.Core_MDF_Product_Category_txt__c ='Desktop';
                Database.insert(pfr);
                
                List<Campaign> campToBeUpdated = new List<Campaign>();
                List<PartnerFundRequest> pfrToBeUpdated = new List<PartnerFundRequest>(); 
                ipaCamp.Status = 'Proposal Accepted';
                campToBeUpdated.add(ipaCamp);
                
                Database.update(campToBeUpdated);
                
                pfr.Core_MDF_Fund_Request_Status__c = 'Planned';
                pfr.Core_MDF_Reimbursement_Rate_pct__c ='100%';
                pfrToBeUpdated.add(pfr);
                
                Database.update(pfrToBeUpdated);
                
                Id recordtype = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByDeveloperName().get('Core_MDF_IPA_ProposalBased').getRecordTypeId(); 
                
                system.debug('campBudg::' + ipaCamp.Core_MDF_Opal_Budget_Type_Txt__c);                
                PartnerMarketingBudget pmb = [Select id,Title, Description, Core_MDF_Budget_Status__c, StartDate, EndDate, Amount, Core_MDF_Budget_Type_Txt__c,
                                              Core_MDF_Budget_Partner__c,Core_MDF_Program__c, RecordTypeId, IsIgnoreValidation From PartnerMarketingBudget where Id = :ipaCamp.Core_MDF_Opal_Budget_Type_Txt__c];
                system.debug('pmb::' + pmb);  
                PartnerFundAllocation pfa = [Select Id, ChannelPartnerId, Amount from PartnerFundAllocation where BudgetId = :pmb.Id]; 
                system.debug('pfa::' + pfa);  
                Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Program__c='Core_MDF_Intel_Partner_Alliance' limit 1];
                system.debug('bank1::' + bank1);                                          
                PartnerFundClaim claim1 =  Core_MDF_CCP_IPA_TestDataUtility.createIPAClaim('IPA Claim',Core_MDF_CCP_IPA_TestDataUtility.claim_RecordType_IPA, pfr.Id, System.today(), System.today(),50.00, bank1.Id, false); 
                claim1.Core_MDF_Type_Txt__c ='Claim';
                claim1.Core_MDF_Currency__c='USD';
                claim1.Core_MDF_Country_Location_nm__c= 'AFGHANISTAN'; 
                claim1.Core_MDF_Campaign_Id__c = ipaCamp.Id;
                claim1.Core_MDF_VAT_Opt_In__c = 'Yes';
                claim1.Core_MDF_VAT_Eligibility_Ind__c= true ; 
                claim1.Core_MDF_VAT_Hold_Ind__c = true;
                claim1.Core_MDF_Status__c = 'Hold';
                insert claim1;
                system.debug('claim1::' + claim1.Core_MDF_Status__c);
                Core_MDF_Claim_VAT_Info__c vatInfo = [select id,Core_MDF_VAT_Invoice_Number_Txt__c from Core_MDF_Claim_VAT_Info__c where Core_MDF_Claim_Id__c = : claim1.Id limit 1];
                vatInfo.Core_MDF_VAT_Invoice_Number_Txt__c = 'VATINV001';
                Database.update(vatInfo);
                system.debug('vatInfo::' + vatInfo.Core_MDF_VAT_Invoice_Number_Txt__c);
                //Create Document
                ContentVersion cv = new ContentVersion();
                cv.Title = 'Test Document';
                cv.PathOnClient = 'TestDocument.pdf';
                cv.VersionData = Blob.valueOf('Test Content');
                cv.IsMajorVersion = true;
                Insert cv;
                System.debug('Query Limit 5: '+ Limits.getQueries());
                //Get Content documents
                List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
                
                //create ContentDocumentLink  record 
                ContentDocumentLink cdl = New ContentDocumentLink();
                cdl.LinkedEntityId = vatInfo.Id;
                cdl.ContentDocumentId = documents[0].Id;
                cdl.shareType = 'V';
                insert cdl;
                System.debug('Query Limit 6: '+ Limits.getQueries());
                vatInfo.Core_MDF_Status_Txt__c = 'Approved';
                Database.update(vatInfo);
                system.debug('getfinalstatus::'+ claim1.Core_MDF_Status__c);
                
                Core_MDF_Payment_Run__c ipaPayRunRecord = new Core_MDF_Payment_Run__c();
                ipaPayRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
                ipaPayRunRecord.Core_MDF_Geo_Txt__c = 'EMEA';
                ipaPayRunRecord.Core_MDF_Start_Dt__c = System.today().addDays(-5);                                                       
                ipaPayRunRecord.Core_MDF_End_Dt__c = System.today().addDays(5);
                ipaPayRunRecord.Core_MDF_Program_Txt__c = 'Intel Partner Alliance';
                Database.insert(ipaPayRunRecord);
                
                Core_MDF_Batch_PaymentFileGenerator paymentbatch = new Core_MDF_Batch_PaymentFileGenerator(ipaPayRunRecord);
                database.executebatch(paymentbatch,200);
                Test.stopTest();
            }
    }
    
    // Test method to test scheduling and file generation functionality Payments Process 
    @isTest static void testPaymentRunSchOnCreate(){
        Test.startTest();
        
        List<Core_MDF_Payment_Run__c> paymentRunList = new List<Core_MDF_Payment_Run__c>();
        Map<String, PartnerFundClaim> claimMap = new Map<String, PartnerFundClaim>();
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User payAdmUser = [SELECT Id,Email from User where Email='testPayment@example.com' limit 1];
        claimMap = createClaim();
        Test.stopTest();
        System.runAs(payAdmUser){
            Core_MDF_Payment_Run__c payRunRecord = new Core_MDF_Payment_Run__c();
            payRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
            payRunRecord.Core_MDF_Geo_Txt__c = 'ASMO';
            //payRunRecord.Core_MDF_Program_Id__c  = cp.Id;
            payRunRecord.Core_MDF_Program_Txt__c ='Client CoMarketing Fund';
      
            paymentRunList.add(payRunRecord);
            Database.insert(payRunRecord);
            Core_MDF_Batch_PaymentFileGenerator paymentbatch = new Core_MDF_Batch_PaymentFileGenerator(payRunRecord);
            database.executebatch(paymentbatch,200);
        }

    }
    
    // Test method to test offset Adjustment
    @isTest static void testAdjustmentActiveFalse(){
        Test.startTest();
        List<Core_MDF_Payment_Run__c> paymemtRunList = new List<Core_MDF_Payment_Run__c>();
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User claimCaseUser = [SELECT Id,Email from User where Email='testreviewer@example.com' limit 1];
        Map<String, PartnerFundClaim> claimMap = new Map<String, PartnerFundClaim>();
        User payAdmUser = [SELECT Id,Email from User where Email='testPayment@example.com' limit 1];
        //Id claim_RecordType_CCF = Schema.SObjectType.PartnerFundClaim.getRecordTypeInfosByName().get('Core_MDF_Client_Co_Marketing_Fund').getRecordTypeId();
        //Core_MDF_Bank__c indiaBank = [Select Id from Core_MDF_Bank__c where Name ='Test CCFBank' limit 1] ;
        //PartnerFundRequest indiaActivity2 = [Select Id, Core_MDF_Start_Date__c FROM  PartnerFundRequest WHERE Title = 'indiaActivity2'];
        //PartnerFundClaim claim1 =[SELECT Id,Core_MDF_Status__c from PartnerFundClaim where Title ='India Claim3'limit 1];
        
        /*PartnerFundClaim indiaClaim3 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim3',Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                indiaActivity2.Id, 
                                                                                indiaActivity2.Core_MDF_Start_Date__c, indiaActivity2.Core_MDF_Start_Date__c, 
                                                                                100, 
                                                                                indiaActivity2.Core_MDF_Start_Date__c, indiaBank.ID, false);
        
        
        indiaClaim3.Core_MDF_Currency__c = 'USD';
        insert indiaClaim3;*/
        claimMap = createClaim();
        
        //PartnerFundClaim indiaClaim3 =[SELECT Id,Core_MDF_Status__c from PartnerFundClaim where Title ='India Claim3'limit 1]; 
        System.debug('Limit Soql before stopTest-createClaim' +Limits.getQueries());
        Test.stopTest();
        System.debug('Limit Soql after createClaim' +Limits.getQueries());
        System.runAs(claimCaseUser){
            Core_MDF_Adjustment_Request__c adjustment1 = new Core_MDF_Adjustment_Request__c();          
            adjustment1.Core_MDF_Reference_Claim_Nbr__c = claimMap.get('India Claim3').Id;
            adjustment1.Core_MDF_Amount_Amt__c = 10;
            adjustment1.Core_MDF_Reason_Cd__c = 'Claim Review Results (Negative)';
            Database.insert(adjustment1);
        }
        System.debug('Limit Soql-After adjustment' +Limits.getQueries());
        System.runAs(payAdmUser){  
            Core_MDF_Payment_Run__c payRunRecord = new Core_MDF_Payment_Run__c();
            payRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
            payRunRecord.Core_MDF_Geo_Txt__c = 'EMEA';
            payRunRecord.Core_MDF_Program_Txt__c ='Client CoMarketing Fund';
            paymemtRunList.add(payRunRecord);
            
            Database.insert(paymemtRunList);
            System.debug('Limit Soql' +Limits.getQueries());
            System.assertNotEquals(paymemtRunList[0].Id,null);
            Core_MDF_Batch_PaymentFileGenerator paymentbatch = new Core_MDF_Batch_PaymentFileGenerator(payRunRecord);
            database.executebatch(paymentbatch,200);
            System.debug('Limit Soql Before testAdjustmentActiveFalse End' +Limits.getQueries());
            /*Core_MDF_Payment_Run__c payRunRecord1 = new Core_MDF_Payment_Run__c();
            payRunRecord1.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
            payRunRecord1.Core_MDF_Geo_Txt__c = 'EMEA';
            //payRunRecord1.Core_MDF_Program_Id__c  = cp1.Id;
            payRunRecord1.Core_MDF_Program_Txt__c = 'Data Center CoMarketing Fund';
             paymemtRunList.add(payRunRecord1);
            
            System.assertNotEquals(payRunRecord1.Id,null);*/
        }
        
    }
    // Test method to test offset Adjustment
    @isTest static void testAdjustmentEqualClaimAndActiveTrue(){
        Test.startTest();
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User claimCaseUser = [SELECT Id,Email from User where Email='testreviewer@example.com' limit 1];  
        Map<String, PartnerFundClaim> claimMap = new Map<String, PartnerFundClaim>();
        User payAdmUser = [SELECT Id,Email from User where Email='testPayment@example.com' limit 1];
        claimMap = createClaim();
        //PartnerFundClaim claim2 =[SELECT Id,Core_MDF_Status__c from PartnerFundClaim where Title ='India Claim2'limit 1];
        System.debug('Limit Soql-inside Test.startTest' +Limits.getQueries());
        Test.stopTest();
        System.runAs(claimCaseUser){
            Core_MDF_Adjustment_Request__c adjustment1 = new Core_MDF_Adjustment_Request__c();          
            adjustment1.Core_MDF_Reference_Claim_Nbr__c = claimMap.get('India Claim2').Id;
            adjustment1.Core_MDF_Amount_Amt__c = 25;
            adjustment1.Core_MDF_Reason_Cd__c = 'Claim Review Results (Negative)';
            Database.insert(adjustment1); 
        }
        System.debug('Limit Soql-After adjustment' +Limits.getQueries());
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
        System.runAs(payAdmUser){
            Core_MDF_Payment_Run__c payRunRecord = new Core_MDF_Payment_Run__c();
            payRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
            payRunRecord.Core_MDF_Geo_Txt__c = 'APJ';
            //payRunRecord.Core_MDF_Program_Id__c  = cp.Id;
            payRunRecord.Core_MDF_Program_Txt__c = 'Client CoMarketing Fund';
            Database.insert(payRunRecord);
            System.debug('Limit Soql-after prun insertion' +Limits.getQueries());
            System.assertNotEquals(payRunRecord.Id,null);
            /*
            Core_MDF_Payment_Run__c payRunRecord1 = new Core_MDF_Payment_Run__c();
            payRunRecord1.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
            payRunRecord1.Core_MDF_Geo_Txt__c = 'APJ';
            //payRunRecord1.Core_MDF_Program_Id__c  = cp1.Id;
            payRunRecord1.Core_MDF_Program_Txt__c = 'Data Center CoMarketing Fund';
            Database.insert(payRunRecord1);*/
            System.debug('Limit Soql-After Prun1 insertion' +Limits.getQueries());
            Core_MDF_Batch_PaymentFileGenerator paymentbatch = new Core_MDF_Batch_PaymentFileGenerator(payRunRecord);
            database.executebatch(paymentbatch,200);
            System.assertNotEquals(payRunRecord.Id,null);
            System.debug('Limit Soql' +Limits.getQueries());
        }        
             
    }
    // Test method to test offset Adjustment
    @isTest static void testAdjustmentGreaterthanClaim(){
        Test.startTest();
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User claimCaseUser = [SELECT Id,Email from User where Email='testreviewer@example.com' limit 1];
        Map<String, PartnerFundClaim> claimMap = new Map<String, PartnerFundClaim>();
        User payAdmUser = [SELECT Id,Email from User where Email='testPayment@example.com' limit 1];
        claimMap = createClaim();
        //PartnerFundClaim claim3 =[SELECT Id,Core_MDF_Status__c from PartnerFundClaim where Title ='India Claim4'limit 1];
        System.debug('Limit Soql-Inside Test.Starttest' +Limits.getQueries());
        Test.stopTest();
        System.runAs(claimCaseUser){  
            Core_MDF_Adjustment_Request__c adjustment1 = new Core_MDF_Adjustment_Request__c();          
            adjustment1.Core_MDF_Reference_Claim_Nbr__c = claimMap.get('India Claim4').Id;
            adjustment1.Core_MDF_Amount_Amt__c = 25;
            adjustment1.Core_MDF_Reason_Cd__c = 'Claim Review Results (Negative)';
            Database.insert(adjustment1);
        }
        System.debug('Limit Soql-After Adjustment' +Limits.getQueries());
        System.runAs(payAdmUser){
            Core_MDF_Payment_Run__c payRunRecord = new Core_MDF_Payment_Run__c();
            payRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
            payRunRecord.Core_MDF_Geo_Txt__c = 'PRC';
            //payRunRecord.Core_MDF_Program_Id__c  = cp.Id;
            payRunRecord.Core_MDF_Program_Txt__c = 'Client CoMarketing Fund';
            Database.insert(payRunRecord);
            System.assertNotEquals(payRunRecord.Id,null);

            /*Core_MDF_Payment_Run__c payRunRecord1 = new Core_MDF_Payment_Run__c();
            payRunRecord1.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
            payRunRecord1.Core_MDF_Geo_Txt__c = 'PRC';
            //payRunRecord1.Core_MDF_Program_Id__c  = cp1.Id;
            payRunRecord1.Core_MDF_Program_Txt__c = 'Data Center CoMarketing Fund';
            Database.insert(payRunRecord1);*/
            System.debug('Limit Soql-After insert of PRUN' +Limits.getQueries());
            Core_MDF_Batch_PaymentFileGenerator paymentbatch = new Core_MDF_Batch_PaymentFileGenerator(payRunRecord);
            database.executebatch(paymentbatch,200);
            System.assertNotEquals(payRunRecord.Id,null);
        }
             
    }
    
   @isTest static void testRetailAdjustmentClaim(){
        Test.startTest(); 
       
        //ChannelProgram cp2 = [SELECT ID From ChannelProgram where Name = 'Retail Marketing Funds' limit 1];
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User payAdmUser = [SELECT Id,Email from User where Email='testPayment@example.com' limit 1];
        //User claimCaseUser = [SELECT Id,Email from User where Email='testreviewer@example.com' limit 1];
        Map<String, PartnerFundClaim> claimMap = new Map<String, PartnerFundClaim>();
        //PartnerFundRequest indiaActivity4 = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title='indiaActivity4' limit 1];
         
       claimMap = createClaim();
       //PartnerFundClaim retailMdfClaim1 =[SELECT Id,Core_MDF_Status__c from PartnerFundClaim where Title ='RMF MDF Claim' limit 1];
       Test.stopTest();
       //Core_MDF_Bank__c retailBank = [Select ID from Core_MDF_Bank__c where Core_MDF_Program__c = 'Core_MDF_Retail_Marketing_Funds' limit 1];
       System.runAs(sysAdminUser){
            Core_MDF_Adjustment_Request__c adjustment1 = new Core_MDF_Adjustment_Request__c();          
            adjustment1.Core_MDF_Reference_Claim_Nbr__c = claimMap.get('RMF MDF Claim').Id;
            adjustment1.Core_MDF_Amount_Amt__c = 25;
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
        List<Core_MDF_Payment_Run__c> paymentRunList = new List<Core_MDF_Payment_Run__c>();
        System.runAs(payAdmUser){
           Core_MDF_Payment_Run__c payRunRecordRetail = new Core_MDF_Payment_Run__c();
            //payRunRecordRetail.Core_MDF_Geo_Txt__c = 'APJ';
            payRunRecordRetail.Core_MDF_Geo_Txt__c = 'ASMO';
            payRunRecordRetail.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
            payRunRecordRetail.Core_MDF_Start_Dt__c = System.today().addDays(-5);                                                       
            payRunRecordRetail.Core_MDF_End_Dt__c = System.today().addDays(5);
            //payRunRecordRetail.Core_MDF_Program_Id__c  = cp2.Id;
            payRunRecordRetail.Core_MDF_Program_Txt__c = 'Retail Marketing Funds';
            payRunRecordRetail.Core_MDF_Budget_Type_Txt__c = 'Retail MDF';
            paymentRunList.add(payRunRecordRetail);
            Database.insert(paymentRunList);
            Core_MDF_Batch_PaymentFileGenerator paymentbatch = new Core_MDF_Batch_PaymentFileGenerator (paymentRunList[0]);
            database.executebatch(paymentbatch,200);
            System.assertNotEquals(payRunRecordRetail.Id,null); 
        }
        
    } 
    // Test method to test offset Adjustment
    @isTest static void testAdjustmentLessthanClaim(){
        Test.startTest();
        //ChannelProgram cp = [SELECT ID From ChannelProgram where Name = 'Client Co-Marketing Fund'];
        //ChannelProgram cp1 = [SELECT ID From ChannelProgram where Name = 'Data Center Co-Marketing Fund'];
        
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
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
        Test.stopTest();
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
        System.runAs(payAdmUser){
            List<Core_MDF_Payment_Run__c> payRunList = new List<Core_MDF_Payment_Run__c>();
            Core_MDF_Payment_Run__c payRunRecord = new Core_MDF_Payment_Run__c();
            payRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
            payRunRecord.Core_MDF_Geo_Txt__c = 'ASMO';
            //payRunRecord.Core_MDF_Program_Id__c  = cp.Id;
            payRunRecord.Core_MDF_Program_Txt__c = 'Client CoMarketing Fund';
            payRunList.add(payRunRecord);
            //Database.insert(payRunRecord);
            
            /*
            Core_MDF_Payment_Run__c payRunRecord1 = new Core_MDF_Payment_Run__c();
            payRunRecord1.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
            payRunRecord1.Core_MDF_Geo_Txt__c = 'ASMO';
            //payRunRecord1.Core_MDF_Program_Id__c  = cp1.Id;
            payRunRecord1.Core_MDF_Program_Txt__c = 'Data Center CoMarketing Fund';
            payRunList.add(payRunRecord1);*/
            Database.insert(payRunList);
            Core_MDF_Batch_PaymentFileGenerator paymentbatch = new Core_MDF_Batch_PaymentFileGenerator(payRunList[0]);
            database.executebatch(paymentbatch,200);
            //System.assertNotEquals(payRunRecord1.Id,null);
            System.assertNotEquals(payRunRecord.Id,null); 
            
        }
             
    }
    // Test method to test Exception Handling In case of any errors during Payments Process 
    @isTest  
    static void testPaymentRunSchOnCreateError(){ 
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User payAdmUser = [SELECT Id,Email from User where Email='testPayment@example.com' limit 1];
        //User claimCaseUser = [SELECT Id,Email from User where Email='testreviewer@example.com' limit 1];
        
        
        PartnerFundRequest indiaActivity = [SELECT Id,RecordTypeId,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title='indiaActivity' limit 1];
        indiaActivity.RecordTypeId = Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_DCF;
        update indiaActivity;
        Test.startTest();
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
        }
        System.runAs(payAdmUser){
            Core_MDF_Payment_Run__c payRunRecord1 = new Core_MDF_Payment_Run__c();
            payRunRecord1.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(20);
            payRunRecord1.Core_MDF_Geo_Txt__c = 'ASMO';
            //payRunRecord1.Core_MDF_Program_Id__c  = cp1.Id;
            payRunRecord1.Core_MDF_Program_Txt__c = 'Data Center CoMarketing Fund';
            System.debug('testPaymentRunSchOnCreateError-BeforeStopTest' +Limits.getQueries());
            insert payRunRecord1;            
            payRunRecord1.Core_MDF_ScheduleRun_Dtm__c = DateTime.Now().addMinutes(10);
            Database.update(payRunRecord1);
            System.debug('testPaymentRunSchOnCreateError-AfterPaymentRunInsert' +Limits.getQueries());
            Test.stopTest();
            
            /*System.debug('testPaymentRunSchOnCreateError-AfterPaymentRunInsert' +Limits.getQueries());
            payRunRecord1.Core_MDF_ScheduleRun_Dtm__c = DateTime.Now().addMinutes(10);
            Database.update(payRunRecord1);*/
            
            //Core_MDF_Payment_Run__c uptdPrun = [Select Core_MDF_ErrorDetails_Txt__c From Core_MDF_Payment_Run__c where Id =: payRunRecord1.Id LIMIT 1];
            System.assertNotEquals(payRunRecord1.Id,null);
            System.debug('testPaymentRunSchOnCreateError-BeforeEnd' +Limits.getQueries());
            //Database.delete(payRunRecord1);
        }  
              
    }
    
    // Test method for restrict upload content file  
    @isTest  
    static void testRestrictUploadPaymentFile(){
        Core_MDF_Payment_Run__c payRunRecord = new Core_MDF_Payment_Run__c();
        try{
            Test.startTest();
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
                payRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
                payRunRecord.Core_MDF_Geo_Txt__c = 'ASMO';
                //payRunRecord.Core_MDF_Program_Id__c  = cp.Id;
                payRunRecord.Core_MDF_Program_Txt__c = 'Client CoMarketing Fund';
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
        Test.stopTest(); 
        System.runAs(claimCaseUser){
            Core_MDF_Adjustment_Request__c adjustment1 = new Core_MDF_Adjustment_Request__c();          
            adjustment1.Core_MDF_Reference_Claim_Nbr__c = indiaClaim.Id;
            adjustment1.Core_MDF_Amount_Amt__c = 5000;
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
        System.runAs(payAdmUser){
            Core_MDF_Payment_Run__c payRunRecord = new Core_MDF_Payment_Run__c();
            payRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
            payRunRecord.Core_MDF_Geo_Txt__c = 'ASMO';
            //payRunRecord.Core_MDF_Program_Id__c  = cp.Id;
            payRunRecord.Core_MDF_Program_Txt__c = 'Client CoMarketing Fund';
            Database.insert(payRunRecord);
            System.assertNotEquals(payRunRecord.Id,null);
            Core_MDF_Batch_PaymentFileGenerator paymentbatch = new Core_MDF_Batch_PaymentFileGenerator(payRunRecord);
            database.executebatch(paymentbatch,200);
        }
           
    }
    // Test method to test Retail Mdf Claim Creation
    @isTest static void testCreateRetailPaymentRun(){
        
        Test.startTest(); 
        
        User payAdmUser = [SELECT Id,Email from User where Email='testPayment@example.com' limit 1];
        List<PermissionSetAssignment> psa = [Select id,PermissionSet.Label from PermissionSetAssignment where AssigneeId =:payAdmUser.id];
        System.debug('psa list::::'+psa);
        Core_MDF_Bank__c retailProgBank = [Select ID,Core_MDF_Program__c,Core_MDF_Supplier_Country_txt__c from Core_MDF_Bank__c where Core_MDF_Program__c = 'Core_MDF_Retail_Marketing_Funds'  limit 1];
        PartnerFundRequest retailActivity = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c,Core_MDF_Budget_Type_nm__c from PartnerFundRequest where Title='indiaActivity4' limit 1];
        
        
        List<PartnerFundClaim> listOfClaims = new List<PartnerFundClaim>();
        PartnerFundClaim retailMdfClaim = Core_MDF_CCP_TestDataUtility.createClaim('Retail MDF Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, retailActivity.Id, System.today(), System.today(), 50.00, System.today(), retailProgBank.Id, false);
        retailMdfClaim.Core_MDF_Type_Txt__c ='Claim';
        retailMdfClaim.Core_MDF_Currency__c='USD';
        retailMdfClaim.Core_MDF_Country_Location_nm__c= 'India'; 
        retailMdfClaim.Core_MDF_Quarter_Year_Txt__c = 'Q3-2020';
        retailMdfClaim.Core_MDF_VAT_Eligibility_Ind__c = false;
        retailMdfClaim.Core_MDF_Status__c ='Payment Due';
        
        //POP mandatory for Retail
        List<String> documentIdWithTitle = new List<String>();
        list<String> tempString = new list<String>();
        list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
        
        String str1 = retailMdfClaim.Id+';#'+'Test Doc1';
        String str2 = retailMdfClaim.Id+';#'+'Test Doc2';
        system.debug('str2' +str2);
        
        documentIdWithTitle.add(str1);
        documentIdWithTitle.add(str2);
        
        for(String str: documentIdWithTitle){
            tempString = str.split(';#');
            Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
            auditDoc.Core_MDF_Document_Id__c = tempString[0];
            auditDoc.Core_MDF_Document_Title__c = tempString[1];
            auditDoc.Core_MDF_Claim__c = retailMdfClaim.Id;
            auditDoc.Core_MDF_Proof_of_Branding__c = true;
            auditDoc.Core_MDF_Proof_of_Cost__c = true;
            auditDoc.Core_MDF_Proof_of_Execution__c = true;                
            auditDocList.add(auditDoc);
            system.debug('auditDocList-->' +auditDocList);
        }            
        
        if(auditDocList.size()>0){
            Database.insert(auditDocList);                
        }
        //String res = Core_MDF_PartnerFundClaim.saveClaim(retailMdfClaim, auditDocList);
        //System.assertEquals(retailMdfClaim.ID,res);
        retailMdfClaim.Core_MDF_Status__c = 'Payment Due';
        Database.update(retailMdfClaim);
       // Core_MDF_PaymentProcessRetailMdfIPA.createBuSplitClaimChildRecords(retailMdfClaim, 'CCG', 20);
        System.runAs(payAdmUser){
            Core_MDF_Payment_Run__c retailPayRunRecord = new Core_MDF_Payment_Run__c();
            retailPayRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
            retailPayRunRecord.Core_MDF_Geo_Txt__c = 'APJ';
            retailPayRunRecord.Core_MDF_Start_Dt__c = System.today().addDays(-5);                                                       
            retailPayRunRecord.Core_MDF_End_Dt__c = System.today().addDays(5);
            retailPayRunRecord.Core_MDF_Budget_Type_Txt__c = 'retail MDF';
            retailPayRunRecord.Core_MDF_Program_Txt__c = 'Retail Marketing Funds';
            Database.insert(retailPayRunRecord);
            Test.stopTest();
            Core_MDF_Batch_PaymentFileGenerator paymentbatch = new Core_MDF_Batch_PaymentFileGenerator(retailPayRunRecord);
            database.executebatch(paymentbatch,200);
            
        }        
        
    }
    // Test method to test Retail Mdf Claim Creation
    @isTest static void testCreateRSAMDPaymentRun(){
        
      Test.startTest(); 
      User payAdmUser = [SELECT Id,Email from User where Email='testPayment@example.com' limit 1];
      //ChannelProgram retailCP = [SELECT ID From ChannelProgram where Name = 'Retail Marketing Funds'];
      PartnerFundRequest activityRSA = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c,Core_MDF_Budget_Type_nm__c from PartnerFundRequest where Title='indiaActivity5' limit 1];
      //PartnerMarketingBudget BdgtForRSA = [SELECT Id,Title,StartDate,EndDate, Core_MDF_Budget_Type_Txt__c,RecordType.DeveloperName from PartnerMarketingBudget where Title='RSABudget' limit 1];
      Core_MDF_Bank__c retailBank = [Select ID,Core_MDF_Program__c,Core_MDF_Supplier_Country_txt__c from Core_MDF_Bank__c where Core_MDF_Program__c = 'Core_MDF_Retail_Marketing_Funds'  limit 1];  
        
        
        PartnerFundClaim claimRSAMd = Core_MDF_CCP_TestDataUtility.createRetailRSAMDClaim(Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, activityRSA.Id, System.today(), System.today(), 50.00, false);
        claimRSAMd.Core_MDF_Country_Location_nm__c= 'INDIA';
        claimRSAMd.Title = 'Retail RSA MD Claim';
        claimRSAMd.Core_MDF_Invoice_Date__c = System.today();
        claimRSAMd.Core_MDF_Invoice_Number__c = '1234';
        claimRSAMd.Core_MDF_Media_Vehicle__c = 'test36';
        claimRSAMd.Core_MDF_OtherCostsnotReimbursable_Local__c = 0;
        claimRSAMd.Core_MDF_Taxes_Local__c = 0;
        claimRSAMd.Core_MDF_Bank__c = retailBank.Id;
        //POP mandatory for Retail
        List<String> documentIdWithTitle = new List<String>();
        list<String> tempString = new list<String>();
        list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
        
        String str1 = claimRSAMd.Id+';#'+'Test Doc1';
        String str2 = claimRSAMd.Id+';#'+'Test Doc2';
        system.debug('str2' +str2);
        
        documentIdWithTitle.add(str1);
        documentIdWithTitle.add(str2);
        
        for(String str: documentIdWithTitle){
            tempString = str.split(';#');
            Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
            auditDoc.Core_MDF_Document_Id__c = tempString[0];
            auditDoc.Core_MDF_Document_Title__c = tempString[1];
            auditDoc.Core_MDF_Claim__c = claimRSAMd.Id;
            auditDoc.Core_MDF_Proof_of_Branding__c = true;
            auditDoc.Core_MDF_Proof_of_Cost__c = true;
            auditDoc.Core_MDF_Proof_of_Execution__c = true;                
            auditDocList.add(auditDoc);
            system.debug('auditDocList-->' +auditDocList);
        }            
        
        if(auditDocList.size()>0){
            Database.insert(auditDocList);                
        }
        //insert claimRSAMd;
        //String res = Core_MDF_PartnerFundClaim.saveClaim(claimRSAMd, auditDocList);
        System.debug('rsamdclaimId'+claimRSAMd.ID);
        System.debug('rsamdclaimId'+claimRSAMd.Core_MDF_Status__c);
        //System.assertEquals(claimRSAMd.ID,res);
        
        claimRSAMd.Core_MDF_Status__c = 'Payment Due';
        Database.update(claimRSAMd);
        
        System.runAs(payAdmUser){
            Core_MDF_Payment_Run__c retailPayRunRecord = new Core_MDF_Payment_Run__c();
            retailPayRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
            retailPayRunRecord.Core_MDF_Geo_Txt__c = 'APJ';
            retailPayRunRecord.Core_MDF_Start_Dt__c = System.today().addDays(-5);                                                       
            retailPayRunRecord.Core_MDF_End_Dt__c = System.today().addDays(5);
            retailPayRunRecord.Core_MDF_Budget_Type_Txt__c = 'RSA MD';
            //retailPayRunRecord.Core_MDF_Program_Id__c  = retailCP.Id;
            retailPayRunRecord.Core_MDF_Program_Txt__c  ='Retail Marketing Funds';
            
            Database.insert(retailPayRunRecord);
            Test.stopTest(); 
            Core_MDF_Batch_PaymentFileGenerator paymentbatch = new Core_MDF_Batch_PaymentFileGenerator(retailPayRunRecord);
            database.executebatch(paymentbatch,200);
        System.assertNotEquals(retailPayRunRecord.Id,null);
       
        }
        
    }
    
    // Test method to test Retail Mdf Claim Creation
    @isTest static void testRetailPaymentRunOnError(){
      
      User payAdmUser = [SELECT Id,Email from User where Email='testPayment@example.com' limit 1];
      User sysAdm = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
      //ChannelProgram retailCP = [SELECT ID From ChannelProgram where Name = 'Retail Marketing Funds'];
      PartnerFundRequest retailActivity = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c,Core_MDF_Budget_Type_nm__c,Core_MDF_Product_Category_txt__c from PartnerFundRequest where Title='indiaActivity4' limit 1];        
        
        Core_MDF_Bank__c retailMDFBank = [Select ID,Core_MDF_Program__c,Core_MDF_Supplier_Country_txt__c from Core_MDF_Bank__c where Core_MDF_Program__c = 'Core_MDF_Retail_Marketing_Funds'  limit 1];
        retailMDFBank.Core_MDF_Supplier_Country_txt__c = 'USA';
        System.runAs(sysAdm){
          database.update(retailMDFBank);
        }
        //System.Debug('retailMDFBankCntry'+retailMDFBank.Core_MDF_Supplier_Country_txt__c);
        Test.startTest(); 
        PartnerFundClaim retailMdfClaim = Core_MDF_CCP_TestDataUtility.createClaim('Retail MDF Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, retailActivity.Id, System.today(), System.today(), 50.00, System.today(), retailMDFBank.Id, false);
        retailMdfClaim.Core_MDF_Type_Txt__c ='Claim';
        retailMdfClaim.Core_MDF_Currency__c='USD';
        retailMdfClaim.Core_MDF_Country_Location_nm__c= 'India'; 
        retailMdfClaim.Core_MDF_Quarter_Year_Txt__c = 'Q3-2020';
        retailMdfClaim.Core_MDF_VAT_Eligibility_Ind__c = false;
        retailMdfClaim.Core_MDF_Status__c ='Payment Due';
        
        List<String> documentIdWithTitle = new List<String>();
        list<String> tempString = new list<String>();
        list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
        
        String str1 = retailMdfClaim.Id+';#'+'Test Doc1';
        String str2 = retailMdfClaim.Id+';#'+'Test Doc2';
        system.debug('str2' +str2);
        
        documentIdWithTitle.add(str1);
        documentIdWithTitle.add(str2);
        
        for(String str: documentIdWithTitle){
            tempString = str.split(';#');
            Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
            auditDoc.Core_MDF_Document_Id__c = tempString[0];
            auditDoc.Core_MDF_Document_Title__c = tempString[1];
            auditDoc.Core_MDF_Claim__c = retailMdfClaim.Id;
            auditDoc.Core_MDF_Proof_of_Branding__c = true;
            auditDoc.Core_MDF_Proof_of_Cost__c = true;
            auditDoc.Core_MDF_Proof_of_Execution__c = true;                
            auditDocList.add(auditDoc);
            system.debug('auditDocList-->' +auditDocList);
        }            
        
        if(auditDocList.size()>0){
            Database.insert(auditDocList);                
        }
        //String res = Core_MDF_PartnerFundClaim.saveClaim(retailMdfClaim, auditDocList);
        //System.assertEquals(retailMdfClaim.ID,res);
        retailMdfClaim.Core_MDF_Status__c = 'Payment Due';
        Database.update(retailMdfClaim);
        
        PartnerFundClaim retailMdfClaim1 = Core_MDF_CCP_TestDataUtility.createClaim('Retail MDF Claim1', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, retailActivity.Id, System.today(), System.today(), 50.00, System.today(), retailMDFBank.Id, false);
        retailMdfClaim1.Core_MDF_Type_Txt__c ='Claim';
        retailMdfClaim1.Core_MDF_Currency__c='USD';
        retailMdfClaim1.Core_MDF_Country_Location_nm__c= 'India'; 
        retailMdfClaim1.Core_MDF_Quarter_Year_Txt__c = 'Q3-2020';
        retailMdfClaim1.Core_MDF_VAT_Eligibility_Ind__c = false;
        retailMdfClaim1.Core_MDF_Status__c ='Payment Due';
        
        List<String> documentIdWithTitle1 = new List<String>();
        list<String> tempString1 = new list<String>();
        list<Core_MDF_Audit_Document__c> auditDocList1 = new list<Core_MDF_Audit_Document__c>();
        
        String str3 = retailMdfClaim1.Id+';#'+'Test Doc1';
        String str4 = retailMdfClaim1.Id+';#'+'Test Doc2';
        system.debug('str4' +str4);
        
        documentIdWithTitle1.add(str3);
        documentIdWithTitle1.add(str4);
        
        for(String str: documentIdWithTitle1){
            tempString1 = str.split(';#');
            Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
            auditDoc.Core_MDF_Document_Id__c = tempString1[0];
            auditDoc.Core_MDF_Document_Title__c = tempString1[1];
            auditDoc.Core_MDF_Claim__c = retailMdfClaim1.Id;
            auditDoc.Core_MDF_Proof_of_Branding__c = true;
            auditDoc.Core_MDF_Proof_of_Cost__c = true;
            auditDoc.Core_MDF_Proof_of_Execution__c = true;                
            auditDocList1.add(auditDoc);
            system.debug('auditDocList-->' +auditDocList1);
        }            
        
        if(auditDocList1.size()>0){
            Database.insert(auditDocList1);                
        }
        //String res1 = Core_MDF_PartnerFundClaim.saveClaim(retailMdfClaim1, auditDocList1);
        //System.assertEquals(retailMdfClaim1.ID,res1);
        retailMdfClaim1.Core_MDF_Status__c = 'Payment Due';
        
        
        Database.update(retailMdfClaim1);
        Test.stopTest();
        System.runAs(payAdmUser){
            Core_MDF_Payment_Run__c retailPayRunRecord = new Core_MDF_Payment_Run__c();
            retailPayRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
            retailPayRunRecord.Core_MDF_Geo_Txt__c = 'APJ';
            //retailPayRunRecord.Core_MDF_Geo_Txt__c = 'ASMO';
            retailPayRunRecord.Core_MDF_Start_Dt__c = System.today().addDays(-5);                                                       
            retailPayRunRecord.Core_MDF_End_Dt__c = System.today().addDays(5);
            retailPayRunRecord.Core_MDF_Budget_Type_Txt__c = 'retail MDF';
            retailPayRunRecord.Core_MDF_Program_Txt__c  ='Retail Marketing Funds';
            Database.insert(retailPayRunRecord);
            Core_MDF_Batch_PaymentFileGenerator paymentbatch = new Core_MDF_Batch_PaymentFileGenerator (retailPayRunRecord);
            database.executebatch(paymentbatch,200);
            Map<String, Core_MDF_PaymentFileWrapper> fileWrapperMap = new Map<String, Core_MDF_PaymentFileWrapper>();
            Core_MDF_PaymentFileWrapper fileWrapperobj = new Core_MDF_PaymentFileWrapper();
            fileWrapperobj.sumOfClaimsAmount = 2;
            fileWrapperobj.claimsToBeProcessed.add(retailMdfClaim);
            fileWrapperobj.paymentWrapperUniqueKey = 'abc';
            fileWrapperMap.put('line1',fileWrapperobj);
            Core_MDF_PaymentFileWrapper fileWrapperobj2 = new Core_MDF_PaymentFileWrapper();
            fileWrapperobj2.sumOfClaimsAmount = 3;
            fileWrapperobj2.claimsToBeProcessed.add(retailMdfClaim1);
            fileWrapperobj2.paymentWrapperUniqueKey = 'abc';
            fileWrapperMap.put('line2',fileWrapperobj2);
            Core_MDF_PaymentProcessRetailMdfIPA.createPaymentWrapperMap(fileWrapperMap,retailPayRunRecord);
        }        
        
    } 
    public static Map<String, PartnerFundClaim> createClaim(){
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        pfrList = [Select Id,title, Core_MDF_Start_Date__c FROM PartnerFundRequest];
        Map<String, PartnerFundRequest> pfrMap = new Map<String, PartnerFundRequest>();
        for(PartnerFundRequest pfr : pfrList){
            pfrMap.put(pfr.title,pfr);
        }
        List<PartnerFundClaim> claimListToBeProcessed = new List<PartnerFundClaim>();
        Map<String,Core_MDF_Bank__c> bankMap = new Map<String,Core_MDF_Bank__c>();
        for(Core_MDF_Bank__c bank : [Select Id,name from Core_MDF_Bank__c]){
            bankMap.put(bank.name,bank);
        }
        Map<String, PartnerFundClaim> claimMap = new Map<String, PartnerFundClaim>();
        
        PartnerFundClaim indiaClaim = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                               pfrMap.get('indiaActivity').Id, 
                                                                               pfrMap.get('indiaActivity').Core_MDF_Start_Date__c, pfrMap.get('indiaActivity').Core_MDF_Start_Date__c, 
                                                                               101, 
                                                                               pfrMap.get('indiaActivity').Core_MDF_Start_Date__c, bankMap.get('Test CCFBank').ID, false);
        indiaClaim.Core_MDF_Currency__c = 'USD';
        claimListToBeProcessed.add(indiaClaim);
        PartnerFundClaim indiaClaim2 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim2', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                pfrMap.get('indiaActivity1').Id, 
                                                                                pfrMap.get('indiaActivity1').Core_MDF_Start_Date__c, pfrMap.get('indiaActivity1').Core_MDF_Start_Date__c, 
                                                                                100, 
                                                                                pfrMap.get('indiaActivity1').Core_MDF_Start_Date__c, bankMap.get('Test CCFBank').ID, false);
        
        
        indiaClaim2.Core_MDF_Currency__c = 'USD';
        
        claimListToBeProcessed.add(indiaClaim2);
        PartnerFundClaim indiaClaim3 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim3',Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                pfrMap.get('indiaActivity2').Id, 
                                                                                pfrMap.get('indiaActivity2').Core_MDF_Start_Date__c, pfrMap.get('indiaActivity2').Core_MDF_Start_Date__c, 
                                                                                100, 
                                                                                pfrMap.get('indiaActivity2').Core_MDF_Start_Date__c, bankMap.get('Test CCFBank').ID, false);
        
        
        indiaClaim3.Core_MDF_Currency__c = 'USD';
        
        claimListToBeProcessed.add(indiaClaim3);
        PartnerFundClaim indiaClaim4 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim4', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                pfrMap.get('indiaActivity3').Id, 
                                                                                pfrMap.get('indiaActivity3').Core_MDF_Start_Date__c, pfrMap.get('indiaActivity3').Core_MDF_Start_Date__c, 
                                                                                100, 
                                                                                pfrMap.get('indiaActivity3').Core_MDF_Start_Date__c, bankMap.get('Test CCFBank').ID, false);
        
        
        indiaClaim4.Core_MDF_Currency__c = 'USD';
        claimListToBeProcessed.add(indiaClaim4);
        PartnerFundClaim rmfMdfClaim = Core_MDF_CCP_TestDataUtility.createClaim('RMF MDF Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfrMap.get('indiaActivity4').Id, System.today(), System.today(), 50.00, System.today(), bankMap.get('retailBank').ID, false);
        rmfMdfClaim.Core_MDF_Type_Txt__c ='Claim';
        rmfMdfClaim.Core_MDF_Currency__c='USD';
        rmfMdfClaim.Core_MDF_Country_Location_nm__c= 'India'; 
        rmfMdfClaim.Core_MDF_Quarter_Year_Txt__c = 'Q3-2020';
        rmfMdfClaim.Core_MDF_VAT_Eligibility_Ind__c = true;
        rmfMdfClaim.Core_MDF_Status__c ='Payment Due';
        claimListToBeProcessed.add(rmfMdfClaim);
        Database.insert(claimListToBeProcessed);
        

        if(claimListToBeProcessed!=null & claimListToBeProcessed.size()>0){
            for(PartnerFundClaim pfc : claimListToBeProcessed){
                claimMap.put(pfc.title,pfc);
            }
        }        
        return claimMap;
    }
    @isTest static void testDeletePaymentRun(){
        Test.startTest();
        
        List<Core_MDF_Payment_Run__c> paymentRunList = new List<Core_MDF_Payment_Run__c>();
        Map<String, PartnerFundClaim> claimMap = new Map<String, PartnerFundClaim>();
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User payAdmUser = [SELECT Id,Email from User where Email='testPayment@example.com' limit 1];
        claimMap = createClaim();
        Test.stopTest();
        System.runAs(payAdmUser){
            Core_MDF_Payment_Run__c payRunRecord = new Core_MDF_Payment_Run__c();
            payRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
            payRunRecord.Core_MDF_Geo_Txt__c = 'ASMO';
            //payRunRecord.Core_MDF_Program_Id__c  = cp.Id;
            payRunRecord.Core_MDF_Program_Txt__c ='Client CoMarketing Fund';
      
            paymentRunList.add(payRunRecord);
            Database.insert(payRunRecord);
            Database.delete(payRunRecord);
        }
    }
   /* @isTest static void testBuSplitPayment(){
        Map<String, PartnerFundClaim> claimMap = new Map<String, PartnerFundClaim>();
        claimMap = createClaim();
        retailMdfClaim = claimMap.get('RMF MDF Claim');
        ChannelProgram IPACP = [SELECT ID,Name From ChannelProgram where Name = 'Intel Partner Alliance'];
        User payAdmUser = [SELECT Id,Email from User where Email='testPayment@example.com' limit 1];
        System.runAs(payAdmUser){
            Core_MDF_Payment_Run__c retailPayRunRecord = new Core_MDF_Payment_Run__c();
            retailPayRunRecord.Core_MDF_Program_Id__c = IPACP.Id;
            Core_MDF_Configuration__c programsforBuSplit = Core_MDF_Configuration__c.getValues('PROGRAMS_FOR_BU_SPLIT');
            programsforBuSplit.Core_MDF_Value__c = 'Retail Marketing Funds';
            update programsforBuSplit;
            retailMdfClaim = [Select Id,Core_MDF_VAT_Eligibility_Ind__c,Core_MDF_Program__c,Core_MDF_C_Type_Ind__c,Request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_Bank__c,Core_MDF_Bank__r.Core_MDF_Supplier_Number__c,
                              Request.Core_MDF_Product_Category_txt__c,Core_MDF_Quarter_Year_txt__c,Core_MDF_Budget_Type_Nm__c,Amount,Core_MDF_VAT_Amt__c,Core_MDF_Region_Cd__c,Core_MDF_Sub_Region_Cd__c,Request.Core_MDF_BU_Split__c,
                              Request.Core_MDF_BU1_Split_Percent_nbr__c,Request.Core_MDF_BU2_Split_Percent_nbr__c,ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c From PartnerFundClaim where title =: 'Retail MDF Claim' limit 1];
            Core_MDF_PaymentProcessRetailMdfIPA.groupClaimsforPaymentFileRetailMDFIPA(new List<PartnerFundClaim>{retailMdfClaim}, retailPayRunRecord);
        }
    }*/
    @isTest static void testcurrencyCoversion(){
        Map<String, PartnerFundClaim> claimMap = new Map<String, PartnerFundClaim>();
        Test.startTest();
        claimMap = createClaim();
        PartnerFundClaim retailMdfClaim = claimMap.get('RMF MDF Claim');
        retailMdfClaim = [Select Core_MDF_Bank__r.Core_MDF_Payment_Currency_Cd__c FROM PartnerFundClaim where Id =: retailMdfClaim.Id limit 1];
        Map<String, Core_MDF_PaymentFileWrapper> paymentFileWrapperMap = new  Map<String, Core_MDF_PaymentFileWrapper>();
        Core_MDF_PaymentFileWrapper fileWrapper1 = new Core_MDF_PaymentFileWrapper();
        fileWrapper1.sumOfClaimsAmount = 24;
        fileWrapper1.claimsToBeProcessed.add(retailMdfClaim);
        paymentFileWrapperMap.put('key', fileWrapper1);
        List<Core_MDF_Currency_Exchange_Rates__c> newValues = new List<Core_MDF_Currency_Exchange_Rates__c>();
                        
        Core_MDF_Currency_Exchange_Rates__c record1 = new Core_MDF_Currency_Exchange_Rates__c();
        record1.Name= 'USD';
        record1.Core_MDF_Exchange_Rate__c = 1;
        record1.Core_MDF_Market_Date__c =System.today();
        record1.Core_MDF_Intel_WW__c = 'WW23';
        record1.Core_MDF_Unique_Key__c = 'USD'+Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
        newValues.add(record1);
        
        insert newValues;
        Test.stopTest();
        Core_MDF_PaymentProcessRetailMdfIPA.getConvertedAmount(paymentFileWrapperMap);
    }
}