@isTest
public class PMP_RichMediaAssetDocDownloadTest {
    
    //Method 1 - Insert and Update Operation
    public static testmethod void InsertandUpdateRichMedia(){
        List<PMP_Rich_Media_Asset_Stage__c> testrecordlist = new List<PMP_Rich_Media_Asset_Stage__c>();
        PMP_Rich_Media_Asset_Stage__c rma = new PMP_Rich_Media_Asset_Stage__c();
        rma.PMP_Document_Download_Path_url__c = 'example/test';
        rma.PMP_Document_Name_Nm__c = 'test Doc';
        rma.PMP_Document_Id__c ='123';
        rma.PMP_Document_Type_Txt__c = 'PDF';
        rma.PMP_Document_Path_Txt__c = 'https://builders-staging.onsumaye.com/marketplaceapi/slapi/v1/document/ 98314276214627134202710629077394/508095026dd62';
        testrecordlist.add(rma);
        Test.startTest();
        //Testing Insert Scn Here
        insert testrecordlist;
        String modified = JSON.serialize(testrecordlist);
        PMP_RichMediaAssetDocDownload.fetchFileFromExternalUrl(modified);
        //Testing Update Scn Here
        testrecordlist[0].PMP_Document_Name_Nm__c ='Name Updated';
        String modifiedUpdate = JSON.serialize(testrecordlist);
        PMP_RichMediaAssetDocDownload.fetchFileFromExternalUrl(modifiedUpdate);
        Test.stopTest();  
    }

}