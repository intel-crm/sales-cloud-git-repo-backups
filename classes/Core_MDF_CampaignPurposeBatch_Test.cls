@isTest
public class Core_MDF_CampaignPurposeBatch_Test {
    
    public static Id payRun_RecordType_IPAMDF = Schema.SObjectType.Core_MDF_Payment_Run__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance_MDF').getRecordTypeId();
    
    // test method for data setup
    @TestSetup static void setUpData(){
        
        
        UserRole usRole = [SELECT Id, Name FROM UserRole where Name = 'Admin' LIMIT 50000];
        User testUser = Core_MDF_CCP_TestDataUtility.createUser(false);
        testUser.LastName = 'Sys Admin';
        testUser.UserRoleId = usRole.Id;
        testUser.IsActive=true;
        insert testUser;
        System.runAs(testUser){
            List<Account> acctList = new List<Account>();
            List<User> userList = new List<User>();
            
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
            //bypassFunctionKeys.add('Bypass_Activity_ApprovalProcess');
            bypassFunctionKeys.add('Bypass_ShareActivityWithUsers');
            bypassFunctionKeys.add('Bypass_ShareActivityWithAccNodeGroup');
            bypassFunctionKeys.add('Bypass_geoLeadApprovalProcess');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', true);
            Id campaign_RecordType_IPA = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
            
            // Creating a map of profile name and profile Id
            Map<String,Id> profileToId = new Map<String,Id>();
            for(Profile prfl:[SELECT Id,Name FROM Profile WHERE Name IN ('System Administrator','CCP - Core Access')]) {
                profileToId.put(prfl.Name,prfl.Id);
            }
            // Creating a map of PS names and PS
            Map<String,PermissionSet> nameToPerSet = new Map<String,PermissionSet>();
            for(PermissionSet pSet:[SELECT Id,Name FROM PermissionSet WHERE Name IN (
                'Core_MDF_CCP_Internal_APJ_User',
                'Core_MDF_CCP_Internal_Payment_Schedule_Admin',
                'Core_MDF_CCP_Internal_IPA_Payment_Adm',
                'View_All_Data',
                'Core_MDF_CCP_Internal_IPA_Acct_Mgr'
            )]) {
                nameToPerSet.put(pSet.Name,pSet);
            }
            
            PermissionSet paymentAdmGeoPS = nameToPerSet.get('Core_MDF_CCP_Internal_APJ_User'); 
            PermissionSet paymentAdmSchedulePS = nameToPerSet.get('Core_MDF_CCP_Internal_Payment_Schedule_Admin'); 
            PermissionSet ipaPaymentAdmPS = nameToPerSet.get('Core_MDF_CCP_Internal_IPA_Payment_Adm');
            PermissionSet viewAllDataPS = nameToPerSet.get('View_All_Data');
         //   PermissionSet accountmanagerrole = nameToPerSet.get('Core_MDF_CCP_Internal_IPA_Acct_Mgr');
            
            
            User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false); 
            usr2.Email='testPayment@example.com';
            usr2.LastName='PayAdmUser';
            usr2.profileId = profileToId.get('CCP - Core Access');
            usr2.IsActive = true;
            userList.add(usr2); 
            
            // Creating User with utility class 
            User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr.Email = 'sysadmin@example.com';
            userList.add(usr);
            database.insert(userList);
            List<PermissionSetAssignment> permSetAssgnLst = new List<PermissionSetAssignment>();
            
            // Assigning IPA Payment Admin PS
           /* PermissionSetAssignment assignPermissionSetObj3 = new PermissionSetAssignment();
            assignPermissionSetObj3.AssigneeId = testUser.Id;
            assignPermissionSetObj3.PermissionSetId = accountmanagerrole.Id;
            permSetAssgnLst.add(assignPermissionSetObj3);*/
            
            
            // Assigning IPA Payment Admin PS
            PermissionSetAssignment assignPermissionSetObj2 = new PermissionSetAssignment();
            assignPermissionSetObj2.AssigneeId = testUser.Id;
            assignPermissionSetObj2.PermissionSetId = ipaPaymentAdmPS.Id;
            permSetAssgnLst.add(assignPermissionSetObj2);
            
            // Assigning CCP Internal APJ User PS
            PermissionSetAssignment assignGeoPermissionSet = new PermissionSetAssignment();
            assignGeoPermissionSet.AssigneeId = testUser.Id;
            assignGeoPermissionSet.PermissionSetId = paymentAdmGeoPS.Id;
            permSetAssgnLst.add(assignGeoPermissionSet);
            
            // Assigning Payment Admin Schedule PS
            PermissionSetAssignment assignSchedulePermissionSet = new PermissionSetAssignment();
            assignSchedulePermissionSet.AssigneeId = testUser.Id;
            assignSchedulePermissionSet.PermissionSetId = paymentAdmSchedulePS.Id;
            permSetAssgnLst.add(assignSchedulePermissionSet);
            
            // Assigning View All Data PS
            PermissionSetAssignment assignViewAllPermissionSet = new PermissionSetAssignment();
            assignViewAllPermissionSet.AssigneeId = testUser.Id;
            assignViewAllPermissionSet.PermissionSetId = viewAllDataPS.Id;
            permSetAssgnLst.add(assignViewAllPermissionSet);
            system.runAs(testUser){
                Database.insert(permSetAssgnLst);
                
            }
            PermissionSet ccfAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr' LIMIT 1];
            PermissionSet retailAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Retail_Account_Manager' LIMIT 1];
            PermissionSet ipaAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_IPA_Acct_Mgr' LIMIT 1];
            PermissionSet ipaProgAdmPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Proposal_Activity_POR_Approver' LIMIT 1];
            PermissionSet ipaL2ApproverPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Proposal_Activity_L2_Approver' LIMIT 1];
            PermissionSet ipaPriceReviewPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Price_Reviewer' LIMIT 1];
            PermissionSet rmfGeoApp = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Retail_Marketing_GEO_Approver' LIMIT 1];
            PermissionSet ipaL1Approver = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Int_IPA_ProposalL1_Approver' LIMIT 1];
            PermissionSet dcfBudgetApprover = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_DCF_MDF_Budget_Approver' LIMIT 1];
            
            List<PermissionSetAssignment> permissionSetAssignmentList = new List<PermissionSetAssignment>();
            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = ipaPriceReviewPS.Id, AssigneeId = testUser.Id);
            permissionSetAssignmentList.add(psa);
            
            PermissionSetAssignment psa1 = new PermissionSetAssignment(PermissionSetId = ccfAccManagerPS.Id, AssigneeId = testUser.Id);
            permissionSetAssignmentList.add(psa1);
            
            PermissionSetAssignment psa6 = new PermissionSetAssignment(PermissionSetId = retailAccManagerPS.Id, AssigneeId = testUser.Id);
            permissionSetAssignmentList.add(psa6);
            
            PermissionSetAssignment psa7 = new PermissionSetAssignment(PermissionSetId = ipaAccManagerPS.Id, AssigneeId = testUser.Id);
            permissionSetAssignmentList.add(psa7);
            
            PermissionSetAssignment psa8 = new PermissionSetAssignment(PermissionSetId = ipaProgAdmPS.Id, AssigneeId = testUser.Id);
            permissionSetAssignmentList.add(psa8);
            
            PermissionSetAssignment psa9 = new PermissionSetAssignment(PermissionSetId = ipaL2ApproverPS.Id, AssigneeId = testUser.Id);
            permissionSetAssignmentList.add(psa9);
            
            PermissionSetAssignment psa10 = new PermissionSetAssignment(PermissionSetId = rmfGeoApp.Id, AssigneeId = testUser.Id);
            permissionSetAssignmentList.add(psa10);
            
            PermissionSetAssignment psa11 = new PermissionSetAssignment(PermissionSetId = ipaL1Approver.Id, AssigneeId = testUser.Id);
            permissionSetAssignmentList.add(psa11);
            
            PermissionSetAssignment psa12 = new PermissionSetAssignment(PermissionSetId = dcfBudgetApprover.Id, AssigneeId = testUser.Id);
            permissionSetAssignmentList.add(psa12);
            
            System.runAs(testUser){
                insert permissionSetAssignmentList;
            }
            
            
            
            
            
            
            
            
            Id acctRecord_Type = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
            Account acc = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test IPA Accounttest', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);//changed 2nd parameter
            //insert acc;
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test IPA Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            acc1.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
            acc1.Core_MDF_CoMarketingActive__c = true;
                        acc1.Core_MDF_CoMarketing_Ultimate_Account__c = acc.Id;

            acc1.Core_IPA_One_Partner_Id__c=acc.id;
            acctList.add(acc1);
            insert(acctList);
            // Updating Accounts 
            acc1.isPartner = true;
            Database.update(acc1);
            Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2', cp.Id, Core_MDF_CCP_TestDataUtility.account_Record_Type, acc1.Id, false);//changed record type from Intel to Acc
            acc2.Core_Geo__c='';
            acc2.Core_Sub_Geo__c='';
            
            acc2.BillingCity = 'Test City';         
            acc2.BillingCountry= 'AUS';
            acc2.BillingStreet= 'Test Street';
            insert acc2;
            //NA
            //Account ccfAccforAcc = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acctList[0].Id, false);
            //ccfAccforAcc.Core_Geo__c='';
            //ccfAccforAcc.Core_Sub_Geo__c='';
            //insert ccfAccforAcc;
            
            
            //NA
            List<Group> grpList = new List<Group>();
            Group ipaExtGrp = new Group();
            ipaExtGrp.Name = 'Core CCP IPA External';
            ipaExtGrp.DeveloperName = 'Core_MDF_CCP_IPA_External';
            grpList.add(ipaExtGrp);
            
            Group ipaExtGrp2 = new Group();
            ipaExtGrp2.Name = 'Core CCP IPA External2';
            ipaExtGrp2.DeveloperName = 'Core_MDF_CCP_IPA_External2';
            grpList.add(ipaExtGrp2);
            System.runAs(usr){
                Database.insert(grpList);  
                
                
                // Creating Group Member
                List<GroupMember> grpMemList = new List<GroupMember>();
                GroupMember ipaExtGrpMem1 = new GroupMember();
                ipaExtGrpMem1.UserOrGroupId = usr2.Id;
                ipaExtGrpMem1.GroupId = ipaExtGrp.Id;
                grpMemList.add(ipaExtGrpMem1);
                
                GroupMember ipaExtGrpMem2 = new GroupMember();
                ipaExtGrpMem2.UserOrGroupId =usr.Id;
                ipaExtGrpMem2.GroupId = ipaExtGrp.Id;
                grpMemList.add(ipaExtGrpMem2);
                
                Database.insert(grpMemList);
            }
            List<Core_MDF_Partner_Group_Mapping__c> pgmList = new List<Core_MDF_Partner_Group_Mapping__c>();
            // Creating Partner Group Mapping
            Core_MDF_Partner_Group_Mapping__c pgmExt = new Core_MDF_Partner_Group_Mapping__c();
            pgmExt.Core_MDF_Account__c = acc1.Id;
            pgmExt.Core_MDF_Group_Name__c = 'Core_MDF_CCP_IPA_External';
            pgmExt.Core_MDF_Type_of_Access__c = 'EXTERNAL';
            pgmExt.Core_MDF_Group_Id__c = ipaExtGrp.Id;                
            pgmExt.Core_MDF_Channel_Program__c = cp.Id;
            pgmExt.Core_MDF_Source_Txt__c = 'Test';
            pgmExt.Core_MDF_Region_cd__C = 'APJ';
            pgmExt.Core_MDF_AccountIdGroupName__c = acc1.Id+'Core_MDF_CCP_IPA_External';
            pgmList.add(pgmExt);
            
            
            Database.insert(pgmList);
            ///////////////////////////
            
            string budgetType = Core_MDF_CCP_IPA_TestDataUtility.createBenefit(acc2);
            //budgetType = 'Proposal I MDF';
            PartnerMarketingBudget budget = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget New',Core_MDF_CCP_IPA_TestDataUtility.budgetIPA_ProposalBased_Record_Type,acc2.Id,cp.Id,200000,System.today().addDays(-20),System.today(), false);
            budget.Core_MDF_Budget_Type_Txt__c= budgetType;
            Database.insert(budget);
            
            PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('allocation',budget,acc2, 100000,true);
            
            Core_MDF_Account_Node_Attributes__c accNodeAttr = new Core_MDF_Account_Node_Attributes__c();
            accNodeAttr.Core_MDF_Account_id__c = acc2.Id;
            accNodeAttr.Core_MDF_Program_id__c = cp.Id;
            accNodeAttr.Core_MDF_CSAR_GL_Account_nbr__c = 402110;
            accNodeAttr.Core_MDF_NonPO_GL_Account_nbr__c = 506710;
            accNodeAttr.Core_MDF_Customer_NonPO_GL_Account_nbr__c = 244200;
            insert accNodeAttr;
            Test.startTest();
            Campaign camp = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test IPA Camp',acc2.Id, System.today().addDays(-30), System.today().addDays(300),budgetType, 1234.00, 'AFGHANISTAN','Consumer','Coffee Lake','Pending Review', false);
            camp.Core_MDF_Region_cd__c = 'APJ';
            camp.Core_MDF_Budget_Type_txt__c = budgetType;
            camp.Core_MDF_Budget__c = budget.Id;
            camp.Core_MDF_Reimbursement_Amt__c = 10000;
            Database.insert(camp);
            camp.Status = 'Completed';
            camp.Core_MDF_CampOutcomeOpt_In_Ind__c=true;
            camp.Core_MDF_Outcomes_nm__c='Volume - Units';
            update camp;
            // Create Campaign Outcome
            Core_MDF_Campaign_Outcomes__c outcome = new Core_MDF_Campaign_Outcomes__c();
            outcome.Core_MDF_Campaign_Id__c = camp.Id;
            outcome.Core_MDF_Active_Ind__c = true;
            outcome.Core_MDF_Quantity_nbr__c = null;
            insert outcome;
           /* PartnerFundRequest pfr = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(camp.Id,acc2.Id,System.today().addDays(-25),System.today().addDays(25),false);
            pfr.Core_MDF_BU_Split__c ='CCG';
            pfr.Core_MDF_BU1_Split_Percent_nbr__c=100;
            pfr.amount = 500;
            pfr.Core_MDF_Reimbursement_Rate_txt__c='60%';
            pfr.Core_MDF_Budget_Type_nm__c = budgetType;
            Database.insert(pfr);
            List<Campaign> campToBeUpdated = new List<Campaign>();
            List<PartnerFundRequest> pfrToBeUpdated = new List<PartnerFundRequest>(); 
            camp.Status = 'Proposal Accepted';
            campToBeUpdated.add(camp);
            Database.update(campToBeUpdated);
            
            pfr.Core_MDF_Fund_Request_Status__c = 'Planned';
            pfr.Core_MDF_Reimbursement_Rate_pct__c ='100%';
            pfrToBeUpdated.add(pfr);
            
            Database.update(pfrToBeUpdated);
            Core_MDF_CCP_TestDataUtility.insertCurrencyExchangeRates();  
            // Create test data for Core_MDF_Activity_Attributes__c
            Core_MDF_Activity_Attributes__c activityAttribute = new Core_MDF_Activity_Attributes__c(
                Core_MDF_Co_Marketing_Activity__c = pfr.Id,
                Core_MDF_Field_Name_nm__c = 'Digital Media - # of Impressions',
                Core_MDF_Field_Value_nbr__c = 200,
                Core_MDF_Type_nm__c = 'KPI',
                Core_MDF_Tactics_nm__c = 'Digital Media',
                Core_MDF_Is_Active_Ind__c = true
            );
            insert activityAttribute;*/
            
            
            Test.stopTest();
           
            
            Id IUPGM_recordtype_IPA = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
            Id IUPGM_recordtype_RMF = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
           /* Core_MDF_Int_Users_Partner_Geo_Mapping__c IPAiupgm5= new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            
            IPAiupgm5.Core_MDF_Account_id__c = acc.Id;
            IPAiupgm5.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
            IPAiupgm5.RecordTypeId = IUPGM_recordtype_IPA;
            IPAiupgm5.Core_MDF_Region_Sub_Region_nm__c = 'WW';
            IPAiupgm5.Core_MDF_User_id__c =testUser.Id;
            IPAiupgm5.Core_MDF_Role_nm__c='Core_MDF_CCP_Internal_IPA_Acct_Mgr';
            IPAiupgm5.Core_MDF_All_Accounts_cd__c = 'No';
            IPAiupgm5.Core_MDF_All_Budget_Type_Access_Ind__c = true;
            IPAiupgm5.Core_MDF_Active_Ind__c=true;
            Database.insert(IPAiupgm5);*/
           
             //IUPGM Insert
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm1 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();        
        iupgm1.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
        iupgm1.Core_MDF_Region_Sub_Region_nm__c = 'WW';
        iupgm1.Core_MDF_Approval_Region_nm__c = 'WW';
        iupgm1.Core_MDF_User_id__c = testUser.Id;
        iupgm1.Core_MDF_All_Budget_Type_Access_Ind__c = true;
        iupgm1.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_IPA_Acct_Mgr';
        iupgm1.Core_MDF_All_Accounts_cd__c = 'No';
        iupgm1.Core_MDF_Account_id__c = acc1.Id;
        iupgm1.Core_MDF_Active_Ind__c =  true;
        iupgm1.RecordTypeId = IUPGM_recordtype_IPA;
        //iupgm1.Core_MDF_Channel_Program_id__c = progToIdMap.get('Intel Partner Alliance');
        iupgmList.add(iupgm1);
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm2 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();        
        iupgm2.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
        iupgm2.Core_MDF_Region_Sub_Region_nm__c = 'APJ';
        iupgm2.Core_MDF_User_id__c = testUser.Id;
        iupgm2.Core_MDF_Activity_Classification_nm__c = 'Sales;Marketing';
        iupgm2.Core_MDF_All_Budget_Type_Access_Ind__c = false;
        iupgm2.Core_MDF_GeoSubGeo_Budget_Type_nm__c = 'APJ->Client Specialties MDF;APJ->Business Client Acceleration - MDF';
        iupgm2.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_Proposal_Activity_L2_Approver';
        iupgm2.Core_MDF_All_Accounts_cd__c = 'Yes';
        iupgm2.Core_MDF_Active_Ind__c =  true;
        iupgm2.RecordTypeId = IUPGM_recordtype_IPA;
        //iupgm2.Core_MDF_Channel_Program_id__c = progToIdMap.get('Intel Partner Alliance');
        iupgmList.add(iupgm2);
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm3 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();        
        iupgm3.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
        iupgm3.Core_MDF_Region_Sub_Region_nm__c = 'APJ';
        iupgm3.Core_MDF_User_id__c = testUser.Id;
        iupgm3.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_Proposal_Activity_POR_Approver';
        iupgm3.Core_MDF_All_Accounts_cd__c = 'Yes';
        iupgm3.Core_MDF_All_Budget_Type_Access_Ind__c = true;
        iupgm3.Core_MDF_Active_Ind__c =  true;
        iupgm3.RecordTypeId = IUPGM_recordtype_IPA;
        //iupgm3.Core_MDF_Channel_Program_id__c = progToIdMap.get('Intel Partner Alliance');
        iupgmList.add(iupgm3);
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm4 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();        
        iupgm4.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
        iupgm4.Core_MDF_Region_Sub_Region_nm__c = 'APJ';
        iupgm4.Core_MDF_User_id__c = testUser.Id;
        iupgm4.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_Proposal_Activity_POR_Approver';
        iupgm4.Core_MDF_All_Accounts_cd__c = 'No';
        iupgm4.Core_MDF_All_Budget_Type_Access_Ind__c = true;
        iupgm4.Core_MDF_Account_id__c = acc.Id;
        iupgm4.Core_MDF_Active_Ind__c =  true;
        iupgm4.RecordTypeId = IUPGM_recordtype_IPA;
        //iupgm4.Core_MDF_Channel_Program_id__c = progToIdMap.get('Intel Partner Alliance');
        iupgmList.add(iupgm4);
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm5 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();        
        iupgm5.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
        iupgm5.Core_MDF_Region_Sub_Region_nm__c = 'APJ';
        iupgm5.Core_MDF_User_id__c = testUser.Id;
        iupgm5.Core_MDF_Activity_Classification_nm__c = 'Sales;Marketing';
        iupgm5.Core_MDF_All_Budget_Type_Access_Ind__c = false;
        iupgm5.Core_MDF_GeoSubGeo_Budget_Type_nm__c = 'APJ->Client Specialties MDF';
        iupgm5.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_Proposal_Activity_L2_Approver';
        iupgm5.Core_MDF_All_Accounts_cd__c = 'No';
        iupgm5.Core_MDF_Active_Ind__c =  true;
        iupgm5.Core_MDF_Account_id__c = acc.Id;
        iupgm5.RecordTypeId = IUPGM_recordtype_IPA;
        //iupgm5.Core_MDF_Channel_Program_id__c = progToIdMap.get('Intel Partner Alliance');
        iupgmList.add(iupgm5);
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm6= new Core_MDF_Int_Users_Partner_Geo_Mapping__c();        
        iupgm6.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
        iupgm6.Core_MDF_Region_Sub_Region_nm__c = 'WW';
        iupgm6.Core_MDF_Approval_Region_nm__c = 'WW';
        iupgm6.Core_MDF_User_id__c = testUser.Id;
        iupgm6.Core_MDF_All_Budget_Type_Access_Ind__c = true;
        iupgm6.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_Price_Reviewer';
        iupgm6.Core_MDF_All_Accounts_cd__c = 'No';
        iupgm6.Core_MDF_Account_id__c = acc.Id;
        iupgm6.Core_MDF_Active_Ind__c =  true;
        iupgm6.RecordTypeId = IUPGM_recordtype_IPA;
        //iupgm6.Core_MDF_Channel_Program_id__c = progToIdMap.get('Intel Partner Alliance');
        iupgmList.add(iupgm6);
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm7 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();        
        iupgm7.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
        iupgm7.Core_MDF_Region_Sub_Region_nm__c = 'WW';
        iupgm7.Core_MDF_Approval_Region_nm__c = 'WW';
        iupgm7.Core_MDF_User_id__c = testUser.Id;
        iupgm7.Core_MDF_All_Budget_Type_Access_Ind__c = true;
        iupgm7.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_Price_Reviewer';
        iupgm7.Core_MDF_All_Accounts_cd__c = 'Yes';
        iupgm7.Core_MDF_Active_Ind__c =  true;
        //iupgm7.Core_MDF_Channel_Program_id__c = progToIdMap.get('Client Co-Marketing Fund');
        iupgmList.add(iupgm7);
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm8 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm8.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
        iupgm8.Core_MDF_Region_Sub_Region_nm__c = 'EMEA';
        iupgm8.Core_MDF_User_id__c =  testUser.Id;
        iupgm8.Core_MDF_All_Accounts_cd__c = 'Yes';
        iupgm8.Core_MDF_Role_nm__c='Core_MDF_CCP_Internal_CCF_Acct_Mgr';
        //iupgm8.Core_MDF_Channel_Program_id__c = progToIdMap.get('Client Co-Marketing Fund');
        iupgmList.add(iupgm8);
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm9 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm9.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
        iupgm9.Core_MDF_Region_Sub_Region_nm__c = 'WW';
        iupgm9.Core_MDF_User_id__c =  testUser.Id;
        iupgm9.Core_MDF_All_Budget_Type_Access_Ind__c = true;
        iupgm9.Core_MDF_All_Accounts_cd__c = 'Yes';
        iupgm9.Core_MDF_Role_nm__c='Core_MDF_CCP_Int_IPA_ProposalL1_Approver';
        iupgm9.RecordTypeId = IUPGM_recordtype_IPA;
        //iupgm9.Core_MDF_Channel_Program_id__c = progToIdMap.get('Intel Partner Alliance');
        iupgmList.add(iupgm9);
        
       /* Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm10 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm10.Core_MDF_Program_nm__c = 'Data Center CoMarketing Fund';
        iupgm10.Core_MDF_Region_Sub_Region_nm__c = 'WW';
        iupgm10.Core_MDF_User_id__c =  testUser.Id;
        iupgm10.Core_MDF_All_Budget_Type_Access_Ind__c = true;
        iupgm10.Core_MDF_All_Accounts_cd__c = 'Yes';
        iupgm10.Core_MDF_Active_Ind__c =  true;
        iupgm10.RecordTypeId = DCF_RecordType;
        iupgm10.Core_MDF_Role_nm__c='Core_MDF_CCP_Internal_DCF_MDF_Budget_Approver';
        //iupgm10.Core_MDF_Channel_Program_id__c = progToIdMap.get('Data Center Co-Marketing Fund');
        iupgmList.add(iupgm10);*/
        
        system.runAs(testUser){
            insert iupgmList;
        }
          
        }
        
    }
    @isTest 
    static void validateIPAPaymentRun() { 
        
        // User sysAdminUser = [SELECT Id,Email FROM User WHERE Email='sysadmin@example.com' LIMIT 1];
        // User ipaPayAdm = [SELECT Id,Email FROM User WHERE Email='testPayment@example.com' LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE LastName = 'Sys Admin'];
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test IPA Accounttest' limit 1];
        PartnerFundClaim claim1;
        System.runAs(testUser){          
            
            Test.startTest();
            
            // Get IPA Campaign
            Campaign ipaCamp  = [SELECT Id, Name, StartDate, Status, EndDate, Description,Core_MDF_Ultimate_Account_txt__c,
                                 Core_MDF_Budget__c, Core_MDF_Account__c, Core_MDF_Channel_Program__c,
                                 Core_MDF_Opal_Budget_Type_Txt__c, Core_MDF_Total_Campaign_Cost_Amt__c
                                 FROM Campaign 
                                 WHERE Name = 'Test IPA Camp' 
                                 LIMIT 1];
            
            Core_MDF_Campaign_Outcomes__c cmppurpose=[SELECT Id, Name, Core_MDF_Active_Ind__c, Core_MDF_Campaign_Id__c, Core_MDF_Quantity_nbr__c,
                                                     Core_MDF_Campaign_Id__r.Core_MDF_Ultimate_Account_txt__c, Core_MDF_Campaign_Id__r.Status 
                                                     FROM Core_MDF_Campaign_Outcomes__c];
            
            system.debug('accids::'+cmppurpose.Core_MDF_Campaign_Id__r.Core_MDF_Ultimate_Account_txt__c);
            system.debug('status::'+cmppurpose.Core_MDF_Campaign_Id__r.Status);
            system.debug('status::'+cmppurpose.Core_MDF_Quantity_nbr__c);
            
            list<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgm = [SELECT id,Core_MDF_User_id__c,Core_MDF_Program_nm__c,Core_MDF_GeoSubGeo_Budget_Type_nm__c,Core_MDF_is_User_Active_ind__c,
                                                                     Core_MDF_Role_nm__c,Core_MDF_Region_Sub_Region_nm__c, Core_MDF_Active_Ind__c,Core_MDF_Account_id__c
                                                               FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                                    where Core_MDF_Account_id__c=:acc.Id
                                                                    and Core_MDF_Active_Ind__c = TRUE
                                                                    and Core_MDF_Role_nm__c='Core_MDF_CCP_Internal_IPA_Acct_Mgr'
                                                                    AND Core_MDF_is_User_Active_ind__c = TRUE];
            system.debug('iupgmList--ris'+iupgm);
            
            
            Core_MDF_CampaignPurposeBatchForReminder ipaReminder = new Core_MDF_CampaignPurposeBatchForReminder();
            Database.executeBatch(ipaReminder);
            System.Assert(ipaReminder!=null);
            
        }
        
        Test.stopTest();
    }
   

    
}