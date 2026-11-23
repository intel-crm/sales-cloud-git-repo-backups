/****************************************************************************************************************************************
* Class Name  : PMP_GenerateDQReportStorefrontBatchTest 
* Version     : 1.0 
* Created Date: 22/08/2022   
* Modification Log :
* Developer                       Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Yashasvi Aggarwal            22/08/2022                   Test class for PMP_GenerateDQReportStorefrontBatch
* ****************************************************************************************************************************************/
@isTest
public class PMP_GenerateDQReportStorefrontBatchTest {
     @testSetup static void setup() {
        // Create common test accounts
        Account acc1 = PMP_TestDataUtility.createIntelAccount('TestAccount1', PMP_TestDataUtility.intel_Account_Record_Type, true);
        Contact con1 = PMP_TestDataUtility.createContact(acc1.id,true);
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Account acc2 = PMP_TestDataUtility.createAccount('TestPartnerAccount1', devRecordTypeId, true);
        PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompany1', acc1.Id, true);
        cmp1.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;
        cmp1.PMP_Company_Lifecycle_Status_Nm__c='Published';
        update cmp1;
        PMP_Company__c cmp2 = PMP_TestDataUtility.createCompanyInformation('TestCompany2', acc1.Id, true);
        cmp2.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;
        cmp2.PMP_Company_Lifecycle_Status_Nm__c='Draft';
        update cmp2;
        PMP_OPID_MPI_Rel__c jun= new PMP_OPID_MPI_Rel__c();
        jun.PMP_One_Partner_ID__c= acc1.Id;
        jun.PMP_Marketing_Profile_Id__c= cmp1.Id;
        jun.Is_Active__c=true;     
        insert jun;      
         //IPA2.0:US-4497-1631_OfferingEOL
        /*PMP_Partner_Offering__c videOffering = PMP_TestDataUtility.createOffering('TestVideoOffering','Public Content', 
                                                                                 'TestVideoOffering',cmp1.Id, true,'Admin Review','');
        List<PMP_Partner_Offering_Resource__c> addOfferingResources = new List<PMP_Partner_Offering_Resource__c>();
        String contentDocumentId;
        List<contentDocument> contentDocs = PMP_TestDataUtility.createContentDocument(true);
        List<ContentDocumentLink> cdl = new List<ContentDocumentLink>();
        for(contentDocument cd : contentDocs){
            cdl.add(PMP_TestDataUtility.createContentDocumentLink(videOffering.Id, cd.Id));
            contentDocumentId=cd.Id;
        }*/
     }
    @isTest
    public static void executeBatchMethodOfferingTest()
    {   
         Test.startTest();
         Id batchProcessId = Database.executebatch(new PMP_GenerateDQReportStorefrontBatch());
         system.assertNotEquals(batchProcessId,Null);
         Test.stopTest();
    }
}