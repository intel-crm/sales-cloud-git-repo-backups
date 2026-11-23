/***************************************************************************************************
* Apex Class Name: Core_IPS_ListOfContactsController_Test
* Version     : 1.0 
* Function    : Test class for Core_IPS_ListOfContactsController_Test
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Created for US682835 - A Contact on the Partner portal needs to have a means to see all other IPS Active Contacts on their same Account. 
****************************************************************************************************/
@isTest
public class Core_IPS_ListOfContactsController_Test {
    
    public static testmethod void portalUsercreation(){
        Account portalAccount1 = new Account(
            Name = 'newAcc2',
            BillingCity = 'folsom',
            BillingCountry = 'USA',
            BillingStreet = 'Creek Side Dr',
            BillingState = 'NV',
            BillingPostalCode = '591213',
            Core_CIM_ID__c = '11429344',
            Core_B2B_Entitlement__c = true,
            Core_Account_Legal_Name__c = 'TestLegalName',
            OwnerId = userinfo.getUserId()
        );       
        Database.insert(portalAccount1);
        System.assert(portalAccount1.Id != null, 'Account Record not created');
            
        //Create contact
        Contact contact2 = new Contact(
            AccountId = portalAccount1.id,
            FirstName = 'portia2',
            LastName  = 'portalTestUser2',
            Email='portia2@intel.com',
            MailingCountry = 'India'
        );
        Database.insert(contact2);
        System.assert(contact2.Id != null, 'Contact Record not created');
            
        List<Profile> profileList = [select id, name from Profile where name = 'partner'];
        
        User userTest = new User(alias = 'testUser', email='testUser@inteltest.com',
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles',ProfileId=ProfileList[0].id,
                                 IsActive =true,
                                 ContactId = contact2.Id, username='tester@inteltest.com',PortalRole = 'Manager');
        insert userTest;
        System.assert(userTest.Id != null, 'User Record not created');
            
        System.runAs(userTest){
            
            PageReference pageRef = Page.Core_IPS_ListOfContacts;
            Test.setCurrentPage(pageRef);
            Core_IPS_ListOfContactsController displayContacts = new Core_IPS_ListOfContactsController();
            displayContacts.getTotalPages();
            displayContacts.getPageNumber();
            displayContacts.getTotalSize();
            displayContacts.next();
            displayContacts.previous();
            displayContacts.getDisableNext();
            displayContacts.getDisablePrevious();
            displayContacts.showRecords();
        }  
    }  
}