/****************************************************************************************************************************************
* Class Name  : SeismicLiveSendAPI_Test 
* Version     : 1.0 
* Created Date: 10-06-2021
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Saif Alam            10/06/2021                 Test class for SeismicLiveSendAPI.
*****************************************************************************************************************************************/
@isTest
public class SeismicLiveSendAPI_Test {
    @TestSetup private static void setup() {  
    // Create Test Account
   Account testAccount = new Account(Name = 'Seismic Test', Core_Account_Type__c = 'Distributor',Industry = 'Communications',
                                          BillingCity='Pune', BillingCountry='IND', BillingCountryCode = 'IND', BillingState = 'MH',BillingStateCode = 'MH', BillingStreet = 'TestStreet');
       insert testAccount; 
        // Create Test Contacts     
        Contact c1 = new Contact(FirstName='First', LastName='FirstTest',email='test1@intel.com',AccountId=testAccount.Id,  MailingCountry= 'IND');
        insert c1;
        Contact c2 = new Contact(FirstName='First', LastName='FirstTest',email='test2@intel.com',AccountId=testAccount.Id,HasOptedOutOfEmail=true,  MailingCountry= 'IND');
        insert c2;
        Contact c3 = new Contact(FirstName='First', LastName='FirstTest',email='test3@intel.com',AccountId=testAccount.Id,Core_Sales_Do_Not_Contact_Ind__c=true,  MailingCountry= 'IND');
        insert c3;
        Contact c4 = new Contact(FirstName='First', LastName='FirstTest',email='test4@intel.com',AccountId=testAccount.Id,Core_Contact_Export_Compliance_Block__c=true,  MailingCountry= 'IND');
        insert c4;
        Contact c5 = new Contact(FirstName='First', LastName='FirstTest',email='sandeep.joshi@intel.com',AccountId=testAccount.Id, MailingCountry= 'IND');
        insert c5;
        
        // Create Test Leads    
        Lead l1 = new Lead(FirstName='First', LastName='FirstTest',email='test5@intel.com',Company = 'XYZ',leadSource ='Email',HasOptedOutOfEmail = true);
        insert l1; 
        Lead l2 = new Lead(FirstName='First', LastName='FirstTest',email='test6@intel.com',Company = 'XYZ',leadSource ='Email',Core_Do_not_call__c = true);
        insert l2; 
    }
    @isTest static void runTest() {
        List<String> emailAddresses = new List<String>();
        emailAddresses.add('test0@intel.com');
        emailAddresses.add('test1@intel.com');
        emailAddresses.add('test2@intel.com');
        emailAddresses.add('test3@intel.com');
        emailAddresses.add('test4@intel.com');
        emailAddresses.add('sandeep.joshi@intel.com');
        emailAddresses.add('test5@intel.com');
        emailAddresses.add('test6@intel.com');
      List<Map<String, String>> responseMap =  SeismicLiveSendAPI.Validate(emailAddresses);
        System.debug('responseMap:'+ responseMap);
        for(Map<String,String> v: responseMap){
   			
            /* Runs checks for each record
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
            if(v.get('email').equals('sandeep.joshi@intel.com')){
                System.assertEquals('Success',v.get('status'));
            }
            if(v.get('email').equals('test5@intel.com')){
                System.assertEquals('Fail',v.get('status'));
            }
            if(v.get('email').equals('test6@intel.com')){
                System.assertEquals('Fail',v.get('status'));
            }*/
            
        }
        
        
        //Test Config Data
        List<SeismicUserDeletion_Config__c> configs = new List<SeismicUserDeletion_Config__c>();
        configs.add(new SeismicUserDeletion_Config__c(Name = 'GraphAPI_apiScope', Key__c = 'GraphAPI_apiScope', Value__c = 'https://graph.microsoft.com/.default'));
        configs.add(new SeismicUserDeletion_Config__c(Name = 'GraphAPI_ClientId', Key__c = 'GraphAPI_ClientId', Value__c = 'd27aaefe-a853-45a0-ab45-04ba27a230ad'));
        configs.add(new SeismicUserDeletion_Config__c(Name = 'GraphAPI_ClientSecret', Key__c = 'GraphAPI_ClientSecret', Value__c = 'fVB7Q~_7IXC1E6dClojFNBLkbb~OQ5LUKmB65'));         
        configs.add(new SeismicUserDeletion_Config__c(Name = 'GraphAPI_EndPoint', Key__c = 'GraphAPI_EndPoint', Value__c = 'https://login.microsoftonline.com/46c98d88-e344-4ed4-8496-4ed7712e255d/oauth2/v2.0/token'));
        configs.add(new SeismicUserDeletion_Config__c(Name = 'Seismic_AD_PremiumUser', Key__c = 'Seismic_AD_PremiumUser', Value__c = '8b0b84e3-f02f-480f-a7e8-ca75c5d90755'));         
        configs.add(new SeismicUserDeletion_Config__c(Name = 'Seismic_AD_BusinessUser', Key__c = 'Seismic_AD_BusinessUser', Value__c = 'b683f081-4afd-4c91-9292-fb1af0e07539'));
        configs.add(new SeismicUserDeletion_Config__c(Name = 'Yoda_Email', Key__c = 'Yoda_Email', Value__c = 'yoda.seismic.support@intel.com'));         
        configs.add(new SeismicUserDeletion_Config__c(Name = 'Sales_POCEmail', Key__c = 'Sales_POCEmail', Value__c = 'sales_content_poc@intel.com'));
        configs.add(new SeismicUserDeletion_Config__c(Name = 'IsTest', Key__c = 'IsTest', Value__c = 'true'));
        configs.add(new SeismicUserDeletion_Config__c(Name = 'MaxRecordAllow', Key__c = 'MaxRecordAllow', Value__c = '2'));
        insert configs;
        
        //Test Initilization
        Boolean flg = SeismicLiveSendAPI.initialize();
        System.assertEquals(true, flg);
        System.assertEquals(configs.size(), SeismicLiveSendAPI.config.size(), 'initialize');
        
        //Test getGraphAPIToken
		String accessToken = SeismicLiveSendAPI.getGraphAPIToken();
        
        //Test getUser from GraphAPI
        String test_user = SeismicLiveSendAPI.getUser('sandeep.joshi@intel.com', accessToken);
        
    }
}