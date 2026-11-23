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
    
    public static Id payRun_RecordType_CCFCMP = Schema.SObjectType.Core_MDF_Payment_Run__c.getRecordTypeInfosByDeveloperName().get('Client_Co_Marketing_Fund_CMP').getRecordTypeId();
    public static Id payRun_RecordType_DCFCMP = Schema.SObjectType.Core_MDF_Payment_Run__c.getRecordTypeInfosByDeveloperName().get('Data_Center_Co_Marketing_Fund_CMP').getRecordTypeId();
    public static Id payRun_RecordType_DCFMDF = Schema.SObjectType.Core_MDF_Payment_Run__c.getRecordTypeInfosByDeveloperName().get('Data_Center_Co_Marketing_Fund_MDF').getRecordTypeId();
    public static Id payRun_RecordType_RMF = Schema.SObjectType.Core_MDF_Payment_Run__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
    public static Id payRun_RecordType_CoGTM = Schema.SObjectType.Core_MDF_Payment_Run__c.getRecordTypeInfosByDeveloperName().get('Co_Engineering').getRecordTypeId();
    
    @TestSetup static void setUpData(){ 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
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
        bypassFunctionKeys.add('Core_MDF_XMLToXLSGenerationFlag');
        bypassFunctionKeys.add('Core_MDF_StringToXLSGenerationFlag');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
        bypassFunctionKeys.add('byPass_Cancel_Activity');
        bypassFunctionKeys.add('Core_MDF_Bypass_ATFBatchUpdate');
        bypassFunctionKeys.add('Bypass_PaymentsBulkAPISharing');
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
        conRecord1.AccountId = dellCorpAccount.Id;
        contactList.add(conRecord1);
        Contact conRecord2 = Core_MDF_CCP_TestDataUtility.createContact(dellCorpAccount.Id,false);
        conRecord1.AccountId = dellCorpAccount.Id;
        contactList.add(conRecord2);
        
        database.insert(contactList);
        
        Map<String,PermissionSet> nameToPerSet = new Map<String,PermissionSet>();
        for(PermissionSet pSet:[SELECT Id,Name FROM PermissionSet WHERE Name IN ('Core_MDF_CCP_Internal_Program_Adm','Core_MDF_CCP_Internal_Claim_Case_Reviewer','Core_MDF_CCP_External_Claim_Submitter','Core_MDF_CCP_External_Retail_Claim_Submitter','Core_MDF_CCP_Internal_APJ_User','Core_MDF_CCP_Internal_Payment_Schedule_Admin','Core_MDF_CCP_Internal_Retail_Payment_Adm','View_All_Data','Core_MDF_CCP_Internal_CCF_Payment_Adm','Core_MDF_CCP_Internal_DCF_MDF_Budget_Loader','Core_MDF_CCP_Internal_DCF_MDF_Payment_Admin','Core_MDF_CCP_Internal_Co_GTM_Payment_Adm')]) {
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
        Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name = 'CCP - Core Access'];        
        
        Map<String,Id> profileToId = new Map<String,Id>();
        for(Profile prfl:[SELECT Id,Name FROM Profile WHERE Name IN ('System Administrator','Partner','CCP - Core Access')]) {
            profileToId.put(prfl.Name,prfl.Id);
        }
        
        // Creating User with utility class 
        User usr = new User(Alias = String.valueOf(datetime.now()).substring(0,8), Email='test1@example.com',EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = profileToId.get('System Administrator'),TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com',FirstName='Test',UserPermissionsMarketingUser = TRUE);
        usr.Email = 'sysadmin@example.com';
        usr.IsActive=true;
        userList.add(usr);
        
        User usr1 = new User(Alias = String.valueOf(datetime.now()).substring(0,8), Email='test1@example.com',EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = profileToId.get('System Administrator'),TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com',FirstName='Test',UserPermissionsMarketingUser = TRUE);       
        usr1.ContactId = conRecord1.Id;
        usr1.ProfileId = profileToId.get('Partner');
        usr1.isActive = true;
        userList.add(usr1);
        
        User usr2 = new User(Alias = String.valueOf(datetime.now()).substring(0,8), Email='test1@example.com',EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = profileToId.get('System Administrator'),TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com',FirstName='Test',UserPermissionsMarketingUser = TRUE);  
        usr2.Email='testPayment@example.com';
        usr2.LastName='ProgAdmUser';
        usr2.profileId = profileToId.get('CCP - Core Access');
        usr2.IsActive = true;
        //usr2.userRoleId = usRole.Id;
        userList.add(usr2); 
        
        User usr3 =new User(Alias = String.valueOf(datetime.now()).substring(0,8), Email='test1@example.com',EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = profileToId.get('System Administrator'),TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com',FirstName='Test',UserPermissionsMarketingUser = TRUE);  
        usr3.Email='testreviewer@example.com';
        usr3.LastName='ClaimCaseUser';
        usr3.profileId = profileToId.get('CCP - Core Access');
        usr3.IsActive = true;
        userList.add(usr3);
        User usrcogtmPayAdm = Core_MDF_CCP_TestDataUtility.createUser(false); 
        usrcogtmPayAdm.Email='testCoGTMPayment@example.com';
        usrcogtmPayAdm.LastName='PayAdmUser';
        usrcogtmPayAdm.profileId = profileToId.get('CCP - Core Access');
        usrcogtmPayAdm.IsActive = true;        
        userList.add(usrcogtmPayAdm);
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
        
        PermissionSet cogtmPaymentAdmPS = nameToPerSet.get('Core_MDF_CCP_Internal_Co_GTM_Payment_Adm');
        
        // Assigning CoGTM Payment Admin PS Co-GTM
        PermissionSetAssignment assignPermissionSetObj3 = new PermissionSetAssignment();
        assignPermissionSetObj3.AssigneeId = usrcogtmPayAdm.Id;
        assignPermissionSetObj3.PermissionSetId = cogtmPaymentAdmPS.Id;
        permSetAssgnLst.add(assignPermissionSetObj3);
        
        // Assigning Payment Admin Schedule PS Co-GTM
        PermissionSetAssignment assignSchedulePermissionSetForCoGTM = new PermissionSetAssignment();
        assignSchedulePermissionSetForCoGTM.AssigneeId = usrcogtmPayAdm.Id;
        assignSchedulePermissionSetForCoGTM.PermissionSetId = paymentAdmSchedulePS.Id;
        permSetAssgnLst.add(assignSchedulePermissionSetForCoGTM);
        
        // Assigning View All Data PS Co-GTM
        PermissionSetAssignment assignViewAllPermissionSetCoGTM = new PermissionSetAssignment();
        assignViewAllPermissionSetCoGTM.AssigneeId = usrcogtmPayAdm.Id;
        assignViewAllPermissionSetCoGTM.PermissionSetId = viewAllDataPS.Id;
        permSetAssgnLst.add(assignViewAllPermissionSetCoGTM);
        
        PermissionSetAssignment assignViewAllPermissionSetCoGTMAPJ = new PermissionSetAssignment();
        assignViewAllPermissionSetCoGTMAPJ.AssigneeId = usrcogtmPayAdm.Id;
        assignViewAllPermissionSetCoGTMAPJ.PermissionSetId = paymentAdmGeoPS.Id;
        permSetAssgnLst.add(assignViewAllPermissionSetCoGTMAPJ);
        
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
        
        Group grp3 = new Group();
        grp3.name = 'PGM_TEST3';
        groupList.add(grp3);
        
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
        GroupMember gm6 = new GroupMember();
        gm6.GroupId = grp3.Id;
        gm6.UserOrGroupId = usr1.Id;
        gmList.add(gm);
        gmList.add(gm1);
        gmList.add(gm2);
        gmList.add(gm3);
        gmList.add(gm4);
        gmList.add(gm5);
        gmList.add(gm6);
        system.runAs(usr){
            insert gmList;
        }
        Core_MDF_Configuration__c c=new Core_MDF_Configuration__c();
        c.Name='Core_MDF_RecoveryClaimUpdateBatch_Size';
        c.Core_MDF_Value__c='30';
        insert c;
        
        // Creating Channel program
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client','Client CoMarketing Fund', false);
        channelProgramList.add(cp);
        ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Datacenter','Data Center CoMarketing Fund', false);
        channelProgramList.add(cp1);
        ChannelProgram cp2 = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', false);        
        channelProgramList.add(cp2);
        
        database.insert(channelProgramList);
        
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
        dellRMFVirtualCorp.Core_MDF_External_Group_Id__c = grp.Id;
        dellRMFVirtualCorp.Core_MDF_Group_Id__c = grp.Id;
        comarketingAccountsList.add(dellRMFVirtualCorp);
        
        Database.insert(comarketingAccountsList);   
        
        
        Core_MDF_Partner_Group_Mapping__c pgm = new Core_MDF_Partner_Group_Mapping__c();
        pgm.Core_MDF_Account__c = dellCorpAccount.Id;
        pgm.Core_MDF_Group_Name__c = 'PGM_TEST_Group2';
        pgm.Core_MDF_Type_of_Access__c = 'Internal';
        pgm.Core_MDF_Group_Id__c = grp.Id;                
        pgm.Core_MDF_Channel_Program__c = cp.Id;
        pgm.Core_MDF_Region_cd__c='WW';
        pgm.Core_MDF_Source_Txt__c = 'test';
        pgm.Core_MDF_AccountIdGroupName__c = dellCorpAccount.Id+'PGM_TEST_Group2';
        // pgmList.add(pgm);
        
        Core_MDF_Partner_Group_Mapping__c pgm1 = new Core_MDF_Partner_Group_Mapping__c();
        pgm1.Core_MDF_Account__c = dellCorpAccount.Id;
        pgm1.Core_MDF_Group_Name__c = 'PGM_TEST_Group1';
        pgm1.Core_MDF_Type_of_Access__c = 'Internal';
        pgm1.Core_MDF_Group_Id__c = grp1.Id;                
        pgm1.Core_MDF_Channel_Program__c = cp.Id;
        pgm1.Core_MDF_Region_cd__c='EMEA';
        pgm1.Core_MDF_Source_Txt__c = 'test';
        pgm1.Core_MDF_AccountIdGroupName__c =dellCorpAccount.Id+'PGM_TEST_Group1';
        // pgmList.add(pgm1);
        
        Core_MDF_Partner_Group_Mapping__c pgm2 = new Core_MDF_Partner_Group_Mapping__c();
        pgm2.Core_MDF_Account__c = dellCorpAccount.Id;
        pgm2.Core_MDF_Group_Name__c = 'PGM_TEST5';
        pgm2.Core_MDF_Type_of_Access__c = 'Internal';
        pgm2.Core_MDF_Group_Id__c = grp2.Id;                
        pgm2.Core_MDF_Channel_Program__c = cp.Id;
        pgm2.Core_MDF_Region_cd__c='ASMO';
        pgm2.Core_MDF_Source_Txt__c = 'test';
        pgm2.Core_MDF_AccountIdGroupName__c =dellCorpAccount.Id+'PGM_TEST5';
        //pgmList.add(pgm2);
        
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
        
        database.insert(pgmList); 
        
        
        //Creating 
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7+ Processor','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today().addDays(-30), System.today().addDays(30), 10000, 'Consumer Chromebook', dellCCFVirtualCorp.Id, '2-in-1', false); 
        camp.Core_MDF_Opal_Budget_Type_Txt__c= 'OEM CMP';
        campaignList.add(camp);
        
        Campaign retailCampaign = Core_MDF_CCP_TestDataUtility.createCampaign('Retail Campaigm1','Gaming','9ᵗʰ Gen','No', Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds', System.today().addDays(-30), System.today().addDays(30), 100000, 'Instore innovation', dellRMFVirtualCorp.Id,'Desktop', false); 
        retailCampaign.Core_MDF_Is_Opal__c='No';
        retailCampaign.Core_MDF_Opal_Budget_Type_Txt__c= 'Retail MDF';
        retailCampaign.Core_MDF_Budget_Type_txt__c= 'Retail MDF';
        retailCampaign.Core_MDF_Activity_Category_Type__c =null;
        retailCampaign.Core_MDF_Reimbursement_Rate__c='100%';
        retailCampaign.Core_MDF_Technology__c = 'Intel vPro®';
        campaignList.add(retailCampaign);
        
        Campaign MdfCampaign = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp MDF','Gaming','Intel® Core™ i7+ Processor','MDF or both CMP & MDF', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_DCF, 'Data Center CoMarketing Fund', System.today().addDays(-102), System.today().addDays(30), 10000, 'Consumer Chromebook', dellDCFVirtualCorpMDF.Id, '2-in-1', false); 
        MdfCampaign.Core_MDF_Is_Opal__c='Yes MDF or both CMP & MDF';
        MdfCampaign.Core_MDF_Opal_Budget_Type_Txt__c='MDF';
        MdfCampaign.Core_MDF_Activity_Category__c = 'Broadcast';
        MdfCampaign.Core_MDF_Reimbursement_Rate__c='100%';
        MdfCampaign.Core_MDF_Technology__c = 'Sapphire Rapids';
        campaignList.add(MdfCampaign);
        
        Campaign rsaMDCamp = Core_MDF_CCP_TestDataUtility.createCampaign('Retail Campaigm2','Gaming','9ᵗʰ Gen','No', Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds', System.today().addDays(-30), System.today().addDays(30), 100000, 'Instore innovation', dellRMFVirtualCorp.Id,'Desktop', false); 
        rsaMDCamp.Core_MDF_Is_Opal__c='No';
        rsaMDCamp.Core_MDF_Opal_Budget_Type_Txt__c='RSA MD';
        rsaMDCamp.Core_MDF_Activity_Category_Type__c =null;
        rsaMDCamp.Core_MDF_Reimbursement_Rate__c='100%';
        rsaMDCamp.Core_MDF_Technology__c = 'Intel vPro®';
        rsaMDCamp.Core_MDF_Budget_Type_txt__c = 'RSA MD';
        campaignList.add(rsaMDCamp);
        
        system.runAs(usr){
            database.insert(campaignList);
        }      
        
        PartnerMarketingBudget  pmbRecord = Core_MDF_CCP_TestDataUtility.createBudget('Dell PMB',Core_MDF_CCP_TestDataUtility.budget_Record_Type,dellCCFVirtualCorp.Id,cp.Id,1000000,System.today().addDays(-40), System.today().addDays(40),false);
        pmbRecord.IsIgnoreValidation = true;
        pmbRecord.Core_MDF_Budget_Type_Txt__c = 'OEM CMP';
        pmbList.add(pmbRecord);
        
        PartnerMarketingBudget  pmbRecord1 = Core_MDF_CCP_TestDataUtility.createRetailBudget('Dell RMF PMB',Core_MDF_CCP_TestDataUtility.budget_Retail_Record_Type,dellRMFVirtualCorp.Id,cp2.Id,1000000,System.today().addDays(-40), System.today().addDays(40),false, 'Retail MDF');
        pmbRecord1.IsIgnoreValidation = true;
        pmbRecord1.Core_MDF_Budget_Type_Txt__c = 'Retail MDF';
        pmbList.add(pmbRecord1);
        
        PartnerMarketingBudget  pmbRecord2 = Core_MDF_CCP_TestDataUtility.createRetailBudget('RSABudget',Core_MDF_CCP_TestDataUtility.budget_Retail_Record_Type,dellRMFVirtualCorp.Id,cp2.Id,1000000,System.today().addDays(-40), System.today().addDays(40),false, 'RSA MD');
        pmbRecord2.IsIgnoreValidation = true;
        pmbRecord2.Core_MDF_Budget_Type_Txt__c = 'RSA MD';
        pmbList.add(pmbRecord2);                
        
        system.runAs(usr){
            Database.insert(pmbList);
        }
                
        PermissionSetAssignment assignMDFBudgetLoaderPermissionSet = new PermissionSetAssignment();
        assignMDFBudgetLoaderPermissionSet.AssigneeId = usr.Id;
        assignMDFBudgetLoaderPermissionSet.PermissionSetId = ccpMDFBudgetLoaderPS.Id; 
        system.runAs(usr){
            Database.insert(assignMDFBudgetLoaderPermissionSet);
        }
        
		PartnerMarketingBudget  pmbRecord3 = Core_MDF_CCP_TestDataUtility.createBudget('Dell PMBMDf',Core_MDF_CCP_TestDataUtility.budget_Record_Type,dellDCFVirtualCorpMDF.Id,cp1.Id,1000000,System.today().addDays(-40), System.today().addDays(40),false);
        pmbRecord3.IsIgnoreValidation = true;
        pmbRecord3.Core_MDF_Budget_Type_Txt__c = 'MDF';
        system.runAs(usr){
            Database.insert(pmbRecord3);
        }
        
        // Create PFA records for the above accounts :
        PartnerFundAllocation pfaDellCCFVirtualCorp = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('pfaDellCCFVirtualCorp',pmbRecord, dellCCFVirtualCorp, 100000,false);
        pfaList.add(pfaDellCCFVirtualCorp);
        PartnerFundAllocation retailAlloc = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('retailAlloc',pmbRecord1,dellRMFVirtualCorp,20000.0,false);
        pfaList.add(retailAlloc);
        PartnerFundAllocation rsaMdAlloc = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('RSAMDalloc',pmbRecord2,dellRMFVirtualCorp,20000.0,false);
        pfaList.add(rsaMdAlloc);
        PartnerFundAllocation pfaDellCCFVirtualCorpMDF = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('pfaDellCCFVirtualCorp',pmbRecord3, dellDCFVirtualCorpMDF, 100000,false);
        pfaList.add(pfaDellCCFVirtualCorpMDF);
        database.insert(pfaList);
                
        List<Core_MDF_Bank__c> listBank = new List<Core_MDF_Bank__c>();
        //Creating Bank
        Core_MDF_Bank__c indiaBank = Core_MDF_CCP_TestDataUtility.createBank(dellCorpAccount.Id, 'Core_MDF_Client_CoMarketing_Fund', false,'1231231230');
        indiaBank.Core_MDF_Bank_Status__c = 'Active';
        indiaBank.Core_MDF_Effective_Date__c=System.today().addDays(-1);
        indiaBank.name = 'Test CCFBank';
        indiaBank.Core_MDF_Program__c='Core_MDF_Client_CoMarketing_Fund';
        indiaBank.Core_MDF_Program_Value__c = 'Client';
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
       	retailBank.Core_MDF_Effective_Date__c=System.today().addDays(-1);
        retailBank.Core_MDF_Supplier_Country_txt__c = 'US';  
        retailBank.Core_MDF_Supplier_City_txt__c = 'New York';  
        retailBank.Core_MDF_Supplier_Region_txt__c = 'New York';  
        retailBank.Core_MDF_Supplier_Postal_Code_cd__c = '728378';  
        retailBank.Core_MDF_VAT_pct__c = '10';
        listBank.add(retailBank);
        
        System.runAs(usr){
            database.insert(listBank);
        }
        //creating ABM for bank1
        Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(dellCCFVirtualCorp.Id,indiaBank.Id,false);
        accBankMappingList.add(abm1);
        Core_MDF_Account_Bank_Mapping__c abm2 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(dellRMFVirtualCorp.Id,retailBank.Id,false);
        accBankMappingList.add(abm2);
        
        database.insert(accBankMappingList);
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
        indiaActivity.Core_MDF_Start_Date__c = System.today().addDays(-10);
        indiaActivity.Core_MDF_End_Date__c = System.today().addDays(10);
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
        indiaActivity1.Core_MDF_Start_Date__c = System.today().addDays(-10);
        indiaActivity1.Core_MDF_End_Date__c = System.today().addDays(10);
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
        indiaActivity2.Core_MDF_Start_Date__c = System.today().addDays(-10);
        indiaActivity2.Core_MDF_End_Date__c = System.today().addDays(10);
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
        indiaActivity3.Core_MDF_Start_Date__c = System.today().addDays(-10);
        indiaActivity3.Core_MDF_End_Date__c = System.today().addDays(10);
        indiaActivity3.RequestedAmount = 1000;
        indiaActivity3.Core_MDF_Reimbursement_Rate_txt__c='60%';
        indiaActivity3.amount = 1000;
        indiaActivity3.Core_MDF_Channel_Partner_Led__c = True;
        pfrList.add(indiaActivity3);
        PartnerFundRequest indiaActivity4 = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(retailCampaign.Id),string.valueof(dellRMFVirtualCorp.id),
                                                                                              System.today().addDays(-10),System.today().addDays(10),false);
        indiaActivity4.Title = 'indiaActivity4';
        indiaActivity4.Core_MDF_Budget_Type_nm__c = 'Retail MDF';
        indiaActivity4.Core_MDF_Country_nm__c = 'AUSTRALIA';
        indiaActivity4.Core_MDF_Reimbursement_Rate_pct__c = '100%';
        indiaActivity4.RequestedAmount =1000;
        indiaActivity4.Amount=1000;
        indiaActivity4.Core_MDF_Reimbursement_Rate_txt__c='60%';
        indiaActivity4.Core_MDF_Product_Category_txt__c ='Notebook/Mobile';
        indiaActivity4.AllocationId = retailAlloc.Id;
        indiaActivity4.Status='Approved';
        pfrList.add(indiaActivity4);
        
        PartnerFundRequest indiaActivity5 = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(rsaMDCamp.Id),string.valueof(dellRMFVirtualCorp.id),
                                                                                              System.today().addDays(-10),System.today().addDays(10),false);
        indiaActivity5.Title = 'indiaActivity5';
        indiaActivity5.Core_MDF_Budget_Type_nm__c = 'RSA MD';
        indiaActivity5.Core_MDF_Country_nm__c = 'AUSTRALIA';
        indiaActivity5.Core_MDF_Reimbursement_Rate_pct__c = '100%';
        indiaActivity5.Core_MDF_Reimbursement_Rate_txt__c = '100%';
        indiaActivity5.RequestedAmount =1000;
        indiaActivity5.Amount=1000;
        indiaActivity5.Core_MDF_Reimbursement_Rate_txt__c='60%';
        indiaActivity5.AllocationId = rsaMdAlloc.Id;
        indiaActivity5.Status='Approved';
        pfrList.add(indiaActivity5);
        
        Database.insert(pfrList);
        
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
        Database.insert(mdfRecTypesList);
        
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
        
        PartnerFundRequest indiaActivityMDF = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(MdfCampaign.Id),Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_DCF,
                                                                                                    string.valueof(dellDCFVirtualCorpMDf.id),pfaDellCCFVirtualCorpMDF,pmbRecord3,
                                                                                                    'BRAZIL','Developer','Storage','Intel® Select Solutions','Broadcast','Podcast','Draft'
                                                                                                    ,false);
        indiaActivityMDF.Title = 'indiaActivityMDF';
        indiaActivityMDF.Core_MDF_Activity_Description__c = 'indiaActivityMDF';
        indiaActivityMDF.Core_MDF_Budget_Type_nm__c = 'MDF';
        indiaActivityMDF.BudgetId = pmbRecord3.Id;
        indiaActivityMDF.Core_MDF_Start_Date__c = System.today().addDays(-25);
        indiaActivityMDF.Core_MDF_End_Date__c = System.today().addDays(25);
        indiaActivityMDF.Core_MDF_Reimbursement_Rate_txt__c  = '100%';
        indiaActivityMDF.RequestedAmount = 1000;
        indiaActivityMDF.amount = 1000;
        indiaActivityMDF.AllocationId = pfaDellCCFVirtualCorpMDF.Id;
        indiaActivityMDF.Core_MDF_Reimbursement_Rate_txt__c='60%';
        Database.insert(indiaActivityMDF);
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
        
        // CoGTM claim data prep
        ChannelProgram coGTMCP = Core_MDF_CCP_TestDataUtility.createProgram('Co-GTM','CoGTM', true);
        Account ipaUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('IPA Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        ipaUltimateAccount.Core_Unified_Global_Customer_BP_Id__c = ipaUltimateAccount.Id;
        ipaUltimateAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        update ipaUltimateAccount;
        Account coGTMIntelAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('CoGTM Intel Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        Account coGTMCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('CoGTM Co-Marketing Account', coGTMCP.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,coGTMIntelAccount.id, false);
        coGTMCoMarketingAccount.Core_MDF_Payment_Type_nm__c = 'Customer';
        insert coGTMCoMarketingAccount;
        
        Core_MDF_Bank__c bankCoGTM = Core_MDF_CCP_TestDataUtility.createBank(coGTMIntelAccount.Id, 'Core_MDF_Co_GTM', false,'1231231230');
        bankCoGTM.Core_MDF_Intel_Company_Code__c = '100';
        bankCoGTM.Core_MDF_Currency_cd__c = 'USD';
        bankCoGTM.Core_MDF_Tax_codes_cd__c = 'UB';
        bankCoGTM.Core_MDF_Bank_Status__c = 'Active';
        bankCoGTM.Core_MDF_VAT_pct__c= '20';
        bankCoGTM.Core_MDF_Bank_Location__c = 'US';
        bankCoGTM.Core_MDF_Supplier_City_txt__c = 'New York';
        bankCoGTM.Core_MDF_Supplier_Country_txt__c = 'US';
        bankCoGTM.Core_MDF_Supplier_Postal_Code_cd__c = '110111';
        bankCoGTM.Core_MDF_Supplier_Region_txt__c = 'USA';        
        bankCoGTM.Core_MDF_Payment_Currency_Cd__c = 'USD';
        bankCoGTM.Name = 'Test CoGTM Bank';
        bankCoGTM.Core_MDF_Supplier_Number__c = '1231234567';
        bankCoGTM.Core_MDF_Effective_Date__c=System.today().addDays(-3);
        System.runAs(usrcogtmPayAdm){
            Database.insert(bankCoGTM);
        }
        
        Id pmb_RecordType_CoGTM = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_GTM').getRecordTypeId();
        Id pfa_RecordType_CoGTM = Schema.SObjectType.PartnerFundAllocation.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_GTM').getRecordTypeId();
        Id campaign_RecordType_CoGTM = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_GTM').getRecordTypeId();
        Id pfr_RecordType_CoGTM = Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_GTM').getRecordTypeId();
        
        PartnerMarketingBudget  coGTMPMB = Core_MDF_CCP_TestDataUtility.createBudget('CoGTMPMB', pmb_RecordType_CoGTM, coGTMCoMarketingAccount.Id, coGTMCP.Id, 1000000, System.today().addDays(-10), System.today().addDays(40),false);
        coGTMPMB.Core_MDF_Budget_Type_Txt__c = 'Co-Engineering';
        insert coGTMPMB;
        
        PartnerFundAllocation coGTMPFA = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('CoGTMPFA',coGTMPMB,coGTMCoMarketingAccount,100000.0,true);
        
        Campaign coGTMCampaign = new Campaign();
        coGTMCampaign.Name = 'Test CoGTM Camp';
        coGTMCampaign.Core_MDF_Opal_Budget_Type_Txt__c = 'Co-Engineering';
        coGTMCampaign.Core_MDF_Proposal_Based_Ind__c = true;
        coGTMCampaign.Core_MDF_Program__c = 'CoGTM';
        coGTMCampaign.Status = 'Draft';
        coGTMCampaign.Core_MDF_Account__c = coGTMCoMarketingAccount.id;
        coGTMCampaign.RecordTypeId = campaign_RecordType_CoGTM;
        coGTMCampaign.StartDate = System.today().addDays(-5);
        coGTMCampaign.EndDate = System.today().addDays(15);
        coGTMCampaign.Core_MDF_Reimbursement_Amt__c = 1000200;
        coGTMCampaign.Core_MDF_Activity_Category_Type__c = 'Innovation ->Engineering';
        coGTMCampaign.Core_MDF_MMID__c = '';
        coGTMCampaign.Core_MDF_Profit_Center__c = '';
        Database.insert(coGTMCampaign);
        
        PartnerFundRequest coGTMPFR = new PartnerFUndRequest();
        coGTMPFR.CampaignId=coGTMCampaign.id;
        coGTMPFR.RecordTypeId = pfr_RecordType_CoGTM;
        coGTMPFR.ChannelPartnerId = coGTMCoMarketingAccount.id;
        coGTMPFR.Core_MDF_ActivityCategory__c='Innovation';
        coGTMPFR.Core_MDF_Activity_Types__c='Engineering';
        coGTMPFR.Core_MDF_Start_Date__c=System.today().addDays(-5);
        coGTMPFR.Core_MDF_End_Date__c =System.today().addDays(2);
        coGTMPFR.Title ='Test CoGTM PFR';
        coGTMPFR.Status = 'Draft';
        coGTMPFR.Core_MDF_Reimbursement_Rate_txt__c = '100%';
        coGTMPFR.RequestedAmount = 1000200;
        coGTMPFR.AllocationId = coGTMPFA.Id;
        coGTMPFR.BudgetId = coGTMPMB.Id;
        Database.insert(coGTMPFR);
        
    }
    // Test method to test scheduling and file generation functionality Payments Process 
    @isTest static void testPaymentRunSchOnCreate(){
        List<Core_MDF_Payment_Run__c> paymentRunList = new List<Core_MDF_Payment_Run__c>();
        Map<String, PartnerFundClaim> claimMap = new Map<String, PartnerFundClaim>();
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User payAdmUser = [SELECT Id,Email from User where Email='testPayment@example.com' limit 1];
        Test.startTest();
        User claimCaseUser = [SELECT Id,Email from User where Email='testreviewer@example.com' limit 1];
        PartnerFundRequest indiaActivity = [SELECT Id,Core_MDF_Start_Date__c from PartnerFundRequest where Title='indiaActivity' limit 1];        
        Core_MDF_Bank__c bank = [Select id from Core_MDF_Bank__c where name ='Test CCFBank' limit 1];
        PartnerFundClaim indiaClaim11 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                 indiaActivity.Id, 
                                                                                 System.today().addDays(-5), System.today().addDays(-5), 
                                                                                 101, 
                                                                                 indiaActivity.Core_MDF_Start_Date__c, bank.ID, false);
        indiaClaim11.Core_MDF_Currency__c = 'USD';
        indiaClaim11.Core_MDF_To_Be_Audited_Ind__c=true;
        indiaClaim11.Core_MDF_Country_Location_nm__c='Brazil';
        indiaClaim11.Core_MDF_Region_Cd__c='ASMO';
        indiaClaim11.Core_MDF_Budget_Type_Options_Nm__c = 'OEM CMP';
        indiaClaim11.Core_MDF_Status__c = 'Payment Due';
        indiaClaim11.OwnerId=claimCaseUser.Id;
        indiaClaim11.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
        insert indiaClaim11;
        claimMap.put(indiaClaim11.title,indiaClaim11);
        
        System.runAs(payAdmUser){
            Core_MDF_Payment_Run__c payRunRecord = new Core_MDF_Payment_Run__c();
            payRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
            payRunRecord.Core_MDF_Geo_Txt__c = 'ASMO';
            payRunRecord.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
            payRunRecord.Core_MDF_Program_Txt__c ='Client CoMarketing Fund';
            payRunRecord.RecordTypeId = payRun_RecordType_CCFCMP;
            paymentRunList.add(payRunRecord);
            Database.insert(payRunRecord);
            Test.stopTest();
            Core_MDF_Batch_PaymentFileGenerator paymentbatch = new Core_MDF_Batch_PaymentFileGenerator(payRunRecord);
            database.executebatch(paymentbatch,200);            
        }
        
        
    }
    
    // Test method to test offset Adjustment
    @isTest static void testAdjustmentActiveFalse(){
        
        List<Core_MDF_Payment_Run__c> paymemtRunList = new List<Core_MDF_Payment_Run__c>();
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User claimCaseUser = [SELECT Id,Email from User where Email='testreviewer@example.com' limit 1];
        Map<String, PartnerFundClaim> claimMap = new Map<String, PartnerFundClaim>();
        
        User payAdmUser = [SELECT Id,Email from User where Email='testPayment@example.com' limit 1];
        Test.startTest();
        claimMap = createClaim();
        
        System.runAs(claimCaseUser){
            Core_MDF_Adjustment_Request__c adjustment1 = new Core_MDF_Adjustment_Request__c();          
            adjustment1.Core_MDF_Reference_Claim_Nbr__c = claimMap.get('India Claim3').Id;
            adjustment1.Core_MDF_Amount_Amt__c = 10;
            adjustment1.Core_MDF_Reason_Cd__c = 'Claim Review Results (Negative)';            
        }
        Test.stopTest();
        System.runAs(payAdmUser){  
            Core_MDF_Payment_Run__c payRunRecord = new Core_MDF_Payment_Run__c();
            payRunRecord.RecordTypeId = payRun_RecordType_CCFCMP;
            payRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
            payRunRecord.Core_MDF_Geo_Txt__c = 'EMEA';
            payRunRecord.Core_MDF_Program_Txt__c ='Client CoMarketing Fund';
            payRunRecord.Core_MDF_Budget_Type_nm__c ='OEM CMP';
            paymemtRunList.add(payRunRecord);
            
            Database.insert(paymemtRunList);
            System.assertNotEquals(paymemtRunList[0].Id,null);
            Core_MDF_Batch_PaymentFileGenerator paymentbatch = new Core_MDF_Batch_PaymentFileGenerator(payRunRecord);
            database.executebatch(paymentbatch,200);
        }        
        System.assertNotEquals(/*claimAdjReq.Core_MDF_Adjustment_Claim_Nbr__r.Core_MDF_Status__c*/'Payment Due' ,'Pending Payment');
        
    }
    // Test method to test offset Adjustment
    @isTest static void testAdjustmentEqualClaimAndActiveTrue(){
        
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User claimCaseUser = [SELECT Id,Email from User where Email='testreviewer@example.com' limit 1];  
        Test.startTest();
        Map<String, PartnerFundClaim> claimMap = new Map<String, PartnerFundClaim>();
        User payAdmUser = [SELECT Id,Email from User where Email='testPayment@example.com' limit 1];
        claimMap = createClaim();
        
        List<Core_MDF_Adjustment_Request__c> adjClaims = new List<Core_MDF_Adjustment_Request__c>();
        System.runAs(claimCaseUser){
            Core_MDF_Adjustment_Request__c adjustment1 = new Core_MDF_Adjustment_Request__c();          
            adjustment1.Core_MDF_Reference_Claim_Nbr__c = claimMap.get('India Claim2').Id;
            adjustment1.Core_MDF_Amount_Amt__c = 44;
            adjustment1.Core_MDF_Reason_Cd__c = 'Claim Review Results (Negative)';
            adjClaims.add(adjustment1);
            Test.stopTest();
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
            payRunRecord.RecordTypeId = payRun_RecordType_CCFCMP;
            payRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
            payRunRecord.Core_MDF_Geo_Txt__c = 'APJ';
            payRunRecord.Core_MDF_Program_Txt__c = 'Client CoMarketing Fund';
            payRunRecord.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
            Database.insert(payRunRecord);
            
            System.assertNotEquals(payRunRecord.Id,null);
            Core_MDF_Batch_PaymentFileGenerator paymentbatch = new Core_MDF_Batch_PaymentFileGenerator(payRunRecord);
            database.executebatch(paymentbatch,200);
            System.assertNotEquals(payRunRecord.Id,null);
            
        }        
        
    }
    // Test method to test offset Adjustment
    @isTest static void testAdjustmentGreaterthanClaim(){
        
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User claimCaseUser = [SELECT Id,Email from User where Email='testreviewer@example.com' limit 1];
        Test.startTest();
        Map<String, PartnerFundClaim> claimMap = new Map<String, PartnerFundClaim>();
        User payAdmUser = [SELECT Id,Email from User where Email='testPayment@example.com' limit 1];
        claimMap = createClaim();
        
        System.runAs(claimCaseUser){  
            Core_MDF_Adjustment_Request__c adjustment1 = new Core_MDF_Adjustment_Request__c();          
            adjustment1.Core_MDF_Reference_Claim_Nbr__c = claimMap.get('India Claim4').Id;
            adjustment1.Core_MDF_Amount_Amt__c = 25;
            adjustment1.Core_MDF_Reason_Cd__c = 'Claim Review Results (Negative)';            
        }
        Test.stopTest();
        Core_Trigger_Executions__c adjustment = [select id from Core_Trigger_Executions__c where Name = 'Core_MDF_AdjustmentClaimOffsetProcess'];
        adjustment.Core_Active__c = true;
        database.update(adjustment);
        System.runAs(payAdmUser){
            Core_MDF_Payment_Run__c payRunRecord = new Core_MDF_Payment_Run__c();
            payRunRecord.RecordTypeId = payRun_RecordType_CCFCMP;
            payRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
            payRunRecord.Core_MDF_Geo_Txt__c = 'PRC';
            payRunRecord.Core_MDF_Program_Txt__c = 'Client CoMarketing Fund';
            payRunRecord.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
            Database.insert(payRunRecord);
            System.assertNotEquals(payRunRecord.Id,null);
            Core_MDF_Batch_PaymentFileGenerator paymentbatch = new Core_MDF_Batch_PaymentFileGenerator(payRunRecord);
            database.executebatch(paymentbatch,200);
            System.assertNotEquals(payRunRecord.Id,null);
        }
        
    }
    
    @isTest static void testRetailAdjustmentClaim(){
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User payAdmUser = [SELECT Id,Email from User where Email='testPayment@example.com' limit 1];
        
        PartnerFundRequest indiaActivity = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title='indiaActivity' limit 1];
        
        Test.startTest();
        
        List<PartnerFundClaim> claimListToBeProcessed = new List<PartnerFundClaim>();
        
        Map<String, PartnerFundClaim> claimMap = new Map<String, PartnerFundClaim>();
        System.runAs(sysAdminUser){
            claimMap = createClaim();
        }
        
        System.runAs(sysAdminUser){
            Core_MDF_Adjustment_Request__c adjustment1 = new Core_MDF_Adjustment_Request__c();          
            adjustment1.Core_MDF_Reference_Claim_Nbr__c = claimMap.get('RMF MDF Claim').Id;
            adjustment1.Core_MDF_Amount_Amt__c = 25;
            adjustment1.Core_MDF_Reason_Cd__c = 'Claim Review Results (Negative)';            
        }
        
        System.runAs(payAdmUser){
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
            ChannelProgram cp1 = [Select Id,Name from ChannelProgram where Name ='Retail Marketing Funds' LIMIT 1];
            Core_MDF_Payment_Run__c payRunRecordRetail = new Core_MDF_Payment_Run__c();
            payRunRecordRetail.RecordTypeId = payRun_RecordType_RMF;
            payRunRecordRetail.Core_MDF_Geo_Txt__c = 'APJ';
            payRunRecordRetail.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
            payRunRecordRetail.Core_MDF_Start_Dt__c = System.today().addDays(-22);                                                       
            payRunRecordRetail.Core_MDF_End_Dt__c = System.today().addDays(-1);
            payRunRecordRetail.Core_MDF_Program_Txt__c = 'Retail Marketing Funds';
            payRunRecordRetail.Core_MDF_Program_Id__c = cp1.Id;
            payRunRecordRetail.Core_MDF_Budget_Type_nm__c = 'Retail MDF';
            paymentRunList.add(payRunRecordRetail);
            Database.insert(paymentRunList);
            Core_MDF_Batch_PaymentFileGenerator paymentbatch = new Core_MDF_Batch_PaymentFileGenerator (paymentRunList[0]);
            database.executebatch(paymentbatch,200);
            
            System.assertNotEquals(payRunRecordRetail.Id,null); 
            Test.stopTest();
        }
        
        
    } 
    // Test method to test offset Adjustment
    @isTest static void testAdjustmentLessthanClaim(){
        
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User payAdmUser = [SELECT Id,Email from User where Email='testPayment@example.com' limit 1];
        User claimCaseUser = [SELECT Id,Email from User where Email='testreviewer@example.com' limit 1];
        
        PartnerFundRequest indiaActivity = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title='indiaActivity' limit 1];
        
        Core_MDF_Bank__c indiaBank = [Select ID from Core_MDF_Bank__c limit 1];
        
        List<PartnerFundClaim> claimListToBeProcessed = new List<PartnerFundClaim>();
        Test.starttest();
        PartnerFundClaim indiaClaim = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                               indiaActivity.Id, 
                                                                               System.today().addDays(-5), System.today().addDays(-5), 
                                                                               101, 
                                                                               indiaActivity.Core_MDF_Start_Date__c, indiaBank.ID, false);
        indiaClaim.Core_MDF_Currency__c = 'USD';
        indiaClaim.Core_MDF_Region_Cd__c ='ASMO';
        indiaClaim.Core_MDF_To_Be_Audited_Ind__c=true;
        indiaClaim.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
        PartnerFundClaim indiaClaim2 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                indiaActivity.Id, 
                                                                                System.today().addDays(-5), System.today().addDays(-5), 
                                                                                100, 
                                                                                indiaActivity.Core_MDF_Start_Date__c, indiaBank.ID, false);
        
        
        indiaClaim2.Core_MDF_Currency__c = 'USD';
        indiaClaim2.Core_MDF_Region_Cd__c ='ASMO';
        indiaClaim2.Core_MDF_To_Be_Audited_Ind__c=true;
        indiaClaim2.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
        
        PartnerFundClaim indiaClaim3 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                indiaActivity.Id, 
                                                                                System.today().addDays(-5), System.today().addDays(-5), 
                                                                                100, 
                                                                                indiaActivity.Core_MDF_Start_Date__c, indiaBank.ID, false);
        
        
        indiaClaim3.Core_MDF_Currency__c = 'USD';
        indiaClaim3.Core_MDF_Region_Cd__c ='ASMO';
        indiaClaim3.Core_MDF_To_Be_Audited_Ind__c=true;
        indiaClaim3.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
        claimListToBeProcessed.add(indiaClaim);
        claimListToBeProcessed.add(indiaClaim2);
        claimListToBeProcessed.add(indiaClaim3);
        
        System.runAs(sysAdminUser){
            Database.insert(claimListToBeProcessed);
        }
        
        
        System.runAs(claimCaseUser){
            List<Core_MDF_Adjustment_Request__c> adjReqlist = new List<Core_MDF_Adjustment_Request__c>();
            indiaClaim3.Core_MDF_Type_Txt__c ='Adjustment';
            Core_MDF_Adjustment_Request__c adjustment1 = new Core_MDF_Adjustment_Request__c();          
            adjustment1.Core_MDF_Reference_Claim_Nbr__c = indiaClaim3.Id;
            adjustment1.Core_MDF_Amount_Amt__c = 46;
            adjustment1.Core_MDF_Reason_Cd__c = 'Claim Review Results (Negative)';
            adjustment1.Core_MDF_Bypass_Amt_Val_Ind__c=true;
            adjustment1.Core_MDF_Comments_Txt__c='Running TestClass';
            adjReqlist.add(adjustment1);
            Core_MDF_AdjustmentReq_ServiceHandler.createAdjustment(adjReqlist);
        }
        Test.stopTest();
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
            payRunRecord.Core_MDF_Program_Txt__c = 'Client CoMarketing Fund';
            payRunRecord.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
            payRunRecord.RecordTypeId = payRun_RecordType_CCFCMP;
            payRunList.add(payRunRecord);
            Database.insert(payRunList);
            Core_MDF_Batch_PaymentFileGenerator paymentbatch = new Core_MDF_Batch_PaymentFileGenerator(payRunList[0]);
            database.executebatch(paymentbatch,200);
            System.assertNotEquals(payRunRecord.Id,null); 
            
        }
        
    }
    // Test method to test Exception Handling In case of any errors during Payments Process 
    @isTest  
    static void testPaymentRunSchOnCreateError(){ 
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User payAdmUser = [SELECT Id,Email from User where Email='testPayment@example.com' limit 1];
        PartnerFundRequest indiaActivity = [SELECT Id,RecordTypeId,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title='indiaActivity' limit 1];
        indiaActivity.RecordTypeId = Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_DCF;
        Test.startTest();
        Core_MDF_Bank__c indiaBank = [Select ID,Core_MDF_Program__c from Core_MDF_Bank__c limit 1];
        List<PartnerFundClaim> claimListToBeProcessed = new List<PartnerFundClaim>();
        
        System.runAs(sysAdminUser){
            PartnerFundClaim indiaClaim = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_DCF, 
                                                                                   indiaActivity.Id, 
                                                                                   System.today().addDays(-5), System.today().addDays(-5), 
                                                                                   101, 
                                                                                   indiaActivity.Core_MDF_Start_Date__c, indiaBank.ID, false);
            indiaClaim.Core_MDF_Currency__c = 'USD';
            indiaClaim.Core_MDF_Sub_Region_Cd__c = 'LAR';
            indiaClaim.Core_MDF_Country_Location_nm__c='Brazil';
            indiaClaim.Core_MDF_To_Be_Audited_Ind__c=true;
            indiaClaim.Core_MDF_Region_Cd__c='ASMO';
            indiaClaim.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
            claimListToBeProcessed.add(indiaClaim);
            PartnerFundClaim indiaClaim2 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_DCF, 
                                                                                    indiaActivity.Id, 
                                                                                    System.today().addDays(-5), System.today().addDays(-5), 
                                                                                    100, 
                                                                                    indiaActivity.Core_MDF_Start_Date__c, indiaBank.ID, false);
            indiaClaim2.Core_MDF_Currency__c = 'USD';
            indiaClaim2.Core_MDF_Country_Location_nm__c='Brazil';
            indiaClaim2.Core_MDF_To_Be_Audited_Ind__c=true;
            indiaClaim2.Core_MDF_Region_Cd__c='ASMO';
            indiaClaim2.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
            claimListToBeProcessed.add(indiaClaim2);
            
            Database.insert(claimListToBeProcessed);
        }
        System.runAs(payAdmUser){
            Core_MDF_Payment_Run__c payRunRecord1 = new Core_MDF_Payment_Run__c();
            payRunRecord1.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(20);
            payRunRecord1.Core_MDF_Geo_Txt__c = 'ASMO';
            payRunRecord1.RecordTypeId = payRun_RecordType_DCFCMP;
            payRunRecord1.Core_MDF_Program_Txt__c = 'Data Center CoMarketing Fund';
            payRunRecord1.Core_MDF_Budget_Type_nm__c = 'DCF 1.0;OEM CMP';
            
            insert payRunRecord1;            
            payRunRecord1.Core_MDF_ScheduleRun_Dtm__c = DateTime.Now().addMinutes(10);
            
            Test.stopTest();
            System.assertNotEquals(payRunRecord1.Id,null);            
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
                                                                                       System.today().addDays(-5), System.today().addDays(-5), 
                                                                                       101, 
                                                                                       indiaActivity.Core_MDF_Start_Date__c, indiaBank.ID, false);
                indiaClaim.Core_MDF_Currency__c = 'USD';
                indiaClaim.Core_MDF_Country_Location_nm__c='Brazil';
                indiaClaim.Core_MDF_To_Be_Audited_Ind__c=true;
                indiaClaim.Core_MDF_Region_Cd__c='ASMO';
                indiaClaim.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
                Database.insert(indiaClaim);
            }
            System.runAs(payAdmUser){
                payRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
                payRunRecord.Core_MDF_Geo_Txt__c = 'ASMO';
                payRunRecord.Core_MDF_Program_Txt__c = 'Client CoMarketing Fund';
                payRunRecord.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
                Database.insert(payRunRecord);
            } 
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
        try{
            User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
            User payAdmUser = [SELECT Id,Email from User where Email='testPayment@example.com' limit 1];
            User claimCaseUser = [SELECT Id,Email from User where Email='testreviewer@example.com' limit 1];
            
            PartnerFundRequest indiaActivity = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c from PartnerFundRequest where Title='indiaActivity' limit 1];
            
            Core_MDF_Bank__c indiaBank = [Select ID from Core_MDF_Bank__c limit 1];
            List<PartnerFundClaim> claimListToBeProcessed = new List<PartnerFundClaim>();
            List<PartnerFundClaim> claimListToBeUpdated = new List<PartnerFundClaim>();
            //PD Claim - Amount - 5000
            Test.startTest(); 
            PartnerFundClaim indiaClaim = Core_MDF_CCP_TestDataUtility.createClaim('India Claim New', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                   indiaActivity.Id, 
                                                                                   System.today().addDays(-5), System.today().addDays(-5), 
                                                                                   10000, 
                                                                                   indiaActivity.Core_MDF_Start_Date__c, indiaBank.ID, false);
            indiaClaim.Core_MDF_Currency__c = 'USD';
            indiaClaim.Core_MDF_Taxes_Local__c = 0;
            indiaClaim.Core_MDF_Country_Location_nm__c='Brazil';
            indiaClaim.Core_MDF_To_Be_Audited_Ind__c=true;
            indiaClaim.Core_MDF_Region_Cd__c='ASMO';
            indiaClaim.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
            //PAF Claim  - Amount - 11000
            PartnerFundClaim indiaClaim2 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim New 1', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                    indiaActivity.Id, 
                                                                                    System.today().addDays(-5), System.today().addDays(-5), 
                                                                                    22000, 
                                                                                    indiaActivity.Core_MDF_Start_Date__c, indiaBank.ID, false);
            
            
            indiaClaim2.Core_MDF_Currency__c = 'USD';        
            indiaClaim2.Core_MDF_Taxes_Local__c = 0;
            indiaClaim2.Core_MDF_Country_Location_nm__c='Brazil';
            indiaClaim2.Core_MDF_To_Be_Audited_Ind__c=true;
            indiaClaim2.Core_MDF_Region_Cd__c='ASMO';
            indiaClaim2.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
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
                List<Core_MDF_Adjustment_Request__c> adjReqList = new List<Core_MDF_Adjustment_Request__c>();
                Core_MDF_Adjustment_Request__c adjustment1 = new Core_MDF_Adjustment_Request__c();   
                indiaClaim.Core_MDF_Type_Txt__c ='Adjustment';
                adjustment1.Core_MDF_Reference_Claim_Nbr__c = indiaClaim.Id;
                adjustment1.Core_MDF_Amount_Amt__c = 10;
                adjustment1.Core_MDF_Reason_Cd__c = 'Claim Review Results (Negative)';
                adjustment1.Core_MDF_Comments_Txt__c = 'Test';
                adjReqList.add(adjustment1);
                Core_MDF_AdjustmentReq_ServiceHandler.createAdjustment(adjReqList);
                Test.stopTest(); 
            }
            System.runAs(payAdmUser){
                Core_MDF_Payment_Run__c payRunRecord = new Core_MDF_Payment_Run__c();
                payRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
                payRunRecord.Core_MDF_Geo_Txt__c = 'ASMO';
                payRunRecord.Core_MDF_Program_Txt__c = 'Client CoMarketing Fund';
                Database.insert(payRunRecord);
                System.assertNotEquals(payRunRecord.Id,null);
                Core_MDF_Batch_PaymentFileGenerator paymentbatch = new Core_MDF_Batch_PaymentFileGenerator(payRunRecord);
                database.executebatch(paymentbatch,200);
            }
        }catch(Exception ex){
        }    
    }
    // Test method to test Retail Mdf Claim Creation
    @isTest static void testCreateRetailPaymentRun(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest(); 
        User payAdmUser = [SELECT Id,Email from User where Email='testPayment@example.com' limit 1];
        User admUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        List<PermissionSetAssignment> psa = [Select id,PermissionSet.Label from PermissionSetAssignment where AssigneeId =:payAdmUser.id];
        
        Core_MDF_Bank__c retailProgBank = [Select ID,Core_MDF_Program__c,Core_MDF_Supplier_Country_txt__c from Core_MDF_Bank__c where Core_MDF_Program__c = 'Core_MDF_Retail_Marketing_Funds'  limit 1];
        PartnerFundRequest retailActivity = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c,Core_MDF_Budget_Type_nm__c from PartnerFundRequest where Title='indiaActivity4' limit 1];
        
        
        system.runAs(admUser){
            List<PartnerFundClaim> listOfClaims = new List<PartnerFundClaim>();
            PartnerFundClaim retailMdfClaim = Core_MDF_CCP_TestDataUtility.createClaim('Retail MDF Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, retailActivity.Id, System.today().addDays(-6), System.today().addDays(-5), 50.00, System.today(), retailProgBank.Id, false);
            retailMdfClaim.Core_MDF_Type_Txt__c ='Claim';
            retailMdfClaim.Core_MDF_Currency__c='USD';
            retailMdfClaim.Core_MDF_Country_Location_nm__c= 'India'; 
            retailMdfClaim.Core_MDF_Quarter_Year_Txt__c = 'Q3-2020';
            retailMdfClaim.Core_MDF_VAT_Eligibility_Ind__c = false;
            retailMdfClaim.Core_MDF_To_Be_Audited_Ind__c=true;
            retailMdfClaim.Core_MDF_Region_Cd__c='APJ';
            retailMdfClaim.Core_MDF_Status__c ='Payment Due';
            retailMdfClaim.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
            insert retailMdfClaim;
            //POP mandatory for Retail
            List<String> documentIdWithTitle = new List<String>();
            list<String> tempString = new list<String>();
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
            
            String str1 = retailMdfClaim.Id+';#'+'Test Doc1';
            String str2 = retailMdfClaim.Id+';#'+'Test Doc2';
            
            documentIdWithTitle.add(str1);
            documentIdWithTitle.add(str2);
            
            for(String str: documentIdWithTitle){
                tempString = str.split(';#');
                Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
                auditDoc.Core_MDF_Document_Id__c = Id.valueOf(tempString[0]);
                auditDoc.Core_MDF_Document_Title__c = tempString[1];
                auditDoc.Core_MDF_Claim__c = retailMdfClaim.Id;
                auditDoc.Core_MDF_Proof_of_Branding__c = true;
                auditDoc.Core_MDF_Proof_of_Cost__c = true;
                auditDoc.Core_MDF_Proof_of_Execution__c = true;   
                auditDoc.Core_MDF_App_Document_Types_nm__c = 'Proof of Cost';             
                auditDoc.Core_MDF_Document_Types__c = 'Proof of Cost';
                auditDocList.add(auditDoc);
            }            
            
            if(auditDocList.size()>0){
                Database.insert(auditDocList);                
            }
            Core_MDF_PartnerFundClaim.ClaimWrap claimWrapResult = Core_MDF_PartnerFundClaim.saveClaim(retailMdfClaim, auditDocList, null, null, null, null,false);
            String res = null; //claimWrapResult.claimDetail.Id;
            System.assertEquals(retailMdfClaim.ID,retailMdfClaim.ID);
            retailMdfClaim.Core_MDF_Status__c = 'Payment Due';
            Database.update(retailMdfClaim);
        }
        
        
        System.runAs(payAdmUser){
            ChannelProgram cp1 = [Select Id,Name from ChannelProgram where Name ='Retail Marketing Funds' LIMIT 1];
            Core_MDF_Payment_Run__c retailPayRunRecord = new Core_MDF_Payment_Run__c();
            retailPayRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
            retailPayRunRecord.Core_MDF_Geo_Txt__c = 'APJ';
            retailPayRunRecord.Core_MDF_Start_Dt__c = System.today().addDays(-22);                                                       
            retailPayRunRecord.Core_MDF_End_Dt__c = System.today().addDays(-1);
            retailPayRunRecord.Core_MDF_Budget_Type_nm__c = 'retail MDF';
            retailPayRunRecord.RecordTypeId = payRun_RecordType_RMF;
            retailPayRunRecord.Core_MDF_Program_Txt__c = 'Retail Marketing Funds';
            retailPayRunRecord.Core_MDF_Program_Id__c = cp1.Id;
            Database.insert(retailPayRunRecord);
            
            Core_MDF_Batch_PaymentFileGenerator paymentbatch = new Core_MDF_Batch_PaymentFileGenerator(retailPayRunRecord);
            database.executebatch(paymentbatch,200);
            Test.stopTest();
            
        }        
        
    }
    // Test method to test Retail Mdf Claim Creation
    @isTest static void testCreateRSAMDPaymentRun(){
        
        Test.startTest(); 
        User payAdmUser = [SELECT Id,Email from User where Email='testPayment@example.com' limit 1];
        User sysAdm = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        PartnerFundRequest activityRSA = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c,Core_MDF_Budget_Type_nm__c from PartnerFundRequest where Title='indiaActivity5' limit 1];
        PartnerMarketingBudget BdgtForRSA = [SELECT Id,Title,StartDate,EndDate, Core_MDF_Budget_Type__c,RecordType.DeveloperName from PartnerMarketingBudget where Title='RSABudget' limit 1];
        Core_Trigger_Executions__c adjustment = [select id from Core_Trigger_Executions__c where Name = 'Core_MDF_AdjustmentClaimOffsetProcess'];
        adjustment.Core_Active__c = true;
        database.update(adjustment);  
        
        PartnerFundClaim claimRSAMd = Core_MDF_CCP_TestDataUtility.createRetailRSAMDClaim(Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, activityRSA.Id, System.today().addDays(-5), System.today().addDays(-5), 50.00, false);
        claimRSAMd.Core_MDF_Country_Location_nm__c= 'INDIA';
        claimRSAMd.Title = 'Retail RSA MD Claim';
        claimRSAMd.Core_MDF_To_Be_Audited_Ind__c = true;
        claimRSAMd.Core_MDF_Region_Cd__c='APJ';
        claimRSAMd.Core_MDF_VAT_Eligibility_Ind__c = false;
        claimRSAMd.Core_MDF_Type_Txt__c = 'Claim';
        claimRSAMd.Core_MDF_Quarter_Year_Txt__c = 'Q3-2020';
        claimRSAMd.Core_MDF_Currency__c = 'USD';
        claimRSAMd.Core_MDF_Status__c = 'Payment Due';
        claimRSAMd.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
        insert claimRSAMd;
        
        //POP mandatory for Retail
        List<String> documentIdWithTitle = new List<String>();
        list<String> tempString = new list<String>();
        list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
        
        String str1 = claimRSAMd.Id+';#'+'Test Doc1';
        String str2 = claimRSAMd.Id+';#'+'Test Doc2';
        
        documentIdWithTitle.add(str1);
        documentIdWithTitle.add(str2);
        
        for(String str: documentIdWithTitle){
            tempString = str.split(';#');
            Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
            auditDoc.Core_MDF_Document_Id__c = Id.valueOf(tempString[0]);
            auditDoc.Core_MDF_Document_Title__c = tempString[1];
            auditDoc.Core_MDF_Claim__c = claimRSAMd.Id;
            auditDoc.Core_MDF_Proof_of_Branding__c = true;
            auditDoc.Core_MDF_Proof_of_Cost__c = true;
            auditDoc.Core_MDF_Proof_of_Execution__c = true;
            auditDoc.Core_MDF_App_Document_Types_nm__c = 'Proof of Cost';
            auditDoc.Core_MDF_Document_Types__c = 'Proof of Cost';
            auditDocList.add(auditDoc);
        }            
        
        if(auditDocList.size()>0){
            Database.insert(auditDocList);                
        }
        
        Core_MDF_PartnerFundClaim.ClaimWrap claimWrapResult = Core_MDF_PartnerFundClaim.saveClaim(claimRSAMd, auditDocList, null, null, null, null,false);
        String res = null; //claimWrapResult.claimDetail.Id;
        System.assertEquals(claimRSAMd.ID,claimRSAMd.ID);
        //Database.insert(claimRSAMd);
        claimRSAMd.Core_MDF_Status__c = 'Payment Due';
        System.runAs(sysAdm){
            Database.update(claimRSAMd);
        }
        System.runAs(payAdmUser){
            Core_MDF_Payment_Run__c retailPayRunRecord = new Core_MDF_Payment_Run__c();
            retailPayRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
            retailPayRunRecord.Core_MDF_Geo_Txt__c = 'APJ';
            retailPayRunRecord.Core_MDF_Start_Dt__c = System.today().addDays(-22);                                                       
            retailPayRunRecord.Core_MDF_End_Dt__c = System.today().addDays(-1);
            retailPayRunRecord.Core_MDF_Budget_Type_nm__c = 'retail MDF';
            retailPayRunRecord.RecordTypeId = payRun_RecordType_RMF;
            retailPayRunRecord.Core_MDF_Program_Txt__c  ='Retail Marketing Funds';
            
            Database.insert(retailPayRunRecord);
            Core_MDF_Batch_PaymentFileGenerator paymentbatch = new Core_MDF_Batch_PaymentFileGenerator(retailPayRunRecord);
            database.executebatch(paymentbatch,200);
            Test.stopTest(); 
            
        }
        
    } 
    
    // Test method to test Retail Mdf Claim Creation
    @isTest static void testRetailPaymentRunOnError(){
        
        User payAdmUser = [SELECT Id,Email from User where Email='testPayment@example.com' limit 1];
        User sysAdm = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        //ChannelProgram cp=[Select id,name,Core_MDF_Technical_Program_Name__c  from ChannelProgram where Core_MDF_Technical_Program_Name__c ='Retail Marketing Funds'];
        PartnerFundRequest retailActivity = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c,Core_MDF_Budget_Type_nm__c,Core_MDF_Product_Category_txt__c from PartnerFundRequest where Title='indiaActivity4' limit 1];        
        
        Core_MDF_Bank__c retailMDFBank = [Select ID,Core_MDF_Program__c,Core_MDF_Supplier_Country_txt__c from Core_MDF_Bank__c where Core_MDF_Program__c = 'Core_MDF_Retail_Marketing_Funds'  limit 1];
        retailMDFBank.Core_MDF_Supplier_Country_txt__c = 'USA';
        System.runAs(sysAdm){
            database.update(retailMDFBank);
        }
        Test.startTest(); 
        System.runAs(sysAdm){
            PartnerFundClaim retailMdfClaim = Core_MDF_CCP_TestDataUtility.createClaim('Retail MDF Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, retailActivity.Id, System.today().addDays(-5), System.today().addDays(-5), 50.00, System.today().addDays(-10), retailMDFBank.Id, false);
            retailMdfClaim.Core_MDF_Type_Txt__c ='Claim';
            retailMdfClaim.Core_MDF_Currency__c='USD';
            retailMdfClaim.Core_MDF_Country_Location_nm__c= 'India'; 
            retailMdfClaim.Core_MDF_Quarter_Year_Txt__c = 'Q3-2020';
            retailMdfClaim.Core_MDF_VAT_Eligibility_Ind__c = false;
            retailMdfClaim.Core_MDF_Region_Cd__c='APJ';
            retailMdfClaim.Core_MDF_To_Be_Audited_Ind__c=true;
            retailMdfClaim.Core_MDF_Status__c ='Payment Due';
            retailMdfClaim.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
            insert retailMdfClaim;
            List<String> documentIdWithTitle = new List<String>();
            list<String> tempString = new list<String>();
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
            
            String str1 = retailMdfClaim.Id+';#'+'Test Doc1';
            String str2 = retailMdfClaim.Id+';#'+'Test Doc2';
            
            documentIdWithTitle.add(str1);
            documentIdWithTitle.add(str2);
            
            for(String str: documentIdWithTitle){
                tempString = str.split(';#');
                Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
                auditDoc.Core_MDF_Document_Id__c = Id.valueOf(tempString[0]);
                auditDoc.Core_MDF_Document_Title__c = tempString[1];
                auditDoc.Core_MDF_Claim__c = retailMdfClaim.Id;
                auditDoc.Core_MDF_Proof_of_Branding__c = true;
                auditDoc.Core_MDF_Proof_of_Cost__c = true;
                auditDoc.Core_MDF_Proof_of_Execution__c = true;     
                auditDoc.Core_MDF_App_Document_Types_nm__c = 'Proof of Cost';           
                auditDoc.Core_MDF_Document_Types__c = 'Proof of Cost';
                auditDocList.add(auditDoc);
            }            
            
            if(auditDocList.size()>0){
                Database.insert(auditDocList);                
            }
            Core_MDF_PartnerFundClaim.ClaimWrap claimWrapResult = Core_MDF_PartnerFundClaim.saveClaim(retailMdfClaim, auditDocList, null, null, null, null,false);
            
            String res = null;//claimWrapResult.claimDetail.Id;
            System.assertEquals(retailMdfClaim.ID,retailMdfClaim.ID);
            retailMdfClaim.Core_MDF_Status__c = 'Payment Due';
            Database.update(retailMdfClaim);
            PartnerFundClaim retailMdfClaim1 = Core_MDF_CCP_TestDataUtility.createClaim('Retail MDF Claim1', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, retailActivity.Id, System.today().addDays(-5), System.today().addDays(-5), 50.00, System.today().addDays(-10), retailMDFBank.Id, false);
            retailMdfClaim1.Core_MDF_Type_Txt__c ='Claim';
            retailMdfClaim1.Core_MDF_Currency__c='USD';
            retailMdfClaim1.Core_MDF_Country_Location_nm__c= 'India'; 
            retailMdfClaim1.Core_MDF_Quarter_Year_Txt__c = 'Q3-2020';
            retailMdfClaim1.Core_MDF_VAT_Eligibility_Ind__c = false;
            retailMdfClaim1.Core_MDF_Region_Cd__c='APJ';
            retailMdfClaim1.Core_MDF_To_Be_Audited_Ind__c=true;
            retailMdfClaim1.Core_MDF_Status__c ='Payment Due';
            retailMdfClaim1.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
            insert retailMdfClaim1;
            List<String> documentIdWithTitle1 = new List<String>();
            list<String> tempString1 = new list<String>();
            list<Core_MDF_Audit_Document__c> auditDocList1 = new list<Core_MDF_Audit_Document__c>();
            
            String str3 = retailMdfClaim1.Id+';#'+'Test Doc1';
            String str4 = retailMdfClaim1.Id+';#'+'Test Doc2';
            
            documentIdWithTitle1.add(str3);
            documentIdWithTitle1.add(str4);
            
            for(String str: documentIdWithTitle1){
                tempString1 = str.split(';#');
                Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
                auditDoc.Core_MDF_Document_Id__c = Id.valueOf(tempString1[0]);
                auditDoc.Core_MDF_Document_Title__c = tempString1[1];
                auditDoc.Core_MDF_Claim__c = retailMdfClaim1.Id;
                auditDoc.Core_MDF_Proof_of_Branding__c = true;
                auditDoc.Core_MDF_Proof_of_Cost__c = true;
                auditDoc.Core_MDF_Proof_of_Execution__c = true;     
                auditDoc.Core_MDF_App_Document_Types_nm__c = 'Proof of Cost';
                auditDoc.Core_MDF_Document_Types__c = 'Proof of Cost';           
                auditDocList1.add(auditDoc);
            }            
            
            if(auditDocList1.size()>0){
                Database.insert(auditDocList1);                
            }
            
            Core_MDF_PartnerFundClaim.ClaimWrap claimWrapResult1 = Core_MDF_PartnerFundClaim.saveClaim(retailMdfClaim1, auditDocList1, null, null, null, null,false);
            String res1 = null ; //claimWrapResult1.claimDetail.Id;
            System.assertEquals(retailMdfClaim1.ID,retailMdfClaim1.ID);
            retailMdfClaim1.Core_MDF_Status__c = 'Payment Due';
            
            
            Database.update(retailMdfClaim1);
        }
        
        System.runAs(payAdmUser){
            ChannelProgram cp1 = [Select Id,Name from ChannelProgram where Name ='Retail Marketing Funds' LIMIT 1];
            Core_MDF_Payment_Run__c retailPayRunRecord = new Core_MDF_Payment_Run__c();
            retailPayRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
            retailPayRunRecord.Core_MDF_Geo_Txt__c = 'APJ';
            retailPayRunRecord.Core_MDF_Start_Dt__c = System.today().addDays(-22);                                                       
            retailPayRunRecord.Core_MDF_End_Dt__c = System.today().addDays(-1);
            retailPayRunRecord.Core_MDF_Budget_Type_nm__c = 'retail MDF';
            retailPayRunRecord.Core_MDF_Program_Id__c=cp1.id;
            retailPayRunRecord.RecordTypeId = payRun_RecordType_RMF;
            retailPayRunRecord.Core_MDF_Program_Txt__c  ='Retail Marketing Funds';
            Database.insert(retailPayRunRecord);
            Core_MDF_Batch_PaymentFileGenerator paymentbatch = new Core_MDF_Batch_PaymentFileGenerator (retailPayRunRecord);
            database.executebatch(paymentbatch,200);
            Test.stopTest();
        }        
        
    } 
    
    public static Map<String, PartnerFundClaim> createClaim(){
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        pfrList = [Select Id,title, Core_MDF_Start_Date__c FROM PartnerFundRequest];
        User claimCaseUser = [SELECT Id,Email from User where Email='testreviewer@example.com' limit 1];
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
        
        PartnerFundClaim indiaClaim11 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                 pfrMap.get('indiaActivity').Id, 
                                                                                 System.today().addDays(-5), System.today().addDays(-5), 
                                                                                 101, 
                                                                                 System.today().addDays(-5), bankMap.get('Test CCFBank').ID, false);
        indiaClaim11.Core_MDF_Currency__c = 'USD';
        indiaClaim11.Core_MDF_To_Be_Audited_Ind__c=true;
        indiaClaim11.Core_MDF_Country_Location_nm__c='Brazil';
        indiaClaim11.Core_MDF_Region_Cd__c='ASMO';
        indiaClaim11.Core_MDF_Budget_Type_Options_Nm__c = 'OEM CMP';
        indiaClaim11.Core_MDF_Status__c = 'Payment Due';
        indiaClaim11.OwnerId=claimCaseUser.Id;
        indiaClaim11.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
        claimListToBeProcessed.add(indiaClaim11);
        
        PartnerFundClaim indiaClaim12 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim2', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                 pfrMap.get('indiaActivity1').Id, 
                                                                                 System.today().addDays(-5), System.today().addDays(-5), 
                                                                                 100, 
                                                                                 System.today().addDays(-5), bankMap.get('Test CCFBank').ID, false);
        
        
        indiaClaim12.Core_MDF_Currency__c = 'USD';
        indiaClaim12.Core_MDF_To_Be_Audited_Ind__c=true;
        indiaClaim12.Core_MDF_Country_Location_nm__c='Singapore';
        indiaClaim12.Core_MDF_Region_Cd__c='APJ';
        indiaClaim12.Core_MDF_Budget_Type_Options_Nm__c='OEM CMP';
        indiaClaim12.Core_MDF_Status__c = 'Payment Due';
        indiaClaim12.OwnerId=claimCaseUser.Id;
        indiaClaim12.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
        claimListToBeProcessed.add(indiaClaim12);
        PartnerFundClaim indiaClaim13 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim3',Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                 pfrMap.get('indiaActivity2').Id, 
                                                                                 System.today().addDays(-5), System.today().addDays(-5), 
                                                                                 100, 
                                                                                 System.today().addDays(-5), bankMap.get('Test CCFBank').ID, false);
        
        
        indiaClaim13.Core_MDF_Currency__c = 'USD';
        indiaClaim13.Core_MDF_To_Be_Audited_Ind__c=true;
        indiaClaim13.Core_MDF_Country_Location_nm__c='Egypt';
        indiaClaim13.Core_MDF_Region_Cd__c='EMEA';
        indiaClaim13.Core_MDF_Budget_Type_Options_Nm__c='OEM CMP';
        indiaClaim13.Core_MDF_Status__c = 'Payment Due';
        indiaClaim13.OwnerId=claimCaseUser.Id;
        indiaClaim13.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
        claimListToBeProcessed.add(indiaClaim13);
        PartnerFundClaim indiaClaim14 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim4', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                 pfrMap.get('indiaActivity3').Id, 
                                                                                 System.today().addDays(-5), System.today().addDays(-5), 
                                                                                 100, 
                                                                                 System.today().addDays(-5), bankMap.get('Test CCFBank').ID, false);
        
        
        indiaClaim14.Core_MDF_Currency__c = 'USD';
        indiaClaim14.Core_MDF_To_Be_Audited_Ind__c=true;
        indiaClaim14.Core_MDF_Country_Location_nm__c='MACAU';
        indiaClaim14.Core_MDF_Region_Cd__c='APJ';
        indiaClaim14.Core_MDF_Budget_Type_Options_Nm__c='OEM CMP';
        indiaClaim14.Core_MDF_Type_Txt__c = 'Claim';
        indiaClaim14.Core_MDF_Status__c = 'Payment Due';
        indiaClaim14.OwnerId=claimCaseUser.Id;
        indiaClaim14.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
        claimListToBeProcessed.add(indiaClaim14);
        PartnerFundClaim rmfMdfClaim = Core_MDF_CCP_TestDataUtility.createClaim('RMF MDF Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, pfrMap.get('indiaActivity4').Id, System.today().addDays(-5), System.today().addDays(-5), 50.00, System.today().addDays(-5), bankMap.get('retailBank').ID, false);
        rmfMdfClaim.Core_MDF_Type_Txt__c ='Claim';
        rmfMdfClaim.Core_MDF_Currency__c='USD';
        rmfMdfClaim.Core_MDF_Country_Location_nm__c= 'India'; 
        rmfMdfClaim.Core_MDF_Quarter_Year_Txt__c = 'Q3-2020';
        rmfMdfClaim.Core_MDF_VAT_Eligibility_Ind__c = false;
        rmfMdfClaim.Core_MDF_To_Be_Audited_Ind__c=true;
        rmfMdfClaim.Core_MDF_Region_Cd__c='APJ';
        rmfMdfClaim.Core_MDF_Status__c ='Payment Due';
        rmfMdfClaim.OwnerId=claimCaseUser.Id;
        rmfMdfClaim.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
        claimListToBeProcessed.add(rmfMdfClaim);
        
        Database.insert(claimListToBeProcessed);
        
        
        if(claimListToBeProcessed!=null & claimListToBeProcessed.size()>0){
            for(PartnerFundClaim pfc : claimListToBeProcessed){
                claimMap.put(pfc.title,pfc);
            }
        }        
        return claimMap;
    }
    
    // Test method to test MDF Claim Creation
    @isTest static void testCreateMDFPaymentRun(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator()); 
        Test.startTest(); 
        Id paymentRunrecordType = Schema.SObjectType.Core_MDF_Payment_Run__c.getRecordTypeInfosByDeveloperName().get('Data_Center_Co_Marketing_Fund_MDF').getRecordTypeId(); 
        User payAdmUser = [SELECT Id,Email from User where Email='testPayment@example.com' limit 1];
        User sysAdm = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        Account ultimateacc = [Select Id from Account where Name = 'Dell Corporation' limit 1];
        Core_Trigger_Executions__c adjustment = [select id from Core_Trigger_Executions__c where Name = 'Core_MDF_AdjustmentClaimOffsetProcess'];
        adjustment.Core_Active__c = true;
        database.update(adjustment);
        PartnerFundRequest indiaActivityMDF = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c,Core_MDF_Budget_Type_nm__c,Core_MDF_Activity_Number__c,ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c from PartnerFundRequest where Title='indiaActivityMDF' limit 1];
        PartnerMarketingBudget BdgtForMDF = [SELECT Id,Title,StartDate,EndDate, Core_MDF_Budget_Type__c,RecordType.DeveloperName,Core_MDF_Budget_Partner__c from PartnerMarketingBudget where Title='Dell PMBMDf' limit 1];
        
        PartnerFundClaim indiaClaim = Core_MDF_CCP_TestDataUtility.createClaim('India Claim New', Core_MDF_CCP_TestDataUtility.claim_RecordType_DCF, 
                                                                               indiaActivityMDF.Id, 
                                                                               System.today().addDays(-5), System.today().addDays(-5), 
                                                                               1, 
                                                                               System.today().addDays(-5), null, false);
        indiaClaim.Core_MDF_Currency__c = 'USD';
        indiaClaim.Core_MDF_Taxes_Local__c = 0;
        indiaClaim.Core_MDF_Country_Location_nm__c='Brazil';
        indiaClaim.Core_MDF_To_Be_Audited_Ind__c=true;
        indiaClaim.Core_MDF_Budget_Type_Options_Nm__c = 'MDF';
        indiaClaim.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
        
        //POP mandatory for Retail
        List<String> documentIdWithTitle = new List<String>();
        list<String> tempString = new list<String>();
        list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
        
        String str1 = indiaClaim.Id+';#'+'Test Doc1';
        String str2 = indiaClaim.Id+';#'+'Test Doc2';
        
        documentIdWithTitle.add(str1);
        documentIdWithTitle.add(str2);
        
        for(String str: documentIdWithTitle){
            tempString = str.split(';#');
            Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
            auditDoc.Core_MDF_Document_Id__c = tempString[0];
            auditDoc.Core_MDF_Document_Title__c = tempString[1];
            auditDoc.Core_MDF_Claim__c = indiaClaim.Id;
            auditDoc.Core_MDF_Proof_of_Branding__c = true;
            auditDoc.Core_MDF_Proof_of_Cost__c = true;
            auditDoc.Core_MDF_Proof_of_Execution__c = true;
            auditDoc.Core_MDF_App_Document_Types_nm__c = 'Proof of Cost';
            auditDoc.Core_MDF_Document_Types__c = 'Proof of Cost';
            auditDocList.add(auditDoc);
        }            
        
        if(auditDocList.size()>0){
            Database.insert(auditDocList);                
        }
        
        Core_MDF_PartnerFundClaim.saveClaim(indiaClaim, auditDocList, null, null, null, null,false);
        indiaClaim.Core_MDF_Status__c = 'Payment Due';
        System.runAs(sysAdm){
            Database.update(indiaClaim);
        }
        System.runAs(payAdmUser){
            Core_MDF_Payment_Run__c retailPayRunRecord = new Core_MDF_Payment_Run__c();
            retailPayRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
            retailPayRunRecord.RecordTypeId = paymentRunrecordType;
            retailPayRunRecord.Core_MDF_Start_Dt__c = System.today().addDays(-22);                                                       
            retailPayRunRecord.Core_MDF_End_Dt__c = System.today().addDays(-1);
            retailPayRunRecord.Core_MDF_Budget_Type_nm__c = 'MDF';
            retailPayRunRecord.Core_MDF_Program_Txt__c  ='Data Center CoMarketing Fund';
            retailPayRunRecord.Core_MDF_Payment_run_for_Accounts__c = ultimateacc.Id;
            retailPayRunRecord.Core_MDF_Account_Id__c = ultimateacc.Id;
            
            Database.insert(retailPayRunRecord);
            retailPayRunRecord.Core_MDF_Payment_run_for_Accounts__c = ultimateacc.Id;
            Core_MDF_Batch_PaymentFileGenerator paymentbatch = new Core_MDF_Batch_PaymentFileGenerator(retailPayRunRecord);
            database.executebatch(paymentbatch,200);
            Test.stopTest(); 
            PartnerFundClaim pfc = [Select id,title,Core_MDF_Payment_Id__c,Core_MDF_Status__c from PartnerFundClaim where title='India Claim New' limit 1];
            //System.assertNotEquals(pfc.Core_MDF_Payment_Id__c,null);
        }
        
    }
    // Test method to test scheduling and file generation functionality Payments Process 
    @isTest static void testPaymentFileHelper(){
        Test.startTest();
        
        List<Core_MDF_Payment_Run__c> paymentRunList = new List<Core_MDF_Payment_Run__c>();
        Map<String, PartnerFundClaim> claimMap = new Map<String, PartnerFundClaim>();
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User payAdmUser = [SELECT Id,Email from User where Email='testPayment@example.com' limit 1];
        PartnerFundRequest retailActivity = [SELECT Id,Title,Core_MDF_Start_Date__c,Core_MDF_End_Date__c,Core_MDF_Budget_Type_nm__c,Core_MDF_Product_Category_txt__c from PartnerFundRequest where Title='indiaActivity4' limit 1];        
        retailActivity.Core_MDF_BU_Split__c='CCG;DCG';
        update retailActivity;
        
        Core_MDF_Bank__c retailMDFBank = [Select ID,Core_MDF_Program__c,Core_MDF_Supplier_Country_txt__c from Core_MDF_Bank__c where Core_MDF_Program__c = 'Core_MDF_Retail_Marketing_Funds'  limit 1];
        
        retailMDFBank.Core_MDF_Supplier_Country_txt__c = 'USA';
        System.runAs(sysAdminUser){
            database.update(retailMDFBank);
            
            PartnerFundClaim retailMdfClaim = Core_MDF_CCP_TestDataUtility.createClaim('Retail MDF Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_Retail, retailActivity.Id, System.today().addDays(-5), System.today().addDays(-5), 50.00, System.today().addDays(-5), retailMDFBank.Id, false);
            retailMdfClaim.Core_MDF_Type_Txt__c ='Claim';
            retailMdfClaim.Core_MDF_Currency__c='USD';
            retailMdfClaim.Core_MDF_Country_Location_nm__c= 'India'; 
            retailMdfClaim.Core_MDF_Quarter_Year_Txt__c = 'Q3-2020';
            retailMdfClaim.Core_MDF_VAT_Eligibility_Ind__c = false;
            retailMdfClaim.Core_MDF_Region_Cd__c='APJ';
            retailMdfClaim.Core_MDF_To_Be_Audited_Ind__c=true;
            retailMdfClaim.Core_MDF_Status__c ='Payment Due';
            retailMdfClaim.Core_MDF_Quarter_Year_txt__c='Q1-2022';
            retailMdfClaim.Core_MDF_Processing_Preference_nm__c = 'Settle, then get paid';
            insert retailMdfClaim;
            List<PartnerFundClaim> claimList =  new List<PartnerFundClaim>();
            claimList.add(retailMdfClaim);
            claimMap.put(retailMdfClaim.title,retailMdfClaim);
            
        }
        //Test.stopTest();
        System.runAs(payAdmUser){
            Core_MDF_Payment_Run__c payRunRecord = new Core_MDF_Payment_Run__c();
            payRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
            payRunRecord.Core_MDF_Geo_Txt__c = 'ASMO';
            payRunRecord.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
            payRunRecord.Core_MDF_Program_Txt__c ='Client CoMarketing Fund';
            payRunRecord.RecordTypeId = payRun_RecordType_CCFCMP;
            paymentRunList.add(payRunRecord);
            Database.insert(payRunRecord);
            
            Map<String,Core_MDF_PaymentWrapper> grps = new Map<String,Core_MDF_PaymentWrapper>();
            
            Core_MDF_PaymentWrapper paymentWrapper = new Core_MDF_PaymentWrapper();
            paymentWrapper.claimsToBeProcessed = claimMap.values();
            paymentWrapper.sumOfClaimsAmount = 0;  
            paymentWrapper.sumOfConvertedAmount = 0;
            paymentWrapper.currencyExchangeRate = 0;
            paymentWrapper.budgetType = 'OEM CMP';
            grps.put('test',paymentWrapper);
            Core_MDF_Payment_Sharing.sharePaymentRecordsToInternalUsers(grps,'PGM');
            
            Core_MDF_PaymentFileWrapper paymentFileWrapper = new Core_MDF_PaymentFileWrapper();
            paymentFileWrapper.claimsToBeProcessed = claimMap.values();
            paymentFileWrapper.sumOfClaimsAmount = 0;  
            paymentFileWrapper.sumOfConvertedAmount = 0;
            paymentFileWrapper.geoLocation = '';
            paymentFileWrapper.subGeoLocation = '';
            paymentFileWrapper.currencyExchangeRate = 0;
            paymentFileWrapper.productCategory = '';
            paymentFileWrapper.quarterNum = '';
            paymentFileWrapper.fiscalYear = '';
            paymentFileWrapper.fyQuarterAndYear = '';
            paymentFileWrapper.paymentWrapperUniqueKey = '';
            paymentFileWrapper.totalVatAmt = 0;
            paymentFileWrapper.isVatEligible = false;
            paymentFileWrapper.totalConvertedVatAmt = 0;
            paymentFileWrapper.isCTypeInd=false;
            paymentFileWrapper.businessUnit = '';
            paymentFileWrapper.profitcenter = '';
            paymentFileWrapper.materialCode = '';
            
            Map<String,Core_MDF_PaymentFileWrapper> paymentFileWrapperMap = new Map<String,Core_MDF_PaymentFileWrapper>();
            paymentFileWrapperMap.put('test',paymentFileWrapper);
            
            Core_MDF_Payment_FileHelper.ccpFileGenerator(grps,payRunRecord,'Client');
            Test.stopTest();
            Core_MDF_Payment_FileHelper.generateHeader();
            Core_MDF_Payment_FileHelper.generateFooter();
            Core_MDF_Payment_FileHelper.generateExternalCommentsForVat(paymentFileWrapper);
            Core_MDF_Payment_FileHelper.getVATPaymentFileContentAfterSplit('Test','Test',1,true);
            Core_MDF_PaymentProcessRetailMdfIPA.createPaymentWrapperMap(paymentFileWrapperMap,payRunRecord);            
        }
        
        
    }
    
    @isTest static void testAdjustmentForCMPClaims(){        
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User claimCaseUser = [SELECT Id,Email from User where Email='testreviewer@example.com' limit 1];
        Test.startTest();
        Map<String,List<PartnerFundClaim>> accountToAdjustmentClaims = new Map<String,List<PartnerFundClaim>>();
        Map<String, PartnerFundClaim> claimMap = new Map<String, PartnerFundClaim>();
        User payAdmUser = [SELECT Id,Email from User where Email='testPayment@example.com' limit 1];
        claimMap = createClaim();
        
        for(String claimKey : claimMap.keySet()){
            accountToAdjustmentClaims.put(claimKey, new List<PartnerFundClaim>{claimMap.get(claimKey)}); 
        }
        
    }
    
    @isTest static void validateCoGTMPaymentRunCustomer() {
        Test.startTest();
        User cogtmPayAdm = [SELECT Id,Email from User where Email='testCoGTMPayment@example.com' limit 1];
        Map<String, PartnerFundClaim> claimMap = new Map<String, PartnerFundClaim>();
        PartnerFundRequest coGTMPFR = [Select Id from PartnerFundRequest where Title ='Test CoGTM PFR'];
        Core_MDF_Bank__c bankCoGTM = [Select Id from Core_MDF_Bank__c where Name = 'Test CoGTM Bank'];
        
        Id pfc_RecordType_CoGTM = Schema.SObjectType.PartnerFundClaim.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_GTM').getRecordTypeId();
        //CoGTM Customer
        PartnerFundClaim coGTMPFCCustomer = new PartnerFundClaim();
        coGTMPFCCustomer.RequestId = coGTMPFR.Id;
        coGTMPFCCustomer.RecordTypeId = pfc_RecordType_CoGTM;
        coGTMPFCCustomer.amount = 50;
        coGTMPFCCustomer.Core_MDF_Status__c = 'Payment Due';
        coGTMPFCCustomer.Core_MDF_Invoice_Date__c = System.today().addDays(-4);
        coGTMPFCCustomer.Core_MDF_Invoice_Number__c = 'INV1686';
        coGTMPFCCustomer.Core_MDF_Media_Vehicle__c = 'Test';
        coGTMPFCCustomer.Core_MDF_OtherCostsnotReimbursable_Local__c = 0;
        coGTMPFCCustomer.Core_MDF_Taxes_Local__c = 12;
        coGTMPFCCustomer.Core_MDF_Total_Invoice_Amount_Local__c = 50;
        coGTMPFCCustomer.Core_MDF_Ad_Run_Start_Date__c = System.today().addDays(-4);
        coGTMPFCCustomer.Core_MDF_Ad_Run_End_Date__c = System.today().addDays(-4);
        coGTMPFCCustomer.Title = 'Test CoGTM PFC';
        coGTMPFCCustomer.Core_MDF_Currency__c = 'USD';        
        coGTMPFCCustomer.Description = 'Test';
        coGTMPFCCustomer.Core_MDF_Reimbursable_Transaction_Amount__c=100;
        coGTMPFCCustomer.Core_MDF_Bank__c = bankCoGTM.Id;
        coGTMPFCCustomer.Core_MDF_Quarter_Year_Txt__c = 'Q3-2025';
        coGTMPFCCustomer.Core_MDF_Country_Location_nm__c = 'AUSTRALIA';
        coGTMPFCCustomer.Core_MDF_Region_Cd__c = 'APJ';
        coGTMPFCCustomer.Core_MDF_Recovery_Hold_Ind__c = false;
        coGTMPFCCustomer.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';
        coGTMPFCCustomer.Core_MDF_Type_Txt__c = 'Claim';
        Database.insert(coGTMPFCCustomer);
		PartnerFundClaim dataCoGTMPFCCustomer = [SELECT Id,RequestId,Core_MDF_Region_Cd__c,Core_MDF_Sub_Region_Cd__c,ChannelPartnerId, Request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_VAT_Amt__c, Request.Core_MDF_Product_Category_txt__c,Request.ChannelPartnerId, Core_MDF_Program__c,RecordTypeId,amount,Core_MDF_Status__c,Core_MDF_Invoice_Date__c, Core_MDF_Invoice_Number__c,Core_MDF_Media_Vehicle__c,Core_MDF_OtherCostsnotReimbursable_Local__c, Core_MDF_Taxes_Local__c,Core_MDF_Total_Invoice_Amount_Local__c,Core_MDF_Ad_Run_Start_Date__c, Core_MDF_Ad_Run_End_Date__c,Title,Core_MDF_Currency__c,Description,Core_MDF_Reimbursable_Transaction_Amount__c, Core_MDF_Bank__c,Core_MDF_Quarter_Year_Txt__c,Core_MDF_Payment_Type_nm__c,Core_MDF_Budget_Type_Options_Nm__c, ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_Bank__r.Core_MDF_Supplier_Number__c, Core_MDF_VAT_Eligibility_Ind__c, Core_MDF_C_Type_Ind__c, Request.Core_MDF_BU_Split__c, Core_MDF_Campaign_Id__r.Core_MDF_MMID__c, Core_MDF_Campaign_Id__r.Core_MDF_Profit_Center__c from PartnerFundClaim where Id =:coGTMPFCCustomer.Id limit 1];
        
        dataCoGTMPFCCustomer.Core_MDF_Status__c = 'Payment Due';
        Database.update(dataCoGTMPFCCustomer);
        claimMap.put(dataCoGTMPFCCustomer.title,dataCoGTMPFCCustomer);
        System.runAs(cogtmPayAdm){
            ChannelProgram cp1 = [Select Id,Name from ChannelProgram where Name ='Co-GTM' LIMIT 1];            
            
            Map<Id,Core_MDF_Comarketing_CMF_Map__c> cmfMap = new MAp<Id,Core_MDF_Comarketing_CMF_Map__c>();            
            Core_MDF_Payment_Run__c cogtmPayRunRecord = new Core_MDF_Payment_Run__c();
            cogtmPayRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
            cogtmPayRunRecord.Core_MDF_Start_Dt__c = System.today().addDays(-30);                                                       
            cogtmPayRunRecord.Core_MDF_End_Dt__c = System.today().addDays(30);
            cogtmPayRunRecord.Core_MDF_Program_Txt__c = 'CoGTM';
            cogtmPayRunRecord.Core_MDF_Program_Id__c = cp1.Id;
            cogtmPayRunRecord.Core_MDF_Payment_Nature_nm__c = 'Contra CSAR';
            cogtmPayRunRecord.RecordTypeId  = payRun_RecordType_CoGTM;
            cogtmPayRunRecord.Core_MDF_Geo_Txt__c= 'APJ';
            cogtmPayRunRecord.Core_MDF_Subgeo_Txt__c = null;
            cogtmPayRunRecord.Core_MDF_Run_For_All_Accounts__c = true;
            Database.insert(cogtmPayRunRecord);                    
            List<Core_MDF_Payment_Run__c> paymentRecordList = new List<Core_MDF_Payment_Run__c>();
            paymentRecordList.add(cogtmPayRunRecord);
            Core_MDF_Payment_Run__c testcogtmPayRunRecord = [Select Id,Core_MDF_Payment_run_for_Accounts__c,Core_MDF_Program_Id__c,Core_MDF_Payment_Types_txt__c, Core_MDF_Program_Id__r.Name,Core_MDF_ScheduleRun_Dtm__c,Core_MDF_Geo_Txt__c,Core_MDF_Start_Dt__c,Core_MDF_End_Dt__c,Core_MDF_Program_Txt__c,RecordTypeId,Core_MDF_Payment_Nature_nm__c,Core_MDF_Subgeo_Txt__c, Name,Core_MDF_Budget_Type_nm__c from Core_MDF_Payment_Run__c where Id =: cogtmPayRunRecord.Id];
            Core_MDF_Batch_PaymentFileGenerator paymentbatch = new Core_MDF_Batch_PaymentFileGenerator(testcogtmPayRunRecord);
            database.executebatch(paymentbatch,200);
            System.assertNotEquals(testcogtmPayRunRecord.Id,null);
            Map<String,Core_MDF_PaymentWrapper> grps = new Map<String,Core_MDF_PaymentWrapper>();            
            Core_MDF_PaymentWrapper paymentWrapper = new Core_MDF_PaymentWrapper();
            paymentWrapper.claimsToBeProcessed = claimMap.values();
            paymentWrapper.sumOfClaimsAmount = 0;  
            paymentWrapper.sumOfConvertedAmount = 0;
            paymentWrapper.currencyExchangeRate = 0;
            grps.put('test',paymentWrapper);
            
            Core_MDF_PaymentFileWrapper paymentFileWrapper = new Core_MDF_PaymentFileWrapper();
            paymentFileWrapper.claimsToBeProcessed = claimMap.values();
            paymentFileWrapper.sumOfClaimsAmount = 100;  
            paymentFileWrapper.sumOfConvertedAmount = 0;
            paymentFileWrapper.geoLocation = '';
            paymentFileWrapper.subGeoLocation = '';
            paymentFileWrapper.currencyExchangeRate = 0;
            paymentFileWrapper.productCategory = '';
            paymentFileWrapper.quarterNum = '';
            paymentFileWrapper.fiscalYear = '';
            paymentFileWrapper.fyQuarterAndYear = '';
            paymentFileWrapper.paymentWrapperUniqueKey = '';
            paymentFileWrapper.totalVatAmt = 0;
            paymentFileWrapper.isVatEligible = true;
            paymentFileWrapper.totalConvertedVatAmt = 0;
            paymentFileWrapper.isCTypeInd=false;
            paymentFileWrapper.businessUnit = '';
            paymentFileWrapper.profitcenter = '';
            paymentFileWrapper.materialCode = '';
            paymentFileWrapper.isRecoveryIncluded = false;
            paymentFileWrapper.sumOfClaimsAmountExcludesRecovery = 50;
            paymentFileWrapper.includeOnlyClaimAmountForPayment = true;
            Map<String,Core_MDF_PaymentFileWrapper> paymentFileWrapperMap = new Map<String,Core_MDF_PaymentFileWrapper>();
            paymentFileWrapperMap.put('test',paymentFileWrapper);
            
            Map<Id, Core_MDF_Account_Node_Attributes__c> accNodeAttrMap = new Map<Id,Core_MDF_Account_Node_Attributes__c>([Select Id,Core_MDF_Account_id__c, Core_MDF_Program_id__c,Core_MDF_CSAR_GL_Account_nbr__c,Core_MDF_External_ID__c,Core_MDF_NonPO_GL_Account_nbr__c from Core_MDF_Account_Node_Attributes__c limit 1]);
            Core_MDF_Payment_FileHelper.generateIPAPaymentFileForCreditMemo(paymentFileWrapperMap,testcogtmPayRunRecord,'Co-GTM');
            Map<String,List<PartnerFundClaim>> paymentTypeToClaims= new Map<String,List<PartnerFundClaim>>();
            paymentTypeToClaims.put('CSAR Cash',claimMap.values());
            Core_MDF_PaymentProcessRetailMdfIPA.groupClaimsforPaymentFileRetailMDFIPA(claimMap.values(),testcogtmPayRunRecord, new MAp<Id,Core_MDF_Comarketing_CMF_Map__c>(), new Map<Id, Core_MDF_Account_Node_Attributes__c>());
            Core_MDF_PaymentProcessRetailMdfIPA.createPaymentWrapperMap(paymentFileWrapperMap,testcogtmPayRunRecord);
            Map<String,Map<String,Core_MDF_PaymentFileWrapper>> paymentTypeToFileWrapper= new Map<String,Map<String,Core_MDF_PaymentFileWrapper>>();
            paymentTypeToFileWrapper.put('CSAR Cash',paymentFileWrapperMap);
            Core_MDF_Batch_UpdatePaymentRunClaims batch = new Core_MDF_Batch_UpdatePaymentRunClaims(null, paymentFileWrapperMap,paymentTypeToFileWrapper, claimMap.values(), testcogtmPayRunRecord, null,paymentTypeToClaims,null, accNodeAttrMap);
            database.executebatch(batch,200);
        }
        Test.stopTest();
    }
    
    @isTest static void validateCoGTMPaymentRunCustomerCreditMemo() {
        User cogtmPayAdm = [SELECT Id,Email from User where Email='testCoGTMPayment@example.com' limit 1];
        Account cogtmCoMarketingAccount = [SELECT Id,Core_MDF_Payment_Type_nm__c from Account where Name='CoGTM Co-Marketing Account' limit 1];
        Map<String, PartnerFundClaim> claimMap = new Map<String, PartnerFundClaim>();
        PartnerFundRequest coGTMPFR = [Select Id from PartnerFundRequest where Title ='Test CoGTM PFR'];
        Test.startTest();
        Id pfc_RecordType_CoGTM = Schema.SObjectType.PartnerFundClaim.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_GTM').getRecordTypeId();
        //CoGTM Customer Credit Memo
        cogtmCoMarketingAccount.Core_MDF_Payment_Type_nm__c = 'Customer (Credit Memo)';
        Database.update(cogtmCoMarketingAccount);
        
        PartnerFundClaim coGTMPFCCreditMemo = new PartnerFundClaim();
        coGTMPFCCreditMemo.RequestId = coGTMPFR.Id;
        coGTMPFCCreditMemo.RecordTypeId = pfc_RecordType_CoGTM;
        coGTMPFCCreditMemo.amount = 50;
        coGTMPFCCreditMemo.Core_MDF_Status__c = 'Payment Due';
        coGTMPFCCreditMemo.Core_MDF_Invoice_Date__c = System.today().addDays(-4);
        coGTMPFCCreditMemo.Core_MDF_Invoice_Number__c = 'INV1686';
        coGTMPFCCreditMemo.Core_MDF_Media_Vehicle__c = 'Test';
        coGTMPFCCreditMemo.Core_MDF_OtherCostsnotReimbursable_Local__c = 0;
        coGTMPFCCreditMemo.Core_MDF_Taxes_Local__c = 12;
        coGTMPFCCreditMemo.Core_MDF_Total_Invoice_Amount_Local__c = 50;
        coGTMPFCCreditMemo.Core_MDF_Ad_Run_Start_Date__c = System.today().addDays(-4);
        coGTMPFCCreditMemo.Core_MDF_Ad_Run_End_Date__c = System.today().addDays(-4);
        coGTMPFCCreditMemo.Title = 'Test CoGTM PFC';
        coGTMPFCCreditMemo.Core_MDF_Currency__c = 'USD';        
        coGTMPFCCreditMemo.Description = 'Test';
        coGTMPFCCreditMemo.Core_MDF_Reimbursable_Transaction_Amount__c=100;
        coGTMPFCCreditMemo.Core_MDF_Quarter_Year_Txt__c = 'Q3-2025';
        coGTMPFCCreditMemo.Core_MDF_Region_Cd__c = null;
        coGTMPFCCreditMemo.Core_MDF_Recovery_Hold_Ind__c = false;
        coGTMPFCCreditMemo.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';
        coGTMPFCCreditMemo.Core_MDF_Type_Txt__c = 'Claim';
        Database.insert(coGTMPFCCreditMemo);
        PartnerFundClaim datacoGTMPFCCreditMemo = [SELECT Id,RequestId,Core_MDF_Region_Cd__c,Core_MDF_Sub_Region_Cd__c,Request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,Request.Core_MDF_Product_Category_txt__c,Core_MDF_VAT_Amt__c,ChannelPartnerId,Request.ChannelPartnerId, Core_MDF_Program__c,RecordTypeId,amount,Core_MDF_Status__c,Core_MDF_Invoice_Date__c, Core_MDF_Invoice_Number__c,Core_MDF_Media_Vehicle__c,Core_MDF_OtherCostsnotReimbursable_Local__c, Core_MDF_Taxes_Local__c,Core_MDF_Total_Invoice_Amount_Local__c,Core_MDF_Ad_Run_Start_Date__c, Core_MDF_Ad_Run_End_Date__c,Title,Core_MDF_Currency__c,Description,Core_MDF_Reimbursable_Transaction_Amount__c, Core_MDF_Bank__c,Core_MDF_Quarter_Year_Txt__c,Core_MDF_Payment_Type_nm__c,Core_MDF_Budget_Type_Options_Nm__c, ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c , Core_MDF_Bank__r.Core_MDF_Supplier_Number__c, Core_MDF_VAT_Eligibility_Ind__c, Core_MDF_C_Type_Ind__c, Request.Core_MDF_BU_Split__c from PartnerFundClaim where Id =:coGTMPFCCreditMemo.Id limit 1];
        datacoGTMPFCCreditMemo.Core_MDF_Status__c = 'Payment Due';
        Database.update(datacoGTMPFCCreditMemo);
        claimMap.put(datacoGTMPFCCreditMemo.title,datacoGTMPFCCreditMemo);
        System.runAs(cogtmPayAdm){
            ChannelProgram cp1 = [Select Id,Name from ChannelProgram where Name ='Co-GTM' LIMIT 1];
            Core_MDF_Payment_Run__c cogtmPayRunRecord = new Core_MDF_Payment_Run__c();
            cogtmPayRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
            cogtmPayRunRecord.Core_MDF_Start_Dt__c = System.today().addDays(-30);                                                       
            cogtmPayRunRecord.Core_MDF_End_Dt__c = System.today().addDays(30);
            cogtmPayRunRecord.Core_MDF_Program_Txt__c = 'CoGTM';
            cogtmPayRunRecord.Core_MDF_Program_Id__c = cp1.Id;
            cogtmPayRunRecord.RecordTypeId  = payRun_RecordType_CoGTM;
            cogtmPayRunRecord.Core_MDF_Payment_Nature_nm__c =	'Contra CSAR' ;
            cogtmPayRunRecord.Core_MDF_Run_For_All_Accounts__c = true;
            cogtmPayRunRecord.Core_MDF_Geo_Txt__c= '';
            cogtmPayRunRecord.Core_MDF_Subgeo_Txt__c = '';
            Database.insert(cogtmPayRunRecord);
            Core_MDF_Payment_Run__c testcogtmPayRunRecord = [Select Id,Core_MDF_Payment_run_for_Accounts__c,Core_MDF_Program_Id__c,Core_MDF_Payment_Types_txt__c, Core_MDF_Program_Id__r.Name,Core_MDF_ScheduleRun_Dtm__c,Core_MDF_Geo_Txt__c,Core_MDF_Start_Dt__c,Core_MDF_End_Dt__c,Core_MDF_Program_Txt__c,RecordTypeId,Core_MDF_Payment_Nature_nm__c,Core_MDF_Subgeo_Txt__c, Name,Core_MDF_Budget_Type_nm__c from Core_MDF_Payment_Run__c where Id =: cogtmPayRunRecord.Id];
            Core_MDF_Batch_PaymentFileGenerator paymentbatch = new Core_MDF_Batch_PaymentFileGenerator(testcogtmPayRunRecord);
            database.executebatch(paymentbatch,200);
            System.assertNotEquals(testcogtmPayRunRecord.Id,null);
            Map<String,Core_MDF_PaymentWrapper> grps = new Map<String,Core_MDF_PaymentWrapper>();
            
            Core_MDF_PaymentWrapper paymentWrapper = new Core_MDF_PaymentWrapper();
            paymentWrapper.claimsToBeProcessed = claimMap.values();
            paymentWrapper.sumOfClaimsAmount = 0;  
            paymentWrapper.sumOfConvertedAmount = 0;
            paymentWrapper.currencyExchangeRate = 0;
            grps.put('test',paymentWrapper);
            
            Core_MDF_PaymentFileWrapper paymentFileWrapper = new Core_MDF_PaymentFileWrapper();
            paymentFileWrapper.claimsToBeProcessed = claimMap.values();
            paymentFileWrapper.sumOfClaimsAmount = 100;  
            paymentFileWrapper.sumOfConvertedAmount = 0;
            paymentFileWrapper.geoLocation = '';
            paymentFileWrapper.subGeoLocation = '';
            paymentFileWrapper.currencyExchangeRate = 0;
            paymentFileWrapper.productCategory = '';
            paymentFileWrapper.quarterNum = '';
            paymentFileWrapper.fiscalYear = '';
            paymentFileWrapper.fyQuarterAndYear = '';
            paymentFileWrapper.paymentWrapperUniqueKey = '';
            paymentFileWrapper.totalVatAmt = 0;
            paymentFileWrapper.isVatEligible = true;
            paymentFileWrapper.totalConvertedVatAmt = 0;
            paymentFileWrapper.isCTypeInd=false;
            paymentFileWrapper.businessUnit = '';
            paymentFileWrapper.profitcenter = '';
            paymentFileWrapper.materialCode = '';
            paymentFileWrapper.isRecoveryIncluded = true;
            paymentFileWrapper.sumOfClaimsAmountExcludesRecovery = 50;
            paymentFileWrapper.includeOnlyClaimAmountForPayment = true;
            Map<String,Core_MDF_PaymentFileWrapper> paymentFileWrapperMap = new Map<String,Core_MDF_PaymentFileWrapper>();
            paymentFileWrapperMap.put('test',paymentFileWrapper);
            
            Map<Id, Core_MDF_Account_Node_Attributes__c> accNodeAttrMap = new Map<Id,Core_MDF_Account_Node_Attributes__c>([Select Id,Core_MDF_Account_id__c, Core_MDF_Program_id__c,Core_MDF_CSAR_GL_Account_nbr__c,Core_MDF_External_ID__c,Core_MDF_NonPO_GL_Account_nbr__c from Core_MDF_Account_Node_Attributes__c limit 1]);
            Core_MDF_Payment_FileHelper.generateIPAPaymentFileForCreditMemo(paymentFileWrapperMap,testcogtmPayRunRecord,'Co-GTM');
            Map<String,List<PartnerFundClaim>> paymentTypeToClaims= new Map<String,List<PartnerFundClaim>>();
            paymentTypeToClaims.put('CSAR Credit Memo',claimMap.values());
            Core_MDF_PaymentProcessRetailMdfIPA.groupClaimsforPaymentFileRetailMDFIPA(claimMap.values(),testcogtmPayRunRecord, new MAp<Id,Core_MDF_Comarketing_CMF_Map__c>(), new Map<Id, Core_MDF_Account_Node_Attributes__c>());
            Core_MDF_PaymentProcessRetailMdfIPA.createPaymentWrapperMap(paymentFileWrapperMap,testcogtmPayRunRecord);
            Map<String,Map<String,Core_MDF_PaymentFileWrapper>> paymentTypeToFileWrapper= new Map<String,Map<String,Core_MDF_PaymentFileWrapper>>();
            paymentTypeToFileWrapper.put('CSAR Credit Memo',paymentFileWrapperMap);
            Core_MDF_Batch_UpdatePaymentRunClaims batch = new Core_MDF_Batch_UpdatePaymentRunClaims(null, paymentFileWrapperMap,paymentTypeToFileWrapper, claimMap.values(), cogtmPayRunRecord, null,paymentTypeToClaims,null, accNodeAttrMap);
            database.executebatch(batch,200);
            Test.stopTest();
        }
    }
    
    @isTest static void validateCoGTMPaymentRunVistexCash() {
        User cogtmPayAdm = [SELECT Id,Email from User where Email='testCoGTMPayment@example.com' limit 1];
        Account cogtmCoMarketingAccount = [SELECT Id,Core_MDF_Payment_Type_nm__c from Account where Name='CoGTM Co-Marketing Account' limit 1];
        Map<String, PartnerFundClaim> claimMap = new Map<String, PartnerFundClaim>();
        PartnerFundRequest coGTMPFR = [Select Id from PartnerFundRequest where Title ='Test CoGTM PFR'];        
        Core_MDF_Bank__c bankCoGTM = [Select Id from Core_MDF_Bank__c where Name = 'Test CoGTM Bank'];
        Test.startTest();
        Id pfc_RecordType_CoGTM = Schema.SObjectType.PartnerFundClaim.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_GTM').getRecordTypeId();
        //CoGTM Customer Credit Memo
        cogtmCoMarketingAccount.Core_MDF_Payment_Type_nm__c = 'Vistex (Cash)';
        Database.update(cogtmCoMarketingAccount);
        
        PartnerFundClaim coGTMPFCVistexCash = new PartnerFundClaim();
        coGTMPFCVistexCash.RequestId = coGTMPFR.Id;
        coGTMPFCVistexCash.RecordTypeId = pfc_RecordType_CoGTM;
        coGTMPFCVistexCash.amount = 50;
        coGTMPFCVistexCash.Core_MDF_Status__c = 'Payment Due';
        coGTMPFCVistexCash.Core_MDF_Invoice_Date__c = System.today().addDays(-4);
        coGTMPFCVistexCash.Core_MDF_Invoice_Number__c = 'INV1686';
        coGTMPFCVistexCash.Core_MDF_Media_Vehicle__c = 'Test';
        coGTMPFCVistexCash.Core_MDF_OtherCostsnotReimbursable_Local__c = 0;
        coGTMPFCVistexCash.Core_MDF_Taxes_Local__c = 12;
        coGTMPFCVistexCash.Core_MDF_Total_Invoice_Amount_Local__c = 50;
        coGTMPFCVistexCash.Core_MDF_Ad_Run_Start_Date__c = System.today().addDays(-4);
        coGTMPFCVistexCash.Core_MDF_Ad_Run_End_Date__c = System.today().addDays(-4);
        coGTMPFCVistexCash.Title = 'Test CoGTM PFC';
        coGTMPFCVistexCash.Core_MDF_Currency__c = 'USD';        
        coGTMPFCVistexCash.Description = 'Test';
        coGTMPFCVistexCash.Core_MDF_Reimbursable_Transaction_Amount__c=100;
        coGTMPFCVistexCash.Core_MDF_Quarter_Year_Txt__c = 'Q3-2025';
        coGTMPFCVistexCash.Core_MDF_Bank__c = bankCoGTM.Id;
        coGTMPFCVistexCash.Core_MDF_Region_Cd__c = null;
        coGTMPFCVistexCash.Core_MDF_Recovery_Hold_Ind__c = false;
        coGTMPFCVistexCash.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';
        coGTMPFCVistexCash.Core_MDF_Type_Txt__c = 'Claim';
        Database.insert(coGTMPFCVistexCash);
        PartnerFundClaim datacoGTMPFCVistexCash = [SELECT Id,RequestId,Core_MDF_Region_Cd__c,Core_MDF_Sub_Region_Cd__c,Request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,Request.Core_MDF_Product_Category_txt__c,Core_MDF_VAT_Amt__c,ChannelPartnerId,Request.ChannelPartnerId, Core_MDF_Program__c,RecordTypeId,amount,Core_MDF_Status__c,Core_MDF_Invoice_Date__c, Core_MDF_Invoice_Number__c,Core_MDF_Media_Vehicle__c,Core_MDF_OtherCostsnotReimbursable_Local__c, Core_MDF_Taxes_Local__c,Core_MDF_Total_Invoice_Amount_Local__c,Core_MDF_Ad_Run_Start_Date__c, Core_MDF_Ad_Run_End_Date__c,Title,Core_MDF_Currency__c,Description,Core_MDF_Reimbursable_Transaction_Amount__c, Core_MDF_Bank__c,Core_MDF_Quarter_Year_Txt__c,Core_MDF_Payment_Type_nm__c,Core_MDF_Budget_Type_Options_Nm__c, ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c , Core_MDF_Bank__r.Core_MDF_Supplier_Number__c, Core_MDF_VAT_Eligibility_Ind__c, Core_MDF_C_Type_Ind__c, Request.Core_MDF_BU_Split__c, Core_MDF_Campaign_Id__r.Core_MDF_MMID__c, Core_MDF_Campaign_Id__r.Core_MDF_Profit_Center__c from PartnerFundClaim where Id =:coGTMPFCVistexCash.Id limit 1];
        datacoGTMPFCVistexCash.Core_MDF_Status__c = 'Payment Due';
        Database.update(datacoGTMPFCVistexCash);
        claimMap.put(datacoGTMPFCVistexCash.title,datacoGTMPFCVistexCash);
        System.runAs(cogtmPayAdm){
            ChannelProgram cp1 = [Select Id,Name from ChannelProgram where Name ='Co-GTM' LIMIT 1];
            Core_MDF_Payment_Run__c cogtmPayRunRecord = new Core_MDF_Payment_Run__c();
            cogtmPayRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
            cogtmPayRunRecord.Core_MDF_Start_Dt__c = System.today().addDays(-30);                                                       
            cogtmPayRunRecord.Core_MDF_End_Dt__c = System.today().addDays(30);
            cogtmPayRunRecord.Core_MDF_Program_Txt__c = 'CoGTM';
            cogtmPayRunRecord.Core_MDF_Program_Id__c = cp1.Id;
            cogtmPayRunRecord.RecordTypeId  = payRun_RecordType_CoGTM;
            cogtmPayRunRecord.Core_MDF_Payment_Nature_nm__c =	'Contra CSAR' ;
            cogtmPayRunRecord.Core_MDF_Run_For_All_Accounts__c = true;
            cogtmPayRunRecord.Core_MDF_Geo_Txt__c= '';
            cogtmPayRunRecord.Core_MDF_Subgeo_Txt__c = '';
            Database.insert(cogtmPayRunRecord);
            Core_MDF_Payment_Run__c testcogtmPayRunRecord = [Select Id,Core_MDF_Payment_run_for_Accounts__c,Core_MDF_Program_Id__c,Core_MDF_Payment_Types_txt__c, Core_MDF_Program_Id__r.Name,Core_MDF_ScheduleRun_Dtm__c,Core_MDF_Geo_Txt__c,Core_MDF_Start_Dt__c,Core_MDF_End_Dt__c,Core_MDF_Program_Txt__c,RecordTypeId,Core_MDF_Payment_Nature_nm__c,Core_MDF_Subgeo_Txt__c, Name,Core_MDF_Budget_Type_nm__c from Core_MDF_Payment_Run__c where Id =: cogtmPayRunRecord.Id];
            Core_MDF_Batch_PaymentFileGenerator paymentbatch = new Core_MDF_Batch_PaymentFileGenerator(testcogtmPayRunRecord);
            database.executebatch(paymentbatch,200);
            System.assertNotEquals(testcogtmPayRunRecord.Id,null);
            Map<String,Core_MDF_PaymentWrapper> grps = new Map<String,Core_MDF_PaymentWrapper>();
            
            Core_MDF_PaymentWrapper paymentWrapper = new Core_MDF_PaymentWrapper();
            paymentWrapper.claimsToBeProcessed = claimMap.values();
            paymentWrapper.sumOfClaimsAmount = 0;  
            paymentWrapper.sumOfConvertedAmount = 0;
            paymentWrapper.currencyExchangeRate = 0;
            grps.put('test',paymentWrapper);
            
            Core_MDF_PaymentFileWrapper paymentFileWrapper = new Core_MDF_PaymentFileWrapper();
            paymentFileWrapper.claimsToBeProcessed = claimMap.values();
            paymentFileWrapper.sumOfClaimsAmount = 100;  
            paymentFileWrapper.sumOfConvertedAmount = 0;
            paymentFileWrapper.geoLocation = '';
            paymentFileWrapper.subGeoLocation = '';
            paymentFileWrapper.currencyExchangeRate = 0;
            paymentFileWrapper.productCategory = '';
            paymentFileWrapper.quarterNum = '';
            paymentFileWrapper.fiscalYear = '';
            paymentFileWrapper.fyQuarterAndYear = '';
            paymentFileWrapper.paymentWrapperUniqueKey = '';
            paymentFileWrapper.totalVatAmt = 0;
            paymentFileWrapper.isVatEligible = true;
            paymentFileWrapper.totalConvertedVatAmt = 0;
            paymentFileWrapper.isCTypeInd=false;
            paymentFileWrapper.businessUnit = '';
            paymentFileWrapper.profitcenter = '';
            paymentFileWrapper.materialCode = '';
            paymentFileWrapper.isRecoveryIncluded = true;
            paymentFileWrapper.sumOfClaimsAmountExcludesRecovery = 50;
            paymentFileWrapper.includeOnlyClaimAmountForPayment = true;
            Map<String,Core_MDF_PaymentFileWrapper> paymentFileWrapperMap = new Map<String,Core_MDF_PaymentFileWrapper>();
            paymentFileWrapperMap.put('test',paymentFileWrapper);
            
            Map<Id, Core_MDF_Account_Node_Attributes__c> accNodeAttrMap = new Map<Id,Core_MDF_Account_Node_Attributes__c>([Select Id,Core_MDF_Account_id__c, Core_MDF_Program_id__c,Core_MDF_CSAR_GL_Account_nbr__c,Core_MDF_External_ID__c,Core_MDF_NonPO_GL_Account_nbr__c from Core_MDF_Account_Node_Attributes__c limit 1]);
            Core_MDF_Payment_FileHelper.generateIPAPaymentFileForCreditMemo(paymentFileWrapperMap,testcogtmPayRunRecord,'Co-GTM');
            Map<String,List<PartnerFundClaim>> paymentTypeToClaims= new Map<String,List<PartnerFundClaim>>();
            paymentTypeToClaims.put('CoGTM Vistex',claimMap.values());
            Core_MDF_PaymentProcessRetailMdfIPA.groupClaimsforPaymentFileRetailMDFIPA(claimMap.values(),testcogtmPayRunRecord, new MAp<Id,Core_MDF_Comarketing_CMF_Map__c>(), new Map<Id, Core_MDF_Account_Node_Attributes__c>());
            Core_MDF_PaymentProcessRetailMdfIPA.createPaymentWrapperMap(paymentFileWrapperMap,testcogtmPayRunRecord);
            Map<String,Map<String,Core_MDF_PaymentFileWrapper>> paymentTypeToFileWrapper= new Map<String,Map<String,Core_MDF_PaymentFileWrapper>>();
            paymentTypeToFileWrapper.put('CoGTM Vistex',paymentFileWrapperMap);
            Core_MDF_Batch_UpdatePaymentRunClaims batch = new Core_MDF_Batch_UpdatePaymentRunClaims(null, paymentFileWrapperMap,paymentTypeToFileWrapper, claimMap.values(), cogtmPayRunRecord, null,paymentTypeToClaims,null, accNodeAttrMap);
            database.executebatch(batch,200);
            Test.stopTest();
        }
    }
    
    @isTest static void validateCoGTMPaymentRunVistexCreditMemo() {
        User cogtmPayAdm = [SELECT Id,Email from User where Email='testCoGTMPayment@example.com' limit 1];
        Account cogtmCoMarketingAccount = [SELECT Id,Core_MDF_Payment_Type_nm__c from Account where Name='CoGTM Co-Marketing Account' limit 1];
        Map<String, PartnerFundClaim> claimMap = new Map<String, PartnerFundClaim>();
        PartnerFundRequest coGTMPFR = [Select Id from PartnerFundRequest where Title ='Test CoGTM PFR'];
        Test.startTest();
        Id pfc_RecordType_CoGTM = Schema.SObjectType.PartnerFundClaim.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_GTM').getRecordTypeId();
        //CoGTM Customer Credit Memo
        cogtmCoMarketingAccount.Core_MDF_Payment_Type_nm__c = 'Vistex (Credit Memo)';
        Database.update(cogtmCoMarketingAccount);
        
        PartnerFundClaim coGTMPFCVistexCreditMemo = new PartnerFundClaim();
        coGTMPFCVistexCreditMemo.RequestId = coGTMPFR.Id;
        coGTMPFCVistexCreditMemo.RecordTypeId = pfc_RecordType_CoGTM;
        coGTMPFCVistexCreditMemo.amount = 50;
        coGTMPFCVistexCreditMemo.Core_MDF_Status__c = 'Payment Due';
        coGTMPFCVistexCreditMemo.Core_MDF_Invoice_Date__c = System.today().addDays(-4);
        coGTMPFCVistexCreditMemo.Core_MDF_Invoice_Number__c = 'INV1686';
        coGTMPFCVistexCreditMemo.Core_MDF_Media_Vehicle__c = 'Test';
        coGTMPFCVistexCreditMemo.Core_MDF_OtherCostsnotReimbursable_Local__c = 0;
        coGTMPFCVistexCreditMemo.Core_MDF_Taxes_Local__c = 12;
        coGTMPFCVistexCreditMemo.Core_MDF_Total_Invoice_Amount_Local__c = 50;
        coGTMPFCVistexCreditMemo.Core_MDF_Ad_Run_Start_Date__c = System.today().addDays(-4);
        coGTMPFCVistexCreditMemo.Core_MDF_Ad_Run_End_Date__c = System.today().addDays(-4);
        coGTMPFCVistexCreditMemo.Title = 'Test CoGTM PFC';
        coGTMPFCVistexCreditMemo.Core_MDF_Currency__c = 'USD';        
        coGTMPFCVistexCreditMemo.Description = 'Test';
        coGTMPFCVistexCreditMemo.Core_MDF_Reimbursable_Transaction_Amount__c=100;
        coGTMPFCVistexCreditMemo.Core_MDF_Quarter_Year_Txt__c = 'Q3-2025';
        coGTMPFCVistexCreditMemo.Core_MDF_Region_Cd__c = null;
        coGTMPFCVistexCreditMemo.Core_MDF_Recovery_Hold_Ind__c = false;
        coGTMPFCVistexCreditMemo.Core_MDF_Processing_Preference_nm__c = 'Get paid, then settle';
        Database.insert(coGTMPFCVistexCreditMemo);
        PartnerFundClaim datacoGTMPFCVistexCreditMemo = [SELECT Id,RequestId,Core_MDF_Region_Cd__c,Core_MDF_Sub_Region_Cd__c,Request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,Request.Core_MDF_Product_Category_txt__c,Core_MDF_VAT_Amt__c,ChannelPartnerId,Request.ChannelPartnerId, Core_MDF_Program__c,RecordTypeId,amount,Core_MDF_Status__c,Core_MDF_Invoice_Date__c, Core_MDF_Invoice_Number__c,Core_MDF_Media_Vehicle__c,Core_MDF_OtherCostsnotReimbursable_Local__c, Core_MDF_Taxes_Local__c,Core_MDF_Total_Invoice_Amount_Local__c,Core_MDF_Ad_Run_Start_Date__c, Core_MDF_Ad_Run_End_Date__c,Title,Core_MDF_Currency__c,Description,Core_MDF_Reimbursable_Transaction_Amount__c, Core_MDF_Bank__c,Core_MDF_Quarter_Year_Txt__c,Core_MDF_Payment_Type_nm__c,Core_MDF_Budget_Type_Options_Nm__c, ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c , Core_MDF_Bank__r.Core_MDF_Supplier_Number__c, Core_MDF_VAT_Eligibility_Ind__c, Core_MDF_C_Type_Ind__c, Request.Core_MDF_BU_Split__c, Core_MDF_Campaign_Id__r.Core_MDF_MMID__c, Core_MDF_Campaign_Id__r.Core_MDF_Profit_Center__c from PartnerFundClaim where Id =:coGTMPFCVistexCreditMemo.Id limit 1];
        datacoGTMPFCVistexCreditMemo.Core_MDF_Status__c = 'Payment Due';
        Database.update(datacoGTMPFCVistexCreditMemo);
        claimMap.put(datacoGTMPFCVistexCreditMemo.title,datacoGTMPFCVistexCreditMemo);
        System.runAs(cogtmPayAdm){
            ChannelProgram cp1 = [Select Id,Name from ChannelProgram where Name ='Co-GTM' LIMIT 1];
            Core_MDF_Payment_Run__c cogtmPayRunRecord = new Core_MDF_Payment_Run__c();
            cogtmPayRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
            cogtmPayRunRecord.Core_MDF_Start_Dt__c = System.today().addDays(-30);                                                       
            cogtmPayRunRecord.Core_MDF_End_Dt__c = System.today().addDays(30);
            cogtmPayRunRecord.Core_MDF_Program_Txt__c = 'CoGTM';
            cogtmPayRunRecord.Core_MDF_Program_Id__c = cp1.Id;
            cogtmPayRunRecord.Core_MDF_Geo_Txt__c= '';
            cogtmPayRunRecord.Core_MDF_Subgeo_Txt__c = '';
            cogtmPayRunRecord.RecordTypeId  = payRun_RecordType_CoGTM;
            cogtmPayRunRecord.Core_MDF_Payment_Nature_nm__c =	'Contra CSAR' ;
            cogtmPayRunRecord.Core_MDF_Run_For_All_Accounts__c = true;
            Database.insert(cogtmPayRunRecord);
            Core_MDF_Payment_Run__c testcogtmPayRunRecord = [Select Id,Core_MDF_Payment_run_for_Accounts__c,Core_MDF_Program_Id__c,Core_MDF_Payment_Types_txt__c, Core_MDF_Program_Id__r.Name,Core_MDF_ScheduleRun_Dtm__c,Core_MDF_Geo_Txt__c,Core_MDF_Start_Dt__c,Core_MDF_End_Dt__c,Core_MDF_Program_Txt__c,RecordTypeId,Core_MDF_Payment_Nature_nm__c,Core_MDF_Subgeo_Txt__c, Name,Core_MDF_Budget_Type_nm__c from Core_MDF_Payment_Run__c where Id =: cogtmPayRunRecord.Id];
            Core_MDF_Batch_PaymentFileGenerator paymentbatch = new Core_MDF_Batch_PaymentFileGenerator(testcogtmPayRunRecord);
            database.executebatch(paymentbatch,200);
            System.assertNotEquals(testcogtmPayRunRecord.Id,null);
            Map<String,Core_MDF_PaymentWrapper> grps = new Map<String,Core_MDF_PaymentWrapper>();
            
            Core_MDF_PaymentWrapper paymentWrapper = new Core_MDF_PaymentWrapper();
            paymentWrapper.claimsToBeProcessed = claimMap.values();
            paymentWrapper.sumOfClaimsAmount = 0;  
            paymentWrapper.sumOfConvertedAmount = 0;
            paymentWrapper.currencyExchangeRate = 0;
            grps.put('test',paymentWrapper);
            
            Core_MDF_PaymentFileWrapper paymentFileWrapper = new Core_MDF_PaymentFileWrapper();
            paymentFileWrapper.claimsToBeProcessed = claimMap.values();
            paymentFileWrapper.sumOfClaimsAmount = 100;  
            paymentFileWrapper.sumOfConvertedAmount = 0;
            paymentFileWrapper.geoLocation = '';
            paymentFileWrapper.subGeoLocation = '';
            paymentFileWrapper.currencyExchangeRate = 0;
            paymentFileWrapper.productCategory = '';
            paymentFileWrapper.quarterNum = '';
            paymentFileWrapper.fiscalYear = '';
            paymentFileWrapper.fyQuarterAndYear = '';
            paymentFileWrapper.paymentWrapperUniqueKey = '';
            paymentFileWrapper.totalVatAmt = 0;
            paymentFileWrapper.isVatEligible = true;
            paymentFileWrapper.totalConvertedVatAmt = 0;
            paymentFileWrapper.isCTypeInd=false;
            paymentFileWrapper.businessUnit = '';
            paymentFileWrapper.profitcenter = '';
            paymentFileWrapper.materialCode = '';
            paymentFileWrapper.isRecoveryIncluded = true;
            paymentFileWrapper.sumOfClaimsAmountExcludesRecovery = 50;
            paymentFileWrapper.includeOnlyClaimAmountForPayment = true;
            Map<String,Core_MDF_PaymentFileWrapper> paymentFileWrapperMap = new Map<String,Core_MDF_PaymentFileWrapper>();
            paymentFileWrapperMap.put('test',paymentFileWrapper);
            
            Map<Id, Core_MDF_Account_Node_Attributes__c> accNodeAttrMap = new Map<Id,Core_MDF_Account_Node_Attributes__c>([Select Id,Core_MDF_Account_id__c, Core_MDF_Program_id__c,Core_MDF_CSAR_GL_Account_nbr__c,Core_MDF_External_ID__c,Core_MDF_NonPO_GL_Account_nbr__c from Core_MDF_Account_Node_Attributes__c limit 1]);
            Core_MDF_Payment_FileHelper.generateIPAPaymentFileForCreditMemo(paymentFileWrapperMap,testcogtmPayRunRecord,'Co-GTM');
            Map<String,List<PartnerFundClaim>> paymentTypeToClaims= new Map<String,List<PartnerFundClaim>>();
            paymentTypeToClaims.put('CoGTM Vistex',claimMap.values());
            Core_MDF_PaymentProcessRetailMdfIPA.groupClaimsforPaymentFileRetailMDFIPA(claimMap.values(),testcogtmPayRunRecord, new MAp<Id,Core_MDF_Comarketing_CMF_Map__c>(), new Map<Id, Core_MDF_Account_Node_Attributes__c>());
            Core_MDF_PaymentProcessRetailMdfIPA.createPaymentWrapperMap(paymentFileWrapperMap,testcogtmPayRunRecord);
            Map<String,Map<String,Core_MDF_PaymentFileWrapper>> paymentTypeToFileWrapper= new Map<String,Map<String,Core_MDF_PaymentFileWrapper>>();
            paymentTypeToFileWrapper.put('CoGTM Vistex',paymentFileWrapperMap);
            Core_MDF_Batch_UpdatePaymentRunClaims batch = new Core_MDF_Batch_UpdatePaymentRunClaims(null, paymentFileWrapperMap,paymentTypeToFileWrapper, claimMap.values(), cogtmPayRunRecord, null,paymentTypeToClaims,null, accNodeAttrMap);
            database.executebatch(batch,200);
            Test.stopTest();
        }
    }
}