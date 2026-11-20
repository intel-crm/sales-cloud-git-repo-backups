/*********************************************************************************************************************
Apex Class Name  : PRM_IPA_Constants
Version       : 1.0
Created Date  : JAN 2022
Function      : Utility class to store common keywords related to IPA

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* Aravind                  06/01/2022               Utility class to store common keywords related to IPA

*********************************************************************************************************************/
public class PRM_IPA_Constants {
    public static final String CALLOUT_TYPE_OUTBOUND = 'Outbound';
    public static final String CALLOUT_TYPE_INBOUND = 'Inbound';
    public static final String MODULE_SELF_REGISTRATION = 'Self Registration';
    public static final String MODULE_ADMIN_REGISTRATION = 'Admin Registration';
    public static final String MODULE_OPID = 'OPID';
    public static final String MODULE_ONDEMAND_OPID = 'OnDemand OPID';
    public static final String SYSTEM_NAME_AGS = 'AGS';
    public static final String SYSTEM_NAME_AEM = 'AEM';
    public static final String SYSTEM_NAME_ERPM = 'ERPM';
    public static final String SYSTEM_NAME_CIM = 'CIM';
    public static final String PRM_EMAIL_VERIFICATION_REQUEST = 'PRM_Email_Verification_Request';
    public static final String PRM_ACCOUNT_CREATE_REQUEST = 'Account_Create_Request';
    public static final String PRICING_TENDER_PGM_CHANNEL = 'Intel Quote Request';
    public static final Id ACCOUNT_CREATE_REQUEST_RT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(PRM_ACCOUNT_CREATE_REQUEST).getRecordTypeId();
    public static final Id CONTACT_RECORD_TYPE_ID = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
    public static final Id EV_RECORD_TYPE_ID =  Schema.SObjectType.PRM_Registration_Request__c.getRecordTypeInfosByDeveloperName().get(PRM_EMAIL_VERIFICATION_REQUEST).getRecordTypeId();
    public static final Id ADMIN_REGISTRATION_RT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Admin_Registration).getRecordTypeId();
    public static final String Authorization = 'Authorization';
    public static final String Bearer = 'Bearer ';

}