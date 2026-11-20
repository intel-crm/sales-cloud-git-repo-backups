/**************************************************************************************
Apex Class Name:  EPUM_LogDataUpdateBatch_Test
Version     : 1.0 
Created Date: 11 Aug 2020
Function    : Test Class for EPUM_LogDataUpdateBatch
User Story : US751665 - IPA: EPUM Dashboard enhancements and UAT readiness
*/

@isTest
public class EPUM_LogDataUpdateBatch_Test {
    
    @testSetup 
    static void createData() {
        
        List<EPUM_Log__c> listOfLogs = new List<EPUM_Log__c>();
        EPUM_Log__c epumLog1 = new EPUM_Log__c();
        epumLog1.EPUM_Search_Text__c = 'testcontact@mailinator.com';
        epumLog1.EPUM_isContact_Registered__c = false;
        epumLog1.EPUM_Origin_Txt__c = 'Invite Sent to Contact';
        listOfLogs.add(epumLog1);
        
        EPUM_Log__c epumLog2 = new EPUM_Log__c();
        epumLog2.EPUM_Search_Text__c = 'testcontact2@mailinator.com';
        epumLog2.EPUM_isContact_Registered__c = false;
        epumLog2.EPUM_Origin_Txt__c = 'Invite Sent to Contact2';
        listOfLogs.add(epumLog2);
        
        insert listOfLogs;
        
        String partnerAccRecTypeId = System.Label.PMP_Partner_Account_Record_Type_Id;
        Account partnerAccount = new Account(Name ='PartnerAccount',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'CCG Sales Group',
                                             Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi',
                                             ShippingCity='delhi',ShippingCountry='Ind',ShippingStreet='cbc chowk delhi',Core_Intel_Partner_Alliance_PartnerGroup__c=True);
        insert partnerAccount;
        
        Id IntelContRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId();
        Contact cont = new Contact(FirstName='Test',LastName='Contact',Email='testcontact@mailinator.com',AccountId=partnerAccount.Id,RecordTypeId=IntelContRecTypeId,
                                   MailingCity='delhi',MailingCountry='India',MailingPostalCode='123456',Core_IPA_PartnerRole__c = 'Service Provider');
        insert cont;
        
        ChannelProgram cp = new ChannelProgram(Name='Intel Partner Alliance',Category='Reseller',PRM_programCode__c='IPA',IsActive=True);
        insert cp;
        
        PRM_ContactRelationships__c contRel = new PRM_ContactRelationships__c();
        contRel.PRM_Channel_Program_Id__c = cp.Id;
        contRel.Name = 'Employee';
        contRel.PRM_Contact_Relationship_Cd__c = 'WORKSFOR';
        insert contRel;
        
        PRM_Account_Contact_Relationship__c acr  = new PRM_Account_Contact_Relationship__c();
        acr.PRM_Account_Id__c = partnerAccount.Id;
        acr.PRM_Contact_Id__c = cont.Id;
        acr.PRM_isActive__c = True;
        acr.PRM_Relationship_Id__c = contRel.Id;
        acr.PRM_Status_Nm__c = 'Complete';
        insert acr;
        
        PRM_Account_Contact_Relationship__c acrUpdate = [Select Id,PRM_Status_Nm__c FROM PRM_Account_Contact_Relationship__c where Id =: acr.Id];
        acrUpdate.PRM_Status_Nm__c = 'Complete';
        update acrUpdate;
        
    }
    
    /*static testmethod void batchApexTest(){
        Test.startTest();
        Database.executeBatch(new EPUM_LogDataUpdateBatch());
        Test.stopTest();
    }*/
    
    static testmethod void testScheduledJob() {
        String CRON_EXP = '0 0 0 28 2 ? 2022';
        Test.startTest();
        EPUM_LogDataUpdateBatch du = new EPUM_LogDataUpdateBatch();
        System.schedule('EPUM Log Update', CRON_EXP, du);
        system.assert(du != null , 'EPUM_LogDataUpdateBatch scheduled');
        Test.stopTest();
    }
    
}