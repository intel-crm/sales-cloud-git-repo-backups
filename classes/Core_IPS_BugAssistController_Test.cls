/**
* @File Name : Core_IPS_BugAssistController_Test.cls
* @Description : Test Class for Core_IPS_BugAssistController
* @Author : Hassan Khan
* @Last Modified By : Hassan Khan
* @Last Modified On : November 7, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | November 7, 2024 |   | Initial Version
**/
@IsTest
public class Core_IPS_BugAssistController_Test {
    static testmethod void possitiveTest(){
		Case testCase = TestUtilities.getCase();
        insert testCase;
        
        String bugAssistRecId = Core_IPS_BugAssistController.createIPSBugAssistAttachmentRecord();
        
        Core_IPS_BugAssist_Attachment__c bugAssistAttachment = new Core_IPS_BugAssist_Attachment__c();
        bugAssistAttachment.id = bugAssistRecId;
        bugAssistAttachment.Core_File_URL__c = 'https://efttest.intel.com/sftservices/download/IPS_SFT?FileName=Purchase+Confirmation.pdf&AppFileID=3ad02d2b-75ce-429d-871c-d858d7970b67&AppData=caseId-null';
		bugAssistAttachment.Core_File_Description__c = 'Testing';
        bugAssistAttachment.Core_FileSizeInBytes__c = '1000';
        bugAssistAttachment.Core_Upload_Status__c = 'Complete';
        bugAssistAttachment.Core_IPS_Attachment_Visibility__c = 'Public to Customers';
        bugAssistAttachment.Core_IPS_Attachment_Source__c = 'Customer Portal';
        bugAssistAttachment.Core_Type__c = 'Attachment';
        bugAssistAttachment.Core_Category__c = 'Attachment';
		bugAssistAttachment.Core_File_GUID__c = '7d811ca8-06b9-43e3-8a11-ef5fa96c6df6';
		bugAssistAttachment.Core_File_Name__c = 'TestJSON_hk.json';
		bugAssistAttachment.Core_File_Size__c = '.92 KB';
		bugAssistAttachment.Core_FileSizeInBytes__c = '947';
        //bugAssistAttachment.Core_SFT_Suggestion__c = 'Testing';
        //bugAssistAttachment.Core_SFT_Recommendation__c = 'Testing';
        
		update bugAssistAttachment;
        
        Test.startTest();
        Core_IPS_BugAssistController.bugAssistRecordConversion(testCase.Id,bugAssistAttachment.Id);
        Core_IPS_BugAssistController.fetchBugAssistRecord(bugAssistAttachment.Id);
        Core_IPS_BugAssistController.bugAssistRecordDeletion(bugAssistAttachment.Id);     
        Test.stopTest();
        
        System.assert(bugAssistAttachment.id != null);
    }
    static testmethod void possitiveTest2(){  
        Core_IPS_Product_Organization__c prodOrg = TestUtilities.getSupportOrg();
        insert prodOrg;
        
        Product2 prod = TestUtilities.getProduct();
        insert prod;
        
        Asset assetRec = TestUtilities.getAsset();
        assetRec.Core_Product_Organization__c = prodOrg.id;
        insert assetRec;
        
        
        Core_IPS_Supported_Product__c supportedProd= TestUtilities.getSupportedProduct();
        supportedProd.Core_Product__c = prod.id;
        supportedProd.Core_Product_Organization__c = prodOrg.id;
        supportedProd.Core_Flag_Status__c = 'Auto Approve';
        insert supportedProd;
        
        
        Test.startTest();
    	Core_IPS_BugAssistController.validateProductOrg(assetRec.Id);
        Core_IPS_BugAssistController.validateBugAssistProd(supportedProd.Id);
        Test.stopTest();
        System.assert(assetRec.id != null);
    }
}