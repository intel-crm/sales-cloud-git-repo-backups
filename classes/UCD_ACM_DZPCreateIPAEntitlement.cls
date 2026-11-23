public with sharing class UCD_ACM_DZPCreateIPAEntitlement {
    @invocableMethod
    public static void UCD_ACM_DZPCreateIPAEntitlement(List<PRM_Bulk_Data_Upload__c> dataLoad) {
        Map<String,PRM_Bulk_Data_Upload__c> dataLoadMap = new Map<String,PRM_Bulk_Data_Upload__c>();
        for(PRM_Bulk_Data_Upload__c loadRec : dataLoad){
            dataLoadMap.put(loadRec.PRM_ContactEmail__c, loadRec);

        }
        PRM_Contact_Bulk_DataLoad_Utility.processContactRecords(dataLoadMap);
    }
}