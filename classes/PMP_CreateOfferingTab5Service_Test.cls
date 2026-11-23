/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class PMP_CreateOfferingTab5Service_Test {
    
    @testSetup
    static void setupSeedData() {
        
        Account acc1 = PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        PMP_Partner_Offering__c offering1 = PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        
        //create content document , so that we can assocaite to offering resource
        List<ContentVersion> versions = PMP_TestDataUtility.getContentVersions(true,2);
        List<Id> cvIds = new List<Id>();
        for(ContentVersion cv : versions) {
            cvIds.add(cv.Id);
        }
        List<ContentVersion> insertedVersions = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cvIds];
                
        //set up offering resources and insert 
        List<PMP_Partner_Offering_Resource__c> offeringResources = new List<PMP_Partner_Offering_Resource__c>();
        offeringResources.add(PMP_TestDataUtility.createOfferingResourceInstance('Resource1','www.intel.com',offering1.Id,PMP_StaticConstants_Offering.IMAGE,insertedVersions[0].ContentDocumentId));
        offeringResources.add(PMP_TestDataUtility.createOfferingResourceInstance('Resource2','www.intel.com',offering1.Id,PMP_StaticConstants_Offering.THUMBNAIL_IMAGE,insertedVersions[1].ContentDocumentId));
        insert offeringResources;
    }
    
    static testMethod void generateThumbnailImageSuccessTest() {
        
        List<PMP_Partner_Offering__c> offerings = [Select Id from PMP_Partner_Offering__c];
        //start the test execution
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new PMP_ImageResizeServiceSuccessMock());
            PMP_CreateOfferingTab5Service.generateThumbnailImages(offerings[0].Id);
        Test.stopTest();
        
        List<PMP_Partner_Offering_Resource__c> thumbnailOfferingResource = [Select Id from PMP_Partner_Offering_Resource__c WHERE PMP_Resource_Type_Nm__c = :PMP_StaticConstants_Offering.THUMBNAIL_IMAGE];
        system.assertEquals(1,thumbnailOfferingResource.size());
        
            
    }
    
    static testMethod void generateThumbnailImageFailureTest() {
        
        List<PMP_Partner_Offering__c> offerings = [Select Id from PMP_Partner_Offering__c];
        
        //start the test execution
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new PMP_ImageResizeServiceFailureMock());
            PMP_CreateOfferingTab5Service.generateThumbnailImages(offerings[0].Id);
        Test.stopTest();
        
        List<PMP_Partner_Offering_Resource__c> thumbnailOfferingResource = [Select Id from PMP_Partner_Offering_Resource__c WHERE PMP_Resource_Type_Nm__c = :PMP_StaticConstants_Offering.THUMBNAIL_IMAGE];
        system.assertEquals(0,thumbnailOfferingResource.size());//If the callout failed then no thumbnail created
        
        List<Core_Log_Failed_Callout_Entry__c> coreLogEntryRecords = new List<Core_Log_Failed_Callout_Entry__c>();
        coreLogEntryRecords = [Select Id,Core_Status__c from Core_Log_Failed_Callout_Entry__c];
        system.assertEquals(coreLogEntryRecords.size(),1);
        system.assertEquals(coreLogEntryRecords[0].Core_Status__c,'Investigating');
        
            
    }
}