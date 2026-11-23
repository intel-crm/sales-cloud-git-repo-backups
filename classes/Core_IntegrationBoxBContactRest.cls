@RestResource(urlMapping='/BoxB/Contact')
global class Core_IntegrationBoxBContactRest {
    @HttpGet
    global static Core_IntegrationUtility.BoxB_ContactWrapper generateBoxBContactOutboundMessage() {
        String contactId = RestContext.request.params.get('contactId');
        String enterpriseId = RestContext.request.params.get('enterpriseId');
        Contact c;
        List<Contact>  lstContacts;
        if(!String.isBlank(contactId)) {
            c = [SELECT Id, Core_Enterprise_Id__c,Core_Login_Id__c,AccountId,FirstName,LastName,Core_English_Only_First_Name__c,
                     Core_English_Only_Last_Name__c,Email,Phone,Account.Name,MailingCountry,Core_Job_Function__c,Core_Deactivated__c,
                     CreatedDate,LastModifiedDate,Account.Core_CIM_ID__c
                     FROM Contact 
                     WHERE Id=:contactId];
        } else {
            lstContacts = [SELECT Id, Core_Enterprise_Id__c,Core_Login_Id__c,AccountId,FirstName,LastName,Core_English_Only_First_Name__c,
                     Core_English_Only_Last_Name__c,Email,Phone,Account.Name,MailingCountry,Core_Job_Function__c,Core_Deactivated__c,
                     CreatedDate,LastModifiedDate,Account.Core_CIM_ID__c
                     FROM Contact 
                     WHERE Core_Enterprise_Id__c=:enterpriseId];
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
            b.EXTRN_LGN_ID      = c.Core_Login_Id__c;
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
            b.CIMID             = c.Account.Core_CIM_ID__c;
            b.ACCT_NM           = c.Account.Name;
            
            return b;
          
        } else if(lstContacts != null && lstContacts.size() > 0) {
            c = lstContacts[0];
            Core_IntegrationUtility.BoxB_ContactWrapper b = new Core_IntegrationUtility.BoxB_ContactWrapper();
            b.CST_ID            = c.Core_Enterprise_Id__c;
            b.INTRNL_LGN_ID     = '';
            b.EXTRN_LGN_ID      = c.Core_Login_Id__c;
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
            b.CIMID             = c.Account.Core_CIM_ID__c;
            b.ACCT_NM           = c.Account.Name;
            
            return b;
        }
        RestResponse res = RestContext.response;
        res.statusCode = 404;
        return null;
    }
}