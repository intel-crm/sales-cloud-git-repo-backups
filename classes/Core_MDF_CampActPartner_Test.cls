@isTest(SeeAllData=false)
public without sharing class Core_MDF_CampActPartner_Test{
    @TestSetup 
    static void createTestData() {
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
        
        Set<String> myset1 = new Set<String>();
        List<String> result1 = new List<String>();
        myset1.addAll(bypassFunctionKeys);
        result1.addAll(myset1);
        
        List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
        
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name = 'CCP - Core Access'];
        // Highlight: Unused Local Variable - Indira
       // UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 50000];
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'MDF Budget Loader';
        usr.profileId = systemAdminProfile.Id;
        Database.insert(usr);
        
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName = 'User Test1';
        usr1.profileId = ccpCoreProfile.Id;
        Database.insert(usr1);
        
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.LastName = 'TestClass TestUser';
        usr2.profileId = systemAdminProfile.Id;
        Database.insert(usr2);
        
        Test.startTest();   
        ChannelProgram eefCp = Core_MDF_CCP_TestDataUtility.createProgram('Ecosystem Extension Fund','Ecosystem Extension Fund', true);
        
        Id campaign_RecordType_EEF = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Ecosystem_Extension_Fund').getRecordTypeId();
        Id iupgm_Recordtype_EEF = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c .getRecordTypeInfosByDeveloperName().get('Core_MDF_Ecosystem_Extension_Fund').getRecordTypeId();
        //Create Group
        Group eefGrp = new Group();
        eefGrp.Name = 'Core CCP EEF External';
        eefGrp.DeveloperName = 'Core_CCP_EEF_External';
        Database.insert(eefGrp);
        
        // Creating Account with utility class
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        
        Account intelAcc = Core_MDF_CCP_TestDataUtility.createIntelAccount('Intel Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        
        Account eefPrimaryVirtualCorp = Core_MDF_CCP_TestDataUtility.createAccount ('EEF Primary Virtual Corp', eefCp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);                           
        eefPrimaryVirtualCorp.Core_MDF_Parent_Fund_Account__c = intelAcc.Id;
        eefPrimaryVirtualCorp.Core_MDF_Partner_Type_nm__c ='Primary Partner';
        eefPrimaryVirtualCorp.Core_MDF_External_Group_Id__c = eefGrp.Id;
        insert eefPrimaryVirtualCorp;
        
        Account eefActivatingVirtualCorp = Core_MDF_CCP_TestDataUtility.createAccount ('EEF Activating Virtual Corp', eefCp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);                           
        eefActivatingVirtualCorp.Core_MDF_Parent_Fund_Account__c = acc1.Id;
        eefActivatingVirtualCorp.Core_MDF_Partner_Type_nm__c ='Activating Partner';
        insert eefActivatingVirtualCorp;
        
        system.runAs(usr){
            PermissionSet eefBudLoader = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_Internal_EEF_Budget_Loader' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = eefBudLoader.Id);
            PermissionSet eefBudManager = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_Internal_EEF_Budget_Manager' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = usr2.id, PermissionSetId = eefBudManager.Id);
            PermissionSet eefPrimAccManager = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_Internal_EEF_Primary_Partner_Acct_Mgr' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = eefPrimAccManager.Id);
            PermissionSet eefPrimAccManager1 = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_Internal_EEF_Primary_Partner_Acct_Mgr' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = usr2.id, PermissionSetId = eefPrimAccManager1.Id);
            PermissionSet eefPrimAccManager2 = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_Internal_EEF_Primary_Partner_Acct_Mgr' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = eefPrimAccManager2.Id);            
        }
        
        List<PartnerMarketingBudget> pmbList = new List<PartnerMarketingBudget>(); 
        System.runAs(usr){
            Core_MDF_Partner_Mapping__c priToActiPartnerMapping = new Core_MDF_Partner_Mapping__c();
            priToActiPartnerMapping.Core_MDF_Primary_Partner_Account_id__c = eefPrimaryVirtualCorp.Id;
            priToActiPartnerMapping.Core_MDF_Activating_Partner_Account_id__c = eefActivatingVirtualCorp.Id;
            priToActiPartnerMapping.Core_MDF_Effective_Start_Date__c = System.today()-10;
            priToActiPartnerMapping.Core_MDF_Effective_End_Date__c = System.today()+10;
            priToActiPartnerMapping.Core_MDF_Channel_Program__c = eefCp.Id;
            insert priToActiPartnerMapping;
            
            PartnerMarketingBudget pbmEef = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget EEF', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, eefPrimaryVirtualCorp.Id, eefCp.Id, 30000, System.today()-30, System.today()+30, false);
            pbmEef.Core_MDF_Budget_Status__c = 'Released';
            pmbList.add(pbmEef);
            
            Database.insert(pmbList);
           // Highlight: Unused Local Variable - Indira
           // PartnerFundAllocation eefPFA = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test EEF PFA', pbmEef, eefActivatingVirtualCorp, 30000, true);
            Group extGrp = new Group();
            extGrp.name = 'Core_MDF_EEF_EXT';
            extGrp.DoesIncludeBosses = false;
            insert extGrp;
            Group eeFWWgrp = new Group();
            eeFWWgrp.Name = 'Core CCP EEF WW INTERNAL';
            eeFWWgrp.DeveloperName = 'Core_CCP_EEF_WW_Internal';
            insert eeFWWgrp;
            Group eeFASMOgrp = new Group();
            eeFASMOgrp.Name = 'Core CCP EEF ASMO INTERNAL';
            eeFASMOgrp.DeveloperName = 'Core_CCP_EEF_ASMO_Internal';
            insert eeFASMOgrp;
            
            // Creating Partner Group Mapping
            Core_MDF_Partner_Group_Mapping__c pgm = new Core_MDF_Partner_Group_Mapping__c();
            pgm.Core_MDF_Account__c = intelAcc.Id;
            pgm.Core_MDF_Group_Name__c = 'Core_CCP_EEF_External';
            pgm.Core_MDF_Type_of_Access__c = 'External';
            pgm.Core_MDF_Group_Id__c = intelAcc.Id;                
            pgm.Core_MDF_Channel_Program__c = eefCp.Id;
            Database.insert(pgm);
            Core_MDF_Partner_Group_Mapping__c pgm1 = new Core_MDF_Partner_Group_Mapping__c();
            pgm1.Core_MDF_Account__c = acc1.Id;
            pgm1.Core_MDF_Group_Name__c = 'Core_MDF_EEF_EXT';
            pgm1.Core_MDF_Type_of_Access__c = 'External';
            pgm1.Core_MDF_Group_Id__c = extGrp.Id;                
            pgm1.Core_MDF_Channel_Program__c = eefCp.Id;
            Database.insert(pgm1);
            
            Core_MDF_Partner_Group_Mapping__c asmoPGM = new Core_MDF_Partner_Group_Mapping__c();
            asmoPGM.Core_MDF_Account__c = intelAcc.Id;
            asmoPGM.Core_MDF_Group_Name__c = 'Core_CCP_EEF_ASMO_Internal';
            asmoPGM.Core_MDF_Type_of_Access__c = 'Internal';
            asmoPGM.Core_MDF_Region_cd__c = 'ASMO';
            asmoPGM.Core_MDF_BudgetType_nm__c = 'Cloud';
            asmoPGM.Core_MDF_Group_Id__c = eeFASMOgrp.Id;                
            asmoPGM.Core_MDF_Channel_Program__c = eefCp.Id;
            asmoPGM.Core_MDF_Source_Txt__c = 'Test';
            asmoPGM.Core_MDF_AccountIdGroupName__c = intelAcc.Id+'Core_CCP_EEF_ASMO_Internal';
            insert asmoPGM;
            
            Core_MDF_Partner_Group_Mapping__c wwPgm = new Core_MDF_Partner_Group_Mapping__c();
            wwPgm.Core_MDF_Account__c = intelAcc.Id;
            wwPgm.Core_MDF_Group_Name__c = 'Core_CCP_EEF_WW_Internal';
            wwPgm.Core_MDF_Type_of_Access__c = 'Internal';
            wwPgm.Core_MDF_Region_cd__c = 'WW';
            wwPgm.Core_MDF_Group_Id__c = eeFWWgrp.Id;                
            wwPgm.Core_MDF_Channel_Program__c = eefCp.Id;
            wwPgm.Core_MDF_Source_Txt__c = 'Test';
            wwPgm.Core_MDF_AccountIdGroupName__c = intelAcc.Id+'Core_CCP_EEF_WW_Internal';
            insert wwPgm;
            
            Core_MDF_Partner_Group_Mapping__c wwPgm1 = new Core_MDF_Partner_Group_Mapping__c();
            wwPgm1.Core_MDF_Account__c = acc1.Id;
            wwPgm1.Core_MDF_Group_Name__c = 'Core_CCP_EEF_WW_Internal';
            wwPgm1.Core_MDF_Type_of_Access__c = 'Internal';
            wwPgm1.Core_MDF_Region_cd__c = 'WW';
            wwPgm1.Core_MDF_BudgetType_nm__c = 'Cloud';
            wwPgm1.Core_MDF_Group_Id__c = eeFWWgrp.Id;                
            wwPgm1.Core_MDF_Channel_Program__c = eefCp.Id;
            wwPgm1.Core_MDF_Source_Txt__c = 'Test';
            wwPgm1.Core_MDF_AccountIdGroupName__c = intelAcc.Id+'Core_CCP_EEF_WW_Internal';
            insert wwPgm1;

            
            List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmLst = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm1 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgm1.RecordTypeId =  iupgm_Recordtype_EEF;
            iupgm1.Core_MDF_Program_nm__c = 'Ecosystem Extension Fund';
            iupgm1.Core_MDF_Region_Sub_Region_nm__c = 'WW';
            iupgm1.Core_MDF_User_id__c =  usr.Id;
            iupgm1.Core_MDF_All_Budget_Type_Access_Ind__c = true;
            iupgm1.Core_MDF_All_Accounts_cd__c = 'No';
            iupgm1.Core_MDF_Account_id__c = intelAcc.Id;
            iupgm1.Core_MDF_Role_nm__c='Core_MDF_Internal_EEF_Primary_Partner_Acct_Mgr';
            iupgm1.Core_MDF_Channel_Program_id__c = eefCp.Id;
            iupgmLst.add(iupgm1);
            insert iupgmLst;
            
            Campaign eefCamp = new Campaign();
            eefCamp.RecordTypeId = campaign_RecordType_EEF;
            eefCamp.Core_MDF_Program__c = 'Ecosystem Extension Fund';
            eefCamp.Name = 'Campaign EEF Campaign';
            eefCamp.Description = 'Test';
            eefCamp.Core_MDF_Account__c = eefPrimaryVirtualCorp.Id;
            eefCamp.Core_MDF_Partner_Mapping_Txt__c = eefActivatingVirtualCorp.Id;
            eefCamp.StartDate = System.today();
            eefCamp.EndDate = System.today()+5;
            eefCamp.Core_MDF_External_Visibility_Date__c = System.today();
            eefCamp.Core_MDF_Opal_Budget_Type_Txt__c = 'Cloud';
            eefCamp.Core_MDF_Total_Campaign_Cost_Amt__c = 10000;
            eefCamp.Core_MDF_CSP_Intel_Based_Revenue_Amt__c = 1000;
            eefCamp.Core_MDF_Priority__c = 'Enterprise AI';
            eefCamp.Core_MDF_Market__c = 'AFGHANISTAN';
            eefCamp.Core_MDF_Audience__c = 'C-Suite';
            eefCamp.Core_MDF_Product_Type__c = 'Cloud Instance Consumption';
            eefCamp.Core_MDF_Brand__c = 'Intel® SGX';
            eefCamp.Core_MDF_Industry_Nm__c = 'Accommodation and Food Services';
            eefCamp.Core_MDF_Activity_Category__c = 'Broadcast';
            eefCamp.Core_MDF_Activity_Type__c = 'Radio';
            eefCamp.Core_MDF_Supports_legacy_program__c = 'MDF or both CMP & MDF';
            insert eefCamp;
            
            Core_MDF_Camp_to_ActPartner__c camptoActPtr = new Core_MDF_Camp_to_ActPartner__c();
            camptoActPtr.Core_MDF_Activating_Partner_Account_id__c = eefActivatingVirtualCorp.Id;
            camptoActPtr.Core_MDF_Channel_Program__c = eefCp.Id;
            camptoActPtr.Core_MDF_Campaign_Id__c = eefCamp.Id;
            camptoActPtr.Core_MDF_Reimbursement_Rate_pct__c = '100%';
            camptoActPtr.Core_MDF_Active_Ind__c = true;
            insert camptoActPtr;
        }
        
        Test.stopTest();
    }
    
    @isTest static void testSchedulerMethod()
    {  
        User usr1 = [SELECT Id FROM User WHERE LastName = 'TestClass TestUser' LIMIT 50000];
        
        System.runAs(usr1){
            Campaign cmp = [SELECT Id, Name FROM Campaign WHERE Name ='Campaign EEF Campaign' LIMIT 1];
             Assert.areEqual(cmp.Name,'Campaign EEF Campaign');
            
            String cronExp = '0 0 * ? * * *';
            Test.startTest();
            // Highlight: Unused Local Variable - Indira
           // String shareCamp = System.schedule('Test Campaign Share', cronExp, new Core_MDF_BatchSharecmpSchedule());
            List<Id> grpIdList= new List<Id>();
            
            for(CampaignShare shareList : [SELECT Id, CampaignId, UserOrGroupId FROM CampaignShare WHERE CampaignId =: cmp.Id LIMIT 50000 ]){
                grpIdList.add(string.valueof(shareList.UserOrGroupId));
            }
            // Highlight: Unused Local Variable - Indira
           // String json = '{"inputStrquery":"SELECT Id, Name, Type, RecordTypeId, Status, StartDate, EndDate,IsActive, OwnerId, Core_MDF_External_Visibility_Date__c,Core_MDF_Program__c, Core_MDF_Account__c,Core_MDF_Channel_Program__c FROM Campaign WHERE Core_MDF_External_Visibility_Date__c >= LAST_N_DAYS:5 AND Core_MDF_External_Visibility_Date__c <= TODAY AND RecordType.DeveloperName IN: recTypeDeveloperName"}';
            
            //Core_MDF_BatchShareCampVisibility.generateInstance(json,'Core_MDF_BatchShareCampVisibility (String inputStrquery)');
            Test.stopTest();
        }
    }
    @isTest static void unshareCampToActPartTest(){
        User usr1 = [SELECT Id FROM User WHERE LastName = 'TestClass TestUser' LIMIT 50000];
        System.runAs(usr1){
            Campaign cmp = [SELECT Id, Name, Core_MDF_Region_cd__c FROM Campaign WHERE Name ='Campaign EEF Campaign' LIMIT 1];
            Core_MDF_Camp_to_ActPartner__c campToActPartner = [Select Id,Core_MDF_Active_Ind__c from Core_MDF_Camp_to_ActPartner__c where Core_MDF_Campaign_Id__c =: cmp.Id];
            campToActPartner.Core_MDF_Active_Ind__c = false;
            update campToActPartner;
            List<Id> mappingSharetobeDeleted = new List<Id>();
            mappingSharetobeDeleted.add(campToActPartner.Id);
            Core_MDF_CampActPartnerServiceHandler.unShareCampActPartner(mappingSharetobeDeleted);
            Assert.areEqual(campToActPartner.Core_MDF_Active_Ind__c,false);
            campToActPartner.Core_MDF_Active_Ind__c = true;
            update campToActPartner;
            cmp.Core_MDF_Region_cd__c = 'APJ;ASMO';
            update cmp;
        }
    }
    
    @isTest static void testShareUnshareCampActPartner() {
        User usr1 = [SELECT Id FROM User WHERE LastName = 'TestClass TestUser' LIMIT 50000];
        System.runAs(usr1){
            Campaign cmp = [SELECT Id, Name, Core_MDF_Region_cd__c FROM Campaign WHERE Name ='Campaign EEF Campaign' LIMIT 1];
            Core_MDF_Camp_to_ActPartner__c campToActPartner = [Select Id,Core_MDF_Active_Ind__c from Core_MDF_Camp_to_ActPartner__c where Core_MDF_Campaign_Id__c =: cmp.Id];
            List<Core_MDF_CampActPartnerServiceHandler.InitialInputs> inpList = new List<Core_MDF_CampActPartnerServiceHandler.InitialInputs>();
            Core_MDF_CampActPartnerServiceHandler.InitialInputs inp1 = new Core_MDF_CampActPartnerServiceHandler.InitialInputs();
            inp1.campToActPartner = campToActPartner;
            inp1.mode = 'Share';
            inpList.add(inp1);
            Core_MDF_CampActPartnerServiceHandler.shareUnshareCamptoActPartner(inpList);
            // Unit Test Method should include System.Assert - Indira
            System.assertNotEquals(null, campToActPartner.Id, 'Campaign to Act Partner should exist');
        }
    }
    
    //test eef related methods from campaign create page apex class
    @isTest
    static void testFetchCampToActPartnerData() {
        User usr1 = [SELECT Id FROM User WHERE LastName = 'TestClass TestUser' LIMIT 50000];
        System.runAs(usr1){
            Campaign cmp = [SELECT Id, Name, Core_MDF_Region_cd__c FROM Campaign WHERE Name ='Campaign EEF Campaign' LIMIT 1];
            //sucess scenario
            Core_MDF_CampaignCreatePage.fetchCampToActPartnerData(cmp.Id);
            // Unit Test Method should include System.Assert - Indira
            System.assertEquals('Campaign EEF Campaign', cmp.Name, 'Campaign name should match');
        }
        
    }
    
    @isTest
    static void testGetSIOrISVAccounts() {
        User usr1 = [SELECT Id FROM User WHERE LastName = 'TestClass TestUser' LIMIT 50000];
        System.runAs(usr1){
            Account acc = [Select Id,Core_MDF_Partner_Type_nm__c from Account where Core_MDF_Partner_Type_nm__c = 'Primary Partner'];
            Core_MDF_CampaignCreatePage.getSIOrISVAccounts(acc.Id);
            // Unit Test Method should include System.Assert - Indira
            System.assertEquals('Primary Partner', acc.Core_MDF_Partner_Type_nm__c, 'Account partner type should be Primary Partner');
        }
    }
        
        @isTest
        static void testGetPartnerAccList() {
            User usr1 = [SELECT Id FROM User WHERE LastName = 'TestClass TestUser' LIMIT 50000];
            List<Account> acc = [Select Id from Account where Core_MDF_Partner_Type_nm__c in ('Primary Partner','Activating Partner')];
            String accIds = acc[0].Id+';'+acc[1].Id;
            System.runAs(usr1){
                Core_MDF_CampaignCreatePage.getPartnerAccList(acc[0].Id);
                Core_MDF_CampaignCreatePage.getPartnerAccList(accIds);
             // Unit Test Method should include System.Assert - Indira
            System.assert(acc.size() >= 2, 'Should have at least 2 accounts');
            }
    }
    
    @isTest
    static void testSaveCampToISVMapping() {
        User usr1 = [SELECT Id FROM User WHERE LastName = 'TestClass TestUser' LIMIT 50000];
        System.runAs(usr1){
            Campaign cmp = [SELECT Id, Name, Core_MDF_Region_cd__c,Core_MDF_Partner_Mapping_Txt__c FROM Campaign WHERE Name ='Campaign EEF Campaign' LIMIT 1];
            Core_MDF_CampaignCreatePage.saveCampToISVMapping(cmp);
            // Unit Test Method should include System.Assert - Indira
         System.assertNotEquals(null, cmp.Id, 'Campaign should exist');
        }
    }
    
    @isTest
    static void testSearch() {
        User usr1 = [SELECT Id FROM User WHERE LastName = 'User Test1' LIMIT 50000];
        Campaign cmp = [SELECT Id, Name, Core_MDF_Region_cd__c,Core_MDF_Partner_Mapping_Txt__c FROM Campaign WHERE Name ='Campaign EEF Campaign' LIMIT 1];
        System.runAs(usr1){
            String filter='Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c = \'Ecosystem Extension Fund\''  ;
            List<sObject> campaignListQuery = new List<sObject>();
            campaignListQuery=Core_MDF_CampaignCreatePage.search('Campaign EEF Campaign','Account',filter, false);
            assert.areEqual(false,campaignListQuery.equals(cmp),'Assert Passed');
        }
    }
    
    //Core_MDF_ProcessCamp_RelatedRecords - EEF
    @isTest
    static void testInsertUpdateActivatingPartnerMap1() {
      User usr1 = [SELECT Id FROM User WHERE LastName = 'User Test1' LIMIT 50000];
      Campaign testCampaign = [SELECT Id, Name, Core_MDF_Region_cd__c,Core_MDF_Partner_Mapping_Txt__c, Core_MDF_Program__c FROM Campaign WHERE Name ='Campaign EEF Campaign' LIMIT 1];
      List<Campaign> newCampaignList = new List<Campaign>{testCampaign};

        Map<Id, Campaign> oldCampaignMap = new Map<Id, Campaign>();
        System.runAs(usr1){
        Test.startTest();
        Core_MDF_ProcessCamp_RelatedRecords.insertUpdateActivatingPartnerMap(newCampaignList, oldCampaignMap, true, false);
        oldCampaignMap.put(testCampaign.Id, testCampaign);
        Core_MDF_ProcessCamp_RelatedRecords.insertUpdateActivatingPartnerMap(newCampaignList, oldCampaignMap, false, true);
        Test.stopTest();
        }
       	List<Core_MDF_Camp_to_ActPartner__c> actPartnerRecords = [SELECT Id, Core_MDF_Campaign_Id__c, Core_MDF_Activating_Partner_Account_id__c, Core_MDF_Active_Ind__c 
                                                                  FROM Core_MDF_Camp_to_ActPartner__c WHERE Core_MDF_Campaign_Id__c = :testCampaign.Id];
        System.assertEquals(1, actPartnerRecords.size());
    }
}