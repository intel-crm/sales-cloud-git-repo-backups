/***************************************************************************************************
Apex Class Name: Core_IPS_FileUpload_Controller_Test 
Version     : 1.0 
Created Date: 1st Oct 2015
Function    : IPS SCFT File Upload -> Test Class
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Johri, Sagar              10/01/2015              Created
* Malhotra, Abhimanyu S     10/28/2015              Add comments and Additional navigation Test Method
****************************************************************************************************/

@isTest public class Core_IPS_FileUpload_Controller_Test {
/***************************************************************************************************
Method Name:  UploadTest
Method Type: Test Method
Version     : 1.0 
Created Date: 11th Nov 2015
Description:  File Upload Test
Scenario Type: Positive 
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      10/12/2015              Created
****************************************************************************************************/     
    //Upload Test    
    private static testMethod void UploadTest() {
        List<Core_IPS_File_Upload_Master__c> lstFileUpldMaster =new  List<Core_IPS_File_Upload_Master__c>();
        Core_IPS_FileUpload_Controller FileUploadControllerObj = new Core_IPS_FileUpload_Controller();	
        Core_IPS_File_Upload_Master__c FileUploadMasterObj; 
        
        //Create File Upload Master record Test Data
        FileUploadMasterObj = TestUtilities.getFileUploadMasterRecord();
        FileUploadMasterObj.Core_FileUploadedBy__c = UserInfo.getUserId();
        insert FileUploadMasterObj;
        system.assert(FileUploadMasterObj.Id != null);
        //Test File Upload VF Page
        PageReference pref = Page.Core_IPS_File_Upload_Admin;
        Test.setCurrentPage(pref);
        //Start Test
        Test.startTest();
        FileUploadControllerObj.fileId = FileUploadMasterObj.id;
        FileUploadControllerObj.addfileId();    
        lstFileUpldMaster = FileUploadControllerObj.UploadedFiles;
        Test.stopTest(); 
        System.assert(lstFileUpldMaster.size() == 1);
    }
/***************************************************************************************************
Method Name:  Delete Test
Method Type: Test Method
Version     : 1.0 
Created Date: 11th Nov 2015
Description:  File Delete Test
Scenario Type: Negative 
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      1/08/2016              Created
****************************************************************************************************/     
    //Upload Test    
    private static testMethod void DeleteTest() {
        List<Core_IPS_File_Upload_Master__c> lstFileUpldMaster =new  List<Core_IPS_File_Upload_Master__c>();
        Core_IPS_FileUpload_Controller FileUploadControllerObj;
        Core_IPS_File_Upload_Master__c FileUploadMasterObj; 
        Id ToBeDeletedId;
        
        //Create File Upload Master record Test Data
        FileUploadMasterObj = TestUtilities.getFileUploadMasterRecord();
        FileUploadMasterObj.Core_FileUploadedBy__c = UserInfo.getUserId();
        insert FileUploadMasterObj;
        system.assert(FileUploadMasterObj.Id != null);
        ToBeDeletedId = FileUploadMasterObj.Id;
        //Test File Upload VF Page
        PageReference pref = Page.Core_IPS_File_Upload_Admin;
        Test.setCurrentPage(pref);
        //Start Test
        Test.startTest();
        FileUploadControllerObj = new Core_IPS_FileUpload_Controller();	
        FileUploadControllerObj.fileId = FileUploadMasterObj.id;
        FileUploadControllerObj.addfileId();    
        lstFileUpldMaster = FileUploadControllerObj.UploadedFiles;
        System.assert(lstFileUpldMaster.size() == 1);
        lstFileUpldMaster.clear();
        delete FileUploadMasterObj;
        FileUploadControllerObj.fileId = ToBeDeletedId;
        FileUploadControllerObj.addfileId();    
        lstFileUpldMaster = FileUploadControllerObj.UploadedFiles; 
        Test.stopTest();
        System.assert(lstFileUpldMaster.size() == 0);
    }		    
/***************************************************************************************************
Method Name:  NaviagationTest
Method Type: Test Method
Version     : 1.0 
Created Date: 11th Nov 2015
Description:  Navigation Test
Scenario Type: Positive 
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S      10/12/2015              Created
****************************************************************************************************/         
    //Navigation Test
    private static testMethod void NavigationTest() {
        Core_IPS_FileUpload_Controller FileUploadControllerObj = new Core_IPS_FileUpload_Controller();	    
        PageReference pref = Page.Core_IPS_File_Upload_Admin;
        Test.setCurrentPage(pref);
        Test.startTest();
        String NextPage = FileUploadControllerObj.GotoIPSFileUploadMaster().getUrl();
        Schema.Describesobjectresult result = Schema.Sobjecttype.Core_IPS_File_Upload_Master__c;
        String prefix = result.getKeyPrefix();   
        String fileUploadListViewPage = '/' + prefix + '/o';
        Test.stopTest();
        System.assertEquals(fileUploadListViewPage, NextPage);    
        
    }
}