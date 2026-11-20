@isTest
public class PMP_RetryFailedCalloutBatch_Test {
    
    @testSetup
    static void setup(){
        List<ID> contentDocumentIds = new List<ID>();
        list<contentDocument> docs = PMP_TestDataUtility.createContentDocument(true);
        for(contentDocument cd : docs){
            contentDocumentIds.add(cd.Id);
        }
        
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId = :contentDocumentIds[0] LIMIT 1];
        
        /*ContentDistribution cd = new ContentDistribution(Name='test0', ContentVersionId=contentVersion_2.Id);
        insert cd;*/
        
        // System.debug('contentDocumentId-->'+contentDocumentIds);
        /*List<ContentDistribution> distributionData = [SELECT Id, Name, ContentVersionId, ContentDocumentId, RelatedRecordId, 
                                                        DistributionPublicUrl, ContentDownloadUrl FROM ContentDistribution 
                                                        WHERE ContentDocumentId IN :contentDocumentIds];*/
        
        Core_Log_Failed_Callout_Entry__c logEntry = new Core_Log_Failed_Callout_Entry__c ();
        logEntry.Core_sObjectId__c = contentDocumentIds[0]; 
        //IPA2.0:US-4497-1631_OfferingEOL
        //logEntry.Core_Origin__c = 'PMP_ImageResizeService';
        logEntry.Core_Origin__c = 'PMP_CompanyImageResizeService';
        logEntry.Core_Project__c = 'PMP';
        //logEntry.Core_Object_Name__c = 'PMP_Partner_Offering_Resource__c';
		logEntry.Core_Object_Name__c = 'PMP_Company_Resource__c';
        logEntry.Core_Status__c = 'Investigating';
        logEntry.Core_Entry_Time__c = System.Now(); 
        logEntry.Core_Retry_Count__c = Integer.valueOf(PMP_Utility.getValue('Thumbnail_Retry_Callout_Max_Limit'));      
        insert logEntry;
    }
    static testMethod void testMethod1(){
        Test.startTest();
        PMP_RetryFailedCalloutBatch obj = new PMP_RetryFailedCalloutBatch();
        ID batchprocessid = Database.executeBatch(obj);
        
        system.assertNotEquals(batchprocessid,Null);
        Test.stopTest(); 
    }
}