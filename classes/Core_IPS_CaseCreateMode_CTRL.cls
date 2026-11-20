public with sharing class Core_IPS_CaseCreateMode_CTRL {
    public static List<Core_IPS_SSLCCase_DefaultData__c> casedef= new  List<Core_IPS_SSLCCase_DefaultData__c>();
    @AuraEnabled(cacheable=true)
    public static List<Core_IPS_SSLCCase_DefaultData__c> getCustomSettingLogs(){
        if (Schema.sObjectType.Core_IPS_SSLCCase_DefaultData__c.isAccessible()) {
            casedef = [SELECT Id, Name, Core_IPS_Default_Data__c, Core_IPS_Default_data_Id__c FROM Core_IPS_SSLCCase_DefaultData__c Limit 49999]; //Limit Added by Tushar
        }
        return casedef;
    }
}