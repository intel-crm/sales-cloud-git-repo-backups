@isTest
public class PMP_RichMediaAssetTriggerHelperTest {
    
    public static testmethod void callrichmediadownloadtest(){
        List<PMP_Rich_Media_Asset_Stage__c> testrecordlist = new List<PMP_Rich_Media_Asset_Stage__c>();
        PMP_Rich_Media_Asset_Stage__c rma = new PMP_Rich_Media_Asset_Stage__c();
        rma.PMP_Document_Download_Path_url__c = 'https://example.test.com';
        rma.PMP_Document_Name_Nm__c = 'test Doc';
        rma.PMP_Document_Id__c ='123';
        rma.PMP_Document_Type_Txt__c = 'PDF';
        rma.PMP_Is_Retrieved_Ind__c = false;
        rma.PMP_ReTrigger_Ind__c = false;
        rma.PMP_PDF_Updated_Dt__c = System.now();
        rma.PMP_Document_Path_Txt__c = 'https://builders-staging.onsumaye.com/marketplaceapi/slapi/v1/document/ 98314276214627134202710629077394/508095026dd62';
        testrecordlist.add(rma);
        insert testrecordlist;
        testrecordlist[0].PMP_PDF_Updated_Dt__c = System.now()+1;
        testrecordlist[0].PMP_Is_Retrieved_Ind__c = true;
        testrecordlist[0].PMP_ReTrigger_Ind__c = true;
        update testrecordlist;
        Map<Id,PMP_Rich_Media_Asset_Stage__c> testrecordmap = new  Map<Id,PMP_Rich_Media_Asset_Stage__c>(testrecordlist);
        Test.startTest();
        PMP_RichMediaAssetTriggerHelper.callrichmediadownload(testrecordmap,testrecordlist);
        PMP_RichMediaAssetTriggerHelper.oldPdfUpdateDateCapture(testrecordmap,testrecordlist);
        Test.stopTest();
    }
}