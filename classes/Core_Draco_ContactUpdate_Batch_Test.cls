/******************************************************************************************************************************************
Class Name  : Core_Draco_ContactUpdate_Batch_Test
Version     : 1.0
Created Date: 24 FEB 2023
Function    : Test Class for Core_Draco_ContactUpdate_Batch class   

Modification Log :
* Developer                 	Date [DD/MM/YYYY]           	Description
* ----------------------------------------------------------------------------
* Shreyas Sanghai [Team: DRACO]			24/02/2023             	Original version
*****************************************************************************************************************************************/

@isTest
public class Core_Draco_ContactUpdate_Batch_Test {
    
    @isTest static void executeTest(){
        Test.startTest();
        Account act1 = new Account();
        act1.name = 'TestAct1';
        act1.AccountNumber = '23456780';
        act1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        act1.Core_Account_Type__c = 'Distributor';
        act1.Industry = 'Manufacturing';
        act1.Core_Sub_Industry__c = 'Appliance and Electrical Equipment';
        act1.BillingCity='City';
        act1.BillingStreet='Street';
        act1.BillingCountry='India';
        act1.BillingPostalCode='Postal code';
        insert act1;
        
        Contact c1 = new Contact();
        c1.FirstName ='Test1';
        c1.LastName = 'COntact';
        c1.AccountId = act1.Id;
        c1.email='Test1.COntact@intel.com';
        c1.Core_AGS_Integration_Status__c = 'Failed';
        c1.Core_AGS_Integration_Message__c = 'Some AGS Error containing AGS getrole api flow failed';
        c1.Core_Enterprise_Id__c = '30000270166';
        insert c1;
        
        Set<Contact> conSet = new Set<Contact>();
        conSet.add(c1);
        
        //Prepare Test User for running test
        Profile profile = [SELECT Id, Name FROM Profile WHERE Name ='System Administrator' LIMIT 1];
        User newUser1 = new User(
            profileId = profile.id, 
            username = 'testUser'+String.valueOf(Math.random())+'@CoreMD.com', 
            email = 'pbuser@example.com', 
            emailencodingkey = 'UTF-8', 
            localesidkey = 'en_US', 
            languagelocalekey = 'en_US', 
            timezonesidkey = 'America/Los_Angeles', 
            alias='nuser', 
            lastname='lastname');
        insert newUser1;
        
        System.runAs(newuser1){
        Core_Draco_ContactUpdate_Batch batchCont = new Core_Draco_ContactUpdate_Batch(conSet);
        ID batchprocessid = Database.executeBatch(batchCont);
        }
        Test.stopTest();
    }
}