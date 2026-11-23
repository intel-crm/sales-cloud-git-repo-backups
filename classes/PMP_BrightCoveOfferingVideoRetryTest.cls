/****************************************************************************************************************************************
* Class Name  : PMP_BrightCoveOfferingVideoRetryTest 
* Version     : 1.0 
* Created Date: 04/04/2022   
* Modification Log :
* Developer                       Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Yashasvi Aggarwal            04/04/2022                   Test class for PMP_BrightCoveOfferingVideoRetryBatch
* ****************************************************************************************************************************************/
@isTest
public class PMP_BrightCoveOfferingVideoRetryTest {
    @isTest
    static void testIsWorking() {
        Boolean result = PMP_BrightCoveOfferingVideoRetryBatch.isWorking();
        System.assertEquals(true, result);
    }
//IPA2.0 - As part of TWC729-7977 commented the entire class
/*
    @testSetup static void setup() {
        // Create common test accounts
        Account acc1 = PMP_TestDataUtility.createIntelAccount('TestAccount1', PMP_TestDataUtility.intel_Account_Record_Type, true);
        //Contact con1 = PMP_TestDataUtility.createContact(acc1.id,true);
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        //Account acc2 = PMP_TestDataUtility.createAccount('TestPartnerAccount1', devRecordTypeId, true);
        PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompany1', acc1.Id, true);
        cmp1.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;
        update cmp1;
        PMP_OPID_MPI_Rel__c jun= new PMP_OPID_MPI_Rel__c();
        jun.PMP_One_Partner_ID__c= acc1.Id;
        jun.PMP_Marketing_Profile_Id__c= cmp1.Id;
        jun.Is_Active__c=true;     
        insert jun;                       
        PMP_Partner_Offering__c videOffering = PMP_TestDataUtility.createOffering('TestVideoOffering','Public Content', 
                                                                                 'TestVideoOffering',cmp1.Id, true,'Admin Review','');
        List<PMP_Partner_Offering_Resource__c> addOfferingResources = new List<PMP_Partner_Offering_Resource__c>();
        String contentDocumentId;
        List<contentDocument> contentDocs = PMP_TestDataUtility.createContentDocument(true);
        List<ContentDocumentLink> cdl = new List<ContentDocumentLink>();
        for(contentDocument cd : contentDocs){
            cdl.add(PMP_TestDataUtility.createContentDocumentLink(videOffering.Id, cd.Id));
            contentDocumentId=cd.Id;
        }
        PMP_Partner_Offering_Resource__c videoResource1 = PMP_TestDataUtility.createOfferingResourceInstance('IntelVideo1','',videOffering.Id,'Video','');
        videoResource1.PMP_BrightCoveVideoAccountID__c=String.valueOf(PMP_Utility.getValue('PMP_BrightCoveAccountID'));
        videoResource1.PMP_Partner_Offering_Image__c=contentDocumentId;
        videoResource1.PMP_Integration_Status_Nm__c='Aborted';
        videoResource1.PMP_BrightCove_Video_Extension_Txt__c='.mp4';
         
        PMP_Partner_Offering_Resource__c videoResource2 = PMP_TestDataUtility.createOfferingResourceInstance('IntelVideo2','',videOffering.Id,'Video','');
        videoResource2.PMP_BrightCoveVideoAccountID__c=String.valueOf(PMP_Utility.getValue('PMP_BrightCoveAccountID'));
        videoResource2.PMP_Partner_Offering_Image__c=contentDocumentId;
        videoResource2.PMP_BrightCoveVideoId__c='6303298970001';
        videoResource2.PMP_Integration_Status_Nm__c='Aborted';
        videoResource2.PMP_BrightCove_Video_Extension_Txt__c='.mp4';
         
        PMP_Partner_Offering_Resource__c videoResource3 = PMP_TestDataUtility.createOfferingResourceInstance('IntelVideo3','',videOffering.Id,'Video','');
        videoResource3.PMP_BrightCoveVideoAccountID__c=String.valueOf(PMP_Utility.getValue('PMP_BrightCoveAccountID'));
        videoResource3.PMP_Partner_Offering_Image__c=contentDocumentId;
        videoResource3.PMP_BrightCoveVideoId__c='6303298970001';
        videoResource3.PMP_BrightCoveVideoJobId__c='87b8d307-c6ec-448b-bb88-cc65a33d01b8';
        videoResource3.PMP_Integration_Status_Nm__c='Aborted';
        videoResource3.PMP_BrightCove_Video_Extension_Txt__c='.mp4';
         
        PMP_Partner_Offering_Resource__c videoResource4 = PMP_TestDataUtility.createOfferingResourceInstance('IntelVideo4','',videOffering.Id,'Video','');
        videoResource4.PMP_BrightCoveVideoAccountID__c=String.valueOf(PMP_Utility.getValue('PMP_BrightCoveAccountID'));
        videoResource4.PMP_Partner_Offering_Image__c=contentDocumentId;
        videoResource4.PMP_BrightCoveVideoId__c='6303298970001';
        videoResource4.PMP_BrightCoveVideoJobId__c='87b8d307-c6ec-448b-bb88-cc65a33d01b8';
        videoResource4.PMP_BrightCoveVideoThumbnail_URL__c='https://cf-images.us-east-1.prod.boltdns.net/v1/jit/6298977448001/bdd27b50-d632-4d73-ac96-44bb8686f3c7/main/160x90/19s29ms/match/image.jpg';
        videoResource4.PMP_Integration_Status_Nm__c='Aborted';
        videoResource4.PMP_BrightCove_Video_Extension_Txt__c='.mp4';
         
        PMP_Partner_Offering_Resource__c videoResource5 = PMP_TestDataUtility.createOfferingResourceInstance('IntelVideo5','',videOffering.Id,'Video','');
        videoResource5.PMP_BrightCoveVideoAccountID__c=String.valueOf(PMP_Utility.getValue('PMP_BrightCoveAccountID'));
        videoResource5.PMP_Partner_Offering_Image__c=contentDocumentId;
        videoResource5.PMP_BrightCoveVideoId__c='6303298970001';
        videoResource5.PMP_BrightCoveVideoJobId__c='87b8d307-c6ec-448b-bb88-cc65a33d01b8';
        videoResource5.PMP_BrightCoveVideoThumbnail_URL__c='https://cf-images.us-east-1.prod.boltdns.net/v1/jit/6298977448001/bdd27b50-d632-4d73-ac96-44bb8686f3c7/main/160x90/19s29ms/match/image.jpg';
        videoResource5.PMP_Integration_Status_Nm__c='Aborted';
        videoResource5.PMP_Delete_BrightCove_Video_Ind__c=true;
        videoResource5.PMP_BrightCove_Video_Extension_Txt__c='.mp4';
        videoResource5.PMP_Integration_Status_Reason_Txt__c=system.label.PMP_Integration_Delete_Video_Msg;
         
        addOfferingResources.add(videoResource1);
        addOfferingResources.add(videoResource2);
        addOfferingResources.add(videoResource3);
        addOfferingResources.add(videoResource4);
        addOfferingResources.add(videoResource5);
    
        if(addOfferingResources != null){
            insert addOfferingResources;
        }
     }
    @isTest
    public static void executeBatchMethodOfferingTest1()
    {   
        PMP_Partner_Offering__c testVideoOffering = [select id from PMP_Partner_Offering__c where Name=:'TestVideoOffering' Limit 1];
        PMP_Partner_Offering_Resource__c videoResource1 = [select id,PMP_Partner_Offering_Image__c,PMP_Resource_Description_Txt__c from PMP_Partner_Offering_Resource__c where 
                                                          PMP_Offering_Id__c=:testVideoOffering.id and Name=:'IntelVideo1' Limit 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PMP_BrightCoveVideoMockResponseTest('200','')); 
        Database.executebatch(new PMP_BrightCoveOfferingVideoRetryBatch(videoResource1.id),1);
        Test.stopTest();
    }
    @isTest
    public static void executeBatchMethodOfferingTest2()
    {   
        PMP_Partner_Offering__c testVideoOffering = [select id from PMP_Partner_Offering__c where Name=:'TestVideoOffering' Limit 1];
        PMP_Partner_Offering_Resource__c videoResource2 = [select id,PMP_Partner_Offering_Image__c,PMP_Resource_Description_Txt__c from PMP_Partner_Offering_Resource__c where 
                                                           PMP_Offering_Id__c=:testVideoOffering.id and Name=:'IntelVideo2' Limit 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PMP_BrightCoveVideoMockResponseTest('200','')); 
        Database.executebatch(new PMP_BrightCoveOfferingVideoRetryBatch(videoResource2.id),1);
        Test.stopTest();
    }
    @isTest
    public static void executeBatchMethodOfferingTest3()
    {   
        PMP_Partner_Offering__c testVideoOffering = [select id from PMP_Partner_Offering__c where Name=:'TestVideoOffering' Limit 1];
        PMP_Partner_Offering_Resource__c videoResource3 = [select id,PMP_Partner_Offering_Image__c,PMP_Resource_Description_Txt__c from PMP_Partner_Offering_Resource__c where 
                                                           PMP_Offering_Id__c=:testVideoOffering.id and Name=:'IntelVideo3' Limit 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PMP_BrightCoveVideoMockResponseTest('200','')); 
        Database.executebatch(new PMP_BrightCoveOfferingVideoRetryBatch(videoResource3.id),1);
        Test.stopTest();
    }
    @isTest
    public static void executeBatchMethodOfferingTest4()
    {   
        PMP_Partner_Offering__c testVideoOffering = [select id from PMP_Partner_Offering__c where Name=:'TestVideoOffering' Limit 1];
        PMP_Partner_Offering_Resource__c videoResource4 = [select id,PMP_Partner_Offering_Image__c,PMP_Resource_Description_Txt__c from PMP_Partner_Offering_Resource__c where 
                                                           PMP_Offering_Id__c=:testVideoOffering.id and Name=:'IntelVideo4' Limit 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PMP_BrightCoveVideoMockResponseTest('200','')); 
        Database.executebatch(new PMP_BrightCoveOfferingVideoRetryBatch(videoResource4.id),1);
        Test.stopTest();
    }
    @isTest
    public static void executeBatchMethodOfferingTest5()
    {   
        PMP_Partner_Offering__c testVideoOffering = [select id from PMP_Partner_Offering__c where Name=:'TestVideoOffering' Limit 1];
        PMP_Partner_Offering_Resource__c videoResource5 = [select id,PMP_Partner_Offering_Image__c,PMP_Resource_Description_Txt__c from PMP_Partner_Offering_Resource__c where 
                                                           PMP_Offering_Id__c=:testVideoOffering.id and Name=:'IntelVideo5' Limit 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PMP_BrightCoveVideoMockResponseTest('200','')); 
        Database.executebatch(new PMP_BrightCoveOfferingVideoRetryBatch(videoResource5.id),1);
        Test.stopTest();
    }
*/
}