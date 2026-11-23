/**************************************************************************************
Apex Class Name : Core_Draco_EntitlementCleanup_Batch_Test
Version     : 1.0 
Created Date: 10th Feb 2023
Description : Batch class for Entitlements cleanup and Republishing Contacts failed due to specific errors. 
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* Shreyas[Team Draco]     10 Feb 2023               Original Version
*************************************************************************************/

@isTest
public class Core_Draco_EntitlementCleanup_Batch_Test {
    @testSetup 
    static void setup() {
        //Prepare the list of Accounts
        List<Account> accList = new List<Account>();
        Account intelAccount1 = new Account(Name ='IntelAccount34',Core_Account_Type__c = 'Original Design Manufacturer (ODM)',Core_Sales_Groups__c= 'PRC Sales Group',
                                            Industry='Agriculture', BillingCity='Pune',BillingCountry='Ind',BillingStreet='abc chowk delhi', Core_IPA_Partner_Role__c = 'Distributor');
        
        accList.add(intelAccount1);
        Database.insert (accList);
        
        
        //Prepare the list of Contacts
        List<Contact> allContacts = new List<Contact>();
        Contact conTest;
        for(Integer i = 1; i<=2; i++){
            conTest = new Contact(firstname='TestIntel',lastname='Contact'+string.valueof(i), accountId=intelAccount1.id, Core_Enterprise_Id__c='30000270166'+string.valueof(i), Email='dellco123'+string.valueof(i)+'@dell.com',
                                 Core_AGS_Integration_Status__c = 'Failed', Core_AGS_Integration_Message__c = 'Some random AGS Error containing Operation taking too long to complete from AGS and already has a pending add role request'); 
            allContacts.add(conTest);
        }
        for(Integer i = 3; i<=10; i++){
            conTest = new Contact(firstname='TestIntel',lastname='Contact'+string.valueof(i), accountId=intelAccount1.id, Core_Enterprise_Id__c='30000270166'+string.valueof(i), Email='dellco123'+string.valueof(i)+'@dell.com',
                                 Core_AGS_Integration_Status__c = 'Failed', Core_AGS_Integration_Message__c = 'Some AGS Error containing AGS getrole api flow failed'); 
            allContacts.add(conTest);
        }
        insert allContacts;
        
        
        //Prepare the list of AGS Roles
        Core_AGS_Role__c agsRole = new Core_AGS_Role__c(Name ='XIRIS Disti Reporting',Core_Technical_Name__c = 'XIRIS_DistiRepUser',Core_IsActive__c = true);
        Insert agsRole;
        
        //Prepare the list of Entitlement Details
        Core_Entitlement__c entdetail = new Core_Entitlement__c(Core_Display_Name__c = 'XIRIS_DistiRepUser', Name = 'XIRIS_DistiRepUser', Core_IsActive__c = true, Core_AGS_Role_Id__c = agsRole.Id);
        insert entdetail;
        
        //Prepare the list of failed CE Records
        List<Core_Contact_Entitlement__c> allConEnt = new List <Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c contEnt1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c = allContacts[0].Id, Core_Entitlement_Id__c = entdetail.Id, Core_Status_of_Assignment_Failure__c = 'Failed Assignment',Core_Retrigger_Attempt__c = 1, Core_Selected__c = false, Core_Status__c = 'Complete', Core_Update_Reason__c = 'Operation taking too long to complete from AGS');
        Core_Contact_Entitlement__c contEnt3 = new Core_Contact_Entitlement__c(Core_Contact_Id__c = allContacts[1].Id, Core_Entitlement_Id__c = entdetail.Id, Core_Status_of_Assignment_Failure__c = 'Failed Removal',Core_Retrigger_Attempt__c = 1, Core_Selected__c = true, Core_Status__c = 'Complete', Core_Update_Reason__c = 'Operation taking too long to complete from AGS');
        allConEnt.add(contEnt1);
        allConEnt.add(contEnt3);
        Database.insert(allConEnt);
        
        
        //Prepare Custom Setting Records
        List<Core_AE_Retry_and_Reprocess_Logics__c> listAECustSett = new List<Core_AE_Retry_and_Reprocess_Logics__c>();
        Core_AE_Retry_and_Reprocess_Logics__c custSet1 = new Core_AE_Retry_and_Reprocess_Logics__c(Name = '1', Core_Logic_Name__c = 'Daily Entitlement Cleanup - Entitlement Based',
                                                                                                  Core_Error_Contains__c = 'Operation taking too long to complete from AGS;already has a pending add role request', Core_Maximum_Attempts__c = 2);
        Core_AE_Retry_and_Reprocess_Logics__c custSet2 = new Core_AE_Retry_and_Reprocess_Logics__c(Name = '2', Core_Logic_Name__c = 'Daily Entitlement Cleanup - Contact Based',
                                                                                                  Core_Error_Contains__c = 'AGS getrole api flow failed', Core_Maximum_Attempts__c = 2);
        listAECustSett.add(custSet1);
        listAECustSett.add(custSet2);
        Database.insert(listAECustSett);
        
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
    }  
    
    @isTest
    static void dailyEntitlementCleanup_test(){
        List<String> functionalityList1 = new List<String>();
        String functionalityStr1 = 'DailyEntitlementCleanup';
        functionalityList1.add(functionalityStr1);
        Test.startTest();
        User runAsUser = [SELECT Id FROM User WHERE Email = 'pbuser@example.com'];
        List<Core_Contact_Entitlement__c> conEntList = [SELECT Id, Core_Entitlement_Nm__c, Core_Contact_Id__c, Core_Status_of_Assignment_Failure__c,Core_Retrigger_Attempt__c, Core_Selected__c, Core_Status__c,Core_Update_Reason__c FROM Core_Contact_Entitlement__c];
        for(Core_Contact_Entitlement__c conEnt : conEntList){
            
        }
        
        System.runAs(runAsUser){
            Core_Draco_Misc_Functionalities.functionalityClassificationMethod(functionalityList1);
        }
        Test.stopTest();
    }
    
}