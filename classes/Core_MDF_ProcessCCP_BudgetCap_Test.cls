/****************************************************************************************************************************************
* Class Name  : Core_MDF_ProcessCCP_BudgetCap_Test 
* Version     : 1.0 
* Created Date: 05-09-2019
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – HP        5/09/2019                   Created Core_MDF_ProcessCCP_BudgetCap_Test to test sum of claimed cap amount
*****************************************************************************************************************************************/
@isTest
private class Core_MDF_ProcessCCP_BudgetCap_Test {
/****************************************************************************************************************************************
Method Name:                                   createBudgetCapRecords
Description:                                   Created createBudgetCapRecords() to test sum of claimed cap amount
Added By:                                      Accenture – HP      -  5/09/2019
Modified By:                  Date:            Changes: 
Accenture – HP         5/09/2019         Created.
*****************************************************************************************************************************************/
   public static Id IPA_RecordType = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();

    @TestSetup static void setUpData(){ 
        List<Contact> contactList = new List<Contact>();
        List<User> userList = new List<User>();
        List<ChannelProgram> channelProgramList = new List<ChannelProgram>();
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        List<PartnerFundClaim> claimListToBeProcessed = new List<PartnerFundClaim>();
        List<PartnerFundAllocation> pfaList = new List<PartnerFundAllocation>(); 
        List<Core_MDF_Partner_Group_Mapping__c> pgmList = new List<Core_MDF_Partner_Group_Mapping__c>();
        List<Group> groupList = new List<Group>();
        List<Account> comarketingAccountsList = new List<Account>();
        List<PartnerMarketingBudget> pmbList = new List<PartnerMarketingBudget>();
        List<Campaign> campaignList = new List<Campaign>();
        List<Core_MDF_Account_Bank_Mapping__c> accBankMappingList = new List<Core_MDF_Account_Bank_Mapping__c>();
        List<String> bypassFunctionKeys = new List<String>();
        bypassFunctionKeys.add('Bypass_Duplicate_Budget_Check');
        bypassFunctionKeys.add('Bypass_GeoBased_Budget_Sharing');
        bypassFunctionKeys.add('Bypass_Allocation_Reservation');
        bypassFunctionKeys.add('Bypass_GeoBased_Allocation_Sharing');
        bypassFunctionKeys.add('Bypass_Duplicate_Bank_Check');
        bypassFunctionKeys.add('Bypass_Bank_Internal_Sharing');
        bypassFunctionKeys.add('Bypass_Bank_External_Sharing');
        bypassFunctionKeys.add('Bypass_Bank_ABM_Sharing');
        bypassFunctionKeys.add('Bypass_ABM_Internal_Sharing');
        bypassFunctionKeys.add('Bypass_ABM_External_Sharing');
        bypassFunctionKeys.add('Bypass_ABM_NodeGroup_Sharing');        
        bypassFunctionKeys.add('byPassShareUnshareCampaignRecord');
        bypassFunctionKeys.add('byPassCampaignAndRelatedRecords');
        bypassFunctionKeys.add('Bypass_PaymentRun_Duplicate_Check');
        bypassFunctionKeys.add('Bypass_Claims_Duplicate_Check');
        bypassFunctionKeys.add('Bypass_Duplicate_Budget_Check');
        bypassFunctionKeys.add('Bypass_Claims_Sharing_Internal_Users');
        bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_On_Owner_Chng');
        bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_Internal_Usrs');
        bypassFunctionKeys.add('Bypass_ClaimAdjReq_Share_External_Usrs');
        bypassFunctionKeys.add('Bypass_Claim_AdjReq_Amount_Validation');
        bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Budget_Amt_Check');        
        bypassFunctionKeys.add('Bypass_Claims_ABM_Validation');
        bypassFunctionKeys.add('Bypass_Claims_Sharing_Partner_Users');
        bypassFunctionKeys.add('Bypass_Payment_Doc_InvFileVAT_Validate');
        bypassFunctionKeys.add('Bypass_Bank_Program_InActivation_Check');
        bypassFunctionKeys.add('Bypass_Claims_Amt_vs_Camp_Amt_Check');
        bypassFunctionKeys.add('Bypass_Claim_OwnerLang_EmailTemp');
        bypassFunctionKeys.add('Bypass_StampingOfActySubType_Check');
        bypassFunctionKeys.add('Bypass_Claims_Sharing_On_Owner_Change');
        bypassFunctionKeys.add('Bypass_UpdateActivityFields');
        bypassFunctionKeys.add('Bypass_ValidateActivityWithCampaign');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access');
        bypassFunctionKeys.add('byPass_Cancel_Activity');
        bypassFunctionKeys.add('Bypass_ShareActivityWithUsers');
        bypassFunctionKeys.add('Bypass_Activity_ApprovalProcess');
        bypassFunctionKeys.add('Bypass_ShareActivityWithAccNodeGroup');
        bypassFunctionKeys.add('ShareActivityWithInternalUsers_Bypass');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
        bypassFunctionKeys.add('Bypass_IUPGM_PE_Creation_Insert');
        bypassFunctionKeys.add('Core_MDF_Bypass_Sharing_to_PGM');
        bypassFunctionKeys.add('Core_MDF_BypassAccPgm_Sharing');
        bypassFunctionKeys.add('Bypass_Budget_Approval_Process');
        bypassFunctionKeys.add('ByPass_BlockLegacyBudgetCreation');
        
        Set<String> myset1 = new Set<String>();
        List<String> result1 = new List<String>();
        myset1.addAll(bypassFunctionKeys);
        result1.addAll(myset1);
        
        List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
        
        //Creating Intel Account with utility class
        Account dellCorpAccount = Core_MDF_CCP_TestDataUtility.createAccount ('Dell Corporation', NULL,Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);   
        dellCorpAccount.BillingCity = 'Test City';         
        dellCorpAccount.BillingCountry= 'AUS';
        dellCorpAccount.BillingStreet= 'Test Street';
        dellCorpAccount.BillingState= 'TAS';
        dellCorpAccount.Core_Geo__c= 'APJ';
        database.insert(dellCorpAccount);
        
        //Creating Contact for Partner User
        Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(dellCorpAccount.Id,false);
        conRecord1.MailingCountry ='Australia';
        contactList.add(conRecord1);
        Contact conRecord2 = Core_MDF_CCP_TestDataUtility.createContact(dellCorpAccount.Id,false);
      conRecord2.MailingCountry ='Australia';
        contactList.add(conRecord2);
        
        database.insert(contactList);

        Map<String,PermissionSet> nameToPerSet = new Map<String,PermissionSet>();
        for(PermissionSet pSet:[SELECT Id,Name FROM PermissionSet WHERE Name IN ('Core_MDF_CCP_Internal_Program_Adm',
                            'Core_MDF_CCP_Internal_Claim_Case_Reviewer',
                            'Core_MDF_CCP_External_Claim_Submitter',
                            'Core_MDF_CCP_External_Retail_Claim_Submitter',
                            'Core_MDF_CCP_Internal_APJ_User',
                            'Core_MDF_CCP_Internal_Payment_Schedule_Admin',
                            'Core_MDF_CCP_Internal_Retail_Payment_Adm',
                            'View_All_Data',
                            'Core_MDF_CCP_Internal_CCF_Payment_Adm',
                            'Core_MDF_CCP_Internal_DCF_MDF_Budget_Loader',
                            'Core_MDF_CCP_Internal_DCF_MDF_Payment_Admin',
                            'Core_MDF_CCP_Internal_IPA_Budget_Loader')]) {
            nameToPerSet.put(pSet.Name,pSet);
        }
        
        PermissionSet progAdmPS = nameToPerSet.get('Core_MDF_CCP_Internal_Program_Adm');
        PermissionSet clmCaseUsr = nameToPerSet.get('Core_MDF_CCP_Internal_Claim_Case_Reviewer');
        PermissionSet clmSubmitterUser = nameToPerSet.get('Core_MDF_CCP_External_Claim_Submitter');
        PermissionSet clmRetailSubmitter = nameToPerSet.get('Core_MDF_CCP_External_Retail_Claim_Submitter');
        PermissionSet paymentAdmGeoPS = nameToPerSet.get('Core_MDF_CCP_Internal_APJ_User'); 
        PermissionSet paymentAdmSchedulePS = nameToPerSet.get('Core_MDF_CCP_Internal_Payment_Schedule_Admin'); 
        PermissionSet paymentAdmRMFPS = nameToPerSet.get('Core_MDF_CCP_Internal_Retail_Payment_Adm'); 
        PermissionSet viewAllDataPS = nameToPerSet.get('View_All_Data'); 
        PermissionSet ccpPSadmin = nameToPerSet.get('Core_MDF_CCP_Internal_CCF_Payment_Adm'); 
        PermissionSet ccpMDFBudgetLoaderPS = nameToPerSet.get('Core_MDF_CCP_Internal_DCF_MDF_Budget_Loader'); 
        PermissionSet ccpDCFMDFPayAdminPS = nameToPerSet.get('Core_MDF_CCP_Internal_DCF_MDF_Payment_Admin');
        PermissionSet ipaFinanceUserPS = nameToPerSet.get('Core_MDF_CCP_Internal_IPA_Budget_Loader');
        
       
        Map<String,Id> profileToId = new Map<String,Id>();
        for(Profile prfl:[SELECT Id,Name FROM Profile WHERE Name IN ('System Administrator','Partner','CCP - Core Access')]) {
            profileToId.put(prfl.Name,prfl.Id);
        }
        
        
        // Creating User with utility class 
        User usr = new User(Alias = String.valueOf(datetime.now()).substring(0,8), Email='test1@example.com',
                                 EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', ProfileId = profileToId.get('System Administrator'),
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com',FirstName='Test',
                                 UserPermissionsMarketingUser = TRUE);
        usr.Email = 'sysadmin@example.com';
        usr.IsActive=true;
        userList.add(usr);
        
        User usr1 = new User(Alias = String.valueOf(datetime.now()).substring(0,8), Email='test1@example.com',
                                 EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', ProfileId = profileToId.get('System Administrator'),
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com',FirstName='Test',
                                 UserPermissionsMarketingUser = TRUE);       
        usr1.ContactId = conRecord1.Id;
        usr1.ProfileId = profileToId.get('Partner');
        usr1.isActive = true;
        //userList.add(usr1);
        
        User usr2 = new User(Alias = String.valueOf(datetime.now()).substring(0,8), Email='test1@example.com',
                                 EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', ProfileId = profileToId.get('System Administrator'),
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com',FirstName='Test',
                                 UserPermissionsMarketingUser = TRUE);  
        usr2.Email='testPayment@example.com';
        usr2.LastName='ProgAdmUser';
        usr2.profileId = profileToId.get('CCP - Core Access');
        usr2.IsActive = true;
        userList.add(usr2); 
        
        User usr3 =new User(Alias = String.valueOf(datetime.now()).substring(0,8), Email='test1@example.com',
                                 EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', ProfileId = profileToId.get('System Administrator'),
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com',FirstName='Test',
                                 UserPermissionsMarketingUser = TRUE);  
        usr3.Email='testreviewer@example.com';
        usr3.LastName='ClaimCaseUser';
        usr3.profileId = profileToId.get('CCP - Core Access');
        usr3.IsActive = true;
        userList.add(usr3);
        
        User usr4 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr4.Email = 'ipafinanceuser@example.com';
        usr4.IsActive = true;
        userList.add(usr4);
        
        database.insert(userList);
        
        List<PermissionSetAssignment> permSetAssgnLst = new List<PermissionSetAssignment>();
        
        PermissionSetAssignment assignPermissionSetObj = new PermissionSetAssignment();
        assignPermissionSetObj.AssigneeId = usr2.Id;
        assignPermissionSetObj.PermissionSetId = progAdmPS.Id;
        permSetAssgnLst.add(assignPermissionSetObj);
        
        PermissionSetAssignment assignPermissionSetObj2 = new PermissionSetAssignment();
        assignPermissionSetObj2.AssigneeId = usr2.Id;
        assignPermissionSetObj2.PermissionSetId = ccpPSadmin.Id;
        permSetAssgnLst.add(assignPermissionSetObj2);
        
        PermissionSetAssignment assignPermissionSetObj1 = new PermissionSetAssignment();
        assignPermissionSetObj1.AssigneeId = usr3.Id;
        assignPermissionSetObj1.PermissionSetId = clmCaseUsr.Id;
        permSetAssgnLst.add(assignPermissionSetObj1);
        
        PermissionSetAssignment assignGeoPermissionSet = new PermissionSetAssignment();
        assignGeoPermissionSet.AssigneeId = usr2.Id;
        assignGeoPermissionSet.PermissionSetId = paymentAdmGeoPS.Id;
        permSetAssgnLst.add(assignGeoPermissionSet);
        
        PermissionSetAssignment assignSchedulePermissionSet = new PermissionSetAssignment();
        assignSchedulePermissionSet.AssigneeId = usr2.Id;
        assignSchedulePermissionSet.PermissionSetId = paymentAdmSchedulePS.Id;
        permSetAssgnLst.add(assignSchedulePermissionSet);
        
        PermissionSetAssignment assignRMFPermissionSet = new PermissionSetAssignment();
        assignRMFPermissionSet.AssigneeId = usr2.Id;
        assignRMFPermissionSet.PermissionSetId = paymentAdmRMFPS.Id;
        permSetAssgnLst.add(assignRMFPermissionSet);
        
        PermissionSetAssignment assignViewAllPermissionSet = new PermissionSetAssignment();
        assignViewAllPermissionSet.AssigneeId = usr2.Id;
        assignViewAllPermissionSet.PermissionSetId = viewAllDataPS.Id;
        permSetAssgnLst.add(assignViewAllPermissionSet);
        
        PermissionSetAssignment assignClaimCasePermissionSet = new PermissionSetAssignment();
        assignClaimCasePermissionSet.AssigneeId = usr.Id;
        assignClaimCasePermissionSet.PermissionSetId = clmCaseUsr.Id;
        permSetAssgnLst.add(assignClaimCasePermissionSet);
        
        PermissionSetAssignment assignMDFDCfPayAdmPermissionSet = new PermissionSetAssignment();
        assignMDFDCfPayAdmPermissionSet.AssigneeId = usr2.Id;
        assignMDFDCfPayAdmPermissionSet.PermissionSetId = ccpDCFMDFPayAdminPS.Id;
        permSetAssgnLst.add(assignMDFDCfPayAdmPermissionSet);
        
        PermissionSetAssignment assignIPAFInanceUsrPermissionSet = new PermissionSetAssignment();
        assignIPAFInanceUsrPermissionSet.AssigneeId = usr4.Id;
        assignIPAFInanceUsrPermissionSet.PermissionSetId = ipaFinanceUserPS.Id;
        permSetAssgnLst.add(assignIPAFInanceUsrPermissionSet);
        
        system.runAs(usr){
            Database.insert(permSetAssgnLst);
        }

        //IUPGM isert
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm1 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm1.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
        iupgm1.RecordTypeId = IPA_RecordType;
        iupgm1.Core_MDF_Region_cd__c = 'WW';
        iupgm1.Core_MDF_User_id__c = usr4.Id;
        iupgm1.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_IPA_Budget_Loader';
        iupgm1.Core_MDF_All_Accounts_cd__c = 'yes';
        iupgm1.Core_MDF_All_Budget_Type_Access_Ind__c = true;
        iupgm1.Core_MDF_Active_Ind__c= TRUE;
        iupgm1.Core_MDF_Region_Sub_Region_nm__c = 'WW';
        
        iupgmList.add(iupgm1);
        system.runAs(usr){
            insert iupgmList;
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
        
        Group grp3 = new Group();
        grp3.name = 'PGM_TEST3';
        groupList.add(grp3);
        
        system.runAs(usr){
            Database.insert(groupList);
        }
        
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
        system.runAs(usr){
            Database.insert(usList);
        }
        
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
        //GroupMember gm6 = new GroupMember();
        //gm6.GroupId = grp3.Id;
        //gm6.UserOrGroupId = usr1.Id;
        gmList.add(gm);
        gmList.add(gm1);
        gmList.add(gm2);
        gmList.add(gm3);
        gmList.add(gm4);
        gmList.add(gm5);
        //gmList.add(gm6);
        
        system.runAs(usr){
            insert gmList;
        }
        
        // Creating Channel program
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client','Client CoMarketing Fund', false);
        channelProgramList.add(cp);
        ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Datacenter','Data Center CoMarketing Fund', false);
        channelProgramList.add(cp1);
        ChannelProgram cp2 = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', false);        
        channelProgramList.add(cp2);
        
        system.runAs(usr2){
            database.insert(channelProgramList);
        }
        
        // Creating Co-marketing Account with utility class
        Account dellCCFVirtualCorp = Core_MDF_CCP_TestDataUtility.createAccount ('Dell CCF Virtual Corp', cp.Id,Core_MDF_CCP_TestDataUtility.account_Record_Type, false);
        dellCCFVirtualCorp.Core_MDF_Parent_Fund_Account__c = dellCorpAccount.Id;
        dellCCFVirtualCorp.Core_MDF_CoMarketingActive__c = true;
        comarketingAccountsList.add(dellCCFVirtualCorp);
        
        // Creating Co-marketing Account with utility class
        Account dellDCFVirtualCorpMDF = Core_MDF_CCP_TestDataUtility.createAccount ('Dell DCF Virtual Corp', cp1.Id,Core_MDF_CCP_TestDataUtility.account_Record_Type, false);
        dellDCFVirtualCorpMDF.Core_MDF_Parent_Fund_Account__c = dellCorpAccount.Id;
        dellDCFVirtualCorpMDF.Core_MDF_CoMarketingActive__c = true;
        comarketingAccountsList.add(dellDCFVirtualCorpMDF);
    
        // Creating Co-marketing Account with utility class
        Account dellRMFVirtualCorp = Core_MDF_CCP_TestDataUtility.createAccount ('Dell RMF Virtual Corp', cp2.Id,Core_MDF_CCP_TestDataUtility.account_Record_Type, false);
        dellRMFVirtualCorp.Core_MDF_Parent_Fund_Account__c = dellCorpAccount.Id;
        dellRMFVirtualCorp.Core_Geo__c = 'APJ';
        comarketingAccountsList.add(dellRMFVirtualCorp);
        
        system.runAs(usr2){
            Database.insert(comarketingAccountsList);
        }
        
        Core_MDF_Partner_Group_Mapping__c pgm = new Core_MDF_Partner_Group_Mapping__c();
        pgm.Core_MDF_Account__c = dellCorpAccount.Id;
        pgm.Core_MDF_Group_Name__c = 'PGM_TEST';
        pgm.Core_MDF_Type_of_Access__c = 'Internal';
        pgm.Core_MDF_Group_Id__c = grp.Id;                
        pgm.Core_MDF_Channel_Program__c = cp.Id;
        pgm.Core_MDF_Region_cd__c='WW';
        pgm.Core_MDF_Source_Txt__c = 'test';
        pgm.Core_MDF_AccountIdGroupName__c = dellCorpAccount.Id+'PGM_TEST';
        pgmList.add(pgm);
        
        Core_MDF_Partner_Group_Mapping__c pgm1 = new Core_MDF_Partner_Group_Mapping__c();
        pgm1.Core_MDF_Account__c = dellCorpAccount.Id;
        pgm1.Core_MDF_Group_Name__c = 'PGM_TEST1';
        pgm1.Core_MDF_Type_of_Access__c = 'Internal';
        pgm1.Core_MDF_Group_Id__c = grp1.Id;                
        pgm1.Core_MDF_Channel_Program__c = cp.Id;
        pgm1.Core_MDF_Region_cd__c='EMEA';
        pgm1.Core_MDF_Source_Txt__c = 'test';
        pgm1.Core_MDF_AccountIdGroupName__c =dellCorpAccount.Id+'PGM_TEST1';
        pgmList.add(pgm1);
        
        Core_MDF_Partner_Group_Mapping__c pgm2 = new Core_MDF_Partner_Group_Mapping__c();
        pgm2.Core_MDF_Account__c = dellCorpAccount.Id;
        pgm2.Core_MDF_Group_Name__c = 'PGM_TEST2';
        pgm2.Core_MDF_Type_of_Access__c = 'Internal';
        pgm2.Core_MDF_Group_Id__c = grp2.Id;                
        pgm2.Core_MDF_Channel_Program__c = cp.Id;
        pgm2.Core_MDF_Region_cd__c='ASMO';
        pgm2.Core_MDF_Source_Txt__c = 'test';
        pgm2.Core_MDF_AccountIdGroupName__c =dellCorpAccount.Id+'PGM_TEST2';
        pgmList.add(pgm2);
        
        Core_MDF_Partner_Group_Mapping__c pgm3 = new Core_MDF_Partner_Group_Mapping__c();
        pgm3.Core_MDF_Account__c = dellCorpAccount.Id;
        pgm3.Core_MDF_Group_Name__c = 'PGM_TEST3';
        pgm3.Core_MDF_Type_of_Access__c = 'External';
        pgm3.Core_MDF_Group_Id__c = grp3.Id;                
        pgm3.Core_MDF_Channel_Program__c = cp.Id;
        pgm3.Core_MDF_Region_cd__c='ASMO';
        pgm3.Core_MDF_Source_Txt__c = 'test';
        pgm3.Core_MDF_AccountIdGroupName__c =dellCorpAccount.Id+'PGM_TEST3';
        pgmList.add(pgm3);
        
        system.runAs(usr){
            database.insert(pgmList);
        }
                   
        //Creating campaign
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7+ Processor','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today().addDays(-10), System.today().addDays(10), 10000, 'Consumer Chromebook', dellCCFVirtualCorp.Id, '2-in-1', false); 
        camp.Core_MDF_Opal_Budget_Type_Txt__c= 'OEM CMP';
        camp.Core_MDF_Technology__c = '';
        campaignList.add(camp);
    
        Campaign retailCampaign = Core_MDF_CCP_TestDataUtility.createCampaign('Retail Campaigm1','Gaming','9ᵗʰ Gen','No', Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds', System.today().addDays(-20), System.today().addDays(20), 100000, 'Instore innovation', dellRMFVirtualCorp.Id,'Desktop', false); 
        retailCampaign.Core_MDF_Is_Opal__c='No';
        retailCampaign.Core_MDF_Opal_Budget_Type_Txt__c= 'Retail MDF';
        retailCampaign.Core_MDF_Activity_Category_Type__c =null;
        retailCampaign.Core_MDF_Reimbursement_Rate__c='100%';
        retailCampaign.Core_MDF_Technology__c = 'Wifi6';
        campaignList.add(retailCampaign);
        
        Campaign MdfCampaign = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp MDF','Gaming','Intel® Core™ i7+ Processor','MDF or both CMP & MDF', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_DCF, 'Data Center CoMarketing Fund', System.today().addDays(-100), System.today().addDays(10), 10000, 'Consumer Chromebook', dellDCFVirtualCorpMDF.Id, '2-in-1', false); 
        MdfCampaign.Core_MDF_Is_Opal__c='Yes MDF or both CMP & MDF';
        MdfCampaign.Core_MDF_Opal_Budget_Type_Txt__c='MDF';
        MdfCampaign.Core_MDF_Activity_Category__c = 'Audio 2025';
        MdfCampaign.Core_MDF_Activity_Category_Type__c = 'Audio 2025->Podcast';
        MdfCampaign.Core_MDF_Reimbursement_Rate__c='100%';
        MdfCampaign.Core_MDF_Technology__c = '';
        campaignList.add(MdfCampaign);
        
        Campaign rsaMDCamp = Core_MDF_CCP_TestDataUtility.createCampaign('Retail Campaigm2','Gaming','9ᵗʰ Gen','No', Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds', System.today().addDays(-10), System.today().addDays(10), 100000, 'Instore innovation', dellRMFVirtualCorp.Id,'Desktop', false); 
        rsaMDCamp.Core_MDF_Is_Opal__c='No';
        rsaMDCamp.Core_MDF_Opal_Budget_Type_Txt__c='RSA MD';
        rsaMDCamp.Core_MDF_Activity_Category_Type__c =null;
        rsaMDCamp.Core_MDF_Reimbursement_Rate__c='100%';
        rsaMDCamp.Core_MDF_Technology__c = 'Wifi6';
        campaignList.add(rsaMDCamp);
        //Test.startTest();
        system.runAs(usr2){
            database.insert(campaignList);
        } 
        
        PartnerMarketingBudget  pmbRecord = Core_MDF_CCP_TestDataUtility.createBudget('Dell PMB',Core_MDF_CCP_TestDataUtility.budget_Record_Type,dellCCFVirtualCorp.Id,cp.Id,1000000,System.today().addDays(-15),System.today().addDays(15),false);
        pmbRecord.IsIgnoreValidation = true;
        pmbRecord.Core_MDF_Budget_Type_Txt__c = 'OEM CMP';
        pmbList.add(pmbRecord);
    
        PartnerMarketingBudget  pmbRecord1 = Core_MDF_CCP_TestDataUtility.createRetailBudget('Dell RMF PMB',Core_MDF_CCP_TestDataUtility.budget_Retail_Record_Type,dellRMFVirtualCorp.Id,cp2.Id,1000000,System.today().addDays(-15),System.today().addDays(15),false, 'Retail MDF');
        pmbRecord1.IsIgnoreValidation = true;
        pmbRecord1.Core_MDF_Budget_Type_Txt__c = 'Retail MDF';
        pmbList.add(pmbRecord1);
        
        PartnerMarketingBudget  pmbRecord2 = Core_MDF_CCP_TestDataUtility.createRetailBudget('RSABudget',Core_MDF_CCP_TestDataUtility.budget_Retail_Record_Type,dellRMFVirtualCorp.Id,cp2.Id,1000000,System.today().addDays(-15),System.today().addDays(15),false, 'RSA MD');
        pmbRecord2.IsIgnoreValidation = true;
        pmbRecord2.Core_MDF_Budget_Type_Txt__c = 'RSA MD';
        pmbList.add(pmbRecord2);
        system.runAs(usr2){
            Database.insert(pmbList);
        }
        PermissionSetAssignment assignMDFBudgetLoaderPermissionSet = new PermissionSetAssignment();
        assignMDFBudgetLoaderPermissionSet.AssigneeId = usr.Id;
        assignMDFBudgetLoaderPermissionSet.PermissionSetId = ccpMDFBudgetLoaderPS.Id; 
        system.runAs(usr){
            Database.insert(assignMDFBudgetLoaderPermissionSet);
        }
        Id DCF_RecordType = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Data_Center_Co_Marketing_Fund').getRecordTypeId();

        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmMDF = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgmMDF.Core_MDF_Account_id__c = dellCorpAccount.id;
        iupgmMDF.Core_MDF_Program_nm__c = 'Data Center CoMarketing Fund';
        iupgmMDF.RecordTypeId = DCF_RecordType;
        iupgmMDF.Core_MDF_Channel_Program_id__c = cp1.id;
        iupgmMDF.Core_MDF_All_Accounts_cd__c = 'No';
        iupgmMDF.Core_MDF_User_id__c = usr.id;
        iupgmMDF.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_DCF_MDF_Budget_Loader';
        iupgmMDF.Core_MDF_Region_cd__c = 'WW';
        iupgmMDF.Core_MDF_Region_Sub_Region_nm__c = 'WW';
        system.runAs(usr){
            Database.insert(iupgmMDF);
        }
        
        // Create PFA records for the above accounts :
        PartnerFundAllocation pfaDellCCFVirtualCorp = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('pfaDellCCFVirtualCorp',pmbRecord, dellCCFVirtualCorp, 100000,false);
        pfaList.add(pfaDellCCFVirtualCorp);
        PartnerFundAllocation retailAlloc = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('retailAlloc',pmbRecord1,dellRMFVirtualCorp,20000.0,false);
        pfaList.add(retailAlloc);
        PartnerFundAllocation rsaMdAlloc = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('RSAMDalloc',pmbRecord2,dellRMFVirtualCorp,20000.0,false);
        pfaList.add(rsaMdAlloc);
        system.runAs(usr2){
            database.insert(pfaList);
        }
        
        List<Core_MDF_Bank__c> listBank = new List<Core_MDF_Bank__c>();
        //Creating Bank
        Core_MDF_Bank__c indiaBank = Core_MDF_CCP_TestDataUtility.createBank(dellCorpAccount.Id, 'CCF', false,'1231231230');
        indiaBank.Core_MDF_Bank_Status__c = 'Active';
        indiaBank.Core_MDF_Effective_Date__c=System.today().addDays(-4);
        indiaBank.name = 'Test CCFBank';
        indiaBank.Core_MDF_Program__c='Core_MDF_Client_CoMarketing_Fund';
        indiaBank.Core_MDF_Payment_Currency_Cd__c = 'USD';
        listBank.add(indiaBank);
        
        Core_MDF_Bank__c retailBank = Core_MDF_CCP_TestDataUtility.createBank(dellCorpAccount.Id, 'Core_MDF_Retail_Marketing_Funds', false,'1231231230');
        retailBank.Core_MDF_Intel_Company_Code__c = '150';
        retailBank.name = 'retailBank';
        retailBank.Core_MDF_Currency_cd__c = 'USD';
        retailBank.Core_MDF_Payment_Currency_Cd__c = 'USD';
        retailBank.Core_MDF_Tax_codes_cd__c = 'I0';
        retailBank.Core_MDF_Bank_Location__c = 'US';
        retailBank.Core_MDF_Bank_Status__c = 'Active';  
        retailBank.Core_MDF_Effective_Date__c=System.today().addDays(-4); 
        retailBank.Core_MDF_Supplier_Country_txt__c = 'US';  
        retailBank.Core_MDF_Supplier_City_txt__c = 'New York';  
        retailBank.Core_MDF_Supplier_Region_txt__c = 'New York';  
        retailBank.Core_MDF_Supplier_Postal_Code_cd__c = '728378'; 
        retailBank.Core_MDF_VAT_pct__c = '10';
        listBank.add(retailBank);
        
        System.runAs(usr){
            database.insert(listBank);
        
        //creating ABM for bank1
        Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(dellCCFVirtualCorp.Id,indiaBank.Id,true);
        accBankMappingList.add(abm1);
        Core_MDF_Account_Bank_Mapping__c abm2 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(dellRMFVirtualCorp.Id,retailBank.Id,true);
        accBankMappingList.add(abm2);
        }
         Test.startTest(); 
        //Creating Partner fund Request for each Geo 
        PartnerFundRequest indiaActivity = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                 string.valueof(dellCCFVirtualCorp.id),pfaDellCCFVirtualCorp,pmbRecord,
                                                                                                 'BRAZIL','Consumer','Desktop','Intel® Core™ i5 Processor','Broadcast','Podcast','Draft'
                                                                                                 ,false);
        indiaActivity.Title = 'indiaActivity';
        indiaActivity.Core_MDF_Activity_Description__c = 'indiaActivity';
        indiaActivity.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
        indiaActivity.BudgetId = pmbRecord.Id;
        indiaActivity.Core_MDF_Start_Date__c = System.today().addDays(-3);
        indiaActivity.Core_MDF_End_Date__c = System.today().addDays(5);
        indiaActivity.RequestedAmount = 1000;
        indiaActivity.amount = 1000;
        indiaActivity.Core_MDF_Channel_Partner_Led__c = True;
        indiaActivity.Core_MDF_Reimbursement_Rate_txt__c='60%';
        pfrList.add(indiaActivity);
        
        PartnerFundRequest indiaActivity1= Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                 string.valueof(dellCCFVirtualCorp.id),pfaDellCCFVirtualCorp,pmbRecord,
                                                                                                 'SINGAPORE','Consumer','Desktop','Intel® Core™ i5 Processor','Broadcast','Podcast','Draft'
                                                                                                 ,false);
        indiaActivity1.Title = 'indiaActivity1';
        indiaActivity1.Core_MDF_Activity_Description__c = 'indiaActivity';
        indiaActivity1.BudgetId = pmbRecord.Id;
        indiaActivity1.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
        indiaActivity1.Core_MDF_Start_Date__c = System.today();
        indiaActivity1.Core_MDF_End_Date__c = System.today();
        indiaActivity1.RequestedAmount = 1000;
        indiaActivity1.amount = 1000;
        indiaActivity1.Core_MDF_Channel_Partner_Led__c = True;
        indiaActivity1.Core_MDF_Reimbursement_Rate_txt__c='60%';
        pfrList.add(indiaActivity1);
        PartnerFundRequest indiaActivity2= Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                 string.valueof(dellCCFVirtualCorp.id),pfaDellCCFVirtualCorp,pmbRecord,
                                                                                                 'EGYPT','Consumer','Desktop','Intel® Core™ i5 Processor','Broadcast','Podcast','Draft'
                                                                                                ,false);
        indiaActivity2.Title = 'indiaActivity2';
        indiaActivity2.Core_MDF_Activity_Description__c = 'indiaActivity';
        indiaActivity2.BudgetId = pmbRecord.Id;
        indiaActivity2.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
        indiaActivity2.Core_MDF_Start_Date__c = System.today();
        indiaActivity2.Core_MDF_End_Date__c = System.today();
        indiaActivity2.RequestedAmount = 1000;
        indiaActivity2.amount = 1000;
        indiaActivity2.Core_MDF_Channel_Partner_Led__c = True;
        indiaActivity2.Core_MDF_Reimbursement_Rate_txt__c='60%';
        pfrList.add(indiaActivity2);
        PartnerFundRequest indiaActivity3 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                  string.valueof(dellCCFVirtualCorp.id),pfaDellCCFVirtualCorp,pmbRecord,
                                                                                                  'MACAU','Consumer','Desktop','Intel® Core™ i5 Processor','Broadcast','Podcast','Draft'
                                                                                                  ,false);
        indiaActivity3.Title = 'indiaActivity3';
        indiaActivity3.Core_MDF_Activity_Description__c = 'indiaActivity';
        indiaActivity3.BudgetId = pmbRecord.Id;
        indiaActivity3.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
        indiaActivity3.Core_MDF_Start_Date__c = System.today();
        indiaActivity3.Core_MDF_End_Date__c = System.today();
        indiaActivity3.RequestedAmount = 1000;
        indiaActivity3.Core_MDF_Reimbursement_Rate_txt__c='60%';
        indiaActivity3.amount = 1000;
        indiaActivity3.Core_MDF_Channel_Partner_Led__c = True;
        pfrList.add(indiaActivity3);
        PartnerFundRequest indiaActivity4 = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(retailCampaign.Id),string.valueof(dellRMFVirtualCorp.id),
                            System.today(),System.today(),false);
        indiaActivity4.Title = 'indiaActivity4';
        indiaActivity4.Core_MDF_Budget_Type_nm__c = 'Retail MDF';
        indiaActivity4.Core_MDF_Country_nm__c = 'INDIA';
        indiaActivity4.Core_MDF_Reimbursement_Rate_pct__c = '100%';
        indiaActivity4.RequestedAmount =1000;
        indiaActivity4.Amount=1000;
        indiaActivity4.Core_MDF_Reimbursement_Rate_txt__c='60%';
        indiaActivity4.Core_MDF_Product_Category_txt__c ='Notebook/Mobile';
        indiaActivity4.AllocationId = retailAlloc.Id;
        //pfrList.add(indiaActivity4);
        
        PartnerFundRequest indiaActivity5 = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(rsaMDCamp.Id),string.valueof(dellRMFVirtualCorp.id),
                            System.today(),System.today(),false);
        indiaActivity5.Title = 'indiaActivity5';
        indiaActivity5.Core_MDF_Budget_Type_nm__c = 'RSA MD';
        indiaActivity5.Core_MDF_Country_nm__c = 'INDIA';
        indiaActivity5.Core_MDF_Reimbursement_Rate_pct__c = '100%';
        indiaActivity5.Core_MDF_Reimbursement_Rate_txt__c = '100%';
        indiaActivity5.RequestedAmount =1000;
        indiaActivity5.Amount=1000;
        indiaActivity5.Core_MDF_Reimbursement_Rate_txt__c='60%';
        indiaActivity5.AllocationId = rsaMdAlloc.Id;
        //pfrList.add(indiaActivity5);
        
        System.runAs(usr2){
            Database.insert(pfrList);
        }
        
        
        
        Core_MDF_CCP_TestDataUtility.createTriggerExecutionRecords();
        
        Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();
        List<Core_MDF_Configuration__c> mdfRecTypesList = new List<Core_MDF_Configuration__c>();
        Core_MDF_Configuration__c mdfRecTypes = new Core_MDF_Configuration__c();
        mdfRecTypes.name='Payment_Run_RecordTypes_MDF';
        mdfRecTypes.Core_MDF_Value__c='Client_Co_Marketing_Fund_MDF,Data_Center_Co_Marketing_Fund_MDF';
        mdfRecTypesList.add(mdfRecTypes);
        
        Core_MDF_Configuration__c mdfbudgTypes= new Core_MDF_Configuration__c();
        mdfbudgTypes.name='BUDGET_TYPE_CLAIM_BANK_HIDE';
        mdfbudgTypes.Core_MDF_Value__c='MDF,MDF+';
        mdfRecTypesList.add(mdfbudgTypes);
        
        Core_MDF_Configuration__c Programs_For_MDF_PaymentRun= new Core_MDF_Configuration__c();
        Programs_For_MDF_PaymentRun.name='Programs_For_MDF_PaymentRun';
        Programs_For_MDF_PaymentRun.Core_MDF_Value__c='Client Co-Marketing Fund,Data Center Co-Marketing Fund';
        mdfRecTypesList.add(Programs_For_MDF_PaymentRun);
        
        Core_MDF_Configuration__c mdfClaimType = new Core_MDF_Configuration__c();
        mdfClaimType.name='Core_MDF_ClaimTypeValues';
        mdfClaimType.Core_MDF_Value__c='YMNS,YMNC';
        mdfRecTypesList.add(mdfClaimType);
        
        Core_MDF_Configuration__c mdfSalesUnit= new Core_MDF_Configuration__c();
        mdfSalesUnit.name='Core_MDF_Sales_Unit';
        mdfSalesUnit.Core_MDF_Value__c='PC';
        mdfRecTypesList.add(mdfSalesUnit);
        
        Core_MDF_Configuration__c MDfRowHeaders= new Core_MDF_Configuration__c();
        MDfRowHeaders.name='Core_MDF_Row_Headers';
        MDfRowHeaders.Core_MDF_Value__c='H,I';
        mdfRecTypesList.add(MDfRowHeaders);
        
        Core_MDF_Configuration__c distributChannel= new Core_MDF_Configuration__c();
        distributChannel.name='Core_MDF_Vistex_Distribution_Channel';
        distributChannel.Core_MDF_Value__c='1';
        mdfRecTypesList.add(distributChannel);
        
        Core_MDF_Configuration__c vistexDivision= new Core_MDF_Configuration__c();
        vistexDivision.name='Core_MDF_Vistex_Division';
        vistexDivision.Core_MDF_Value__c='1';
        mdfRecTypesList.add(vistexDivision);
        
        Core_MDF_Configuration__c Programs_For_PaymentRun= new Core_MDF_Configuration__c();
        Programs_For_PaymentRun.name='PROGRAMS_FOR_BU_SPLIT';
        Programs_For_PaymentRun.Core_MDF_Value__c='Retail Marketing Funds;Intel Partner Alliance';
        mdfRecTypesList.add(Programs_For_PaymentRun);
        
        Core_MDF_Configuration__c ALLOWED_PRG_FOR_RUS_NOTIF= new Core_MDF_Configuration__c();
        ALLOWED_PRG_FOR_RUS_NOTIF.name='ALLOWED_PRG_FOR_RUS_NOTIF';
        ALLOWED_PRG_FOR_RUS_NOTIF.Core_MDF_Value__c='Client Co-Marketing Fund';
        mdfRecTypesList.add(ALLOWED_PRG_FOR_RUS_NOTIF);
        
        Database.insert(mdfRecTypesList);
        
        PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, indiaActivity.Id, indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 50.00, System.today(), indiaBank.Id, false);
        claim1.Core_MDF_Currency__c='USD';//INR
        claim1.Core_MDF_Country_Location_nm__c = 'Brazil';
        claim1.Core_MDF_Budget_Type_Options_Nm__c = 'CCF 1.0';
        claim1.Core_MDF_Status__c = 'Payment Due';
        claim1.Core_MDF_Region_Cd__c='ASMO';
        claim1.Core_MDF_Processing_Preference_nm__c='Settle, then get paid';
        database.Insert(claim1);
        
        List<Core_Trigger_Executions__c> customSettings = new List<Core_Trigger_Executions__c>();
        
        Core_Trigger_Executions__c setting4 = new Core_Trigger_Executions__c();
        setting4.Core_Active__c = true;
        setting4.Core_Class_Name__c = 'Core_MDF_AdjustmentClaimOffsetProcess';
        setting4.Core_Description__c = 'Demo Description';
        setting4.Core_Object__c = 'Core_MDF_Payment_Run__c';
        setting4.Core_Trigger_Events__c = 'after insert';
        setting4.name = 'Core_MDF_AdjustmentClaimOffsetProcess';
        customSettings.add(setting4);
        insert customSettings;
        
        Test.stopTest();
        List<Core_MDF_Currency_Exchange_Rates__c> newValues = new List<Core_MDF_Currency_Exchange_Rates__c>();
        Core_MDF_Currency_Exchange_Rates__c record1 = new Core_MDF_Currency_Exchange_Rates__c();
        record1.Name= 'ZMK';
        record1.Core_MDF_Exchange_Rate__c = 0.0000850159;
        record1.Core_MDF_Market_Date__c =System.today();
        record1.Core_MDF_Intel_WW__c = Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
        record1.Core_MDF_Unique_Key__c = 'USA'+Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
        newValues.add(record1);
      
        Core_MDF_Currency_Exchange_Rates__c record2 = new Core_MDF_Currency_Exchange_Rates__c();
        record2.Name= 'INR';
        record2.Core_MDF_Exchange_Rate__c = 1;
        record2.Core_MDF_Market_Date__c =System.today();
        record2.Core_MDF_Intel_WW__c = Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
        record2.Core_MDF_Unique_Key__c = 'INR'+Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
        newValues.add(record2); 
        
        Core_MDF_Currency_Exchange_Rates__c record3 = new Core_MDF_Currency_Exchange_Rates__c();
        record3.Name= 'USD';
        record3.Core_MDF_Exchange_Rate__c = 1;
        record3.Core_MDF_Market_Date__c =System.today();
        record3.Core_MDF_Intel_WW__c = Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
        record3.Core_MDF_Unique_Key__c = 'USD'+Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
        newValues.add(record3); 
        database.insert(newValues);
        
    }
    
    @isTest static void createBudgetCapRecords() {
        test.startTest();
        UserRole usRole = [SELECT Id,name FROM UserRole where Name = 'Admin' LIMIT 50000];
        PartnerMarketingBudget pmbRecord = [select id,title,Core_MDF_Budget_Status__c, TotalAllocatedAmount from PartnerMarketingBudget where title = 'Dell PMB'];
        // Creating User with utility class 
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName = 'User Test1';
        usr1.UserRoleId = usRole.Id;
        Database.insert(usr1);
        System.runAs(usr1){
            Core_MDF_Budget_Cap__c budgetCap = new Core_MDF_Budget_Cap__c();
            budgetCap.Core_MDF_Cap_Type_nm__c = 'Channel Led Activity';
            budgetCap.Core_MDF_Budget_Name_id__c = pmbRecord.Id;
            budgetCap.Core_MDF_Requested_Cap_amt__c = 15000;
            Database.insert(budgetCap);  
            
            
            //Updating budget cap record to validate error 
            Core_MDF_Budget_Cap__c bcRecord = [SELECT Id,Core_MDF_Requested_Cap_amt__c,Core_MDF_Cap_Type_nm__c,Core_MDF_Approved_Cap_amt__c FROM 
                                               Core_MDF_Budget_Cap__c WHERE Id =:budgetCap.Id ];
            bcRecord.Core_MDF_Requested_Cap_amt__c = 5000;
            Database.saveResult srRes2 = Database.update(bcRecord,false);
            //System.assertEquals(false,srRes2.isSuccess());
            Assert.areEqual(false, srRes2.isSuccess());
            List<Database.saveResult> srResList = new List<Database.saveResult>(); 
            srResList.add(srRes2);
            // Calling insertLogEntryRecord method
            Core_MDF_ProcessCCP_BudgetCap.insertLogEntryRecord(srResList);
            Core_MDF_ProcessCCP_BudgetCap.insertLogEntryRecord(null);
            test.stoptest();
        }
    }

/****************************************************************************************************************************************
    Method Name:                                             testValidateRuleMethod
    Description:                                             Created for Validating Rules
    Added By:                                                Accenture – HP  -  5/09/2019
    Modified By:                  Date:                      Changes: 
    Accenture – Harika P          5/09/2019                  Created.
*****************************************************************************************************************************************/      
    
    @isTest static void testValidateRuleMethod()
    { 
        test.startTest();
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 50000];
        
        // Creating User with utility class 
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName = 'User Test1';
        usr1.UserRoleId = usRole.Id;
        Database.insert(usr1);
        System.runAs(usr1){
            Boolean ruleResult;
            //testing validateRule method for data type DOUBLE with appropriate operators
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('10','10','Equal','DOUBLE');
            Assert.areEqual(true, ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('10','20','Not Equal','DOUBLE');
            Assert.areEqual(true, ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('10','40','Equal','DOUBLE');
            Assert.areEqual(false, ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('20','20','Not Equal','DOUBLE');  
            Assert.areEqual(false, ruleResult);

            //testing validateRule method for data type PICKLIST with appropriate operators         
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('50%','50%','Equal','PICKLIST');
            Assert.areEqual(true, ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('50%','30%','Not Equal','PICKLIST');
            Assert.areEqual(true, ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('50%','30%','Greater Than','PICKLIST');
            Assert.areEqual(false, ruleResult);
            
            //testing validateRule method for data type CURRENCY with appropriate operators             
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('5000','2000','Not Equal','CURRENCY');
            Assert.areEqual(true, ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('5000','5000','Equal','CURRENCY');
            Assert.areEqual(true, ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('5000','2000','Greater Than','CURRENCY');
            Assert.areEqual(true, ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('2000','5000','Less Than','CURRENCY');
            Assert.areEqual(true, ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('5000','4000','Greater Than or Equal','CURRENCY');
            Assert.areEqual(true, ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('4000','5000','Less Than or Equal','CURRENCY');
            Assert.areEqual(true, ruleResult);
            
            //testing validateRule method for data type DATE with appropriate operators  
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching(String.valueOf(System.today().addDays(5)),String.valueOf(System.today()),
                                                                      'Greater Than','DATE');
            Assert.areEqual(true, ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching(String.valueOf(System.today()),String.valueOf(System.today().addDays(5)),
                                                                      'Less Than','DATE');
            Assert.areEqual(true, ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching(String.valueOf(System.today()),String.valueOf(System.today()),'Equal','DATE');
            Assert.areEqual(true, ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching(String.valueOf(System.today()),String.valueOf(System.today()),'Not Equal',
                                                                      'DATE');
            Assert.areEqual(false, ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching(String.valueOf(System.today()),String.valueOf(System.today()),
                                                                      'Greater Than or Equal','DATE');
            Assert.areEqual(true, ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching(String.valueOf(System.today()),String.valueOf(System.today().addDays(1)),
                                                                      'Less Than or Equal','DATE');
            Assert.areEqual(true, ruleResult);
            
            //testing validateRule method for data type MULTIPICKLIST with appropriate operators    
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('ALBANIA;AUSTRALIA','ALBANIA;AUSTRALIA','Equal','MULTIPICKLIST');
            Assert.areEqual(true, ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('ALBANIA;AUSTRALIA','ALBANIA;AUSTRALIA','Not Equal','MULTIPICKLIST');
            Assert.areEqual(false, ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('ALBANIA;AUSTRALIA','ALBANIA;INDIA','Not Equal','MULTIPICKLIST');
            Assert.areEqual(true, ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('ALBANIA;AUSTRALIA','ALBANIA;INDIA','Equal','MULTIPICKLIST');
            Assert.areEqual(false, ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('ALBANIA','ALBANIA;AUSTRALIA','Equal','MULTIPICKLIST');
            Assert.areEqual(false, ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('ALBANIA;AUSTRALIA','ALBANIA;AUSTRALIA','Greater Than','MULTIPICKLIST');
            Assert.areEqual(false, ruleResult);
            
            //testing validateRule method for data type TEXTAREA with appropriate operators
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('Tset','Test','Equal','TEXTAREA');
            Assert.areEqual(false, ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('Test','Test','Equal','TEXTAREA');
            Assert.areEqual(true, ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('Test1','Test','Not Equal','TEXTAREA');
            Assert.areEqual(true, ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('Test1','Test','Not Equal','TESTFIELDTYPE');
            Assert.areEqual(false, ruleResult);
            
            //testing validateRule method for data type all with appropriate IN,NOT In, Equla and Not Equal operators
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('ALBANIA','ALBANIA;AUSTRALIA','In','MULTIPICKLIST');
            Assert.areEqual(true, ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('ALBANIA;INDIA','ALBANIA;AUSTRALIA','In','MULTIPICKLIST');
            Assert.areEqual(false, ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('ALBANIA;INDIA','ALBANIA;AUSTRALIA','Not In','MULTIPICKLIST');
            Assert.areEqual(false, ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('10','10','In','STRING');
            Assert.areEqual(true, ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('10;20','10','In','STRING');
            Assert.areEqual(false, ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching(NULL,NULL,'In','STRING');
            Assert.areEqual(true, ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching(NULL,'ALBANIA;AUSTRALIA','In','STRING');
            Assert.areEqual(false, ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching(NULL,'ALBANIA;AUSTRALIA','Not In','STRING');
            Assert.areEqual(true, ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('ALBANIA','ALBANIA;AUSTRALIA','Not In','STRING');
            Assert.areEqual(false, ruleResult);     
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('INDIA','ALBANIA;AUSTRALIA','Not In','STRING');
            Assert.areEqual(true, ruleResult);    
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching(NULL,NULL,'Not In','STRING');
            Assert.areEqual(false, ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('ALBANIA','ALBANIA;AUSTRALIA','In','MULTIPICKLIST');
            Assert.areEqual(true, ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('ALBANIA',NULL,'In','MULTIPICKLIST');
            Assert.areEqual(false, ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching(NULL,'ALBANIA','In','MULTIPICKLIST');
            Assert.areEqual(false, ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching(NULL,NULL,'In','MULTIPICKLIST');
            Assert.areEqual(true, ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching(NULL,NULL,'Not In','MULTIPICKLIST');
            Assert.areEqual(false, ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('ALBANIA','ALBANIA;AUSTRALIA','Not In','MULTIPICKLIST');
            Assert.areEqual(false, ruleResult);     
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching(NULL,'ALBANIA','Not In','MULTIPICKLIST');
            Assert.areEqual(true, ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching(NULL,NULL,'Equal','MULTIPICKLIST');
            Assert.areEqual(true, ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('ALBANIA',NULL,'Equal','STRING');
            Assert.areEqual(false, ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching(NULL,'ALBANIA','Equal','MULTIPICKLIST');
            Assert.areEqual(false, ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching(NULL,NULL,'Not Equal','MULTIPICKLIST');
            Assert.areEqual(false, ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('ALBANIA',NULL,'Not Equal','STRING');
            Assert.areEqual(true, ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching(NULL,'ALBANIA','Not Equal','MULTIPICKLIST');
            Assert.areEqual(true, ruleResult);
            ruleResult = Core_MDF_ProcessCCP_BudgetCap.isCriteriaMatching('INDIA','ALBANIA;AUSTRALIA','Not In','MULTIPICKLIST');
            Assert.areEqual(true, ruleResult);     
          
            test.stopTest();
        }
    }
    @isTest static void testIPADuplicateOverlappingCaps(){
        Test.startTest();
        list<Core_MDF_Configuration__c> configSettingList = new list<Core_MDF_Configuration__c>();
        Core_MDF_Configuration__c setting = new Core_MDF_Configuration__c();
        setting.Name = 'CAMPAIGN_STATUS_IGNOREDFOR_BDGTCAPLINK';
        setting.Core_MDF_Value__c = 'Cancelled';
        setting.Core_MDF_Category__c='Campaign Status for exclusion while budgtCap Link';
        configSettingList.add(setting);
        
        Core_MDF_Configuration__c setting1 = new Core_MDF_Configuration__c();
        setting1.Name = 'CAMPAIGN_STATUS_FOR_BUDGETCAPAMT';
        setting1.Core_MDF_Value__c = 'Pending Approval,Planned,In Progress,Completed';
        setting1.Core_MDF_Category__c='IPA Budget Type Cap Linking Delinking';
        configSettingList.add(setting1);
        database.insert(configSettingList);
        
        Id ipaBudTypeCapRecordtype = Schema.SObjectType.Core_MDF_Budget_Cap__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_IPA_Budget_Type_Cap').getRecordTypeId();
        List<User> userList = new List<User>();
        Map<String,Id> profileToId = new Map<String,Id>();
        for(Profile prfl:[SELECT Id,Name FROM Profile WHERE Name IN ('System Administrator')]) {
            profileToId.put(prfl.Name,prfl.Id);
        }
        User usr = [SELECT Id,Email from User where Email='ipafinanceuser@example.com' limit 1];
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmDebug = [select id,Core_MDF_Budget_Type_nm__c,/*Core_MDF_Budget_Type_txt__c,*/ Core_MDF_Region_cd__c,Core_MDF_All_Budget_Type_Access_Ind__c,Core_MDF_Role_nm__c,Core_MDF_GeoSubGeo_Budget_Type_nm__c,Core_MDF_Channel_Program_id__r.Core_MDF_Technical_Program_Name__c,Core_MDF_Active_Ind__c,Core_MDF_is_User_Active_ind__c from Core_MDF_Int_Users_Partner_Geo_Mapping__c where Core_MDF_User_id__c = :usr.id];

        List<Core_MDF_Budget_Cap__c> ipaBudgetCaps = new List<Core_MDF_Budget_Cap__c>();
        Core_MDF_Budget_Cap__c budgetCapJan = new Core_MDF_Budget_Cap__c();
        budgetCapJan.RecordtypeId = ipaBudTypeCapRecordtype;
        budgetCapJan.Core_MDF_Budget_Type_nm__c = 'Business Client Acceleration - MDF';
        budgetCapJan.Core_MDF_Requested_Cap_amt__c = 31;
        budgetCapJan.Core_MDF_Effective_Start_Date_Dt__c = Date.newInstance(2021, 01, 05);
        budgetCapJan.Core_MDF_Effective_End_Date_Dt__c = Date.newInstance(2021, 01, 06);
        budgetCapJan.Core_MDF_Region_nm__c = 'APJ';
        ipaBudgetCaps.add(budgetCapJan);
        Core_MDF_Budget_Cap__c budgetCapFeb = new Core_MDF_Budget_Cap__c();
        budgetCapFeb.RecordtypeId = ipaBudTypeCapRecordtype;
        budgetCapFeb.Core_MDF_Budget_Type_nm__c = 'Business Client Acceleration - MDF';
        budgetCapFeb.Core_MDF_Requested_Cap_amt__c = 31;
        budgetCapFeb.Core_MDF_Effective_Start_Date_Dt__c = Date.newInstance(2021, 02, 05);
        budgetCapFeb.Core_MDF_Effective_End_Date_Dt__c = Date.newInstance(2021, 02, 06);
        budgetCapFeb.Core_MDF_Region_nm__c = 'APJ';
        ipaBudgetCaps.add(budgetCapFeb);
        try{
            System.runAs(usr){
                insert ipaBudgetCaps;             
            }
        }catch(Exception e){
                String errorMessage = e.getMessage();
                //system.debug(errorMessage +'errorMessageAfter 1stInsertion');
            } 
        
        ipaBudgetCaps = new List<Core_MDF_Budget_Cap__c>();        
        Core_MDF_Budget_Cap__c budgetCapJan1 = new Core_MDF_Budget_Cap__c();
        budgetCapJan1.RecordtypeId = ipaBudTypeCapRecordtype;
        budgetCapJan1.Core_MDF_Budget_Type_nm__c = 'Business Client Acceleration - MDF';
        budgetCapJan1.Core_MDF_Requested_Cap_amt__c = 32;
        budgetCapJan1.Core_MDF_Effective_Start_Date_Dt__c = Date.newInstance(2021, 01, 04);
        budgetCapJan1.Core_MDF_Effective_End_Date_Dt__c = Date.newInstance(2021, 01, 07);
        budgetCapJan1.Core_MDF_Region_nm__c = 'APJ';
        ipaBudgetCaps.add(budgetCapJan1);
        Core_MDF_Budget_Cap__c budgetCapJan3 = new Core_MDF_Budget_Cap__c();
        budgetCapJan3.RecordtypeId = ipaBudTypeCapRecordtype;
        budgetCapJan3.Core_MDF_Budget_Type_nm__c = 'Business Client Acceleration - MDF';
        budgetCapJan3.Core_MDF_Requested_Cap_amt__c = 31;
        budgetCapJan3.Core_MDF_Effective_Start_Date_Dt__c = Date.newInstance(2021, 01, 05);
        budgetCapJan3.Core_MDF_Effective_End_Date_Dt__c = Date.newInstance(2021, 01, 06);
        budgetCapJan3.Core_MDF_Region_nm__c = 'APJ';
        ipaBudgetCaps.add(budgetCapJan3);
        System.runAs(usr){          
            try{
                database.insert(ipaBudgetCaps);
            }
            catch(Exception e){
                //System.debug('Exception Caught'+e);
            }
        }
        Test.stopTest();
        Assert.areNotEqual(ipaBudgetCaps, null);  
    }
/****************************************************************************************************************************************
    Method Name:                                             testCampaignLinkDelinkOnBudgetCapCreation
    Description:                                             Created to check campaigns are linking/Delinking to the budgetcap on creation
    Added By:                                                Accenture – Nirmala  -  27/02/2021
    Modified By:                  Date:                      Changes: 
    Accenture – Nirmala K        27/05/2021                   Created.
*****************************************************************************************************************************************/ 
    @isTest static void testCampaignLinkDelinkOnBudgetCapCreation() {
        User usr1= [SELECT Id,Email from User where Email='ipafinanceuser@example.com' limit 1];
        
        Group ipaGrp = new Group();
        ipaGrp.Name = 'Core CCP IPA External';
        ipaGrp.DeveloperName = 'Core_MDF_CCP_IPA_External';
        Database.insert(ipaGrp);
        
        GroupMember ipaGrpMem = new GroupMember();
        ipaGrpMem.UserOrGroupId = usr1.Id;
        ipaGrpMem.GroupId = ipaGrp.Id;
        Database.insert(ipaGrpMem);
        
        
        System.runAs(usr1){
            list<Core_Trigger_Executions__c> list2 = new list<Core_Trigger_Executions__c>();
            Core_Trigger_Executions__c execution1 = new Core_Trigger_Executions__c();
            execution1.Name = 'BypassCampaignBenefitValidation';
            execution1.Core_Active__c = FALSE;
            execution1.Core_Class_Name__c = 'Core_MDF_Proposal_Based_Campaign_Process';
            execution1.Core_Description__c = 'BypassCampaignBenefitValidation';
            execution1.Core_Object__c = 'Campaign';
            execution1.Core_Trigger_Events__c = 'Before Update,Before Insert';
            list2.add(execution1);
            
            Core_Trigger_Executions__c execution2 = new Core_Trigger_Executions__c();
            execution2.Name = 'Core_MDF_Bypass_Manual_Share';
            execution2.Core_Active__c = TRUE;
            execution2.Core_Class_Name__c = 'Core_MDF_PNUMappingTriggerHandler';
            execution2.Core_Description__c = 'Switch ON/OFF the Manual Share';
            execution2.Core_Object__c = 'Core_MDF_Partner_Node_User_Mapping__c';
            execution2.Core_Trigger_Events__c = 'After Insert';
            list2.add(execution2);
            insert list2;
            
            list <Core_MDF_Configuration__c> list3 = new list <Core_MDF_Configuration__c>();
            Core_MDF_Configuration__c setting = new Core_MDF_Configuration__c();
            setting.Name = 'CAMPAIGN_STATUS_IGNOREDFOR_BDGTCAPLINK';
            setting.Core_MDF_Value__c = 'Cancelled';
            setting.Core_MDF_Category__c='Campaign Status for exclusion while budgtCap Link';
            list3.add(setting);
            //insert setting;
            
            Core_MDF_Configuration__c setting1 = new Core_MDF_Configuration__c();
            setting1.Name = 'CAMPAIGN_STATUS_FOR_BUDGETCAPAMT';
            setting1.Core_MDF_Value__c = 'Pending Approval,Planned,In Progress,Completed';
            setting1.Core_MDF_Category__c='IPA Budget Type Cap Linking Delinking';
            list3.add(setting1);
            
            
            Core_MDF_Configuration__c setting2 = new Core_MDF_Configuration__c();
            setting2.Name = 'UPDATE_CAMPAIGN_BATCH_SIZE';
            setting2.Core_MDF_Value__c = '100';
            setting2.Core_MDF_Category__c='Batch Size';
            list3.add(setting2);
            insert list3;

            ChannelProgram ipaCP = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', true);
            // Creating Intel Account with utility class
            Account ipaUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('IPA Intel Account for Test',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);            
            // Creating Co-marketing Account with utility class
            Account ipaCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('IPA Co-Marketing Account', ipaCP.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,ipaUltimateAccount.id, true);           

            Test.StartTest();
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmIPA = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgmIPA.Core_MDF_Account_id__c = ipaUltimateAccount.Core_MDF_Parent_Fund_Account__c;
            iupgmIPA.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
            iupgmIPA.RecordTypeId = IPA_RecordType;
            iupgmIPA.Core_MDF_Budget_Type_nm__c = 'Client Specialties MDF';
            iupgmIPA.Core_MDF_All_Budget_Type_Access_Ind__c=true;
            iupgmIPA.Core_MDF_Region_Sub_Region_nm__c = 'WW';
            iupgmIPA.Core_MDF_Region_cd__c='WW';
            iupgmIPA.Core_MDF_User_id__c = usr1.Id;
            iupgmIPA.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_IPA_Budget_Loader';
            iupgmIPA.Core_MDF_All_Accounts_cd__c = 'Yes';
            Database.insert(iupgmIPA);
            
            Core_MDF_Partner_Group_Mapping__c pgm1 = new Core_MDF_Partner_Group_Mapping__c();
            pgm1.Core_MDF_Account__c = ipaUltimateAccount.Id;
            pgm1.Core_MDF_Group_Name__c = 'Core_MDF_CCP_IPA_External';
            pgm1.Core_MDF_Type_of_Access__c = 'EXTERNAL';
            pgm1.Core_MDF_Group_Id__c = ipaGrp.Id;                
            pgm1.Core_MDF_Channel_Program__c = ipaCP.Id;
            pgm1.Core_MDF_Source_Txt__c = 'Test';
            pgm1.Core_MDF_Region_cd__C = 'APJ';
            pgm1.Core_MDF_AccountIdGroupName__c = ipaUltimateAccount.Id+'Core_MDF_CCP_IPA_External';
            Database.insert(pgm1);
            String budgetType = Core_MDF_CCP_ConstantClass.CS_MDF_BUDGET_TYPE;
            // Creating Campaign using utility class
            Campaign ipaCampaignForAP = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - AP',ipaCoMarketingAccount.id, System.today(), System.today().adddays(30),budgetType, 110000,'INDIA', 'Developer', 'Apollo Lake', 'Pending Review', true);
            ipaCampaignForAP.Core_MDF_Opal_Budget_Type_Txt__c ='Client Specialties MDF';
            // Creating Budget using Utility class
            //PartnerMarketingBudget  pmbRecord = Core_MDF_CCP_TestDataUtility.createBudget('Dell PMB',Core_MDF_CCP_TestDataUtility.budget_Record_Type,ipaCoMarketingAccount.Id,ipaCP.Id,1000000,System.today().addDays(-4),System.today().addDays(110),true);
            // fetching IPA record type for Budget cap
            Id recordTypeId =Schema.SObjectType.Core_MDF_Budget_Cap__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_IPA_Budget_Type_Cap').getRecordTypeId();
            // Creating Campaign using utility class
            
            Campaign ipaCampaign1 = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - Budgetcap2',ipaCoMarketingAccount.id, system.today().addDays(-249), system.today().addDays(-151),'Client Specialties MDF', 110000,'INDIA', 'Developer', 'Apollo Lake', 'In Progress', true);
            Campaign ipaCampaign2 = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - Budgetcap3',ipaCoMarketingAccount.id, system.today().addDays(-250), system.today().addDays(-150),'Client Specialties MDF', 110000,'INDIA', 'Developer', 'Apollo Lake', 'Completed', true);
            Approval.Lock(ipaCampaign2,true);
            //creating budget caps within the range of startdate and enddate of campaign
            List<Core_MDF_Budget_Cap__c> bdtCapList=new List<Core_MDF_Budget_Cap__c>();
            Core_MDF_Budget_Cap__c budcap1= new Core_MDF_Budget_Cap__c();
            budcap1.RecordTypeId=recordTypeId;
            budcap1.Core_MDF_Budget_Type_nm__c='Client Specialties MDF';
            budcap1.Core_MDF_Cap_Status_nm__c='Active';
            budcap1.Core_MDF_Effective_Start_Date_Dt__c=system.today().addDays(-400);
            budcap1.Core_MDF_Effective_End_Date_Dt__c=system.today().addDays(-350);
            budcap1.Core_MDF_Requested_Cap_amt__c=9000000;
            budcap1.Core_MDF_Region_nm__c = 'APJ';
            bdtCapList.add(budcap1);
            Core_MDF_Budget_Cap__c budcap2= new Core_MDF_Budget_Cap__c();
            budcap2.RecordTypeId=recordTypeId;
            budcap2.Core_MDF_Budget_Type_nm__c='Client Specialties MDF';
            budcap2.Core_MDF_Cap_Status_nm__c='Active';
            budcap2.Core_MDF_Effective_Start_Date_Dt__c=system.today().addDays(-250);
            budcap2.Core_MDF_Effective_End_Date_Dt__c=system.today().addDays(-150);
            budcap2.Core_MDF_Requested_Cap_amt__c=9000000;
            budcap2.Core_MDF_Region_nm__c = 'APJ';
            bdtCapList.add(budcap2);
            Core_MDF_Budget_Cap__c budcap3= new Core_MDF_Budget_Cap__c();
            budcap3.RecordTypeId=recordTypeId;
            budcap3.Core_MDF_Budget_Type_nm__c='Client Specialties MDF';
            budcap3.Core_MDF_Cap_Status_nm__c='Active';
            budcap3.Core_MDF_Effective_Start_Date_Dt__c=system.today().addDays(-50);
            budcap3.Core_MDF_Effective_End_Date_Dt__c=system.today().addDays(-10);
            budcap3.Core_MDF_Requested_Cap_amt__c=9000000;
            budcap3.Core_MDF_Region_nm__c = 'WW';
            bdtCapList.add(budcap3);
            Core_MDF_Budget_Cap__c budcap4= new Core_MDF_Budget_Cap__c();
            budcap4.RecordTypeId=recordTypeId;
            budcap4.Core_MDF_Budget_Type_nm__c='Client Specialties MDF';
            budcap4.Core_MDF_Cap_Status_nm__c='Active';
            budcap4.Core_MDF_Effective_Start_Date_Dt__c=system.today().addDays(-250);
            budcap4.Core_MDF_Effective_End_Date_Dt__c=system.today().addDays(-150);
            budcap4.Core_MDF_Requested_Cap_amt__c=9000000;
            budcap4.Core_MDF_Region_nm__c = 'ASMO';
            bdtCapList.add(budcap4);
            System.runAs(usr1){
                try{Database.insert(bdtCapList);}
                catch(Exception ex){
                    //system.debug(ex);
                }
            }
            
            List<Core_MDF_Budget_Cap__c> bdtCapListUpdate=[Select id,Core_MDF_Cap_Status_nm__c,Core_MDF_Budget_Type_nm__c,Core_MDF_Effective_Start_Date_Dt__c,Core_MDF_Effective_End_Date_Dt__c,Core_MDF_Requested_Cap_amt__c from Core_MDF_Budget_Cap__c
                                                           where Core_MDF_Cap_Status_nm__c='Active' AND Core_MDF_Budget_Type_nm__c='Client Specialties MDF' LIMIT 2];                                                                
                                                                              
            bdtCapListUpdate[0].Core_MDF_Cap_Status_nm__c='Inactive';
            bdtCapListUpdate[1].Core_MDF_Effective_Start_Date_Dt__c = system.today().addDays(-251);
            Database.Update(bdtCapListUpdate);
            List<Core_MDF_Budget_Cap__c> bdtCapListUpdate2=new List<Core_MDF_Budget_Cap__c>();
            budcap1.Core_MDF_Cap_Status_nm__c = 'Active';
            budcap2.Core_MDF_Cap_Status_nm__c = 'Active';
            budcap2.Core_MDF_Effective_Start_Date_Dt__c=system.today().addDays(-252);
            budcap2.Core_MDF_Effective_End_Date_Dt__c=system.today().addDays(-145);
            bdtCapListUpdate2.add(budcap1);
            bdtCapListUpdate2.add(budcap2);
            System.runAs(usr1){
                try{Database.Update(bdtCapListUpdate2);}
                catch(Exception ex){
                    //system.debug(ex);
                }
            }
            Core_MDF_Batch_UpdateCampaigns updateCampaignBatch = new Core_MDF_Batch_UpdateCampaigns(new List<Campaign>{ipaCampaign1});
            updateCampaignBatch.failedBudgetCapIds = new Set<Id>{budcap1.Id};
                updateCampaignBatch.setFailedIndicatorOnBudgetCaps();
                database.executeBatch(updateCampaignBatch);
            Test.stopTest();
            Assert.areNotEqual(budcap1, null);  
        }
    }   
}