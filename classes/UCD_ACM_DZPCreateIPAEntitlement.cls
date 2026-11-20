public with sharing class UCD_ACM_DZPCreateIPAEntitlement {
    
    @invocableMethod
    public static void UCD_ACM_DZPCreateIPAEntitlement(List<PRM_Bulk_Data_Upload__c> dataLoad) {
        try{
            Map<String,PRM_Bulk_Data_Upload__c> dataLoadMap = new Map<String,PRM_Bulk_Data_Upload__c>();
            for(PRM_Bulk_Data_Upload__c loadRec : dataLoad){
                dataLoadMap.put(loadRec.PRM_ContactEmail__c, loadRec);
                
            }
            if(dataLoadMap.size() > 0){
                PRM_AcctContRel_TriggerHandlerNew.isDZPregistration = true;
                PRM_Contact_Bulk_DataLoad_Utility.processContactRecords(dataLoadMap);
            }
        }catch(Exception e){
            System.debug(e);	
        }
        // PRM_Contact_Bulk_DataLoad_Utility.processContactRecords(dataLoadMap);
    }
}