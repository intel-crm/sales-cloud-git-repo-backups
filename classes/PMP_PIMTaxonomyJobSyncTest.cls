/****************************************************************************************************************************************
* Class Name  : PMP_PIMTaxonomyJobSyncTest 
* Version     : 1.0 
* Created Date: 29/09/2021   
* Modification Log :
* Developer                       Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Yashasvi Aggarwal            29/09/2021                 Test class for PMP_PIMTaxonomyJobSync
* ****************************************************************************************************************************************/
@isTest
public class PMP_PIMTaxonomyJobSyncTest {
    @isTest
    public static void testInvokeTaxonomyProcessing()
    {
        Test.startTest();
        Core_Batch_Header__c testbatchheader = new Core_Batch_Header__c();
        testbatchheader.Name = 'PMP_TaxonomyUploadQueueable';
        testbatchheader.Email_Distribution_List__c = 'abc@test.com';
        insert testbatchheader;
        String testJSON='PMP_All_Files_Delta';
        PMP_PIMTaxonomyJobSync.invokeTaxonomyProcessing(testJSON);
        testJSON='Processors_Attribute_Chinese,Processors_Attribute_English';
        String response=PMP_PIMTaxonomyJobSync.invokeTaxonomyProcessing(testJSON);
        System.assertEquals('2 Files Successful', response);
	    Test.stopTest();      
    }
}