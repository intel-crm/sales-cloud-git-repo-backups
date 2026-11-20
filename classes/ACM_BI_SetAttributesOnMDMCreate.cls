/**
 * Class to assign account attributes such as Recordtype, Name, OwnerId when accounts created from Reltio MDM system
 * Author - chethan.s.kunder@intel.com
 * Date - 21 Feb 2023
 */ 
public without sharing class ACM_BI_SetAttributesOnMDMCreate implements UCD_ACM_ServiceContracts.IBeforeInsertAccountTrigger {
    static Boolean runOnce = true;

    /**
     * Public method for the class, this will be invoked from trigger handler
     */
    public void execute(List<Account> newAccounts) {

        try{
            if(runOnce){
                if(isValid() || Test.isRunningTest()){

                    setAttributes(newAccounts);
                    updateAccountAddress( newAccounts );

                }
            }
            runOnce = false;
        }catch(Exception ex){
            UCD_ACM_Logger.error('ACM_BI_SetAttributesOnMDMCreate','execute',ex.getMessage() +  '==>' + ex.getStackTraceString(),null);
        }

    }

    /**
     * Method for validation
     */
    private Boolean isValid() {
        return userInfo.getUserId() == Label.UCD_ACM_ReltioUser;
    }

    /**
     * Method to set account attributes before creating
     */
    private void setAttributes(List<Account> newAccounts) {

        Id rejAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Rejected_Account').getRecordTypeId();
        Id dealAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('End_Customer_Deal_Account').getRecordTypeId();

            for (Account account : newAccounts) {
                account.OwnerId =  System.Label.Core_UncoveredAccount_UserId;
                account.RecordTypeId = rejAccountRTId;
                account.Name = account.Core_Data_Simplified_Account_Nm__c;
                account.Core_Sales_Groups__c = null;
                if (account.Core_MDM_Status__c == 'APRV') {
                    account.RecordTypeId = dealAccountRTId;                    
                }
            }
 
    }


    /*
     * description : Update Billing Address.
     * params : List<Account> accounts
     * return : NA
     * author and date : harshalx.sunil.gosavi@intel.com, 08/12/2021
    */

    public static void updateAccountAddress(List < Account > accounts) { 
        if( accounts != null ){

            For(Account account: accounts) {
                if (String.isNOtBlank( account.Core_Customer_Aggregation_Type__c ) && String.isNotBlank( account.Core_Data_Country_Nm__c )) {

                    if (String.isBlank( account.BillingCountryCode )) {
                        account.BillingCountryCode = UCD_ACM_Utils.validateCountryName(account.Core_Data_Country_Nm__c);
                    }
                    if (String.isBlank( account.ShippingCountryCode )) {
                        account.ShippingCountryCode = UCD_ACM_Utils.validateCountryName(account.Core_Data_Country_Nm__c);
                    }

                }
            }

        }
    }
}