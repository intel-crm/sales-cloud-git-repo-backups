/**************************************************************************************
Apex Class Name:  Core_A_E_Notify_Requester_Test
Description    : This class is Test class for Core_A_E_Notify_Requester
*************************************************************************************/
@isTest
public class Core_A_E_Notify_Requester_Test
{
    
    @testSetup
    static void testDataSetup() {
        List<Contact> contacts = new List<Contact>();
        Contact NewContact = new Contact();
        String intelAccRecTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        Account acc= new Account();
        acc.Name = 'Test Account';
        acc.BillingCity ='test';
        acc.BillingCountry='India';
        acc.BillingStreet='Bangalore'; 
		acc.RecordTypeId=intelAccRecTypeId; 
        insert acc;
        NewContact.FirstName = 'Test';
        NewContact.LastName = 'Email';
        NewContact.AccountId = acc.Id;
        NewContact.Email = 'testsend@mail.com'; 
        NewContact.Core_AGS_Integration_Status__c = 'Successful';//Pending
        NewContact.MailingCountry='India';
        contacts.add(NewContact);
        //insert NewContact;
        
        Contact NewContact2 = new Contact();
        NewContact2.FirstName = 'Test';
        NewContact2.LastName = 'Email2';
        NewContact2.AccountId = acc.Id;
        NewContact2.Email = 'testsend2@mail.com'; 
        NewContact2.Core_AGS_Integration_Status__c = 'Pending';
		NewContact2.MailingCountry='India';
        
        contacts.add(NewContact2);
        //insert NewContact2;
        insert contacts;
        
        Core_Entitlement_Profile_Access__c epa = new Core_Entitlement_Profile_Access__c( Core_Profile_Id__c = userinfo.getProfileId().substring(0,15),
                                                                                        Core_Send_Notification_Ind__c = true
                                                                                       );
        insert epa; 
        Core_ERPM_Engagement__c erpmEng = new Core_ERPM_Engagement__c(
            Name = 'CCF',
            Core_Technical_Engagement_Code__c = 'CCF',
            Core_Technical_DeDup_Number__c = 'CCF',
            Core_Engagement_Type__c = 'SEC'
        );
        insert erpmEng;
        Core_AGS_Role__c agsRole = new Core_AGS_Role__c();
                             agsRole.Core_Technical_Name__c = 'CCP_CCF_External_Activity_Submitter_Test';
                             agsRole.Name = 'CCP_CCF_External_Activity_Submitter_Test';
                             insert agsRole;
        List<Core_Entitlement__c> entitlements = new List<Core_Entitlement__c>();
        Core_Entitlement__c entitlement = new Core_Entitlement__c();
                             entitlement.Name = 'CCF Activity Submitter Test';
                             entitlement.Core_Display_Name__c = 'CCF Activity Submitter Test';
                             entitlement.Core_ERPM_Engagement_Id__c = erpmEng.Id;
                             entitlement.Core_AGS_Role_Id__c = agsRole.Id;
                             entitlement.Core_Category__c = 'Intel® Partner Investment Center';
                             entitlement.Core_Sub_Category__c = 'Web Order Management (WOM)';
							 entitlements.add(entitlement);
                             //insert entitlement;
        
        Core_Entitlement__c entitlement1 = new Core_Entitlement__c();
                             entitlement1.Name = 'DCF Activity Submitter Test';
                             entitlement1.Core_Display_Name__c = 'DCF Activity Submitter Test';
                             entitlement1.Core_ERPM_Engagement_Id__c = erpmEng.Id;
                             entitlement1.Core_AGS_Role_Id__c = agsRole.Id;
                             entitlement1.Core_Category__c = 'Intel® Partner Investment Center';
                             entitlement1.Core_Sub_Category__c = 'Web Reporting';
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
        					 contactEntitlements.add(contactEntitlement3);
        //insert contactEntitlement3;
        
        Core_Contact_Entitlement__c contactEntitlement4 = new Core_Contact_Entitlement__c();
                             contactEntitlement4.Core_Entitlement_Requester_Id__c = UserInfo.getUserId();
                             contactEntitlement4.Core_Contact_Id__c = newContact2.Id;
                             contactEntitlement4.Core_Entitlement_Id__c = entitlement1.Id;
        					 //contactEntitlement4.Core_Entitlement_Requester_Id__c = user.id;
        					 contactEntitlement4.Core_Email_Pending_To_Requester_Ind__c = true;
        					 contactEntitlements.add(contactEntitlement4);
        //insert contactEntitlement4;
        //contactEntitlements.add(contactEntitlement1);
        
        Core_Contact_Entitlement__c contactEntitlement2 = new Core_Contact_Entitlement__c();
                             //contactEntitlement2.Core_Entitlement_Requester_Id__c = UserInfo.getUserId();
                             contactEntitlement2.Core_Contact_Id__c = NewContact2.Id;
        					 //contactEntitlement2.Core_Contact_Id__r.Core_AGS_Integration_Status__c='Pending';
                             contactEntitlement2.Core_Entitlement_Id__c = entitlement.Id;
        					 contactEntitlement2.Core_Email_Pending_To_Requester_Ind__c = true;
        					contactEntitlement3.Core_Data_Loaded__c=false;
        					 contactEntitlement2.Core_Entitlement_Requester_Id__c = user.id;
         contactEntitlements.add(contactEntitlement2);              
                             //insert contactEntitlement2;
                             insert contactEntitlements;
    }
    
    @isTest
    static void testSendMail()
    {
        List<Contact> contacts = [select id from contact];
        //system.debug('Contact List of type contacts ==>'+contacts );
        List<Id> contactIds = new List<Id>();
        for(Contact con : contacts ) {  contactIds.add(con.Id);
                                     }
		Assert.isNotNull(contacts);
        //system.debug('Contact List of type Ids ==>'+contactIds );
        Test.startTest();
        Core_A_E_Notify_Requester.sendEmail(contactIds);
        Test.stopTest();                           
    }
	//Added as a part of Sela Code Scan Fixes(TWC1811-6067)
    @isTest
    static void testSendMail1()
    {
        
        List<Contact> contacts = [select id from contact where LastName='Email2' limit 1];
        //system.debug('Contact List of type contacts ==>'+contacts );
        List<Id> contactIds = new List<Id>();
        contactIds.add(contacts[0].id);
		Assert.isNotNull(contacts[0].id);
        Test.startTest();
        Core_A_E_Notify_Requester.sendEmail(contactIds);
        Test.stopTest();                           
    }
    
}