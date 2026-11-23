/****************************************************************************************************************************************
* Class Name  : PMP_BrightCoveOfferingVideoUploadTest 
* Version     : 1.0 
* Created Date: 04/04/2022   
* Modification Log :
* Developer                       Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Yashasvi Aggarwal            04/04/2022                   Test class for PMP_BrightCoveOfferingVideoUploadBatch
* ****************************************************************************************************************************************/
@isTest
public class PMP_BrightCoveOfferingVideoUploadTest {
    @isTest
    static void testIsWorking() {
        Boolean result = PMP_BrightCoveOfferingVideoUploadBatch.isWorking();
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
        PMP_Partner_Offering_Resource__c videoResource = PMP_TestDataUtility.createOfferingResourceInstance('IntelVideo','',videOffering.Id,'Video','');
        videoResource.PMP_BrightCoveVideoAccountID__c=String.valueOf(PMP_Utility.getValue('PMP_BrightCoveAccountID'));
        videoResource.PMP_Partner_Offering_Image__c=contentDocumentId;
        videoResource.PMP_BrightCove_Video_Extension_Txt__c='.mp4';
        addOfferingResources.add(videoResource);
        
        if(addOfferingResources != null){
            insert addOfferingResources;
        }
     }
    @isTest
    public static void executeBatchMethodOfferingTest()
    {   
         Test.startTest();
         Test.setMock(HttpCalloutMock.class, new PMP_BrightCoveVideoMockResponseTest('200','')); 
         Id batchProcessId = Database.executebatch(new PMP_BrightCoveOfferingVideoUploadBatch(),1);
         system.assertNotEquals(batchProcessId,Null);
         Test.stopTest();
    }
*/
}