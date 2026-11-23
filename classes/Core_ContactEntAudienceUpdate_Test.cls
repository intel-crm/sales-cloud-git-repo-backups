/**************************************************************************************
Apex Class Name:  Core_ContactEntAudienceUpdate_Test
Version     : 1.0 
Created Date: 1 Oct 2018
Description    : This class is Test class for Core_ContactEntitlementAudienceUpdate
*************************************************************************************/
@isTest
public class Core_ContactEntAudienceUpdate_Test {
    
    static testMethod void conEntitlements(){
        
        Profile sysAdminPrf = [select id, name from Profile where name = 'System Administrator' Limit 1];  
        User sysAdminUser = new User(Alias = 'itAdm21',   Email='itAdminTestx21@intel.com', 
                                     EmailEncodingKey='UTF-8',   LastName='UnitTestAdmin1',
                                     LanguageLocaleKey='en_US',  LocaleSidKey='en_US', 
                                     ProfileId = sysAdminPrf.Id,  TimeZoneSidKey='America/Los_Angeles',
                                     UserName='salesRepTestx21@intel.com');
        insert sysAdminUser;
        
        system.runas(sysAdminUser){
            Account testAccount = new Account(Name='testAccount123', Core_Sales_Group__c='Global Accounts', Core_IsODM__c = true,
                                              Core_Account_Type__c='Other', Industry='Others', Core_CNDA_Number__c = '12345',
                                              BillingStreet='1234 tester St', BillingCity='testCity', BillingState='OR',
                                              BillingCountry='USA', BillingPostalCode='12345',Core_IPS_Active__c = true, Core_CIM_ID__c ='123124');
            insert testAccount;
            
            
            Contact testContact = new Contact(FirstName='testFirstName123', LastName='testLastName', Email='test123@testing.com.test',MailingCountry='India',
                                              AccountId=testAccount.Id,Core_IPS_Active__c =false,Core_IPS_Intel_Support_Owner__c= sysAdminUser.Id,
                                              core_audience_list__c ='DCF User');
            insert testContact;
            System.debug('SA TC testContact:'+testContact);
            Core_ERPM_Engagement__c testERPMEngagement = new Core_ERPM_Engagement__c(Name  ='Partner File Transfer', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='PFT');
            insert testERPMEngagement;   
            Core_Entitlement__c entitle_aud1 =new Core_Entitlement__c (name ='DCF User',Core_ERPM_Engagement_Id__c=testERPMEngagement.id,Core_Display_Name__c='DCF User', Core_IsActive__c=true); 
            insert entitle_aud1;
            Core_Entitlement__c entitle_aud =new Core_Entitlement__c (name ='CCF User',Core_ERPM_Engagement_Id__c=testERPMEngagement.id,Core_Display_Name__c='CCF User',Core_IsActive__c=true); 
            insert entitle_aud;
            System.debug('SA TC Entitlement:'+entitle_aud);
            Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c = entitle_aud.Id,Core_Status__c='Pending', Core_Selected__c=true);	
            insert ce1;
            
            
            system.assertEquals(testContact.Core_Audience_List__c, 'DCF User');  
            ce1.Core_Status__c='Complete';
            update ce1;
            //contact audience field should have been updated by the trigger
            Contact updatedContact=[Select ID,Core_Audience_List__c From Contact
                                    WHERE ID =: testContact.Id];
            
            System.assertEquals(updatedContact.Core_Audience_List__c, 'DCF User');
            
            // Test removal of CCP DCF USER
            
            
            Core_Contact_Entitlement__c ce2 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c = entitle_aud1.Id,Core_Status__c='Pending',Core_Selected__c=true);	
            insert ce2;
            List<Core_Contact_Entitlement__c> oldList = [SELECT Id, Core_Contact_Id__c,Core_Entitlement_Id__c,Core_Selected__c,Core_Status__c,Core_Type__c FROM Core_Contact_Entitlement__c WHERE Id = :ce2.Id];

            Test.startTest();
            ce2.Core_Selected__c = false;
            ce2.Core_Status__c='Complete';
            update ce2;
            List<Core_Contact_Entitlement__c> newList = [SELECT Id, Core_Contact_Id__c,Core_Entitlement_Id__c,Core_Selected__c,Core_Status__c,Core_Type__c FROM Core_Contact_Entitlement__c WHERE Id = :ce2.Id];
            Map<Id, Core_Contact_Entitlement__c> oldMap = new Map<Id, Core_Contact_Entitlement__c>(oldList);
            Map<Id, Core_Contact_Entitlement__c> newMap = new Map<Id, Core_Contact_Entitlement__c>(newList);
            Core_ContactEntitlementAudienceUpdate.updateContactAudience(oldList,newList,oldMap,newMap);
            Test.stopTest();
            //contact audience field should have been updated by the trigger
            updatedContact=[Select ID,Core_Audience_List__c From Contact
                            WHERE ID =: testContact.Id];
            
            
        }
        
    }
    
    
    
}