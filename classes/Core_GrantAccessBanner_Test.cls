/*********************************************************************************************************************************
Apex Class Name : Core_GrantAccessBanner_Test
Created Date : April'2022
Function : Test Class for 'Core_GrantAccessBanner' class

Modification Log
Developer                       Date                     Description
*Shubham Khandelwal            April'2022          Test Class for 'Core_GrantAccessBanner' class
*********************************************************************************************************************************/


@isTest()
public class Core_GrantAccessBanner_Test {
    
    @isTest
    Static void getBannerDetailsTest(){
        
        
        List<Core_GA_Banner__c> banList = new List<Core_GA_Banner__c>();
        Core_GA_Banner__c gab = new Core_GA_Banner__c();
        gab.Name = 'Test Banner1';
        gab.Core_Start_Date__c = System.today();
        
        gab.Core_End_Date__c = System.today().addDays(30);
        gab.Core_Message__c = 'New Message';
        
        banList.add(gab);
        
        insert banList;
        
        
        Test.startTest();
        Core_GrantAccessBanner.getBannerDetails();
        
        List<Core_GA_Banner__c> banList2 = new List<Core_GA_Banner__c>();
        Core_GA_Banner__c gab2 = new Core_GA_Banner__c();
        gab2.Name = 'Test Banner2';
        gab2.Core_Start_Date__c = System.today().addDays(-25);
        gab2.Core_End_Date__c = System.today() + (-2);
        gab2.Core_Message__c = 'New Message2';
        
        banList2.add(gab2);
        
        insert banList2;
        Core_GrantAccessBanner.getBannerDetails();
        Test.stopTest();
        
        
    }
    
    @isTest
    Static void checkContactGecTest(){
        
        Test.startTest();
        
        Account newAccount = new Account();//Account
        newAccount.Name='John Rick';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount.Core_User_Defined_Website__c = 'WWW.test123.com';
        insert newAccount;
        
        
        List<Contact> con = new List<Contact>();
        Contact cont = new Contact();  //Contact
        cont.AccountId=newAccount.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.email='AdamGrill@rediff.com';
        cont.Core_Contact_Export_Compliance_Block__c = true;
        con.add(cont);
       
        insert con;
        
        List<Core_GA_Banner__c> banList10 = new List<Core_GA_Banner__c>();
        Core_GA_Banner__c gab10 = new Core_GA_Banner__c();
        gab10.Name = 'Test Banner10';
        gab10.Core_Start_Date__c = System.today();        
        gab10.Core_End_Date__c = System.today().addDays(30);
        gab10.Core_Message__c = 'New Message10';        
        banList10.add(gab10);
        
        insert banList10;
        Boolean flag = true;

        //Contact c = [Select id, Core_Contact_Export_Compliance_Block__c from Contact where id=: gab10.Id];
        Core_GrantAccessBanner.checkContactGec(cont.Id);
        
        Test.stopTest();
        
        
    }
}