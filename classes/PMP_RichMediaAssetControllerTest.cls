@isTest
public class PMP_RichMediaAssetControllerTest {
    
    //Method -1 Company Search
    @testsetup
    static void testSetup(){
        PMP_Company__c comp = new PMP_Company__c();
        comp.Name = 'Adlink';
        comp.PMP_Account_Industry__c = 'Agriculture';
        comp.PMP_Company_Information_Language_Nm__c = PMP_StaticConstants_Partner.English;
        comp.PMP_Account_Dsc__c = 'test Desc';
        comp.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
        comp.PMP_Account_Tag_Line__c = 'test tagline';
        //comp.PMP_Account_Specialty__c = 'Cloud Data Center Specialist';
        comp.PMP_Partner_Benefit_Type__c = 'Solutions Marketplace Basic Profile';
        comp.PMP_Partner_Segment_Nm__c = 'Client Computing';
        comp.PMP_Partner_Program_nm__c = 'Manufacturer';
        comp.PMP_Disti_Sys_Solutions_Nm__c = 'Data Center';
        comp.PMP_Benefit_Update_Ind__c = false;
        comp.PMP_Is_Working_Copy_Ind__c = false;
        insert comp;
        
        PMP_Rich_Media_Asset_Stage__c testrecord = new PMP_Rich_Media_Asset_Stage__c();
        testrecord.PMP_Document_Name_Nm__c = 'Test Document';
        testrecord.PMP_Document_Id__c = '1234';
        testrecord.PMP_Document_Type_Txt__c = 'Solution Brief';
        testrecord.PMP_Document_Path_Txt__c = 'Path';
        testrecord.PMP_Partner_Name_Nm__c = 'Dell AMC';
        testrecord.PMP_Added_On_Dt__c = System.now();
        testrecord.PMP_Document_Description_Dsc__c = 'Test Document';
        testrecord.PMP_Document_Download_Path_url__c = 'https://testurl.com';
        testrecord.PMP_Is_Retrieved_Ind__c = true;
        insert testrecord;
        
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S';
        conVer.PathOnClient = 'application.pdf';
        conVer.Title = 'Test Document';
        conVer.VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body');
        conVer.IsAssetEnabled = true;
        conVer.IsMajorVersion = false;
        conVer.Description = 'test Description';
        insert conVer;
        
    }
    public static testmethod void getCompanyListTest(){  
        String key = 'Adlink';
        Test.startTest();
        PMP_RichMediaAssetController.getCompanyList(key);
        Test.stopTest();
    }
    
    //Method -2 OfferingSearch
    // public static testmethod void getOfferingsonPartnersTest(){
        
    //     List<PMP_Company__c> comp = [Select Id from PMP_Company__c];
    //     PMP_Partner_Offering__c offering1 = PMP_SearchTestDataFactory.createOffering('TestOffering','Public Content', 
    //                                                                                  'TestOffering',comp[0].Id, true,'Published','test tagline');
    //     offering1.PMP_Partner_Offering_Start_Dt__c = System.today()-2;
    //     offering1.PMP_Partner_Offering_End_Dt__c = System.today()+2;
    //     offering1.PMP_Is_Not_Available_On_MP_Ind__c = false;
    //     update offering1;
    //     String id = comp[0].Id;
    //     Test.startTest();
    //     PMP_RichMediaAssetController.getOfferingsonPartners(id);
    //     Test.stopTest();
    // }
    
    //Method -3 assetSaveOperation
    //  public static testmethod void assetSaveOperationTest(){
    //     List<ContentVersion> cvlist = [Select Id from ContentVersion];
    //     List<PMP_Rich_Media_Asset_Stage__c> rmalist = [Select Id from PMP_Rich_Media_Asset_Stage__c];
    //     List<PMP_Company__c> comp = [Select Id from PMP_Company__c];
    //     PMP_Partner_Offering__c offering1 = PMP_SearchTestDataFactory.createOffering('TestOffering','Public Content', 
    //                                                                                  'TestOffering',comp[0].Id, true,'Published','test tagline');
    //     PMP_Partner_Offering__c offering2 = PMP_SearchTestDataFactory.createOffering('TestOfferingWorkingCopy','Public Content', 
    //                                                                                  'TestOffering',comp[0].Id, true,'Approved','test tagline');
    //     offering1.PMP_Partner_Offering_Start_Dt__c = System.today()-2;
    //     offering1.PMP_Partner_Offering_End_Dt__c = System.today()+2;
    //     offering1.PMP_Is_Not_Available_On_MP_Ind__c = false;
    //     offering1.PMP_Working_Copy_Id__c = offering2.Id;
    //     update offering1;
    //     List<PMP_Partner_Offering__c> selectedRecords = new List<PMP_Partner_Offering__c>();
    //     selectedRecords.add(offering1);
         
    //     ContentDocumentLink conDocLink = new ContentDocumentLink();
    //     Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cvlist[0].Id].ContentDocumentId;
    //     conDocLink.LinkedEntityId = rmalist[0].Id;
    //     conDocLink.ContentDocumentId = conDoc;
    //     conDocLink.shareType = 'V';
    //     conDocLink.Visibility = 'AllUsers';
    //     insert conDocLink;
         
    //     Test.startTest();
    //     //PMP_RichMediaAssetController.assetSaveOperation(rmalist[0].Id, selectedRecords);
    //     Test.stopTest();
    // }
    
    //Method 4 - OfferingResourceDescTruncate
   /* public static testmethod void offeringResourceDescriptionTurncateTest() {
        String des = 'Prodapt is working with Intel® and other leading Open Virtual Exchange partners to develop the Network Edge Accelerator Test (NEAT) lab for fast edge compute deployment and orchestration Prodapt is working with Intel® and other leading Open Virtual Exchange';
        String des1 = 'Prodapt is working with Intel® and other leading Open Virtual Exchange partners to develop the Network Edge Accelerator Test (NEAT) lab for fast edge compute deployment and orchestration Prodapt is working with Intel® and other leading Open Virtual Excha n';
        Integer maxsize = 255;
        Test.startTest();
        PMP_RichMediaAssetController.offeringResourceDescriptionTurncate(des,maxsize);
        PMP_RichMediaAssetController.offeringResourceDescriptionTurncate(des1,maxsize);
        Test.stopTest();
    }*/
}