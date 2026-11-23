/******************************************************************************************************************************************
Class Name  : Core_Draco_Misc_Functionalities_Test
Version     : 1.0
Created Date: 12 DEC 2022
Function    : Test Class for Various business logics that currespond to Team Draco that are implemented in Core_Draco_Misc_Functionalities class   

Modification Log :
* Developer                 	Date [DD/MM/YYYY]           	Description
* ----------------------------------------------------------------------------
* Akshay More [Team: DRACO]			20/12/2022              	Original version
*****************************************************************************************************************************************/

@isTest(SeeAllData=false)
public class Core_Draco_Misc_Functionalities_Test {
    @testSetup 
    static void setup() {
        //Prepare the list of Accounts
        List<Account> accList = new List<Account>();
        Account intelAccount1 = new Account(Name ='IntelAccount1',Core_Account_Type__c = 'Original Design Manufacturer (ODM)',Core_Sales_Groups__c= 'PRC Sales Group',
                                            Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi', Core_IPA_Partner_Role__c = 'Distributor', Core_B2B_Entitlement__c = true);
        Account intelAccount2 = new Account(Name ='IntelAccount2',Core_Account_Type__c = 'Original Design Manufacturer (ODM)',Core_Sales_Groups__c= 'PRC Sales Group',
                                            Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi', Core_IPA_Partner_Role__c = 'Distributor', Core_B2B_Entitlement__c = true);
        accList.add(intelAccount1);
        accList.add(intelAccount2);
        Database.insert (accList);
      
        
        //Prepare the list of Contacts
        List<Contact> allContacts = new List<Contact>();
        Contact contact1 = new Contact(firstname='Intel', 
                                       lastname='Contact1', accountId=intelAccount1.id,Core_Enterprise_Id__c='300002701661',Email='dellco1234c1@dell.com',Core_Contact_B2B_Indicator__c = true);
        Contact contact2 = new Contact(firstname='Intel', 
                                       lastname='Contact2', accountId=intelAccount2.id,Core_Enterprise_Id__c='300002701662',Email='dellco1234c2@dell.com',Core_Contact_B2B_Indicator__c = false);
        allContacts.add(contact1);
        allContacts.add(contact2);
        Database.insert(allContacts);
       
        
        //Prepare the Integration Inbound Message of any type. Here we took 'Blackbox' message
        Core_Integration_Inbound_Message__c IIMMessage = new Core_Integration_Inbound_Message__c (Core_Source_System__c = 'ERPM', Core_Message_Type__c = 'Blackbox', Core_Payload__c  = '{"Status":"Success","ErrorCode":null,"ErrorText":null,"ErrorDetails":null,"PersonID":9602080,"EnterpriseID":"300002701661","LoginID":"dellco1234c1@dell.com","EmailID":"dellco1234c1@dell.com","Accounts":[]}', Core_Processing_Status__c = 'Successful');
        Database.Insert(IIMMessage,false);
        
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
    static void b2bFalg_AccountCleanup_b2bAccount() {
        User usr1 = [SELECT Id FROM User WHERE email = 'pbuser@example.com'];
        List<String> functionalityList = new List<String>();
        String functionalityStr = 'B2BAccountCleanup';
        functionalityList.add(functionalityStr);
        Test.startTest();
        System.runAs(usr1){
            Core_Draco_Misc_Functionalities.functionalityClassificationMethod(functionalityList);
        }
        Test.stopTest();
    }
    
      
    
    @isTest
    static void test_CreationOfIntegrationMonitoringLog() {
        User usr1 = [SELECT Id FROM User WHERE email = 'pbuser@example.com'];
        Contact con = [SELECT Id FROM Contact WHERE Email = 'dellco1234c1@dell.com'];
        Core_Integration_Inbound_Message__c IIMMessage = [SELECT Id FROM Core_Integration_Inbound_Message__c LIMIT 1];
        Integer IntgDuration = 222;
        Id conId = con.Id;
        Test.startTest();
        System.runAs(usr1){
            Core_Draco_Misc_Functionalities.createIntgrationMonitoringLog('AGS', 'Success', con.Id, IIMMessage.Id, IntgDuration, 'String IntgLogTags');
            Core_Draco_Misc_Functionalities.createIntgrationMonitoringLog('AGS', 'some categorised error: unable to obtain exclusive access to this record or 1 records', con.Id, IIMMessage.Id, IntgDuration, 'String IntgLogTags');
            Core_Draco_Misc_Functionalities.createIntgrationMonitoringLog('AGS', 'some uncategorised error: agfdhkjfxfykrst', con.Id, IIMMessage.Id, IntgDuration, 'String IntgLogTags');
            Core_Draco_Misc_Functionalities.createIntgrationMonitoringLog('ERPM', 'Success', con.Id, IIMMessage.Id, IntgDuration, 'String IntgLogTags');
            Core_Draco_Misc_Functionalities.createIntgrationMonitoringLog('ERPM', 'some categorised error: unable to obtain exclusive access to this record or 1 records', con.Id, IIMMessage.Id, IntgDuration, 'String IntgLogTags');
            Core_Draco_Misc_Functionalities.createIntgrationMonitoringLog('ERPM', 'some uncategorised error: agfdhkjfxfykrst', con.Id, IIMMessage.Id, IntgDuration, 'String IntgLogTags');
            Core_Draco_Misc_Functionalities.createIntgrationMonitoringLog(null, 'Success', con.Id, IIMMessage.Id, IntgDuration, 'String IntgLogTags');
        }
        Test.stopTest();
    }
    @isTest
    static void test_addRemoveDZPCNDA(){
        Contact con = [SELECT Id,Account.Core_CNDA_Number__c FROM Contact WHERE Email = 'dellco1234c1@dell.com'];
           List<Core_Entitlement__c> lstEntitlementDetails = new List<Core_Entitlement__c>();
            List<Core_AGS_Role__c> lstAGSRoles = new List<Core_AGS_Role__c>();
            List<Core_ERPM_Engagement__c> lstERPMEngagements = new List<Core_ERPM_Engagement__c>();
            
            lstAGSRoles = createTestAGSRole(2);
            lstERPMEngagements = createTestERPMEngagement(2);
        	List<String> entitlementName= new List<String>{'Employee','Developer Zone Premier(CNDA required)'};
        	for(Integer i=0 ; i<=1; i++){
                Core_Entitlement__c testEntitlementDetail = new Core_Entitlement__c();
                testEntitlementDetail.Name = entitlementName[i];
                testEntitlementDetail.Core_Display_Name__c = entitlementName[i];
                testEntitlementDetail.Core_ERPM_Engagement_Id__c = lstERPMEngagements[i].Id;
                testEntitlementDetail.Core_AGS_Role_Id__c = lstAGSRoles[i].Id;
                testEntitlementDetail.Core_IsActive__c = true;
                lstEntitlementDetails.add(testEntitlementDetail);
            }
        	 if(lstEntitlementDetails.size()>0) {
                insert lstEntitlementDetails;
            }
         List<Core_Contact_Entitlement__c> lstTestContactEntitlementsToInsert = new List<Core_Contact_Entitlement__c>();
        
        Boolean selected = true;
      	 for(Core_Entitlement__c entObj : lstEntitlementDetails){
             Core_Contact_Entitlement__c ce =
                                new Core_Contact_Entitlement__c(Core_Contact_Id__c=con.Id, Core_Selected__c=selected,
                                                                Core_Entitlement_Id__c=entObj.id,Core_Status__c ='Complete');
                lstTestContactEntitlementsToInsert.add(ce);
             
             
        }
        if(lstTestContactEntitlementsToInsert != null && lstTestContactEntitlementsToInsert.size() > 0) {
                insert lstTestContactEntitlementsToInsert;
               
            }
         Test.startTest();
        Core_Draco_Misc_Functionalities.validateBeforeDML(lstTestContactEntitlementsToInsert,new List<Contact>{con});
        Core_Draco_Misc_Functionalities.republishConEntFuture(new Set<id>{lstTestContactEntitlementsToInsert[0].id});
          Test.stopTest();
    }
            private static List<Core_AGS_Role__c> createTestAGSRole(Integer numOfTestAGSRoles) {
            
            List<Core_AGS_Role__c> lstAGSRoles = new List<Core_AGS_Role__c>();
            for(Integer i=0; i<numOfTestAGSRoles; i++) {
                Integer currentNumber = 1;
                Core_AGS_Role__c testAGSRole = new Core_AGS_Role__c();
                testAGSRole.Name = 'Test AGS Role ' + currentNumber;
                testAGSRole.Core_IsActive__c = true;
                testAGSRole.Core_Technical_Name__c = 'Test AGS Role Tech Name ' + currentNumber;
                lstAGSRoles.add(testAGSRole);
            }
            if(lstAGSRoles.size()>0) {
                insert lstAGSRoles;
                return lstAGSRoles;
            } else {
                return null;
            }
        }
      private static List<Core_ERPM_Engagement__c> createTestERPMEngagement(Integer numOfTestERPMEngagements) {
            List<Core_ERPM_Engagement__c> lstERPMEngagements = new List<Core_ERPM_Engagement__c>();
            for(Integer i = 0; i < numOfTestERPMEngagements; i++) {
                Integer currentNumber = 1;
                Core_ERPM_Engagement__c testERPMEngagement = new Core_ERPM_Engagement__c();
                testERPMEngagement.Name = 'Test ERPM Engagement ' + currentNumber;
                testERPMEngagement.Core_Technical_Engagement_Code__c = 'ENG' + currentNumber;
                testERPMEngagement.Core_Technical_DeDup_Number__c = 'B2B';
                testERPMEngagement.Core_Engagement_Type__c = 'SEC';
                testERPMEngagement.Core_IsActive__c = true;
                lstERPMEngagements.add(testERPMEngagement);
            }
            if(lstERPMEngagements.size()>0) {
                insert lstERPMEngagements;
                return lstERPMEngagements;
            } else {
                return null;
            }
        }
   
}