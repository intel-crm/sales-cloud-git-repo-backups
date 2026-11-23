/*
* Original Method author and date : Harshal Gosavi, 4th August 2021
* Moved From Core_AccountTriggerHandletController and new Class Created
* New Class Created By : swarupx.kumar.singh@intel.com, 27th Feb 2023
* Updated By: Pravitha V, 9/9/2024 - Included Intel Account and Inactive Account RTs and introduced hierarchy fields change criteria for PE trigger
*/

public class ACM_AU_TriggerPlatformEventOnUpdate implements UCD_ACM_ServiceContracts.IAfterUpdateAccountTrigger {
    public static Boolean platformRunOnce = true;
    private static Id rejAcctRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Label.Core_Rejected_Account).getRecordTypeId();
    private static Id intelAcctRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Label.PRM_Intel_Account).getRecordTypeId();
    private static Id endCustAcctRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Label.Core_End_Customer_Deal_Account).getRecordTypeId();
    private static Id inactiveAcctRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Label.Core_Inactive_Account).getRecordTypeId(); 
    
    public void execute(UCD_ACM_UnitOfWork unitOfWork, Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts) {
        if(platformRunOnce) {
            try {
                triggerPlatformEventOnUpdate(unitOfWork, oldAccounts, newAccounts);
            } catch(exception ex) {
                UCD_ACM_Logger.error('ACM_AU_TriggerPlatformEventOnUpdate','execute',ex.getMessage() +  '==>' + ex.getStackTraceString(),null);
            }
        }        
    }
    
    private void triggerPlatformEventOnUpdate(UCD_ACM_UnitOfWork unitOfWork, Map<Id,Account> oldAccounts, Map<Id, Account> newAccounts) {
        if(newAccounts != null && oldAccounts != null) {
            Set<Id> accountIds = new Set<Id>();
            For(Account acc: newAccounts.values()) {
                if(isChangeValidForPublish(oldAccounts, acc)) {
                    accountIds.add(acc.Id);
                }
            }
            if (accountIds.size() > 0) {
                UCD_ACM_Common.updateACMIntegrationMessage(unitOfWork, accountIds);
                platformRunOnce = false;
            }
        }
    }

    /**
     * Publish criterias:
     * 1. MyDeals/IQR accounts getting rejected
     * 2. Defined attribute changes to End Customer Accounts & Intel Account
     * 3. Account changing to Inactive Account
     */
    private Boolean isChangeValidForPublish(Map<Id,Account> oldAccounts, Account acct) {
        Account oldAcct = oldAccounts.get(acct.Id);
        Id oldRTId = oldAcct.RecordTypeId;
        String vistexSource = System.Label.VistexAccountSources;
        return (acct.Core_Customer_Aggregation_Type__c != null && acct.Core_Business_Party_Id__c != null &&
            ((acct.RecordTypeId == rejAcctRTId && oldRTId != acct.RecordTypeId && vistexSource.Contains(acct.Core_Account_Reference_Source_Name__c))
            || ((acct.RecordTypeId == endCustAcctRTId || acct.RecordTypeId == intelAcctRTId) 
                && ((acct.Core_Customer_Aggregation_Type__c != oldAcct.Core_Customer_Aggregation_Type__c)
                    || (acct.Core_Survivor_Account_Id__c != oldAcct.Core_Survivor_Account_Id__c)
                    || (acct.Core_Business_Party_Id__c != oldAcct.Core_Business_Party_Id__c)
                    || (acct.Core_Data_Simplified_Account_Nm__c != oldAcct.Core_Data_Simplified_Account_Nm__c)
                    || (String.isNotBlank(acct.Core_Data_Simplified_Account_Nm__c) && String.isNotBlank(oldAcct.Core_Data_Simplified_Account_Nm__c) && !(acct.Core_Data_Simplified_Account_Nm__c.equals(oldAcct.Core_Data_Simplified_Account_Nm__c)))
                    || (acct.RecordTypeId != oldRTId)
                    || (acct.BillingCountry != oldAcct.BillingCountry)
                    || (acct.ShippingCountry != oldAcct.ShippingCountry)
                    || (acct.parentId != oldAcct.parentId)
                    || (acct.Core_Data_Country_Nm__c != oldAcct.Core_Data_Country_Nm__c)
                    || (acct.Core_Account_Request_Rejection_Reason__c != oldAcct.Core_Account_Request_Rejection_Reason__c)
                    || (acct.Core_Account_Request_Rejection_Notes__c != oldAcct.Core_Account_Request_Rejection_Notes__c)
                    || (acct.Core_Parent_Data_Simplified_Account_Nm__c != oldAcct.Core_Parent_Data_Simplified_Account_Nm__c)
                    || (String.isNotBlank(acct.Core_Parent_Data_Simplified_Account_Nm__c) && String.isNotBlank(oldAcct.Core_Parent_Data_Simplified_Account_Nm__c) && !(acct.Core_Parent_Data_Simplified_Account_Nm__c.equals(oldAcct.Core_Parent_Data_Simplified_Account_Nm__c)))
                    || (acct.Core_Parent_Business_Party_Id__c != oldAcct.Core_Parent_Business_Party_Id__c)
                    || (acct.Core_Unified_Global_Customer_BP_Id__c != oldAcct.Core_Unified_Global_Customer_BP_Id__c)
                    || (acct.Core_Unified_Global_Customer_Name__c != oldAcct.Core_Unified_Global_Customer_Name__c)
                    || (acct.Core_Unified_Intermediate_Customer_BP_Id__c != oldAcct.Core_Unified_Intermediate_Customer_BP_Id__c)
                    || (acct.Core_Unified_Intermediate_Customer_Name__c != oldAcct.Core_Unified_Intermediate_Customer_Name__c)
                    || (acct.Core_Unified_Intermdt_Customer_2_BP_Id__c != oldAcct.Core_Unified_Intermdt_Customer_2_BP_Id__c)
                    || (acct.Core_Unified_Intermdt_Customer_2_Name__c != oldAcct.Core_Unified_Intermdt_Customer_2_Name__c)
                    || (Label.UCD_ACM_Switch_IAO_Change == 'true' && (acct.Core_Compliance_Watch_List_Type__c != oldAcct.Core_Compliance_Watch_List_Type__c || acct.Core_Compliance_Status__c!=oldAcct.Core_Compliance_Status__c))
                    || (Label.UCD_ACM_Switch_IAO_Change == 'false' && (acct.Core_Compliance_Watch_List_Type__c != oldAcct.Core_Compliance_Watch_List_Type__c))
                    || (acct.Name != oldAcct.Name)))
            || (acct.RecordTypeId == inactiveAcctRTId && acct.RecordTypeId != oldRTId)));
    }
}