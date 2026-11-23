/**
* Class to set account attributes(attributes which can not be included in connector mapping due to technical reasons), when account is updated via Reltio
* Author - chethan.s.kunder@intel.com
* Date - 02 Mar 2023
*/ 
public without sharing class ACM_BU_SetAttributesOnMDMUpdate implements UCD_ACM_ServiceContracts.IBeforeUpdateAccountTrigger {
    static boolean runOnce = true;
    Id intelRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
    Id requestedRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Requested_Account').getRecordTypeId();
    Id dealAcctRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('End_Customer_Deal_Account').getRecordTypeId();
    Id rejectedAcctId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(String.valueOf(System.Label.Core_Rejected_Account)).getRecordTypeId();
    
    
    /**
* Public method for the class, this will be invoked from trigger handler
*/
    public void execute(Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts) {
        try {
            // Run the logic only once and after all validations are completed
            if (runOnce && (isValid() || Test.isRunningTest())) {
                setAttributes(newAccounts,oldAccounts);
                geoAndSubgeoMapping(newAccounts);
                setCountryandStateCode(newAccounts);
                //setAddressMapping(newAccounts);
            }
            runOnce = false;
        } catch (Exception ex) {
            UCD_ACM_Logger.error('ACM_BU_SetAttributesOnMDMUpdate','execute',ex.getMessage() +  '==>' + ex.getStackTraceString(),null);
            
        }
    }
    
    /**
* Method to add validations
*/
    private Boolean isValid() {
        return userInfo.getUserId() == Label.UCD_ACM_ReltioUser;
    }
    
    /**
* Method to set account attributes before updating
*/
    private void setAttributes(Map<Id, Account> newAccounts,Map<Id,Account> oldAccounts) {
        Map<String, Account_Create_Process_Mapping__mdt> processBySource = UCD_ACM_Utils.getAccountProcessMappingBySourceName(); 
        for(Account account : newAccounts.values()) {            
            if(String.isNotEmpty(account.Core_Account_Reference_Source_Name__c)
               && processBySource.containsKey(account.Core_Account_Reference_Source_Name__c)
               && processBySource.get(account.Core_Account_Reference_Source_Name__c).Set_MDM_Name__c
               && String.isNotEmpty(account.Core_Data_Simplified_Account_Nm__c) 
               && oldAccounts.get(account.Id).RecordTypeId==requestedRecordTypeId) {
                   account.Name = account.Core_Data_Simplified_Account_Nm__c;
               }
            if(account.Core_Customer_Aggregation_Type__c == 'UNFD_GLBL_CUST')
            {
                account.ParentId = null;
            }
            if(Schema.sObjectType.Account.fields.Core_Data_Country_Nm__c.isUpdateable() && account.Core_Customer_Aggregation_Type__c == 'UNFD_LOC_CUST' && String.isNotBlank(account.Core_MDM_Location_Country_Nm__c))
            {
                account.Core_Data_Country_Nm__c = account.Core_MDM_Location_Country_Nm__c;
            }
        }                  
    }
    /*
** Method to update geo and subgeo fields
*/
    private void geoAndSubgeoMapping(Map<Id, Account> newAccounts){
        
        for(Account account : newAccounts.values()) {                
            if((account.RecordTypeId == intelRecordTypeId ||account.RecordTypeId == requestedRecordTypeId) && account.BillingCountryCode != null){
                
                account.Core_Geo__c	 = UCD_ACM_Utils.getGeoforCountry(account.BillingCountryCode);
                account.Core_Sub_Geo__c = 	UCD_ACM_Utils.getSubGeoforCountry(account.BillingCountryCode);
            }
        }
    }
    
    /*
Method to set Country and State Code
*/
    private void setCountryandStateCode(Map<Id, Account> newAccounts) {
        Map<String,String> countryCodeByCountryName = new Map<String,String>();
        Id inactiveRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Inactive_Account').getRecordTypeId();
        for(Account account : newAccounts.values()) {
            if((account.RecordTypeId == intelRecordTypeId || account.RecordTypeId == inactiveRecordTypeId ||account.RecordTypeId == dealAcctRTId || account.RecordTypeId == rejectedAcctId) && String.isNotBlank(account.Core_MDM_Location_Country_Nm__c)) {                
                String mdmCountryName = account.Core_MDM_Location_Country_Nm__c;
                
                if(countryCodeByCountryName.isEmpty()) {
                    countryCodeByCountryName = UCD_ACM_Utils.getCountryCodeByName();
                }
                account.BillingCountryCode = countryCodeByCountryName.get(mdmCountryName);                   
            } 
        }    
    }
    
    /*
Method to Map Physical address for Country and Location Aggregation Type
*/
   /* private void setAddressMapping(Map<Id, Account> newAccounts) {
        
        for(Account account : newAccounts.values()) {
            if(account.Core_Customer_Aggregation_Type__c=='UNFD_CTRY_CUST' ||account.Core_Customer_Aggregation_Type__c=='UNFD_LOC_CUST')
            {
                account.Core_Unified_Customer_Address__Street__s=account.Core_Unified_Secondary_Address__Street__s;
                account.Core_Unified_Customer_Address__City__s=account.Core_Unified_Secondary_Address__City__s;
                account.Core_Unified_Customer_Address__PostalCode__s=account.Core_Unified_Secondary_Address__PostalCode__s;
                
            }
        }
    }*/
}