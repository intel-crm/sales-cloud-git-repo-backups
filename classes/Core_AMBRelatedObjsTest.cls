/**************************************************************************************
Apex Class Name:  Core_AMBRelatedObjsTest
Version     : 1.0 
Created Date: 04 July 2018
Function    : Test Class for Core_AMBRelatedObjs
Modification Log :
* Developer                       Date                    Description
* ----------------------------------------------------------------------------                 
* Ragamalika Mohanraj             04/07/2018              Original Version
*************************************************************************************/
@isTest
public class Core_AMBRelatedObjsTest{

 public static testmethod void AMB_test1() {
       
        // Insert an account, insert users, associate them with the account via custom account team records
        Account testAccount = Core_Test_Utility.createAccount(1)[0];
        insert testAccount;
        
        Contact testContact = new Contact(FirstName='Test', LastName='Contact', Email='test@intel.com', AccountId=testAccount.Id);
        insert testContact;
       List<Account_Meeting_Brief__c> briefList = new List<Account_Meeting_Brief__c>();
       Account_Meeting_Brief__c brief1 = new Account_Meeting_Brief__c(Account__c=testAccount.Id, Core_Account_Brief_Event__c='Test Event',
                                                                      Core_Account_Meeting_Location__c='Quahog', Core_Executive_Name__c='Peter Griffin',
                                                                      Core_Account_Meeting_Date__c=Date.today(), Core_Account_Meeting_Time__c= '10:00 AM',
                                                                      Core_Account_Meeting_End_Time__c = '11:00 AM',
                                                                      Core_Account_Meeting_Customer_Contact__c=testContact.Id,
                                                                      Core_Account_Meeting_Intel_Contact__c=testContact.Id);
        try{
        insert brief1;
        system.assertEquals('Test Event', brief1.Core_Account_Brief_Event__c);
        briefList.add(brief1);
        
        }catch(Exception ex){
            system.assertEquals(ex.getMessage(), ex.getMessage());
        }
    
     Test.startTest();
  
  PageReference pageRef = Page.Core_New_Meeting_Objectives; 
  pageRef.getParameters().put('id', String.valueOf(briefList[0].Id));
  Test.setCurrentPage(pageRef);

  ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(briefList);
  stdSetController.setSelected(briefList);
  Core_AMBRelatedObjs ext = new Core_AMBRelatedObjs(stdSetController);
  ext.getNewMeetingObjectivesUrl();
 Test.stopTest();

}

 public static testmethod void AMB_test2() {
       
        // Insert an account, insert users, associate them with the account via custom account team records
        Account testAccount = Core_Test_Utility.createAccount(1)[0];
        insert testAccount;
        
        Contact testContact = new Contact(FirstName='Test', LastName='Contact', Email='test@intel.com', AccountId=testAccount.Id);
        insert testContact;
       List<Account_Meeting_Brief__c> briefList = new List<Account_Meeting_Brief__c>();
       Account_Meeting_Brief__c brief1 = new Account_Meeting_Brief__c(Account__c=testAccount.Id, Core_Account_Brief_Event__c='Test Event',
                                                                      Core_Account_Meeting_Location__c='Quahog', Core_Executive_Name__c='Peter Griffin',
                                                                      Core_Account_Meeting_Date__c=Date.today(), Core_Account_Meeting_Time__c='03:00 AM',
                                                                      Core_Account_Meeting_Customer_Contact__c=testContact.Id,
                                                                      Core_Account_Meeting_End_Time__c = '11:00 AM',
                                                                      Core_Account_Meeting_Intel_Contact__c=testContact.Id);
        try{
        insert brief1;
        briefList.add(brief1);
        
        }catch(Exception ex){
            system.assertEquals(ex.getMessage(), ex.getMessage());
        }
    
     Test.startTest();
  
  PageReference pageRef = Page.Core_New_Meeting_Attendee; 
  pageRef.getParameters().put('id', String.valueOf(briefList[0].Id));
  Test.setCurrentPage(pageRef);

  ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(briefList);
  stdSetController.setSelected(briefList);
  Core_AMBRelatedObjs ext = new Core_AMBRelatedObjs(stdSetController);
  ext.getNewMeetingAttendeeUrl();
 Test.stopTest();

}

public static testmethod void AMB_test3() {
       
        // Insert an account, insert users, associate them with the account via custom account team records
        Account testAccount = Core_Test_Utility.createAccount(1)[0];
        insert testAccount;
        
        Contact testContact = new Contact(FirstName='Test', LastName='Contact', Email='test@intel.com', AccountId=testAccount.Id);
        insert testContact;
       List<Account_Meeting_Brief__c> briefList = new List<Account_Meeting_Brief__c>();
       Account_Meeting_Brief__c brief1 = new Account_Meeting_Brief__c(Account__c=testAccount.Id, Core_Account_Brief_Event__c='Test Event',
                                                                      Core_Account_Meeting_Location__c='Quahog', Core_Executive_Name__c='Peter Griffin',
                                                                      Core_Account_Meeting_Date__c=Date.today(), Core_Account_Meeting_Time__c='03:00 AM',
                                                                      Core_Account_Meeting_Customer_Contact__c=testContact.Id,
                                                                      Core_Account_Meeting_End_Time__c = '11:00 AM',
                                                                      Core_Account_Meeting_Intel_Contact__c=testContact.Id);
        try{
        insert brief1;
        briefList.add(brief1);
        
        }catch(Exception ex){
            system.assertEquals(ex.getMessage(), ex.getMessage());
        }
    
     Test.startTest();
  
  PageReference pageRef = Page.Core_New_Meeting_Agenda_Item; 
  pageRef.getParameters().put('id', String.valueOf(briefList[0].Id));
  Test.setCurrentPage(pageRef);

  ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(briefList);
  stdSetController.setSelected(briefList);
  Core_AMBRelatedObjs ext = new Core_AMBRelatedObjs(stdSetController);
  ext.getNewMeetingAgendaItemUrl();
 Test.stopTest();

}
    public static testmethod void AMB_test4() {
       
        // Insert an account, insert users, associate them with the account via custom account team records
        Account testAccount = Core_Test_Utility.createAccount(1)[0];
        insert testAccount;
        
        Contact testContact = new Contact(FirstName='Test', LastName='Contact', Email='test@intel.com', AccountId=testAccount.Id);
        insert testContact;
       List<Account_Meeting_Brief__c> briefList = new List<Account_Meeting_Brief__c>();
       Account_Meeting_Brief__c brief1 = new Account_Meeting_Brief__c(Account__c=testAccount.Id, Core_Account_Brief_Event__c='Test Event',
                                                                      Core_Account_Meeting_Location__c='Quahog', Core_Executive_Name__c='Peter Griffin',
                                                                      Core_Account_Meeting_Date__c=Date.today(), Core_Account_Meeting_Time__c='03:00 AM',
                                                                      Core_Account_Meeting_Customer_Contact__c=testContact.Id,
                                                                      Core_Account_Meeting_End_Time__c = '11:00 AM',
                                                                      Core_Account_Meeting_Intel_Contact__c=testContact.Id);
        try{
        insert brief1;
        briefList.add(brief1);
        
        }catch(Exception ex){
            system.assertEquals(ex.getMessage(), ex.getMessage());
        }
    
     Test.startTest();
  
  PageReference pageRef = Page.Core_New_Customer_Attendees; 
  pageRef.getParameters().put('id', String.valueOf(briefList[0].Id));
  Test.setCurrentPage(pageRef);

  ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(briefList);
  stdSetController.setSelected(briefList);
  Core_AMBRelatedObjs ext = new Core_AMBRelatedObjs(stdSetController);
  ext.getNewCustomerAttendeeUrl();
 Test.stopTest();

}
}