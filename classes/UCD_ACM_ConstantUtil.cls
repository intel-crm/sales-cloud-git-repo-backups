public without sharing class UCD_ACM_ConstantUtil {
    
    public static final Id acctRTIntel =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(String.valueOf(System.Label.PRM_Intel_Account)).getRecordTypeId();
    public static final Id acctRTECD =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(String.valueOf(System.Label.Core_End_Customer_Deal_Account)).getRecordTypeId();
    public static final Id acctRTInactive =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(String.valueOf(System.Label.Core_Inactive_Account)).getRecordTypeId();
    public static final Id acctRTRejected =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(String.valueOf(System.Label.Core_Rejected_Account)).getRecordTypeId();
    public static final Id acctRTRequested = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(String.valueOf(System.Label.Core_Requested_Account)).getRecordTypeId();
    public static final Id acctRTComarketing = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Core_MDF_Co_Marketing_Record_Type_Name).getRecordTypeId();
    public static final Id acctRTPAG = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Partner_Account_Group_Record_Type).getRecordTypeId();
    public static final Id acctRTIntelUltimate =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(String.valueOf(System.Label.Core_Intel_Ultimate_Account)).getRecordTypeId();
    public static final Id acctRTBusinessPartner =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(String.valueOf(System.Label.Core_Business_Partner)).getRecordTypeId();


    //public static final Id reltioActionDeActivate ='DEACTIVATE';   
}