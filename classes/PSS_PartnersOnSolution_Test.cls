/********************************************************************************************************************
* Class Name  : PSS_PartnersOnSolution_Test 
* Version     : 1.0 
* Created Date: 04/15/2021
* Modification Log :
* Created By : Hanuma Pantham
*******************************************************************************************************************/
/*IPA2.0: US-TWC729-7976*/
@isTest
public class PSS_PartnersOnSolution_Test {
    
//     @testSetup static void setup(){
        
//         Profile profileName = [Select Id,Name from Profile where Name = 'System Administrator'];
        
//         User testAEUser = new User(UserName = 'testAEUser54321@intel.com.crm.testclass', LastName = 'User', Email = 'testAEUser54321@intel.com',
//                                    Alias = 'taeusr', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8',
//                                    ProfileId = profileName.Id, LanguageLocaleKey = 'en_US');
//         insert testAEUser;
        
//         User testAESuperUser = new User(UserName = 'testAESuperUser54321@intel.com.crm.testclass', LastName = 'User', Email = 'testAESuperUser54321@intel.com',
//                                         Alias = 'taesusr', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8',
//                                         ProfileId = profileName.Id, LanguageLocaleKey = 'en_US');
//         insert testAESuperUser; 
//         PermissionSet adminPset = [Select Id,Name,ProfileId from PermissionSet where Name = 'PMP_Internal_Intel_Admin'];
//         PermissionSetAssignment psetAssignment = new PermissionSetAssignment(AssigneeId = UserInfo.getUserId(),
//                                                                              PermissionSetId = adminPset.Id);
        
        
//         Id AccPartnerRecType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
//         Id AccIntelRecType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        
//         //String recordTypeDevName = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getDeveloperName();
//         //system.debug('recordTypeDevName is'+recordTypeDevName);
//         List<Account> accList = new List<Account>();
//         Account partnerRec = new Account();
//         partnerRec.Name='Test Parent Account1';
//         // partnerRec.RecordTypeId=AccPartnerRecType;
//         partnerRec.RecordTypeId = AccPartnerRecType;
//         partnerRec.Core_IPA_Partner_Segment__c = 'Client Computing';
//         partnerRec.Core_Account_Type__c='Cloud Service Provider (CSP)';
//         partnerRec.BillingCountryCode='USA';
//         partnerRec.BIllingStateCode='AL';
//         partnerRec.BillingCity='Alabama123';
//         partnerRec.BillingStreet='test';
//         partnerRec.BillingPostalCode='123445';
//         accList.add(partnerRec);        
        
//         Account Intelrec= new Account();
//         Intelrec.Name='Test Intel Account 1';
//         Intelrec.RecordTypeId=AccIntelRecType;
//        // Intelrec.RecordType.DeveloperName=recordTypeDevName;
//        // Intelrec.RecordType.developerName = PSS_StaticConstants.PAG_ACCOUNT_DEVELOPERNAME;
//         Intelrec.Core_IPA_Partner_Segment__c = 'Client Computing';
//         Intelrec.Core_Account_Type__c='Cloud Service Provider (CSP)';
//         Intelrec.BillingCountryCode='IND';
//         Intelrec.BIllingStateCode='GJ';
//         Intelrec.BillingCity='New Hellow12';
//         Intelrec.BillingStreet='Hellow22';
//         Intelrec.BillingPostalCode='9876633';
//         Intelrec.Core_User_Defined_Website__c='www.intel.com';
//         accList.add(Intelrec);
//         insert accList;
        
//         Contact con =PSS_TestDataUtility.createPartnerContact('PartnerContact','abc12334testnew@gmail.com',Intelrec.id);
//         insert con;
        
//         Core_Account_Group_Member__c agm= new Core_Account_Group_Member__c();
//         agm.Core_Intel_Account_Id__c=Intelrec.id;
//         agm.Core_Partner_Account_Id__c=partnerRec.id;
//         insert agm;
        
//         PRM_ContactRelationships__c pcR = new PRM_ContactRelationships__c();
//         pcR.Name ='Employee';
//         pcR.PRM_Contact_Relationship_Cd__c ='WORKSFOR';
//         insert pcR;
        
//         PRM_Account_Contact_Relationship__c prmCont= new PRM_Account_Contact_Relationship__c();
//         prmCont.PRM_Account_Id__c =Intelrec.id;
//         prmCont.PRM_Status_Nm__c='Complete';
//         prmCont.PRM_InActive_Ind__c= false;
//         prmCont.PRM_Contact_Id__c = con.id;
//         prmCont.PRM_Relationship_Id__c = pcR.id; 
//         insert prmCont;
        
//         ChannelProgram cp = new ChannelProgram(); //Channel Program
//         cp.Name='Intel Partner Alliance';
//         cp.PRM_programCode__c='IPA';
//         insert cp;
        
//         ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
//         cpl.Name='Titanium';
//         cpl.ProgramId=cp.Id;
//         insert cpl;
        
//         ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
//         cpl1.Name='Member';
//         cpl1.ProgramId=cp.Id;
//         insert cpl1;
        
//         ChannelProgramLevel cpl2=new ChannelProgramLevel(); //Channel Program Level
//         cpl2.Name='Gold';
//         cpl2.ProgramId=cp.Id;
//         insert cpl2;  
        
//         PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
//         acm.PRM_Account_Id__c=partnerRec.id;
//         acm.PRM_Status_Nm__c='Approved';
//         acm.PRM_Channel_Program_Id__c=cp.Id;
//         acm.PRM_Channel_Program_Level_Id__c=cpl.Id;
//         acm.PRM_Partner_Role__c='Service Provider';
//         insert acm;
        
//         PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
//         pb.Name = 'Partner University';
//         pb.PRM_Channel_Program_Id__c = cp.id;
//         pb.PRM_Benefit_Cd__c = 'BNFTSMBA';
//         pb.PRM_Account_Type_Nm__c = 'Both'; 
//         insert pb;
        
//         PRM_PartnerBenefit__c pb1 = new PRM_PartnerBenefit__c(); //Partner Benefit
//         pb1.Name = 'Solutions Marketplace Basic Profile';
//         pb1.PRM_Channel_Program_Id__c = cp.id;
//         pb1.PRM_Benefit_Cd__c = 'BFTMKTPLBC';
//         pb1.PRM_Account_Type_Nm__c = 'Both'; 
//         insert pb1;
//         PRM_PartnerBenefit__c pb2 = new PRM_PartnerBenefit__c(); //Partner Benefit
//         pb2.Name = 'Solutions Marketplace Enhanced';
//         pb2.PRM_Channel_Program_Id__c = cp.id;
//         pb2.PRM_Benefit_Cd__c = 'BFTMKTPLED';
//         pb2.PRM_Account_Type_Nm__c = 'Both'; 
//         insert pb2;
//         PRM_PartnerType__c pt=new PRM_PartnerType__c(); // Partner type
//         pt.Name='Cloud Service Provider (CSP)';
//         pt.PRM_Role_Name__c='Service Provider';
//         pt.PRM_PartneryTypeCode__c='CSP';
//         pt.PRM_PartnerRoleCode__c='SPR';
//         pt.PRM_channelprogram__c=cp.Id;
//         insert pt;
        
//         PRM_VXBnftMatrix__c bem=new PRM_VXBnftMatrix__c(); //Benefit Matrix
//         bem.PRM_Approval_Type_Nm__c='Automatic';
//         bem.PRM_Channel_Program_Id__c=cp.Id;
//         bem.PRM_Channel_Program_Level_Id__c=cpl.Id;
//         bem.PRM_Covered_Account_Ind__c=True;
//         bem.PRM_IsActive_Ind__c=True;
//         bem.PRM_Partner_Benefit_Id__c=pb1.Id;
//         bem.PRM_Partner_Type_Id__c=pt.Id;
//         bem.PRM_Partner_Role_Nm__c='Service Provider';
//         insert bem;
        
//         PRM_VXBnftMatrix__c bem1=new PRM_VXBnftMatrix__c(); //Benefit Matrix
//         bem1.PRM_Approval_Type_Nm__c='Automatic';
//         bem1.PRM_Channel_Program_Id__c=cp.Id;
//         bem1.PRM_Channel_Program_Level_Id__c=cpl.Id;
//         bem1.PRM_Covered_Account_Ind__c=True;
//         bem1.PRM_IsActive_Ind__c=True;
//         bem1.PRM_Partner_Benefit_Id__c=pb2.Id;
//         bem1.PRM_Partner_Type_Id__c=pt.Id;
//         bem1.PRM_Partner_Role_Nm__c='Service Provider';
//         insert bem1;
        
//         PRM_VXBnftMatrix__c bem3=new PRM_VXBnftMatrix__c(); //Benefit Matrix
//         bem3.PRM_Approval_Type_Nm__c='Automatic';
//         bem3.PRM_Channel_Program_Id__c=cp.Id;
//         bem3.PRM_Channel_Program_Level_Id__c=cpl1.Id;
//         bem3.PRM_Covered_Account_Ind__c=True;
//         bem3.PRM_IsActive_Ind__c=True;
//         bem3.PRM_Partner_Benefit_Id__c=pb.Id;
//         bem3.PRM_Partner_Type_Id__c=pt.Id;
//         bem3.PRM_Partner_Role_Nm__c='Service Provider';
//         insert bem3;
        
        
//         PRM_AccountBenefitAssociation__c aba1 = new PRM_AccountBenefitAssociation__c();
//         aba1.PRM_Account_Id__c = partnerRec.Id;
//         aba1.PRM_Partner_Benefit_Id__c = pb.id;
//         aba1.PRM_Status_Nm__c = 'Active';
//         insert aba1;
        
//         prm_skip_trigger__c cs = new prm_skip_trigger__c();
//         cs.Name = 'ABA_Trigger';
//         cs.inactive__c = false;
//         insert cs;
        
//         PRM_BatchCustomSetting__c bsCS = new PRM_BatchCustomSetting__c();
//         bsCS.Name ='BatchFieldValues';
//         bsCS.PRM_PartnerRole__c ='Service Provider';
//         bsCS.PRM_PartnerType__c='Cloud Service Provider (CSP)';
//         bsCS.PRM_MP_Benefits__c ='Solutions Marketplace Enhanced';    
//         insert bsCS;
        
//         //system.debug('partnerRec1.RecordTypeId is'+partnerRec.RecordTypeId);
        
//         PMP_Company__c marketingProfileInfo = new PMP_Company__c();
//         marketingProfileInfo.Name = 'Test Parent Account1';
//         marketingProfileInfo.PMP_Account_Id__c = partnerRec.Id;
//         marketingProfileInfo.PMP_Is_Published_Ind__c = true;
//         marketingProfileInfo.PMP_Benefit_Update_Ind__c = false;
//         marketingProfileInfo.PMP_Company_Lifecycle_Status_Nm__c ='Published';
//         marketingProfileInfo.PMP_One_Partner_ID__c='avsc1234';
//         marketingProfileInfo.PMP_Partner_Program_nm__c='Distributor';
//         marketingProfileInfo.PMP_Partner_Benefit_Type__c ='Solutions Marketplace Enhanced';
//         insert marketingProfileInfo;
//         //system.debug('marketingProfileInfo1 inserted'+marketingProfileInfo);
        
        
//         PMP_OPID_MPI_Rel__c oPIDCompanyDatatest = new PMP_OPID_MPI_Rel__c();
//         oPIDCompanyDatatest.PMP_Marketing_Profile_Id__c=marketingProfileInfo.Id;
//         oPIDCompanyDatatest.PMP_One_Partner_ID__c=partnerRec.Id;
//         oPIDCompanyDatatest.Is_Active__c = true; 
//         // oPIDCompanyDatatest.PMP_One_Partner_ID__r.RecordType.developerName =PSS_StaticConstants.PAG_ACCOUNT_DEVELOPERNAME;
//         insert oPIDCompanyDatatest;
//         //system.debug('oPIDCompanyDatatest inserted'+oPIDCompanyDatatest);
        
//         /*
// PMP_Company__c marketingProfileInfo1 = new PMP_Company__c();
// marketingProfileInfo1.Name = partnerRec.Name;
// marketingProfileInfo1.PMP_Account_Id__c = partnerRec.Id;
// marketingProfileInfo1.PMP_Is_Published_Ind__c = true;
// marketingProfileInfo1.PMP_Benefit_Update_Ind__c = false;
// marketingProfileInfo1.PMP_Company_Lifecycle_Status_Nm__c ='Published';
// marketingProfileInfo1.PMP_One_Partner_ID__c='avsc1234';
// marketingProfileInfo1.PMP_Partner_Program_nm__c='Distributor';
// insert marketingProfileInfo1;
// system.debug('marketingProfileInfo1 inserted'+marketingProfileInfo1);


// PMP_OPID_MPI_Rel__c oPIDCompanyDatatest1 = new PMP_OPID_MPI_Rel__c();
// oPIDCompanyDatatest1.PMP_Marketing_Profile_Id__c=marketingProfileInfo1.Id;
// oPIDCompanyDatatest1.PMP_One_Partner_ID__c=partnerRec.Id;
// oPIDCompanyDatatest1.Is_Active__c = true; 
// // oPIDCompanyDatatest.PMP_One_Partner_ID__r.RecordType.developerName =PSS_StaticConstants.PAG_ACCOUNT_DEVELOPERNAME;
// insert oPIDCompanyDatatest1;
// system.debug('oPIDCompanyDatatest inserted'+oPIDCompanyDatatest1);
// */
        
        
//     }
    
//     @isTest static void testgetPermissionset() {
//         // code_block
        
//         Test.StartTest();
//         PermissionSet adminPset = [Select Id,Name,ProfileId from PermissionSet where Name = 'PMP_Internal_Intel_Admin' LIMIT 1];
//         PermissionSetAssignment psetAssignment = new PermissionSetAssignment(AssigneeId = UserInfo.getUserId(),
//                                                                              PermissionSetId = adminPset.Id);
//         //insert psetAssignment;
        
//         List<PermissionSetAssignment> psassignment = PSS_PartnersOnSolution.getPermissionset();
//         System.assertEquals(adminPset.Name,'PMP_Internal_Intel_Admin');
//         Test.stopTest();
//     }
    
//     @isTest static void testgetSoulutionButtonVisibility(){
        
//         /*PMP_Static_Constants__c st = new PMP_Static_Constants__c();
// st.Name = 'PMP_Sys_Admin_Profile';
// st.PMP_Value__c = 'System Administrator';
// insert st;*/
        
//         PermissionSet adminPset = [Select Id,Name,ProfileId from PermissionSet where Name = 'PMP_Internal_Intel_Admin' LIMIT 1];
//         PermissionSetAssignment psetAssignment = new PermissionSetAssignment(AssigneeId = UserInfo.getUserId(),
//                                                                              PermissionSetId = adminPset.Id);
//         // insert psetAssignment;
        
//         Test.StartTest();
//         Boolean psassignment = PSS_PartnersOnSolution.getSoulutionButtonVisibility();
//         Boolean psassignment1 = PSS_PartnersOnSolution.getexportButtonVisibility();
//         System.assertEquals(adminPset.Name,'PMP_Internal_Intel_Admin');
//         Test.stopTest();
//     }

    
//     @isTest static void testgetPartnerContacts() {
//         PMP_Company__c cmp =[select id,Name from PMP_Company__c where Name = 'Test Parent Account1' LIMIT 1];
//         Test.StartTest();
//         List<contact> conList = PSS_PartnersOnSolution.getPartnerContacts(cmp.id);
//         PSS_PartnersOnSolution.partnersOnSolutionSearch(cmp.Name);
//         system.assertEquals(cmp.Name, 'Test Parent Account1');
//         Test.stopTest();
        
//     }
    
//     @isTest static void testgetPickListValuesIntoList() {
//         Test.StartTest();
//         List<String> pickValue=PSS_PartnersOnSolution.getPickListValuesIntoList();
//         System.assertEquals(pickValue.size()>0, true);
//         Test.stopTest();
//     }
}