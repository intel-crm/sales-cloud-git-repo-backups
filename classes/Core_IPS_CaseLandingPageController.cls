/*
 * Class Name : Core_IPS_CaseLandingPageController
 * Test class Name : Core_IPS_CaseLandingPageControllerTest
 * 
 */

public class Core_IPS_CaseLandingPageController {
    
    @AuraEnabled
    public static String getStandardActionRedirectionURL(String actionStr, String objectStr, String profileStr, String recTypeName) {
        String uniqueCode = actionStr + '$' + objectStr + '$' + profileStr + '$' + recTypeName;
        String urlStr = '';
        String uniqueKey;
        Map<String, String> actionRedirectUrl = new Map<String, String>();
        for(StandardActionRedirection__C sAction: StandardActionRedirection__C.getAll().values()) {
            uniqueKey = sAction.Action__c + '$' + sAction.Object__c + '$' + sAction.Profile_del__c + '$' + sAction.Record_Type__c;
            uniqueKey = uniqueKey.toLowerCase();
			actionRedirectUrl.put(uniqueKey, sAction.URI__c); 
        }
        urlStr = actionRedirectUrl.get(uniqueCode.toLowerCase());
        return urlStr;
    }
    
    @AuraEnabled
    public static Map<Id, String> getCaseRecordTypeIds() {
        Map<Id, String> recordTypeIdNameMap = new Map<Id, String>();
        Schema.DescribeSObjectResult dsr = Case.SObjectType.getDescribe();
            Schema.RecordTypeInfo defaultRecordType;
            for(Schema.RecordTypeInfo rti : dsr.getRecordTypeInfos()) {
                recordTypeIdNameMap.put(rti.recordTypeId, rti.developername);
            }
        return recordTypeIdNameMap;
    }
}