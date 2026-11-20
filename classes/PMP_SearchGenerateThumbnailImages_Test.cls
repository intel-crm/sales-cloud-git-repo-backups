@isTest
Private class PMP_SearchGenerateThumbnailImages_Test {
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
        //PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        PMP_Company__c cmp1 = new PMP_Company__c(Name='TestCompany1',PMP_Account_Industry__c='Others',PMP_Account_Id__c=acc1.Id);
        insert cmp1;                                             
        Test.setCreatedDate(cmp1.Id, DateTime.valueOf('2019-08-25 12:32:53'));
        PMP_Company__c temp = [SELECT CreatedDate from PMP_Company__c where id =: cmp1.Id];
        // system.debug('create date : ' + temp.CreatedDate);
        

        //create content document , so that we can assocaite to company resource
        List<ContentVersion> versions = new List<ContentVersion>();
        versions.add(PMP_SearchTestDataFactory.createCompanyDocuments(cmp1.Id, 'Test logo1', true));
        versions.add(PMP_SearchTestDataFactory.createCompanyDocuments(cmp1.Id, 'Test logo2', true));
        List<Id> cvIds = new List<Id>();
        for(ContentVersion cv : versions) {
        	cvIds.add(cv.Id);
        }
        List<ContentVersion> insertedVersions = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cvIds];
                
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
        resource.PMP_Company_Resource_Type_Nm__c = resourceType;
    //    if(resourceType == PMP_StaticConstants_Partner.IMAGE || resourceType == PMP_StaticConstants_Partner.THUMBNAIL_IMAGE)
       if(resourceType == 'Image' || resourceType == 'Thumbnail Image')    
            resource.PMP_Company_Image__c = contentId;
        else
            resource.PMP_Company_Resource_URL_txt__c = url;

        return resource;    
    }    

    static testMethod void generateThumbnailImageSuccessTest() {
		List<PMP_Company__c> comp_list = [Select Id, CreatedDate,name, CreatedById from PMP_Company__c limit 10];
       // PMP_Company__c comp = comp_list.isEmpty() ? null : comp_list[0];
        	PMP_Company__c comp=new PMP_Company__c();
        	comp.name='test1';
        	insert comp;
        List<PMP_Company_Resource__c> comp_resources = [Select Id, PMP_Company_Image__c from PMP_Company_Resource__c WHERE PMP_Company_Resource_Type_Nm__c ='Image'];
        //system.debug('resource ==> ' + comp_resources);
       
        //start the test execution
        Test.startTest();
        PMP_SearchGenerateThumbnailImages obj = new PMP_SearchGenerateThumbnailImages();
        Database.executeBatch(obj);
        obj.execute(null,comp_list);
      //  Id batchprocessid = Database.executeBatch(obj,1);
      //  system.debug('batchId ==> ' + batchprocessid);
        Test.stopTest();
        
        //One new thumbnail and one old thumbnail image will be available
        List<PMP_Company_Resource__c> thumbnailCompResource = [Select Id from PMP_Company_Resource__c WHERE PMP_Company_Resource_Type_Nm__c = 'Thumbnail Image'];
        system.assertEquals(1,thumbnailCompResource.size(),'No error'); 
    }
    
    static testMethod void generateThumbnailImageSuccessMock(){
        List<PMP_Company__c> comp_list = [Select Id from PMP_Company__c limit 10];
        PMP_Company__c comp = comp_list.isEmpty() ? null : comp_list[0];
        Test.startTest();
        PMP_SearchGenerateThumbnailImages obj = new PMP_SearchGenerateThumbnailImages();
        Test.setMock(HttpCalloutMock.class, new PMP_ImageResizeServiceSuccessMock());
        obj.generateThumbnails(comp.Id);
        system.assertNotEquals(Null, comp_list.size(), 'No Error');
        Test.stopTest();
    }
    
    static testMethod void generateThumbnailImageFailureMock(){
        PMP_Company__c cmp1 = new PMP_Company__c(Name='testCompany');
        insert cmp1;
        Test.startTest();
        PMP_SearchGenerateThumbnailImages obj = new PMP_SearchGenerateThumbnailImages();
        Test.setMock(HttpCalloutMock.class, new PMP_ImageResizeServiceFailureMock());
        obj.generateThumbnails(cmp1.Id);
        system.assertNotEquals(Null, cmp1, 'No Error');
        Test.stopTest();
    }
    
    static testMethod void generateThumbnailImageFailureTest() {
		List<PMP_Company__c> comp_list = [Select Id from PMP_Company__c limit 10];
        PMP_Company__c comp = comp_list.isEmpty() ? null : comp_list[0];
        List<PMP_Company_Resource__c> comp_resources = [Select Id, PMP_Company_Image__c from PMP_Company_Resource__c WHERE PMP_Company_Resource_Type_Nm__c = :PMP_StaticConstants_Partner.IMAGE];
        //start the test execution
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new PMP_ImageResizeServiceFailureMock());
        	PMP_SearchGenerateThumbnailImages obj = new PMP_SearchGenerateThumbnailImages();
        	obj.generateThumbnails(comp.Id);
        	//PMP_Image_Resizing.generateThumbnailImages('a3q0n000000HFEfAAO');
        	system.assertNotEquals(Null, comp_list.size(), 'No Error');
        Test.stopTest();
        
       
    }    
}