/*********************************************************************************************************************
Class Name  : PRM_PAGAccountTriggerRollUp_Test
Version       : 1.0
Created Date  : AUG 2020
Function      : Test Class of 'PRM_PAGAccountTriggerRollUp'

Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------------------------
* Rahul Kainth          	8/14/2020               Test Class of 'PRM_PAGAccountTriggerRollUp'

*********************************************************************************************************************/

@isTest
public class PRM_PAGAccountTriggerRollup_Test {
    
    @isTest
    public static void testFunction1(){
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id pagAccountType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
        Test.startTest();
        /*Core_Trigger_Executions__c cs = new Core_Trigger_Executions__c (Name = 'Roll_up_account',
                                                                        Core_Active__c = true,
                                                                        Core_Class_Name__c = 'Core_AccountHandler',
                                                                        Core_Object__c = 'Account',
                                                                        Core_Trigger_Events__c = 'after update',
                                                                        Core_Description__c = 'roll up child accounts biz org type and partner segment');
        insert cs;*/
        
        Core_Trigger_Executions__c te2 = new Core_Trigger_Executions__c();
            te2.Name = 'Roll_up_account';
            te2.Core_Active__c = True;
            te2.Core_Class_Name__c = 'Core_AccountHandler';
            te2.Core_Description__c = 'after update';
            te2.Core_Object__c = 'Account';
            te2.Core_Trigger_Events__c = 'after update';
        insert te2;


        Account a = new Account();
        a.Name = 'Pag Account';
        a.RecordTypeId = pagAccountType;
        a.Core_Account_Type__c ='Cloud Service Provider (CSP);Electronic Manufacturing Services (EMS)';
        a.Industry='Agriculture';
        a.BillingCity='New Delhi';
        a.BillingCountryCode='IND';
        a.BillingStreet='4th Floor,New Road';
        a.BillingPostalCode='923013';
        a.BillingStateCode='KA';
        a.Core_IPA_Partner_Role__c = 'Service Provider';
        a.Core_IPA_Partner_Segment__c = 'Client Computing;Internet of Things and Embedded';
        try{
        insert a;
            }
            catch(Exception e){
            	 insert a;	    
            } 
        
        Account a1 = new Account();
        a1.RecordTypeId = accountRecordTypeIntel;
        a1.Name='New Account';
        a1.Core_Account_Type__c ='Distributor;Electronic Manufacturing Services (EMS)';
        a1.Industry='Agriculture';
        a1.BillingCity='Bengaluru';
        a1.BillingCountryCode='IND';
        a1.BillingStreet='5th Floor,New Road';
        a1.BillingPostalCode='110065';
        a1.BillingStateCode='KA';
        a1.Core_IPA_Partner_Role__c = 'Service Provider';
        a1.Core_IPA_Partner_Segment__c = 'Client Computing;Storage and Memory';
        a1.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        a1.Core_IPA_One_Partner_Id__c = a.Id;
        insert a1;
        
        Account a2 = new Account();
        a2.RecordTypeId = accountRecordTypeIntel;
        a2.Name='New Account2';
        a2.Core_Account_Type__c ='Cloud Service Provider (CSP);Electronic Manufacturing Services (EMS)';
        a2.Industry='Agriculture';
        a2.BillingCity='Goa';
        a2.BillingCountryCode='IND';
        a2.BillingStreet='4th Floor,New Road';
        a2.BillingPostalCode='110065';
        a2.BillingStateCode='KA';
        a2.Core_IPA_Partner_Role__c = 'Service Provider';
        a2.Core_IPA_Partner_Segment__c = 'Internet of Things and Embedded;Client Computing';
        a2.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        a2.Core_IPA_One_Partner_Id__c = a.Id;
        insert a2;
        
        
       
        
        Account a4 = new Account();
        a4.RecordTypeId = accountRecordTypeIntel;
        a4.Name='New Account1';
        a4.Industry='Agriculture';
        a4.BillingCity='Bengaluru';
        a4.BillingCountryCode='IND';
        a4.BillingStreet='5th Floor,New Road';
        a4.BillingPostalCode='110065';
        a4.BillingStateCode='KA';
        a4.Core_IPA_Partner_Role__c = 'Service Provider';
        a4.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        a4.Core_IPA_One_Partner_Id__c = a.Id;        
        a4.Core_IPA_Partner_Segment__c = 'Internet of Things and Embedded';
        a4.Core_Account_Type__c = 'Distributor;Reseller';
        insert a4;

        Account a3 = new Account();
        a3.RecordTypeId = accountRecordTypeIntel;
        a3.Name='New Account3';
        a3.Core_Account_Type__c ='Distributor';
        a3.Industry='Agriculture';
        a3.BillingCity='Goa';
        a3.BillingCountryCode='IND';
        a3.BillingStreet='4th Floor,New Road';
        a3.BillingPostalCode='110065';
        a3.BillingStateCode='KA';
        a3.Core_IPA_Partner_Role__c = 'Service Provider';
        a3.Core_IPA_Partner_Segment__c = 'Internet of Things and Embedded';
        a3.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        a3.Core_IPA_One_Partner_Id__c = a.Id;
        insert a3;
        
        Core_Account_Group_Member__c cag =  new Core_Account_Group_Member__c();               
        cag.Core_Intel_Account_Id__c = a4.id; 
        cag.Core_Partner_Account_Id__c = a.id;
        cag.Core_Inactive_Ind__c = false;
        insert cag; 
        
        Core_Account_Group_Member__c cag1 =  new Core_Account_Group_Member__c();               
        cag1.Core_Intel_Account_Id__c = a3.id; 
        cag1.Core_Partner_Account_Id__c = a.id;
        cag1.Core_Inactive_Ind__c = false;
        insert cag1;
        

        List<Account> updatedAccount = new List<account>();
        updatedAccount.add(a4);
        updatedAccount.add(a3);
        
        Map<Id,Account> oldMap = new Map<Id,Account>();
        oldMap.put(a4.Id,a1);
        oldMap.put(a3.id,a2);
        
        PRM_PAGAccountTriggerRollUp.updatepagaccount(updatedAccount,oldMap);
        Test.stopTest();
        
        System.assertEquals('Internet of Things and Embedded', a3.Core_IPA_Partner_Segment__c, 'Value does not match');
    }
    @isTest
    public static void testFunction2(){
                    
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id pagAccountType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
        Test.startTest();
        Core_Trigger_Executions__c cs = new Core_Trigger_Executions__c (Name = 'Roll_up_account',
                                                                        Core_Active__c = true,
                                                                        Core_Class_Name__c = 'Core_AccountHandler',
                                                                        Core_Object__c = 'Account',
                                                                        Core_Trigger_Events__c = 'after update',
                                                                        Core_Description__c = 'roll up child accounts biz org type and partner segment');
        insert cs;
        
        Account a = new Account();
        a.Name = 'Pag Account';
        a.RecordTypeId = pagAccountType;
        a.Core_Account_Type__c ='Cloud Service Provider (CSP);Electronic Manufacturing Services (EMS)';
        a.Industry='Agriculture';
        a.BillingCity='New Delhi';
        a.BillingCountryCode='IND';
        a.BillingStreet='4th Floor,New Road';
        a.BillingPostalCode='923013';
        a.BillingStateCode='KA';
        a.Core_IPA_Partner_Role__c = 'Service Provider';
        a.Core_IPA_Partner_Segment__c = 'Client Computing;Internet of Things and Embedded';
            try{
        insert a;
            }
            catch(Exception e){
            	 insert a;	    
            }        
        
        Account a3 = new Account();
        a3.RecordTypeId = accountRecordTypeIntel;
        a3.Name='New Account3';
        a3.Core_Account_Type__c ='Distributor;Cloud Service Provider (CSP);Electronic Manufacturing Services (EMS)';
        a3.Industry='Agriculture';
        a3.BillingCity='ckm';
        a3.BillingCountryCode='IND';
        a3.BillingStreet='4th Floor,New Road new';
        a3.BillingPostalCode='110066';
        a3.BillingStateCode='KA';
        a3.Core_IPA_Partner_Role__c = 'Service Provider';
        a3.Core_IPA_Partner_Segment__c = 'Internet of Things and Embedded;Client Computing';
        a3.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        a3.Core_IPA_One_Partner_Id__c = a.Id;
        insert a3;
        
        
         Account a4 = new Account();
        a4.RecordTypeId = accountRecordTypeIntel;
        a4.Name='New Account4';
        a4.Core_Account_Type__c ='Distributor;Cloud Service Provider (CSP);Electronic Manufacturing Services (EMS)';
        a4.Industry='Agriculture';
        a4.BillingCity='ckm';
        a4.BillingCountryCode='IND';
        a4.BillingStreet='4th Floor,New Road new';
        a4.BillingPostalCode='110066';
        a4.BillingStateCode='KA';
        a4.Core_IPA_Partner_Role__c = 'Service Provider';
        a4.Core_IPA_Partner_Segment__c = 'Internet of Things and Embedded;Client Computing';
        a4.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        a4.Core_IPA_One_Partner_Id__c = a.Id;
        insert a4;

          Core_Account_Group_Member__c cag2 =  new Core_Account_Group_Member__c();               
        cag2.Core_Intel_Account_Id__c = a4.id; 
        cag2.Core_Partner_Account_Id__c = a.id;
        cag2.Core_Inactive_Ind__c = false;
        insert cag2;
        List<Account> updatedAccount = new List<Account>();
        updatedAccount.add(a4);
        Map<Id,Account> oldMap = new Map<Id,Account>();
        oldMap.put(a4.id,a3);

        
      
        
        PRM_PAGAccountTriggerRollUp.updatepagaccount(updatedAccount,oldMap);
        Test.stopTest();
    }
    
}