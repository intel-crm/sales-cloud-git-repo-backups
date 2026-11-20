/*********************************************************************************************************************
Class Name  : PRM_AccountNumberGenerator_Test
Version       : 1.0
Created Date  : JULY 2020
Function      : Test Class for 'PRM_AccountNumberGenerator'

Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------------------------
* Rahul Kainth              29/07/2020              PRM_AccountNumberGenerator

*********************************************************************************************************************/

@isTest
public class PRM_AccountNumberGenerator_Test {
    
   /* @isTest
    static void insertAccount(){
        Test.startTest();
        system.debug('inside insertAccount');
        Account__c customSetting = new Account__c();
        customSetting.PRM_Max_Account_Number__c = '63628892297';
        customSetting.Name ='AccountNumber';
        insert customSetting;
        
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();        
        Account a = PRM_TestUtility.getAccount();
        
        a.RecordTypeId = accountRecordTypeIntel;
        a.Core_Account_Type__c ='Distributor';
        a.Industry='Agriculture';
        a.BillingCity='New Delhi';
        a.BillingCountryCode='IND';
        a.BillingStreet='4th Floor,New Road';
        a.BillingPostalCode='110037';
        a.BillingStateCode='KA';
        System.debug('a'+a);
        insert a; 
        test.stopTest();
    } */
    @isTest
    static void updateAccount(){
        Test.startTest();
        Account__c customSetting = new Account__c();
        customSetting.PRM_Max_Account_Number__c = '63628892297';
        customSetting.Name ='AccountNumber';
        insert customSetting;
        
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();        
        Account a = PRM_TestUtility.getAccount();
        
        a.RecordTypeId = accountRecordTypeIntel;
        a.Core_Account_Type__c ='Distributor';
        a.Industry='Agriculture';
        a.BillingCity='New Delhi';
        a.BillingCountryCode='IND';
        a.BillingStreet='4th Floor,New Road';
        a.BillingPostalCode='110037';
        a.BillingStateCode='KA';
        System.debug('a'+a);
        insert a; 
        
        Account a1 = PRM_TestUtility.getAccount();
        
        a1.RecordTypeId = accountRecordTypeIntel;
        a1.Core_Account_Type__c ='Distributor';
        a1.Industry='Agriculture';
        a1.BillingCity='New Test';
        a1.BillingCountryCode='IND';
        a1.BillingStreet='4t,New Road';
        a1.BillingPostalCode='116737';
        a1.BillingStateCode='KA';
        a1.AccountNumber = '1234567';
        insert a1; 
        
        try {
        String accNumber = PRM_AccountNumberGenerator.getAccountNum();
        PRM_AccountNumberGenerator.updateAccountNumberCS(new List<Account>{a1}, null);   
        if(a.AccountNumber == null){
            PRM_AccountNumberGenerator.updateAccountNumberCS(new List<Account>{a}, null);
            update a;
            PRM_AccountNumberGenerator.updateAccountNumberCS(null, null);
        }
        }Catch(Exception ex){
           
        }
        
        test.stopTest();
    }
}