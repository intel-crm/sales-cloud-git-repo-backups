/****************************************************************************************************************************************
* Class Name  : PMP_BrightCoveOfferingVideoStatusTest 
* Version     : 1.0 
* Created Date: 04/04/2022   
* Modification Log :
* Developer                       Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Yashasvi Aggarwal            04/04/2022                   Test class for PMP_BrightCoveOfferingVideoStatusBatch
* ****************************************************************************************************************************************/
@isTest
public class PMP_BrightCoveOfferingVideoStatusTest {
    //  @testSetup static void setup() {
    //     // Create common test accounts
    //     Account acc1 = PMP_TestDataUtility.createIntelAccount('TestAccount1', PMP_TestDataUtility.intel_Account_Record_Type, true);
    //     //Contact con1 = PMP_TestDataUtility.createContact(acc1.id,true);
    //     Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
    //     //Account acc2 = PMP_TestDataUtility.createAccount('TestPartnerAccount1', devRecordTypeId, true);
    //     PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompany1', acc1.Id, true);
    //     cmp1.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;
    //     update cmp1;
    //     PMP_OPID_MPI_Rel__c jun= new PMP_OPID_MPI_Rel__c();
    //     jun.PMP_One_Partner_ID__c= acc1.Id;
    //     jun.PMP_Marketing_Profile_Id__c= cmp1.Id;
    //     jun.Is_Active__c=true;     
    //     insert jun;                       
    //     PMP_Partner_Offering__c videOffering = PMP_TestDataUtility.createOffering('TestVideoOffering','Public Content', 
    //                                                                              'TestVideoOffering',cmp1.Id, true,'Approved','');
    //     List<PMP_Partner_Offering_Resource__c> addOfferingResources = new List<PMP_Partner_Offering_Resource__c>();
    //     String contentDocumentId;
    //     List<contentDocument> contentDocs = PMP_TestDataUtility.createContentDocument(true);
    //     List<ContentDocumentLink> cdl = new List<ContentDocumentLink>();
    //     for(contentDocument cd : contentDocs){
    //         cdl.add(PMP_TestDataUtility.createContentDocumentLink(videOffering.Id, cd.Id));
    //         contentDocumentId=cd.Id;
    //     }
         
    //     PMP_Partner_Offering_Resource__c deletedVideoResource = PMP_TestDataUtility.createOfferingResourceInstance('IntelVideoDelete','',videOffering.Id,'Video','');
    //     deletedVideoResource.PMP_BrightCoveVideoAccountID__c=String.valueOf(PMP_Utility.getValue('PMP_BrightCoveAccountID'));
    //     deletedVideoResource.PMP_Partner_Offering_Image__c=contentDocumentId;
    //     deletedVideoResource.PMP_BrightCoveVideoId__c='6302734001001';
    //     deletedVideoResource.PMP_BrightCoveVideoJobId__c='87b8d307-c6ec-448b-bb88-cc65a33d01b8';
    //     deletedVideoResource.PMP_Delete_BrightCove_Video_Ind__c=true;
    //     deletedVideoResource.PMP_Integration_Status_Reason_Txt__c=system.label.PMP_Integration_Delete_Video_Msg;
         
    //     addOfferingResources.add(deletedVideoResource);
    
         
    //     if(addOfferingResources != null){
    //         insert addOfferingResources;
    //     }
    //  }
    // @isTest
    // public static void executeBatchMethodOfferingTest()
    // {   
    //      Test.startTest();
    //      Test.setMock(HttpCalloutMock.class, new PMP_BrightCoveVideoMockResponseTest('204','')); 
    //      Id batchProcessId = Database.executebatch(new PMP_BrightCoveOfferingVideoStatusBatch(),1);
    //      system.assertNotEquals(batchProcessId,Null);
    //      Test.stopTest();
    // }
}