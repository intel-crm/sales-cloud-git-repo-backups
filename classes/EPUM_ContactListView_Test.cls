/**************************************************************************************
Apex Class Name : EPUM_ContactListView_Test
Version     : 1.0 
Created Date: 28th may 2020
Description : test class for EPUM_ContactListView
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* Raushan                  28/04/2020             Original Version
*************************************************************************************/
@isTest
public class EPUM_ContactListView_Test {
    
    @testSetup
    static void testDataSetup() {
        
        List<Account> accList = new List<Account>();
        String partnerAccRecTypeId = System.Label.PMP_Partner_Account_Record_Type_Id;
        Account partnerAccount1 = new Account(Name ='PartnerAccount1',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'CCG Sales Group',
                                          Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi');
        
        accList.add(partnerAccount1);
        Account acc= new Account();
        acc.Name = 'Test Account';
        acc.BillingCity ='test';
        acc.BillingCountry='India';
        acc.BillingStreet='Bangalore';
        accList.add(acc);
        insert accList;
        
        Core_Account_Group_Member__c accGroupMem1 = new Core_Account_Group_Member__c();
            accGroupMem1.Core_Partner_Account_Id__c =partnerAccount1.Id;
            accGroupMem1.Core_Intel_Account_Id__c =acc.Id;
            //accGroupMem1.Core_MDA_Ind__c = true;
        insert accGroupMem1;
        List<Contact> lstContacts = new List<Contact>();
        Contact newContact = new Contact();
        NewContact.FirstName = 'Test';
        NewContact.LastName = 'Email';
        NewContact.AccountId = acc.Id;
        NewContact.Email = 'testsend@mail.com'; 
        NewContact.Core_IPA_PartnerRole__c ='Distributor';
        lstContacts.add(NewContact);
        
        Contact newContact2 = new Contact();
        NewContact2.FirstName = 'Test1';
        NewContact2.LastName = 'Emai1';
        NewContact2.AccountId = acc.Id;
        NewContact2.Email = 'testsend@mail1.com'; 
        NewContact2.Core_IPA_PartnerRole__c ='Distributor';
        lstContacts.add(NewContact2);
        
        Contact newContact3 = new Contact();
        NewContact3.FirstName = 'Test1';
        NewContact3.LastName = 'Emai1';
        NewContact3.AccountId = acc.Id;
        NewContact3.Email = 'testsend@mail1.com'; 
        NewContact3.Core_IPA_PartnerRole__c ='Distributor';
        lstContacts.add(NewContact3);
        insert lstContacts;
        //Contact c = [Select Id,Name,Core_IPA_PartnerRole__c,Core_IPA_One_Partner_Id__c from contact where id=:NewContact.Id];
        
        
        Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='Partner' LIMIT 1];
         
        User user = new User(Alias = 'part', 
                             Email='partnerTest@intel.com', 
                             EmailEncodingKey='UTF-8',
                             LastName='UnitTestItAdmin',
                             LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', 
                             ProfileId = partnerProfile.Id, 
                             TimeZoneSidKey='America/Los_Angeles',
                             UserName='adminTest'+Crypto.getRandomLong()+'@intel.com',
                            ContactId = NewContact.Id);
                             
         insert user; 
        //System.runAs(user){
            
        
        Core_ERPM_Engagement__c erpmEng = new Core_ERPM_Engagement__c(
            Name = 'Intel Partner Alliance',
            Core_Technical_Engagement_Code__c = 'IPA'
           
        );
        insert erpmEng;
        
       
        
        Core_Entitlement__c entitlement = new Core_Entitlement__c();
                             entitlement.Name = 'Warranty Requestor';
                             entitlement.Core_Display_Name__c = 'Warranty Requestor';
                             entitlement.Core_ERPM_Engagement_Id__c = erpmEng.Id;

                             entitlement.Core_Category__c = 'Intel Partner Alliance (IPA)';
                             entitlement.Core_Sub_Category__c = 'Solutions Marketplace';
                             
                             insert entitlement;
        Core_Contact_Entitlement__c contactEntitlement = new Core_Contact_Entitlement__c();
                             
                             contactEntitlement.Core_Contact_Id__c = NewContact.Id;
                             contactEntitlement.Core_Entitlement_Id__c = entitlement.Id;
                             
        insert contactEntitlement;
        
        List<PRM_ContactRelationships__c> contactRelationships = new List<PRM_ContactRelationships__c>();
         PRM_ContactRelationships__c conRel = new PRM_ContactRelationships__c();
         conRel.Name = 'Works For';
         conRel.PRM_Contact_Relationship_Cd__c = 'WORKSFOR';
        
        contactRelationships.add(conRel);
       
         PRM_ContactRelationships__c conRel2 = new PRM_ContactRelationships__c();
         conRel2.Name = 'Primary Contact';
         conRel2.PRM_Contact_Relationship_Cd__c = 'PRIMARYCONTACT';
         contactRelationships.add(conRel2);
        
         PRM_ContactRelationships__c conRel3= new PRM_ContactRelationships__c();
         conRel3.Name = 'Primary Contact Delegate';
         conRel3.PRM_Contact_Relationship_Cd__c = 'PRIMCONTDEL';
         contactRelationships.add(conRel3);
        
        
        insert contactRelationships;
        
        /*PRM_Account_Contact_Relationship__c pac = new PRM_Account_Contact_Relationship__c();
        pac.PRM_Account_Id__c = acc.Id;
        pac.PRM_Contact_Id__c = NewContact.Id;
        pac.PRM_Relationship_Id__r.Name = conRel1.Name;
        System.debug('pac ='+conRel1.Name);
        insert pac;*/
        
         PRM_VXEnttlmntMatrix__c vxe = new PRM_VXEnttlmntMatrix__c ();
         vxe.PRM_Entitlement_Id__c =entitlement.Id;
         vxe.PRM_Approval_Type_Nm__c = 'Manual';
         vxe.PRM_Contact_Relationship_Id__c =conRel.Id;
         insert vxe;
        
        List<PRM_Account_Contact_Relationship__c> pacs = new List<PRM_Account_Contact_Relationship__c>();
        PRM_Account_Contact_Relationship__c pac = new PRM_Account_Contact_Relationship__c();
        pac.PRM_Account_Id__c = acc.Id;
        pac.PRM_Contact_Id__c = NewContact.Id;
        pac.PRM_Relationship_Id__c = conRel.id;
        pacs.add(pac);
            
        
        PRM_Account_Contact_Relationship__c pac1 = new PRM_Account_Contact_Relationship__c();
        pac1.PRM_Account_Id__c = acc.Id;
        pac1.PRM_Contact_Id__c = NewContact2.Id;
        pac1.PRM_Relationship_Id__c = conRel2.id;
        pacs.add(pac1);
        
        PRM_Account_Contact_Relationship__c pac2 = new PRM_Account_Contact_Relationship__c();
        pac2.PRM_Account_Id__c = acc.Id;
        pac2.PRM_Contact_Id__c = NewContact3.Id;
        pac2.PRM_Relationship_Id__c = conRel3.id;
        pacs.add(pac2);
            
        insert pacs;
            String strListView = 'ListViewContact';
            DateTime dtSearchStart = datetime.now();
            EPUM_Log__c epumLog1 = EPUM_Utility.createEPUMLogs(strListView,'Yes',dtSearchStart,'');
            Database.insert(epumLog1);
    
        
    }
@isTest
static void listViewTest()
    {
        User u = [SELECT Id,Email, Name FROM User WHERE Email='partnerTest@intel.com'];
        System.assertEquals(u.Email, 'partnertest@intel.com');
        System.runAs(u){
            
            Test.startTest();
            EPUM_ContactListView.fetchContactListView();
            EPUM_ContactListView.insertEpumLog();
            //EPUM_ContactListView.fetchPrimaryContacts();
            Test.stopTest();
        }
                                  
    }
}