@RestResource(urlMapping='/BoxB/Contact')
global class Core_IntegrationBoxBContactRest {
    //   public static String dummyMethod1() {
    //     return null;
    // } 
    public static final string LOG_ENTRY_ORIGIN = 'GetBoxBcontacts';
    public static final String LOG_ENTRY_PROJECT = 'ACM';
    public static final String LOG_ENTRY_SCOPE = 'BoxBcontacts';
    public static final String LOG_ENTRY_INFO = 'info';
    public static final String LOG_ENTRY_OBJECT = 'Contact';
    public static final String LOG_ENTRY_ERROR = 'error';
    public static Map<String,Core_ACM_Control_Execution__c> mapIntegrationBoxBContactRest = Core_ACM_Control_Execution__c.getAll();

    @HttpGet
    global static Core_IntegrationUtility.BoxB_ContactWrapper generateBoxBContactOutboundMessage() {
        boolean hasError = false; 
        Exception exceptionObj = null;
        if(mapIntegrationBoxBContactRest.containsKey('IntegrationBoxBContactRest') && mapIntegrationBoxBContactRest.get('IntegrationBoxBContactRest').IsActive__c){
            try{
                String contactId = RestContext.request.params.get('contactId');
                String enterpriseId = RestContext.request.params.get('enterpriseId');
                Contact c;
                List<Contact>  lstContacts;
                if(!String.isBlank(contactId)) {
                    c = [SELECT Id, Core_Enterprise_Id__c,AccountId,FirstName,LastName,Core_English_Only_First_Name__c,
                            Core_English_Only_Last_Name__c,Email,Phone,Account.Name,MailingCountry,Core_Job_Function__c,Core_Deactivated__c,
                            CreatedDate,LastModifiedDate/*,Account.Core_CIM_ID__c*/
                            FROM Contact 
                            WHERE Id=:contactId WITH SECURITY_ENFORCED];
                } else {
                    lstContacts = [SELECT Id, Core_Enterprise_Id__c,AccountId,FirstName,LastName,Core_English_Only_First_Name__c,
                            Core_English_Only_Last_Name__c,Email,Phone,Account.Name,MailingCountry,Core_Job_Function__c,Core_Deactivated__c,
                            CreatedDate,LastModifiedDate/*,Account.Core_CIM_ID__c*/
                            FROM Contact 
                            WHERE Core_Enterprise_Id__c=:enterpriseId WITH SECURITY_ENFORCED];
                    if(lstContacts.size()>1) {
                        RestResponse res = RestContext.response;
                        res.statusCode = 300;
                        return null;
                    }
                }
                
                if(!String.isBlank(contactId) && c != null) {
                    Core_IntegrationUtility.BoxB_ContactWrapper b = new Core_IntegrationUtility.BoxB_ContactWrapper();
                    b.CST_ID            = c.Core_Enterprise_Id__c;
                    b.INTRNL_LGN_ID     = '';
                    b.EXTRN_LGN_ID      = '';
                    b.ACCT_ID           = c.AccountId;
                    b.FRST_NM           = c.FirstName;
                    b.LST_NM            = c.LastName;
                    b.ENG_FRST_NM       = c.Core_English_Only_First_Name__c;
                    b.ENG_LST_NM        = c.Core_English_Only_Last_Name__c;
                    b.EMAIL_ADDR_TXT    = c.Email;
                    b.PHN_ADDR_TXT      = c.Phone;
                    b.EXTRN_ORG_NM      = c.Account.Name;
                    b.CTRY_NM           = Core_Entitlement_Outbound_Integrations.getISO2CountryCode(c.MailingCountry);
                    b.USR_ACCT_SUSP_DTM = '';
                    b.PRI_OCCP_TTL_CD   = c.Core_Job_Function__c;
                    b.EBUS_AGT_STS_CD   = (c.Core_Deactivated__c ? 'inactive' : 'active'); // TO DO: Validate this logic with Jordan
                    b.CREATE_DT         = c.CreatedDate.date();
                    b.CHANGE_DTM        = c.LastModifiedDate;
                    b.CIMID             = null;
                    b.ACCT_NM           = c.Account.Name;
                    
                    return b;
                
                } else if(lstContacts != null && lstContacts.size() > 0) {
                    c = lstContacts[0];
                    Core_IntegrationUtility.BoxB_ContactWrapper b = new Core_IntegrationUtility.BoxB_ContactWrapper();
                    b.CST_ID            = c.Core_Enterprise_Id__c;
                    b.INTRNL_LGN_ID     = '';
                    b.EXTRN_LGN_ID      = '';
                    b.ACCT_ID           = c.AccountId;
                    b.FRST_NM           = c.FirstName;
                    b.LST_NM            = c.LastName;
                    b.ENG_FRST_NM       = c.Core_English_Only_First_Name__c;
                    b.ENG_LST_NM        = c.Core_English_Only_Last_Name__c;
                    b.EMAIL_ADDR_TXT    = c.Email;
                    b.PHN_ADDR_TXT      = c.Phone;
                    b.EXTRN_ORG_NM      = c.Account.Name;
                    b.CTRY_NM           = Core_Entitlement_Outbound_Integrations.getISO2CountryCode(c.MailingCountry);
                    b.USR_ACCT_SUSP_DTM = '';
                    b.PRI_OCCP_TTL_CD   = c.Core_Job_Function__c;
                    b.EBUS_AGT_STS_CD   = (c.Core_Deactivated__c ? 'inactive' : 'active'); // TO DO: Validate this logic with Jordan
                    b.CREATE_DT         = c.CreatedDate.date();
                    b.CHANGE_DTM        = c.LastModifiedDate;
                    b.CIMID             = null;
                    b.ACCT_NM           = c.Account.Name;
                    
                    return b;
                }
                RestResponse res = RestContext.response;
                res.statusCode = 404;
            }
            catch(Exception ex) {
                exceptionObj = ex;
                system.debug('Message'+ ex);  
                hasError = true;
            }
            finally{
                string LOG_ENTRY_SEVERITY = ( hasError == true ?  LOG_ENTRY_ERROR : LOG_ENTRY_INFO ); 
                string LOG_ENTRY_Message ='Records processed ';
                //Creating a Log Entry record
                Core_Log_Entry.core_Log_Entry(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE,LOG_ENTRY_SEVERITY, 
                                                    LOG_ENTRY_Message,'',null, LOG_ENTRY_OBJECT, '', exceptionObj);            
            }
        }
        return null;      
    }
}