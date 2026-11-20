/**************************************************************************************
Apex Class Name:  Core_AccountCoverageTriggerHandler_Test
Version     : 1.0 
Created Date: 09 Nov 2016
Description    : This class is Test class for Core_AccountCoverageTriggerHandler
*************************************************************************************/
@isTest
public class Core_AccountCoverageTriggerHandler_Test{
    public static testMethod void updateTrigger(){
        Core_AccountCoverage_Export__c ACE = new Core_AccountCoverage_Export__c();
         ACE.Name = 'test';
         ACE.Core_Account_Id__c = '001o000000OTEooAAH';
         ACE.Core_Ext_Id__c ='001o000000OTEooAAH005o0000002TEST'; 
         ACE.Core_User_Id__c='005o0000002Hdg6AAC';
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