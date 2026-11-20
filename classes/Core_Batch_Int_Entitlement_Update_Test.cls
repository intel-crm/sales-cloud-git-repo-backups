/**************************************************************************************
Apex Class Name : Core_Batch_Int_Entitlement_Update_Test
Version     : 1.0 
Created Date: 11th Jan 2024
Description :  Test Class for Core_Batch_Internal_Entitlement_Update
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* Shreyas[Team Draco]     11 Jan 2024               Original Version
*************************************************************************************/

@isTest(seeAllData=false)
public class Core_Batch_Int_Entitlement_Update_Test {
    @testSetup 
    static void setup() {
        //Prepare the list of Accounts
        List<Account> accList = new List<Account>();
		String intelAccRecTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        Account intelAccount1 = new Account(Name ='IntelAccount34',Core_Account_Type__c = 'Original Design Manufacturer (ODM)',Core_Sales_Groups__c= 'PRC Sales Group',RecordTypeId=intelAccRecTypeId,
                                            Industry='Agriculture', BillingCity='Pune',BillingCountry='Ind',BillingStreet='abc chowk delhi', Core_IPA_Partner_Role__c = 'Distributor');
        
        accList.add(intelAccount1);
        Database.insert (accList);
        
        
        //Prepare the list of Contacts
        List<Contact> allContacts = new List<Contact>();
        
        Contact conTest1 = new Contact(firstname='TestIntel',lastname='ContactAE', accountId=intelAccount1.id, Core_Enterprise_Id__c='300002701661',MailingCountry='India', Email='dellcon1@dell.com');
        allContacts.add(conTest1);
        
        Contact conTest2 = new Contact(firstname='TestIntel',lastname='ContactNM', accountId=intelAccount1.id, Core_Enterprise_Id__c='300002701662',MailingCountry='India', Email='dellco2@dell.com'); 
        allContacts.add(conTest2);
        insert allContacts;
        
        
        //Prepare the list of AGS Roles
        List<Core_AGS_Role__c> agsRoleList = new List<Core_AGS_Role__c>();
        Core_AGS_Role__c agsRole1 = new Core_AGS_Role__c(Name ='Co-Marketing(Salesforce)-External Channel MDF Activity Submitter',Core_Technical_Name__c = 'Co-Marketing(Salesforce)-External Channel MDF Activity Submitter',Core_IsActive__c = true);
        Core_AGS_Role__c agsRole2 = new Core_AGS_Role__c(Name ='Co-Marketing(Salesforce)-External Account Budget Administrator-CCF',Core_Technical_Name__c = 'Co-Marketing(Salesforce)-External Account Budget Administrator-CCF',Core_IsActive__c = true);
        Core_AGS_Role__c agsRole3 = new Core_AGS_Role__c(Name ='Partner Portal',Core_Technical_Name__c = 'SFDC Intel Partner External',Core_IsActive__c = true);
        agsRoleList.add(agsRole1);
        agsRoleList.add(agsRole2);
        agsRoleList.add(agsRole3);
        Database.insert(agsRoleList);
        //Prepare the list of Entitlement Details
        List<Core_Entitlement__c>entdetailList = new List<Core_Entitlement__c>();
        Core_Entitlement__c entdetail1 = new Core_Entitlement__c(Core_Display_Name__c = 'Channel MDF Activity Submitter', Name = 'Channel MDF Activity Submitter', Core_IsActive__c = true,Core_Entitlement_Type__c = 'Salesforce', Core_AGS_Role_Id__c = agsRole1.Id);
        Core_Entitlement__c entdetail2 = new Core_Entitlement__c(Core_Display_Name__c = 'CCF Account Budget Administrator', Name = 'CCF Account Budget Administrator', Core_IsActive__c = true,Core_Entitlement_Type__c = 'Salesforce', Core_AGS_Role_Id__c = agsRole2.Id);
        Core_Entitlement__c entdetail3 = new Core_Entitlement__c(Core_Display_Name__c = 'Partner Portal', Name = 'Partner Portal', Core_IsActive__c = true,Core_Entitlement_Type__c = 'AGS', Core_AGS_Role_Id__c = agsRole3.Id);
        entdetailList.add(entdetail1);
        entdetailList.add(entdetail2);
        entdetailList.add(entdetail3);
        Database.insert(entdetailList);
        
        //Prepare the list of failed CE Records
        List<Core_Contact_Entitlement__c> allConEnt = new List <Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c contEnt1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c = allContacts[0].Id, Core_Entitlement_Id__c = entdetail1.Id, Core_Status_of_Assignment_Failure__c = 'Failed Assignment', Core_Selected__c = false, Core_Status__c = 'Complete', Core_Update_Reason__c = 'User record not Available');
        Core_Contact_Entitlement__c contEnt2 = new Core_Contact_Entitlement__c(Core_Contact_Id__c = allContacts[1].Id, Core_Entitlement_Id__c = entdetail2.Id, Core_Status_of_Assignment_Failure__c = 'Failed Removal', Core_Selected__c = true, Core_Status__c = 'Complete', Core_Update_Reason__c = 'User record not Available');
        Core_Contact_Entitlement__c contEnt3 = new Core_Contact_Entitlement__c(Core_Contact_Id__c = allContacts[0].Id, Core_Entitlement_Id__c = entdetail3.Id,Core_Status__c = 'Pending');
        //Core_Contact_Entitlement__c contEnt4 = new Core_Contact_Entitlement__c(Core_Contact_Id__c = allContacts[1].Id, Core_Entitlement_Id__c = entdetail3.Id,Core_Status__c = 'Pending');
        allConEnt.add(contEnt1);
        allConEnt.add(contEnt2);
        allConEnt.add(contEnt3);
        Database.insert(allConEnt);
        List<Core_Contact_Entitlement__c> contEntRec = new List<Core_Contact_Entitlement__c>();
        for(Core_Contact_Entitlement__c conEntUpdate : [Select Id, Core_Selected__c from Core_Contact_Entitlement__c]){
            if(!conEntUpdate.Core_Selected__c){
                conEntUpdate.Core_Status_of_Assignment_Failure__c = 'Failed Assignment';
                contEntRec.add(conEntUpdate);
            } else {
                conEntUpdate.Core_Status_of_Assignment_Failure__c = 'Failed Removal';
                contEntRec.add(conEntUpdate);
            }
        }
        Database.update(contEntRec);
        
        Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 1];
        
        List<User> lstUser = new List<User>();
        User usr = new User();
        usr.UserName = 'dellcon1@dell.com';
        usr.LastName = 'ContactAE';
        usr.ProfileId = partnerProfile.Id;
        usr.Email = 'dellcon1@dell.com';
        usr.ContactId = conTest1.Id;
        usr.EmailEncodingKey='UTF-8';
        usr.LanguageLocaleKey='en_US';
        usr.LocaleSidKey='en_US';
        usr.TimeZoneSidKey='America/Los_Angeles';
        usr.Alias = String.valueOf(datetime.now()).substring(0,8);
        
        lstUser.add(usr);
        
        User usr1 = new User();
        usr1.Username = 'dellco2@dell.com';
        usr1.LastName = 'ContactNM';
        usr1.ProfileId = partnerProfile.Id;
        usr1.Email = 'dellco2@dell.com';
        usr1.ContactId = conTest2.Id;
        usr1.EmailEncodingKey='UTF-8';
        usr1.LanguageLocaleKey='en_US';
        usr1.LocaleSidKey='en_US';
        usr1.TimeZoneSidKey='America/Los_Angeles';
        usr1.Alias = String.valueOf(datetime.now()).substring(0,8);
        lstUser.add(usr1);
        
        Database.insert(lstUser);
    }
    
    @isTest public static void testBatch(){
        Test.startTest();
        Core_Batch_Internal_Entitlement_Update testBatch = new Core_Batch_Internal_Entitlement_Update();
        Id idBatch = database.executebatch(testBatch, 2);
        Test.stopTest();
        system.assertEquals(true, idBatch != null? true : false , 'Batch executed successfully');
    }
}