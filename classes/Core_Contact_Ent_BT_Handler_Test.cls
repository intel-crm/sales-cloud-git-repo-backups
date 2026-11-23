/***********************************************************************************************************
Apex Class Name:  Core_Contact_Ent_BT_Handler_Test
Version     : 1.0 
Created Date: 11 NOV 2021
Function    : Test Class for the Core_Contact_Ent_BT_Handler
Modification Log :
* Developer                   Date                   Description
* ------------------------------------------------------------------------------------------------------------                  
* Gaurav Kurwade              11/11/2021             Added updateContactBTtrue_Test, updateContactBTfalse_Test
**************************************************************************************************************/

@isTest
public class Core_Contact_Ent_BT_Handler_Test {
    
    @testSetup        
    static void setupDataCreation()
    {
        Account testAccount = new Account(Name='testAccountSetup', Core_Sales_Group__c='Global Accounts',
                                          Core_Account_Type__c='Other', Industry='Others',Core_CIM_ID__c = '223255',Core_English_Only_Name__c = 'exception',
                                          BillingStreet='1234 CBT testAccountSetup', BillingCity='CBT testCity1', BillingState='OR',
                                          BillingCountry='USA', BillingPostalCode='2395',Core_CNDA_Number__c = '126575'/*,Core_IPS_Active__c = true*/);
        insert testAccount;
        Contact testContact = new Contact(FirstName='testFirstName123CBT',Core_Set_ERPM_Status_Bypass__c = true,LastName='testLastCBTName', Email='test1234@testingCBT.com.testsetup',
                                          AccountId=testAccount.id,Core_Personal_Email_Indicator__c = false,Core_English_Only_First_Name__c = 'testFirst',MailingCountry='USA',
                                          Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId());
        
        insert testContact;
        
        Core_AGS_Role__c agsrole = new Core_AGS_Role__c();
        agsrole.Core_Technical_Name__c = 'RDC_Priv_User';
        agsrole.Name = 'Intel Quote Request';
        insert agsrole;
        
        List<Core_Entitlement__c> entInsertList = New List<Core_Entitlement__c>();
        Core_Entitlement__c ee1 = new Core_Entitlement__c();
        ee1.Core_AGS_Role_Id__c = agsrole.Id;
        ee1.Name ='Intel Quote Request1';
        ee1.Entitlement_B2B_B2C_Indicator__c = 'B2B';
        ee1.Core_Display_Name__c = 'Intel Quote Request1';
        ee1.ER_Program__c ='IPS';
        entInsertList.add(ee1);
        
        Core_Entitlement__c ee2 = new Core_Entitlement__c();
        ee2.Core_AGS_Role_Id__c = agsrole.Id;
        ee2.Name ='Intel Quote Request2';
        ee2.Entitlement_B2B_B2C_Indicator__c = 'B2B';
        ee2.Core_Display_Name__c = 'Intel Quote Request2';
        ee2.ER_Program__c ='IPS';
        entInsertList.add(ee2);
        
        Core_Entitlement__c ee3 = new Core_Entitlement__c();
        ee3.Core_AGS_Role_Id__c = agsrole.Id;
        ee3.Name ='Intel Quote Request3';
        ee3.Entitlement_B2B_B2C_Indicator__c = 'B2B';
        ee3.Core_Display_Name__c = 'Intel Quote Request3';
        ee3.ER_Program__c ='IPS';
        entInsertList.add(ee3);
        
        Core_Entitlement__c ee4 = new Core_Entitlement__c();
        ee4.Core_AGS_Role_Id__c = agsrole.Id;
        ee4.Name ='Intel Quote Request4';
        ee4.Entitlement_B2B_B2C_Indicator__c = 'B2B';
        ee4.Core_Display_Name__c = 'Intel Quote Request4';
        ee4.ER_Program__c ='IPS';
        entInsertList.add(ee4);
        
        Core_Entitlement__c ee5 = new Core_Entitlement__c();
        ee5.Core_AGS_Role_Id__c = agsrole.Id;
        ee5.Name ='Intel Quote Request5';
        ee5.Entitlement_B2B_B2C_Indicator__c = 'B2B';
        ee5.Core_Display_Name__c = 'Intel Quote Request5';
        ee5.ER_Program__c ='IPS';
        entInsertList.add(ee5);
        
        Core_Entitlement__c ee6 = new Core_Entitlement__c();
        ee6.Core_AGS_Role_Id__c = agsrole.Id;
        ee6.Name ='Intel Quote Request6';
        ee6.Entitlement_B2B_B2C_Indicator__c = 'B2B';
        ee6.Core_Display_Name__c = 'Intel Quote Request6';
        ee6.ER_Program__c ='IPS';
        entInsertList.add(ee6);
        
        Core_Entitlement__c ee7 = new Core_Entitlement__c();
        ee7.Core_AGS_Role_Id__c = agsrole.Id;
        ee7.Name ='Intel Quote Request7';
        ee7.Entitlement_B2B_B2C_Indicator__c = 'B2B';
        ee7.Core_Display_Name__c = 'Intel Quote Request7';
        ee7.ER_Program__c ='IPS';
        entInsertList.add(ee7);
        
        Core_Entitlement__c ee8 = new Core_Entitlement__c();
        ee8.Core_AGS_Role_Id__c = agsrole.Id;
        ee8.Name ='Intel Quote Request8';
        ee8.Entitlement_B2B_B2C_Indicator__c = 'B2B';
        ee8.Core_Display_Name__c = 'Intel Quote Request8';
        ee8.ER_Program__c ='IPS';
        entInsertList.add(ee8);
        
        Core_Entitlement__c ee9 = new Core_Entitlement__c();
        ee9.Core_AGS_Role_Id__c = agsrole.Id;
        ee9.Name ='Intel Quote Request9';
        ee9.Entitlement_B2B_B2C_Indicator__c = 'B2B';
        ee9.Core_Display_Name__c = 'Intel Quote Request9';
        ee9.ER_Program__c ='IPS';
        entInsertList.add(ee9);
        
        insert entInsertList;
        
        Business_Types__c business = new Business_Types__c(Business_Type_Code__c='Intel Quote Request', Name='IQR', Is_Active__c = true);
        insert business;
        
        Business_Types__c business6 = new Business_Types__c(Business_Type_Code__c='Intel Quote Request6', Name='IQR6', Is_Active__c = true);
        insert business6;
        
        Business_Types__c business7 = new Business_Types__c(Business_Type_Code__c='Intel Quote Request7', Name='IQR7', Is_Active__c = true);
        insert business7;
        
        List<PRM_VXEnttlmntMatrix__c> entMatList = New List<PRM_VXEnttlmntMatrix__c>();
        Id eBREnttRecTypeId = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByName().get(System.Label.EBREntitlementRecordTypeName).getRecordTypeId();
        PRM_VXEnttlmntMatrix__c em = new PRM_VXEnttlmntMatrix__c();
        em.Business_Types__c = business.Id;
        em.PRM_IsActive_Ind__c = true;
        em.PRM_Entitlement_Id__c = ee1.Id;
        em.RecordTypeId = eBREnttRecTypeId;
        em.PRM_Approval_Type_Nm__c = 'Manual';
        entMatList.add(em);
        
        PRM_VXEnttlmntMatrix__c em1 = new PRM_VXEnttlmntMatrix__c();
        em1.Business_Types__c = business.Id;
        em1.PRM_IsActive_Ind__c = true;
        em1.PRM_Entitlement_Id__c = ee2.Id;
        em1.RecordTypeId = eBREnttRecTypeId;
        em1.PRM_Approval_Type_Nm__c = 'Manual';
        entMatList.add(em1);
        
        PRM_VXEnttlmntMatrix__c em2 = new PRM_VXEnttlmntMatrix__c();
        em2.Business_Types__c = business.Id;
        em2.PRM_IsActive_Ind__c = true;
        em2.PRM_Entitlement_Id__c = ee3.Id;
        em2.RecordTypeId = eBREnttRecTypeId;
        em2.PRM_Approval_Type_Nm__c = 'Manual';
        entMatList.add(em2);
        
        PRM_VXEnttlmntMatrix__c em3 = new PRM_VXEnttlmntMatrix__c();
        em3.Business_Types__c = business.Id;
        em3.PRM_IsActive_Ind__c = true;
        em3.PRM_Entitlement_Id__c = ee4.Id;
        em3.RecordTypeId = eBREnttRecTypeId;
        em3.PRM_Approval_Type_Nm__c = 'Manual';
        entMatList.add(em3);
        
        PRM_VXEnttlmntMatrix__c em4 = new PRM_VXEnttlmntMatrix__c();
        em4.Business_Types__c = business.Id;
        em4.PRM_IsActive_Ind__c = true;
        em4.PRM_Entitlement_Id__c = ee5.Id;
        em4.RecordTypeId = eBREnttRecTypeId;
        em4.PRM_Approval_Type_Nm__c = 'Manual';
        entMatList.add(em4);
        
        PRM_VXEnttlmntMatrix__c em6 = new PRM_VXEnttlmntMatrix__c();
        em6.Business_Types__c = business6.Id;
        em6.PRM_IsActive_Ind__c = true;
        em6.PRM_Entitlement_Id__c = ee6.Id;
        em6.RecordTypeId = eBREnttRecTypeId;
        em6.PRM_Approval_Type_Nm__c = 'Manual';
        entMatList.add(em6);
        
        PRM_VXEnttlmntMatrix__c em7 = new PRM_VXEnttlmntMatrix__c();
        em7.Business_Types__c = business7.Id;
        em7.PRM_IsActive_Ind__c = true;
        em7.PRM_Entitlement_Id__c = ee7.Id;
        em7.RecordTypeId = eBREnttRecTypeId;
        em7.PRM_Approval_Type_Nm__c = 'Manual';
        entMatList.add(em7);
        
        PRM_VXEnttlmntMatrix__c em8 = new PRM_VXEnttlmntMatrix__c();
        em8.Business_Types__c = business6.Id;
        em8.PRM_IsActive_Ind__c = true;
        em8.PRM_Entitlement_Id__c = ee8.Id;
        em8.RecordTypeId = eBREnttRecTypeId;
        em8.PRM_Approval_Type_Nm__c = 'Manual';
        entMatList.add(em8);
        
        PRM_VXEnttlmntMatrix__c em9 = new PRM_VXEnttlmntMatrix__c();
        em9.Business_Types__c = business7.Id;
        em9.PRM_IsActive_Ind__c = true;
        em9.PRM_Entitlement_Id__c = ee9.Id;
        em9.RecordTypeId = eBREnttRecTypeId;
        em9.PRM_Approval_Type_Nm__c = 'Manual';
        entMatList.add(em9);
        
        insert entMatList;
        Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c = testContact.Id,Core_Entitlement_Id__c=ee1.Id,Core_Selected__c=true,Core_Status__c = 'Pending', Core_Source__c='Grant Access');
        insert ce1;
        
        Core_Contact_Entitlement__c ce2 = new Core_Contact_Entitlement__c(Core_Contact_Id__c = testContact.Id,Core_Entitlement_Id__c=ee6.Id,Core_Selected__c=false,Core_Status__c = 'Pending', Core_Source__c='Grant Access');
        insert ce2;
        
        Core_Contact_Entitlement__c ce3 = new Core_Contact_Entitlement__c(Core_Contact_Id__c = testContact.Id,Core_Entitlement_Id__c=ee3.Id,Core_Selected__c=true,Core_Status__c = 'Complete', Core_Source__c='Grant Access');
        insert ce3;
        
        Core_Contact_Entitlement__c ce4 = new Core_Contact_Entitlement__c(Core_Contact_Id__c = testContact.Id,Core_Entitlement_Id__c=ee7.Id,Core_Selected__c=false,Core_Status__c = 'Complete', Core_Source__c='Grant Access');
        insert ce4;
    }
    
    static testMethod void CBTValidationRuleException()
    {
        
        Account testAccount = new Account(Name='testAccountSetup', Core_Sales_Group__c='Global Accounts',
                                              Core_Account_Type__c='Other', Industry='Others',Core_CIM_ID__c = '223255',Core_English_Only_Name__c = 'exception',
                                              BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',
                                              BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '126545',Core_IPS_Active__c = true);
            insert testAccount;
            
            Contact testContact = new Contact(FirstName='testFirstName123',Core_Set_ERPM_Status_Bypass__c = true,LastName='testLastName', Email='test1234@testing.com.testsetup',
                                              AccountId=testAccount.id,Core_Personal_Email_Indicator__c = false,MailingCountry='USA',
                                              Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId());
            
            insert testContact;
        
        Core_AGS_Role__c agsrole = new Core_AGS_Role__c();
        agsrole.Core_Technical_Name__c = 'RDC_Priv_User';
        agsrole.Name = 'Developer Zone Premier';
        insert agsrole;
        
        Core_Entitlement__c ee = new Core_Entitlement__c();
        ee.Core_AGS_Role_Id__c = agsrole.Id;
        ee.Name ='Resource & Design Center for Secure Content';
        ee.Entitlement_B2B_B2C_Indicator__c = 'B2B';
        ee.Core_Display_Name__c = 'Developer Zone Premier(CNDA required)';
        ee.ER_Program__c ='DZP';
        insert ee;
        
        Id accCreateRequestId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        Test.StartTest();
        PRM_Registration_Request__c regRequest = new PRM_Registration_Request__c();
        regRequest.Name = 'RR1';
        regRequest.PRM_First_Name__c = 'testFirstName123';
        regRequest.PRM_Last_Name__c = 'testLastName';
        regRequest.PRM_Email_ID__c = 'test1234@testing.com.testsetup';
        regRequest.PRM_Preferred_Language__c='ENG';
        regRequest.Entitlement_Details__c = ee.Id;
        regRequest.PRM_Contact_Salesforce_Id__c = testContact.Id;
        regRequest.PRM_Salesforce_ID__c = testAccount.Id;
        regRequest.Current_Status__c = 'Open';
        regRequest.PRM_Status__c = 'New';
        regRequest.RecordTypeId = accCreateRequestId;
        insert regRequest;
         System.assertEquals('New',regRequest.PRM_Status__c);
           Business_Types__c business = new Business_Types__c(Business_Type_Code__c='Developer Zone Premier', Name='DZP', Is_Active__c = true);
            
            insert business;
        
        Map<Id,Id> entBusinessTypeMap = new Map<Id,Id>();
        entBusinessTypeMap.put(ee.Id, business.Id);
        
        List<Id> reqIdList = new List<Id>();
        reqIdList.add(regRequest.Id);
        //ER_ABT_TriggerHandler_Utility.AssignAccountBusinessTypes(new List<PRM_Registration_Request__c>{regRequest}, entBusinessTypeMap); 
        Core_Contact_Ent_BT_Handler.AssignContactBusinessTypes(new List<PRM_Registration_Request__c>{regRequest}, entBusinessTypeMap);
   
        Test.StopTest();
    }
    
    static testMethod void CBTValidationRuleSuccess()
    {
        Account testAccount = new Account(Name='testAccountSetup', Core_Sales_Group__c='Global Accounts',
                                              Core_Account_Type__c='Other', Industry='Others',Core_CIM_ID__c = '223255',Core_English_Only_Name__c = 'exception',
                                              BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',
                                              BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '126545',Core_IPS_Active__c = true);
            insert testAccount;
            
            Contact testContact = new Contact(FirstName='testFirstName123',Core_Set_ERPM_Status_Bypass__c = true,LastName='testLastName', Email='test1234@testing.com.testsetup',
                                              AccountId=testAccount.id,Core_Personal_Email_Indicator__c = false,Core_English_Only_First_Name__c = 'testFirst',MailingCountry='USA',
                                              Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId());
            
            insert testContact;
        
        Core_AGS_Role__c agsrole = new Core_AGS_Role__c();
        agsrole.Core_Technical_Name__c = 'RDC_Priv_User';
        agsrole.Name = 'Developer Zone Premier';
        insert agsrole;
        
        Core_Entitlement__c ee = new Core_Entitlement__c();
        ee.Core_AGS_Role_Id__c = agsrole.Id;
        ee.Name ='Resource & Design Center for Secure Content';
        ee.Entitlement_B2B_B2C_Indicator__c = 'B2B';
        ee.Core_Display_Name__c = 'Developer Zone Premier(CNDA required)';
        ee.ER_Program__c ='DZP';
        insert ee;
        
         Business_Types__c business = new Business_Types__c(Business_Type_Code__c='Developer Zone Premier', Name='DZP', Is_Active__c = true);
            
            insert business;
        
        Id eBREnttRecTypeId = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByName().get(System.Label.EBREntitlementRecordTypeName).getRecordTypeId();
        PRM_VXEnttlmntMatrix__c em = new PRM_VXEnttlmntMatrix__c();
        em.Business_Types__c = business.Id;
        em.PRM_IsActive_Ind__c = true;
        em.PRM_Entitlement_Id__c = ee.Id;
        em.RecordTypeId = eBREnttRecTypeId;
        em.PRM_Approval_Type_Nm__c = 'Manual';
        insert em;
        
        Map<Id,Id> entBusinessTypeMap = new Map<Id,Id>();
        entBusinessTypeMap.put(ee.Id, business.Id);
        
        Id accCreateRequestId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        Test.StartTest();
        PRM_Registration_Request__c regRequest = new PRM_Registration_Request__c();
        regRequest.Name = 'RR1';
        regRequest.PRM_First_Name__c = 'testFirstName123';
        regRequest.PRM_Last_Name__c = 'testLastName';
        regRequest.PRM_Email_ID__c = 'test1234@testing.com.testsetup';
        regRequest.PRM_Preferred_Language__c='ENG';
        regRequest.Entitlement_Details__c = ee.Id;
        regRequest.PRM_Contact_Salesforce_Id__c = testContact.Id;
        regRequest.PRM_Salesforce_ID__c = testAccount.Id;
        regRequest.Current_Status__c = 'Open';
        regRequest.PRM_Status__c = 'New';
        regRequest.RecordTypeId = accCreateRequestId;
        insert regRequest;   
        System.assertEquals('New',regRequest.PRM_Status__c);
        List<Id> reqIdList = new List<Id>();
        reqIdList.add(regRequest.Id);
        //ER_ABT_TriggerHandler_Utility.AssignAccountBusinessTypes(new List<PRM_Registration_Request__c>{regRequest}, entBusinessTypeMap);
        Core_Contact_Ent_BT_Handler.AssignContactBusinessTypes(new List<PRM_Registration_Request__c>{regRequest}, entBusinessTypeMap);
        
        Test.StopTest();
    }
    static testMethod void CBTValidateContactEntPendingTrue()
    {
        Contact testContact = [Select Id,name from Contact Limit 1]; 
        Core_Entitlement__c ee = [Select Id,Core_Display_Name__c from Core_Entitlement__c WHERE Core_Display_Name__c = 'Intel Quote Request5' LIMIT 1];
       
		Core_Contact_Entitlement__c ce2 = new Core_Contact_Entitlement__c(Core_Contact_Id__c = testContact.Id,Core_Entitlement_Id__c=ee.id,Core_Selected__c=true,Core_Status__c = 'Pending', Core_Source__c='Grant Access');
        Test.StartTest();
        insert ce2;
        System.assertEquals(true,ce2.Core_Selected__c);
		Test.StopTest();        
    }
    static testMethod void CBTValidateContactEntCompleteTrue()
    {
        Contact testContact = [Select Id,name,AccountId from Contact Limit 1];
        Core_Entitlement__c ee = [Select Id,Core_Display_Name__c from Core_Entitlement__c WHERE Core_Display_Name__c = 'Intel Quote Request5' LIMIT 1];
        
        Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c = testContact.Id,Core_Entitlement_Id__c=ee.id,Core_Selected__c=true,Core_Status__c = 'Complete', Core_Source__c='Grant Access');
        Test.StartTest();
        insert ce1;
        System.assertEquals(true,ce1.Core_Selected__c); 
		Test.StopTest();        
    }
    static testMethod void CBTValidateContactEntPendingFalse()
    {
        Contact testContact = [Select Id,name from Contact Limit 1]; 
        Core_Entitlement__c ee = [Select Id,Core_Display_Name__c from Core_Entitlement__c WHERE Core_Display_Name__c = 'Intel Quote Request8' LIMIT 1];
        
        Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c = testContact.Id,Core_Entitlement_Id__c=ee.id,Core_Selected__c=false,Core_Status__c = 'Pending', Core_Source__c='Grant Access');
        Test.StartTest();
        insert ce1;
        System.assertEquals(false,ce1.Core_Selected__c); 
        Test.StopTest();
        
    }
    static testMethod void CBTValidateContactEntCompleteFalse()
    {
        Contact testContact = [Select Id,name from Contact Limit 1]; 
        Core_Entitlement__c ee = [Select Id,Core_Display_Name__c from Core_Entitlement__c WHERE Core_Display_Name__c = 'Intel Quote Request9' LIMIT 1];
        
        Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c = testContact.Id,Core_Entitlement_Id__c=ee.id,Core_Selected__c=false,Core_Status__c = 'Complete', Core_Source__c='Grant Access');
        Test.StartTest();
        insert ce1;
        System.assertEquals(false,ce1.Core_Selected__c); 
        Test.StopTest();
    }
}