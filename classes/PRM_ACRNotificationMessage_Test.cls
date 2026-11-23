/****************************************************************************************************************************
Apex Class Name     : PRM_ACRNotificationMessage_Test 
Version             : 1.0
Created Date        : 10 August 2020

Modification Log    :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------------
* Bharath Kumar          10 August 2020           Test class to cover PRM_ACRNotificationMessage class

****************************************************************************************************************************/
@isTest
public class PRM_ACRNotificationMessage_Test {
    @testSetup
    public static void testData(){
        Id intelRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account intelAcc1 = new Account();//Account
        intelAcc1.RecordTypeId = intelRecType;
        intelAcc1.Name='David Miller';
        intelAcc1.BillingCity='City';
        intelAcc1.BillingStreet='Street';
        intelAcc1.BillingCountry='India';
        intelAcc1.BillingPostalCode='Postal code';
        intelAcc1.Core_IPA_Partner_Role__c = 'Distributor';	
        intelAcc1.Core_CNDA_Number__c='';
        intelAcc1.Core_Account_Type__c='Cloud Service Provider (CSP)';
        intelAcc1.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        intelAcc1.Core_User_Defined_Website__c = 'www.testcwogp.com';
        insert intelAcc1;
        
        Contact con = new Contact();  //Contact
        con.AccountId=intelAcc1.Id;
        con.lastName='Grill';
        con.FirstName='Adam';
        con.email='AdamGrill@rediff.com';
        con.Core_Job_Function__c='Branch Manager';
        con.Core_eRPM_Language_Code__c='Eng';
        con.Core_IPA_PartnerRole__c = 'Service Provider';
        con.Core_Login_Id__c = 'abc';
        insert con;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        PRM_ContactRelationships__c cr2=new PRM_ContactRelationships__c();
        cr2.Name='Employee';
        cr2.PRM_Contact_Relationship_Cd__c='WORKSFOR';
        cr2.PRM_Default_Relationship_Ind__c = true;
        cr2.PRM_Mandatory_Relationship_Ind__c =false ;
        cr2.PRM_InActive_Ind__c = false;
        cr2.PRM_Channel_Program_Id__c=cp.Id;
        insert cr2;
        
        PRM_Account_Contact_Relationship__c accRec = new PRM_Account_Contact_Relationship__c();
        accRec.PRM_Account_Id__c = intelAcc1.Id;
        accRec.PRM_Contact_Id__c = con.Id;
        accRec.PRM_Status_Nm__c = 'Complete';
        accRec.PRM_Relationship_Id__c = cr2.Id;
        accRec.PRM_InActive_Ind__c = false;
        insert accRec;
        
        Test.setCreatedDate(accRec.Id, Datetime.now().addDays(-1));
    }
    
    @isTest
    public static void sendNotif(){		        
		Id contactId = [Select Id from Contact where FirstName='Adam' Limit 1].Id;
        PRM_ACRNotificationMessage.MessageWrapper[] msgWrapper = new PRM_ACRNotificationMessage.MessageWrapper[]{};
        PRM_ACRNotificationMessage.MessageWrapper msgWrap = new PRM_ACRNotificationMessage.MessageWrapper();
        msgWrap.msgCd = 'MSGNEWCON';
        msgWrap.contactId = contactId;
        msgWrapper.add(msgWrap);
        
        PRM_ACRNotificationMessage.sendNotifications(msgWrapper);
        Integer actualResult = [Select Count() from PRM_Account_Contact_Relationship__c where PRM_Contact_Id__c = :contactId and PRM_InActive_Ind__c = false];
        System.assertEquals(1, actualResult);
        
        /*Test.startTest();
        Id accId = [Select Id from Account where Name='David Miller' Limit 1].Id;
        Id cpId = [Select Id from ChannelProgram where Name = 'Intel Partner Alliance' Limit 1].Id;
        
        PRM_ContactRelationships__c cr1=new PRM_ContactRelationships__c();
        cr1.Name='Partner Admin';
        cr1.PRM_Contact_Relationship_Cd__c='PRIMARY';
        cr1.PRM_Default_Relationship_Ind__c = false;
        cr1.PRM_Mandatory_Relationship_Ind__c = true;
        cr1.PRM_InActive_Ind__c = false;
        cr1.PRM_Channel_Program_Id__c=cpId;
        insert cr1;
        
        PRM_Account_Contact_Relationship__c accRec1 = new PRM_Account_Contact_Relationship__c();
        accRec1.PRM_Account_Id__c = accId;
        accRec1.PRM_Contact_Id__c = contactId;
        accRec1.PRM_Status_Nm__c = 'Complete';
        accRec1.PRM_Relationship_Id__c = cr1.Id;
        accRec1.PRM_InActive_Ind__c = false;
        insert accRec1;
        Test.stopTest();
        Test.setCreatedDate(accRec1.Id, Datetime.now());
        
        PRM_ACRNotificationMessage.MessageWrapper[] msgWrapper1 = new PRM_ACRNotificationMessage.MessageWrapper[]{};
        PRM_ACRNotificationMessage.MessageWrapper msgWrap1 = new PRM_ACRNotificationMessage.MessageWrapper();
        msgWrap1.msgCd = 'MSGNEWCON';
        msgWrap1.contactId = contactId;
        msgWrapper1.add(msgWrap1);
        
        PRM_ACRNotificationMessage.sendNotifications(msgWrapper1);
        Integer actualResult1 = [Select Count() from PRM_Account_Contact_Relationship__c where PRM_Contact_Id__c = :contactId and PRM_InActive_Ind__c = false];
        System.assertEquals(2, actualResult1);*/
        
    }
}