public with sharing class Core_IPS_ProductDetailCtrl_LWC {
    @AuraEnabled(cacheable=true)
    public static Asset getProduct(Id productId){
        try {
            Asset assetObj = [SELECT Id, Name, Core_IPS_Project_Name__c, core_Product_Application__c, Core_IPS_Support_License__c, Core_IPS_Project_Id__c, Status, Core_IPS_Project__r.Id, Core_IPS_Project__r.Name FROM ASSET WHERE Id =: productId];
            if(assetObj != null){
                return assetObj;
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled()
    public static List<Case> getCaseRecords(Integer offSetCount, String assetId) {
        try {
            List<Case> caseList = [SELECT id, CaseNumber, Core_Contact_Name__c, Subject, CreatedDate, Status FROM Case WHERE AssetId =: assetId ORDER BY CaseNumber ASC]; //AND Core_IPS_Premier_Support_Project_ID__c ='IPJ-006580'
            if(caseList != null){
                return caseList;
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}