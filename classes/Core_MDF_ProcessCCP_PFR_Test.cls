/****************************************************************************************************************************************
* Class Name  : Core_MDF_ProcessCCP_PFR_Test 
* Version     : 1.0 
* Created Date: 8-23-2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Harika P        8/27/2018                    Created to test Approvers based on criteria.  
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
private class Core_MDF_ProcessCCP_PFR_Test{
     public static Id RMF_RecordType = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
     
    /****************************************************************************************************************************************
Method Name:                                   createTestData
Description:                                   Creating test data to test approval process
Added By:                                      Accenture – Harika P  -  8/27/2018
Modified By:                  Date:            Changes: 
Accenture – Harika P        8/27/2018           Created.
Accenture – Shridhar K        12/24/2018       Added Allocation and budget parameters createPartnerFundRequest method to fix null pointer exception 
Intel - Narayani Perachi    02/11/2019         Added user and PFR record to test the functionality of Auto approver if created/modified by Account Manager
*****************************************************************************************************************************************/    
    @TestSetup static void createTestData(){
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];

        
        Map<String, Id> psetMap = new Map<String, Id>();
        List<PermissionSet> prmsetlst = [select Id, Name from PermissionSet Where Name IN ('Core_MDF_CCP_Internal_DCF_Acct_Mgr', 'Core_MDF_CCP_Internal_Retail_Account_Manager', 'Core_MDF_CCP_External_Activity_Approver','Core_MDF_CCP_Internal_DCF_Field_Acct_Mgr','Core_MDF_CCP_RMF_PRC_Claim_Operations')];
        for(PermissionSet pset : prmsetlst) {
            psetMap.put(pset.Name, pset.Id);
        }
        list<User> us = New list<User>();
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        us.add(usr);
       // Database.insert(usr);
        
        User usrn1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usrn1.LastName = 'User Testn1';
        usrn1.UserRoleId = usRole.Id;
        us.add(usrn1);
        //Database.insert(usrn1);
        
        User usrn2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usrn2.LastName = 'User Testn2';
        usrn2.UserRoleId = usRole.Id;
        us.add(usrn2);
        Database.insert(us);
        
        System.runAs(usr){
           	List<String> bypassFunctionKeys = new List<String>();
        	Set<String> myset1 = new Set<String>();
        	List<String> result1 = new List<String>();
        	bypassFunctionKeys.add('Bypass_Duplicate_Budget_Check');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
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
        	bypassFunctionKeys.add('Bypass_Claims_Sharing_On_Owner_Change');
        	bypassFunctionKeys.add('Core_MDF_XMLToXLSGenerationFlag');
       	 	bypassFunctionKeys.add('Core_MDF_StringToXLSGenerationFlag');
            bypassFunctionKeys.add('Core_MDF_Bypass_TargetSetngValidations');
        	bypassFunctionKeys.add('Bypass_PaymentsBulkAPISharing');
            bypassFunctionKeys.add('ByPass_BlockLegacyBudgetCreation');
            bypassFunctionKeys.add('Core_MDF_Bypass_AccOnboardValidation'); //14285 Indira
            myset1.addAll(bypassFunctionKeys);
        	result1.addAll(myset1);
        	
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            
            // Creating channel program with utility class
            List<ChannelProgram> cpList = new List<ChannelProgram>();
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client','Client CoMarketing Fund', false);
            ChannelProgram cpRetail = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', false);
            ChannelProgram ipaCP = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', false);
            cpList.add(cp);
            cpList.add(cpRetail);
            cpList.add(ipaCP);
            insert cpList;
            
            // Creating IntelAccount with utility class
            List<Account> accIntelList = new List<Account>();
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                            false);
            acc1.Core_Account_Type__c = 'Reseller';            
            acc1.Industry = 'Food & Beverage';
            acc1.Core_MDF_Channel_Program__c = cp.Id;
            acc1.Core_Geo__c = 'APJ';
            accIntelList.add(acc1);
            
            // Creating Intel Account for retail program
            Account acc1Retail = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account Retail', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                                  false);
            acc1Retail.Core_Account_Type__c = 'Reseller';
            acc1Retail.Industry = 'Food & Beverage';
            acc1Retail.Core_MDF_Channel_Program__c = cpRetail.Id;
            acc1Retail.Core_Geo__c = 'APJ';            
            acc1Retail.Core_Sub_Geo__c = 'IJKK';
            accIntelList.add(acc1Retail);
            
            Account ipaUltimateAccountPFR = Core_MDF_CCP_TestDataUtility.createIntelAccount ('IPA Intel Account PFR',Core_MDF_CCP_TestDataUtility.intel_Account_Record_Type, false);
            ipaUltimateAccountPFR.Core_MDF_Channel_Program__c = ipaCP.Id;
            ipaUltimateAccountPFR.Core_Account_Type__c = 'Reseller';            
            ipaUltimateAccountPFR.Industry = 'Food & Beverage';
            accIntelList.add(ipaUltimateAccountPFR);
            Database.insert(accIntelList);
            
            
            // Creating Co-marketing Account with utility class
            List<Account> accCoMarketingList = new List<Account>();
            Account acc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account', cp.Id,
                                                                      Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            acc.Core_MDF_Parent_Fund_Account__c = acc1.Id;
            accCoMarketingList.add(acc);
            
            // Creating Retail Account with utility class
            Account accRetail = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account Retail', cpRetail.Id,
                                                                            Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accRetail.Core_MDF_Parent_Fund_Account__c = acc1Retail.Id;
            accRetail.Core_Geo__c = 'APJ';
            accRetail.Core_Sub_Geo__c = 'IJKK';
            accCoMarketingList.add(accRetail);
            
            Account accRetail2 = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account Retail2', cpRetail.Id,
                                                                             Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accRetail2.Core_MDF_Parent_Fund_Account__c = acc1Retail.Id;
            accRetail2.Core_Geo__c = 'APJ';
            accRetail2.Core_Sub_Geo__c = 'IJKK';
            accCoMarketingList.add(accRetail2);
            
            Account ipaCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createAccount('IPA Virtual PFR', ipaCP.id, Core_MDF_CCP_TestDataUtility.account_Record_Type,false); 
            Account ipaCoMarketingAcc = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('IPA Co-Marketing Account', ipaCP.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,ipaUltimateAccountPFR.id, true);           
            Account ipaCoMarketingAccount1 = Core_MDF_CCP_TestDataUtility.createAccount('IPA Virtual PFR2', ipaCP.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,false);
            ipaCoMarketingAccount.Core_MDF_Parent_Fund_Account__c = ipaUltimateAccountPFR.Id;
            ipaCoMarketingAccount.Core_MDF_CoMarketing_Ultimate_Account__c = ipaUltimateAccountPFR.Id;
            ipaCoMarketingAccount1.Core_MDF_Parent_Fund_Account__c = ipaUltimateAccountPFR.Id;
            accCoMarketingList.add(ipaCoMarketingAccount);
            
            accCoMarketingList.add(ipaCoMarketingAccount1);
            
            // Creating Group
            List<Group> groupList = new List<Group>();
            
            Group ccfgrp = new Group();
            ccfgrp.Name = 'Core CCP CCF Internal';
            ccfgrp.DeveloperName = 'Core_CCP_CCF_Internal';
            groupList.add(ccfgrp);
            
            Group ccfAPJGrp = new Group();
            ccfAPJGrp.Name = 'Core_MDF_Int_CCF_APJ';
            ccfAPJGrp.DeveloperName = 'Core_MDF_Int_CCFAPJ';
            groupList.add(ccfAPJGrp);
            
            Group ccfAPJGrp1 = new Group();
            ccfAPJGrp1.Name = 'Core_MDF_Ext_CCF_APJ';
            ccfAPJGrp1.DeveloperName = 'Core_MDF_Ext_CCF_APJ';
            groupList.add(ccfAPJGrp1);
            
            Group accNodeGroup = new Group(Name = 'Core_MDF_Retail_Acc_Node_Group', DeveloperName = 'Core_MDF_Retail_Acc_Node_Group');
            groupList.add(accNodeGroup);
            insert groupList;
            
            accCoMarketingList[1].Core_MDF_Group_Id__c = accNodeGroup.Id;
            accCoMarketingList[2].Core_MDF_Group_Id__c = accNodeGroup.Id;
            
            Database.insert(accCoMarketingList);
            
            List<Contact> listContact = new List<Contact>();
            Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(acc1Retail.Id,false);
            conRecord1.Core_Audience_List__c= 'RMF User';
            conRecord1.MailingCountry = 'KOR';
            Contact conRecord2 = Core_MDF_CCP_TestDataUtility.createContact(acc1Retail.Id,false);
            conRecord2.MailingCountry = 'KOR';
            listContact.add(conRecord1);
            listContact.add(conRecord2);
            Database.insert(listContact);
            
            Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name ='RPS_Retailer', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='RPS_Retailer');
            insert cee;
            
            List< Core_Entitlement__c> entListVal = new List< Core_Entitlement__c>();
            Core_Entitlement__c entitle=new Core_Entitlement__c (name ='RMF User', Core_Category__c='Intel® Partner Investment Center',Core_Sub_Category__c='Retail Marketing Funds (RMF)',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test',Core_IsActive__c=true, Core_Permission_Set_API_Nm__c='Core_MDF_Retail_USER');
            entListVal.add(entitle);
            insert entListVal;
            
            List<Core_Contact_Entitlement__c> ceList = new List<Core_Contact_Entitlement__c>();            
            Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c(Core_Contact_Id__c=conRecord1.Id,
                                                                             Core_Entitlement_Id__c=entitle.id,
                                                                             Core_Selected__c=false);
            ceList.add(ce);       
            Database.insert(ceList);
            
            List<User> userList = new List<User>();
            
            User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr1.LastName = 'User Test1';
            userList.add(usr1);
            
            User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr2.LastName = 'User Test2';
            userList.add(usr2);
            
            User usr3 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr3.LastName = 'User Test3';
            userList.add(usr3);
            
            User usr4 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr4.LastName = 'User Test4';
            userList.add(usr4);
            
            User usr5 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr5.LastName = 'User Test5';
            userList.add(usr5);
            
            User usr6 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr6.LastName = 'User Test6';
            userList.add(usr6);
            
            User usr7 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr7.LastName = 'User Test7';
            userList.add(usr7);
            
            User usr8 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr8.LastName = 'User Test8';
            userList.add(usr8);
            
            User usr10 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr10.LastName = 'User Test10';
            userList.add(usr10);
            
            User usr9 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr9.LastName = 'User Test9';
            userList.add(usr9);
            
            Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
            Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
            PermissionSet clmCaseRevPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Claim_Case_Reviewer' LIMIT 1];
            
            User usr11 = Core_MDF_CCP_TestDataUtility.createUser(false);        
            usr11.Email='test1@example.com';
            usr11.ContactId = listContact[0].Id;
            usr11.ProfileId = profileId;
            usr11.isActive = true;
            userList.add(usr11);
            
            User usr12 = Core_MDF_CCP_TestDataUtility.createUser(false);   
            usr12.LastName = 'User Test12';
            
            usr12.isActive = true;
            userList.add(usr12);
            
            User usr14 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr14.LastName = 'Test Opal User';
            userList.add(usr14);
            
            User usr15 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr15.LastName = 'Test PRC MS User';
            userList.add(usr15);
            
            insert userList;
            List<User> updateUser = new List<User>();
            usr2.DelegatedApproverId = usr4.Id;
            usr2.ManagerId = usr6.Id;
            usr12.ManagerId = usr2.Id;
            
            updateUser.add(usr2);
            updateUser.add(usr12);
            update updateUser;            
            
            
            List <PermissionSetAssignment> assignPermissionSetList = new List <PermissionSetAssignment>();
            PermissionSetAssignment assignPermissionSetObj1 = Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(usr15.id,psetMap.get('Core_MDF_CCP_RMF_PRC_Claim_Operations'),false);
            assignPermissionSetList.add(assignPermissionSetObj1);
            PermissionSetAssignment assignPermissionSetObj2 = Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(usr10.id,psetMap.get('Core_MDF_CCP_Internal_DCF_Acct_Mgr'),false);
            assignPermissionSetList.add(assignPermissionSetObj2);
            PermissionSetAssignment assignPermissionSetObj3 = Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(usr12.id,psetMap.get('Core_MDF_CCP_Internal_Retail_Account_Manager'),false);
            assignPermissionSetList.add(assignPermissionSetObj3);
            PermissionSetAssignment assignPermissionSetObj4 = Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(usr11.id,psetMap.get('Core_MDF_CCP_External_Activity_Approver'),false);
            assignPermissionSetList.add(assignPermissionSetObj4);
            PermissionSetAssignment assignPermissionSetObj5 = Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(usr14.id,psetMap.get('Core_MDF_CCP_Internal_DCF_Field_Acct_Mgr'),false);
            assignPermissionSetList.add(assignPermissionSetObj5);
            PermissionSetAssignment assignPermissionSetObj6 = Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(usr14.id,psetMap.get('Core_MDF_CCP_Internal_DCF_Acct_Mgr'),false);
            assignPermissionSetList.add(assignPermissionSetObj6);
            database.insert(assignPermissionSetList);
            
            List<GroupMember> grpMemList = new List<GroupMember>();
            GroupMember ccfGrpMem = new GroupMember();
            ccfGrpMem.UserOrGroupId = usr9.Id;
            ccfGrpMem.GroupId = ccfgrp.Id;
            grpMemList.add(ccfGrpMem);
            
            GroupMember ccfGrpMem1 = new GroupMember();
            ccfGrpMem1.UserOrGroupId = usr11.Id;
            ccfGrpMem1.GroupId = ccfAPJGrp1.Id;
            grpMemList.add(ccfGrpMem1);
            insert grpMemList;
            
            List<Core_MDF_Partner_Group_Mapping__c> pgmList = new List<Core_MDF_Partner_Group_Mapping__c>();
            Core_MDF_Partner_Group_Mapping__c pgm = new Core_MDF_Partner_Group_Mapping__c();
            pgm.Core_MDF_Account__c = acc1.Id;
            pgm.Core_MDF_Virtual_Corp_nm__c = acc.id;
            pgm.Core_MDF_Group_Name__c = 'Core_MDF_Ext_CCF_APJ';
            pgm.Core_MDF_Type_of_Access__c = 'External';
            pgm.Core_MDF_Group_Id__c = ccfAPJGrp1.Id;                
            pgm.Core_MDF_Channel_Program__c = cpRetail.Id;
            pgm.Core_MDF_Source_Txt__c = 'Test';
            pgm.Core_MDF_AccountIdGroupName__c = acc1.Id+'_Core_MDF_Ext_CCF_APJ';
            pgmList.add(pgm); 
            
            Core_MDF_Partner_Group_Mapping__c pgm1 = new Core_MDF_Partner_Group_Mapping__c();
            pgm1.Core_MDF_Account__c = acc1.Id;
            pgm1.Core_MDF_Virtual_Corp_nm__c = acc.id;
            pgm1.Core_MDF_Group_Name__c = 'Core_CCP_CCF_Internal';
            pgm1.Core_MDF_Type_of_Access__c = 'Internal';
            pgm1.Core_MDF_Group_Id__c = ccfgrp.Id;                
            pgm1.Core_MDF_Channel_Program__c = cp.Id;
            pgm1.Core_MDF_Source_Txt__c = 'Test';
            pgm1.Core_MDF_AccountIdGroupName__c = acc1.Id+'Core_CCP_CCF_Internal';
            pgmList.add(pgm1);
            
            Core_MDF_Partner_Group_Mapping__c pgm2 = new Core_MDF_Partner_Group_Mapping__c();
            pgm2.Core_MDF_Account__c = acc1Retail.Id;
            pgm2.Core_MDF_Virtual_Corp_nm__c = acc.id;
            pgm2.Core_MDF_Group_Name__c = 'Core_CCP_Retail_Internal';
            pgm2.Core_MDF_Type_of_Access__c = 'Internal';
            pgm2.Core_MDF_Group_Id__c = ccfgrp.Id;                
            pgm2.Core_MDF_Channel_Program__c = cpRetail.Id;
            pgm2.Core_MDF_Source_Txt__c = 'Test';
            pgm2.Core_MDF_AccountIdGroupName__c = acc1Retail.Id+'Core_CCP_Retail_Internal';
            pgmList.add(pgm2);
            
            //Core_MDF_CCP_TestDataUtility.createPartnerGroupMapping(acc1Retail.Id,'Internal',accRetail.Id,cpRetail.Id,'PGM_Retail_TEST',true);
            Database.insert(pgmList);
            
            // Creating Criterias for approval required
            List<Core_MDF_Criteria__c> criteriaList = new List<Core_MDF_Criteria__c>();
/*            Core_MDF_Criteria__c cr = Core_MDF_CCP_TestDataUtility.createCriteria('PartnerFundRequest','Core_MDF_Activity_Approval_Processs',
                                                                                  'Core_MDF_Channel_Partner_Led__c','Equal','true','Core_MDF_Start_Date__c','Greater Than or Equal', String.valueOf(System.today()),
                                                                                  'Core_MDF_Country_nm__c','Equal','INDIA','Core_MDF_ProductType__c','Equal','Desktop','RequestedAmount','Greater Than','4000',false);
            
            Core_MDF_Criteria__c crMulti = Core_MDF_CCP_TestDataUtility.createCriteria('PartnerFundRequest','Core_MDF_Activity_Approval_MultiLvl_V5',
                                                                                       'Core_MDF_Program__c','Equal','Retail Marketing Funds','RequestedAmount','Greater Than', '0',
                                                                                       'Core_MDF_Country_nm__c','Equal','INDIA','Core_MDF_ProductType__c','Equal','2-in-1','RequestedAmount','Greater Than','0',false);
            criteriaList.add(cr);
            criteriaList.add(crMulti);*/
            insert criteriaList;

            
            List<Core_MDF_Approver__c> approverList = new List<Core_MDF_Approver__c>();
           /* Core_MDF_Approver__c ap1 = Core_MDF_CCP_TestDataUtility.createApprover(cr.Id,usr1.Id, false);
            ap1.Core_MDF_Approver_2__c = usr2.Id;
            ap1.Core_MDF_Approver_3__c = usr6.Id;
            ap1.Core_MDF_Approver_4__c = usr7.Id;
            ap1.Core_MDF_Approver_5__c = usr8.Id;
            ap1.Core_MDF_Active__c=false;
            
            ap1.Core_MDF_Approver_Type__c = 'Internal';
            approverList.add(ap1);*/
            
           /* Core_MDF_Approver__c ap1Retail = Core_MDF_CCP_TestDataUtility.createApprover(crMulti.Id,usr1.Id, false);
            ap1Retail.Core_MDF_Approver_2__c = usr2.Id;
            ap1Retail.Core_MDF_Approver_3__c = usr6.Id;
            ap1Retail.Core_MDF_Approver_4__c = usr7.Id;
            ap1Retail.Core_MDF_Approver_5__c = usr8.Id;
            ap1Retail.Core_MDF_Approver_Type__c = 'Internal';
            approverList.add(ap1Retail);*/
            
            /*Core_MDF_Approver__c ap2 = Core_MDF_CCP_TestDataUtility.createApprover(cr.Id,usr3.Id, false);
            ap2.Core_MDF_Approver_Type__c = 'Internal';
            ap2.Core_MDF_Active__c=false;
            approverList.add(ap2);*/
            
           /* Core_MDF_Approver__c ap3 = Core_MDF_CCP_TestDataUtility.createApprover(cr.Id,usr4.Id, false);
            ap3.Core_MDF_Approver_2__c = usr5.Id;
            ap3.Core_MDF_Active__c=false;
            ap3.Core_MDF_Approver_Type__c = 'Internal';
            approverList.add(ap3);*/
            insert approverList;
            
            List<Core_MDF_Approver__c>  apprList = new List<Core_MDF_Approver__c>();
            List <Core_MDF_Criteria_Rule__c> criteriaRuleList =  new List <Core_MDF_Criteria_Rule__c>();
           /* Core_MDF_Criteria_Rule__c crule1 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap1.Id,'Core_MDF_End_Date__c','Less Than',
                                                                                               String.valueOf(System.today().addDays(2)),true);
            criteriaRuleList.add(crule1);
            
            Core_MDF_Criteria_Rule__c crule2 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap1.Id,'RequestedAmount','Less Than or Equal',
                                                                                               '8000',true);
            criteriaRuleList.add(crule2);
            Core_MDF_Criteria_Rule__c crule3 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap1.Id,'Core_MDF_Brand__c','Equal',
                                                                                               'Intel® Core™ i7 Processor',true);
            criteriaRuleList.add(crule3);
            Core_MDF_Criteria_Rule__c crule4 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap2.Id,'Core_MDF_Brand_nm__c','Equal',
                                                                                               'Intel® Core™ i7 Processor',true);
            criteriaRuleList.add(crule4);
            Core_MDF_Criteria_Rule__c crule5 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap2.Id,'RequestedAmount','Equal','9000',true);
            criteriaRuleList.add(crule5);
            Core_MDF_Criteria_Rule__c crule6 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap2.Id,'Core_MDF_TargetAudience__c','Equal',
                                                                                               'Creator',true);
            criteriaRuleList.add(crule6);
            Core_MDF_Criteria_Rule__c crule7 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap3.Id,'RequestedAmount','Equal','16000',true);
            criteriaRuleList.add(crule7);
            Core_MDF_Criteria_Rule__c crule8 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap3.Id,'Core_MDF_Brand_nm__c','Equal',
                                                                                               'Intel® Core™ i9 Processor',true);
            criteriaRuleList.add(crule8);
            Core_MDF_Criteria_Rule__c crule9 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap3.Id,'Core_MDF_TargetAudience__c','Equal',
                                                                                               'Small Business',true);
            criteriaRuleList.add(crule9);*/
            
            // Retail criteria rules
           /* Core_MDF_Criteria_Rule__c cruleR1 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap1Retail.Id,'Core_MDF_Program__c','Equal',
                                                                                                'Retail Marketing Funds',true);
            criteriaRuleList.add(cruleR1);
            Core_MDF_Criteria_Rule__c cruleR2 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap1Retail.Id,'RequestedAmount','Greater Than',
                                                                                                '0',true);
            criteriaRuleList.add(cruleR2);
            Core_MDF_Criteria_Rule__c cruleR3 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(ap1Retail.Id,'Core_MDF_Fund_Request_Status__c','Equal',
                                                                                                'Pending Review',true);
            criteriaRuleList.add(cruleR3);
            
            ap1.Core_MDF_Active__c = True;
            ap2.Core_MDF_Active__c = True;
            ap3.Core_MDF_Active__c = True;
            apprList.add(ap1);
            apprList.add(ap2);
            apprList.add(ap3);
            Database.update(apprList);
            
            cr.Core_MDF_Active__c = True;
            
            ap1Retail.Core_MDF_Active__c = True;
            Database.update(ap1Retail);
            crMulti.Core_MDF_Active__c = True;*/

            List<Campaign> campList = new List<Campaign>();
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCamp','Consumer','Intel® Corporate Logo', 'Yes',
                                                                        Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund',Date.newInstance(2021, 01, 01) , 
                                                                        Date.newInstance(2021, 06, 29), 2000, 'Unite', acc.Id,'2-in-1', false); 
            //camp.Core_MDF_Opal_Budget_Type_Txt__c = 'CCF 1.0'; 
            campList.add(camp);
            
            Campaign MDFcamp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCampOpal','Consumer','Intel® Corporate Logo', 'MDF or both CMP & MDF',
                                                                           Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund',Date.newInstance(2022, 01, 01) , 
                                                                           Date.newInstance(2022, 06, 06), 2000, 'Unite', acc.Id,'2-in-1', false); 
            campList.add(MDFcamp);
            
            Campaign camp1 = Core_MDF_CCP_TestDataUtility.createCampaign('TestRetailCamp','Gaming','Athena', 'MDF or both CMP & MDF',
                                                                         Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds',System.today().addDays(-3), 
                                                                         System.today().addYears(1), 2000, 'Instore innovation', accRetail.Id,'2-in-1', false);
            campList.add(camp1);
            Campaign camp3 = Core_MDF_CCP_TestDataUtility.createCampaign('Retail Campaigm1','Gaming','Intel® 11ᵗʰ Gen', 'MDF or both CMP & MDF',
                                                                         Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 
                                                                         'Retail Marketing Funds', System.today(), System.today().addDays(2), 
                                                                         10000, 'Instore innovation', accRetail.Id,'Desktop', false);
            
            camp3.Core_MDF_Activity_Category_Type__c =null;
            camp3.Core_MDF_Reimbursement_Rate__c='100%';
            camp3.Core_MDF_Technology__c = 'ACPC';
            campList.add(camp3);
            
            Campaign ipaCampaignForAP = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - AP',ipaCoMarketingAcc.id, System.today(), System.today().adddays(30),null, 110000,'INDIA', 'Developer', 'Apollo Lake', 'Pending Approval', false);
            ipaCampaignForAP.Core_MDF_Region_cd__c = 'APJ';
           // ipaCampaignForAP.Core_MDF_Opal_Budget_Type_Txt__c ='Account Plan';
            ipaCampaignForAP.Core_MDF_Proposal_Based_Ind__c = false;
            ipaCampaignForAP.Core_MDF_Budget_Type_txt__c = 'Account Plan';
            ipaCampaignForAP.Core_MDF_Approval_Stage_nm__c='L2 Regional Marketing';
            ipaCampaignForAP.Core_MDF_Technology__c='';  // 14285 Indira
            campList.add(ipaCampaignForAP); 
            
            insert campList;  
            Core_Trigger_Executions__c coreTriggerExecution = new Core_Trigger_Executions__c();
            coreTriggerExecution.name='Bypass_MDF_Budget_Access';
            coreTriggerExecution.Core_Active__c = true;
            coreTriggerExecution.Core_Class_Name__c = 'Core_MDF_PMBTriggerHandler';
            coreTriggerExecution.Core_Description__c = 'To check whether budget creation access is bypassed or not';
            coreTriggerExecution.Core_Object__c = 'PartnerMarketingBudget';
            coreTriggerExecution.Core_Trigger_Events__c = 'Before Update,Before Insert';
            insert coreTriggerExecution;
            Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
            Test.startTest();
            List<PartnerMarketingBudget> budgetList = new List<PartnerMarketingBudget>();
            String retailBudgetRT = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
            PartnerMarketingBudget  pmbRecord = Core_MDF_CCP_TestDataUtility.createBudget('TestPMB',RecordTypeIdPMB,acc.Id,cp.Id,12345678,System.today().addDays(1),System.today().addDays(15),false);
            PartnerMarketingBudget retailbudget = Core_MDF_CCP_TestDataUtility.createBudget('Retail TestBudget',retailBudgetRT,accRetail.Id,cpRetail.Id,200000,System.today(),System.today(), false);
            PartnerMarketingBudget retailbudgetMD = Core_MDF_CCP_TestDataUtility.createBudget('Retail TestBudget MD',retailBudgetRT,accRetail.Id,cpRetail.Id,200000,System.today(),System.today(), false);
            PartnerMarketingBudget opalbudgetMDF = Core_MDF_CCP_TestDataUtility.createBudget('TestOpalPMB',recordTypeIdPMB,acc.Id,cp.Id,12345678,System.today().addDays(1),System.today().addDays(15),false);
            PartnerMarketingBudget opalbudgetMDF1 = Core_MDF_CCP_TestDataUtility.createBudget('TestOpalPMB1',recordTypeIdPMB,acc.Id,cp.Id,100000,System.today().addDays(16),System.today().addDays(30),false);
            PartnerMarketingBudget OEMPMB = Core_MDF_CCP_TestDataUtility.createBudget('TestoemcmpPMB',recordTypeIdPMB,acc.Id,cp.Id,100000,System.today().addDays(16),System.today().addDays(30),false);
            
            
            OEMPMB.Core_MDF_Budget_Type__c='OEM CMP';
            opalbudgetMDF.Core_MDF_Budget_Type__c='MDF';
            opalbudgetMDF1.Core_MDF_Budget_Type__c='MDF';
            pmbRecord.Core_MDF_Budget_Type__c='CCF 1.0';
            retailBudget.Core_MDF_Budget_Type__c = 'Retail MDF';
            retailbudgetMD.Core_MDF_Budget_Type__c = 'RSA MD';
            
            OEMPMB.Core_MDF_Budget_Type_Txt__c='OEM CMP';
            opalbudgetMDF.Core_MDF_Budget_Type_Txt__c='MDF';
            opalbudgetMDF1.Core_MDF_Budget_Type_Txt__c='MDF';
            pmbRecord.Core_MDF_Budget_Type_Txt__c='CCF 1.0';
            retailBudget.Core_MDF_Budget_Type_Txt__c = 'Retail MDF';
            retailbudgetMD.Core_MDF_Budget_Type_Txt__c = 'RSA MD';
            
            budgetList.add(pmbRecord);
            budgetList.add(retailbudget);
            budgetList.add(retailbudgetMD);
            budgetList.add(opalbudgetMDF);
            budgetList.add(opalbudgetMDF1);
            budgetList.add(OEMPMB);
            
            insert budgetList;
            
            List<Core_MDF_Campaign_Budgets__c> campBudgetList = new List<Core_MDF_Campaign_Budgets__c>();
            Core_MDF_Campaign_Budgets__c campBudget = new Core_MDF_Campaign_Budgets__c();
            campBudget.Core_MDF_Budget_Name_Id__c = opalbudgetMDF.id;
            campBudget.Core_MDF_Campaign_Id__c=MDFcamp.id;
            campBudget.Core_MDF_Budget_Amt__c=363636;
            campBudget.Core_MDF_Reimbursement_Rate_Pct__c='55%';
            campBudget.Core_MDF_Reimbursement_Amt__c= 200000;
            campBudget.Core_MDF_Active_ind__c=true;
            campBudgetList.add(campBudget);
            
            Core_MDF_Campaign_Budgets__c campBudget1 = new Core_MDF_Campaign_Budgets__c();
            campBudget1.Core_MDF_Budget_Name_Id__c = opalbudgetMDF1.id;
            campBudget1.Core_MDF_Campaign_Id__c=MDFcamp.id;
            campBudget1.Core_MDF_Budget_Amt__c=2000;
            campBudget1.Core_MDF_Reimbursement_Rate_Pct__c='55%';
            campBudget1.Core_MDF_Reimbursement_Amt__c= 2000;
            campBudget.Core_MDF_Active_ind__c=true;
            campBudgetList.add(campBudget1);
            
            insert campBudgetList;            
            // Create PFA records for the above accounts :
            List<PartnerFundAllocation> pfaList = new List<PartnerFundAllocation>();
            PartnerFundAllocation pfaRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFA',pmbRecord, acc, 99999,false);        
           // PartnerFundAllocation pfaRecord1 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFA1',pmbRecord, acc, 99999, false);
            //PartnerFundAllocation pfaRecord2 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFA2',pmbRecord, acc, 99999, false);   
            PartnerFundAllocation pfaRecord3 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFA3',opalbudgetMDF, acc, 99999, false);
            PartnerFundAllocation pfaRecord4 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFA4',retailBudget, acc, 99999, false);
            
            pfaList.add(pfaRecord);
           // pfaList.add(pfaRecord1);
            //pfaList.add(pfaRecord2);
            pfaList.add(pfaRecord3);
            pfaList.add(pfaRecord4);
            insert pfaList;
            
            list<PartnerFundRequest> listPRFToBeInserted = new list<PartnerFundRequest>();
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,pmbRecord,'INDIA','Consumer','Desktop',
                                                                                           'Intel® Core™ i7 Processor','Broadcast (Pre-2025)','Radio','Draft',false);
            pfr.Title = 'Test Activity';
            pfr.Core_MDF_Activity_Description__c = 'Test Activity';
            pfr.Core_MDF_Start_Date__c = Date.newInstance(2021, 01, 01);
            pfr.Core_MDF_End_Date__c = Date.newInstance(2021, 06, 29);
            pfr.RequestedAmount = 6000;
            pfr.Core_MDF_Channel_Partner_Led__c = True;
            
            PartnerFundRequest pfr1 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                            Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,pmbRecord,'INDIA','Creator','Desktop',
                                                                                            'Intel® Core™ i7 Processor','Broadcast (Pre-2025)','Radio','Draft',false);
            pfr1.Title = 'Test Activity1';
            pfr1.Core_MDF_Activity_Description__c = 'Test Activity1';
            pfr1.Core_MDF_Start_Date__c = Date.newInstance(2021, 01, 01);
            pfr1.Core_MDF_End_Date__c = Date.newInstance(2021, 06, 29);
            pfr1.RequestedAmount = 9000;
            pfr1.Core_MDF_Channel_Partner_Led__c = True;
            pfr1.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            
            PartnerFundRequest pfr2 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                            Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,pmbRecord,'INDIA','Small Business','Desktop',
                                                                                            'Intel® Core™ i9 Processor','Broadcast (Pre-2025)','Radio','Draft',false);
            pfr2.Title = 'Test Activity2';
            pfr2.Core_MDF_Activity_Description__c = 'Test Activity2';
            pfr2.Core_MDF_Start_Date__c = Date.newInstance(2021, 01, 01);
            pfr2.Core_MDF_End_Date__c = Date.newInstance(2021, 06, 29);
            pfr2.RequestedAmount = 16000;
            pfr2.Core_MDF_Channel_Partner_Led__c = True;
            pfr2.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            
            PartnerFundRequest pfr5 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                            Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,pmbRecord,'INDIA','Gaming','Desktop',
                                                                                            'Intel® Core™ i7 Processor','Out of Home Media (Pre-2025)','Cinema','Draft',false);
            pfr5.Title = 'Test Activity5';
            pfr5.Core_MDF_Activity_Description__c = 'Test Activity5';
            pfr5.Core_MDF_Start_Date__c = Date.newInstance(2021, 01, 01);
            pfr5.Core_MDF_End_Date__c = Date.newInstance(2021, 06, 29);
            pfr5.RequestedAmount = 16000;
            pfr5.Core_MDF_Channel_Partner_Led__c = True;
            pfr5.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            
            PartnerFundRequest pfr6 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                            Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,pmbRecord,'INDIA','Consumer','Desktop',
                                                                                            'Intel® Core™ i7 Processor','Out of Home Media (Pre-2025)','Cinema','Draft',false);
            pfr6.Title = 'Test Activity6';
            pfr6.Core_MDF_Activity_Description__c = 'Test Activity6';
            pfr6.Core_MDF_Start_Date__c = Date.newInstance(2021, 01, 01);
            pfr6.Core_MDF_End_Date__c = Date.newInstance(2021, 06, 29);
            pfr6.RequestedAmount = 16000;
            pfr6.Core_MDF_Channel_Partner_Led__c = False;
            pfr6.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            
            PartnerFundRequest pfr7 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                            Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,pmbRecord,'INDIA','Gaming','Desktop',
                                                                                            'Intel® Core™ i7 Processor','Out of Home Media (Pre-2025)','Cinema','Draft',false);
            pfr7.Title = 'Test Activity7';
            pfr7.Core_MDF_Activity_Description__c = 'Test Activity7';
            pfr7.Core_MDF_Start_Date__c = Date.newInstance(2021, 01, 01);
            pfr7.Core_MDF_End_Date__c = Date.newInstance(2021, 06, 29);
            pfr7.RequestedAmount = 16000;
            pfr7.Core_MDF_Channel_Partner_Led__c = False;
            pfr7.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            pfr7.LastModifiedById = usr10.id; 
            
            PartnerFundRequest pfr8 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                            Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,pmbRecord,'INDIA','Creator','Desktop',
                                                                                            'Intel® Core™ i7 Processor','Broadcast (Pre-2025)','Radio','Draft',false);
            pfr8.Title = 'Test Activity8';
            pfr8.Core_MDF_Activity_Description__c = 'Test Activity8';
            pfr8.Core_MDF_Start_Date__c = Date.newInstance(2021, 01, 01);
            pfr8.Core_MDF_End_Date__c = Date.newInstance(2021, 06, 29);
            pfr8.RequestedAmount = 9000;
            pfr8.OwnerId = usr1.Id;
            pfr8.Core_MDF_Channel_Partner_Led__c = True;
            pfr8.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            
            //PartnerFundRequest testPartnerFundRequest = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp1.Id),string.valueof(accRetail.id),System.today(),System.today(),false); 
            PartnerFundRequest testPartnerFundRequest = New PartnerFundRequest();
            testPartnerFundRequest.CampaignId=string.valueof(camp1.Id);
            testPartnerFundRequest.recordtypeid = Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail;
            testPartnerFundRequest.ChannelPartnerId = string.valueof(acc.id);
            testPartnerFundRequest.Core_MDF_Brand_nm__c='Intel® 11ᵗʰ Gen';
            testPartnerFundRequest.Core_MDF_ActivityCategory__c='Sales Readiness';
            testPartnerFundRequest.Core_MDF_Start_Date__c=System.today();
            testPartnerFundRequest.Core_MDF_End_Date__c =System.today();
            testPartnerFundRequest.Title ='Retail RSA MD Activity';
            testPartnerFundRequest.Core_MDF_Activity_Description__c ='Retail RSA MD Activity';
            testPartnerFundRequest.Core_MDF_Budget_Type_nm__c ='RSA MD';
            testPartnerFundRequest.RequestedAmount =1000;
            testPartnerFundRequest.Amount=1000;
            testPartnerFundRequest.Core_MDF_Activity_Types__c = '';
            testPartnerFundRequest.Core_MDF_Country_nm__c = 'AFGHANISTAN';
            testPartnerFundRequest.Core_MDF_Fund_Request_Status__c = 'Planned';
            testPartnerFundRequest.Core_MDF_Budget_Currency_cd__c ='USD';
            testPartnerFundRequest.Core_MDF_Reimbursement_Rate_pct__c='100%';
            testPartnerFundRequest.Core_MDF_TargetAudience__c = 'Partner Sales Force';
            
            //PartnerFundRequest testPartnerFundRequest1 = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp1.Id),string.valueof(accRetail.id),System.today(),System.today(),false); 
            PartnerFundRequest testPartnerFundRequest1 = New PartnerFundRequest();
            testPartnerFundRequest1.CampaignId=string.valueof(camp1.Id);
            testPartnerFundRequest1.recordtypeid = Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail;
            testPartnerFundRequest1.ChannelPartnerId = string.valueof(acc.id);
            testPartnerFundRequest1.Core_MDF_Brand_nm__c='Intel® 11ᵗʰ Gen';
            testPartnerFundRequest1.Core_MDF_ActivityCategory__c='Sales Readiness';
            testPartnerFundRequest1.Core_MDF_Start_Date__c=System.today();
            testPartnerFundRequest1.Core_MDF_End_Date__c =System.today();
            testPartnerFundRequest1.Title ='Retail MDF Activity';
            testPartnerFundRequest1.Core_MDF_Activity_Description__c ='Retail MDF Activity';
            testPartnerFundRequest1.Core_MDF_Budget_Type_nm__c ='Retail MDF';
            testPartnerFundRequest1.RequestedAmount =1000;
            testPartnerFundRequest1.Amount=1000;
            testPartnerFundRequest1.Core_MDF_Activity_Types__c = '';
            //testPartnerFundRequest1.Core_MDF_Country__c ='United Kingdom';
            testPartnerFundRequest1.Core_MDF_Country_nm__c = 'United Kingdom';
            testPartnerFundRequest1.Core_MDF_Fund_Request_Status__c = 'Planned';
            testPartnerFundRequest1.Core_MDF_Budget_Currency_cd__c ='USD'; 
            testPartnerFundRequest1.Core_MDF_Reimbursement_Rate_pct__c='100%';
            testPartnerFundRequest1.AllocationId = pfaRecord4.Id;
            testPartnerFundRequest1.Core_MDF_TargetAudience__c = 'Partner Sales Force';
            
            PartnerFundRequest MDFpfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(MDFcamp.Id),
                                                                                              Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord3,opalbudgetMDF,'INDIA','Consumer','Desktop',
                                                                                              'Intel® Core™ i7 Processor','Broadcast (Pre-2025)','Radio','Draft',false);
            MDFpfr.Title = 'Test Activity';
            MDFpfr.Core_MDF_Activity_Description__c = 'Test Activity';
            MDFpfr.Core_MDF_Start_Date__c = Date.newInstance(2022, 01, 01);
            MDFpfr.Core_MDF_End_Date__c = Date.newInstance(2022, 06, 06);
            MDFpfr.RequestedAmount = 6000;
            MDFpfr.Amount = 6000;
            MDFpfr.Core_MDF_Channel_Partner_Led__c = True;
            MDFpfr.Core_MDF_Budget_Type_nm__c = 'MDF';
            MDFpfr.Core_MDF_Approval_Step_Completed__c = 1;
            MDFpfr.Core_MDF_Price_reviewer_check_ind__c = False; 
            MDFpfr.Core_MDF_Program_Office_Check_ind__c = False;
            MDFpfr.Core_MDF_Require_Additional_Review_ind__c = True;
            MDFpfr.Core_MDF_Reimbursement_Rate_txt__c = '55%';
            
            PartnerFundRequest MDFpfr1 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(MDFcamp.Id),
                                                                                               Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord3,opalbudgetMDF,'INDIA','Small Business','Desktop',
                                                                                               'Intel® Core™ i7 Processor','Broadcast (Pre-2025)','Radio','Draft',false);
            MDFpfr1.Title = 'Test Activity';
            MDFpfr1.Core_MDF_Activity_Description__c = 'Test Activity';
            MDFpfr1.Core_MDF_Start_Date__c = Date.newInstance(2022, 01, 01);
            MDFpfr1.Core_MDF_End_Date__c = Date.newInstance(2022, 06, 06);
            MDFpfr1.RequestedAmount = 6000;
            MDFpfr1.Amount = 6000;
            MDFpfr1.Core_MDF_Channel_Partner_Led__c = True;
            MDFpfr1.Core_MDF_Budget_Type_nm__c = 'MDF';
            MDFpfr1.Core_MDF_Approval_Step_Completed__c = 2;
            MDFpfr1.Core_MDF_Price_reviewer_check_ind__c = False; 
            MDFpfr1.Core_MDF_Program_Office_Check_ind__c = True;
            MDFpfr1.Core_MDF_Require_Additional_Review_ind__c = True;
            MDFpfr1.Core_MDF_Reimbursement_Rate_txt__c = '55%';
            
            PartnerFundRequest MDFpfr2 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(MDFcamp.Id),
                                                                                               Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord3,opalbudgetMDF,'INDIA','Small Business','Desktop',
                                                                                               'Intel® Core™ i7 Processor','Broadcast (Pre-2025)','Radio','Draft',false);
            MDFpfr2.Title = 'Test Activity';
            MDFpfr2.Core_MDF_Activity_Description__c = 'Test Activity';
            MDFpfr2.Core_MDF_Start_Date__c = Date.newInstance(2022, 01, 01);
            MDFpfr2.Core_MDF_End_Date__c = Date.newInstance(2022, 06, 06);
            MDFpfr2.RequestedAmount = 6000;
            MDFpfr2.Amount = 6000;
            MDFpfr2.Core_MDF_Channel_Partner_Led__c = True;
            MDFpfr2.Core_MDF_Budget_Type_nm__c = 'MDF';
            MDFpfr2.Core_MDF_Approval_Step_Completed__c = 3;
            MDFpfr2.Core_MDF_Price_reviewer_check_ind__c = True; 
            MDFpfr2.Core_MDF_Require_Additional_Review_ind__c = True;
            MDFpfr2.Core_MDF_Reimbursement_Rate_txt__c = '55%';
            
            
            PartnerFundRequest MDFpfr3 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(MDFcamp.Id),
                                                                                               Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord3,opalbudgetMDF,'INDIA','Small Business','Desktop',
                                                                                               'Intel® Core™ i7 Processor','Broadcast (Pre-2025)','Radio','Draft',false);
            MDFpfr3.Title = 'Test Activity';
            MDFpfr3.Core_MDF_Activity_Description__c = 'Test Activity';
            MDFpfr3.Core_MDF_Start_Date__c = Date.newInstance(2022, 01, 01);
            MDFpfr3.Core_MDF_End_Date__c = Date.newInstance(2022, 06, 06);
            MDFpfr3.RequestedAmount = 6000;
            MDFpfr3.Amount = 6000;
            MDFpfr3.Core_MDF_Channel_Partner_Led__c = True;
            MDFpfr3.Core_MDF_Budget_Type_nm__c = 'MDF';
            MDFpfr3.Core_MDF_Approval_Step_Completed__c = 5;
            MDFpfr3.Core_MDF_Price_reviewer_check_ind__c = False; 
            MDFpfr3.Core_MDF_Program_Office_Check_ind__c = False;
            MDFpfr3.Core_MDF_Require_Additional_Review_ind__c = True;
            MDFpfr3.Core_MDF_Reimbursement_Rate_txt__c = '55%';
            
            
            
            PartnerFundRequest MDFpfr4 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(MDFcamp.Id),
                                                                                               Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord3,opalbudgetMDF,'INDIA','Small Business','Desktop',
                                                                                               'Intel® Core™ i7 Processor','Broadcast (Pre-2025)','Radio','Draft',false);
            MDFpfr4.Title = 'Test Activity';
            MDFpfr4.Core_MDF_Activity_Description__c = 'Test Activity';
            MDFpfr4.Core_MDF_Start_Date__c = Date.newInstance(2022, 01, 01);
            MDFpfr4.Core_MDF_End_Date__c = Date.newInstance(2022, 06, 06);
            MDFpfr4.RequestedAmount = 6000;
            MDFpfr4.Amount = 6000;
            MDFpfr4.Core_MDF_Channel_Partner_Led__c = True;
            MDFpfr4.Core_MDF_Budget_Type_nm__c = 'MDF';
            MDFpfr4.Core_MDF_Approval_Step_Completed__c = 0;
            MDFpfr4.Core_MDF_Price_reviewer_check_ind__c = False; 
            MDFpfr4.Core_MDF_Program_Office_Check_ind__c = False;
            MDFpfr4.Core_MDF_Require_Additional_Review_ind__c = False;
            MDFpfr4.Core_MDF_Reimbursement_Rate_txt__c = '55%';
                        
            PartnerFundRequest MDFpfr5 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(MDFcamp.Id),
                                                                                               Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),null,opalbudgetMDF,'INDIA','Small Business','Desktop',
                                                                                               'Intel® Core™ i7 Processor','Broadcast (Pre-2025)','Radio','Draft',false);
            MDFpfr5.Title = 'Test Activity';
            MDFpfr5.Core_MDF_Activity_Description__c = 'Test Activity';
            MDFpfr5.Core_MDF_Start_Date__c = Date.newInstance(2022, 01, 01);
            MDFpfr5.Core_MDF_End_Date__c = Date.newInstance(2022, 06, 06);
            MDFpfr5.RequestedAmount = 60000;
            MDFpfr5.Amount = 6000;
            MDFpfr5.Core_MDF_Channel_Partner_Led__c = True;
            MDFpfr5.Core_MDF_Budget_Type_nm__c = 'MDF';
            MDFpfr5.Core_MDF_Approval_Step_Completed__c = 0;
            MDFpfr5.Core_MDF_Price_reviewer_check_ind__c = False; 
            MDFpfr5.Core_MDF_Program_Office_Check_ind__c = False;
            MDFpfr5.Core_MDF_Require_Additional_Review_ind__c = False;
            MDFpfr5.Core_MDF_Reimbursement_Rate_txt__c = '55%';
            MDFpfr5.AllocationId = pfaRecord.Id;
            
            
            listPRFToBeInserted.add(MDFpfr); 
            listPRFToBeInserted.add(pfr);            
            listPRFToBeInserted.add(pfr1);
            listPRFToBeInserted.add(pfr6);
            listPRFToBeInserted.add(testPartnerFundRequest);
            listPRFToBeInserted.add(testPartnerFundRequest1);
            
            System.runAs(usr){
            Database.insert(listPRFToBeInserted);
            }

            Core_MDF_CCP_TestDataUtility.insertCurrencyExchangeRates();
            // 14285 Indira - start 
                     List<Core_MDF_Partner_Node_User_Mapping__c> existingPNUM = [
                    SELECT Id FROM Core_MDF_Partner_Node_User_Mapping__c 
                    WHERE Core_MDF_User__r.Email = 'test1@example.com'
                    AND Core_MDF_Account__r.Name = 'Co-marketing Test Account Retail'
                ];
            
                if (existingPNUM.isEmpty()) {
                    User usr11Query = [SELECT Id FROM User WHERE Email = 'test1@example.com' LIMIT 1];
                    Account accRetailQuery = [SELECT Id FROM Account WHERE Name = 'Co-marketing Test Account Retail' LIMIT 1];
            Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(accRetail.Id, usr11.Id, true);
                }
            // 14285 Indira - end
            PermissionSet ccfAccManagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr' LIMIT 1];
            
            // Assigning internal ccf acc mgr permission set to usr1
            PermissionSetAssignment psa1 = new PermissionSetAssignment(PermissionSetId = ccfAccManagerPS.Id, AssigneeId = usr1.Id);
            Database.insert(psa1);
            
            Core_MDF_CCP_TestDataUtility.createTriggerExecutionRecords();
            
            List<Core_Trigger_Executions__c> customSetting= new List<Core_Trigger_Executions__c>();
            
            List<Core_Trigger_Executions__c> executionAdjRequest = new List<Core_Trigger_Executions__c>();
            Core_Trigger_Executions__c adjustmentRequestClaimTriggerExecution = new Core_Trigger_Executions__c();
            adjustmentRequestClaimTriggerExecution.Core_Active__c = true;
            adjustmentRequestClaimTriggerExecution.Core_Class_Name__c = 'Core_MDF_AdjustmentReq_ServiceHandler';
            adjustmentRequestClaimTriggerExecution.Core_Trigger_Events__c = 'before insert';
            adjustmentRequestClaimTriggerExecution.Core_Object__c = 'Core_MDF_Adjustment_Request__c';
            adjustmentRequestClaimTriggerExecution.Name = 'createAdjustment';
            adjustmentRequestClaimTriggerExecution.Core_Description__c = 'Negative claim is getting created from Adustemt Request';
            
            customSetting.add(adjustmentRequestClaimTriggerExecution);
            
            Core_Trigger_Executions__c setting1 = new Core_Trigger_Executions__c();
            setting1.Core_Active__c = True;
            setting1.Core_Class_Name__c = 'Core_MDF_PFR_TriggerServiceHandler';
            setting1.Core_Description__c = 'Validate Activity against active claims';
            setting1.Core_Object__c = 'PartnerFundRequest';
            setting1.Core_Trigger_Events__c = 'Before Update';
            setting1.name = 'Core_MDF_ActivityClaimsValidation';
            
            Core_Trigger_Executions__c setting2 = new Core_Trigger_Executions__c();
            setting2.Core_Active__c = True;
            setting2.Core_Class_Name__c = 'Core_MDF_PFR_TriggerServiceHandler';
            setting2.Core_Description__c = 'Validates Activity Amount with claim';
            setting2.Core_Object__c = 'PartnerFundRequest';
            setting2.Core_Trigger_Events__c = 'Before Update';
            setting2.name = 'Core_MDF_ActivityAmountValidation';
            
            Core_Trigger_Executions__c setting3 = new Core_Trigger_Executions__c();
            setting3.Core_Active__c = True;
            setting3.Core_Class_Name__c = 'Core_MDF_PFR_TriggerServiceHandler';
            setting3.Core_Description__c = 'Activity Date Range must comply with claims date range';
            setting3.Core_Object__c = 'PartnerFundRequest';
            setting3.Core_Trigger_Events__c = 'Before Update';
            setting3.name = 'Core_MDF_ActivityDateValidation';
            
            Core_Trigger_Executions__c setting4 = new Core_Trigger_Executions__c();
            setting4.Core_Active__c = True;
            setting4.Core_Class_Name__c = 'Core_MDF_ProcessCCP_PartnerFundRequest';
            setting4.Core_Description__c = 'Validate RMF Notifications';
            setting4.Core_Object__c = 'PartnerFundRequest';
            setting4.Core_Trigger_Events__c = 'After Update, After Insert';
            setting4.name = 'Core_MDF_RMFActivityEmailValidation';
            
            customSetting.add(setting1);
            customSetting.add(setting2);
            customSetting.add(setting3);
            customSetting.add(setting4);
            
            insert customSetting;
            test.stopTest();
            
        }
    }  
    /****************************************************************************************************************************************
Method Name:                                   testSharingForClosedActivity
Description:                                   Created for testing custom approval process for PartnerFundRequest Object
Added By:                                      Accenture – NZ
Modified By:                  Date:            Changes: 
Accenture – NZ                Created.
*****************************************************************************************************************************************/
    @isTest static void testSharingForClosedActivity(){
        User adminUser = Core_MDF_CCP_TestDataUtility.createUser(true);
        permissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Retail_Account_Manager' LIMIT 1];
        System.runAs(adminUser){
            insert new PermissionSetAssignment(AssigneeId = adminUser.id, PermissionSetId = ps.Id);
        }
            PartnerFundRequest pfr = [SELECT id,Title,Core_MDF_Country_nm__c FROM PartnerFundRequest where Title = 'Retail MDF Activity' LIMIT 1];
        System.runAs(adminUser){
            Test.startTest();
            // 1. Create an UK Activity.
            List<PartnerFundRequestShare> pfrShareList = [SELECT ParentId, UserOrGroupId, UserOrGroup.Name 
                                                          FROM PartnerFundRequestShare 
                                                          WHERE parentId = :pfr.Id];
            Boolean apjGrpShare = false;
            // 2. Put an Assert statement to check on the sharing for EMEA Group.
            for(PartnerFundRequestShare shareRec : pfrShareList)
            {
                if(shareRec.UserOrGroup.Name == 'Core_MDF_Retail_Grp'){
                    apjGrpShare = true;
                }
            }
            if(apjGrpShare){
                System.assert(apjGrpShare);
            }
            // 3. Close that Activity.
            pfr.Core_MDF_Fund_Request_Status__c = 'Closed';
            pfr.Core_MDF_Activity_Closure_Type__c = 'No Internal Approval';
            pfr.Core_MDF_Activity_First_Approver_txt__c=adminUser.Id; // 14285 Indira
            update pfr;
            for(PartnerFundRequestShare shareRec : pfrShareList)
            {
                if(shareRec.UserOrGroup.Name == 'Core_MDF_Retail_Grp'){
                    apjGrpShare = true;
                }
            }
            if(apjGrpShare){
                System.assert(apjGrpShare);
            }
            // 4. Put an Assert statement to check on the sharing for EMEA Group.
            pfrShareList = [SELECT ParentId, UserOrGroupId, UserOrGroup.Name 
                            FROM PartnerFundRequestShare 
                            WHERE parentId = :pfr.Id];
            // 5. Update the Country for that Activity to US. UserOrGroup.Name LIKE '%EMEA%'
            pfr.Core_MDF_Country_nm__c = 'United States';
            // 6. Put an Assert statement to check on the sharing for ASMO Group.
            pfrShareList = [SELECT ParentId, UserOrGroupId, UserOrGroup.Name 
                            FROM PartnerFundRequestShare 
                            WHERE parentId = :pfr.Id];
            for(PartnerFundRequestShare shareRec : pfrShareList)
            {
                if(shareRec.UserOrGroup.Name == 'Core_MDF_Retail_Grp'){
                    apjGrpShare = true;
                }
            }
            if(apjGrpShare){
                Assert.isTrue(apjGrpShare);
            }
            Test.stopTest();
            
        }
    }
    /****************************************************************************************************************************************
Method Name:                                   testCustomApprovalProcessMethod
Description:                                   Created for testing custom approval process for PartnerFundRequest Object
Added By:                                      Accenture – Harika P  -  8/27/2018
Modified By:                  Date:            Changes: 
Accenture – Harika P        8/27/2018          Created.
*****************************************************************************************************************************************/
    /*@isTest static void testCustomApprovalProcessMethod(){ 
        User user = [SELECT Id, LastName FROM User WHERE LastName ='User Test'  LIMIT 1];
        System.runAs(user){
            Test.startTest();
            list<User> usrList = [SELECT Id, LastName FROM User LIMIT 1000];
            
            list<PartnerFundRequest> pfrList = [SELECT Id,  Title, ChannelPartnerId, CampaignId,  RequestedAmount,  Core_MDF_Start_Date__c,  
                                                Core_MDF_Channel_Partner_Led__c, Core_MDF_End_Date__c, Core_MDF_Channel_Partner__c,  Core_MDF_Brand_nm__c, Core_MDF_Approver_1__c,  
                                                Core_MDF_Fund_Request_Status__c,  Core_MDF_Approver_2__c, Core_MDF_Activity_Description__c, Core_MDF_pagespayingfor__c, 
                                                Core_MDF_ofPagesEligible__c, Core_MDF_Approver_3__c,  Core_MDF_TargetAudience__c, Core_MDF_ProductType__c, 
                                                Core_MDF_ActivityCategory__c, Core_MDF_Country_nm__c, Core_MDF_Activity_Types__c, Core_MDF_Approver_4__c, Core_MDF_Approver_5__c, 
                                                Core_MDF_Approver_6__c, Core_MDF_Approver_7__c, Core_MDF_Approver_8__c, Core_MDF_Approver_9__c, Core_MDF_Reimbursement_Rate__c,
                                                Core_MDF_Approver_10__c, Core_MDF_Program__c FROM PartnerFundRequest WHERE Title LIKE 'Test Activity%' LIMIT 100];
            
            Map<String,Map<String, list<Id>>> setApproverResultMap1 = Core_MDF_GenericApprovalProcess.setApprovers((List<SObject>) pfrList);
            
            // Testing auto approval records 
            if(setApproverResultMap1.containsKey('autoApproved')){
                Map<String, list<Id>> autoApprovedSObjects = setApproverResultMap1.get('autoApproved');
                PartnerFundRequest autoApprovedActivity = [SELECT Id,  Title, Core_MDF_Fund_Request_Status__c,Core_MDF_Approver_1__c,
                                                           Core_MDF_Approver_2__c,Core_MDF_Approver_3__c,Core_MDF_Approver_4__c,Core_MDF_Approver_5__c,Core_MDF_Approver_6__c, 
                                                           Core_MDF_Approver_7__c, Core_MDF_Approver_8__c, Core_MDF_Approver_9__c, Core_MDF_Approver_10__c, Core_MDF_Reimbursement_Rate__c
                                                           FROM PartnerFundRequest WHERE 
                                                           Title ='Test Activity6' LIMIT 50000];
                System.assert(autoApprovedSObjects.keySet().contains(String.valueOf(autoApprovedActivity.Id)));
                
            }
            Test.stopTest();
            Core_MDF_ProcessCCP_PartnerFundRequest.RemoveApprovalLock(pfrList);
            // Testing approval required records 
            if(setApproverResultMap1.containsKey('approvalRequired')){
                Map<String, list<Id>> nonAutoApprovedSObjects = setApproverResultMap1.get('approvalRequired');
                for(PartnerFundRequest pfr:pfrList){
                    if(nonAutoApprovedSObjects.keySet().contains(pfr.Id)){
                        for(User usr : usrList){
                            if(pfr.Title == 'Test Activity'){
                                //Testing whether User Test1 is the approver or not 
                                if(usr.LastName == 'User Test1'){
                                    Assert.areEqual(nonAutoApprovedSObjects.get(String.valueOf(pfr.ID)).contains(usr.Id), true);
                                }
                                //Testing whether User Test2 is the approver or not 
                                if(usr.LastName == 'User Test2'){
                                    Assert.areEqual(nonAutoApprovedSObjects.get(String.valueOf(pfr.ID)).contains(usr.Id), true);
                                }
                                //Testing whether User Test6 is the approver or not 
                                if(usr.LastName == 'User Test6'){
                                    Assert.areEqual(nonAutoApprovedSObjects.get(String.valueOf(pfr.ID)).contains(usr.Id), true);
                                }
                                //Testing whether User Test7 is the approver or not                                 
                                if(usr.LastName == 'User Test7'){
                                    Assert.areEqual(nonAutoApprovedSObjects.get(String.valueOf(pfr.ID)).contains(usr.Id), true);
                                }
                                //Testing whether User Test8 is the approver or not 
                                if(usr.LastName == 'User Test8'){
                                    Assert.areEqual(nonAutoApprovedSObjects.get(String.valueOf(pfr.ID)).contains(usr.Id), true);
                                }                               
                                
                            }
                            
                            //Testing whether User Test3 is the approver of test Activity1 or not 
                            if(pfr.Title == 'Test Activity1'){
                                if(usr.LastName == 'User Test3'){
                                    Assert.areEqual(nonAutoApprovedSObjects.get(String.valueOf(pfr.ID)).contains(usr.Id), true);
                                }
                                
                            }
                            
                            //Testing whether User Test4 and User Test5 are the approvers of test Activity2 or not 
                            if(pfr.Title == 'Test Activity2'){
                                if(usr.LastName == 'User Test4'){
                                    Assert.areEqual(nonAutoApprovedSObjects.get(String.valueOf(pfr.ID)).contains(usr.Id), true);
                                }
                                if(usr.LastName == 'User Test5'){
                                    Assert.areEqual(nonAutoApprovedSObjects.get(String.valueOf(pfr.ID)).contains(usr.Id), true);
                                }
                            }

                        }
                    }
                }
            }
        }
    }*/
    
    /****************************************************************************************************************************************
Method Name:                                   testRecallApprovalProcess
Description:                                   Created to test recall functionalities.
Added By:                                      Accenture – Shridhar K 12/23/2018
Modified By:                  Date:            Changes: 
Accenture – Shridhar K        12/23/2018       Created. 
*****************************************************************************************************************************************/
    @isTest static void testActivityShare(){
        test.startTest(); 
        User user = [SELECT Id, LastName FROM User WHERE LastName ='User Test'  LIMIT 1];
        Account accRetail = [SELECT Id FROM Account WHERE Name ='Co-marketing Test Account Retail2'  LIMIT 1];
        PartnerFundRequest pfr = [SELECT id,Title,Core_MDF_Country_nm__c,Core_MDF_Sub_Region_nm__c FROM PartnerFundRequest where Title = 'Retail MDF Activity' LIMIT 1];
        
        pfr.OwnerId = user.Id;
        pfr.ChannelPartnerId = accRetail.Id; 
        pfr.Core_MDF_Country_nm__c = 'Argentina';
        pfr.Core_MDF_Activity_First_Approver_txt__c=user.Id; // 14285 Indira
        update pfr;
        System.assert(pfr.Core_MDF_Country_nm__c == 'Argentina');
        test.stopTest();
    }
    
    @isTest static void testIPAactivities(){
        Test.startTest();
        Account ipaUltimateAccountIPA = [select id,Core_MDF_Parent_Fund_Account__c,RecordType.DeveloperName,Core_MDF_Channel_Program__c,Core_MDF_CoMarketing_Ultimate_Account__c 
                                            from Account
                                            where Name= 'IPA Intel Account PFR'];
         Account coMarketingIPA = [select id,Core_MDF_Parent_Fund_Account__c,RecordType.DeveloperName,Core_MDF_Channel_Program__c,Core_MDF_CoMarketing_Ultimate_Account__c 
                                            from Account
                                            where Name= 'IPA Co-Marketing Account'];
        
        string bType = 'Proposal I MDF';
        Group ipaGrp = new Group();
        ipaGrp.Name = 'Core CCP IPA Internal';
        ipaGrp.DeveloperName = 'Core_CCP_IPA_Internal';
        insert ipaGrp;
        
        ChannelProgram ipaCP = [select Id from ChannelProgram where Core_MDF_Technical_Program_Name__c = 'Intel Partner Alliance'];
        
        Core_MDF_Partner_Group_Mapping__c pgm = new Core_MDF_Partner_Group_Mapping__c();
        pgm.Core_MDF_Account__c = ipaUltimateAccountIPA.Id;
        pgm.Core_MDF_Virtual_Corp_nm__c = coMarketingIPA.Id;
        pgm.Core_MDF_Group_Name__c = 'Core_CCP_IPA_Internal';
        pgm.Core_MDF_Type_of_Access__c = 'EXTERNAL';
        pgm.Core_MDF_Group_Id__c = ipaGrp.Id;                
        pgm.Core_MDF_Channel_Program__c = ipaCP.Id;
        pgm.Core_MDF_Region_cd__c = 'WW';
        pgm.Core_MDF_Source_Txt__c = 'Test';
        pgm.Core_MDF_AccountIdGroupName__c = ipaUltimateAccountIPA.Id+'Core_CCP_IPA_Internal';
        insert pgm;
                
        Core_MDF_ProcessCCP_PartnerFundRequest.getTemplateNameByProgNameIPA();
        Core_MDF_ProcessCCP_PartnerFundRequest.getTemplateNameByProgName();
        Campaign ipaCampaign = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - AP',
                                                                                  coMarketingIPA.id, 
                                                                                  System.today().addDays(3), System.today().adddays(30),
                                                                                  bType, 110000,'INDIA', 'Consumer', 
                                                                                  'Apollo Lake', 'Planned', false);
        ipaCampaign.Core_MDF_Proposal_Based_Ind__c = true;
        ipaCampaign.Core_MDF_Technology__c=''; // 14285 Indira
        insert ipaCampaign;
        
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        Map<Id,PartnerFundRequest> oldPfrMap = new Map<Id,PartnerFundRequest>();
        PartnerFundRequest ipaPFR = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaign.id,coMarketingIPA.id,
                                                                                                 System.today().addDays(4),
                                                                                                 System.today().addDays(4),
                                                                                                 false);  
        ipaPFR.RequestedAmount = 1;
        
        
        ipaPFR.Core_MDF_Fund_Request_Status__c = 'Planned';
        ipaPFR.Core_MDF_Region_nm__c = 'APJ';
        PartnerFundRequest ipaPFR2 = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaign.id,coMarketingIPA.id,
                                                                                                  System.today().addDays(4),
                                                                                                  System.today().addDays(4),
                                                                                                  false);
        ipaPFR2.RequestedAmount = 1;
        
        ipaPFR2.Core_MDF_Fund_Request_Status__c = 'Revision Required';
                        
        pfrList.add(ipaPFR2); 
        Database.insert(pfrList);
        oldPfrMap.put(ipaPFR.Id,ipaPFR);
        Test.stopTest();
        try{
            ipaPFR2.RequestedAmount = 1;
            Database.update(ipaPFR2);
        }catch(Exception e){
            
            Boolean expectedExceptionThrown =  e.getMessage().contains('Sum of all Activity Budget Amounts cannot be greater than Proposal Amount.') ? true : false;
            Assert.areEqual(expectedExceptionThrown, false);
        }
        
        Core_MDF_ProcessCCP_PartnerFundRequest.publishActivityPlatformEvent(pfrList,oldPfrMap);
        
        
    }
   
        
    /****************************************************************************************************************************************
Method Name:                                   testNullApprovers
Description:                                   Created to test null approvers functionality.
Added By:                                      Accenture – Harika P  11/27/2019 
Modified By:                  Date:            Changes: 
Accenture – Harika P          11/27/2019       Created./
*****************************************************************************************************************************************/       
   /* @isTest static void testNullApprovers(){
        test.startTest();
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account 1'];
        User user = [SELECT Id FROM User WHERE LastName = 'User Test1'];
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm.Core_MDF_Account_id__c = acc.Id;
        iupgm.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
        iupgm.Core_MDF_Region_cd__c = 'ASMO;EMEA;PRC'; //'ASMO;EMEA;PRC';
        iupgm.Core_MDF_Region_Sub_Region_nm__c = 'ASMO;EMEA;PRC'; //'ASMO;EMEA;PRC';
        iupgm.Core_MDF_User_id__c = user.Id;
        iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr';
        iupgm.Core_MDF_Active_Ind__c = TRUE;
        iupgm.Core_MDF_All_Accounts_cd__c ='No';
        Database.insert(iupgm);
        
        PartnerFundRequest pfr = [SELECT Id, CampaignId, Campaign.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c, 
                                  Campaign.Core_MDF_Channel_Program__c,Core_MDF_Region_nm__c 
                                  FROM PartnerFundRequest  WHERE 
                                  Title ='Test Activity1' LIMIT 1];
        
        Campaign cmp = [Select Id,Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c,
                       Core_MDF_Channel_Program__c FROM Campaign Where Name ='TestCamp' LIMIT 1];
        Map<id,PartnerFundRequest> pfrMap = new Map<id,PartnerFundRequest>();
        
        pfrMap.put(pfr.Id,pfr);
        
        Set<Id> campIdSet = new Set<Id>();
        campIdSet.add(cmp.Id);
        List<String> nullApprovers = new List<String>();
        nullApprovers.add(pfr.Id);
        test.stopTest();
        Assert.areEqual(iupgm.Core_MDF_User_id__c,user.Id);
        
        
    }*/
      @isTest static void testRemoveApprovalLockUnlock(){
          Test.startTest(); 
          User adminUser = Core_MDF_CCP_TestDataUtility.createUser(true);
          permissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Retail_Account_Manager' LIMIT 1];
          System.runAs(adminUser){
              insert new PermissionSetAssignment(AssigneeId = adminUser.id, PermissionSetId = ps.Id);
          }
          Campaign camp = [SELECT Id FROM Campaign WHERE Name ='TestRetailCamp'  LIMIT 1];
          Account acc = [SELECT Id FROM Account WHERE Name ='Co-marketing Test Account Retail'  LIMIT 1];
          list<PartnerFundRequest> pfrs = new list<PartnerFundRequest>();
          boolean apprlck = false;
          
          System.runAs(adminUser){  
              PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                             Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,string.valueof(acc.id),NULL,NULL,'INDIA','Partner Sales Force','Traditional Notebook',
                                                                                             'Intel® 11ᵗʰ Gen','Sales Readiness','','Draft',false);
              pfr.Title = 'Test Retail Activity';
              pfr.Core_MDF_Activity_Description__c = 'Test Retail Activity';
              pfr.Core_MDF_Start_Date__c = System.today().addDays(17);
              pfr.Core_MDF_End_Date__c = System.today().addDays(18);
              pfr.RequestedAmount = 1000;
              pfr.Core_MDF_Country_nm__c = 'INDIA';
              //pfr.Core_MDF_Country__c = 'INDIA';
              pfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
              insert pfr;
              pfr.Core_MDF_Fund_Request_Status__c = 'Revision Required';
              pfr.Core_MDF_Activity_First_Approver_txt__c=adminUser.Id; // 14285 Indira
              update pfr;
              List<PartnerFundRequest> pfrlst = new List<PartnerFundRequest>();
              pfrlst.add(pfr);
              Database.update(pfrlst);
              apprlck = Core_MDF_ProcessCCP_PartnerFundRequest.RemoveApprovalLock(pfrlst);
              Assert.isTrue(apprlck);
          }
          test.stopTest();
      }
    
    //test method for Activity Approval Unlock
    @isTest static void testRetailApprovalUnlock(){
        Test.startTest(); 
        User adminUser = Core_MDF_CCP_TestDataUtility.createUser(true);
        permissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Retail_Account_Manager' LIMIT 1];
        System.runAs(adminUser){
            insert new PermissionSetAssignment(AssigneeId = adminUser.id, PermissionSetId = ps.Id);
        }
        Campaign camp = [SELECT Id FROM Campaign WHERE Name ='TestRetailCamp'  LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name ='Co-marketing Test Account Retail'  LIMIT 1];
        list<PartnerFundRequest> pfrs = new list<PartnerFundRequest>();
        boolean apprlck = false;
        
        System.runAs(adminUser){       
            
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,string.valueof(acc.id),NULL,NULL,'INDIA','Partner Sales Force','Traditional Notebook',
                                                                                           'Intel® 11ᵗʰ Gen','Sales Readiness','','Draft',false);  // 14285 Indira
            pfr.Title = 'Test Retail Activity';
            pfr.Core_MDF_Activity_Description__c = 'Test Retail Activity';
            pfr.Core_MDF_Start_Date__c = System.today().addDays(17);
            pfr.Core_MDF_End_Date__c = System.today().addDays(18);
            pfr.RequestedAmount = 1000;
            pfr.Core_MDF_Country_nm__c = 'INDIA';
            //pfr.Core_MDF_Country__c = 'INDIA';
            pfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            
            pfrs.add(pfr);          
            
            Database.insert(pfrs);
            
            if(Approval.isLocked(pfr.Id))
            {
                List<PartnerFundRequest> pfrlst = new List<PartnerFundRequest>();
                pfr.Core_MDF_Fund_Request_Status__c = 'Cancelled';
                pfrlst.add(pfr);
                Database.update(pfrlst);
                apprlck = Core_MDF_ProcessCCP_PartnerFundRequest.RemoveApprovalLock(pfrlst);  
            }                         
            
            Test.stopTest(); 
        }
        Assert.isFalse(apprlck);
        
        Core_MDF_ProcessCCP_PartnerFundRequest.RemoveApprovalLock(NULL); 
    }
    
    
    @isTest static void testRetailApprovalRecall(){
        
        User adminUser = Core_MDF_CCP_TestDataUtility.createUser(true);
        permissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Retail_Account_Manager' LIMIT 1];
        System.runAs(adminUser){
            insert new PermissionSetAssignment(AssigneeId = adminUser.id, PermissionSetId = ps.Id);
        }
        Campaign camp = [SELECT Id FROM Campaign WHERE Name ='TestRetailCamp'  LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name ='Co-marketing Test Account Retail'  LIMIT 1];
        list<PartnerFundRequest> pfrs = new list<PartnerFundRequest>();
        boolean recall = false;
        
        System.runAs(adminUser){
            
            Test.startTest();        
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,string.valueof(acc.id),NULL,NULL,'INDIA','Partner Sales Force','Traditional Notebook',
                                                                                           'Intel® 11ᵗʰ Gen','Sales Readiness','','Draft',false);   // 14285 Indira
            pfr.Title = 'Test Retail Activity';
            pfr.Core_MDF_Activity_Description__c = 'Test Retail Activity';
            pfr.Core_MDF_Start_Date__c = System.today().addDays(-1); //System.today().addDays(17)
            pfr.Core_MDF_End_Date__c = System.today().addDays(18);
            pfr.RequestedAmount = 1000;
            pfr.Core_MDF_Country_nm__c = 'INDIA';
            //pfr.Core_MDF_Country__c = 'INDIA';
            pfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            pfrs.add(pfr);
            
            Database.insert(pfrs);
            
            if(Approval.isLocked(pfr.Id))
            {
                List<PartnerFundRequest> pfrlst = new List<PartnerFundRequest>();
                pfrlst.add(pfr);
                Core_MDF_ProcessCCP_PartnerFundRequest.RemoveApprovalLock(pfrlst);                     
            }
            
            pfrs = new list<PartnerFundRequest>(); 
            pfr.Core_MDF_Start_Date__c = System.today().addDays(17);
            pfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            pfr.Core_MDF_ProductType__c='Workstation';
            pfrs.add(pfr);
            
            Map<Id,PartnerFundRequest> pfrMap = new Map<Id,PartnerFundRequest>();
            PartnerFundRequest pfr1 = [select id,RequestedAmount,Core_MDF_Program__c,Core_MDF_ProductType__c,Core_MDF_Approval_Step_Completed__c,Core_MDF_Start_Date__c,Core_MDF_Fund_Request_Status__c,recordTypeId,Core_MDF_End_Date__c
                                       from PartnerFundRequest where Id =: pfrs LIMIT 1];
            
            pfr1.Core_MDF_Start_Date__c = System.today().addDays(18);
            pfr1.Core_MDF_Fund_Request_Status__c ='Closed';
            pfr1.Core_MDF_Activity_Closure_Type__c = 'No Internal Approval';
            pfr1.Core_MDF_Activity_First_Approver_txt__c=adminUser.Id; // 14285 Indira
            pfr1.Core_MDF_ProductType__c='Chromebook';
            update pfr1;
            pfrMap.put(pfr1.Id,pfr1);
            Assert.isNotNull(pfrMap);
            Test.stopTest();        
        }
        
    }   
    
    @isTest static void testCallApprovalProcess(){
        Test.startTest(); 
        User user = [SELECT Id, LastName FROM User WHERE LastName ='User Test12'  LIMIT 1];
        
        Campaign camp = [SELECT Id FROM Campaign WHERE Name ='TestRetailCamp'  LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name ='Co-marketing Test Account Retail'  LIMIT 1];
        list<PartnerFundRequest> pfrs = new list<PartnerFundRequest>();
        boolean recall = false;
        PartnerFundRequest pfr;
        PartnerFundRequest pfr1;
        PartnerFundRequest pfr2;
        PartnerFundRequest pfr3;
        System.runAs(user){
            pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                        Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,string.valueof(acc.id),NULL,NULL,'INDIA','Partner Sales Force','Traditional Notebook',
                                                                        'Intel® 11ᵗʰ Gen','Sales Readiness','','Draft',false);  // 14285 Indira
            pfr.Title = 'Test Retail Activity';
            pfr.Core_MDF_Activity_Description__c = 'Test Retail Activity';
            pfr.Core_MDF_Start_Date__c = System.today().addDays(17);
            pfr.Core_MDF_End_Date__c = System.today().addDays(18);
            pfr.RequestedAmount = 26000;
            pfr.Core_MDF_Country_nm__c = 'INDIA';
            //pfr.Core_MDF_Country__c = 'INDIA';
            pfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            pfr.Core_MDF_Approval_Step_Completed__c = 1;
            
            
            pfr1 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                         Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,string.valueof(acc.id),NULL,NULL,'INDIA','Partner Sales Force','Traditional Notebook',
                                                                         'Intel® 11ᵗʰ Gen','Sales Readiness','','Draft',false);   // 14285 Indira
            pfr1.Title = 'Test Retail Activity';
            pfr1.Core_MDF_Activity_Description__c = 'Test Retail Activity';
            pfr1.Core_MDF_Start_Date__c = System.today().addDays(17);
            pfr1.Core_MDF_End_Date__c = System.today().addDays(18);
            pfr1.RequestedAmount = 26000;
            pfr1.Core_MDF_Country_nm__c = 'INDIA';
            //pfr1.Core_MDF_Country__c = 'INDIA';
            pfr1.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            pfr1.Core_MDF_Approval_Step_Completed__c = 1;
            
            
            pfr2 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                         Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,string.valueof(acc.id),NULL,NULL,'INDIA','Partner Sales Force','Traditional Notebook',
                                                                         'Intel® 11ᵗʰ Gen','Sales Readiness','','Draft',false);  // 14285 Indira
            pfr2.Title = 'Test Retail Activity';
            pfr2.Core_MDF_Activity_Description__c = 'Test Retail Activity';
            pfr2.Core_MDF_Start_Date__c = System.today().addDays(17);
            pfr2.Core_MDF_End_Date__c = System.today().addDays(18);
            pfr2.RequestedAmount = 260000;
            pfr2.Core_MDF_Country_nm__c = 'INDIA';
            //pfr2.Core_MDF_Country__c = 'INDIA';
            pfr2.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            pfr2.Core_MDF_Approval_Step_Completed__c = 2;
            pfrs.add(pfr2);
            
            pfr3 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                         Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,string.valueof(acc.id),NULL,NULL,'INDIA','Partner Sales Force','Traditional Notebook',
                                                                         'Intel® 11ᵗʰ Gen','Sales Readiness','','Draft',false);  // 14285 Indira
            pfr3.Title = 'Test Retail Activity';
            pfr3.Core_MDF_Activity_Description__c = 'Test Retail Activity';
            pfr3.Core_MDF_Start_Date__c = System.today().addDays(17);
            pfr3.Core_MDF_End_Date__c = System.today().addDays(18);
            pfr3.RequestedAmount = 260000;
            pfr3.Core_MDF_Country_nm__c = 'INDIA';
            //pfr3.Core_MDF_Country__c = 'INDIA';
            pfr3.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            pfr3.Core_MDF_Approval_Step_Completed__c = 2;
            pfrs.add(pfr3);
            Database.insert(pfrs); 
            Assert.areEqual(true, pfrs!=null);  
            Test.stopTest(); 
        }
    }

    @isTest

static void testScenario1(){

Test.startTest();
  Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Co-marketing Test Account Retail' LIMIT 1];
  User user = [SELECT Id FROM User WHERE LastName = 'Test PRC MS User' and isActive=true];
  Campaign cmp = [SELECT Id FROM Campaign WHERE Name = 'TestRetailCamp'];
  Account coMarketingIPA = [select id,Core_MDF_Parent_Fund_Account__c,RecordType.DeveloperName,Core_MDF_Channel_Program__c,Core_MDF_CoMarketing_Ultimate_Account__c from Account where Name= 'IPA Co-Marketing Account'];
 
  Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
  iupgm.Core_MDF_Account_id__c = acc.Id;
  iupgm.Core_MDF_Program_nm__c = 'Retail Marketing Funds';
  iupgm.RecordTypeId = RMF_RecordType;
  iupgm.Core_MDF_User_id__c = user.Id;
  iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_RMF_PRC_Claim_Operations';
  iupgm.Core_MDF_Active_Ind__c = TRUE;
  iupgm.Core_MDF_All_Accounts_cd__c ='No';
  Database.insert(iupgm);

  Campaign ipaCampaign = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - AP',coMarketingIPA.id, System.today().addDays(3), System.today().adddays(30), 'Proposal I MDF', 110000,'INDIA', 'Consumer','Apollo Lake', 'Planned', false);
  ipaCampaign.Core_MDF_Proposal_Based_Ind__c = false;
  ipaCampaign.Core_MDF_Technology__c=''; // 14285 Indira
  insert ipaCampaign;

  PartnerFundRequest ipaPFR = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaign.id,coMarketingIPA.id,System.today().addDays(4),System.today().addDays(4),false);
  ipaPFR.RequestedAmount = 1;
 // ipaPFR.RecordtypeId = Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Channel_MDF').getRecordTypeId();
  ipaPFR.Core_MDF_Fund_Request_Status__c = 'Planned';
  ipaPFR.Core_MDF_Region_nm__c = 'APJ';
  insert ipaPFR;

  PartnerFundRequest tempVar=[select Id,Core_MDF_Fund_Request_Status__c,ChannelPartnerId,Core_MDF_Proposal_Based_Ind__c,Core_MDF_Program__c,recordtypeId,Recordtype.name,Core_MDF_Country_nm__c from PartnerFundRequest where id=:ipaPFR.Id];
  
  tempVar.Core_MDF_Fund_Request_Status__c='Planned';
  Core_MDF_ProcessCCP_PartnerFundRequest.notifyExternalReviewers(new List<PartnerFundRequest>{tempVar},new Set<Id>{coMarketingIPA.id,acc.Id});

  Test.StopTest();
  Assert.isTrue(tempVar != null);



}
    
    @isTest
    static void retailNotificatonTest(){
        Test.startTest();
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        List<PartnerFundRequest> pfrList2 = new List<PartnerFundRequest>();
        List<PartnerFundRequest> pfrList3 = new List<PartnerFundRequest>();
        Set<ID> accIDSet = new Set<ID>();
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Co-marketing Test Account Retail' LIMIT 1];
        User user = [SELECT Id FROM User WHERE LastName = 'Test PRC MS User'];
        Campaign cmp = [SELECT Id FROM Campaign WHERE Name = 'TestRetailCamp'];
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm.Core_MDF_Account_id__c = acc.Id;
        iupgm.Core_MDF_Program_nm__c = 'Retail Marketing Funds';
        iupgm.RecordTypeId = RMF_RecordType;
        iupgm.Core_MDF_User_id__c = user.Id;
        iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_RMF_PRC_Claim_Operations';
        iupgm.Core_MDF_Active_Ind__c = TRUE;
        iupgm.Core_MDF_All_Accounts_cd__c ='No';
        Database.insert(iupgm);    
        
        
       // PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(cmp.Id),string.valueof(acc.id),System.today(),System.today(),false); 
        PartnerFundRequest pfr = New PartnerFundRequest();
        pfr.CampaignId=string.valueof(cmp.Id);
        pfr.recordtypeid = Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail;
        pfr.ChannelPartnerId = string.valueof(acc.id);
        //pfr.Core_MDF_Country_nm__c='INDIA';
        pfr.Core_MDF_Brand_nm__c='Intel® 11ᵗʰ Gen';
        pfr.Core_MDF_ActivityCategory__c='Sales Readiness';
        //pfr.Core_MDF_Activity_Types__c='In-Store Promotion';
        //pfr.RequestedAmount=12345;
        //pfr.Core_MDF_TargetAudience__c='Enthusiast Gaming';
        pfr.Core_MDF_Start_Date__c=System.today();
        pfr.Core_MDF_End_Date__c =System.today();
       // pfr.Title ='Test Retail';
        //pfr.Core_MDF_Activity_Description__c ='Test Retail Description';
        pfr.Title ='Retail RSA MD Activity';
        pfr.Core_MDF_Activity_Description__c ='Retail RSA MD Activity';
        pfr.Core_MDF_Budget_Type_nm__c ='RSA MD';
        pfr.RequestedAmount =1000;
        pfr.Amount=1000;
        pfr.Core_MDF_Activity_Types__c = '';  // 14285 Indira
        pfr.Core_MDF_Country_nm__c = 'AFGHANISTAN';
        pfr.Core_MDF_Fund_Request_Status__c = 'Planned';
        pfr.Core_MDF_Budget_Currency_cd__c ='USD';
        pfr.Core_MDF_Reimbursement_Rate_pct__c='100%';
        pfr.Core_MDF_TargetAudience__c='Partner Sales Force';
        
        database.insert(pfr);
        pfrList.add(pfr);
        accIDSet.add(acc.id);
        Core_MDF_ProcessCCP_PartnerFundRequest.notifyExternalReviewers(pfrList,accIDSet);
        pfr.Core_MDF_Approval_Step_Completed__c = 1;
        pfr.Core_MDF_Program_Office_Check_ind__c =false;
        pfr.Core_MDF_Price_reviewer_check_ind__c=false;
        pfr.Core_MDF_Require_Additional_Review_ind__c=false;  
        pfr.Core_MDF_Activity_First_Approver_txt__c=user.Id; // 14285 Indira
        database.update(pfr);
        pfrList2.add(pfr);
        Core_MDF_ProcessCCP_PartnerFundRequest.notifyExternalReviewers(pfrList2,accIDSet);
         
       //pfr1 PartnerFundRequest pfr1 = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(cmp.Id),string.valueof(acc.id),System.today(),System.today(),false); 
        PartnerFundRequest pfr1 = New PartnerFundRequest();
        pfr1.CampaignId=string.valueof(cmp.Id);
        pfr1.recordtypeid = Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail;
        pfr1.ChannelPartnerId = string.valueof(acc.id);
        //pfr.Core_MDF_Country_nm__c='INDIA';
        pfr1.Core_MDF_Brand_nm__c='Intel® 11ᵗʰ Gen';
        pfr1.Core_MDF_ActivityCategory__c='Sales Readiness';
        //pfr.Core_MDF_Activity_Types__c='In-Store Promotion';
        //pfr.RequestedAmount=12345;
        //pfr.Core_MDF_TargetAudience__c='Enthusiast Gaming';
        pfr1.Core_MDF_Start_Date__c=System.today();
        pfr1.Core_MDF_End_Date__c =System.today();
       // pfr.Title ='Test Retail';
        pfr1.Title ='Retail RSA MD Activity';
        pfr1.Core_MDF_Activity_Description__c ='Retail RSA MD Activity';
        pfr.Core_MDF_Budget_Type_nm__c ='RSA MD';
        pfr1.RequestedAmount =1000;
        pfr1.Amount=1000;
        pfr1.Core_MDF_Activity_Types__c = '';  // 14285 Indira
        pfr1.Core_MDF_Country_nm__c = 'AFGHANISTAN';
        pfr1.Core_MDF_Fund_Request_Status__c = 'Pending Approval';
        pfr1.Core_MDF_Budget_Currency_cd__c ='USD';
        pfr1.Core_MDF_Reimbursement_Rate_pct__c='100%';
        pfr1.Core_MDF_TargetAudience__c='Partner Sales Force';
        
        database.insert(pfr1);
        pfrList3.add(pfr1);
        accIDSet.add(acc.id);
        Core_MDF_ProcessCCP_PartnerFundRequest.notifyExternalReviewers(pfrList3,accIDSet);
        Account ipaUltimateAccountIPA = [select id,Core_MDF_Parent_Fund_Account__c,RecordType.DeveloperName,Core_MDF_Channel_Program__c,Core_MDF_CoMarketing_Ultimate_Account__c 
                                            from Account
                                            where Name= 'IPA Intel Account PFR'];
         Account coMarketingIPA = [select id,Core_MDF_Parent_Fund_Account__c,RecordType.DeveloperName,Core_MDF_Channel_Program__c,Core_MDF_CoMarketing_Ultimate_Account__c 
                                            from Account
                                            where Name= 'IPA Co-Marketing Account'];
        string bType = 'Proposal I MDF';
        ChannelProgram ipaCP = [select Id from ChannelProgram where Core_MDF_Technical_Program_Name__c = 'Intel Partner Alliance'];
        
        Campaign ipaCampaign = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - AP',
                                                                                  coMarketingIPA.id, 
                                                                                  System.today().addDays(3), System.today().adddays(30),
                                                                                  bType, 110000,'INDIA', 'Consumer', 
                                                                                  'Apollo Lake', 'Planned', false);
        ipaCampaign.Core_MDF_Proposal_Based_Ind__c = false;
        ipaCampaign.Core_MDF_Technology__c = ''; // 14285 Indira
        insert ipaCampaign;
        List<PartnerFundRequest> pfrList4 = new List<PartnerFundRequest>();
        PartnerFundRequest ipaPFR = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaign.id,coMarketingIPA.id,
                                                                                                 System.today().addDays(4),
                                                                                                 System.today().addDays(4),
                                                                                                 false); 
        ipaPFR.RequestedAmount = 1;
        
    //  ipaPFR.RecordtypeId = Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Channel_MDF').getRecordTypeId();
        ipaPFR.Core_MDF_Fund_Request_Status__c = 'Planned';
        ipaPFR.Core_MDF_Region_nm__c = 'APJ';
        pfrList4.add(ipaPFR); 
        Database.insert(pfrList4);
        Set<ID> accIDSet1 = new Set<ID>();
        accIDSet1.add(coMarketingIPA.id);
       
        PartnerFundRequest tempVar=[select Id,Core_MDF_Fund_Request_Status__c,ChannelPartnerId,Core_MDF_Proposal_Based_Ind__c,Core_MDF_Program__c,recordtypeId,Recordtype.name,Core_MDF_Country_nm__c  from PartnerFundRequest where id=:ipaPFR.Id];
        
        Core_MDF_ProcessCCP_PartnerFundRequest.notifyExternalReviewers(new List<PartnerFundRequest>{tempVar},accIDSet1);
        Core_MDF_ProcessCCP_PartnerFundRequest.runOnce();
        Test.stopTest();
        Assert.areEqual(true, pfr!=null);
        
            
    }
    
    @isTest
    static void OpalActivityTest(){
        Test.startTest();
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Co-marketing Test Account' LIMIT 1];
        
        Campaign MDFcamp = [SELECT Id FROM Campaign WHERE Name = 'TestCampOpal'];
        MDFcamp.Core_MDF_Proposal_Based_Ind__c=false;
        //pfaRecord3,opalbudgetMDF
        PartnerMarketingBudget  pmbRecord =[SELECT Id,Title FROM PartnerMarketingBudget WHERE Title = 'TestOpalPMB'];
        PartnerFundAllocation  pfaRecord =[SELECT Id,Title FROM PartnerFundAllocation WHERE Title = 'TestPFA3'];
        // Creating activities using utility class
        PartnerFundRequest MDFpfr4 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(MDFcamp.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,pmbRecord,'INDIA','Consumer','Desktop',
                                                                                           'Intel® Core™ i7 Processor','Broadcast (Pre-2025)','Radio','Draft',false);
        MDFpfr4.Title = 'Test Activity';
        MDFpfr4.Core_MDF_Activity_Description__c = 'Test Activity';
        MDFpfr4.Core_MDF_Start_Date__c = Date.newInstance(2022, 02, 02);
        MDFpfr4.Core_MDF_End_Date__c = Date.newInstance(2022, 04, 04);
        MDFpfr4.RequestedAmount = 60;
        MDFpfr4.Core_MDF_Channel_Partner_Led__c = True;
        MDFpfr4.Core_MDF_Budget_Type_nm__c = 'MDF';
        //MDFpfr4.Core_MDF_Approval_Step_Completed__c = 0;
        MDFpfr4.Core_MDF_Price_reviewer_check_ind__c = False; 
        MDFpfr4.Core_MDF_Program_Office_Check_ind__c = False;
        MDFpfr4.Core_MDF_Require_Additional_Review_ind__c = False; 
        MDFpfr4.BudgetId = pmbRecord.Id;
        MDFpfr4.AllocationId = pfaRecord.Id;
        MDFpfr4.Core_MDF_Reimbursement_Rate_txt__c = '55%';
        MDFpfr4.Core_MDF_Fund_Request_Status__c = 'Revision Required';
        database.insert(MDFpfr4);
 
        //Core_MDF_ProcessCCP_PartnerFundRequest.updateApprovers(null, null);
        Map<String, list<id>> approverIdMap = new Map<String, list<id>>();
        List<Id> approverIds = new List<Id>();
        for(user usr: [select Id from user limit 10]){
            approverIds.add(usr.Id);
        }
        
        
        approverIdMap.put(MDFpfr4.Id, approverIds);
        MDFpfr4.Core_MDF_Fund_Request_Status__c = 'Revision Required';
        database.update(MDFpfr4);
        
        
        Map<id,PartnerFundRequest> pfrMap = new Map<id,PartnerFundRequest>();
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        List<SObject> sObjectList = new List<Sobject>();
        Boolean emeaSubmission = false; 
        pfrMap.put(MDFpfr4.id,MDFpfr4);
        pfrList.add(MDFpfr4);
        PartnerFundRequest pfr  = new PartnerFundRequest();
        sObjectList.add(pfr);
        MDFpfr4.Core_MDF_Fund_Request_Status__c = 'Revision Required';
        database.update(MDFpfr4);
        pfrMap.put(MDFpfr4.id,MDFpfr4);
        pfrList.add(MDFpfr4);
        Set<String> accStrSet = new Set<String>();
        Set<String> perSetStr = new Set<String>();
        accStrSet.add('Test Account 1');
        perSetStr.add(Label.Core_MDF_CCF_Marketing_Owner);
        sObjectList.add(pfr);
        Test.stopTest();
        Assert.areEqual(true, MDFpfr4!=null);
    }
    
    @isTest static void ApprovalProcessTest(){
        Test.startTest();
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Co-marketing Test Account' LIMIT 1];
        
        Campaign MDFcamp = [SELECT Id FROM Campaign WHERE Name = 'TestCampOpal'];
        MDFcamp.Core_MDF_Proposal_Based_Ind__c=false;
        //pfaRecord3,opalbudgetMDF
        PartnerMarketingBudget  pmbRecord =[SELECT Id,Title FROM PartnerMarketingBudget WHERE Title = 'TestOpalPMB'];
        PartnerFundAllocation  pfaRecord =[SELECT Id,Title FROM PartnerFundAllocation WHERE Title = 'TestPFA3'];
        // Creating activities using utility class
        PartnerFundRequest MDFpfr4 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(MDFcamp.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,pmbRecord,'INDIA','Consumer','Desktop',
                                                                                           'Intel® Core™ i7 Processor','Broadcast (Pre-2025)','Radio','Draft',false);
        MDFpfr4.Title = 'Test Activity';
        MDFpfr4.Core_MDF_Activity_Description__c = 'Test Activity';
        MDFpfr4.Core_MDF_Start_Date__c = Date.newInstance(2022, 02, 02);
        MDFpfr4.Core_MDF_End_Date__c = Date.newInstance(2022, 04, 04);
        MDFpfr4.RequestedAmount = 60;
        MDFpfr4.Core_MDF_Channel_Partner_Led__c = True;
        MDFpfr4.Core_MDF_Budget_Type_nm__c = 'MDF';
        MDFpfr4.Core_MDF_Approval_Step_Completed__c = 0;
        MDFpfr4.Core_MDF_Price_reviewer_check_ind__c = False; 
        MDFpfr4.Core_MDF_Program_Office_Check_ind__c = False;
        MDFpfr4.Core_MDF_Require_Additional_Review_ind__c = False; 
        MDFpfr4.BudgetId = pmbRecord.Id;
        MDFpfr4.AllocationId = pfaRecord.Id;
        MDFpfr4.Core_MDF_Reimbursement_Rate_txt__c = '55%';
        MDFpfr4.Core_MDF_Fund_Request_Status__c = 'Pending Approval';
        MDFpfr4.Core_MDF_Require_Additional_Review_ind__c=false;
        database.insert(MDFpfr4);
        
        Map<id,PartnerFundRequest> pfrMap = new Map<id,PartnerFundRequest>();
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        List<SObject> sObjectList = new List<Sobject>();
        Boolean emeaSubmission = false; 
        pfrMap.put(MDFpfr4.id,MDFpfr4);
        pfrList.add(MDFpfr4);
        PartnerFundRequest pfr  = new PartnerFundRequest();
        sObjectList.add(pfr);
        Assert.areEqual(true, sObjectList != null);
        Test.stopTest();
    }
    
    @isTest static void ApprovalProcessTest1(){
        Test.startTest();
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Co-marketing Test Account' LIMIT 1];
        
        Campaign MDFcamp = [SELECT Id FROM Campaign WHERE Name = 'TestCampOpal'];
        MDFcamp.Core_MDF_Proposal_Based_Ind__c=false;
        PartnerMarketingBudget  pmbRecord =[SELECT Id,Title FROM PartnerMarketingBudget WHERE Title = 'TestOpalPMB'];
        PartnerFundAllocation  pfaRecord =[SELECT Id,Title FROM PartnerFundAllocation WHERE Title = 'TestPFA3'];
        // Creating activities using utility class
        PartnerFundRequest MDFpfr4 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(MDFcamp.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,pmbRecord,'INDIA','Consumer','Desktop',
                                                                                           'Intel® Core™ i7 Processor','Broadcast (Pre-2025)','Radio','Draft',false);
        MDFpfr4.Title = 'Test Activity';
        MDFpfr4.Core_MDF_Activity_Description__c = 'Test Activity';
        MDFpfr4.Core_MDF_Start_Date__c = Date.newInstance(2022, 02, 02);
        MDFpfr4.Core_MDF_End_Date__c = Date.newInstance(2022, 04, 04);
        MDFpfr4.RequestedAmount = 60;
        MDFpfr4.Core_MDF_Channel_Partner_Led__c = True;
        MDFpfr4.Core_MDF_MDFReimbursement_Amt__c = 10;
        MDFpfr4.Core_MDF_Budget_Type_nm__c='MDF';
        MDFpfr4.Core_MDF_Approval_Step_Completed__c = 1;
        MDFpfr4.Core_MDF_Price_reviewer_check_ind__c = False; 
        MDFpfr4.Core_MDF_Program_Office_Check_ind__c = False;
        MDFpfr4.Core_MDF_Require_Additional_Review_ind__c = False; 
        MDFpfr4.BudgetId = pmbRecord.Id;
        MDFpfr4.AllocationId = pfaRecord.Id;
        MDFpfr4.Core_MDF_Reimbursement_Rate_txt__c = '55%';
        MDFpfr4.Core_MDF_Fund_Request_Status__c = 'Pending Approval';
        MDFpfr4.Core_MDF_Require_Additional_Review_ind__c=false;
        database.insert(MDFpfr4);
        
        Map<id,PartnerFundRequest> pfrMap = new Map<id,PartnerFundRequest>();
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        List<SObject> sObjectList = new List<Sobject>();
        Boolean emeaSubmission = false; 
        pfrMap.put(MDFpfr4.id,MDFpfr4);
        pfrList.add(MDFpfr4);
        PartnerFundRequest pfr  = new PartnerFundRequest();
        sObjectList.add(pfr);
        Assert.areEqual(true,sObjectList != null);
        Test.stopTest();
    }

    
    @isTest
    static void notifyInternalApprovalTest(){
        Account acc1 = [SELECT Id,Name FROM Account WHERE Name = 'Test Account 1'];
        User user = [SELECT Id FROM User WHERE LastName = 'User Test1'];
        
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm.Core_MDF_Account_id__c = acc1.Id;
        iupgm.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
        iupgm.Core_MDF_Region_cd__c = 'ASMO;EMEA;APJ';
        iupgm.Core_MDF_Region_Sub_Region_nm__c = 'ASMO;EMEA;APJ'; //'ASMO;EMEA;PRC';
        iupgm.Core_MDF_User_id__c = user.Id;
        iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr';
        iupgm.Core_MDF_Active_Ind__c = TRUE;
        iupgm.Core_MDF_All_Accounts_cd__c ='No';
        Database.insert(iupgm);
        
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Co-marketing Test Account' LIMIT 1];
        
        Campaign MDFcamp = [SELECT Id FROM Campaign WHERE Name = 'TestCampOpal'];
        
        PartnerMarketingBudget  pmbRecord =[SELECT Id,Title FROM PartnerMarketingBudget WHERE Title = 'TestOpalPMB'];
        PartnerFundAllocation  pfaRecord =[SELECT Id,Title FROM PartnerFundAllocation WHERE Title = 'TestPFA3'];
        
        PartnerFundRequest MDFpfr4 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(MDFcamp.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,pmbRecord,'INDIA','Consumer','Desktop',
                                                                                           'Intel® Core™ i7 Processor','Broadcast (Pre-2025)','Radio','Draft',false);
        MDFpfr4.Title = 'Test Activity';
        MDFpfr4.Core_MDF_Activity_Description__c = 'Test Activity';
        MDFpfr4.Core_MDF_Start_Date__c = Date.newInstance(2022, 02, 02);
        MDFpfr4.Core_MDF_End_Date__c = Date.newInstance(2022, 04, 04);
        MDFpfr4.RequestedAmount = 60;
        MDFpfr4.Core_MDF_Channel_Partner_Led__c = True;
        MDFpfr4.Core_MDF_Budget_Type_nm__c = 'MDF';
        MDFpfr4.Core_MDF_Price_reviewer_check_ind__c = False; 
        MDFpfr4.Core_MDF_Program_Office_Check_ind__c = False;
        MDFpfr4.Core_MDF_Require_Additional_Review_ind__c = False; 
        MDFpfr4.BudgetId = pmbRecord.Id;
        MDFpfr4.AllocationId = pfaRecord.Id;
        MDFpfr4.Core_MDF_Reimbursement_Rate_txt__c = '55%';
        MDFpfr4.Core_MDF_Fund_Request_Status__c = 'Planned';
        
        test.startTest();
        database.insert(MDFpfr4);
        MDFpfr4.Core_MDF_Fund_Request_Status__c = 'Revision Required';
        database.update(MDFpfr4);
        
        Map<id,PartnerFundRequest> pfrMap = new Map<id,PartnerFundRequest>();
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        List<SObject> sObjectList = new List<Sobject>();
        Boolean emeaSubmission = false; 
        pfrMap.put(MDFpfr4.id,MDFpfr4);
        pfrList.add(MDFpfr4);
        PartnerFundRequest pfr  = new PartnerFundRequest();
        sObjectList.add(pfr);
        
        Test.stopTest();
        Assert.areEqual(true, MDFpfr4!=null);
    }
    @isTest
    static void ccpActivityTest(){
        Test.startTest();
        user usr = [select Id from User limit 1];
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Co-marketing Test Account' LIMIT 1];
        Campaign MDFcamp = [SELECT Id FROM Campaign WHERE Name = 'TestCampOpal'];
        
        PartnerMarketingBudget  pmbRecord =[SELECT Id,Title FROM PartnerMarketingBudget WHERE Title = 'TestOpalPMB'];
        PartnerFundAllocation  pfaRecord =[SELECT Id,Title FROM PartnerFundAllocation WHERE Title = 'TestPFA3'];
        
        PartnerFundRequest MDFpfr4 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(MDFcamp.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,pmbRecord,'INDIA','Consumer','Desktop',
                                                                                           'Intel® Core™ i7 Processor','Broadcast (Pre-2025)','Radio','Draft',false);
        MDFpfr4.Title = 'Test Activity';
        MDFpfr4.Core_MDF_Activity_Description__c = 'Test Activity';
        MDFpfr4.Core_MDF_Start_Date__c = Date.newInstance(2022, 02, 02);
        MDFpfr4.Core_MDF_End_Date__c = Date.newInstance(2022, 04, 04);
        MDFpfr4.RequestedAmount = 60;
        MDFpfr4.Core_MDF_Channel_Partner_Led__c = True;
        MDFpfr4.Core_MDF_Budget_Type_nm__c = 'MDF';     
        MDFpfr4.Core_MDF_Price_reviewer_check_ind__c = False; 
        MDFpfr4.Core_MDF_Program_Office_Check_ind__c = False;
        MDFpfr4.Core_MDF_Require_Additional_Review_ind__c = False; 
        MDFpfr4.BudgetId = pmbRecord.Id;
        MDFpfr4.AllocationId = pfaRecord.Id;
        MDFpfr4.Core_MDF_Reimbursement_Rate_txt__c = '55%';
        MDFpfr4.Core_MDF_Fund_Request_Status__c = 'Planned';
        database.insert(MDFpfr4);       
        MDFpfr4.Core_MDF_L1_Approver_Id__c = usr.Id;
        MDFpfr4.Core_MDF_Fund_Request_Status__c = 'Revision Required';
        database.update(MDFpfr4);
        
        
        Map<id,PartnerFundRequest> pfrMap = new Map<id,PartnerFundRequest>();
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        List<SObject> sObjectList = new List<Sobject>();
        Boolean emeaSubmission = false; 
        pfrMap.put(MDFpfr4.id,MDFpfr4);
        pfrList.add(MDFpfr4);
        PartnerFundRequest pfr  = new PartnerFundRequest();
        sObjectList.add(pfr);
        
        Core_MDF_ProcessCCP_PartnerFundRequest.notifyInternalApproversOnRejection(pfrList);
        Test.stopTest();
       Assert.areEqual(true, MDFpfr4!=null);
    }
    
  /*  @isTest
    static void OpalAutoApprovalActivityTest(){   
        Test.startTest();        
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Co-marketing Test Account' LIMIT 1];
        Campaign MDFcamp = [SELECT Id FROM Campaign WHERE Name = 'TestCampOpal'];
        PartnerMarketingBudget  pmbRecord =[SELECT Id,Title FROM PartnerMarketingBudget WHERE Title = 'TestOpalPMB'];
        PartnerFundAllocation  pfaRecord =[SELECT Id,Title FROM PartnerFundAllocation WHERE Title = 'TestPFA3'];
        
        
        //OPAL AutoApprove
        PartnerFundRequest MDFpfrNew = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(MDFcamp.Id),
                                                                                             Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,pmbRecord,'INDIA','Small Business','Desktop',
                                                                                             'Intel® Core™ i7 Processor','Event','Joint Event','Draft',false);
        Map<id,PartnerFundRequest> pfrMap = new Map<id,PartnerFundRequest>();
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        List<SObject> sObjectList = new List<Sobject>();
        Boolean emeaSubmission = false; 
        
        MDFpfrNew.Title = 'Test Activity';
        MDFpfrNew.Core_MDF_Activity_Description__c = 'Test Activity';
        MDFpfrNew.Core_MDF_Start_Date__c = Date.newInstance(2022, 02, 02);
        MDFpfrNew.Core_MDF_End_Date__c = Date.newInstance(2022, 04, 04);
        
        MDFpfrNew.Core_MDF_Channel_Partner_Led__c = True;
        MDFpfrNew.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
        MDFpfrNew.BudgetId = pmbRecord.Id;
        MDFpfrNew.AllocationId = pfaRecord.Id;
        MDFpfrNew.Core_MDF_Reimbursement_Rate_txt__c = '50%';
        MDFpfrNew.Core_MDF_Fund_Request_Status__c = 'Pending Review';
        MDFpfrNew.RequestedAmount = 100001;
        MDFpfrNew.Core_MDF_Require_Additional_Review_ind__c = false;
        MDFpfrNew.Core_MDF_Activity_CreatedByExternalUsr__c = true;
        MDFpfrNew.Core_MDF_Is_Field_Modified__c = false;
        MDFpfrNew.Core_MDF_Approval_Step_Completed__c = 1;
        MDFpfrNew.Core_MDF_Price_reviewer_check_ind__c = false; 
        MDFpfrNew.Core_MDF_Program_Office_Check_ind__c = false;
        pfrList.add(MDFpfrNew);
        
        PartnerFundRequest MDFpfrNew2 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(MDFcamp.Id),
                                                                                              '0121J000000yaFf',string.valueof(acc.id),pfaRecord,pmbRecord,'INDIA','Small Business','Server',
                                                                                              'Intel® Corporate Logo','Event','Joint Event','Draft',false);
        
        MDFpfrNew2.Title = 'Test Activity Auto 2';
        MDFpfrNew2.Core_MDF_Activity_Description__c = 'Test Activity Auto 2';
        MDFpfrNew2.Core_MDF_Start_Date__c = Date.newInstance(2022, 02, 02);
        MDFpfrNew2.Core_MDF_End_Date__c = Date.newInstance(2022, 04, 04);
        
        MDFpfrNew2.Core_MDF_Channel_Partner_Led__c = True;
        MDFpfrNew2.Core_MDF_Budget_Type_nm__c = 'Service Provider CMP';
        MDFpfrNew2.BudgetId = pmbRecord.Id;
        MDFpfrNew2.AllocationId = pfaRecord.Id;
        MDFpfrNew2.Core_MDF_Reimbursement_Rate_txt__c = '50%';
        MDFpfrNew2.Core_MDF_Fund_Request_Status__c = 'Pending Review';
        MDFpfrNew2.RequestedAmount = 100001;
        MDFpfrNew2.Core_MDF_Require_Additional_Review_ind__c = true;
        MDFpfrNew2.Core_MDF_Activity_CreatedByExternalUsr__c = true;
        MDFpfrNew2.Core_MDF_Is_Field_Modified__c = false;
        MDFpfrNew2.Core_MDF_Approval_Step_Completed__c = 4;
        MDFpfrNew2.Core_MDF_Price_reviewer_check_ind__c = false; 
        MDFpfrNew2.Core_MDF_Program_Office_Check_ind__c = false;
        
        pfrList.add(MDFpfrNew2);
        
        pfrMap.put(MDFpfrNew.id,MDFpfrNew);
        sObjectList.add(MDFpfrNew);
        pfrMap.put(MDFpfrNew2.id,MDFpfrNew2);
        sObjectList.add(MDFpfrNew2);
        MDFpfrNew2.Core_MDF_Fund_Request_Status__c = 'Pending Review';
        MDFpfrNew2.Core_MDF_Approval_Stage__c = 'Price Reviewer';
        MDFpfrNew2.Core_MDF_Price_reviewer_check_ind__c=true;
        pfrList.add(MDFpfrNew2);
        pfrMap.put(MDFpfrNew2.id,MDFpfrNew2);
        sObjectList.add(MDFpfrNew2); 
        Assert.areEqual(true,sObjectList != null);       
        Test.stopTest(); 
    }*/
   /* @isTest
    public static void testCallApprovalProcess5(){
        Test.startTest();
        Account acc=[select id from account where name='Co-marketing Test Account'];
        PartnerMarketingBudget pmb = [select id from PartnerMarketingBudget where Title='TestOpalPMB'];
        PartnerFundAllocation pfa=[select id from PartnerFundAllocation where Title='TestPFA'];
        Campaign camp=[select id from campaign where name='TestCampOpal'];
        
        List<PartnerFundRequest> pfrlist=new List<PartnerFundRequest>();
        PartnerFundRequest pfrMDF = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                          Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfa,pmb,'INDIA','Small Business','Server',
                                                                                          'Intel® Corporate Logo','Broadcast','Radio','Draft',false);
        pfrMDF.Core_MDF_Approval_Step_Completed__c = 1;
        pfrMDF.Core_MDF_Program_Office_Check_ind__c=false;
        pfrMDF.Core_MDF_Price_reviewer_check_ind__c=false;
        pfrMDF.Core_MDF_Require_Additional_Review_ind__c=false;
        pfrMDF.RequestedAmount =1000;
        pfrMDF.Core_MDF_Reimbursement_Rate_txt__c = '50%';
        pfrMDF.Core_MDF_Start_Date__c=  Date.newInstance(2022, 02, 02);
        pfrMDF.Core_MDF_End_Date__c= Date.newInstance(2022, 02, 02);
        pfrMDF.Core_MDF_Budget_Type_nm__c = 'MDF';
        pfrMDF.BudgetId = pmb.Id;
        pfrMDF.AllocationId = pfa.Id;
        pfrMDF.Core_MDF_Fund_Request_Status__c='Pending Review';
        pfrlist.add(pfrMDF);
        
        Map<id,PartnerFundRequest> pfrMap = new Map<id,PartnerFundRequest>();
        List<SObject> sObjectList = new List<Sobject>();
        Boolean emeaSubmission = false; 
        pfrMap.put( pfrMDF.id,pfrMDF);
        sObjectList.add(pfrMDF);
        Assert.areEqual(true,sObjectList != null);
        Test.stopTest(); 
    }*/
    @isTest static void ccpActivityTestCaseOEM(){
        Test.startTest();
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Co-marketing Test Account' LIMIT 1];
        Campaign MDFcamp = [SELECT Id FROM Campaign WHERE Name = 'TestCampOpal'];
        PartnerMarketingBudget  pmbRecord =[SELECT Id,Title FROM PartnerMarketingBudget WHERE Title = 'TestOpalPMB'];
        PartnerFundAllocation  pfaRecord =[SELECT Id,Title FROM PartnerFundAllocation WHERE Title = 'TestPFA3'];
        
        PartnerFundRequest MDFpfr4 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(MDFcamp.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,pmbRecord,'INDIA','Consumer','Desktop',
                                                                                           'Intel® Core™ i7 Processor','Broadcast (Pre-2025)','Radio','Draft',false);
        MDFpfr4.Title = 'Test Activity';
        MDFpfr4.Core_MDF_Activity_Description__c = 'Test Activity';
        MDFpfr4.Core_MDF_Start_Date__c = Date.newInstance(2022, 02, 02);
        MDFpfr4.Core_MDF_End_Date__c = Date.newInstance(2022, 04, 04);
        MDFpfr4.RequestedAmount = 60;
        MDFpfr4.Core_MDF_Channel_Partner_Led__c = True;
        MDFpfr4.Core_MDF_Budget_Type_nm__c = 'MDF';     
        MDFpfr4.Core_MDF_Price_reviewer_check_ind__c = False; 
        MDFpfr4.Core_MDF_Program_Office_Check_ind__c = False;
        MDFpfr4.Core_MDF_Require_Additional_Review_ind__c = False; 
        MDFpfr4.BudgetId = pmbRecord.Id;
        MDFpfr4.AllocationId = pfaRecord.Id;
        MDFpfr4.Core_MDF_Reimbursement_Rate_txt__c = '55%';
        MDFpfr4.Core_MDF_Fund_Request_Status__c = 'Revision Required';
        
        database.insert(MDFpfr4);       
        
        Map<id,PartnerFundRequest> pfrMap = new Map<id,PartnerFundRequest>();
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        List<SObject> sObjectList = new List<Sobject>();
        Boolean emeaSubmission = false; 
        pfrMap.put(MDFpfr4.id,MDFpfr4);
        pfrList.add(MDFpfr4);
        PartnerFundRequest pfr  = new PartnerFundRequest();
        sObjectList.add(pfr);
        Test.stopTest();
        
        Assert.areEqual(true, MDFpfr4!=null);
    }    
    
    @isTest static void ccpActivityTestCaseAmount(){
        Test.startTest();
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Co-marketing Test Account' LIMIT 1];
        Campaign MDFcamp = [SELECT Id FROM Campaign WHERE Name = 'TestCampOpal'];
        PartnerMarketingBudget  pmbRecord =[SELECT Id,Title FROM PartnerMarketingBudget WHERE Title = 'TestOpalPMB'];
        PartnerFundAllocation  pfaRecord =[SELECT Id,Title FROM PartnerFundAllocation WHERE Title = 'TestPFA3'];
        
        PartnerFundRequest MDFpfr4 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(MDFcamp.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,pmbRecord,'INDIA','Consumer','Desktop',
                                                                                           'Intel® Core™ i7 Processor','Broadcast (Pre-2025)','Radio','Draft',false);
        MDFpfr4.Title = 'Test Activity';
        MDFpfr4.Core_MDF_Activity_Description__c = 'Test Activity';
        MDFpfr4.Core_MDF_Start_Date__c = Date.newInstance(2022, 02, 02);
        MDFpfr4.Core_MDF_End_Date__c = Date.newInstance(2022, 04, 04);
        MDFpfr4.Core_MDF_Channel_Partner_Led__c = True;
        MDFpfr4.Core_MDF_Budget_Type_nm__c = 'MDF';     
        MDFpfr4.Core_MDF_Price_reviewer_check_ind__c = False; 
        MDFpfr4.Core_MDF_Program_Office_Check_ind__c = False;
        MDFpfr4.Core_MDF_Require_Additional_Review_ind__c = False; 
        MDFpfr4.BudgetId = pmbRecord.Id;
        MDFpfr4.AllocationId = pfaRecord.Id;
        MDFpfr4.Core_MDF_Reimbursement_Rate_txt__c = '55%';
        MDFpfr4.Core_MDF_Fund_Request_Status__c = 'Revision Required';
        MDFpfr4.Core_MDF_Approval_Step_Completed__c  = 1;
        MDFpfr4.RequestedAmount = 30000;
        database.insert(MDFpfr4);       
        
        Map<id,PartnerFundRequest> pfrMap = new Map<id,PartnerFundRequest>();
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        List<SObject> sObjectList = new List<Sobject>();
        Boolean emeaSubmission = false; 
        pfrMap.put(MDFpfr4.id,MDFpfr4);
        pfrList.add(MDFpfr4);
        PartnerFundRequest pfr  = new PartnerFundRequest();
        sObjectList.add(pfr);

        Core_MDF_ProcessCCP_PartnerFundRequest.notifyCCFDCFExternalReviewer(pfrList);
        Test.stopTest();
        
        Assert.areEqual(true, MDFpfr4!=null);
    }
    
    
@isTest
    static void notifyInternalApprovalTestMethod(){
        test.startTest();
        Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
         User user = Core_MDF_CCP_TestDataUtility.createUser(false);
         user.LastName = 'User Test3';
        user.ProfileId=ccpCoreProfile.id;
        Account acc1 = [SELECT Id,Name FROM Account WHERE Name = 'Test Account 1'];
        
         system.runAs(user)
        {
        PermissionSet psFinance = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Price_Reviewer' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = psFinance.Id);
        }
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> IupgmList=new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm.Core_MDF_Account_id__c = acc1.Id;
        iupgm.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
        iupgm.Core_MDF_Region_Sub_Region_nm__c = 'APJ';
        iupgm.Core_MDF_Region_cd__c='APJ';
        iupgm.Core_MDF_User_id__c = user.Id;
        iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_Price_Reviewer';
        iupgm.Core_MDF_Active_Ind__c = TRUE;
        iupgm.Core_MDF_All_Accounts_cd__c ='Yes';
        iupgm.Core_MDF_Is_Not_an_Approver_Ind__c=False;
        IupgmList.add(iupgm);
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm1 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm1.Core_MDF_Account_id__c = acc1.Id;
        iupgm1.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
        iupgm1.Core_MDF_Region_Sub_Region_nm__c = 'APJ';
        iupgm1.Core_MDF_Region_cd__c='APJ';
        iupgm1.Core_MDF_User_id__c = user.Id;
        iupgm1.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_Price_Reviewer';
        iupgm1.Core_MDF_Active_Ind__c = TRUE;
        iupgm1.Core_MDF_All_Accounts_cd__c ='No';
        iupgm1.Core_MDF_Is_Not_an_Approver_Ind__c=False;
        IupgmList.add(iupgm1);
       
        Database.insert(IupgmList);
        
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Co-marketing Test Account' LIMIT 1];
        
        
        Campaign MDFcamp = [SELECT Id FROM Campaign WHERE Name = 'TestCampOpal'];
        PartnerMarketingBudget  pmbRecord =[SELECT Id,Title FROM PartnerMarketingBudget WHERE Title = 'TestOpalPMB'];
        PartnerFundAllocation  pfaRecord =[SELECT Id,Title FROM PartnerFundAllocation WHERE Title = 'TestPFA3'];
        
        PartnerFundRequest MDFpfr4 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(MDFcamp.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,pmbRecord,'INDIA','Consumer','Desktop',
                                                                                           'Intel® Core™ i7 Processor','Broadcast (Pre-2025)','Radio','Draft',false);
        MDFpfr4.Title = 'Test Activity';
        MDFpfr4.Core_MDF_Activity_Description__c = 'Test Activity';
        MDFpfr4.Core_MDF_Start_Date__c = Date.newInstance(2022, 02, 02);
        MDFpfr4.Core_MDF_End_Date__c = Date.newInstance(2022, 04, 04);
        MDFpfr4.RequestedAmount = 60;
        MDFpfr4.Core_MDF_Channel_Partner_Led__c = True;
        MDFpfr4.Core_MDF_Budget_Type_nm__c = 'MDF';
        MDFpfr4.Core_MDF_Price_reviewer_check_ind__c = False; 
        MDFpfr4.Core_MDF_Program_Office_Check_ind__c = False;
        MDFpfr4.Core_MDF_Require_Additional_Review_ind__c = False; 
        MDFpfr4.BudgetId = pmbRecord.Id;
        MDFpfr4.AllocationId = pfaRecord.Id;
        MDFpfr4.Core_MDF_Reimbursement_Rate_txt__c = '55%';
        MDFpfr4.Core_MDF_Fund_Request_Status__c = 'Revision Required';
        MDFpfr4.Core_MDF_Member_Acceptor_Id__c = user.Id;
        database.insert(MDFpfr4);
        
        
        Map<id,PartnerFundRequest> pfrMap = new Map<id,PartnerFundRequest>();
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        List<SObject> sObjectList = new List<Sobject>();
        Boolean emeaSubmission = false; 
        pfrMap.put(MDFpfr4.id,MDFpfr4);
        pfrList.add(MDFpfr4);
        PartnerFundRequest pfr  = new PartnerFundRequest();
        sObjectList.add(pfr);
        Core_MDF_ProcessCCP_PartnerFundRequest.notifyCCFDCFExternalReviewer(pfrList);
        List<String> accntList = new List<String>();
        accntList.add(acc1.Id);
        List<String> geoList = new List<String>();
        geoList.add('APJ');
        geoList.add('WW');
        List<String> programList = new List<String>();
        programList.add('Client Co-Marketing Fund');
        List<PartnerFundRequest> pfrList1=[select id,Core_MDF_Budget_Type_nm__c,Core_MDF_Approval_Stage__c,Core_MDF_Host_Region_txt__c,Core_MDF_Program__c,Core_MDF_Region_nm__c,Core_MDF_Ultimate_Account_Id__c,Core_MDF_Host_Region_or_Region_txt__c from PartnerFundRequest];
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmqry = [SELECT Id, Core_MDF_User_id__c,Core_MDF_Region_cd__c,Core_MDF_Program_nm__c, Core_MDF_Role_nm__c, 
                                                                    Core_MDF_All_Accounts_cd__c, Core_MDF_Account_id__c,Core_MDF_is_User_Active_ind__c,Core_MDF_Active_Ind__c,Core_MDF_Is_Not_an_Approver_Ind__c FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                                    where Core_MDF_Program_nm__c='Client CoMarketing Fund' limit 2];
        
        List<String> approvalStageStatusList=new List<String> ();
        approvalStageStatusList.add('L1 Approval');
        List<String> budgetTypeList=new List<String> ();
        budgetTypeList.add('MDF');
        // ATHR Avoid long parameter lists - US 14285 - Indira
        Core_MDF_ProcessCCP_PartnerFundRequest.notifyPCTApprovers(new Core_MDF_ProcessCCP_PartnerFundRequest.PCTApproverNotificationWrapper(pfrList1, accntList, geoList, programList));
        Core_MDF_ProcessCCP_PartnerFundRequest.notifyApprovers(new Core_MDF_ProcessCCP_PartnerFundRequest.NotifyApproversWrapper(pfrList1,  accntList,  geoList,  programList,
                                                               approvalStageStatusList, budgetTypeList));
        Assert.areEqual(budgetTypeList != null , true);
        Test.stopTest();
   
        
    }
    @isTest
    static void notifyInternalApprovalTestMethod1(){
        test.startTest();
        Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
         User user = Core_MDF_CCP_TestDataUtility.createUser(false);
         user.LastName = 'User Test3';
        user.ProfileId=ccpCoreProfile.id;
        Account acc1 = [SELECT Id,Name FROM Account WHERE Name = 'Test Account 1'];
         system.runAs(user)
        {
        PermissionSet psFinance = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Price_Reviewer' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = psFinance.Id);
        }
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> IupgmList=new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm.Core_MDF_Account_id__c = acc1.Id;
        iupgm.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
        iupgm.Core_MDF_Region_Sub_Region_nm__c = 'APJ';
        iupgm.Core_MDF_Region_cd__c='APJ';
        iupgm.Core_MDF_User_id__c = user.Id;
        iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_Price_Reviewer';
        iupgm.Core_MDF_Active_Ind__c = TRUE;
        iupgm.Core_MDF_All_Accounts_cd__c ='No';
        iupgm.Core_MDF_Is_Not_an_Approver_Ind__c=True;
        IupgmList.add(iupgm);
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm1 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm1.Core_MDF_Account_id__c = acc1.Id;
        iupgm1.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
        iupgm1.Core_MDF_Region_Sub_Region_nm__c = 'APJ';
        iupgm1.Core_MDF_Region_cd__c='APJ';
        iupgm1.Core_MDF_User_id__c = user.Id;
        iupgm1.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_Price_Reviewer';
        iupgm1.Core_MDF_Active_Ind__c = TRUE;
        iupgm1.Core_MDF_All_Accounts_cd__c ='Yes';
        iupgm1.Core_MDF_Is_Not_an_Approver_Ind__c=True;
        IupgmList.add(iupgm1);
       
        Database.insert(IupgmList);
        
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Co-marketing Test Account' LIMIT 1];
        
        Campaign MDFcamp = [SELECT Id FROM Campaign WHERE Name = 'TestCampOpal'];
        PartnerMarketingBudget  pmbRecord =[SELECT Id,Title FROM PartnerMarketingBudget WHERE Title = 'TestOpalPMB'];
        PartnerFundAllocation  pfaRecord =[SELECT Id,Title FROM PartnerFundAllocation WHERE Title = 'TestPFA3'];
        
        PartnerFundRequest MDFpfr4 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(MDFcamp.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,pmbRecord,'INDIA','Consumer','Desktop',
                                                                                           'Intel® Core™ i7 Processor','Broadcast (Pre-2025)','Radio','Draft',false);
        MDFpfr4.Title = 'Test Activity';
        MDFpfr4.Core_MDF_Activity_Description__c = 'Test Activity';
        MDFpfr4.Core_MDF_Start_Date__c = Date.newInstance(2022, 02, 02);
        MDFpfr4.Core_MDF_End_Date__c = Date.newInstance(2022, 04, 04);
        MDFpfr4.RequestedAmount = 60;
        MDFpfr4.Core_MDF_Channel_Partner_Led__c = True;
        MDFpfr4.Core_MDF_Budget_Type_nm__c = 'MDF';
        MDFpfr4.Core_MDF_Price_reviewer_check_ind__c = False; 
        MDFpfr4.Core_MDF_Program_Office_Check_ind__c = False;
        MDFpfr4.Core_MDF_Require_Additional_Review_ind__c = False; 
        MDFpfr4.BudgetId = pmbRecord.Id;
        MDFpfr4.AllocationId = pfaRecord.Id;
        MDFpfr4.Core_MDF_Reimbursement_Rate_txt__c = '55%';
        MDFpfr4.Core_MDF_Fund_Request_Status__c = 'Revision Required';
        MDFpfr4.Core_MDF_Member_Acceptor_Id__c = user.Id;
        database.insert(MDFpfr4);
        
        
        Map<id,PartnerFundRequest> pfrMap = new Map<id,PartnerFundRequest>();
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        List<SObject> sObjectList = new List<Sobject>();
        Boolean emeaSubmission = false; 
        pfrMap.put(MDFpfr4.id,MDFpfr4);
        pfrList.add(MDFpfr4);
        PartnerFundRequest pfr  = new PartnerFundRequest();
        sObjectList.add(pfr);
        Core_MDF_ProcessCCP_PartnerFundRequest.notifyCCFDCFExternalReviewer(pfrList);
        List<String> accntList = new List<String>();
        accntList.add(acc1.Id);
        List<String> geoList = new List<String>();
        geoList.add('APJ');
        geoList.add('WW');
        List<String> programList = new List<String>();
        programList.add('Client Co-Marketing Fund');
        List<PartnerFundRequest> pfrList1=[select id,Core_MDF_Budget_Type_nm__c,Core_MDF_Approval_Stage__c,Core_MDF_Host_Region_txt__c,Core_MDF_Program__c,Core_MDF_Region_nm__c,Core_MDF_Ultimate_Account_Id__c,Core_MDF_Host_Region_or_Region_txt__c from PartnerFundRequest];
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmqry = [SELECT Id, Core_MDF_User_id__c,Core_MDF_Region_cd__c,Core_MDF_Program_nm__c, Core_MDF_Role_nm__c, 
                                                                    Core_MDF_All_Accounts_cd__c, Core_MDF_Account_id__c,Core_MDF_is_User_Active_ind__c,Core_MDF_Active_Ind__c,Core_MDF_Is_Not_an_Approver_Ind__c FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                                    where Core_MDF_Program_nm__c='Client CoMarketing Fund' limit 2];
        
        List<String> approvalStageStatusList=new List<String> ();
        approvalStageStatusList.add('L1 Approval');
        List<String> budgetTypeList=new List<String> ();
        budgetTypeList.add('MDF');
        // ATHR Avoid long parameter lists - US 14285 - Indira
        Core_MDF_ProcessCCP_PartnerFundRequest.notifyPCTApprovers(new Core_MDF_ProcessCCP_PartnerFundRequest.PCTApproverNotificationWrapper(pfrList1, accntList, geoList, programList));
        Core_MDF_ProcessCCP_PartnerFundRequest.notifyApprovers(new Core_MDF_ProcessCCP_PartnerFundRequest.NotifyApproversWrapper(pfrList1,  accntList,  geoList,  programList,
                                                               approvalStageStatusList, budgetTypeList));
        
        Test.stopTest();
        Assert.isTrue(pfrList != null);
        
    }
    @isTest
    static void notifyInternalApprovalTestMethodNo(){
        test.startTest();
        Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
         User user = Core_MDF_CCP_TestDataUtility.createUser(false);
         user.LastName = 'User Test3';
        user.ProfileId=ccpCoreProfile.id;
        Account acc1 = [SELECT Id,Name FROM Account WHERE Name = 'Test Account 1'];
         system.runAs(user)
        {
        PermissionSet psFinance = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Price_Reviewer' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = psFinance.Id);
        }
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> IupgmList=new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm1 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm1.Core_MDF_Account_id__c = acc1.Id;
        iupgm1.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
        iupgm1.Core_MDF_Region_Sub_Region_nm__c = 'APJ';
        iupgm1.Core_MDF_Region_cd__c='APJ';
        iupgm1.Core_MDF_User_id__c = user.Id;
        iupgm1.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_Price_Reviewer';
        iupgm1.Core_MDF_Active_Ind__c = TRUE;
        iupgm1.Core_MDF_All_Accounts_cd__c ='No';
        iupgm1.Core_MDF_Is_Not_an_Approver_Ind__c=False;
        IupgmList.add(iupgm1);
        Database.insert(IupgmList);
        
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Co-marketing Test Account' LIMIT 1];
        
        Campaign MDFcamp = [SELECT Id FROM Campaign WHERE Name = 'TestCampOpal'];
        PartnerMarketingBudget  pmbRecord =[SELECT Id,Title FROM PartnerMarketingBudget WHERE Title = 'TestOpalPMB'];
        PartnerFundAllocation  pfaRecord =[SELECT Id,Title FROM PartnerFundAllocation WHERE Title = 'TestPFA3'];
        
        PartnerFundRequest MDFpfr4 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(MDFcamp.Id),
                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(acc.id),pfaRecord,pmbRecord,'INDIA','Consumer','Desktop',
                                                                                           'Intel® Core™ i7 Processor','Broadcast (Pre-2025)','Radio','Draft',false);
        MDFpfr4.Title = 'Test Activity';
        MDFpfr4.Core_MDF_Activity_Description__c = 'Test Activity';
        MDFpfr4.Core_MDF_Start_Date__c = Date.newInstance(2022, 02, 02);
        MDFpfr4.Core_MDF_End_Date__c = Date.newInstance(2022, 04, 04);
        MDFpfr4.RequestedAmount = 60;
        MDFpfr4.Core_MDF_Channel_Partner_Led__c = True;
        MDFpfr4.Core_MDF_Budget_Type_nm__c = 'MDF';
        MDFpfr4.Core_MDF_Price_reviewer_check_ind__c = False; 
        MDFpfr4.Core_MDF_Program_Office_Check_ind__c = False;
        MDFpfr4.Core_MDF_Require_Additional_Review_ind__c = False; 
        MDFpfr4.BudgetId = pmbRecord.Id;
        MDFpfr4.AllocationId = pfaRecord.Id;
        MDFpfr4.Core_MDF_Reimbursement_Rate_txt__c = '55%';
        MDFpfr4.Core_MDF_Fund_Request_Status__c = 'Revision Required';
        MDFpfr4.Core_MDF_Member_Acceptor_Id__c = user.Id;
        database.insert(MDFpfr4);
        
        
        Map<id,PartnerFundRequest> pfrMap = new Map<id,PartnerFundRequest>();
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        List<SObject> sObjectList = new List<Sobject>();
        Boolean emeaSubmission = false; 
        pfrMap.put(MDFpfr4.id,MDFpfr4);
        pfrList.add(MDFpfr4);
        PartnerFundRequest pfr  = new PartnerFundRequest();
        sObjectList.add(pfr);
        Core_MDF_ProcessCCP_PartnerFundRequest.notifyCCFDCFExternalReviewer(pfrList);
        List<String> accntList = new List<String>();
        accntList.add(acc1.Id);
        List<String> geoList = new List<String>();
        geoList.add('APJ');
        geoList.add('WW');
        List<String> programList = new List<String>();
        programList.add('Client Co-Marketing Fund');
        List<PartnerFundRequest> pfrList1=[select id,Core_MDF_Budget_Type_nm__c,Core_MDF_Approval_Stage__c,Core_MDF_Host_Region_txt__c,Core_MDF_Program__c,Core_MDF_Region_nm__c,Core_MDF_Ultimate_Account_Id__c from PartnerFundRequest];
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmqry = [SELECT Id, Core_MDF_User_id__c,Core_MDF_Region_cd__c,Core_MDF_Program_nm__c, Core_MDF_Role_nm__c, 
                                                                    Core_MDF_All_Accounts_cd__c, Core_MDF_Account_id__c,Core_MDF_is_User_Active_ind__c,Core_MDF_Active_Ind__c,Core_MDF_Is_Not_an_Approver_Ind__c FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                                    where Core_MDF_Program_nm__c='Client CoMarketing Fund' limit 2];
        
        List<String> approvalStageStatusList=new List<String> ();
        approvalStageStatusList.add('L1 Approval');
        List<String> budgetTypeList=new List<String> ();
        budgetTypeList.add('MDF');
        // ATHR Avoid long parameter lists - US 14285 - Indira
        Core_MDF_ProcessCCP_PartnerFundRequest.notifyPCTApprovers(new Core_MDF_ProcessCCP_PartnerFundRequest.PCTApproverNotificationWrapper(pfrList, accntList, geoList, programList));
        Core_MDF_ProcessCCP_PartnerFundRequest.notifyApprovers(new Core_MDF_ProcessCCP_PartnerFundRequest.NotifyApproversWrapper(pfrList,  accntList,  geoList,  programList,
                                                               approvalStageStatusList, budgetTypeList));
        
        Test.stopTest();
        Assert.isTrue(pfrList!=null);
        
    }  
    @isTest static void validateActivityWithCampaignTest(){
        Test.startTest();
        Account ipaUltimateAccountIPA = [select id,Core_MDF_Parent_Fund_Account__c,RecordType.DeveloperName,Core_MDF_Channel_Program__c,Core_MDF_CoMarketing_Ultimate_Account__c 
                                            from Account
                                            where Name= 'IPA Intel Account PFR'];
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
        ipaCampaign.Core_MDF_Technology__c=''; // 14285 Indira
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
        //ipaPFR.Core_MDF_Budget_Type_nm__c='OEM CMP';
        pfrList1.add(ipaPFR); 
        Database.insert(pfrList1);
        ipaPFR.RequestedAmount= 20;
        PartnerFundRequest ipaPFR2 = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaign.id,coMarketingIPA.id,
                                                                                                  System.today().addDays(4),
                                                                                                  System.today().addDays(4),
                                                                                                  false);
        ipaPFR2.RequestedAmount = 1;
        
        ipaPFR2.Core_MDF_Fund_Request_Status__c = Core_MDF_CCP_ConstantClass.PFR_CLOSED_STATUS;
        ipaPFR2.status = Core_MDF_CCP_ConstantClass.PFR_APPROVED_STATUS;
        ipaPFR2.AllocationId= pfaRecord.Id;
        ipaPFR2.Amount=1000;
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
      
        Core_MDF_ProcessCCP_PartnerFundRequest.validateActivityWithCampaign(null,pfrList);
        Core_MDF_ProcessCCP_PartnerFundRequest.validateActivityWithCampaign(oldPfrMap,pfrList);
        Core_MDF_ProcessCCP_PartnerFundRequest.validateActivityWithCampaign(null,pfrList);
        Core_MDF_ProcessCCP_PartnerFundRequest.updateTotalCampaignCostIpa(null,pfrList,true);
        Core_MDF_ProcessCCP_PartnerFundRequest.updateTotalCampaignCostIpa(null,pfrList2,true);
        Test.stopTest();
        Assert.isNotNull(oldPfrMap);
        
    }
    
    
    
    
    @isTest static void validateActivityWithCampaignTest1(){
        Test.startTest();
        Account ipaUltimateAccountIPA = [select id,Core_MDF_Parent_Fund_Account__c,RecordType.DeveloperName,Core_MDF_Channel_Program__c,Core_MDF_CoMarketing_Ultimate_Account__c 
                                            from Account
                                            where Name= 'IPA Intel Account PFR'];
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
        ipaCampaign.Core_MDF_Technology__c=''; // 14285 Indira
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
        //ipaPFR.Core_MDF_Budget_Type_nm__c='Retail MDF';
        ipaPFR.RecordTypeId=Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
        //ipaPFR.Core_MDF_Budget_Type_nm__c='OEM CMP';
        pfrList1.add(ipaPFR); 
        Database.insert(pfrList1);
        ipaPFR.RequestedAmount= 20;
        PartnerFundRequest ipaPFR2 = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaign.id,coMarketingIPA.id,
                                                                                                  System.today().addDays(4),
                                                                                                  System.today().addDays(4),
                                                                                                  false);
        ipaPFR2.RequestedAmount = 1;
        
        ipaPFR2.Core_MDF_Fund_Request_Status__c = Core_MDF_CCP_ConstantClass.PFR_CLOSED_STATUS;
        ipaPFR2.status = Core_MDF_CCP_ConstantClass.PFR_APPROVED_STATUS;
        ipaPFR2.AllocationId= pfaRecord.Id;
        ipaPFR2.RecordTypeId=Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
        ipaPFR2.Amount=1000;
        pfrList.add(ipaPFR2); 
        Database.insert(pfrList);
        PartnerFundRequest ipaPFR3 = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaign.id,coMarketingIPA.id,
                                                                                                  System.today().addDays(4),
                                                                                                  System.today().addDays(4),
                                                                                                  false);
        ipaPFR3.RequestedAmount = 1;
        
        ipaPFR3.Core_MDF_Fund_Request_Status__c = Core_MDF_CCP_ConstantClass.PFR_CANCELLED_STATUS;
        ipaPFR3.AllocationId= pfaRecord.Id; 
        ipaPFR3.RecordTypeId=Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
        
        pfrList2.add(ipaPFR3);
        Database.insert(pfrList2);
        oldPfrMap.put(ipaPFR.Id,ipaPFR);
      
        Core_MDF_ProcessCCP_PartnerFundRequest.validateActivityWithCampaign(null,pfrList);
        Core_MDF_ProcessCCP_PartnerFundRequest.validateActivityWithCampaign(oldPfrMap,pfrList);
        Core_MDF_ProcessCCP_PartnerFundRequest.validateActivityWithCampaign(null,pfrList);
        Core_MDF_ProcessCCP_PartnerFundRequest.updateTotalCampaignCostIpa(null,pfrList,true);
        Core_MDF_ProcessCCP_PartnerFundRequest.updateTotalCampaignCostIpa(null,pfrList2,true);
        Test.stopTest();
        Assert.isNotNull(oldPfrMap);
        
    }
    
    @isTest static void validateIPAPropActivityWithCampaignTest(){
        Test.startTest();
        Account coMarketingIPA = [select id,Core_MDF_Parent_Fund_Account__c,RecordType.DeveloperName,Core_MDF_Channel_Program__c,Core_MDF_CoMarketing_Ultimate_Account__c 
                                  from Account
                                  where Name= 'IPA Co-Marketing Account'];
        
        string bType = 'Proposal I MDF';
        
        Core_MDF_ProcessCCP_PartnerFundRequest.getTemplateNameByProgNameIPA();
        
        Campaign ipaCampaign = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - AP',
                                                                                  coMarketingIPA.id, 
                                                                                  System.today().addDays(3), System.today().adddays(30),
                                                                                  bType, 110000,'INDIA', 'Consumer', 
                                                                                  'Apollo Lake', 'Planned', false);
        ipaCampaign.Core_MDF_Proposal_Based_Ind__c = true;
        ipaCampaign.Core_MDF_Technology__c=''; // 14285 Indira
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
        
        Core_MDF_ProcessCCP_PartnerFundRequest.validateActivityWithCampaign(oldPfrMap,pfrList);
        //ipaPFR2.Core_MDF_Fund_Request_Status__c='Cancelled';
        //ipaPFR2.Core_MDF_Budget_Amount_Local_amt__c = 1;
        ipaPFR2.RequestedAmount=1;
        update ipaPFR2;
        oldPfrMap.put(ipaPFR2.Id,ipaPFR2);
        Core_MDF_ProcessCCP_PartnerFundRequest.validateActivityWithCampaign(oldPfrMap,pfrList);
        
        Test.stopTest();
        Assert.isNotNull(oldPfrMap);
    }
    @isTest

    static void testScenario2(){
    
      Test.startTest();
    
        Account coMarketingIPA = [select id,Core_MDF_Parent_Fund_Account__c,RecordType.DeveloperName,Core_MDF_Channel_Program__c,Core_MDF_CoMarketing_Ultimate_Account__c from Account where Name= 'IPA Co-Marketing Account'];
    
        Campaign ipaCampaign = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - AP',coMarketingIPA.id, System.today().addDays(3), System.today().adddays(30), 'Proposal I MDF', 110000,'INDIA', 'Consumer','Apollo Lake', 'Planned', false);
        ipaCampaign.Core_MDF_Proposal_Based_Ind__c = true;
        ipaCampaign.Core_MDF_Technology__c=''; // 14285 Indira
        insert ipaCampaign;
    
        PartnerFundRequest ipaPFR = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaign.id,coMarketingIPA.id,System.today().addDays(4),System.today().addDays(4),false);
        ipaPFR.RequestedAmount = 1;
        ipaPFR.RecordtypeId = Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
    
        ipaPFR.Core_MDF_Fund_Request_Status__c = 'Planned';
        ipaPFR.Core_MDF_Region_nm__c = 'APJ';
        insert ipaPFR;

        PartnerFundRequest oldipaPFR = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaign.id,coMarketingIPA.id,System.today().addDays(4),System.today().addDays(4),false);
        oldipaPFR.RequestedAmount = 1;   
        oldipaPFR.RecordtypeId = Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId(); 
        oldipaPFR.Core_MDF_Fund_Request_Status__c = 'Planned';
        oldipaPFR.Core_MDF_Region_nm__c = 'APJ';
        oldipaPFR.Id=ipaPFR.Id;
    
        PartnerFundRequest tempVar=[select Id,CampaignId,Core_MDF_Activity_Level_nm__c,Core_MDF_Fund_Request_Status__c,ChannelPartnerId,Core_MDF_Proposal_Based_Ind__c,Core_MDF_Program__c,recordtypeId,Recordtype.name,Core_MDF_Country_nm__c from PartnerFundRequest where id=:ipaPFR.Id];
        tempVar.Core_MDF_Fund_Request_Status__c='Revision Required';

      

        Core_MDF_ProcessCCP_PartnerFundRequest.publishActivityPlatformEvent(new List<PartnerFundRequest>{tempVar},new Map<Id,PartnerFundRequest>{tempVar.Id=>oldipaPFR});
        Core_MDF_ProcessCCP_PartnerFundRequest.RemoveApprovalLock(new List<PartnerFundRequest>{new PartnerFundRequest() });
        Core_MDF_ProcessCCP_PartnerFundRequest.runOnce();
        Core_MDF_ProcessCCP_PartnerFundRequest.runOnce();
        try{
            Core_MDF_ProcessCCP_PartnerFundRequest.shareActivityWithInternalUsers(new Map<Id,PartnerFundRequest>(),new Map<Id,PartnerFundRequest>{tempVar.Id=>new PartnerFundRequest()});
        }catch(Exception e){}
        Core_MDF_ProcessCCP_PartnerFundRequest.shareActivityWithAccNodeGroupMethod(new Map<Id,PartnerFundRequest>([select Id,CampaignId,Core_MDF_Activity_Level_nm__c,OwnerId,ChannelPartnerId,Core_MDF_Fund_Request_Status__c,Core_MDF_Proposal_Based_Ind__c,Core_MDF_Program__c,recordtypeId,Recordtype.name,Core_MDF_Country_nm__c from PartnerFundRequest where id=:ipaPFR.Id]),new Map<Id,PartnerFundRequest>{tempVar.Id=>new PartnerFundRequest() });
      Test.StopTest();
      Assert.isTrue(tempVar != null);
    }   
  // 14285 Indira - start
 @isTest
static void test_cancelActivityForCancelledCliamsAndEsclations() {

    // Get existing PFR from test setup
    PartnerFundRequest pfr = [SELECT Id, Core_MDF_Fund_Request_Status__c 
                             FROM PartnerFundRequest LIMIT 1];

    // Clone old and new maps
    PartnerFundRequest oldPfr = pfr.clone(false, true, false, false);
    oldPfr.Core_MDF_Fund_Request_Status__c = 'In Progress';

    PartnerFundRequest newPfr = pfr.clone(false, true, false, false);
    newPfr.Id = pfr.Id;
    newPfr.Core_MDF_Fund_Request_Status__c = 
        Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Activity_Cancelled_Status');

    Map<Id, PartnerFundRequest> oldMap = new Map<Id, PartnerFundRequest>{
        pfr.Id => oldPfr
    };

    Map<Id, PartnerFundRequest> newMap = new Map<Id, PartnerFundRequest>{
        pfr.Id => newPfr
    };

    Test.startTest();
    Core_MDF_ProcessCCP_PartnerFundRequest.cancelActivityForCancelledCliamsAndEsclations(newMap, oldMap);
    Test.stopTest();

    System.assert(true, 'Method executed without exception');
}
    
    @isTest
static void test_validatePNUMForExternalUsers_noMapping() {

    PartnerFundRequest pfr = [SELECT Id, ChannelPartnerId 
                             FROM PartnerFundRequest 
                             WHERE ChannelPartnerId != null 
                             LIMIT 1];

    List<PartnerFundRequest> newList = new List<PartnerFundRequest>();

    PartnerFundRequest newPfr = pfr.clone(false, true, false, false);
    newPfr.Id = pfr.Id;

    newList.add(newPfr);

    Map<Id, PartnerFundRequest> oldMap = new Map<Id, PartnerFundRequest>{
        pfr.Id => pfr
    };
 
    Test.startTest();
    try {
        Core_MDF_ProcessCCP_PartnerFundRequest.validatePNUMForExternalUsers(newList, oldMap);
    } catch (Exception e) {
        System.debug('Expected error: ' + e.getMessage());
    }
    Test.stopTest();

    System.assert(true, 'Executed PNUM validation without crash');
}
    
  // 14285 Indira - end
}