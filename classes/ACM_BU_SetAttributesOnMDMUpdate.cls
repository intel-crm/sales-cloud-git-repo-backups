/**
 * Class to set account attributes(attributes which can not be included in connector mapping due to technical reasons), when account is updated via Reltio
 * Author - chethan.s.kunder@intel.com
 * Date - 02 Mar 2023
 */ 
public without sharing class ACM_BU_SetAttributesOnMDMUpdate implements UCD_ACM_ServiceContracts.IBeforeUpdateAccountTrigger {
    static boolean runOnce = true;
    Id intelRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
    Id requestedRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Requested_Account').getRecordTypeId();


    /**
     * Public method for the class, this will be invoked from trigger handler
     */
    public void execute(Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts) {
        System.debug('setMDM%%%***10');
        try {
        // Run the logic only once and after all validations are completed
            if (runOnce && (isValid() || Test.isRunningTest())) {
                System.debug('MDM Update@@@%%%');
                setAttributes(newAccounts,oldAccounts);
                geoAndSubgeoMapping(newAccounts);
                setCountryandStateCode(newAccounts);
            }
            runOnce = false;
        } catch (Exception ex) {
         //   System.debug('Issue in class - ACM_BU_SetAttributesOnMDMUpdate. Error ###'+ ex.getMessage());
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
        System.debug('setattributes@@@%%%'+newAccounts);
        System.debug('old valuesaccounts@@@%%%'+oldAccounts);
        Map<String, Account_Create_Process_Mapping__mdt> processBySource = UCD_ACM_Utils.getAccountProcessMappingBySourceName();
        System.debug('processBySource@@%%'+processBySource);     
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
                System.debug('aggregarion@@@%%%'+account.Core_Customer_Aggregation_Type__c);
                account.ParentId = null;
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
        Map<String, Map<String,String>> stateNameAndCodeByCountry = new Map<String, Map<String,String>>();
        Id inactiveRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Inactive_Account').getRecordTypeId();

        for(Account account : newAccounts.values()) {
            if((account.RecordTypeId == intelRecordTypeId || account.RecordTypeId == inactiveRecordTypeId)) {                
            String mdmCountryName=(account.Core_Customer_Aggregation_Type__c=='UNFD_GLBL_CUST' ||account.Core_Customer_Aggregation_Type__c=='UNFD_INTRMD_CUST')? account.Core_MDM_Location_Country_Nm__c:((account.Core_Customer_Aggregation_Type__c == 'UNFD_COUNTRY_CUST' || account.Core_Customer_Aggregation_Type__c == 'UNFD_LOCATION_CUST') ? account.Core_MDM_Secondary_Country_Nm__c:null);
            String mdmStateCode=(account.Core_Customer_Aggregation_Type__c=='UNFD_GLBL_CUST' ||account.Core_Customer_Aggregation_Type__c=='UNFD_INTRMD_CUST')? account.Core_MDM_Location_State_Nm__c:((account.Core_Customer_Aggregation_Type__c == 'UNFD_COUNTRY_CUST' || account.Core_Customer_Aggregation_Type__c == 'UNFD_LOCATION_CUST') ? account.Core_MDM_Secondary_State_Cd__c:null);

            if(String.isNotBlank(mdmCountryName)) {
                if(countryCodeByCountryName.isEmpty()) {
                    countryCodeByCountryName = UCD_ACM_Utils.getCountryCodeByName();
                }
                account.Core_Unified_Customer_Address__CountryCode__s = countryCodeByCountryName.get(mdmCountryName);              
            }
            if(stateNameAndCodeByCountry.isEmpty()) {
                stateNameAndCodeByCountry = UCD_ACM_Utils.getGlobalPickList();
            }
            if(String.isNotBlank(mdmStateCode) && mdmStateCode.contains('_') && String.isNotBlank(account.Core_Unified_Customer_Address__CountryCode__s) && stateNameAndCodeByCountry.get(String.valueOf(account.Core_Unified_Customer_Address__CountryCode__s)).get(String.valueOf(mdmStateCode.split('_')[1])) != null) {
                account.Core_Unified_Customer_Address__StateCode__s = mdmStateCode.split('_')[1];      
            }
         }
        }
    }
}