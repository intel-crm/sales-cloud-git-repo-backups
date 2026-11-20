@isTest
public class core_S2S_FileUploadCaseCtrlTest {
    
    @isTest static void uploadfiles(){        
        List<core_S2S_FileUploadCaseCtrl.FileDataWp> files = new List<core_S2S_FileUploadCaseCtrl.FileDataWp>();
        core_S2S_FileUploadCaseCtrl.FileDataWp newFile = new core_S2S_FileUploadCaseCtrl.FileDataWp();
        newFile.fileContent = 'StringValues';
        newFile.fileName = 'TestFile';
        newFile.indexNumber = 1;
        files.add(newFile);
        String filedata = JSON.serialize(files);
        Test.startTest();
        String result = core_S2S_FileUploadCaseCtrl.uploadFiles('5007j00000H8GIkAAN',filedata);
        Test.stopTest();
        system.assertEquals('success',result);
    }
    
    @isTest static void uploadEmptyFiles(){
        Test.startTest();
        String result = core_S2S_FileUploadCaseCtrl.uploadFiles('5007j00000H8GIkAAN','');
        Test.stopTest();
        system.assertEquals('record Id is Blank',result);
    }
    
    @IsTest
    static void testUploadFiles_Exception() {
        
        Test.startTest();
        try {
            String invalidFileDataJson = '{ "invalidField": "value" }';
            core_S2S_FileUploadCaseCtrl.uploadFiles('5007j00000H8GIkAAN', invalidFileDataJson);
            System.assert(false, 'Exception should have been thrown');
        } catch (Exception ex) {
            System.assertEquals('Script-thrown exception', ex.getMessage());
        }
        Test.stopTest();
    }
}