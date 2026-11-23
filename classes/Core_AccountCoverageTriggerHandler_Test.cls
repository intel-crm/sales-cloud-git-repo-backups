/**************************************************************************************
Apex Class Name:  Core_AccountCoverageTriggerHandler_Test
Version     : 1.0 
Created Date: 09 Nov 2016
Description    : This class is Test class for Core_AccountCoverageTriggerHandler Core_AccountCoverageExportTriggerHandler
*************************************************************************************/
@isTest
public without sharing class Core_AccountCoverageTriggerHandler_Test{
    
    @isTest
    public static void updateTrigger(){
        Id recordTypeIdAccount =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        List<Account> lstAccounts = Core_Test_Utility.createAccount(1);
        lstAccounts[0].RecordTypeId = recordTypeIdAccount;
        insert lstAccounts; 
        Account acc = [Select id,RecordType.DeveloperName from Account where Id =: lstAccounts[0].Id];
        
        List<Contact> lstContacts = Core_Test_Utility.createContacts(1);
        lstContacts[0].AccountId = lstAccounts[0].id;
        lstContacts[0].External_User_State__c='Accepted';
            lstContacts[0].Core_Job_Function_Code__c = 'TEST1';
            lstContacts[0].Core_ERPM_Integration_Message__c='Timestamp: 2019-06-03 03:47:45 GMT Inbound Message ID: a004F000003V5HCQA0 Error Code: 1031, Error Text: Failure in fetching the SOFT contact details by using Email Id, Error Details: Sequence contains more than one element';
            lstContacts[0].MailingCountry='IND';
        Insert lstContacts;
        
        Contact cont = [Select id,email from contact where Id =: lstContacts[0].Id];
        
        User extUser = Core_MDF_CCP_TestDataUtility.createPartnerUser(false);
        extUser.Email= cont.email;
        extUser.ContactId = cont.Id;
        extUser.isActive = true;
        Database.insert(extUser);
        
        Core_AccountCoverage_Export__c ACE = new Core_AccountCoverage_Export__c();
         ACE.Name = 'test';
         /*ACE.Core_Account_Id__c = '001o000000OTEooAAH';
         ACE.Core_Ext_Id__c ='001o000000OTEooAAH005o0000002TEST'; 
         ACE.Core_User_Id__c='005o0000002Hdg6AAC';*/
         String accid = lstAccounts[0].id;
         String userId = extUser.Id;
         ACE.Core_Account_Id__c = lstAccounts[0].id;
         ACE.Core_Ext_Id__c = accid+userId;
         ACE.Core_User_Id__c= extUser.Id;
         ACE.Core_Status__c='';
         Test.startTest();

         insert ACE;
         Core_AccountCoverage_Export__c ACE1=[SELECT id,Name,Core_Status__c,Core_Operation__c,Core_User_Email__c FROM Core_AccountCoverage_Export__c where id=:ACE.id ];        
        
         System.assertEquals('test', ACE1.Name);
         System.assertEquals('ADD', ACE1.Core_Operation__c);
        
         //Condition 2    changing status from 'New' to 'Processed'
         ACE1.Core_Status__c='Processed';
         update ACE1;
       
         ACE1=[SELECT id,Name,Core_Status__c,Core_Operation__c,Core_User_Email__c FROM Core_AccountCoverage_Export__c where id=:ACE.id ];        
       
         System.assertEquals('ADD', ACE1.Core_Operation__c);
         
         //Condition 3    changing status from 'Processed'  to 'New'  with some field change
         ACE1.Name = 'test 2';
         ACE1.Core_User_Email__c='test1@test.com';
         ACE1.Core_Status__c='New';
         update ACE1;
       
         ACE1=[SELECT id,Name,Core_Status__c,Core_Operation__c,Core_User_Email__c FROM Core_AccountCoverage_Export__c where id=:ACE.id ];        
       
         System.assertEquals('New', ACE1.Core_Status__c);
         System.assertEquals('UPDT', ACE1.Core_Operation__c);
         
       
         //Condition 4     changing status from 'New' to 'Processed'
         ACE1.Core_Status__c='Processed';
         update ACE1;
          
         ACE1=[SELECT id,Name,Core_Status__c,Core_Operation__c,Core_User_Email__c FROM Core_AccountCoverage_Export__c where id=:ACE.id ];        
      
         System.assertEquals('UPDT', ACE1.Core_Operation__c);
         
       
        //Condition 5      changing status from 'Processed'  to 'New' with No change
         ACE1.Core_Status__c='New';
         update ACE1;
        
         ACE1=[SELECT id,Name,Core_Status__c,Core_Operation__c,Core_User_Email__c FROM Core_AccountCoverage_Export__c where id=:ACE.id ];        
        
         System.assertEquals('NC', ACE1.Core_Operation__c);
         
         Test.stopTest();

       
     }
}