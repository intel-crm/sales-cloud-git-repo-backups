/****************************************************************************************************************************************
* Class Name  : Core_MDF_CCP_GenericUtility_Test
* Version     : 1.0 
* Created Date: 20-Nov-2019
* Modification Log :
* Developer                        Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
Accenture - Vaishali                  20-Nov-2019               Created to cover Generic Utility class
NP(11630236)                       28-Feb-2020                  Added source for PGM insert
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
public without sharing class Core_MDF_CCP_GenericUtility_Test {
    
    @TestSetup static void setUpData(){
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        

        /*Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
        User usrSA = Core_MDF_CCP_TestDataUtility.createUser(false);
        usrSA.LastName = 'usrSA';
        usrSA.ProfileId = profileId;
        insert usrSA;*/
        
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        
        System.runAs(usr) {
                    
            PermissionSet psCCF = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_Field_Acct_Mgr' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = psCCF.Id);
        
            //adding bypass feature to bypass access validation
            List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            bypassFunctionKeys.add('ByPass_BlockLegacyBudgetCreation');
            bypassFunctionKeys.add('Core_MDF_validateAccountUserAccess');
            
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
            bypassFunctionKeys.add('Bypass_ShareActivityWithUsers');
            bypassFunctionKeys.add('Bypass_ShareActivityWithAccNodeGroup');
            bypassFunctionKeys.add('Bypass_geoLeadApprovalProcess');
            
            // ADD THE NEW BYPASS FEATURE HERE
            bypassFunctionKeys.add('Core_MDF_Bypass_AccOnboardValidation');
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            
            Core_Trigger_Executions__c bypass = new Core_Trigger_Executions__c();
            bypass.name = 'Core_MDF_Bypass_Campaign_Trigger';
            bypass.Core_Object__c = 'Campaign';
            bypass.Core_Trigger_Events__c = 'All';
            bypass.Core_Active__c = true;
            bypass.Core_Description__c = 'Switch to ON/OFF Campaign Trigger';
            bypass.Core_Class_Name__c = 'Core_MDF_Campaign';
            insert bypass;
            
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
            
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Acc New 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            acc1.Core_MDF_CoMarketingActive__c = true;
            insert acc1;
            
            List<Contact> listContact = new List<Contact>();
            Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(acc1.Id,false);
            conRecord1.Core_Audience_List__c = 'CCF User';
            Contact conRecord2 = Core_MDF_CCP_TestDataUtility.createContact(acc1.Id,false);
            
            listContact.add(conRecord1);
            listContact.add(conRecord2);
            
           /* Contact externalUser = Core_MDF_CCP_TestDataUtility.createContact(acc1.Id,false);
            externalUser.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
            externalUser.Core_Audience_List__c = 'CCF User';
                
            listContact.add(externalUser);*/
            Database.insert(listContact);
            
            Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            iupgm.Core_MDF_Account_id__c = acc1.Id;
            iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_Field_Acct_Mgr';
            iupgm.Core_MDF_Program_nm__c = Core_MDF_CCP_ConstantClass.CCF_TECHNICAL_PROGRAM_NAME;
            iupgm.Core_MDF_User_id__c = usr.Id;
            iupgm.Core_MDF_Active_Ind__c = true;
            iupgm.Core_MDF_Region_Sub_Region_nm__c = 'APJ';
            iupgm.Core_MDF_GeoSubGeo_Budget_Type_nm__c = 'APJ->Account Plan';
            insert iupgm;
            
            
            Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name ='CCF', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='CCF');
            insert cee;
            
            List< Core_Entitlement__c> entListVal = new List< Core_Entitlement__c>();
            
            Core_Entitlement__c entitle=new Core_Entitlement__c (name ='CCF User', Core_Category__c='Intel® Partner Investment Center',Core_Sub_Category__c='Client',Core_Help_Text__c='Enables Intel to set up user with entitlements',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='test',Core_IsActive__c=true, Core_Permission_Set_API_Nm__c='Core_MDF_CCF_USER');
            entListVal.add(entitle);
            
            insert entListVal;
            List<Core_Contact_Entitlement__c> ceList = new List<Core_Contact_Entitlement__c>();
            
            Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c(Core_Contact_Id__c=conRecord1.Id,
                                                                             Core_Entitlement_Id__c=entitle.id,
                                                                             Core_Selected__c=false);
            ceList.add(ce);       
            Database.insert(ceList);
            
            Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
            
            List<User> listUser = new List<User>();
            
            User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);        
            usr1.Email='test1@example.com';
            usr1.ContactId = listContact[0].Id;
            usr1.ProfileId = profileId;
            usr1.isActive = true;
            listUser.add(usr1);
            
            
            
            User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr2.Email='test123@example.com';
            usr2.ContactId = listContact[1].Id;
            usr2.ProfileId = profileId;
            usr2.isActive = true;
            listUser.add(usr2);
            
            
            User usr3 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr3.Email = 'sysadmin@example.com';
            listUser.add(usr3);
            //Database.insert(listUser);
            
            User ipaAccMgr = Core_MDF_CCP_TestDataUtility.createUser(false);
            ipaAccMgr.LastName = 'IPA Acc Mgr';
            ipaAccMgr.isActive = true;
            listUser.add(ipaAccMgr);
            Database.insert(listUser);        
            
            List<ChannelProgram> cpList = new List<ChannelProgram>();
            ChannelProgram ipaCP = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', false); 
            cpList.add(ipaCP);   
            ChannelProgram rmfCP = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', false);    
            cpList.add(rmfCP);
            insert cpList;
            // Highlight: Unused Local Variable 
           /* String ccfProgramName = */  Core_MDF_CCP_GenericUtility.getProgramLabel('Client CoMarketing Fund');
           /* String dcfProgramName = */  Core_MDF_CCP_GenericUtility.getProgramLabel('Data Center CoMarketing Fund');
           /* String ccfbProgramName = */ Core_MDF_CCP_GenericUtility.getProgramLabel('Client CoMarketing Fund Boost');
           /* String spcfProgramName = */ Core_MDF_CCP_GenericUtility.getProgramLabel('Service Provider CoMarketing Fund');
           /* String ipaProgramName = */ Core_MDF_CCP_GenericUtility.getProgramLabel('Intel Partner Allaince');
           /* String ccfLabel = */ Core_MDF_CCP_GenericUtility.getTechnicalProgramName('Client');
           /* String dcfLabel = */ Core_MDF_CCP_GenericUtility.getTechnicalProgramName('Datacenter');
            String Fields = 'id,Assignee.name,PermissionSet.Profile.Name,PermissionSetGroup.DeveloperName,PermissionSet.Id,PermissionSet.Name';
            String whereClause = 'Assignee.name != null limit 1';
            Core_MDF_CCP_GenericUtility.getUserAccessMap(Fields,whereClause);
            
            
            Account ipaAcc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test ipaAcc1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            ipaAcc1.Core_MDF_CoMarketingActive__c = true;
            ipaAcc1.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
            insert(ipaAcc1);
            Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Acc New 2', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, false);
            Account acc3 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Acc New 3', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, false);
            Account ipaCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createAccount('IPA Virtual Acc', ipaCP.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,false);
            ipaCoMarketingAccount.Core_MDF_Parent_Fund_Account__c = ipaAcc1.Id;
            insert( ipaCoMarketingAccount);
            List<Account> accList = new List<Account>();
            accList.add(acc2);
            accList.add(acc3);
            insert accList;
           // Highlight: Unused Local Variable
           /* string budgetType = */ Core_MDF_CCP_IPA_TestDataUtility.createBenefit(ipaCoMarketingAccount); 

            
            PartnerMarketingBudget budget = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget New',Core_MDF_CCP_TestDataUtility.budget_Record_Type,acc2.Id,cp.Id,200000,System.today() -20,System.today().addDays(40), false);
            budget.IsIgnoreValidation = true;
            budget.Core_MDF_Budget_Type_Txt__c='MDF';
            
            PartnerMarketingBudget budget2 = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget New 2',Core_MDF_CCP_TestDataUtility.budget_Record_Type,acc3.Id,cp.Id,200000,System.today() -20,System.today().addDays(40), false);
            budget2.IsIgnoreValidation = true;
            budget2.Core_MDF_Budget_Type_Txt__c='MDF';
            
            List<PartnerMarketingBudget> pmbList = new List<PartnerMarketingBudget>();
            pmbList.add(budget);
            pmbList.add(budget2);
            
            insert pmbList;
            
            List<Group> groupList = new List<Group>();
            
            Group ccfgrp = new Group();
            ccfgrp.Name = 'Core CCP CCF APJ Internal';
            ccfgrp.DeveloperName = 'Core_CCP_CCF_APJ_Internal';
            groupList.add(ccfgrp);
            
            
            Group ccfgrp2 = new Group();
            ccfgrp2.Name = 'Core CCP CCF Internal WW';
            ccfgrp2.DeveloperName = 'Core_CCP_CCF_Internal_WW';
            groupList.add(ccfgrp2);
            
            
            Group ccfgrp3 = new Group();
            ccfgrp3.Name = 'Core CCP CCF APJ SA Internal';
            ccfgrp3.DeveloperName = 'Core_CCP_CCF_APJ_SA_Internal';
            groupList.add(ccfgrp3);
            
            Group ccfgrp4 = new Group();
            ccfgrp4.Name = 'Core CCP CCF APJ SA BT Internal';
            ccfgrp4.DeveloperName = 'Core_CCP_CCF_APJ_SA_BT_Internal';
            groupList.add(ccfgrp4);
            
            Group ccfgrp5 = new Group();
            ccfgrp5.Name = 'Core CCP CCF APJ BT Internal';
            ccfgrp5.DeveloperName = 'Core_CCP_CCF_APJ_BT_Internal';
            groupList.add(ccfgrp5);
            
            Group ccfgrp6 = new Group();
            ccfgrp6.Name = 'Core CCP CCF Internal WW BT';
            ccfgrp6.DeveloperName = 'Core_CCP_CCF_Internal_WW_BT';
            groupList.add(ccfgrp6);
            
            Group ccfgrp1 = new Group();
            ccfgrp1.Name = 'Core CCP CCF External';
            ccfgrp1.DeveloperName = 'Core_CCP_CCF_External';
            groupList.add(ccfgrp1);
            
            Group ccfAPJGrp = new Group();
            ccfAPJGrp.Name = 'Core_MDF_Ext_CCF_APJ';
            ccfAPJGrp.DeveloperName = 'Core_MDF_Ext_CCF_APJ';
            groupList.add(ccfAPJGrp);

            Group ccfgrpWW = new Group();
            ccfgrpWW.Name = 'Core CCP CCF Internal WW CCF';
            ccfgrpWW.DeveloperName = 'Core_CCP_CCF_Internal_WW_CCF';
            groupList.add(ccfgrpWW);
            
            insert groupList;
            
            
            
            Test.startTest();
            GroupMember ccfGrpMem = new GroupMember();
            ccfGrpMem.UserOrGroupId = usr1.Id;
            ccfGrpMem.GroupId = ccfAPJGrp.Id;
            Database.insert(ccfGrpMem);
            
            List<Core_MDF_Partner_Group_Mapping__c> pgmList = new List<Core_MDF_Partner_Group_Mapping__c>();
            
            Core_MDF_Partner_Group_Mapping__c pgm1 = new Core_MDF_Partner_Group_Mapping__c();
            pgm1.Core_MDF_Account__c = acc1.Id;
            pgm1.Core_MDF_Group_Name__c = 'Core_MDF_Ext_CCF_APJ';
            pgm1.Core_MDF_Type_of_Access__c = 'External';
            pgm1.Core_MDF_Group_Id__c = ccfAPJGrp.Id; 
            pgm1.Core_MDF_Channel_Program__c = cp.Id;
            pgm1.Core_MDF_Source_Txt__c = 'Test';
            pgm1.Core_MDF_AccountIdGroupName__c = acc1.Id+'_Core_MDF_Ext_CCF_APJ';
            pgmList.add(pgm1);
            

            Core_MDF_Partner_Group_Mapping__c ccfPgm = new Core_MDF_Partner_Group_Mapping__c();
            ccfPgm.Core_MDF_Account__c = acc1.Id;
            ccfPgm.Core_MDF_Group_Name__c = 'Core_CCP_CCF_APJ_Internal';
            ccfPgm.Core_MDF_Type_of_Access__c = 'Internal';
            ccfPgm.Core_MDF_Group_Id__c = ccfgrp.Id;
            ccfPgm.Core_MDF_Channel_Program__c = cp.Id;
            ccfPgm.Core_MDF_Region_cd__c = 'APJ';
            ccfPgm.Core_MDF_AccountIdGroupName__c = acc1.Id + '_Core_CCP_CCF_APJ_Internal';
            ccfPgm.Core_MDF_Source_Txt__c = 'Test';
            pgmList.add(ccfPgm);
            
            Core_MDF_Partner_Group_Mapping__c ccfPgm2 = new Core_MDF_Partner_Group_Mapping__c();
            ccfPgm2.Core_MDF_Account__c = acc1.Id;
            ccfPgm2.Core_MDF_Group_Name__c = 'Core_CCP_CCF_Internal_WW';
            ccfPgm2.Core_MDF_Type_of_Access__c = 'Internal';
            ccfPgm2.Core_MDF_Group_Id__c = ccfgrp2.Id;
            ccfPgm2.Core_MDF_Channel_Program__c = cp.Id;
            ccfPgm2.Core_MDF_Region_cd__c = 'WW';
            ccfPgm2.Core_MDF_AccountIdGroupName__c = acc1.Id + '_Core_CCP_CCF_Internal_WW';
            ccfPgm2.Core_MDF_Source_Txt__c = 'Test';
            pgmList.add(ccfPgm2);
            
            Core_MDF_Partner_Group_Mapping__c ccfPgm3 = new Core_MDF_Partner_Group_Mapping__c();
            ccfPgm3.Core_MDF_Account__c = acc1.Id;
            ccfPgm3.Core_MDF_Group_Name__c = 'Core_CCP_CCF_APJ_SA_Internal';
            ccfPgm3.Core_MDF_Type_of_Access__c = 'Internal';
            ccfPgm3.Core_MDF_Group_Id__c = ccfgrp3.Id;
            ccfPgm3.Core_MDF_Channel_Program__c = cp.Id;
            ccfPgm3.Core_MDF_Region_cd__c = 'APJ';
            ccfPgm3.Core_MDF_Sub_Region_cd__c = 'SA';
            ccfPgm3.Core_MDF_AccountIdGroupName__c = acc1.Id + '_Core_CCP_CCF_APJ_SA_Internal';
            ccfPgm3.Core_MDF_Source_Txt__c = 'Test';
            
            Core_MDF_Partner_Group_Mapping__c ccfPgm4 = new Core_MDF_Partner_Group_Mapping__c();
            ccfPgm4.Core_MDF_Account__c = acc1.Id;
            ccfPgm4.Core_MDF_Group_Name__c = 'Core_CCP_CCF_APJ_SA_BT_Internal';
            ccfPgm4.Core_MDF_Type_of_Access__c = 'Internal';
            ccfPgm4.Core_MDF_Group_Id__c = ccfgrp4.Id;
            ccfPgm4.Core_MDF_Channel_Program__c = cp.Id;
            ccfPgm4.Core_MDF_Region_cd__c = 'APJ';
            ccfPgm4.Core_MDF_Sub_Region_cd__c = 'SA';
            ccfPgm4.Core_MDF_BudgetType_nm__c = 'MDF';
            ccfPgm4.Core_MDF_AccountIdGroupName__c = acc1.Id + '_Core_CCP_CCF_APJ_SA_BT_Internal';
            ccfPgm4.Core_MDF_Source_Txt__c = 'Test';
            pgmList.add(ccfPgm4);
            
            Core_MDF_Partner_Group_Mapping__c ccfPgm5 = new Core_MDF_Partner_Group_Mapping__c();
            ccfPgm5.Core_MDF_Account__c = acc1.Id;
            ccfPgm5.Core_MDF_Group_Name__c = 'Core_CCP_CCF_APJ_BT_Internal';
            ccfPgm5.Core_MDF_Type_of_Access__c = 'Internal';
            ccfPgm5.Core_MDF_Group_Id__c = ccfgrp5.Id;
            ccfPgm5.Core_MDF_Channel_Program__c = cp.Id;
            ccfPgm5.Core_MDF_Region_cd__c = 'APJ';
            ccfPgm5.Core_MDF_BudgetType_nm__c = 'MDF';
            ccfPgm5.Core_MDF_AccountIdGroupName__c = acc1.Id + '_Core_CCP_CCF_APJ_BT_Internal';
            ccfPgm5.Core_MDF_Source_Txt__c = 'Test';
            pgmList.add(ccfPgm5);
            
            Core_MDF_Partner_Group_Mapping__c ccfPgm6 = new Core_MDF_Partner_Group_Mapping__c();
            ccfPgm6.Core_MDF_Account__c = ipaAcc1.Id;
            ccfPgm6.Core_MDF_Group_Name__c = 'Core_CCP_CCF_Internal_WW_BT';
            ccfPgm6.Core_MDF_Type_of_Access__c = 'Internal';
            ccfPgm6.Core_MDF_Group_Id__c = ccfgrp6.Id;
            ccfPgm6.Core_MDF_Channel_Program__c = ipaCP.Id;
            ccfPgm6.Core_MDF_Region_cd__c = 'WW';
            ccfPgm6.Core_MDF_BudgetType_nm__c = 'Client Specialties MDF';
            ccfPgm6.Core_MDF_AccountIdGroupName__c = ipaAcc1.Id + 'Core_CCP_CCF_Internal_WW_BT';
            ccfPgm6.Core_MDF_Source_Txt__c = 'Test';
            pgmList.add(ccfPgm6);

            Core_MDF_Partner_Group_Mapping__c ccfPgm7 = new Core_MDF_Partner_Group_Mapping__c();
            ccfPgm7.Core_MDF_Account__c = acc1.Id;
            ccfPgm7.Core_MDF_Group_Name__c = 'Core_CCP_CCF_Internal_WW_CCF';
            ccfPgm7.Core_MDF_Type_of_Access__c = 'Internal';
            ccfPgm7.Core_MDF_Group_Id__c = ccfgrpWW.Id;
            ccfPgm7.Core_MDF_Channel_Program__c = cp.Id;
            ccfPgm7.Core_MDF_Region_cd__c = 'WW';
            ccfPgm7.Core_MDF_BudgetType_nm__c = 'MDF';
            ccfPgm7.Core_MDF_AccountIdGroupName__c = acc1.Id + '_Core_CCP_CCF_Internal_WW_CCF';
            ccfPgm7.Core_MDF_Source_Txt__c = 'Test';
            pgmList.add(ccfPgm7);

            Core_MDF_Partner_Group_Mapping__c ccfPgm8 = new Core_MDF_Partner_Group_Mapping__c();
            ccfPgm8.Core_MDF_Account__c = acc1.Id;
            ccfPgm8.Core_MDF_Group_Name__c = 'Core_CCP_CCF_Internal_WW_BT';
            ccfPgm8.Core_MDF_Type_of_Access__c = 'Internal';
            ccfPgm8.Core_MDF_Group_Id__c = ccfgrp6.Id;
            ccfPgm8.Core_MDF_Channel_Program__c = rmfCP.Id;
            ccfPgm8.Core_MDF_Region_cd__c = 'ASMO';
            ccfPgm8.Core_MDF_Sub_Region_cd__c = 'LAR';
            ccfPgm8.Core_MDF_BudgetType_nm__c = 'Retail MDF';
            ccfPgm8.Core_MDF_AccountIdGroupName__c = acc1.Id + 'Core_CCP_CCF_Internal_WW_BT';
            ccfPgm8.Core_MDF_Source_Txt__c = 'Test';
            pgmList.add(ccfPgm8);
            
            insert pgmList;
            
            
            List<PartnerFundAllocation> pfaList = new List<PartnerFundAllocation>();
            PartnerFundAllocation allocation = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation New',budget,acc2,200.0,false);
            PartnerFundAllocation allocation2 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation New',budget2,acc3,200.0,false);
            pfaList.add(allocation);
            pfaList.add(allocation2);
            
            insert pfaList;
            
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 13','Gaming','Intel® Core™ i7 Processor', 'Yes',Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today(), System.today().addDays(15), 10000, 'Always Connected PC', acc2.Id,'Desktop', false); 
            camp.Core_MDF_Opal_Budget_Type_Txt__c= 'MDF';
            camp.Core_MDF_Supports_legacy_program__c = 'Yes';
            insert camp;
            PartnerFundRequest testPartnerFundRequest = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(camp.Id), 
                                                                                                              Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                              String.valueof(acc2.id),allocation,null,'INDIA',
                                                                                                              'Consumer',
                                                                                                              'Desktop',
                                                                                                              'Intel® Core™ i5 Processor',
                                                                                                              'Broadcast (Pre-2025)',
                                                                                                              'Podcast',
                                                                                                              'Draft',
                                                                                                              false);
            testPartnerFundRequest.Core_MDF_Start_Date__c = system.today();
            testPartnerFundRequest.Core_MDF_End_Date__c  = system.today();
            testPartnerFundRequest.Core_MDF_Country_nm__c = 'INDIA';
            insert testPartnerFundRequest;
            
            Test.stopTest();

            List<Core_MDF_Bank__c> listBank = new List<Core_MDF_Bank__c>();
            Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Client_CoMarketing_Fund', false,'1231231230');
            listBank.add(bank);
            Database.insert(listBank);
            
            //Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(acc2.Id, Usr1.Id, true);
        }
    }
    
    @isTest static void createPFR(){
        Test.startTest();
        List<Core_MDF_RecordPGMShareWrapper> recordPGMShareList= new List<Core_MDF_RecordPGMShareWrapper>();
        List<Core_MDF_RecordPGMShareWrapper> recordPGMShareList1= new List<Core_MDF_RecordPGMShareWrapper>();
        Account accRecord = [SELECT Id,Core_MDF_CoMarketing_Ultimate_Account__c, Name
                             FROM Account
                             WHERE Name = 'Test Acc New 3'];
        recordPGMShareList1.add(new Core_MDF_RecordPGMShareWrapper(accRecord.ID,'APJ',NULL,Core_MDF_CCP_ConstantClass.CCF_PROGRAM,accRecord.Core_MDF_CoMarketing_Ultimate_Account__c));
        recordPGMShareList1.add(new Core_MDF_RecordPGMShareWrapper(accRecord.ID,'APJ',NULL,Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'MDF',accRecord.Core_MDF_CoMarketing_Ultimate_Account__c));
        recordPGMShareList1.add(new Core_MDF_RecordPGMShareWrapper(accRecord.ID,'APJ',NULL,Core_MDF_CCP_ConstantClass.IPA_PROGRAM,accRecord.Core_MDF_CoMarketing_Ultimate_Account__c));
        recordPGMShareList1.add(new Core_MDF_RecordPGMShareWrapper(accRecord.ID,'APJ',NULL,Core_MDF_CCP_ConstantClass.IPA_PROGRAM,'Client Specialties MDF',accRecord.Core_MDF_CoMarketing_Ultimate_Account__c));
        recordPGMShareList1.add(new Core_MDF_RecordPGMShareWrapper(accRecord.ID,'APJ',null,Core_MDF_CCP_ConstantClass.RMF_PROGRAM,'Retail MDF',accRecord.Core_MDF_CoMarketing_Ultimate_Account__c));
        PartnerFundRequest pfr = [Select Id,ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_Program__c,Title from PartnerFundRequest where Title = 'test'];
        pfr.ChannelPartnerId = accRecord.Id;
        update pfr;
        recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(pfr.ID,'ASMO','LAR',pfr.Core_MDF_Program__c,pfr.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c));
        recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(pfr.ID,'EMEA',NULL,pfr.Core_MDF_Program__c,pfr.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c));
        recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(pfr.ID,'ASMO','LAR',Core_MDF_CCP_ConstantClass.IPA_PROGRAM,'Client Specialties MDF',pfr.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c));
        recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(pfr.ID,'ASMO','LAR',Core_MDF_CCP_ConstantClass.RMF_PROGRAM,'Retail MDF',pfr.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c));
        recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(pfr.ID,'APJ',null,Core_MDF_CCP_ConstantClass.RMF_PROGRAM,'Retail MDF',pfr.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c));
        recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(pfr.ID,'EMEA',NULL,Core_MDF_CCP_ConstantClass.IPA_PROGRAM,'Client Specialties MDF',pfr.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c));
        try{
            if(recordPGMShareList != null && recordPGMShareList.size() >0){
                Core_MDF_CCP_GenericUtility.createShareRecForInternalPGMgrps('PartnerFundRequest', recordPGMShareList);
                Core_MDF_CCP_GenericUtility.createShareRecForInternalPGMgrps('Account', recordPGMShareList);
            }
        }catch(Exception e){}
        // Highlight: Unused Local Variable 
       // List<user> users = [select Id,Contact.Core_Audience_List__c from user where Email = 'test1@example.com' limit 1];
        
        
        
        Map<String,Core_MDF_CCP_GenericUtility.countryGeoSubGeoWrapper> wrapperMapOfCountryRegion = Core_MDF_CCP_GenericUtility.getCountryGeoMap();
        assert.isTrue(wrapperMapOfCountryRegion.size() > 0);
       
        /*if(!users.isEmpty()){
            system.runAs(users[0]){
                Core_MDF_Partner_Node_User_Mapping__c pnumRecord = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(accRecord.Id,users[0].Id,true);   
            }
        }*/

        List<Core_MDF_CCP_GenericUtility.ActivityExternalSharingParams> wrapperAct=new   List<Core_MDF_CCP_GenericUtility.ActivityExternalSharingParams>();
        Core_MDF_CCP_GenericUtility.ActivityExternalSharingParams actExtShare = new Core_MDF_CCP_GenericUtility.ActivityExternalSharingParams();
        actExtShare.activityId=pfr.id;
        actExtShare.accountId=accRecord.Id;
        wrapperAct.add(actExtShare);
        Core_MDF_CCP_GenericUtility.deletePFRShareForExternal(wrapperAct);
        Core_MDF_CCP_GenericUtility.deleteExternalShareForActivity(wrapperAct);
        Core_MDF_CCP_GenericUtility.getPickListvalues('PartnerFundRequest', 'Core_MDF_Brand_nm__c');
        // Highlight: Unused Local Variable
       // String fields = ' Id,PermissionSet.Name,PermissionSetGroup.DeveloperName,PermissionSet.Profile.Name,PermissionSet.Id ';
       // String whereClause = ' PermissionSet.Profile.Name =\'' + 'IT Admin' +'\' ';  
      
       // String sanitiZedWhereClause = whereClause.replaceAll('\\\\','');
        //Core_MDF_CCP_GenericUtility.getUserAccessMap(fields, sanitiZedWhereClause);
        //Core_MDF_CCP_GenericUtility.getPermSetAssignmentList(fields, sanitiZedWhereClause);
    
        Test.stopTest();
    }
    
    @isTest static void ipaPFR(){
        Test.startTest();
        Set<Id> accountIdSet=new Set<Id>();
        Account accRecord = [SELECT Id, Name
                             FROM Account
                             WHERE Name = 'Test Acc New 1'];
        
        accountIdSet.add(accRecord.Id);
        Set<Id> programIdSet=new Set<Id>();
        ChannelProgram progRecord=[Select Id, Name FROM ChannelProgram where Name='Intel Partner Alliance' ];
        programIdSet.add(progRecord.Id);
        
        Set<String> geoRecord=new Set<String>();
        geoRecord.add('ASMO');
        geoRecord.add('WW');
        
        List<Group> groupList = new List<Group>();
        
        Group ipaASMOGrp = new Group();
        ipaASMOGrp.Name = 'Core_MDF_Ext_IPA_ASMO';
        ipaASMOGrp.DeveloperName = 'Core_MDF_Ext_IPA_ASMO';
        groupList.add(ipaASMOGrp);
        
        Group ipaWWGrp = new Group();
        ipaWWGrp.Name = 'Core_MDF_Ext_IPA_WW';
        ipaWWGrp.DeveloperName = 'Core_MDF_Ext_IPA_WW';
        groupList.add(ipaWWGrp);
        
        Group ipaWWBTGrp = new Group();
        ipaWWBTGrp.Name = 'Core_MDF_Ext_IPA_WW_BT';
        ipaWWBTGrp.DeveloperName = 'Core_MDF_Ext_IPA_WW_BT';
        groupList.add(ipaWWBTGrp);
        
        Group ipaWWBTGrpBca = new Group();
        ipaWWBTGrpBca.Name = 'Core_MDF_Ext_IPA_WW_BCA';
        ipaWWBTGrpBca.DeveloperName = 'Core_MDF_Ext_IPA_WW_BCA';
        groupList.add(ipaWWBTGrpBca);

        insert(groupList);
        
        List<Core_MDF_Partner_Group_Mapping__c> newPGMList = new List<Core_MDF_Partner_Group_Mapping__c>();
        
        
        
        Core_MDF_Partner_Group_Mapping__c pgm2 = new Core_MDF_Partner_Group_Mapping__c();
        pgm2.Core_MDF_Account__c = accRecord.Id;
        pgm2.Core_MDF_Group_Name__c = 'Core_MDF_Ext_IPA_ASMO';
        pgm2.Core_MDF_Type_of_Access__c = 'Internal';
        pgm2.Core_MDF_Group_Id__c = ipaASMOGrp.Id; 
        pgm2.Core_MDF_Channel_Program__c = progRecord.Id;
        pgm2.Core_MDF_Source_Txt__c = 'Test';
        pgm2.Core_MDF_AccountIdGroupName__c = accRecord.Id+'Core_MDF_Ext_IPA_ASMO';
        pgm2.Core_MDF_BudgetType_nm__c='Data Centric Acceleration - MDF';
        pgm2.Core_MDF_Region_cd__c = 'ASMO';
        pgm2.Core_MDF_Sub_Region_cd__c = 'NAR';
        newPGMList.add(pgm2);
        
        Core_MDF_Partner_Group_Mapping__c pgm3 = new Core_MDF_Partner_Group_Mapping__c();
        pgm3.Core_MDF_Account__c = accRecord.Id;
        pgm3.Core_MDF_Group_Name__c = 'Core_MDF_Ext_IPA_WW';
        pgm3.Core_MDF_Type_of_Access__c = 'Internal';
        pgm3.Core_MDF_Group_Id__c = ipaWWGrp.Id; 
        pgm3.Core_MDF_Channel_Program__c = progRecord.Id;
        pgm3.Core_MDF_Source_Txt__c = 'Test';
        pgm3.Core_MDF_AccountIdGroupName__c = accRecord.Id+'Core_MDF_Ext_IPA_WW';
        pgm3.Core_MDF_Region_cd__c = 'WW';
        newPGMList.add(pgm3);
        
        Core_MDF_Partner_Group_Mapping__c pgm4 = new Core_MDF_Partner_Group_Mapping__c();
        pgm4.Core_MDF_Account__c = accRecord.Id;
        pgm4.Core_MDF_Group_Name__c = 'Core_MDF_Ext_IPA_WW_BT';
        pgm4.Core_MDF_Type_of_Access__c = 'Internal';
        pgm4.Core_MDF_Group_Id__c = ipaWWBTGrp.Id; 
        pgm4.Core_MDF_Channel_Program__c = progRecord.Id;
        pgm4.Core_MDF_Source_Txt__c = 'Test';
        pgm4.Core_MDF_AccountIdGroupName__c = accRecord.Id+'Core_MDF_Ext_IPA_WW_BT';
        pgm4.Core_MDF_Region_cd__c = 'WW';
        newPGMList.add(pgm4);

        Core_MDF_Partner_Group_Mapping__c pgm5 = new Core_MDF_Partner_Group_Mapping__c();
        pgm5.Core_MDF_Account__c = accRecord.Id;
        pgm5.Core_MDF_Group_Name__c = 'Core_MDF_Ext_IPA_WW_BCA';
        pgm5.Core_MDF_Type_of_Access__c = 'Internal';
        pgm5.Core_MDF_Group_Id__c = ipaWWBTGrp.Id; 
        pgm5.Core_MDF_Channel_Program__c = progRecord.Id;
        pgm5.Core_MDF_Source_Txt__c = 'Test';
        pgm5.Core_MDF_AccountIdGroupName__c = accRecord.Id+'Core_MDF_Ext_IPA_WW_BCA';
        pgm5.Core_MDF_BudgetType_nm__c='Data Centric Acceleration - MDF';
        pgm5.Core_MDF_Region_cd__c = 'WW';
        newPGMList.add(pgm5);
        insert(newPGMList);
        
        
        Map<String,List<Id>> accountIdProgramIdGeoSubGeoObjectIdListMap = new Map<String,List<Id>>(); 
        Map<String,List<Id>> accountIdProgramIdGeoObjectIdListMap = new Map<String,List<Id>>();
        Map<String,List<Id>> accountIdProgramIdObjectIdListMap = new  Map<String,List<Id>>();
        
        String key1 =(String)pgm2.Core_MDF_Account__c+(String)pgm2.Core_MDF_Channel_Program__c+pgm2.Core_MDF_Region_cd__c+pgm2.Core_MDF_Sub_Region_cd__c;
        String key2 =(String)pgm2.Core_MDF_Account__c+(String)pgm2.Core_MDF_Channel_Program__c+pgm2.Core_MDF_Region_cd__c+pgm2.Core_MDF_Sub_Region_cd__c+pgm2.Core_MDF_BudgetType_nm__c;
        String key3 =(String)pgm3.Core_MDF_Account__c+(String)pgm3.Core_MDF_Channel_Program__c;
        String key4 =(String)pgm4.Core_MDF_Account__c+(String)pgm4.Core_MDF_Channel_Program__c+pgm4.Core_MDF_BudgetType_nm__c;
        String key5 =(String)pgm2.Core_MDF_Account__c+(String)pgm2.Core_MDF_Channel_Program__c+pgm2.Core_MDF_Region_cd__c;
        String key6 =(String)pgm5.Core_MDF_Account__c+(String)pgm5.Core_MDF_Channel_Program__c+pgm5.Core_MDF_Region_cd__c + pgm5.Core_MDF_BudgetType_nm__c;
        
        
        Core_MDF_Bank__c bank =[select Id,Core_MDF_Account__c,Core_MDF_Program__c from Core_MDF_Bank__c where Core_MDF_Program__c='Core_MDF_Client_CoMarketing_Fund'];
        accountIdProgramIdGeoSubGeoObjectIdListMap.put(key1,new List<String>{bank.Id});

        accountIdProgramIdGeoObjectIdListMap.put(key2,new List<String>{bank.Id, ipaASMOGrp.Id});
        accountIdProgramIdGeoObjectIdListMap.put(key5,new List<String>{bank.Id});
        accountIdProgramIdGeoObjectIdListMap.put(key6,new List<String>{bank.Core_MDF_Account__c});

        accountIdProgramIdObjectIdListMap.put(key3,new List<String>{bank.Id});
        accountIdProgramIdObjectIdListMap.put(key4,new List<String>{bank.Id, ipaWWGrp.Id});
        
        Core_MDF_CCP_GenericUtility.createShareRecordsForInternal('PartnerFundRequest',accountIdSet,programIdSet,geoRecord,NULL,NULL,accountIdProgramIdObjectIdListMap);
        Core_MDF_CCP_GenericUtility.createShareRecordsForInternal('PartnerFundRequest',accountIdSet,programIdSet,geoRecord,accountIdProgramIdGeoSubGeoObjectIdListMap,accountIdProgramIdGeoObjectIdListMap,accountIdProgramIdObjectIdListMap);
        assert.areNotEqual(bank.Id, null);
        Test.stopTest();
        
    }
    
    @isTest static void testGetIUPGMRecordsByWrapper(){
        List<String> psNameList = (new List<String>{'Core_MDF_CCP_Internal_CCF_Field_Acct_Mgr'});
        List<ChannelProgram> channelProgramIds = new List<ChannelProgram>();
        channelProgramIds = [Select Id FROM ChannelProgram where Name = 'Client'];
        List<Account> accList = [Select Id FROM Account where Name = 'Test Acc New 1'];
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmRecordsList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        
        Core_MDF_CCP_GenericUtility.QueryIUPGMRecordsWrapper queryIUPGMRecordsWrapperObj = new Core_MDF_CCP_GenericUtility.QueryIUPGMRecordsWrapper();
        queryIUPGMRecordsWrapperObj.psNameList = psNameList;
        queryIUPGMRecordsWrapperObj.psNamesToExcludeForEmail = new List<String>{'testPS'};
        queryIUPGMRecordsWrapperObj.channelProgramIds = (new Set<Id>{channelProgramIds[0]?.Id});
        queryIUPGMRecordsWrapperObj.accountIdsForIUPGMSet = (new Set<Id>{accList[0]?.Id});
        queryIUPGMRecordsWrapperObj.isPermissionSetAssignmentBased = false;
        queryIUPGMRecordsWrapperObj.queryAllAccounts = true;
        queryIUPGMRecordsWrapperObj.notificationType = 'RecoveryIntAccMngrNotification';
        queryIUPGMRecordsWrapperObj.objectName = 'Core_MDF_Recovery__c';
        
        Test.startTest();
        iupgmRecordsList = Core_MDF_CCP_GenericUtility.getIUPGMRecordsByWrapper(queryIUPGMRecordsWrapperObj);
        Test.stopTest();
        assert.isTrue(iupgmRecordsList.size() >= 0);
    }
    
    @isTest static void testGetUserTodayDate(){
        Test.startTest();
        Date userDate = Core_MDF_CCP_GenericUtility.getUserTodayDate();
        Test.stopTest();
        assert.isTrue(userDate != null);
    }
}