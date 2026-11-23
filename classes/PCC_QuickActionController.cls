public class PCC_QuickActionController {
    @AuraEnabled
    public static DDRResponse approveQuickAction(String recordId){
        DDRResponse drresp = new DDRResponse();
        
        Core_Design_Registration_Product__c productRecord = [SELECT Id, Core_Design_Registration_Id__r.Core_Design_Registration_Status_Nm__c,Core_Design_Registration_Id__r.Core_Vertical_Market_Nm__c,Core_Design_Registration_Id__r.Core_Product_Segment_Nm__c, Core_Design_Registration_Id__r.Core_Product_Application_Nm__c,Core_Design_Registration_Id__r.Core_Intel_Platform_Nm__c,Core_Design_Registration_Id__r.Core_Design_Registration_Nm__c  FROM Core_Design_Registration_Product__c WHERE Core_Design_Registration_Id__c =:recordId AND Core_Active_Status__c = false AND Core_Locked_Ind__c = false AND Core_Design_Product_Status_Nm__c ='Pending' limit 1];
        if(productRecord.Core_Design_Registration_Id__r.Core_Design_Registration_Status_Nm__c =='Approved'){
            drresp.registrationIsApproved = true;
            return drresp;
        }
        Opportunity optRecord = [SELECT Id,Name From Opportunity WHERE Name =:productRecord.Core_Design_Registration_Id__r.Core_Design_Registration_Nm__c limit 1];
        
        
        return drresp;
    }
    
    public static void getPicklistValues(){
        
    }
    
    public class DDRResponse{
        @AuraEnabled public boolean registrationIsApproved{get;set;}
    }
    
}