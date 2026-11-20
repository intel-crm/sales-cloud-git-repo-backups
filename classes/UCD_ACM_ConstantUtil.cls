public without sharing class UCD_ACM_ConstantUtil {
    
    public static final Id acctRTIntel =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(String.valueOf(System.Label.PRM_Intel_Account)).getRecordTypeId();
    public static final Id acctRTECD =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(String.valueOf(System.Label.Core_End_Customer_Deal_Account)).getRecordTypeId();
    public static final Id acctRTInactive =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(String.valueOf(System.Label.Core_Inactive_Account)).getRecordTypeId();
    public static final Id acctRTRejected =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(String.valueOf(System.Label.Core_Rejected_Account)).getRecordTypeId();
    public static final Id acctRTRequested = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(String.valueOf(System.Label.Core_Requested_Account)).getRecordTypeId();

}