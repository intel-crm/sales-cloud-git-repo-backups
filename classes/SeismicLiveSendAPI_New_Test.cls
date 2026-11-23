/****************************************************************************************************************************************
* Class Name  : SeismicLiveSendAPI_New_Test 
* Version     : 1.0 
* Created Date: 10-06-2024
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sandeep Joshi            10/06/2024                 Test class for SeismicLiveSendAPI_New_Test.
*****************************************************************************************************************************************/
@isTest
public class SeismicLiveSendAPI_New_Test {
    @TestSetup private static void setup() {  
    // Create Test Account
   Account testAccount = new Account(Name = 'Seismic Test', Core_Account_Type__c = 'Distributor',Industry = 'Communications',
                                          BillingCity='Pune', BillingCountry='IND', BillingCountryCode = 'IND', BillingState = 'MH',BillingStateCode = 'MH', BillingStreet = 'TestStreet');
       insert testAccount; 
        // Create Test Contacts     
        Contact c1 = new Contact(FirstName='First', LastName='FirstTest',email='test1@intel.com',AccountId=testAccount.Id);
        insert c1;
        Contact c2 = new Contact(FirstName='First', LastName='FirstTest',email='test2@intel.com',AccountId=testAccount.Id,HasOptedOutOfEmail=true);
        insert c2;
        Contact c3 = new Contact(FirstName='First', LastName='FirstTest',email='test3@intel.com',AccountId=testAccount.Id,Core_Sales_Do_Not_Contact_Ind__c=true);
        insert c3;
        Contact c4 = new Contact(FirstName='First', LastName='FirstTest',email='test4@intel.com',AccountId=testAccount.Id,Core_Contact_Export_Compliance_Block__c=true);
        insert c4;
        // Create Test Leads    
        Lead l1 = new Lead(FirstName='First', LastName='FirstTest',email='test5@intel.com',Company = 'XYZ',leadSource ='Email',HasOptedOutOfEmail = true);
        insert l1; 
    
    }
    @isTest static void runTest() {
        List<String> emailAddresses = new List<String>();
        emailAddresses.add('test0@intel.com');
        emailAddresses.add('test1@intel.com');
        emailAddresses.add('test2@intel.com');
        emailAddresses.add('test3@intel.com');
        emailAddresses.add('test4@intel.com');
        emailAddresses.add('test5@intel.com');
      List<Map<String, String>> responseMap =  SeismicLiveSendAPI.Validate(emailAddresses);
        System.debug('responseMap:'+ responseMap);
        for(Map<String,String> v: responseMap){
   // Runs checks for each record
            if(v.get('email').equals('test0@intel.com')){
                System.assertEquals('Success',v.get('status'));
            }
            if(v.get('email').equals('test1@intel.com')){
                System.assertEquals('Success',v.get('status'));
            }
            if(v.get('email').equals('test2@intel.com')){
                System.assertEquals('Fail',v.get('status'));
            }
            if(v.get('email').equals('test3@intel.com')){
                System.assertEquals('Fail',v.get('status'));
            }
            if(v.get('email').equals('test4@intel.com')){
                System.assertEquals('Fail',v.get('status'));
            }
            if(v.get('email').equals('test5@intel.com')){
                System.assertEquals('Fail',v.get('status'));
            }
        }
   
    }
}