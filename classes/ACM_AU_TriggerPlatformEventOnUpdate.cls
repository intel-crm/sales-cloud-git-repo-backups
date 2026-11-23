/*
* description : This Class check accounts record type and Cutomer Aggregation Type.
If account record type is 'Rejected' or 'End Customer' and Customer Aggregation Type is not blank
then Create/Update ACM_Integration_Message_Queue__c
* Original Method author and date : Harshal Gosavi, 4th August 2021
* Moved From Core_AccountTriggerHandletController and new Class Created
* New Class Created By : swarupx.kumar.singh@intel.com, 27th Feb 2023
*/
public class ACM_AU_TriggerPlatformEventOnUpdate implements UCD_ACM_ServiceContracts.IAfterUpdateAccountTrigger {
    
    private static Boolean runOnce = true;
    private static Id requestedAccountId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Requested Account').getRecordTypeId();
    private static Id rejectedAccount = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Rejected Account').getRecordTypeId();
    private static Id endCustomerRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('End Customer Deal Account').getRecordTypeId();
    private static Id IntelAccountId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
    private static UCD_ACM_SelectorContracts.IAccountQuerySelector accountQuerySelectorInstance = UCD_ACM_AccountQuerySelector.getInstance();
    private Boolean isValid() {
        return userInfo.getUserId() == Label.UCD_ACM_ReltioUser;
       //return true;
    }
    
    public void execute(UCD_ACM_UnitOfWork unitOfWork, Map<Id, Account> oldAccounts, Map<Id, Account> newAccounts) {
        if(runOnce && (isValid() || Test.isRunningTest())) {
            try {
                triggerPlatformEventOnUpdate(unitOfWork, oldAccounts, newAccounts);
            } catch(exception ex) {
                UCD_ACM_Logger.error('ACM_AU_TriggerPlatformEventOnUpdate','execute',ex.getMessage() +  '==>' + ex.getStackTraceString(),null);
            }
        }
        runOnce = false;
    }
    
    private void triggerPlatformEventOnUpdate(UCD_ACM_UnitOfWork unitOfWork, Map<Id,Account> oldAccounts, Map<Id, Account> newAccounts) {
        if(newAccounts != null && oldAccounts != null) {
            Set<Id> accountIds = new Set<Id>();
            
            For(Account acc: newAccounts.values()) {
                if ( !( oldAccounts.get(acc.Id).RecordTypeId ==  requestedAccountId &&  acc.RecordTypeId == rejectedAccount  && acc.Core_Account_Reference_Source_Name__c == 'Opportunity Management') &&
                    (acc.RecordTypeId == rejectedAccount || acc.RecordTypeId == endCustomerRecordType || acc.RecordTypeId == IntelAccountId) &&  
                    (acc.Core_Customer_Aggregation_Type__c != null) &&
                    ((acc.Core_Customer_Aggregation_Type__c != oldAccounts.get(acc.Id).Core_Customer_Aggregation_Type__c) ||
                     (acc.Core_Survivor_Account_Id__c != oldAccounts.get(acc.Id).Core_Survivor_Account_Id__c) ||
                     (acc.Core_Business_Party_Id__c != oldAccounts.get(acc.Id).Core_Business_Party_Id__c) ||
                     (acc.Core_Data_Simplified_Account_Nm__c != oldAccounts.get(acc.Id).Core_Data_Simplified_Account_Nm__c) ||
                     (String.isNotBlank(acc.Core_Data_Simplified_Account_Nm__c) &&
                     String.isNotBlank(oldAccounts.get(acc.Id).Core_Data_Simplified_Account_Nm__c) &&
                     !(acc.Core_Data_Simplified_Account_Nm__c.equals(oldAccounts.get(acc.Id).Core_Data_Simplified_Account_Nm__c))) ||
                     (acc.RecordTypeId != oldAccounts.get(acc.Id).RecordTypeId) ||
                     (acc.BillingCountry != oldAccounts.get(acc.Id).BillingCountry) ||
                     (acc.ShippingCountry != oldAccounts.get(acc.Id).ShippingCountry) ||
                     (acc.parentId != oldAccounts.get(acc.Id).parentId) ||
                     //(acc.Core_Data_Country_Cd__c != oldAccounts.get(acc.Id).Core_Data_Country_Cd__c) ||
                     (acc.Core_Data_Country_Nm__c != oldAccounts.get(acc.Id).Core_Data_Country_Nm__c) ||
                     (acc.Core_Account_Request_Rejection_Reason__c != oldAccounts.get(acc.Id).Core_Account_Request_Rejection_Reason__c) ||
                     (acc.Core_Account_Request_Rejection_Notes__c != oldAccounts.get(acc.Id).Core_Account_Request_Rejection_Notes__c) ||
                     (acc.Core_Parent_Data_Simplified_Account_Nm__c != oldAccounts.get(acc.id).Core_Parent_Data_Simplified_Account_Nm__c) ||
                     (String.isNotBlank(acc.Core_Parent_Data_Simplified_Account_Nm__c) &&
                     String.isNotBlank(oldAccounts.get(acc.Id).Core_Parent_Data_Simplified_Account_Nm__c) &&
                     !(acc.Core_Parent_Data_Simplified_Account_Nm__c.equals(oldAccounts.get(acc.Id).Core_Parent_Data_Simplified_Account_Nm__c))) ||
                     (acc.Core_Parent_Business_Party_Id__c != oldAccounts.get(acc.Id).Core_Parent_Business_Party_Id__c) ||
                     (acc.Name != oldAccounts.get(acc.Id).Name))) {
                         accountIds.add(acc.Id);
                     }
            }
            if (accountIds.size() > 0) {
                UCD_ACM_Common.updateACMIntegrationMessage(unitOfWork, accountIds);
            }
        }
    }
    
    /** 
* description : Insert or Update ACM_Integration_Message_Queue__c 
* original author and date : harshalx.sunil.gosavi@intel.com 08/02/2022.
* Moved to ACM_AU_TriggerPlatformEventOnUpdate by Swarup as part of refactoring
*/
/*    private void updateACMIntegrationMessage(UCD_ACM_UnitOfWork unitOfWork, Set<Id> accountIds) {
        Map<Id,ACM_Integration_Message_Queue__c> integrationMessageQueueById = accountQuerySelectorInstance.getIntegrationMessageQueueByAccountId(accountIds);
        List<ACM_Integration_Message_Queue__c> insertIntegrationMessages = new List<ACM_Integration_Message_Queue__c>();
        Map<Id,ACM_Integration_Message_Queue__c> integrationMessageQueueByAccountId = new Map<Id,ACM_Integration_Message_Queue__c>(); 
        
        if(integrationMessageQueueById != null && integrationMessageQueueById.size() > 0) {
            For(ACM_Integration_Message_Queue__c integrationMessageQueue : integrationMessageQueueById.values()) {
                integrationMessageQueueByAccountId.put(integrationMessageQueue.Content__c,integrationMessageQueue);
            }
        }
        For(Id accountId : accountIds) {
            if(integrationMessageQueueByAccountId != null && integrationMessageQueueByAccountId.size() > 0 && integrationMessageQueueByAccountId.containsKey(accountId)) {
                if(integrationMessageQueueByAccountId.get(accountId).Message_Status__c == 'Success' ) {
                    ACM_Integration_Message_Queue__c integrationMessage = integrationMessageQueueByAccountId.get(accountId);
                    integrationMessage.Message_Status__c = 'New';
                    unitOfWork.registerModified(integrationMessage);
                }
            } else {
                ACM_Integration_Message_Queue__c integrationMessage = new ACM_Integration_Message_Queue__c();
                integrationMessage.Content__c = accountId;
                integrationMessage.Custom_Filter__c = accountId;
                integrationMessage.Content_Type__c = 'AccountId';
                integrationMessage.Message_Status__c = 'New';
                integrationMessage.Module_Name__c = 'ACM';
                integrationMessage.Queue_Type__c = 'Outbound';
                integrationMessage.Retry_Count__c = 0;
                integrationMessage.Source_System__c = 'Reltio';
                insertIntegrationMessages.add(integrationMessage);
            }
        }
        
        if(insertIntegrationMessages.size() > 0) {
            unitOfWork.registerNew(insertIntegrationMessages);
        }
    }*/
}