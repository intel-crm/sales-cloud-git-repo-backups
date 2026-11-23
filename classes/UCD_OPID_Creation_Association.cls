public with sharing class UCD_OPID_Creation_Association {
    @AuraEnabled(cacheable=true)
    public static String getMessageFromApex(Id recordId) {
        List<Core_Account_Group_Member__c> agm = New List<Core_Account_Group_Member__c>();
        agm = [Select id, Core_Inactive_Ind__c,Core_Intel_Account_Id__c,Core_Intel_Partner_Alliance_PartnerGroup__c,Intel_Record_Type_Text__c,Core_MDA_Ind__c,Core_Partner_Account_Id__c,Primary_Account__c From Core_Account_Group_Member__c Where Core_Intel_Account_Id__c =:recordId AND Core_Inactive_Ind__c = false AND Core_Intel_Partner_Alliance_PartnerGroup__c = true];
        System.debug('agm-->'+agm);
        if(agm != null && !agm.IsEmpty()){
            return 'Please deactivate the existing OPID association to create a new OPID association';
        }
        else{
            return 'Please select the OPID associate or go ahead with new OPID creation';
        }
        
        
    }
}