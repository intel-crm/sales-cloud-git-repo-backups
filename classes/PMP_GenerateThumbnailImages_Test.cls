/**************************************************************************************
Apex Class Name : PMP_GenerateThumbnailImages_Test
Version     : 1.0 
Created Date: 6th Sep, 2019
Description : test class for PMP_GenerateThumbnailImages
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* ONYX Team                 06/09/2019               Original Version
*************************************************************************************/
@isTest
public class PMP_GenerateThumbnailImages_Test {
    
    static testMethod void testGenerateThumbnailImagesPositive(){
        
        List<PMP_Partner_Offering__c> listOfferings= new List<PMP_Partner_Offering__c>();
        //create content document , so that we can assocaite to offering resource
        List<ContentVersion> versions = PMP_TestDataUtility.getContentVersions(true,2);
        List<Id> cvIds = new List<Id>();
        for(ContentVersion cv : versions) {
            cvIds.add(cv.Id);
        }
        List<ContentVersion> insertedVersions = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cvIds];
        
        Account acc1 = PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        PMP_Partner_Offering__c offering1 = PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        offering1.PMP_Partner_Offering_Source_Id__c = '3456578';
        update offering1;
        System.assertEquals('3456578', offering1.PMP_Partner_Offering_Source_Id__c);
        PMP_Partner_Offering_Resource__c res = PMP_TestDataUtility.createOfferingResourceInstance('Resource1','www.intel.com',offering1.Id,PMP_StaticConstants_Offering.IMAGE,insertedVersions[0].ContentDocumentId);
        insert res; 
        Test.startTest();
        PMP_GenerateThumbnailImages obj = new PMP_GenerateThumbnailImages();
        Id batchprocessid = Database.executeBatch(obj,1);
        Test.stopTest();
    }
    
    static testMethod void testgenerateThumbnailsResponseSuccess(){
        
        //create content document , so that we can assocaite to offering resource
        List<ContentVersion> versions = PMP_TestDataUtility.getContentVersions(true,2);
        List<Id> cvIds = new List<Id>();
        for(ContentVersion cv : versions) {
            cvIds.add(cv.Id);
        }
        List<ContentVersion> insertedVersions = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cvIds];
        
        Account acc1 = PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        PMP_Partner_Offering__c offering1 = PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        offering1.PMP_Partner_Offering_Source_Id__c = '3456578';
        update offering1;
        System.assertEquals('3456578', offering1.PMP_Partner_Offering_Source_Id__c);
        PMP_Partner_Offering_Resource__c res = PMP_TestDataUtility.createOfferingResourceInstance('Resource1','www.intel.com',offering1.Id,PMP_StaticConstants_Offering.IMAGE,insertedVersions[0].ContentDocumentId);
        insert res;
        
        Test.startTest();
        PMP_GenerateThumbnailImages obj = new PMP_GenerateThumbnailImages();
        Test.setMock(HttpCalloutMock.class, new PMP_ImageResizeServiceSuccessMock());
        obj.generateThumbnails(offering1.Id);
        Test.stopTest();
    }
    
    static testMethod void testgenerateThumbnailsResponseFailure(){
        
        //create content document , so that we can assocaite to offering resource
        List<ContentVersion> versions = PMP_TestDataUtility.getContentVersions(true,2);
        List<Id> cvIds = new List<Id>();
        for(ContentVersion cv : versions) {
            cvIds.add(cv.Id);
        }
        List<ContentVersion> insertedVersions = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cvIds];
        
        Account acc1 = PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        PMP_Partner_Offering__c offering1 = PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        offering1.PMP_Partner_Offering_Source_Id__c = '3456578';
        update offering1;
        System.assertEquals('3456578', offering1.PMP_Partner_Offering_Source_Id__c);
        PMP_Partner_Offering_Resource__c res = PMP_TestDataUtility.createOfferingResourceInstance('Resource1','www.intel.com',offering1.Id,PMP_StaticConstants_Offering.IMAGE,insertedVersions[0].ContentDocumentId);
        insert res;
        
        Test.startTest();
        PMP_GenerateThumbnailImages obj = new PMP_GenerateThumbnailImages();
        Test.setMock(HttpCalloutMock.class, new PMP_ImageResizeServiceFailureMock());
        obj.generateThumbnails(offering1.Id);
        Test.stopTest();
    }
}