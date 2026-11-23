@RestResource(urlMapping='/BoxB/Account')
global class Core_IntegrationBoxBAccountRest {
	@HttpGet
    global static Core_Entitlement_Outbound_Integrations.BoxB_AccountWrapper generateBoxBAccountOutboundMessage() {
        String accountId = RestContext.request.params.get('accountId');
        Account acctObj = [SELECT Id, Core_CIM_ID_Old__c,Core_Account_Legal_Name__c, BillingCountry, 
                           Core_Geo__c, Name, Core_English_Only_Name__c, Core_CNDA_Number__c, Core_Deactivated__c, 
                           CreatedDate, LastModifiedDate, Core_CIM_ID__c 
                           FROM Account 
                           WHERE Id=:accountId];
        if(acctObj != null) {
            Core_Entitlement_Outbound_Integrations.BoxB_AccountWrapper baw = new Core_Entitlement_Outbound_Integrations.BoxB_AccountWrapper();
            baw.ACCT_ID = acctObj.Id;
            baw.ORG_MSTR_NM = acctObj.Core_Account_Legal_Name__c;
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
            baw.CIMID = acctObj.Core_CIM_ID__c;
            baw.CIMID_OLD = acctObj.Core_CIM_ID_Old__c;
            baw.CNDA_NBR = acctObj.Core_CNDA_Number__c;
            
            String strJSON = JSON.serialize(baw);
            
            /*Core_Integration_Outbound_Message__c outboundMsg = new Core_Integration_Outbound_Message__c();
            outboundMsg.Core_MessageType__c = 'BoxB Account';
            outboundMsg.Core_Payload__c ='<![CDATA[' +  strJSON + ']]>';*/
            
            return baw;
        }
        return null;        
    }  
}