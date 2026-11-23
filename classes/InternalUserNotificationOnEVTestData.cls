@isTest
public class InternalUserNotificationOnEVTestData {
    
    public static List<Id> createTestData(){
        
        //Core_Source__c
        List<Contact> contacts = new List<Contact>();
        Contact NewContact = new Contact();
        Account acc= new Account();
        acc.Name = 'Test Account';
        acc.BillingCity ='test';
        acc.BillingCountry='India';
        acc.BillingStreet='Bangalore';
        insert acc;
        NewContact.FirstName = 'Test';
        NewContact.LastName = 'Email';
        NewContact.AccountId = acc.Id;
        NewContact.Email = 'testsend@mail.com';
        //NewContact.Core_Source__c = 'Grant Access';
        
        contacts.add(NewContact);
        
        Contact NewContact2 = new Contact();
        NewContact2.FirstName = 'Test';
        NewContact2.LastName = 'Email2';
        NewContact2.AccountId = acc.Id;
        NewContact2.Email = 'testsend2@mail.com';
        contacts.add(NewContact2);
        //NewContact2.Core_AGS_Integration_Status__c = 'Pending';
        
        /* Contact NewContact3 = new Contact();
NewContact3.FirstName = 'Test';
NewContact3.LastName = 'Email2';
NewContact3.AccountId = acc.Id;
NewContact3.Email = 'testsend3@mail.com';


contacts.add(NewContact3);*/
        //insert NewContact2;
        insert contacts;
        
        List<Core_Entitlement__c> entitlements = new List<Core_Entitlement__c>();
        
        Core_Entitlement__c entitlement = new Core_Entitlement__c();
        entitlement.Name = 'CCF Activity Submitter Test';
        entitlement.Core_Display_Name__c = 'CCF Activity Submitter Test';
        /* entitlement.Core_ERPM_Engagement_Id__c = erpmEng.Id;
entitlement.Core_AGS_Role_Id__c = agsRole.Id;*/
        entitlement.Core_Category__c = 'Consolidated Co-marketing Platform';
        entitlement.Core_Sub_Category__c = 'Client Co-Marketing Fund (CCF)';
        entitlements.add(entitlement);
        
        Core_Entitlement__c entitlement1 = new Core_Entitlement__c();
        entitlement1.Name = 'DCF Activity Submitter Test';
        entitlement1.Core_Display_Name__c = 'DCF Activity Submitter Test';
        // entitlement1.Core_ERPM_Engagement_Id__c = erpmEng.Id;
        // entitlement1.Core_AGS_Role_Id__c = agsRole.Id;
        entitlement1.Core_Category__c = 'Consolidated Co-marketing Platform';
        entitlement1.Core_Sub_Category__c = 'Client Co-Marketing Fund (CCF)';
        entitlements.add(entitlement1);
        //insert entitlement1;
        insert entitlements;
        
        Profile itAdminProfile = [SELECT Id FROM Profile WHERE Name='IT Admin' LIMIT 1];
        //Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1]; 
        User user = new User(Alias = 'itadmin', 
                             Email='itadminTest@intel.com', 
                             EmailEncodingKey='UTF-8',
                             LastName='UnitTestItAdmin',
                             LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', 
                             ProfileId = itAdminProfile.Id, 
                             TimeZoneSidKey='America/Los_Angeles',
                             UserName='adminTest'+Crypto.getRandomLong()+'@intel.com');
        insert user;
        
        
        List<Core_Contact_Entitlement__c> contactEntitlements = new List<Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c contactEntitlement1 = new Core_Contact_Entitlement__c();
        contactEntitlement1.Core_Entitlement_Requester_Id__c = UserInfo.getUserId();
        contactEntitlement1.Core_Contact_Id__c = newContact.Id;
        contactEntitlement1.Core_Entitlement_Id__c = entitlement.Id;
        contactEntitlement1.Core_Source__c = 'Grant Access';
        contactEntitlement1.Core_Selected__c = true;
        contactEntitlement1.Core_Status__c = 'Complete';
        //contactEntitlement1.Core_Entitlement_Requester_Id__c = user.id;
        contactEntitlement1.Core_Email_Pending_To_Requester_Ind__c = true;
        contactEntitlements.add(contactEntitlement1);
        //insert contactEntitlement1;
        Core_Contact_Entitlement__c contactEntitlement3 = new Core_Contact_Entitlement__c();
        contactEntitlement3.Core_Entitlement_Requester_Id__c = UserInfo.getUserId();
        contactEntitlement3.Core_Contact_Id__c = newContact.Id;
        contactEntitlement3.Core_Entitlement_Id__c = entitlement1.Id;
        //contactEntitlement3.Core_Entitlement_Requester_Id__c = user.id;
        contactEntitlement3.Core_Email_Pending_To_Requester_Ind__c = true;
        contactEntitlement3.Core_Source__c = 'Auto Assign';
        contactEntitlements.add(contactEntitlement3);
        //insert contactEntitlement3;
        
        Core_Contact_Entitlement__c contactEntitlement4 = new Core_Contact_Entitlement__c();
        contactEntitlement4.Core_Entitlement_Requester_Id__c = UserInfo.getUserId();
        contactEntitlement4.Core_Contact_Id__c = newContact2.Id;
        contactEntitlement4.Core_Entitlement_Id__c = entitlement1.Id;
        //contactEntitlement4.Core_Entitlement_Requester_Id__c = user.id;
        contactEntitlement4.Core_Email_Pending_To_Requester_Ind__c = true;
        contactEntitlement4.Core_Source__c = 'Auto Assign';
        contactEntitlement4.Core_Selected__c = False;
        contactEntitlement4.Core_Status__c = 'Complete';
        contactEntitlements.add(contactEntitlement4);
        //insert contactEntitlement4;
        //contactEntitlements.add(contactEntitlement1);
        
        Core_Contact_Entitlement__c contactEntitlement2 = new Core_Contact_Entitlement__c();
        //contactEntitlement2.Core_Entitlement_Requester_Id__c = UserInfo.getUserId();
        contactEntitlement2.Core_Contact_Id__c = newContact2.Id;
        //contactEntitlement2.Core_Contact_Id__r.Core_AGS_Integration_Status__c='Pending';
        contactEntitlement2.Core_Entitlement_Id__c = entitlement.Id;
        contactEntitlement2.Core_Email_Pending_To_Requester_Ind__c = true;
        contactEntitlement2.Core_Entitlement_Requester_Id__c = user.id;
        contactEntitlement2.Core_Source__c = 'Grant Access';
        contactEntitlement2.Core_Selected__c = true;
        contactEntitlement2.Core_Status__c = 'Pending';
        contactEntitlements.add(contactEntitlement2);
        
        //insert contactEntitlement2;
        insert contactEntitlements;
        
        List<Id> cId = new List<Id>(); 
        for(Contact c :contacts){
            cId.add(c.Id);
        }
        
        return cId;
        
    }
    
}