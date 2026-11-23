@isTest
private class PMP_ImageResizeService_Test{
	
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
        List<PMP_Partner_Offering_Resource__c> offeringResources = [Select Id from PMP_Partner_Offering_Resource__c WHERE PMP_Resource_Type_Nm__c = :PMP_StaticConstants_Offering.IMAGE];
        //start the test execution
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new PMP_ImageResizeServiceSuccessMock());
        	PMP_ImageResizeService resizeService = new PMP_ImageResizeService();
            resizeService.retryCallout(offeringResources[0].Id);
        	//resizeService.retryCallout(new List<Id>());//its a future reserved method for bulk processing records
        Test.stopTest();
        
        //One new thumbnail and one old thumbnail image will be available
        List<PMP_Partner_Offering_Resource__c> thumbnailOfferingResource = [Select Id from PMP_Partner_Offering_Resource__c WHERE PMP_Resource_Type_Nm__c = :PMP_StaticConstants_Offering.THUMBNAIL_IMAGE];
        system.assertEquals(2,thumbnailOfferingResource.size()); 
    }
}