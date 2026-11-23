@isTest
public class PRM_Whitelisted_DomainUtility_Test {
	 @isTest static void createAccount(){
     	Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();    
     	List<Account> acct = new List<Account>();
        
        Account a2 = PRM_TestUtility.getAccount();
        a2.AccountNumber = '435765';
        a2.RecordTypeId = accountRecordTypeIntel;
        a2.Name='New Account';
        a2.Core_Account_Type__c ='Distributor';
        a2.Industry='Agriculture';
        a2.BillingCity='Goa';
        a2.BillingCountryCode='IND';
        a2.BillingStreet='4th Floor,New Road';
        a2.BillingPostalCode='110065';
        a2.BillingStateCode='KA';
        a2.Core_IPA_Partner_Role__c = 'Service Provider';
        a2.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        a2.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
       	acct.add(a2); 
         
        Account a1 = PRM_TestUtility.getAccount();
        a1.AccountNumber = '435767';
        a1.RecordTypeId = accountRecordTypeIntel;
        a1.Name='Bernier Group';
        a1.Core_Account_Type__c ='Distributor';
        a1.Industry='Agriculture';
        a1.BillingCity='beijing';
        a1.BillingCountryCode='CHN';
        a1.BillingStreet='4th Floor,New Road';
        a1.BillingPostalCode='110067';
        a1.BillingStateCode='11';
        a1.Core_IPA_Partner_Role__c = 'Distributor';
        a1.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        acct.add(a1);
        insert acct;
        
    	Core_Account_Whitelisted_Domains__c wdom = new Core_Account_Whitelisted_Domains__c() ;
        wdom.Name='maildrop.cc';
        wdom.Account__c=a2.Id;
        wdom.Inactive_Indicator__c=false;
        insert wdom;
        
       Core_Account_Whitelisted_Domains__c wm = new Core_Account_Whitelisted_Domains__c() ;
        wm.Name='mailinator.com';
        wm.Account__c=a1.Id;
        wm.Inactive_Indicator__c=false;
        insert wm;
         
        Test.startTest();
        	Core_Account_Whitelisted_Domains__c wlist = new Core_Account_Whitelisted_Domains__c() ;
        	wlist.Id = wdom.Id;
         	wlist.Name='mailosaur.io';
        	wlist.Account__c=a2.Id;
        	wlist.Inactive_Indicator__c=false;
         	PRM_Whitelisted_Domain_TriggerHandler.IPAfirstRun = true;
        	update wlist;
        
        try{
         	Core_Account_Whitelisted_Domains__c wl = new Core_Account_Whitelisted_Domains__c() ;
        	wl.Id = wm.Id;
         	wl.Name='sky.com';
        	wl.Account__c=a1.Id;
        	wl.Inactive_Indicator__c=false;
        	update wl;
         }
         catch(Exception ex){
             Boolean expectedExceptionThrown =  ex.getMessage().contains('The domain entered is not valid.') ? true : false;
             System.assertEquals(expectedExceptionThrown, false);
         }
        Test.stopTest();
         
     }    
}