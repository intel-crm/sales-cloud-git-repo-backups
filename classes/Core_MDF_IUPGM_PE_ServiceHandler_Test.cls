/****************************************************************************************************************************************
* Class Name        : Core_MDF_IUPGM_PE_ServiceHandler_Test
* Created Date      : 06/15/2022
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* JB - Accenture       06/15/2022         Test Class for Core_MDF_IUPGM_PE_ServiceHandler
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
public class Core_MDF_IUPGM_PE_ServiceHandler_Test{
    /*@TestSetUp
    static void createTestData(){
        
        User testUser = Core_MDF_CCP_TestDataUtility.createUser(true);        
        
        System.runAs(testUser){
            
            List<Core_Trigger_Executions__c> executionList = new List<Core_Trigger_Executions__c>();
            Core_Trigger_Executions__c groupIdForAccountNode = new Core_Trigger_Executions__c();
            groupIdForAccountNode.name = 'Core_MDF_createGroupForAccountNode';
            groupIdForAccountNode.Core_Object__c = 'Account';
            groupIdForAccountNode.Core_Trigger_Events__c = 'After Insert';
            groupIdForAccountNode.Core_Active__c = TRUE;
            groupIdForAccountNode.Core_Description__c = 'To Create Group for each account';
            groupIdForAccountNode.Core_Class_Name__c = 'Core_AccountHandler';
            executionList.add(groupIdForAccountNode);
            
            Core_Trigger_Executions__c marketingUserPermissionUpdate = new Core_Trigger_Executions__c();
            marketingUserPermissionUpdate.name = 'marketingUserPermissionUpdate';
            marketingUserPermissionUpdate.Core_Object__c = 'Core_MDF_Int_Users_Partner_Geo_Mapping__c   ';
            marketingUserPermissionUpdate.Core_Trigger_Events__c = 'After Insert';
            marketingUserPermissionUpdate.Core_Active__c = TRUE;
            marketingUserPermissionUpdate.Core_Description__c = 'If enabled, the user will be updated with Marketing user permission';
            marketingUserPermissionUpdate.Core_Class_Name__c = 'Core_MDF_IUPGM_ServiceHandler';
            executionList.add(marketingUserPermissionUpdate);
            
            Core_Trigger_Executions__c marketingUserPermissionRemoval = new Core_Trigger_Executions__c();
            marketingUserPermissionRemoval.name = 'marketingUserPermissionRemoval';
            marketingUserPermissionRemoval.Core_Object__c = 'Core_MDF_Int_Users_Partner_Geo_Mapping__c  ';
            marketingUserPermissionRemoval.Core_Trigger_Events__c = 'after Update';
            marketingUserPermissionRemoval.Core_Active__c = TRUE;
            marketingUserPermissionRemoval.Core_Description__c = 'If turned on, the marketing user permission on user record will be turned off on IUPGM inactivation';
            marketingUserPermissionRemoval.Core_Class_Name__c = 'Core_MDF_IUPGM_ServiceHandler';
            executionList.add(marketingUserPermissionRemoval);
            
            insert executionList;
            
            List<ChannelProgram> cpList = new List<ChannelProgram>();
            ChannelProgram ccfCp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', false);
            ChannelProgram dcfCp = Core_MDF_CCP_TestDataUtility.createProgram ('Data Center Co-Marketing Fund','Data Center CoMarketing Fund', false);
            ChannelProgram ipaCp = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', false);   
            ChannelProgram cmdfCp = Core_MDF_CCP_TestDataUtility.createProgram ('Channel MDF','Channel MDF', false);
            cpList.add(ccfCp);
            cpList.add(dcfCp);
            cpList.add(ipaCp);
            cpList.add(cmdfCp);
            insert cpList;
            
            List<Account> intelAccList = new List<Account>();
            
            Account testCCF = Core_MDF_CCP_TestDataUtility.createIntelAccount('CCF_Intel_Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            Account testAcctTemp = Core_MDF_CCP_TestDataUtility.createIntelAccount('CMDF_Intel_Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            Account testAcctTemp1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('CMDF_Intel_Account1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            
            intelAccList.add(testCCF);
            intelAccList.add(testAcctTemp);
            intelAccList.add(testAcctTemp1);
            Database.insert(intelAccList);
            
            /*Group cmdfgrp = new Group();
            cmdfgrp.Name = 'CCP TESTACCTTEMP CMDF EMEA INTERNAL';
            cmdfgrp.DeveloperName = 'Core_MDF_CCP_TESTACCTTEMP_CMDF_EMEA_INTERNAL';
            Database.insert(cmdfgrp);
            
            Core_MDF_Partner_Group_Mapping__c cmdfPgm = new Core_MDF_Partner_Group_Mapping__c();
            cmdfPgm.Core_MDF_Account__c = testAcctTemp.Id;
            cmdfPgm.Core_MDF_Group_Name__c = 'Core_MDF_CCP_TESTACCTTEMP_CMDF_EMEA_INTERNAL';
            cmdfPgm.Core_MDF_Type_of_Access__c = 'Internal';           
            cmdfPgm.Core_MDF_Channel_Program__c = ccfCp.Id;
            cmdfPgm.Core_MDF_Region_cd__c = 'EMEA';
            cmdfPgm.Core_MDF_Source_Txt__c = 'Test';  
            cmdfPgm.Core_MDF_BudgetType_nm__c='Intel MDF Account Based2';
            Database.insert(cmdfPgm);
                    
            Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name = 'CCP - Core Access'];
            
            Map<String,PermissionSet> nameToPerSet = new Map<String,PermissionSet>();
            for(PermissionSet pSet:[SELECT Id,Name FROM PermissionSet WHERE Name IN ('Core_MDF_CCP_Internal_Channel_MDF_Budget_Approver', 'Core_MDF_CCP_Internal_IPA_Budget_Approver',
                                            'Core_MDF_CCP_Internal_CCF_MDF_Budget_Approver', 'Core_MDF_CCP_Internal_DCF_MDF_Budget_Approver')]) {
                nameToPerSet.put(pSet.Name,pSet);
            }
            
            PermissionSet cmdfBudgetApprPS = nameToPerSet.get('Core_MDF_CCP_Internal_Channel_MDF_Budget_Approver');
            PermissionSet ipaBudgetApprPS = nameToPerSet.get('Core_MDF_CCP_Internal_IPA_Budget_Approver');
            PermissionSet ccfBudgetApprPS = nameToPerSet.get('Core_MDF_CCP_Internal_CCF_MDF_Budget_Approver');
            PermissionSet dcfBudgetApprPS = nameToPerSet.get('Core_MDF_CCP_Internal_DCF_MDF_Budget_Approver');
            
            List<User> userList = new List<User>();
            List<PermissionSetAssignment> permissionSetAssignmentList = new List<PermissionSetAssignment>();
            
            //CMDF
            for(Integer i = 1; i <= 11; i++){
                User cmdfBudgetAppr = Core_MDF_CCP_TestDataUtility.createUser(false);
                cmdfBudgetAppr.profileId = ccpCoreProfile.Id;
                cmdfBudgetAppr.LastName = 'CMDF Budget Approver' + i;
                userList.add(cmdfBudgetAppr);
            }
            
            //IPA
            for(Integer i = 1; i <= 11; i++){
                User ipaBudgetAppr = Core_MDF_CCP_TestDataUtility.createUser(false);
                ipaBudgetAppr.profileId = ccpCoreProfile.Id;
                ipaBudgetAppr.LastName = 'IPA Budget Approver' + i;
                userList.add(ipaBudgetAppr);
            }
            
            //CCF
            for(Integer i = 1; i <= 11; i++){
                User ccfBudgetAppr = Core_MDF_CCP_TestDataUtility.createUser(false);
                ccfBudgetAppr.profileId = ccpCoreProfile.Id;
                ccfBudgetAppr.LastName = 'CCF Budget Approver' + i;
                userList.add(ccfBudgetAppr);
            }
            
            //DCF
            for(Integer i = 1; i <= 11; i++){
                User dcfBudgetAppr = Core_MDF_CCP_TestDataUtility.createUser(false);
                dcfBudgetAppr.profileId = ccpCoreProfile.Id;
                dcfBudgetAppr.LastName = 'DCF Budget Approver' + i;
                userList.add(dcfBudgetAppr);
            }
            
            insert userList;

            for(User usr : userList){
                PermissionSetAssignment psa11 = new PermissionSetAssignment();
                if(usr.LastName.startsWith('CMDF')){
                    psa11 = new PermissionSetAssignment(PermissionSetId = cmdfBudgetApprPS.Id, AssigneeId = usr.Id);
                }else if(usr.LastName.startsWith('IPA')){
                    psa11 = new PermissionSetAssignment(PermissionSetId = ipaBudgetApprPS.Id, AssigneeId = usr.Id);
                }else if(usr.LastName.startsWith('CCF')){
                    psa11 = new PermissionSetAssignment(PermissionSetId = ccfBudgetApprPS.Id, AssigneeId = usr.Id);
                }else if(usr.LastName.startsWith('DCF')){
                    psa11 = new PermissionSetAssignment(PermissionSetId = dcfBudgetApprPS.Id, AssigneeId = usr.Id);
                }
                
                permissionSetAssignmentList.add(psa11);
            }
            
            insert permissionSetAssignmentList;
	
            List<Core_MDF_Criteria__c> approvalCriteriaList = new List<Core_MDF_Criteria__c>();
            Core_MDF_Criteria__c approvalCriteriaCmdf = new Core_MDF_Criteria__c(Core_MDF_Object_Type__c = 'PartnerMarketingBudget', 
                                                                            Core_MDF_Approval_Criteria_Ref_Code_txt__c = 'Budget_Appr_003',
                                                                            Core_MDF_Approval_Process__c = 'Core_MDF_Channel_MDF_Budget_Approval', 
                                                                            Core_MDF_Field_Name_1__c = 'Core_MDF_Program_Nm__c', Core_MDF_Operator_1__c = 'Equal', 
                                                                            Core_MDF_Value_1__c = 'Channel MDF');
            approvalCriteriaList.add(approvalCriteriaCmdf);
            
            Core_MDF_Criteria__c approvalCriteriaIpa = new Core_MDF_Criteria__c(Core_MDF_Object_Type__c = 'PartnerMarketingBudget', 
                                                                            Core_MDF_Approval_Criteria_Ref_Code_txt__c = 'Budget_Appr_004',
                                                                            Core_MDF_Approval_Process__c = 'Core_MDF_IPA_Budget_Approval', 
                                                                            Core_MDF_Field_Name_1__c = 'Core_MDF_Program_Nm__c', Core_MDF_Operator_1__c = 'Equal', 
                                                                            Core_MDF_Value_1__c = 'Intel Partner Alliance');
            approvalCriteriaList.add(approvalCriteriaIpa);
            
            Core_MDF_Criteria__c approvalCriteriaCcf = new Core_MDF_Criteria__c(Core_MDF_Object_Type__c = 'PartnerMarketingBudget', 
                                                                            Core_MDF_Approval_Criteria_Ref_Code_txt__c = 'Budget_Appr_001',
                                                                            Core_MDF_Approval_Process__c = 'Core_MDF_CCF_Budget_Approval', 
                                                                            Core_MDF_Field_Name_1__c = 'Core_MDF_Program_Nm__c', Core_MDF_Operator_1__c = 'Equal', 
                                                                            Core_MDF_Value_1__c = 'Client Co-Marketing Fund');
            approvalCriteriaList.add(approvalCriteriaCcf);
            
            Core_MDF_Criteria__c approvalCriteriaDcf = new Core_MDF_Criteria__c(Core_MDF_Object_Type__c = 'PartnerMarketingBudget', 
                                                                            Core_MDF_Approval_Criteria_Ref_Code_txt__c = 'Budget_Appr_002',
                                                                            Core_MDF_Approval_Process__c = 'Core_MDF_DCF_Budget_Approval', 
                                                                            Core_MDF_Field_Name_1__c = 'Core_MDF_Program_Nm__c', Core_MDF_Operator_1__c = 'Equal', 
                                                                            Core_MDF_Value_1__c = 'Data Center Co-Marketing Fund');
            approvalCriteriaList.add(approvalCriteriaDcf);
            
            insert approvalCriteriaList;
        }
    }
    
    @isTest
    static void createApproverAndCriteriaRuleRecordsForChannelMDF(){
        Test.startTest();
        Account acc = [SELECT Id FROM Account WHERE Name = 'CMDF_Intel_Account'];
        
        List<User> userCMDF = [SELECT Id FROM User WHERE LastName LIKE 'CMDF Budget Approver%'];
        
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();

        for(User usr : userCMDF){
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgm.Core_MDF_Program_nm__c = 'Channel MDF';
            iupgm.Core_MDF_Region_Sub_Region_nm__c = 'WW';
            iupgm.Core_MDF_Account_id__c=acc.id;
            iupgm.Core_MDF_All_Budget_Type_Access_Ind__c = false;
            iupgm.Core_MDF_User_id__c = usr.Id;
            iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_Channel_MDF_Budget_Approver';
            iupgm.Core_MDF_All_Accounts_cd__c = 'No';
            iupgm.Core_MDF_Budget_Type_nm__c='Intel MDF Account Based2';
            iupgm.Core_MDF_CMDF_GeoSubGeo_BudgetType_nm__c='WW->Intel MDF Account Based2';
            
            iupgmList.add(iupgm);
        }
        
		
        insert iupgmList;
        
        Test.stopTest();   
    }    
    
    @isTest
    static void createApproverAndCriteriaRuleRecordsForIPA(){
        Test.startTest();
        Account acc = [SELECT Id FROM Account WHERE Name = 'CMDF_Intel_Account'];
        
        List<User> userCMDF = [SELECT Id FROM User WHERE LastName LIKE 'IPA Budget Approver%'];
        
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();

        for(User usr : userCMDF){
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgm.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
            iupgm.Core_MDF_Account_id__c=acc.id;
            iupgm.Core_MDF_All_Budget_Type_Access_Ind__c = false;
            iupgm.Core_MDF_User_id__c = usr.Id;
            iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_IPA_Budget_Approver';
            iupgm.Core_MDF_All_Accounts_cd__c = 'No';
            iupgm.Core_MDF_Budget_Type_nm__c='Client Specialties MDF';
            
            iupgmList.add(iupgm);
        }
        
		
        insert iupgmList;
        
        Test.stopTest();   
    } 
    
    @isTest
    static void createApproverAndCriteriaRuleRecordsForCCF(){
        Test.startTest();
        Account acc = [SELECT Id FROM Account WHERE Name = 'CMDF_Intel_Account'];
        
        List<User> userCMDF = [SELECT Id FROM User WHERE LastName LIKE 'CCF Budget Approver%'];
        
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();

        for(User usr : userCMDF){
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgm.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
            iupgm.Core_MDF_Account_id__c=acc.id;
            iupgm.Core_MDF_User_id__c = usr.Id;
            iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_MDF_Budget_Approver';
            iupgm.Core_MDF_All_Accounts_cd__c = 'No';
            iupgm.Core_MDF_Region_Sub_Region_nm__c = 'WW';
            
            iupgmList.add(iupgm);
        }
        
		
        insert iupgmList;
        
        for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : iupgmList){
            iupgm.Core_MDF_Active_Ind__c = false;
        }

        update iupgmList;
        
        Test.stopTest();   
    } 
    
     @isTest
    static void inactivateIupgmRecordsToRemoveApproversCCF(){
        Test.startTest();

        Account acc = [SELECT Id FROM Account WHERE Name = 'CMDF_Intel_Account'];

        ChannelProgram ccfchannelprogram = [SELECT Id FROM ChannelProgram WHERE Name = 'Client Co-Marketing Fund'];
        
        List<User> userCMDF = [SELECT Id FROM User WHERE LastName LIKE 'CCF Budget Approver%'];

        Core_MDF_Criteria__c approvalCriteria = [SELECT Id, Core_MDF_Object_Type__c, Core_MDF_Approval_Criteria_Ref_Code_txt__c, Core_MDF_Approval_Process__c, 
                                                    Core_MDF_Field_Name_1__c, Core_MDF_Operator_1__c, Core_MDF_Value_1__c 
                                                    FROM Core_MDF_Criteria__c WHERE Core_MDF_Object_Type__c = 'PartnerMarketingBudget' AND Core_MDF_Approval_Criteria_Ref_Code_txt__c = 'Budget_Appr_001' LIMIT 1];

        //Creating Approver Set record
        Core_MDF_Approver__c approverRecord = Core_MDF_CCP_TestDataUtility.createApprover(approvalCriteria.Id, userCMDF[0].Id, false);
        approverRecord.Core_MDF_Approver_Type__c = 'Internal';
        approverRecord.Core_MDF_Approver_2__c = userCMDF[1].Id;
        approverRecord.Core_MDF_Approver_3__c = userCMDF[2].Id;
        approverRecord.Core_MDF_Approver_4__c = userCMDF[3].Id;
        approverRecord.Core_MDF_Approver_5__c = userCMDF[4].Id;
        approverRecord.Core_MDF_Approver_6__c = userCMDF[5].Id;
        approverRecord.Core_MDF_Approver_7__c = userCMDF[6].Id;
        approverRecord.Core_MDF_Approver_8__c = userCMDF[7].Id;
        approverRecord.Core_MDF_Approver_9__c = userCMDF[8].Id;
        approverRecord.Core_MDF_Approver_10__c = userCMDF[9].Id;
        insert approverRecord;

        List<Core_MDF_Criteria_Rule__c> cruleList = new List<Core_MDF_Criteria_Rule__c>();
        Core_MDF_Criteria_Rule__c crule1 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(approverRecord.Id, 'Core_MDF_Ultimate_Account_Id__c', 'Equal', acc.Id, false);
        cruleList.add(crule1);

        Core_MDF_Criteria_Rule__c crule2 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(approverRecord.Id, 'Core_MDF_Program__c', 'Equal', ccfchannelprogram.Id, false);
        cruleList.add(crule2);

        insert cruleList;

        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        
        for(User usr : userCMDF){
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgm.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
            iupgm.Core_MDF_Account_id__c=acc.id;
            iupgm.Core_MDF_User_id__c = usr.Id;
            iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_MDF_Budget_Approver';
            iupgm.Core_MDF_All_Accounts_cd__c = 'No';
            iupgm.Core_MDF_Region_Sub_Region_nm__c = 'WW';
            
            iupgmList.add(iupgm);
        }
        
        insert iupgmList;

        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmListToUpdate = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : iupgmList){
            iupgm.Core_MDF_Active_Ind__c = false;
            iupgmListToUpdate.add(iupgm);
        }

        update iupgmListToUpdate;
        
        Test.stopTest();   
    }


    @isTest
    static void activateIupgmRecordsToAddApproversCCF(){
        Test.startTest();

        Account acc = [SELECT Id FROM Account WHERE Name = 'CMDF_Intel_Account'];
        Account acc1 = [SELECT Id FROM Account WHERE Name = 'CMDF_Intel_Account1'];

        ChannelProgram ccfchannelprogram = [SELECT Id FROM ChannelProgram WHERE Name = 'Client Co-Marketing Fund'];
        
        List<User> userCMDF = [SELECT Id FROM User WHERE LastName LIKE 'CCF Budget Approver%'];

        Core_MDF_Criteria__c approvalCriteria = [SELECT Id, Core_MDF_Object_Type__c, Core_MDF_Approval_Criteria_Ref_Code_txt__c, Core_MDF_Approval_Process__c, 
                                                    Core_MDF_Field_Name_1__c, Core_MDF_Operator_1__c, Core_MDF_Value_1__c 
                                                    FROM Core_MDF_Criteria__c WHERE Core_MDF_Object_Type__c = 'PartnerMarketingBudget' AND Core_MDF_Approval_Criteria_Ref_Code_txt__c = 'Budget_Appr_001' LIMIT 1];

        //Creating Approver Set record
        List<Core_MDF_Approver__c> approverList = new List<Core_MDF_Approver__c>();

        Core_MDF_Approver__c approverRecord = Core_MDF_CCP_TestDataUtility.createApprover(approvalCriteria.Id, userCMDF[0].Id, false);
        approverRecord.Core_MDF_Approver_Type__c = 'Internal';
        approverList.add(approverRecord);

        Core_MDF_Approver__c approverRecord1 = Core_MDF_CCP_TestDataUtility.createApprover(approvalCriteria.Id, userCMDF[1].Id, false);
        approverRecord1.Core_MDF_Approver_Type__c = 'Internal';
        approverList.add(approverRecord1);

        insert approverList;

        List<Core_MDF_Criteria_Rule__c> cruleList = new List<Core_MDF_Criteria_Rule__c>();

        Core_MDF_Criteria_Rule__c crule1 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(approverRecord.Id, 'Core_MDF_Ultimate_Account_Id__c', 'Equal', acc.Id, false);
        cruleList.add(crule1);

        Core_MDF_Criteria_Rule__c crule2 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(approverRecord.Id, 'Core_MDF_Program__c', 'Equal', ccfchannelprogram.Id, false);
        cruleList.add(crule2);

        Core_MDF_Criteria_Rule__c crule3 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(approverRecord.Id, 'Core_MDF_Ultimate_Account_Id__c', 'Equal', acc1.Id, false);
        cruleList.add(crule3);

        Core_MDF_Criteria_Rule__c crule4 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(approverRecord.Id, 'Core_MDF_Program__c', 'Equal', ccfchannelprogram.Id, false);
        cruleList.add(crule4);

        insert cruleList;

        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        
        for(User usr : userCMDF){
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgm.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
            iupgm.Core_MDF_Account_id__c=acc.id;
            iupgm.Core_MDF_User_id__c = usr.Id;
            iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_MDF_Budget_Approver';
            iupgm.Core_MDF_All_Accounts_cd__c = 'No';
            iupgm.Core_MDF_Region_Sub_Region_nm__c = 'WW';
            
            iupgmList.add(iupgm);
        }
        
		
        insert iupgmList;

        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmListToUpdate = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : iupgmList){
            iupgm.Core_MDF_Active_Ind__c = true;
            iupgmListToUpdate.add(iupgm);
        }

        update iupgmListToUpdate;
        
        Test.stopTest();   
    }
    
    
    @isTest
    static void createApproverAndCriteriaRuleRecordsForDCF(){
        Test.startTest();
        Account acc = [SELECT Id FROM Account WHERE Name = 'CMDF_Intel_Account'];
        
        List<User> userCMDF = [SELECT Id FROM User WHERE LastName LIKE 'DCF Budget Approver%'];
        
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();

        for(User usr : userCMDF){
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgm.Core_MDF_Program_nm__c = 'Data Center CoMarketing Fund';
            iupgm.Core_MDF_Account_id__c=acc.id;
            iupgm.Core_MDF_User_id__c = usr.Id;
            iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_DCF_MDF_Budget_Approver';
            iupgm.Core_MDF_All_Accounts_cd__c = 'No';
            iupgm.Core_MDF_Region_Sub_Region_nm__c = 'WW';
            
            iupgmList.add(iupgm);
        }
        
		
        insert iupgmList;
        
        Test.stopTest();   
    } 


    @isTest
    static void inactivateIupgmRecordsToRemoveApprovers(){
        Test.startTest();

        Account acc = [SELECT Id FROM Account WHERE Name = 'CMDF_Intel_Account'];

        ChannelProgram cmdfchannelprogram = [SELECT Id FROM ChannelProgram WHERE Name = 'Channel MDF'];
        
        List<User> userCMDF = [SELECT Id FROM User WHERE LastName LIKE 'CMDF Budget Approver%'];

        Core_MDF_Criteria__c approvalCriteria = [SELECT Id, Core_MDF_Object_Type__c, Core_MDF_Approval_Criteria_Ref_Code_txt__c, Core_MDF_Approval_Process__c, 
                                                    Core_MDF_Field_Name_1__c, Core_MDF_Operator_1__c, Core_MDF_Value_1__c 
                                                    FROM Core_MDF_Criteria__c WHERE Core_MDF_Object_Type__c = 'PartnerMarketingBudget' AND Core_MDF_Approval_Criteria_Ref_Code_txt__c = 'Budget_Appr_003' LIMIT 1];

        //Creating Approver Set record
        Core_MDF_Approver__c approverRecord = Core_MDF_CCP_TestDataUtility.createApprover(approvalCriteria.Id, userCMDF[0].Id, false);
        approverRecord.Core_MDF_Approver_Type__c = 'Internal';
        approverRecord.Core_MDF_Approver_2__c = userCMDF[1].Id;
        approverRecord.Core_MDF_Approver_3__c = userCMDF[2].Id;
        approverRecord.Core_MDF_Approver_4__c = userCMDF[3].Id;
        approverRecord.Core_MDF_Approver_5__c = userCMDF[4].Id;
        approverRecord.Core_MDF_Approver_6__c = userCMDF[5].Id;
        approverRecord.Core_MDF_Approver_7__c = userCMDF[6].Id;
        approverRecord.Core_MDF_Approver_8__c = userCMDF[7].Id;
        approverRecord.Core_MDF_Approver_9__c = userCMDF[8].Id;
        approverRecord.Core_MDF_Approver_10__c = userCMDF[9].Id;
        insert approverRecord;

        List<Core_MDF_Criteria_Rule__c> cruleList = new List<Core_MDF_Criteria_Rule__c>();
        Core_MDF_Criteria_Rule__c crule1 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(approverRecord.Id, 'Core_MDF_Ultimate_Account_Id__c', 'Equal', acc.Id, false);
        cruleList.add(crule1);

        Core_MDF_Criteria_Rule__c crule2 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(approverRecord.Id, 'Core_MDF_Program__c', 'Equal', cmdfchannelprogram.Id, false);
        cruleList.add(crule2);

        insert cruleList;

        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        
        for(User usr : userCMDF){
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgm.Core_MDF_Program_nm__c = 'Channel MDF';
            iupgm.Core_MDF_Region_Sub_Region_nm__c = 'WW';
            iupgm.Core_MDF_Account_id__c=acc.id;
            iupgm.Core_MDF_All_Budget_Type_Access_Ind__c = false;
            iupgm.Core_MDF_User_id__c = usr.Id;
            iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_Channel_MDF_Budget_Approver';
            iupgm.Core_MDF_All_Accounts_cd__c = 'No';
            iupgm.Core_MDF_Budget_Type_nm__c='Client Specialties MDF';
            iupgm.Core_MDF_CMDF_GeoSubGeo_BudgetType_nm__c='WW->Intel MDF Account Based2';
            
            iupgmList.add(iupgm);
        }
        
		
        insert iupgmList;

        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmListToUpdate = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : iupgmList){
            iupgm.Core_MDF_Active_Ind__c = false;
            iupgmListToUpdate.add(iupgm);
        }

        update iupgmListToUpdate;
        
        Test.stopTest();   
    }


    @isTest
    static void activateIupgmRecordsToAddApprovers(){
        Test.startTest();

        Account acc = [SELECT Id FROM Account WHERE Name = 'CMDF_Intel_Account'];
        Account acc1 = [SELECT Id FROM Account WHERE Name = 'CMDF_Intel_Account1'];

        ChannelProgram cmdfchannelprogram = [SELECT Id FROM ChannelProgram WHERE Name = 'Channel MDF'];
        
        List<User> userCMDF = [SELECT Id FROM User WHERE LastName LIKE 'CMDF Budget Approver%'];

        Core_MDF_Criteria__c approvalCriteria = [SELECT Id, Core_MDF_Object_Type__c, Core_MDF_Approval_Criteria_Ref_Code_txt__c, Core_MDF_Approval_Process__c, 
                                                    Core_MDF_Field_Name_1__c, Core_MDF_Operator_1__c, Core_MDF_Value_1__c 
                                                    FROM Core_MDF_Criteria__c WHERE Core_MDF_Object_Type__c = 'PartnerMarketingBudget' AND Core_MDF_Approval_Criteria_Ref_Code_txt__c = 'Budget_Appr_003' LIMIT 1];

        //Creating Approver Set record
        List<Core_MDF_Approver__c> approverList = new List<Core_MDF_Approver__c>();

        Core_MDF_Approver__c approverRecord = Core_MDF_CCP_TestDataUtility.createApprover(approvalCriteria.Id, userCMDF[0].Id, false);
        approverRecord.Core_MDF_Approver_Type__c = 'Internal';
        approverList.add(approverRecord);

        Core_MDF_Approver__c approverRecord1 = Core_MDF_CCP_TestDataUtility.createApprover(approvalCriteria.Id, userCMDF[1].Id, false);
        approverRecord1.Core_MDF_Approver_Type__c = 'Internal';
        approverList.add(approverRecord1);

        Core_MDF_Approver__c approverRecord2 = Core_MDF_CCP_TestDataUtility.createApprover(approvalCriteria.Id, userCMDF[2].Id, false);
        approverRecord2.Core_MDF_Approver_Type__c = 'Internal';
        approverList.add(approverRecord2);

        insert approverList;

        List<Core_MDF_Criteria_Rule__c> cruleList = new List<Core_MDF_Criteria_Rule__c>();

        Core_MDF_Criteria_Rule__c crule1 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(approverRecord.Id, 'Core_MDF_Ultimate_Account_Id__c', 'Equal', acc.Id, false);
        cruleList.add(crule1);

        Core_MDF_Criteria_Rule__c crule2 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(approverRecord.Id, 'Core_MDF_Program__c', 'Equal', cmdfchannelprogram.Id, false);
        cruleList.add(crule2);

        Core_MDF_Criteria_Rule__c crule3 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(approverRecord1.Id, 'Core_MDF_Ultimate_Account_Id__c', 'Equal', acc1.Id, false);
        cruleList.add(crule3);

        Core_MDF_Criteria_Rule__c crule4 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(approverRecord1.Id, 'Core_MDF_Program__c', 'Equal', cmdfchannelprogram.Id, false);
        cruleList.add(crule4);

        Core_MDF_Criteria_Rule__c crule5 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(approverRecord2.Id, 'Core_MDF_Ultimate_Account_Id__c', 'Equal', acc1.Id, false);
        cruleList.add(crule5);

        Core_MDF_Criteria_Rule__c crule6 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(approverRecord2.Id, 'Core_MDF_Program__c', 'Equal', cmdfchannelprogram.Id, false);
        cruleList.add(crule6);

        Core_MDF_Criteria_Rule__c crule7 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(approverRecord2.Id, 'Core_MDF_Budget_Type_Txt__c', 'Equal', 'Intel MDF Account Based2', false);
        cruleList.add(crule7);

        insert cruleList;

        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        
        Integer recCount = 0;
        for(User usr : userCMDF){
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgm.Core_MDF_Program_nm__c = 'Channel MDF';
            iupgm.Core_MDF_Region_Sub_Region_nm__c = 'WW';
            iupgm.Core_MDF_Account_id__c=acc.id;
            iupgm.Core_MDF_User_id__c = usr.Id;
            iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_Channel_MDF_Budget_Approver';
            iupgm.Core_MDF_All_Accounts_cd__c = 'No';
            if(recCount <= 5){
                iupgm.Core_MDF_All_Budget_Type_Access_Ind__c = false;
                iupgm.Core_MDF_Budget_Type_nm__c='Intel MDF Account Based2';
                iupgm.Core_MDF_CMDF_GeoSubGeo_BudgetType_nm__c='WW->Intel MDF Account Based2';
            }else{
                iupgm.Core_MDF_All_Budget_Type_Access_Ind__c = true;  
            }
            
            iupgmList.add(iupgm);
            recCount++;
        }
        
		
        insert iupgmList;

        recCount = 0;
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmListToUpdate = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : iupgmList){
            if(recCount <= 3){
                iupgm.Core_MDF_All_Budget_Type_Access_Ind__c = true;
            }else{
                iupgm.Core_MDF_All_Budget_Type_Access_Ind__c = false;
                iupgm.Core_MDF_Budget_Type_nm__c='Client Market Accelerate';
                iupgm.Core_MDF_CMDF_GeoSubGeo_BudgetType_nm__c='WW->Client Market Accelerate';
            }
            iupgmListToUpdate.add(iupgm);
        }

        update iupgmListToUpdate;
        
        Test.stopTest();   
    }

    @isTest
    static void activateIupgmRecordsToAddApproversIPA(){
        Test.startTest();

        Account acc = [SELECT Id FROM Account WHERE Name = 'CMDF_Intel_Account'];
        Account acc1 = [SELECT Id FROM Account WHERE Name = 'CMDF_Intel_Account1'];

        ChannelProgram ipachannelprogram = [SELECT Id FROM ChannelProgram WHERE Name = 'Intel Partner Alliance'];
        
        List<User> userIPA = [SELECT Id FROM User WHERE LastName LIKE 'IPA Budget Approver%'];

        Core_MDF_Criteria__c approvalCriteria = [SELECT Id, Core_MDF_Object_Type__c, Core_MDF_Approval_Criteria_Ref_Code_txt__c, Core_MDF_Approval_Process__c, 
                                                    Core_MDF_Field_Name_1__c, Core_MDF_Operator_1__c, Core_MDF_Value_1__c 
                                                    FROM Core_MDF_Criteria__c WHERE Core_MDF_Object_Type__c = 'PartnerMarketingBudget' AND Core_MDF_Approval_Criteria_Ref_Code_txt__c = 'Budget_Appr_004' LIMIT 1];

        //Creating Approver Set record
        List<Core_MDF_Approver__c> approverList = new List<Core_MDF_Approver__c>();

        Core_MDF_Approver__c approverRecord = Core_MDF_CCP_TestDataUtility.createApprover(approvalCriteria.Id, userIPA[0].Id, false);
        approverRecord.Core_MDF_Approver_Type__c = 'Internal';
        approverList.add(approverRecord);

        Core_MDF_Approver__c approverRecord1 = Core_MDF_CCP_TestDataUtility.createApprover(approvalCriteria.Id, userIPA[1].Id, false);
        approverRecord1.Core_MDF_Approver_Type__c = 'Internal';
        approverList.add(approverRecord1);

        Core_MDF_Approver__c approverRecord2 = Core_MDF_CCP_TestDataUtility.createApprover(approvalCriteria.Id, userIPA[2].Id, false);
        approverRecord2.Core_MDF_Approver_Type__c = 'Internal';
        approverList.add(approverRecord2);

        insert approverList;

        List<Core_MDF_Criteria_Rule__c> cruleList = new List<Core_MDF_Criteria_Rule__c>();

        Core_MDF_Criteria_Rule__c crule1 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(approverRecord.Id, 'Core_MDF_Ultimate_Account_Id__c', 'Equal', acc.Id, false);
        cruleList.add(crule1);

        Core_MDF_Criteria_Rule__c crule2 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(approverRecord.Id, 'Core_MDF_Program__c', 'Equal', ipachannelprogram.Id, false);
        cruleList.add(crule2);

        Core_MDF_Criteria_Rule__c crule3 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(approverRecord1.Id, 'Core_MDF_Ultimate_Account_Id__c', 'Equal', acc1.Id, false);
        cruleList.add(crule3);

        Core_MDF_Criteria_Rule__c crule4 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(approverRecord1.Id, 'Core_MDF_Program__c', 'Equal', ipachannelprogram.Id, false);
        cruleList.add(crule4);

        Core_MDF_Criteria_Rule__c crule5 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(approverRecord2.Id, 'Core_MDF_Ultimate_Account_Id__c', 'Equal', acc1.Id, false);
        cruleList.add(crule5);

        Core_MDF_Criteria_Rule__c crule6 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(approverRecord2.Id, 'Core_MDF_Program__c', 'Equal', ipachannelprogram.Id, false);
        cruleList.add(crule6);

        Core_MDF_Criteria_Rule__c crule7 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(approverRecord2.Id, 'Core_MDF_Budget_Type_Txt__c', 'Equal', 'Client Specialties MDF', false);
        cruleList.add(crule7);

        insert cruleList;

        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        
        Integer recCount = 0;
        for(User usr : userIPA){
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgm.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
            iupgm.Core_MDF_Region_Sub_Region_nm__c = 'WW';
            iupgm.Core_MDF_User_id__c = usr.Id;
            iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_IPA_Budget_Approver';
            if(recCount <= 3){
                iupgm.Core_MDF_All_Accounts_cd__c = 'Yes';
                iupgm.Core_MDF_All_Budget_Type_Access_Ind__c = false;
                iupgm.Core_MDF_Budget_Type_nm__c='Data Center Specialties MDF';
                iupgm.Core_MDF_GeoSubGeo_Budget_Type_nm__c='WW->Data Center Specialties MDF';
            }else if(recCount > 3 && recCount <= 5){
                iupgm.Core_MDF_All_Accounts_cd__c = 'No';
                iupgm.Core_MDF_Account_id__c=acc.id;
                iupgm.Core_MDF_All_Budget_Type_Access_Ind__c = false;
                iupgm.Core_MDF_Budget_Type_nm__c='Data Center Specialties MDF';
                iupgm.Core_MDF_GeoSubGeo_Budget_Type_nm__c='WW->Data Center Specialties MDF';
            }else if(recCount > 5 && recCount <= 8){
                iupgm.Core_MDF_Account_id__c=acc.id;
                iupgm.Core_MDF_All_Accounts_cd__c = 'No';
                iupgm.Core_MDF_All_Budget_Type_Access_Ind__c = true;
            }else{
                iupgm.Core_MDF_All_Accounts_cd__c = 'Yes';
                iupgm.Core_MDF_All_Budget_Type_Access_Ind__c = true;
            }
            
            iupgmList.add(iupgm);
            recCount++;
        }
        
		
        insert iupgmList;

        recCount = 0;
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmListToUpdate = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : iupgmList){

            if(recCount <= 3){
                iupgm.Core_MDF_All_Budget_Type_Access_Ind__c = true;
            }else{
                iupgm.Core_MDF_All_Budget_Type_Access_Ind__c = false;
                iupgm.Core_MDF_Budget_Type_nm__c='Scale Acceleration - MDF';
                iupgm.Core_MDF_GeoSubGeo_Budget_Type_nm__c='WW->Scale Acceleration - MDF';
            }
            iupgmListToUpdate.add(iupgm);
        }

        update iupgmListToUpdate;
        
        Test.stopTest();   
    }*/
}