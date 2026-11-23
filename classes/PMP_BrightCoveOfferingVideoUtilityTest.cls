/****************************************************************************************************************************************
* Class Name  : PMP_BrightCoveOfferingVideoUtilityTest 
* Version     : 1.0 
* Created Date: 04/04/2022   
* Modification Log :
* Developer                       Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Yashasvi Aggarwal            04/04/2022                   Test class for PMP_BrightCoveOfferingVideoStatusUtility
* ****************************************************************************************************************************************/
@isTest
public class PMP_BrightCoveOfferingVideoUtilityTest {
//      @testSetup static void setup() {
//         // Create common test accounts
//         Account acc1 = PMP_TestDataUtility.createIntelAccount('TestAccount1', PMP_TestDataUtility.intel_Account_Record_Type, true);
//         Contact con1 = PMP_TestDataUtility.createContact(acc1.id,true);
//         Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
//         Account acc2 = PMP_TestDataUtility.createAccount('TestPartnerAccount1', devRecordTypeId, true);
//         PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompany1', acc1.Id, true);
//         cmp1.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;
//         update cmp1;
//         PMP_OPID_MPI_Rel__c jun= new PMP_OPID_MPI_Rel__c();
//         jun.PMP_One_Partner_ID__c= acc1.Id;
//         jun.PMP_Marketing_Profile_Id__c= cmp1.Id;
//         jun.Is_Active__c=true;     
//         insert jun;                       
//         PMP_Partner_Offering__c videOffering = PMP_TestDataUtility.createOffering('TestVideoOffering','Public Content', 
//                                                                                  'TestVideoOffering',cmp1.Id, true,'Admin Review','');
//         List<PMP_Partner_Offering_Resource__c> addOfferingResources = new List<PMP_Partner_Offering_Resource__c>();
//         String contentDocumentId;
//         List<contentDocument> contentDocs = PMP_TestDataUtility.createContentDocument(true);
//         List<ContentDocumentLink> cdl = new List<ContentDocumentLink>();
//         for(contentDocument cd : contentDocs){
//             cdl.add(PMP_TestDataUtility.createContentDocumentLink(videOffering.Id, cd.Id));
//             contentDocumentId=cd.Id;
//         }
//         PMP_Partner_Offering_Resource__c videoResource = PMP_TestDataUtility.createOfferingResourceInstance('IntelVideo','',videOffering.Id,'Video','');
//         videoResource.PMP_BrightCoveVideoAccountID__c=String.valueOf(PMP_Utility.getValue('PMP_BrightCoveAccountID'));
//         videoResource.PMP_Partner_Offering_Image__c=contentDocumentId;
//         videoResource.PMP_BrightCoveVideoId__c='6302734001001';
//         videoResource.PMP_BrightCoveVideoJobId__c='87b8d307-c6ec-448b-bb88-cc65a33d01b8';
//         addOfferingResources.add(videoResource);
        
//         if(addOfferingResources != null){
//             insert addOfferingResources;
//         }
//      }
    
//    /* @isTest
//     public static void finishedVideoJobIdStatusTest()
//     {   
//         PMP_Partner_Offering__c testVideoOffering = [select id from PMP_Partner_Offering__c where Name=:'TestVideoOffering' Limit 1];
//         PMP_Partner_Offering_Resource__c videoResource = [select id,PMP_Partner_Offering_Image__c,PMP_Resource_Description_Txt__c from PMP_Partner_Offering_Resource__c where PMP_Offering_Id__c=:testVideoOffering.id Limit 1];
//         Test.startTest();
//         Test.setMock(HttpCalloutMock.class, new PMP_BrightCoveVideoMockResponseTest('200','finished')); 
//         PMP_BrightCoveOfferingVideoStatusUtility.checkVideoJobIdStatus(videoResource.id,testVideoOffering.id,'IntelVideo.mp4','6302734001001','87b8d307-c6ec-448b-bb88-cc65a33d01b8','test_token','Offering_Resource_Type');
//         Test.stopTest();
//     }*/
    
//     @isTest
//     public static void processingVideoJobIdStatusTest()
//     {   
//         PMP_Partner_Offering__c testVideoOffering = [select id from PMP_Partner_Offering__c where Name=:'TestVideoOffering' Limit 1];
//         PMP_Partner_Offering_Resource__c videoResource = [select id,PMP_Partner_Offering_Image__c,PMP_Resource_Description_Txt__c from PMP_Partner_Offering_Resource__c where PMP_Offering_Id__c=:testVideoOffering.id Limit 1];
// 		Map<String,String> videoIdMap =  new  Map<String,String>();
//         videoIdMap.put(videoResource.id,'IntelVideo.mp4'+'|'+'6302734001001');
//         Test.startTest();
//         Test.setMock(HttpCalloutMock.class, new PMP_BrightCoveVideoMockResponseTest('200','processing')); 
//         //PMP_BrightCoveOfferingVideoStatusUtility.checkVideoJobIdStatus(videoResource.id,testVideoOffering.id,'IntelVideo.mp4','6302734001001','87b8d307-c6ec-448b-bb88-cc65a33d01b8','test_token','Offering_Resource_Type');
// 		PMP_BrightCoveOfferingVideoStatusUtility.getVideoThumnailURL(testVideoOffering.id, 'test_token', 'Offering_Resource_Type', videoIdMap);
//         PMP_BrightCoveOfferingVideoStatusUtility.handleErrorResponse('Offering_Resource_Type', videoIdMap, '6302734001001');
//         Test.stopTest();
//     }
    
//     /*@isTest
//     public static void failedVideoJobIdStatusTest()
//     {   
//         PMP_Partner_Offering__c testVideoOffering = [select id from PMP_Partner_Offering__c where Name=:'TestVideoOffering' Limit 1];
//         PMP_Partner_Offering_Resource__c videoResource = [select id,PMP_Partner_Offering_Image__c,PMP_Resource_Description_Txt__c from PMP_Partner_Offering_Resource__c where PMP_Offering_Id__c=:testVideoOffering.id Limit 1];
//         Test.startTest();
//         Test.setMock(HttpCalloutMock.class, new PMP_BrightCoveVideoMockResponseTest('200','failed')); 
//         PMP_BrightCoveOfferingVideoStatusUtility.checkVideoJobIdStatus(videoResource.id,testVideoOffering.id,'IntelVideo.mp4','6302734001001','87b8d307-c6ec-448b-bb88-cc65a33d01b8','test_token','Offering_Resource_Type');
//         Test.stopTest();
//     }*/
//     @isTest
//     public static void errorVideoJobIdStatusTest()
//     {   
//         PMP_Partner_Offering__c testVideoOffering = [select id from PMP_Partner_Offering__c where Name=:'TestVideoOffering' Limit 1];
//         PMP_Partner_Offering_Resource__c videoResource = [select id,PMP_Partner_Offering_Image__c,PMP_Resource_Description_Txt__c from PMP_Partner_Offering_Resource__c where PMP_Offering_Id__c=:testVideoOffering.id Limit 1];
//         Test.startTest();
//         Test.setMock(HttpCalloutMock.class, new PMP_BrightCoveVideoMockResponseTest('210','failed')); 
//         PMP_BrightCoveOfferingVideoStatusUtility.checkVideoJobIdStatus(videoResource.id,testVideoOffering.id,'IntelVideo.mp4','6302734001001','87b8d307-c6ec-448b-bb88-cc65a33d01b8','test_token','Offering_Resource_Type');
//         Test.stopTest();
//     }
    
//     @isTest
//     public static void successDeleteBrightCoveVideoTest()
//     {   
//         PMP_Partner_Offering__c testVideoOffering = [select id from PMP_Partner_Offering__c where Name=:'TestVideoOffering' Limit 1];
//         PMP_Partner_Offering_Resource__c videoResource = [select id,PMP_Partner_Offering_Image__c,PMP_Resource_Description_Txt__c from PMP_Partner_Offering_Resource__c where PMP_Offering_Id__c=:testVideoOffering.id Limit 1];
//         Test.startTest();
//         Test.setMock(HttpCalloutMock.class, new PMP_BrightCoveVideoMockResponseTest('204',''));
//         PMP_BrightCoveOfferingVideoStatusUtility.deleteBrightCoveVideo(videoResource.id,testVideoOffering.id,'IntelVideo.mp4','6302734001001','test_token','Offering_Resource_Type');
//         Test.stopTest();
//     }
    
//     @isTest
//     public static void errorDeleteBrightCoveVideoTest()
//     {   
//         PMP_Partner_Offering__c testVideoOffering = [select id from PMP_Partner_Offering__c where Name=:'TestVideoOffering' Limit 1];
//         PMP_Partner_Offering_Resource__c videoResource = [select id,PMP_Partner_Offering_Image__c,PMP_Resource_Description_Txt__c from PMP_Partner_Offering_Resource__c where PMP_Offering_Id__c=:testVideoOffering.id Limit 1];
//         Test.startTest();
//         Test.setMock(HttpCalloutMock.class, new PMP_BrightCoveVideoMockResponseTest('210',''));
//         PMP_BrightCoveOfferingVideoStatusUtility.deleteBrightCoveVideo(videoResource.id,testVideoOffering.id,'IntelVideo.mp4','6302734001001','test_token','Offering_Resource_Type');
//         Test.stopTest();
//     }
   
//     @isTest
//     public static void performDMLWhenFailedInVideoJobIdOfferingTest()
//     {   
//         PMP_Partner_Offering__c testVideoOffering = [select id from PMP_Partner_Offering__c where Name=:'TestVideoOffering' Limit 1];
//         PMP_Partner_Offering_Resource__c videoResource = [select id,PMP_Partner_Offering_Image__c,PMP_Resource_Description_Txt__c from PMP_Partner_Offering_Resource__c where PMP_Offering_Id__c=:testVideoOffering.id Limit 1];
//         Map<String,String> videoIdMap =  new  Map<String,String>();
//         videoIdMap.put(videoResource.id,'IntelVideo.mp4'+'|'+'6302734001001');
//         Test.startTest();  
//         PMP_BrightCoveOfferingVideoStatusUtility.performDMLWhenFailedInVideoJobIdOffering(videoIdMap,'Video Upload In Progress','checkVideoJobIdStatus');
//         PMP_BrightCoveOfferingVideoStatusUtility.performDMLWhenFailedInVideoJobIdOffering(videoIdMap,'Failed to get video thumbnail URL','getVideoThumnailURL'); 
//         PMP_BrightCoveOfferingVideoStatusUtility.performDMLWhenFailedInVideoJobIdOffering(videoIdMap,'Failed to delete video from BrightCove','deleteBrightCoveVideo'); 
//         Test.stopTest();
//     }
//      @isTest
//     public static void performDMLOfferingTest()
//     {   
//         PMP_Partner_Offering__c testVideoOffering = [select id from PMP_Partner_Offering__c where Name=:'TestVideoOffering' Limit 1];
//         PMP_Partner_Offering_Resource__c videoResource = [select id,PMP_Partner_Offering_Image__c,PMP_Resource_Description_Txt__c from PMP_Partner_Offering_Resource__c where PMP_Offering_Id__c=:testVideoOffering.id Limit 1];
//         Map<String,String> videoIdMap =  new  Map<String,String>();
//         videoIdMap.put(videoResource.id,'IntelVideo.mp4'+'|'+'6302734001001');
//         Test.startTest();  
//         PMP_BrightCoveOfferingVideoStatusUtility.performDMLOffering(videoIdMap,'deleteBrightCoveVideo');
//         Test.stopTest();
//     }
}