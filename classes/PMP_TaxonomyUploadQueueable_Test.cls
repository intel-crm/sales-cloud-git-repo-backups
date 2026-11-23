/****************************************************************************************************************************************
* Class Name  : PMP_TaxonomyUploadQueueable_Test 
* Version     : 1.0 
* Created Date: 04-11-2019
* Modification Log :
* Developer                       Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Infosys - Sangeetha Ganta     05/07/2019                    Test class for PMP_TaxonomyUploadQueueable
* ****************************************************************************************************************************************/
@isTest
public class PMP_TaxonomyUploadQueueable_Test {
    
    @isTest
    public static void uploadQueueableSuccessTest(){
       Core_Batch_Header__c testbatchheader = new Core_Batch_Header__c();
        List<String> staticResourceNames = new List<String>();
        testbatchheader.Name = 'PMP_TaxonomyUploadQueueable';
        testbatchheader.Email_Distribution_List__c = 'abc@test.com';
        insert testbatchheader;
        
        //Core_Batch_Processing__c batchProcessing = new Core_Batch_Processing__c();
        staticResourceNames.add('Hierarchy_English');//PMP_Hierarchy_English
        
        Test.startTest();
        	PMP_TaxonomyUploadQueueable taxonomyUploadQueueable = new PMP_TaxonomyUploadQueueable(staticResourceNames);
        	ID jobID = System.enqueueJob(taxonomyUploadQueueable);
        Test.stopTest();
		
        system.assertEquals(3,[Select Count() from PMP_Category__c]);
    }
    
    @isTest
    public static void uploadQueueableFailureTest(){
        Core_Batch_Header__c testbatchheader = new Core_Batch_Header__c();
        List<String> staticResourceNames = new List<String>();
        testbatchheader.Name = 'PMP_TaxonomyUploadQueueable';
        testbatchheader.Email_Distribution_List__c = 'abc@test.com';
        insert testbatchheader;
        
        staticResourceNames.add('Hierarchy_English_Test');
        
        Test.startTest();
        	PMP_TaxonomyUploadQueueable taxonomyUploadQueueable = new PMP_TaxonomyUploadQueueable(staticResourceNames);
        	ID jobID = System.enqueueJob(taxonomyUploadQueueable);
        Test.stopTest();
        system.assertEquals(0,[Select Count() from PMP_Category__c]);
        
    }
    
    static testMethod void createBatchProcessingLineItemTest(){
        
        List<Database.UpsertResult> upsertResults = new List<Database.UpsertResult>();
        List<PMP_Category__c> categories = new List<PMP_Category__c>();
        
      	PMP_Category__c Category1 = new PMP_Category__c();
        Category1.Name = 'TestCategory1'; 
        Category1.PMP_Active_Ind__c = true;
        Category1.PMP_Partner_Product_Category_Cd__c = 'product1';
        Category1.PMP_Partner_Product_Category_Key__c = '123';
        Category1.PMP_Partner_Product_Parent_Category_Cd__c = 'CODE1';
        insert Category1;
        
        PMP_Category__c Category2 = new PMP_Category__c();
        Category2.Name = 'TestCategory2'; 
        Category2.PMP_Active_Ind__c = true;
        Category2.PMP_Partner_Product_Category_Cd__c = 'product2';
        Category2.PMP_Partner_Product_Category_Key__c = '123';
        Category2.PMP_Partner_Product_Parent_Category_Cd__c = 'CODE2';
        
        categories.add(Category2);
        
        upsertResults = Database.upsert(categories, false);
        
        Core_Batch_Header__c batchHeader = new Core_Batch_Header__c(Email_Distribution_List__c='abc.def@outlook.com',Name = 'Testrecord');
        insert batchHeader;
        
        Core_Batch_Processing__c batchProcessing = new Core_Batch_Processing__c();
        batchProcessing.Batch_Header__c = batchHeader.id;
        batchProcessing.Core_Email_Distribution_List__c = batchHeader.Email_Distribution_List__c;
        insert batchProcessing;
        
        Batch_Processing_Line_Item__c batchProcessingLineItem = new Batch_Processing_Line_Item__c(Batch_Processing__c = batchProcessing.id);
        List<String> staticResourceNames = new List<String>();
        staticResourceNames.add('Hierarchy_English');
        
        Test.startTest();
        PMP_TaxonomyUploadQueueable taxonomyUploadQueueable = new PMP_TaxonomyUploadQueueable(staticResourceNames);
        taxonomyUploadQueueable.createBatchProcessingLineItem(upsertResults,batchProcessingLineItem,'Hierarchy_English');
        Test.stopTest();
    }
}