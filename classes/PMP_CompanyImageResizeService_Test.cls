@isTest
public class PMP_CompanyImageResizeService_Test {
    
    @testSetup
    static void setupTestData() {
        Core_Trigger_Executions__c cs = new Core_Trigger_Executions__c (Name = 'Comp_Resource_Handler',
                                                                        Core_Active__c = true,
                                                                        Core_Class_Name__c = 'PMP_SearchCompanyResourceTriggerHandler',
                                                                        Core_Object__c = 'PMP_Company_Resource__c',
                                                                        Core_Trigger_Events__c = 'after insert, after update',
                                                                        Core_Description__c = 'This is used for creating content distribution records for each Compnay Resource.');
        insert cs;
        Account acc1 = PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        

        //create content document , so that we can assocaite to company resource
        List<ContentVersion> versions = new List<ContentVersion>();
        versions.add(PMP_SearchTestDataFactory.createCompanyDocuments(cmp1.Id, 'Test logo1', true));
        versions.add(PMP_SearchTestDataFactory.createCompanyDocuments(cmp1.Id, 'Test logo2', true));
        List<Id> cvIds = new List<Id>();
        for(ContentVersion cv : versions) {
        	cvIds.add(cv.Id);
        }
        List<ContentVersion> insertedVersions = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cvIds];
        //String imgqq = PMP_StaticConstants_Partner.IMAGE; 
        //system.debug('imgqq'+imgqq);
        //set up company resources and insert 
        List<PMP_Company_Resource__c> comp_resources = new List<PMP_Company_Resource__c>();
        comp_resources.add(createCompanyResourceInstance('Resource1','www.intel.com',cmp1.Id,'Image',insertedVersions[0].ContentDocumentId));
        comp_resources.add(createCompanyResourceInstance('Resource2','www.intel.com',cmp1.Id,'Thumbnail Image',insertedVersions[1].ContentDocumentId));
        insert comp_resources;
    }

    public static PMP_Company_Resource__c createCompanyResourceInstance(String name,String url, Id compId, String resourceType, String contentId){
        PMP_Company_Resource__c resource = new PMP_Company_Resource__c();
        resource.Name				=	name;
        resource.PMP_Company_Id__c = compId;
        resource.PMP_Company_Resource_Sequence_Nbr__c = 0;
        resource.PMP_Company_Resource_Type_Nm__c = resourceType;
        if(resourceType == 'Image' || resourceType =='Thumbnail Image')
            resource.PMP_Company_Image__c = contentId;
        else
            resource.PMP_Company_Resource_URL_txt__c = url;

        return resource;    
    } 
	//IPA2.0:US-4497-1631_OfferingEOL   
    static testMethod void generateThumbnailImageSuccessTest2(){
        List<PMP_Company__c> comp_list = [Select Id from PMP_Company__c LIMIT 10];
        List<PMP_Company_Resource__c> comp_resources = [Select Id, PMP_Company_Image__c,PMP_Company_Resource_Type_Nm__c from PMP_Company_Resource__c WHERE PMP_Company_Resource_Type_Nm__c ='Image'];
        //start the test execution
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PMP_ImageResizeServiceSuccessMock());
        HttpResponse response = PMP_CompanyImageResizeService.makeCalloutToPIM(comp_resources[0].Id, 0);
        Test.stopTest();
		System.assertEquals(200, response.getStatusCode(), 'Expected status code 200');
    }

    static testMethod void generateThumbnailImageSuccessTest() {
		List<PMP_Company__c> comp_list = [Select Id from PMP_Company__c LIMIT 10];
        //PMP_Company__c comp = comp_list.isEmpty() ? null : comp_list[0];
        List<PMP_Company_Resource__c> comp_resources = [Select Id, PMP_Company_Image__c,PMP_Company_Resource_Type_Nm__c from PMP_Company_Resource__c WHERE PMP_Company_Resource_Type_Nm__c ='Image'];
        //start the test execution
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new PMP_ImageResizeServiceSuccessMock());
        	PMP_CompanyImageResizeService resizeService = new PMP_CompanyImageResizeService();
            resizeService.retryCallout(comp_resources[0].Id);
        	
        Test.stopTest();
        
        
        //One new thumbnail and one old thumbnail image will be available
        List<PMP_Company_Resource__c> thumbnailCompResource = [Select Id,PMP_Company_Resource_Type_Nm__c from PMP_Company_Resource__c WHERE PMP_Company_Resource_Type_Nm__c = 'Thumbnail Image'];
        system.assertEquals(2,thumbnailCompResource.size()); 
    }
    
}