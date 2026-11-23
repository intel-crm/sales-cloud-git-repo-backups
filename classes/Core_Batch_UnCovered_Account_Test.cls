/**************************************************************************************
Apex Class Name:  Core_Batch_UnCovered_Account_Test 
Version     : 1.0 
Created Date:  9/26/17 
Description : This test class used in Core_Batch_UnCovered_Accounts_Cleanup.
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Rajesh(Infy Team)            9/26/17                Initial Revision
*************************************************************************************/
@isTest
public class Core_Batch_UnCovered_Account_Test {     
  public static List<Account> accList = new List<Account>();
    static testMethod void AccountUnitTest1() {
     Test.StartTest();
          Core_Uncover_Account_Batch_Recipient__c UncoverEmail= new Core_Uncover_Account_Batch_Recipient__c ();
          UncoverEmail.Name = 'Test Setting';
          UncoverEmail.Core_Recipient_Email1__c= 'test.laxaman@intel.com';
          insert UncoverEmail;
          Id newAccountRecTypeId = [select Id from RecordType where DeveloperName = 'Mastered_Account' limit 1][0].Id;
          Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
          System.runAs(Core_Test_Utility.systemAdminUser) {
               Core_Batch_Header__c batchHeader=new Core_Batch_Header__c(name='Core_Batch_UnCovered_Accounts_Cleanup',Email_Distribution_List__c='laxman.test1@intel.com');
               insert batchHeader;      
               Core_Batch_Processing__c    batchProcessing = new Core_Batch_Processing__c(Batch_Header__C = batchHeader.id,Core_Email_Distribution_List__c ='laxmanax.test1@intel.com',Core_Salesforce_Job_Id__c ='707q0000011NJcsAAG',Core_Batch_Query__c = 'select query',Core_Object_Name__c = 'Account',Core_Start_Date_Time__c = system.now());
               insert batchProcessing; 
               Id profileId = [select Id from Profile where Name ='Integration' limit 1].Id;
               user us=new user(Firstname = 'Uncovered',LastName = 'Account',UserName = 'uncovered.account@intel.com',Email = 'salesforce.system.do.not.reply=intel.com@example.com',Alias ='uncoverd',CommunityNickName = 'test.geo',ProfileId = profileId,LANGUAGELOCALEKEY = 'en_US',LOCALESIDKEY = 'en_US',TIMEZONESIDKEY = 'America/Los_Angeles',EMAILENCODINGKEY = 'ISO-8859-1',Core_User_Geo__c ='EMEA');           
               insert us;
      
              accList.add(new Account(Name = 'Test Account 03-25-2015', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',RecordTypeId = newAccountRecTypeId,
                                   BillingPostalCode = '12345', Core_CIM_ID__c = '8675309',Core_PSG_Account__c=False,Core_Sys_Next_Account__c=False,Core_Partner_Account__c=False,OwnerId=us.Id,Core_Uncover_Marked_for_Clean_Up__c=true,Core_Business_ID__c='301392177'));
              RecordType accRecordType = [select id from recordType where sObjectType='Account' and name ='Intel Account' limit 1];
                               
              acclist.add(new Account(Name='CEP Test Account',recordtypeid=accRecordType.id,BillingCountryCode = 'USA',BIllingStateCode = 'AL',
                                    BillingCity = 'Alabama',BillingStreet = 'test',Core_Account_Type__c = 'Other',Core_Sales_Segment__c = 'Reseller/Channel',Core_Uncover_Marked_for_Clean_Up__c=false,
                                    Core_Sub_Geo__c = 'CEE', Core_Geo__c='ASMO',OwnerId=us.Id)); 
              
              insert acclist;   
              
              RecordType conRecordType = [select id from recordType where sObjectType='Contact' and name = 'Intel Contact' limit  1];
              Contact Cont = new Contact(recordtypeid=conRecordType.id,Email='testcepcontact1111@gmail.com',LastName = 'CEPLast98',FirstName = 'CEPFirst98',AccountId = acclist[0].id,MailingCountry='USA');
              insert Cont;            
                                 
         }
     
     
         Core_Batch_UnCovered_Accounts_Cleanup  acc_cleanup= new Core_Batch_UnCovered_Accounts_Cleanup();
          ID batchprocessid = Database.executeBatch(acc_cleanup);
     Test.StopTest();
     }
 }