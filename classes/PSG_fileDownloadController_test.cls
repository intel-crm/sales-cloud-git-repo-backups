/****************************************************************************************************
Apex Class Name : PSG_UtilityTest
Version         : 1.0 
Created Date    : 08/13/2021
Function        : Test class for PSG_Utility.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Shreyash             08/13/2021                Created
*****************************************************************************************************/
@isTest
public class PSG_fileDownloadController_test {
   /*
@isTest
    public static void contentDocumentTest(){
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        List<ContentDistribution> cdList = new List<ContentDistribution>();  
        cdList.add(new ContentDistribution(
                  ContentVersionId = cv.Id,
                  Name = cv.Title));
         insert cdList;
         List<ContentDistribution> cd = new List<ContentDistribution>([SELECT Name,ContentDownloadUrl FROM ContentDistribution]);  
         List<PSG_fileDownloadController.fileWrapper> downloadableFileList=new List<PSG_fileDownloadController.fileWrapper>();
         PSG_fileDownloadController.fileWrapper testlist=new PSG_fileDownloadController.fileWrapper(conDocId,cd[0].Name,cd[0].ContentDownloadUrl);
         System.assertEquals(testlist.fileTitle,cd[0].Name);
         Test.StartTest();
         try{
            downloadableFileList= PSG_fileDownloadController.getPdfDownloadLink();
         }
         catch(Exception ex){
            System.assertEquals('Script-thrown exception', ex.getMessage());
         }
         Test.StopTest();
    }*/
}