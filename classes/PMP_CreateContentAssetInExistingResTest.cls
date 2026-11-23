@isTest
private class PMP_CreateContentAssetInExistingResTest {
    
    static testMethod void executeContentAssetBatch() {
        
        // Insert Partner Offering record
        List<PMP_Partner_Offering_Resource__c> resourceList = new List<PMP_Partner_Offering_Resource__c>();
        PMP_Partner_Offering__c partnerOfferingRec = new PMP_Partner_Offering__c();
        insert partnerOfferingRec;
        
        //Insert the offering resource records and it to a list
        PMP_Partner_Offering_Resource__c resourceImageRec = new PMP_Partner_Offering_Resource__c();
        resourceImageRec.PMP_Resource_Type_Nm__c = 'Image';
        resourceImageRec.PMP_Offering_Id__c = partnerOfferingRec.Id;
        resourceList.add(resourceImageRec);
        insert resourceList;
        
        Test.startTest();
        PMP_CreateContentAssetInExistingResource bc = new PMP_CreateContentAssetInExistingResource();
        ID batchprocessid=database.executebatch(bc,30);
        Test.stopTest();
    }
}