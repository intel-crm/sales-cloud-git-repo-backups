/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-04-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class PBI_Embed_Class {
    @AuraEnabled(cacheable=true)
    public static boolean checkAccess(id accountID){
        boolean result= false;
        List<Account_Revenue__c> acc = [select id from Account_Revenue__c where Account__c =: accountID WITH SECURITY_ENFORCED];
        result = acc.size()>0?true:false;
        return result;
    }
}