/****************************************************************************************************************************************
* Class Name  : Core_MDF_BatchShareCampVisibility_Test 
* Version     : 1.0 
* Created Date: 8-13-2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Harika P        8/17/2018          Created to test Batch class to periodically share Campaign records based on Member visibility date
* Intel - NP(11630236)		  27/08/2019         Created list to update common objects instead of individual inserts	
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
private class Core_MDF_BatchShareCampVisibility_Test 
{
/****************************************************************************************************************************************
    Method Name:                                             createTestData
    Description:                                             Creating Test data for Batch Class.
    Added By:                                                Accenture – Harika P  -  8/17/2018
    Modified By:                  Date:                      Changes: 
    Accenture – Harika P          8/17/2018                  Created.
*****************************************************************************************************************************************/    
    @TestSetup static void createTestData() 
    {   
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
        
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 50000];
        List<Account> accList = new List<Account>(); List<Contact> conList = new List<Contact>();List<User> userList= new List<User>();
        Test.startTest(); 
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'MDF Budget Loader';
        usr.profileId = systemAdminProfile.Id;
        Database.insert(usr);

        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName = 'User Test1';
        usr1.UserRoleId = usRole.Id;
        usr1.profileId = systemAdminProfile.Id;
        System.runAS(usr){
        Database.insert(usr1);
        }
        
        
        ChannelProgram eefCp = Core_MDF_CCP_TestDataUtility.createProgram('Ecosystem Extension Fund','Ecosystem Extension Fund', true);
        
        Id campaign_RecordType_EEF = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Ecosystem_Extension_Fund').getRecordTypeId();
        // Creating Account with utility class
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 2', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        
        Account intelAcc = Core_MDF_CCP_TestDataUtility.createIntelAccount('Intel Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        
        Account eefPrimaryVirtualCorp = Core_MDF_CCP_TestDataUtility.createAccount ('EEF Primary Virtual Corp', eefCp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);                           
		eefPrimaryVirtualCorp.Core_MDF_Parent_Fund_Account__c = intelAcc.Id;
        eefPrimaryVirtualCorp.Core_MDF_Partner_Type_nm__c ='Primary Partner';
		insert eefPrimaryVirtualCorp;
        
        Account eefActivatingVirtualCorp = Core_MDF_CCP_TestDataUtility.createAccount ('EEF Activating Virtual Corp', eefCp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);                           
		eefActivatingVirtualCorp.Core_MDF_Parent_Fund_Account__c = acc1.Id;
        eefActivatingVirtualCorp.Core_MDF_Partner_Type_nm__c ='Activating Partner';
		insert eefActivatingVirtualCorp;
        Account eefActivatingVirtualCorp2 = Core_MDF_CCP_TestDataUtility.createAccount ('EEF Activating Virtual Corp', eefCp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);                           
		eefActivatingVirtualCorp2.Core_MDF_Parent_Fund_Account__c = acc1.Id;
        eefActivatingVirtualCorp2.Core_MDF_Partner_Type_nm__c ='Activating Partner';
		insert eefActivatingVirtualCorp2;
        System.runAs(usr){
            PermissionSet eefBudLoader = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_Internal_EEF_Budget_Loader' LIMIT 1];
		    insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = eefBudLoader.Id);
             PermissionSet eefBudManager = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_Internal_EEF_Budget_Manager' LIMIT 1];
		    insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = eefBudManager.Id);
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
            PartnerFundAllocation eefPFA = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test EEF PFA', pbmEef, eefActivatingVirtualCorp, 30000, true);
            
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
             Core_MDF_Camp_to_ActPartner__c camptoActPtr2 = new Core_MDF_Camp_to_ActPartner__c();
            camptoActPtr2.Core_MDF_Activating_Partner_Account_id__c = eefActivatingVirtualCorp2.Id;
                camptoActPtr2.Core_MDF_Channel_Program__c = eefCp.Id;
                camptoActPtr2.Core_MDF_Campaign_Id__c = eefCamp.Id;
                camptoActPtr2.Core_MDF_Reimbursement_Rate_pct__c = '100%';
                camptoActPtr2.Core_MDF_Active_Ind__c = true;
            insert camptoActPtr2;
            camptoActPtr2.Core_MDF_Active_Ind__c = false;
            update camptoActPtr2;
            //List<Core_MDF_Camp_to_ActPartner__c> camToActList = new List<Core_MDF_Camp_to_ActPartner__c>();
            //camToActList.add(camptoActPtr);
           // Core_MDF_CampActPartnerServiceHandler.unShareCampActPartner(camToActList);
        }
        Test.stopTest();
        System.runAs(usr1){
            // Creating channel program with utility class
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Datacenter','Data Center CoMarketing Fund', true);
            ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Client','Client CoMarketing Fund', true);
            
            // Creating IntelAccount with utility class
            Account intAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', 
                                                                              Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type,false);
            intAccount.Core_Account_Type__c = 'Reseller';
            //intAcc.Core_Sales_Groups__c = 'Automotive Sales Group';
            intAccount.Industry = 'Food & Beverage';
            Database.insert(intAccount);
            
            // Creating Co-marketing Account with utility class
            Account dcfAcc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing DCF Test Account', 
                                                                         cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            dcfAcc.Core_MDF_Parent_Fund_Account__c = intAccount.Id;
            accList.add(dcfAcc);
            Account ccfAcc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing CCF Test Account', 
                                                                         cp1.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            ccfAcc.Core_MDF_Parent_Fund_Account__c = intAccount.Id;
            accList.add(ccfAcc);
            Database.insert(accList);
            
            // Creating Contact with utility class
            Contact con = Core_MDF_CCP_TestDataUtility.createContact (intAccount.Id, false);
            con.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            conList.add(con);
            Contact con1 = Core_MDF_CCP_TestDataUtility.createContact (intAccount.Id, false);
            con1.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            conList.add(con1);
            Database.insert(conList);
            
            Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 50000];
            
            // Creating User with utility class 
            User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr2.LastName = 'User Test2';
            usr2.ProfileId = partnerProfile.Id;
            usr2.ContactId = con.Id;
            userList.add(usr2);        
            User usr3 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr3.LastName = 'User Test3';
            usr3.ProfileId = partnerProfile.Id;
            usr3.ContactId = con1.Id;
            userList.add(usr3);
            Database.insert(userList);
            
            // Creating Group
            Group dcfGrp = new Group();
            dcfGrp.Name = 'Core CCP DCF External';
            dcfGrp.DeveloperName = 'Core_CCP_DCF_External';
            Database.insert(dcfGrp);
            Group ccfGrp = new Group();
            ccfGrp.Name = 'Core CCP CCF External';
            ccfGrp.DeveloperName = 'Core_CCP_CCF_External';
            Database.insert(ccfGrp);
            
            // Creating Group Member
            GroupMember dcfGrpMem = new GroupMember();
            dcfGrpMem.UserOrGroupId = usr2.Id;
            dcfGrpMem.GroupId = dcfGrp.Id;
            Database.insert(dcfGrpMem);
            GroupMember ccfGrpMem = new GroupMember();
            ccfGrpMem.UserOrGroupId = usr3.Id;
            ccfGrpMem.GroupId = ccfGrp.Id;
            Database.insert(ccfGrpMem);
            
            // Creating Partner Group Mapping
            Core_MDF_Partner_Group_Mapping__c pgm = new Core_MDF_Partner_Group_Mapping__c();
            pgm.Core_MDF_Account__c = intAccount.Id;
            pgm.Core_MDF_Group_Name__c = 'Core_CCP_DCF_External';
            pgm.Core_MDF_Type_of_Access__c = 'External';
            pgm.Core_MDF_Group_Id__c = dcfGrp.Id;                
            pgm.Core_MDF_Channel_Program__c = cp.Id;
            Database.insert(pgm);
            Core_MDF_Partner_Group_Mapping__c pgm1 = new Core_MDF_Partner_Group_Mapping__c();
            pgm1.Core_MDF_Account__c = intAccount.Id;
            pgm1.Core_MDF_Group_Name__c = 'Core_CCP_CCF_External';
            pgm1.Core_MDF_Type_of_Access__c = 'External';
            pgm1.Core_MDF_Group_Id__c = ccfGrp.Id;                
            pgm1.Core_MDF_Channel_Program__c = cp1.Id;
            Database.insert(pgm1);
            
            //Creating Campaign
            Campaign campc1 = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 1','Reseller','Intel® Corporate Logo','Yes', 
                              Core_MDF_CCP_TestDataUtility.Campaign_RecordType_DCF, 'Data Center CoMarketing Fund',System.today().addDays(5) , 
                              System.today().addYears(1), 5000, 'Hybrid Cloud', dcfAcc.Id,'Server', false);
            campc1.Core_MDF_External_Visibility_Date__c = System.today();
           // Database.insert(campc1);       
            
        }  
    }    
/****************************************************************************************************************************************
    Method Name:                                             testSchedulerMethod
    Description:                                             Testing the Batch Sharing and Unsharing Functionality based on Member Visibility Date.
    Added By:                                                Accenture – Harika P  -  09/13/2018
    Modified By:                  Date:                      Changes: 
    Accenture – Harika P          09/13/2018                 Created.
*****************************************************************************************************************************************/
    @isTest static void testSchedulerMethod()
    {  
        User usr1 = [SELECT Id FROM User WHERE LastName = 'User Test1' LIMIT 50000];
        
        System.runAs(usr1){
            List<Group> dcfGrp = [SELECT Id FROM Group WHERE Name ='Core CCP DCF External' LIMIT 50000];
            List<Group> ccfGrp = [SELECT Id FROM Group WHERE Name ='Core CCP CCF External' LIMIT 50000];
            Campaign cmp = [SELECT Id, Name FROM Campaign WHERE Name ='Campaign EEF Campaign' LIMIT 1];
            //Campaign cmp1 = [SELECT Id, Name FROM Campaign WHERE Name ='Test Camp 1' LIMIT 1];
            List<Campaign> cmpList = new List<Campaign>();
            cmpList.add(cmp);
            //cmpList.add(cmp1);
            String cronExp = '0 0 * ? * * *';
            Test.startTest();
            String shareCamp = System.schedule('Test Campaign Share', cronExp, new Core_MDF_BatchSharecmpSchedule());
            List<Id> grpIdList= new List<Id>();
            
            for(CampaignShare shareList : [SELECT Id, CampaignId, UserOrGroupId FROM CampaignShare WHERE CampaignId IN: cmpList LIMIT 50000 ]){
                grpIdList.add(string.valueof(shareList.UserOrGroupId));
            }
            //String json = '{"inputStrquery":"SELECT Id, Name, Type, RecordTypeId, Status, StartDate, EndDate,IsActive, OwnerId, Core_MDF_External_Visibility_Date__c,Core_MDF_Program__c, Core_MDF_Account__c,Core_MDF_Channel_Program__c FROM Campaign WHERE Core_MDF_External_Visibility_Date__c >= LAST_N_DAYS:5 AND Core_MDF_External_Visibility_Date__c <= TODAY AND RecordType.DeveloperName IN: recTypeDeveloperName"}';
            
            //Core_MDF_BatchShareCampVisibility.generateInstance(json,'Core_MDF_BatchShareCampVisibility (String inputStrquery)');
            Test.stopTest();
            //assert.isTrue(grpIdList.contains(dcfGrp[0].Id));
            //assert.isFalse(grpIdList.contains(ccfGrp[0].Id));
        } 
        
        
    }
    
    
}