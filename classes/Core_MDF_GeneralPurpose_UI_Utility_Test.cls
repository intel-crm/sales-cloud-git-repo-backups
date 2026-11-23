@IsTest(seeAllData=false)
public class Core_MDF_GeneralPurpose_UI_Utility_Test{
    public static Id CCF_RecordType = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Client_Co_Marketing_Fund').getRecordTypeId();
     public static Id DCF_RecordType = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Data_Center_Co_Marketing_Fund').getRecordTypeId();
     Public static Id IPA_RecordType = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
     public static Id CMDF_RecordType = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Channel_MDF').getRecordTypeId();
     public static Id RMF_RecordType = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
     public static Id EEF_RecordType = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Ecosystem_Extension_Fund').getRecordTypeId();
    
    @TestSetup
    static void createTestData(){
        User testUser = Core_MDF_CCP_TestDataUtility.createUser(false); 
         UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        testUser.LastName='Admin_user';
        testUser.UserRoleId = usRole.Id;
        insert testUser;
        System.runAs(testUser){
            //Test.startTest();
            List<String> bypassFunctionKeys = new List<String>();
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            bypassFunctionKeys.add('ShareActivityWithInternalUsers_Bypass');
            bypassFunctionKeys.add('byPassShareUnshareCampaignRecord');
            bypassFunctionKeys.add('byPassCampaignAndRelatedRecords');
            bypassFunctionKeys.add('Bypass_Duplicate_Budget_Check');
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            ChannelProgram ccfCp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
            ChannelProgram dcfCp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.DCF_PROGRAM,'Data Center CoMarketing Fund', true);
            ChannelProgram ipaCP = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', true);
            
            Account ccpIntelAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('CCP Test Intel Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);  
            Database.insert(ccpIntelAccount);
            List<Account> accountList = new List<Account>();
            Account ccfacc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing CCF Test Account', 
                                                                         ccfCp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            ccfacc.Core_MDF_Parent_Fund_Account__c = ccpIntelAccount.Id;
            accountList.add(ccfacc);
            Account dcfacc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing DCF Test Account', 
                                                                         dcfCp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            dcfacc.Core_MDF_Parent_Fund_Account__c = ccpIntelAccount.Id;
            
            Account acc6 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 3', ipaCP.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, ccpIntelAccount.Id, false);
            
            accountList.add(dcfacc);
            accountList.add(acc6);
            Database.insert(accountList);
            
            Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(ccpIntelAccount.Id,true);
            conRecord1.Core_Audience_List__c='IPA User';
            update conRecord1;
            
            Core_AGS_Role__c agsRoleCCF = Core_MDF_CCP_TestDataUtility.createAgsRole('IPA_MDF_USER', 'Co-Marketing(Salesforce)-IPA MDF USER', true, false);
            Core_ERPM_Engagement__c erpmEngagementIPA = Core_MDF_CCP_TestDataUtility.createErpmEngagement('IPA', 'IPA', 'DEDUPB2B', 'SEC', true, false);
            Database.insert(erpmEngagementIPA);
            Core_Entitlement__c entitlementIPA = Core_MDF_CCP_TestDataUtility.createEntitlement('IPA MDF User',agsRoleCCF.Id ,'Intel® Partner Investment Center','IPA MDF User',erpmEngagementIPA.Id , true,'Solutions Marketplace',false);
            Database.insert(entitlementIPA); 
            Core_Contact_Entitlement__c contactEntitlementIPA = Core_MDF_CCP_TestDataUtility.createContactEntitlement(conRecord1.Id,entitlementIPA.Id ,true,'Complete', false);
            Database.insert(contactEntitlementIPA); 
            Group ccfgrp = new Group();
            ccfgrp.Name = 'CCP TESTACCTTEMP CCF EMEA INTERNAL';
            ccfgrp.DeveloperName = 'Core_MDF_CCP_TESTACCTTEMP_CCF_EMEA_INTERNAL';
            Database.insert(ccfgrp);
            
            Core_MDF_Partner_Group_Mapping__c ccfPgm = new Core_MDF_Partner_Group_Mapping__c();
            ccfPgm.Core_MDF_Account__c =ccpIntelAccount.Id;
            ccfPgm.Core_MDF_Group_Name__c = 'Core_MDF_CCP_TESTACCTTEMP_CCF_EMEA_INTERNAL';
            ccfPgm.Core_MDF_Type_of_Access__c = 'Internal';           
            ccfPgm.Core_MDF_Channel_Program__c = ccfCp.Id;
            ccfPgm.Core_MDF_Region_cd__c = 'EMEA';
            ccfPgm.Core_MDF_Source_Txt__c = 'Test';            
            Database.insert(ccfPgm);
            
            Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name = 'CCP - Core Access'];
            Set<String> psNameSet = new Set<String> ();
            Map<string,String>  psNameVsIdMap = new Map<string,String>();
            psNameSet.add('Core_MDF_CCP_Internal_CCF_Acct_Mgr');
            psNameSet.add('Core_MDF_CCP_Internal_DCF_Acct_Mgr');
            psNameSet.add('Core_MDF_CCP_Internal_Price_Reviewer');
            psNameSet.add('Core_MDF_CCP_Internal_IPA_Acct_Mgr');
            psNameSet.add('Core_MDF_CCP_External_Activity_Submitter');
            psNameSet.add('Core_MDF_CCP_Int_IPA_ProposalL1_Approver');
            psNameSet.add('Core_MDF_CCP_Internal_Proposal_Activity_L2_Approver');
            psNameVsIdMap = getPermissionSetIdbyName(psNameSet);
            String ccfAccManagerPS =  psNameVsIdMap.get('Core_MDF_CCP_Internal_CCF_Acct_Mgr');
            String dcfAccManagerPS =  psNameVsIdMap.get('Core_MDF_CCP_Internal_DCF_Acct_Mgr');
            String priceReviewerPS =  psNameVsIdMap.get('Core_MDF_CCP_Internal_Price_Reviewer');
            String psIPA =  psNameVsIdMap.get('Core_MDF_CCP_Internal_IPA_Acct_Mgr');
            String psExt =  psNameVsIdMap.get('Core_MDF_CCP_External_Activity_Submitter');
            String psIpaL1 =  psNameVsIdMap.get('Core_MDF_CCP_Int_IPA_ProposalL1_Approver');
            String psIpaL2 =  psNameVsIdMap.get('Core_MDF_CCP_Internal_Proposal_Activity_L2_Approver');
            
            List<User> userList = new List<User>();
            User dcfAccountManager = Core_MDF_CCP_TestDataUtility.createUser(false);
            dcfAccountManager.profileId = ccpCoreProfile.Id;
            dcfAccountManager.LastName = 'DCF Acc Manager';
            userList.add(dcfAccountManager);
            
            User ccfAccountManager = Core_MDF_CCP_TestDataUtility.createUser(false);
            ccfAccountManager.profileId = ccpCoreProfile.Id;
            ccfAccountManager.LastName = 'CCF Acc Manager';
            userList.add(ccfAccountManager);
            
            User priceRev = Core_MDF_CCP_TestDataUtility.createUser(false);
            priceRev.profileId = ccpCoreProfile.Id;
            priceRev.LastName = 'Price Reviewer';
            userList.add(priceRev);
            
            User ActSubmitter= Core_MDF_CCP_TestDataUtility.createUser(false);
            ActSubmitter.profileId = ccpCoreProfile.Id;
            ActSubmitter.LastName = 'Activity submitter';
            userList.add(ActSubmitter);
            
            Database.insert(userList);
            Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' limit 1];
            User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);   
            UserRole ur = [Select Id, Name From UserRole where PortalType ='Partner' limit 1];
             usr1.Email='test1@example.com';
            usr1.ContactId = conRecord1.Id;
            usr1.ProfileId = partnerProfile.id;
            usr1.isActive = true;
            Database.insert(usr1);
            Group grp1 = new Group();
            grp1.Name = 'Core_MDF_CCP_External';
            grp1.DeveloperName = 'Core_MDF_CCP_External';  
            Database.insert(grp1);
            GroupMember grpMember = new GroupMember();
            grpMember.UserOrGroupId = usr1.Id;
            grpMember.GroupId = grp1.Id;
            insert grpMember;
            Core_MDF_Partner_Node_User_Mapping__c pnum = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(acc6.Id,usr1.Id,true);
            List<PermissionSetAssignment> permissionSetAssignmentList = new List<PermissionSetAssignment>();
            
           
            permissionSetAssignmentList.add(new PermissionSetAssignment(AssigneeId = ccfAccountManager.id, PermissionSetId =ccfAccManagerPS));   
            permissionSetAssignmentList.add(new PermissionSetAssignment(AssigneeId = dcfAccountManager.id, PermissionSetId =dcfAccManagerPS));
            permissionSetAssignmentList.add(new PermissionSetAssignment(AssigneeId = priceRev.id, PermissionSetId =priceReviewerPS));
            permissionSetAssignmentList.add(new PermissionSetAssignment(AssigneeId = priceRev.id, PermissionSetId =psIPA));
            permissionSetAssignmentList.add(new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId =psExt));
            permissionSetAssignmentList.add(new PermissionSetAssignment(AssigneeId = priceRev.id, PermissionSetId =psIpaL1));
            permissionSetAssignmentList.add(new PermissionSetAssignment(AssigneeId = priceRev.id, PermissionSetId =psIpaL2));
            
            Database.insert(permissionSetAssignmentList);
              List<Campaign> cmpList=new List<Campaign>();
            
            Campaign ipaCampaignForAP = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - AP',acc6.id, System.today(), System.today().adddays(30),null, 110000,'INDIA', 'Developer', 'Apollo Lake', 'Pending Approval', false);
            ipaCampaignForAP.Core_MDF_Region_cd__c = 'APJ';
            ipaCampaignForAP.Core_MDF_Opal_Budget_Type_Txt__c ='Account Plan';
            ipaCampaignForAP.Core_MDF_Proposal_Based_Ind__c = false;
            ipaCampaignForAP.Core_MDF_Budget_Type_txt__c = 'Account Plan';
            ipaCampaignForAP.Core_MDF_Approval_Stage_nm__c='L2 Regional Marketing';
            cmpList.add(ipaCampaignForAP) ;   
            
            Campaign ipaCampaignForAPsales = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - AP1',acc6.id, System.today(), System.today().adddays(30),null, 110000,'INDIA', 'Developer', 'Apollo Lake', 'Pending Approval', false);
            ipaCampaignForAPsales.Core_MDF_Region_cd__c = 'APJ';
            ipaCampaignForAPsales.Core_MDF_Opal_Budget_Type_Txt__c ='Account Plan';
            ipaCampaignForAPsales.Core_MDF_Proposal_Based_Ind__c = false;
            ipaCampaignForAPsales.Core_MDF_Budget_Type_txt__c = 'Account Plan';
            ipaCampaignForAPsales.Core_MDF_Approval_Stage_nm__c='L2 Regional Sales';
            cmpList.add(ipaCampaignForAPsales) ;
            
             Campaign ipaCampaignForAP1 = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - AP2',acc6.id, System.today(), System.today().adddays(30),null, 110000,'INDIA', 'Developer', 'Apollo Lake', 'Pending Approval', false);
            ipaCampaignForAP1.Core_MDF_Region_cd__c = 'APJ';
            ipaCampaignForAP1.Core_MDF_Opal_Budget_Type_Txt__c ='Account Plan';
            ipaCampaignForAP1.Core_MDF_Proposal_Based_Ind__c = false;
            ipaCampaignForAP1.Core_MDF_Budget_Type_txt__c = 'Account Plan';
            
            cmpList.add(ipaCampaignForAP1) ;
             Database.insert(cmpList);
            
            List<PartnerFundRequest> pfrList=new List<PartnerFundRequest>();
            PartnerFundRequest ipaPFR5 = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaignForAP.id,acc6.id,System.today().addDays(1),System.today().addDays(10),false);
            ipaPFR5.Title='Test Activity1';
            ipaPFR5.Core_MDF_Approval_Stage__c = 'Price Reviewer';
            ipaPFR5.Core_MDF_Region_nm__c='APJ';
            pfrList.add(ipaPFR5);
            
            PartnerFundRequest ipaPFR6 = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaignForAP.id,acc6.id,System.today().addDays(1),System.today().addDays(10),false);
            ipaPFR6.Title='Test Activity2';
            ipaPFR6.Core_MDF_Approval_Stage__c = 'L2 Regional Sales';
            ipaPFR6.Core_MDF_Region_nm__c='APJ';
            pfrList.add(ipaPFR6);
            
            PartnerFundRequest ipaPFR7 = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaignForAP.id,acc6.id,System.today().addDays(1),System.today().addDays(10),false);
            ipaPFR7.Title='Test Activity3';
            ipaPFR7.Core_MDF_Approval_Stage__c = 'L2 Regional Marketing';
            ipaPFR7.recordtypeid=Core_MDF_CCP_IPA_TestDataUtility.partnerFund_RecordType_IPA;
            ipaPFR7.Core_MDF_Region_nm__c='APJ';
            pfrList.add(ipaPFR7);
            Database.insert(pfrList);
            //Test.stopTest();
            Test.starttest();
            List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
            Core_MDF_Int_Users_Partner_Geo_Mapping__c ccfiupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            ccfiupgm.RecordTypeId = CCF_RecordType;
            ccfiupgm.Core_MDF_Account_id__c = ccpIntelAccount.Id;
            ccfiupgm.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
            ccfiupgm.Core_MDF_Region_Sub_Region_nm__c = 'EMEA';
            ccfiupgm.Core_MDF_User_id__c = ccfAccountManager.Id;
            ccfiupgm.Core_MDF_All_Accounts_cd__c = 'No';
            ccfiupgm.Core_MDF_Role_nm__c='Core_MDF_CCP_Internal_CCF_Acct_Mgr';
            iupgmList.add(ccfiupgm);
            
            Core_MDF_Int_Users_Partner_Geo_Mapping__c dcfiupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            dcfiupgm.RecordTypeId = DCF_RecordType;
            dcfiupgm.Core_MDF_Account_id__c = ccpIntelAccount.Id;
            dcfiupgm.Core_MDF_Program_nm__c = 'Data Center CoMarketing Fund';
            dcfiupgm.Core_MDF_Region_Sub_Region_nm__c = 'EMEA';
            dcfiupgm.Core_MDF_User_id__c =dcfAccountManager.Id;
            dcfiupgm.Core_MDF_Role_nm__c='Core_MDF_CCP_Internal_DCF_Acct_Mgr';
            dcfiupgm.Core_MDF_All_Accounts_cd__c = 'No';
            iupgmList.add(dcfiupgm);
            
            Core_MDF_Int_Users_Partner_Geo_Mapping__c IPAiupgm1 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            IPAiupgm1.RecordTypeId = IPA_RecordType;
            IPAiupgm1.Core_MDF_Account_id__c = ccpIntelAccount.Id;
            IPAiupgm1.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
            IPAiupgm1.Core_MDF_Region_Sub_Region_nm__c = 'APJ';
            IPAiupgm1.Core_MDF_Region_cd__c = 'APJ';
            IPAiupgm1.Core_MDF_User_id__c =priceRev.Id;
            IPAiupgm1.Core_MDF_GeoSubGeo_Budget_Type_nm__c='APJ->Business Client Acceleration - MDF;';
            IPAiupgm1.Core_MDF_Role_nm__c='Core_MDF_CCP_Internal_IPA_Acct_Mgr';
            IPAiupgm1.Core_MDF_All_Accounts_cd__c = 'No';
            IPAiupgm1.Core_MDF_All_Budget_Type_Access_Ind__c = false;
            iupgmList.add(IPAiupgm1);
            
            Core_MDF_Int_Users_Partner_Geo_Mapping__c IPAiupgm3= new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            IPAiupgm3.RecordTypeId = IPA_RecordType;
            IPAiupgm3.Core_MDF_Account_id__c = ccpIntelAccount.Id;
            IPAiupgm3.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
            IPAiupgm3.Core_MDF_Region_cd__c = 'APJ;EMEA';
            IPAiupgm3.Core_MDF_Region_Sub_Region_nm__c = 'APJ;EMEA';
            IPAiupgm3.Core_MDF_GeoSubGeo_Budget_Type_nm__c = 'APJ->Business Client Acceleration - MDF;EMEA->Business Client Acceleration - MDF';
            IPAiupgm3.Core_MDF_User_id__c =priceRev.Id;
            IPAiupgm3.Core_MDF_Role_nm__c='Core_MDF_CCP_Int_IPA_ProposalL1_Approver';
            IPAiupgm3.Core_MDF_All_Accounts_cd__c = 'No';
            IPAiupgm3.Core_MDF_All_Budget_Type_Access_Ind__c = false;
            iupgmList.add(IPAiupgm3);
            
            Core_MDF_Int_Users_Partner_Geo_Mapping__c IPAiupgm31= new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            IPAiupgm31.RecordTypeId = IPA_RecordType;
            IPAiupgm31.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
            IPAiupgm31.Core_MDF_Region_cd__c = 'APJ;EMEA';
            IPAiupgm31.Core_MDF_Region_Sub_Region_nm__c = 'APJ;EMEA';
            IPAiupgm31.Core_MDF_GeoSubGeo_Budget_Type_nm__c = 'APJ->Business Client Acceleration - MDF;EMEA->Business Client Acceleration - MDF';
            IPAiupgm31.Core_MDF_User_id__c =priceRev.Id;
            IPAiupgm31.Core_MDF_Role_nm__c='Core_MDF_CCP_Int_IPA_ProposalL1_Approver';
            IPAiupgm31.Core_MDF_All_Accounts_cd__c = 'Yes';
            IPAiupgm31.Core_MDF_All_Budget_Type_Access_Ind__c = false;
            iupgmList.add(IPAiupgm31);
            
            Core_MDF_Int_Users_Partner_Geo_Mapping__c IPAiupgm4= new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            IPAiupgm4.RecordTypeId = IPA_RecordType;
            IPAiupgm4.Core_MDF_Account_id__c = ccpIntelAccount.Id;
            IPAiupgm4.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
            IPAiupgm4.Core_MDF_Region_cd__c = 'WW';
            IPAiupgm4.Core_MDF_Region_Sub_Region_nm__c = 'WW';
            IPAiupgm4.Core_MDF_Approval_Region_nm__c = 'WW';
            IPAiupgm4.Core_MDF_User_id__c =priceRev.Id;
            IPAiupgm4.Core_MDF_Role_nm__c='Core_MDF_CCP_Internal_Price_Reviewer';
            IPAiupgm4.Core_MDF_All_Accounts_cd__c = 'Yes';
            IPAiupgm4.Core_MDF_All_Budget_Type_Access_Ind__c = false;
            iupgmList.add(IPAiupgm4);
            
            Core_MDF_Int_Users_Partner_Geo_Mapping__c IPAiupgm5= new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            IPAiupgm5.RecordTypeId = IPA_RecordType;
            IPAiupgm5.Core_MDF_Account_id__c = ccpIntelAccount.Id;
            IPAiupgm5.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
            IPAiupgm5.Core_MDF_Region_cd__c = 'WW';
            IPAiupgm5.Core_MDF_Region_Sub_Region_nm__c = 'WW';
            IPAiupgm5.Core_MDF_User_id__c =priceRev.Id;
            IPAiupgm5.Core_MDF_Role_nm__c='Core_MDF_CCP_Internal_Proposal_Activity_L2_Approver';
            IPAiupgm5.Core_MDF_All_Accounts_cd__c = 'Yes';
            IPAiupgm5.Core_MDF_All_Budget_Type_Access_Ind__c = true;
            IPAiupgm5.Core_MDF_Activity_Classification_nm__c ='Sales;Marketing';
            iupgmList.add(IPAiupgm5);
            Database.insert(iupgmList);
            Test.stopTest();
        }
    }
    static Map<string,String> getPermissionSetIdbyName(Set<String> psNameSet){
        Map<string,String>  resultMap = new Map<string,String>();
        for(permissionSet ps: [SELECT Id , Name
                               FROM PermissionSet
                               WHERE Name IN:psNameSet]){
             resultMap.put(ps.Name, ps.Id);
            
        }
        return resultMap;
    }
    @isTest
    public static void testGetIntelActivityOwnersforCCF(){
        User testusr = [SELECT Id,Name FROM User where lastname = 'Admin_user' LIMIT 1];
        System.runAs(testusr){
            Test.startTest(); 
            Account ccpIntelAccount = [SELECT Id FROM Account WHERE Name = 'CCP Test Intel Account'];
            Account ccfCoMarketingAccount=[select Id from Account where Name='Co-marketing CCF Test Account'];
            Account dcfCoMarketingAccount=[select Id from Account where Name='Co-marketing DCF Test Account'];
            User dcfAccManager= [select Id From User where LastName='DCF Acc Manager'];
            Campaign cmp=[Select Id,Status,Core_MDF_Account__r.Id From Campaign Where Name='Test Campaign - AP' LIMIT 1];
            Id cmpAccID = cmp.Core_MDF_Account__r.Id;
            List<string> countryList=new List<string>();       
            countryList.add('ALBANIA');
            Core_MDF_GeneralPurpose_UI_Utility.getIntelActivityOwners(ccfCoMarketingAccount.Id,cmpAccID,'Core_MDF_Client_CoMarketing_Fund',countryList,'OEM CMP',false);
            Boolean testclassResult=Core_MDF_GeneralPurpose_UI_Utility.isApprover(dcfCoMarketingAccount.Id,cmpAccID, 'Core_MDF_Data_Center_CoMarketing_Fund', countryList,'OEM CMP', String.valueOf(dcfAccManager.Id));
            Core_MDF_GeneralPurpose_UI_Utility.isApprover(null,null,null,null,null,null);
            Assert.areEqual(testclassResult, true);
            Test.stopTest();
        }
        
    }
    
    
    @isTest
    public static void testIsRecordApprover(){
        User testusr = [SELECT Id,Name FROM User where lastname = 'Admin_user' LIMIT 1];
        System.runAs(testusr){
            Test.startTest(); 
            Account ccfCoMarketingAccount=[select Id from Account where Name='Co-marketing CCF Test Account'];
            Account dcfCoMarketingAccount=[select Id from Account where Name='Co-marketing DCF Test Account'];
            User dcfAccManager= [select Id From User where LastName='DCF Acc Manager'];
            User ccfAccountManager =[select Id from User where LastName = 'CCF Acc Manager'];
            List<string> countryList=new List<string>();      
            countryList.add('AFGHANISTAN');
            Core_MDF_GeneralPurpose_UI_Utility.isRecordApproverWithBudgetType(ccfCoMarketingAccount.Id, 'Core_MDF_Client_CoMarketing_Fund', countryList, 'Price Reviewer', String.valueOf(dcfAccManager.Id),'OEM CMP');
            Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(ccfCoMarketingAccount.Id, 'Core_MDF_Client_CoMarketing_Fund', countryList, 'Price Reviewer', String.valueOf(dcfAccManager.Id));
            Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(ccfCoMarketingAccount.Id, 'Core_MDF_Client_CoMarketing_Fund', countryList, 'L1 Approval', String.valueOf(dcfAccManager.Id));
            Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(ccfCoMarketingAccount.Id, 'Core_MDF_Client_CoMarketing_Fund', countryList, 'Program Office Reviewer', String.valueOf(dcfAccManager.Id));
            Boolean testclassResult=Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(ccfCoMarketingAccount.Id, 'Core_MDF_Client_CoMarketing_Fund', countryList, 'L2 Approval', String.valueOf(dcfAccManager.Id));
            Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(ccfCoMarketingAccount.Id, 'Core_MDF_Client_CoMarketing_Fund', countryList, 'Geo Lead Approval', String.valueOf(dcfAccManager.Id));
            Assert.areEqual(testclassResult, false);
            Test.stopTest();
        }
        
    }
    @isTest
    public static void testgetMemberactivityOwners(){
         User testusr = [SELECT Id,Name FROM User where lastname = 'Admin_user' LIMIT 1];
        System.runAs(testusr){
            Test.startTest(); 
            Account ccfCoMarketingAccount=[select Id from Account where Name='Co-marketing CCF Test Account'];
            Account acc6=[select Id from Account where Name='Test Account 3'];
            User usr1 =[select Id from User where Email='test1@example.com'];
            User ccfAccountManager =[select Id from User where LastName = 'CCF Acc Manager'];
            Campaign cmp=[Select Id,Status,Core_MDF_Account__r.Id From Campaign Where Name='Test Campaign - AP' LIMIT 1];
            Id cmpAccID = cmp.Core_MDF_Account__r.Id;
            List<string> countryList=new List<string>();      
            countryList.add('AFGHANISTAN');
            Core_MDF_GeneralPurpose_UI_Utility.getMemberactivityOwners(ccfCoMarketingAccount.Id, true);
            Core_MDF_GeneralPurpose_UI_Utility.getMemberactivityOwners(ccfCoMarketingAccount.Id, false);
            Core_MDF_GeneralPurpose_UI_Utility.getMemberactivityOwners(null, true);
            Core_MDF_GeneralPurpose_UI_Utility.getMemberactivityOwners(acc6.Id, false);
            Core_MDF_GeneralPurpose_UI_Utility.getIntelActivityOwners(ccfCoMarketingAccount.Id,cmpAccID,'Core_MDF_Client_CoMarketing_Fund',countryList,'OEM CMP',true);
            Boolean testclassResult = Core_MDF_GeneralPurpose_UI_Utility.isSubmitterActive(ccfCoMarketingAccount.Id, String.valueOf(ccfAccountManager.Id));
            Core_MDF_GeneralPurpose_UI_Utility.isSubmitterActive(null,null);
            Core_MDF_GeneralPurpose_UI_Utility.MemberActivityOwnerWrapper extActSubmitterObj = new Core_MDF_GeneralPurpose_UI_Utility.MemberActivityOwnerWrapper();
            extActSubmitterObj.userId = usr1.Id;
            extActSubmitterObj.fullName= 'TestUserName';
            extActSubmitterObj.firstName = 'TestUserFName';
            extActSubmitterObj.lastName = 'TestUserLName';
            extActSubmitterObj.email = 'TestUserEmail';
            Assert.areEqual(testclassResult, false);
            Test.stopTest();
        }
    }
    @isTest
    public static void testIUPGMRecordsPCT(){
        User testusr = [SELECT Id,Name FROM User where lastname = 'Admin_user' LIMIT 1];
        System.runAs(testusr){
            Test.startTest();      
            Account ccpIntelAccount = [SELECT Id FROM Account WHERE Name = 'CCP Test Intel Account'];
            Account ccfCoMarketingAccount=[select Id from Account where Name='Co-marketing CCF Test Account'];
            Account dcfCoMarketingAccount=[select Id from Account where Name='Co-marketing DCF Test Account'];
            User dcfAccManager= [select Id From User where LastName='DCF Acc Manager'];
            User ccfAccountManager =[select Id from User where LastName = 'CCF Acc Manager']; 
            User priceReviewerUser =[select Id from User where LastName = 'Price Reviewer' LIMIT 1];
            List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
            List<string> geoList =new List<string>();      
            geoList.add('APJ');
            geoList.add('EMEA');
            List<string> accList=new List<string>();      
            accList.add(ccpIntelAccount.Id);
            List<string> programList=new List<string>();      
            programList.add(Core_MDF_CCP_ConstantClass.CCF_PROGRAM);
            programList.add('Intel Partner Alliance');
            String approvalStage = 'Price Reviewer';
            List<String> approvalStageList=new List<String>();
            approvalStageList.add('Price Reviewer');
            approvalStageList.add('L2 Regional Sales');
            List<string> roles=new List<string>();
            roles.add('Core_MDF_CCP_Internal_Price_Reviewer');
            roles.add('Core_MDF_CCP_Internal_IPA_Acct_Mgr');
            roles.add('Core_MDF_CCP_Int_IPA_ProposalL1_Approver');
            List<String> budgetTList=new List<String>();
            budgetTList.add('Business Client Acceleration - MDF');
            Core_MDF_GeneralPurpose_UI_Utility.getIupgmRecordsPCT(accList, programList, geoList,'Core_MDF_CCP_Internal_Price_Reviewer');
            Core_MDF_GeneralPurpose_UI_Utility.getIupgmRecordsPCT(accList, programList, geoList,'Core_MDF_CCP_Internal_IPA_Acct_Mgr');
            Core_MDF_GeneralPurpose_UI_Utility.getIupgmRecordsForApprovers(accList, programList, geoList, roles, 'Core_MDF_GeneralPurpose_UI_Utility_Role_Mappings');
            Core_MDF_GeneralPurpose_UI_Utility.getIupgmForApproversWithBudgetType(accList, programList, geoList, roles,budgetTList,approvalStageList);
            Core_MDF_GeneralPurpose_UI_Utility.getIupgmRecordsWithBudgetType(ccpIntelAccount.Id,'Intel Partner Alliance',priceReviewerUser.Id,'APJ','Core_MDF_CCP_Int_IPA_ProposalL1_Approver','Business Client Acceleration - MDF');
            Core_MDF_GeneralPurpose_UI_Utility.getIupgmRecordsWithBudgetType(ccpIntelAccount.Id,'Intel Partner Alliance',priceReviewerUser.Id,'APJ','Core_MDF_CCP_Internal_IPA_Acct_Mgr','Business Client Acceleration - MDF');
            Core_MDF_GeneralPurpose_UI_Utility.getIupgmRecords(ccpIntelAccount.Id, 'Intel Partner Alliance',priceReviewerUser.Id,'APJ', 'Core_MDF_CCP_Internal_IPA_Acct_Mgr');
            Core_MDF_GeneralPurpose_UI_Utility.getIupgmRecords(ccpIntelAccount.Id, 'Intel Partner Alliance',priceReviewerUser.Id,'APJ', 'Core_MDF_CCP_Int_IPA_ProposalL1_Approver');
            
            Core_MDF_GeneralPurpose_UI_Utility.isRecordApproverWithBudgetType(ccpIntelAccount.Id,'Intel Partner Alliance',geoList,'L1 Approval',priceReviewerUser.Id,'Business Client Acceleration - MDF');
            Core_MDF_GeneralPurpose_UI_Utility.isRecordApproverWithBudgetType(ccpIntelAccount.Id,'Intel Partner Alliance',geoList,'L2 Approval',priceReviewerUser.Id,'Business Client Acceleration - MDF');
            Core_MDF_GeneralPurpose_UI_Utility.isRecordApproverWithBudgetType(null,null,null,null,null,null);
            Boolean testclassResult=Core_MDF_GeneralPurpose_UI_Utility.isRecordApproverWithBudgetType(ccpIntelAccount.Id,'Intel Partner Alliance',geoList,'Program Office Reviewer',priceReviewerUser.Id,'Business Client Acceleration - MDF');
            
            Assert.areEqual(testclassResult, false);
            Test.stopTest(); 
        }
    }
    @isTest
    public static void isRecordApproverSobjectTest(){
        User testusr = [SELECT Id,Name FROM User where lastname = 'Admin_user' LIMIT 1];
        System.runAs(testusr){
            Test.startTest();
            Account acc=[select id,name from Account where name='Test Account 3' limit 1];
            User priceReviewerUser =[select Id from User where LastName = 'Price Reviewer' LIMIT 1];
            List<Campaign> campList=[select id,Core_MDF_Sub_Region_cd__c,recordType.DeveloperName,Core_MDF_Program__c,Core_MDF_Ultimate_Account_txt__c,Core_MDF_Host_Region_cd__c,Core_MDF_Region_cd__c,Core_MDF_Opal_Budget_Type_Txt__c,name,Core_MDF_Proposal_Based_Ind__c,Core_MDF_Budget_Type_txt__c,
                                        Core_MDF_Approval_Stage_nm__c from Campaign where name like '%Test Campaign - AP%'];
            List<PartnerFundRequest> pfrList = [select id,title,recordType.DeveloperName,Core_MDF_Ultimate_Account_Id__c,Core_MDF_Host_Region_or_Region_txt__c,
                                           Core_MDF_Region_nm__c,Core_MDF_Sub_Region_nm__c,Core_MDF_Host_Region_txt__c,
                                           Core_MDF_Approval_Stage__c,Core_MDF_Budget_Type_nm__c,Core_MDF_Proposal_Based_Ind__c from PartnerFundRequest where title Like '%Test Activity%'];
           
            Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(campList[0],priceReviewerUser.id);
           
            Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(campList[1],priceReviewerUser.id);
            
            Boolean testclassResult12 = Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(campList[2],priceReviewerUser.id);
            
            //Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(pfrList[0],priceReviewerUser.id);
           
            //Boolean testclassResult12=Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(pfrList[1],priceReviewerUser.id);
            //Boolean testclassResult13=Core_MDF_GeneralPurpose_UI_Utility.isRecordApprover(pfrList[2],priceReviewerUser.id);
            
            Assert.areEqual(testclassResult12, false);
            Test.stopTest();
        }
    }
}