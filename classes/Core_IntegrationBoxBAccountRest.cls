@RestResource(urlMapping='/BoxB/Account')
global without sharing class Core_IntegrationBoxBAccountRest {
    public static final string LOG_ENTRY_ORIGIN = 'GetBoxBAccount';
    public static final String LOG_ENTRY_PROJECT = 'ACM';
    public static final String LOG_ENTRY_SCOPE = 'BoxBAccount';
    public static final String LOG_ENTRY_INFO = 'info';
    public static final String LOG_ENTRY_OBJECT = 'Account';
    public static final String LOG_ENTRY_ERROR = 'error';
    public static string LOG_ENTRY_SEVERITY;
    public static string LOG_ENTRY_Message;
    public static Map<String,Core_ACM_Control_Execution__c> mapIntegrationBoxBAccountRest = Core_ACM_Control_Execution__c.getAll();

    @HttpGet
    global static Core_Entitlement_Outbound_Integrations.BoxB_AccountWrapper generateBoxBAccountOutboundMessage() {
        boolean hasError = false; 
        Exception exceptionObj = null;
        if(mapIntegrationBoxBAccountRest.containsKey('IntegrationBoxBAccountRest') && mapIntegrationBoxBAccountRest.get('IntegrationBoxBAccountRest').IsActive__c){
            try{
                String accountId = RestContext.request.params.get('accountId');
                Account acctObj = [SELECT Id, /*Core_CIM_ID_Old__c,Core_Account_Legal_Name__c,*/ BillingCountry, 
                                Core_Geo__c, Name, Core_English_Only_Name__c, Core_CNDA_Number__c, Core_Deactivated__c, 
                                CreatedDate, LastModifiedDate, /*Core_CIM_ID__c,*/Core_RDC_Content_Restriction__c 
                                FROM Account 
                                WHERE Id=:accountId];
                if(acctObj != null) {
                    Core_Entitlement_Outbound_Integrations.BoxB_AccountWrapper baw = new Core_Entitlement_Outbound_Integrations.BoxB_AccountWrapper();
                    baw.ACCT_ID = acctObj.Id;
                    baw.ORG_MSTR_NM = null;
                    baw.CTRY_CD = Core_Entitlement_Outbound_Integrations.getISO2CountryCode(acctObj.BillingCountry);
                    baw.GEO_NM = acctObj.Core_Geo__c;
                    baw.ACCT_NM = acctObj.Name;
                    baw.ACCT_ENG_NM = acctObj.Core_English_Only_Name__c;
                    baw.RIALTO_ROL_ID = 'N/A';
                    baw.RIALTO_ROL_NM = 'N/A';
                    baw.CITR_ID = acctObj.Core_CNDA_Number__c;
                    baw.PROF_ORG_TY_CD = 'EXTRNORG';
                    if(acctObj.Core_Deactivated__c) {
                        baw.INACT_IND = 'Y';
                    } else {
                        baw.INACT_IND = 'N';       
                    }
                    baw.CREATE_DT = acctObj.CreatedDate;
                    baw.CHANGE_DT = acctObj.LastModifiedDate;
                    baw.CIMID = null;
                    baw.CIMID_OLD = null;
                    baw.CNDA_NBR = acctObj.Core_CNDA_Number__c;
                    baw.ACCT_RDC =acctObj.Core_RDC_Content_Restriction__c;  //US108564-Added this RDC flag for any Contacts entitled to RDC privileged access under this account.
                    String strJSON = JSON.serialize(baw);
                    
                    Core_Integration_Outbound_Message__c outboundMsg = new Core_Integration_Outbound_Message__c();
                    outboundMsg.Core_MessageType__c = 'BoxB Account';
                    outboundMsg.Core_Payload__c ='<![CDATA[' +  strJSON + ']]>';
                    return baw;
                }
        
            }
            catch(Exception ex) {
                exceptionObj = ex;  
                hasError = true;
            }
            finally{
                string LOG_ENTRY_SEVERITY = ( hasError == true ?  LOG_ENTRY_ERROR : LOG_ENTRY_INFO ); 
                string LOG_ENTRY_Message = 'Records processed';
                //Creating a Log Entry record
                Core_Log_Entry.core_Log_Entry(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE,LOG_ENTRY_SEVERITY, 
                                                    LOG_ENTRY_Message,'',null, LOG_ENTRY_OBJECT, '', exceptionObj);            
            }
        }      
        return null;        
    }  
}