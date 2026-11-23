public without sharing class UCD_ACM_RecordTypeHandler {

    public void updateRecordTypeForRequestedAccount(List<Account> newAccounts) {
        try{
            if(userInfo.getUserName() == 'ucd_reltio_connector_user@intel.com.crm.crmdevint3') {

                Id intelRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
                Id ecdRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('End_Customer_Deal_Account').getRecordTypeId();
                Id rejectedRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Rejected_Account').getRecordTypeId();

                for(Account accountRecord : newAccounts) {
                    if((accountRecord.Core_Customer_Process_Engg__c == 'SLS_PPLN' 
                        || accountRecord.Core_Customer_Process_Engg__c == 'DIR_PRC_EXCPT'
                        || accountRecord.Core_Customer_Process_Engg__c == 'SLS_PPLN')
                        && accountRecord.Core_Account_Reference_Source_Name__c == 'Opportunity Management') {

                        accountRecord.RecordTypeId = intelRecordTypeId;

                    } else if((accountRecord.Core_Account_Reference_Source_Name__c == 'IQR'
                                || accountRecord.Core_Account_Reference_Source_Name__c == 'MyDeals'
                                || accountRecord.Core_Account_Reference_Source_Name__c == 'UCD')
                                && accountRecord.Core_Is_Duplicate__c == null) {
                        
                        accountRecord.RecordTypeId = ecdRecordTypeId;
                        
                    } else if((accountRecord.Core_Account_Reference_Source_Name__c == 'IQR'
                                || accountRecord.Core_Account_Reference_Source_Name__c == 'MyDeals'
                                || accountRecord.Core_Account_Reference_Source_Name__c == 'UCD')
                                && accountRecord.Core_Is_Duplicate__c != null) {
                
                        accountRecord.RecordTypeId = rejectedRecordTypeId;
                
                    }
                }
            }

        } catch(Exception ex) {
            System.debug('Record Type Exception '+ex);
            //Core_MDF_CCP_UtilityClass.logError(ex);
        }
    }
}