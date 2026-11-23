@isTest
public class UCD_AccountDuplicateTest {
    
    @isTest static  void testGetCallout() {
        test.startTest();
         Account a1 = new Account(Name='Test Account1', Core_Geo__c ='EMEA', Core_CIM_ID__c = '8675309', BillingStreet = 'Sample', BillingCity = 'Sample City', BillingState = 'KA', BillingCountry = 'IND');
        Account a2 = new Account(Name='Test Account2', Core_Geo__c ='EMEA', Core_CIM_ID__c = '8675309', BillingStreet = 'Sample', BillingCity = 'Sample City', BillingState = 'KA', BillingCountry = 'IND');
        Account a3 = new Account(Name='Test Account3', Core_Geo__c ='EMEA', Core_CIM_ID__c = '', BillingStreet = 'Sample', BillingCity = 'Sample City', BillingState = 'KA', BillingCountry = 'IND');
        
        insert a1;
        insert a2;
        insert a3;
        test.stopTest();
         UCD_AccountDuplicate obj1 = new UCD_AccountDuplicate();
             UCD_AccountDuplicate.getRegionListSort('EMEA');
        UCD_AccountDuplicate.getRegionHome('EMEA');
        
        system.debug('*****'+UCD_AccountDuplicate.getRegionListSort('EMEA').size());
        System.assertequals(UCD_AccountDuplicate.getRegionListSort('EMEA').size(), 1);
    }
    
    @isTest static  void testwrapexport() {
        Account a1 = new Account(Name='Test Account1', Core_Geo__c ='EMEA', Core_CIM_ID__c = '8675309', BillingStreet = 'Sample', BillingCity = 'Sample City', BillingState = 'KA', BillingCountry = 'IND');
        Account a2 = new Account(Name='Test Account2', Core_Geo__c ='EMEA', Core_CIM_ID__c = '8675309', BillingStreet = 'Sample', BillingCity = 'Sample City', BillingState = 'KA', BillingCountry = 'IND');
        Account a3 = new Account(Name='Test Account3', Core_Geo__c ='EMEA', Core_CIM_ID__c = '', BillingStreet = 'Sample', BillingCity = 'Sample City', BillingState = 'KA', BillingCountry = 'IND');
        
        insert a1;
        insert a2;
        insert a3;
        UCD_AccountDuplicate.AccountWrapper accwrp =new UCD_AccountDuplicate.AccountWrapper(a1);
        UCD_AccountDuplicate.getAccounts('EMEA');
        system.debug('+++++'+UCD_AccountDuplicate.getAccounts('EMEA').size());
       System.assertequals(UCD_AccountDuplicate.getAccounts('EMEA').size(), 2);
        
    }
    
    @isTest static  void testGetCalloutNew() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u1 = new User(Alias = 'standa', Email='saplingstandarduser@intel.com',
      EmailEncodingKey='UTF-8', Firstname = 'Uncovered', LastName='account', LanguageLocaleKey='en_US',
      LocaleSidKey='en_US', ProfileId = p.Id,
      TimeZoneSidKey='America/Los_Angeles', UserName='saplingstandarduser@intel.com');
        insert u1;
        Account a1 = new Account(Name='Test Account1', Core_Geo__c ='EMEA', Core_CIM_ID__c = '8675309', BillingStreet = 'Sample', BillingCity = 'Sample City', BillingState = 'KA', BillingCountry = 'IND');
        Account a2 = new Account(Name='Test Account2', Core_Geo__c ='EMEA', Core_CIM_ID__c = '8675309', BillingStreet = 'Sample', BillingCity = 'Sample City', BillingState = 'KA', BillingCountry = 'IND');
        Account a3 = new Account(Name='Test Account3', Core_Geo__c ='EMEA', Core_CIM_ID__c = '', BillingStreet = 'Sample', BillingCity = 'Sample City', BillingState = 'KA', BillingCountry = 'IND');
        
        Account a4 = new Account(Name='Test Account4', OwnerId= u1.Id, Core_Geo__c ='EMEA', Core_CIM_ID__c = '8675309', BillingStreet = 'Sample', BillingCity = 'Sample City', BillingState = 'KA', BillingCountry = 'IND');

        insert a1;
        insert a2;
        insert a3;
        insert a4;
        List<account> result = UCD_AccountDuplicate.getAccountsForCim(a1.Core_CIM_ID__c);
        system.debug(result.size());
        System.assertequals(result.size(), 3);
    }
}