public with sharing class Sales_GenerateTemporaryLicense {
    @AuraEnabled
    public static Boolean validateTemporaryNICId(Id hostRecordId){
        boolean isValid = false;
        for(Sales_License__c salesLicenseRec :[SELECT Id,Sales_License_Expiration_Date_Dt__c,Sales_License_Host_Node_Id__c,Sales_Tool_License_Type__c,Sales_License_Available_Temp_Licenses__c,Sales_License_Host_Node_Id__r.Temporary_NIC_ID__c 
                                               FROM Sales_License__c WHERE Sales_License_Host_Node_Id__c =: hostRecordId]){
                                                   if((salesLicenseRec.id != null) &&
                                                      (salesLicenseRec.Sales_Tool_License_Type__c == 'NEUTRAL' || salesLicenseRec.Sales_Tool_License_Type__c =='N-A' || salesLicenseRec.Sales_Tool_License_Type__c == 'FLOAT' ) 
                                                      && (salesLicenseRec.Sales_License_Host_Node_Id__r.Temporary_NIC_ID__c != null)&& (salesLicenseRec.Sales_License_Available_Temp_Licenses__c!=null && salesLicenseRec.Sales_License_Available_Temp_Licenses__c>0)){
                                                          isValid=true;
                                                      }                                                    
                                               }
        return isValid;
    }
}