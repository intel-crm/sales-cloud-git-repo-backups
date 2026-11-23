global class InactiveremoveBatchclass implements Database.Batchable<sObject> {
    Id InactiveAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Inactive_Account').getRecordTypeId();
    Datetime dt=System.now().addMinutes(-30);
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('@@$raj'+ InactiveAccountRTId);
        String query='Select Id,Name,Core_MDM_Website__c, Core_Data_Simplified_Account_Nm__c,Core_Data_Country_Cd__c,Core_Account_Request_Rejection_Reason__c,Core_Account_Request_Rejection_Notes__c,Core_Data_Simplified_Local_Language_Nm__c,Core_Deactivated__c,Core_Business_Party_Id__c,Core_Intel_Partner_Alliance_PartnerGroup__c,Core_MDF_CoMarketingActive__c,RecordTypeId,LastModifiedDate From Account Where Core_Business_Party_Id__c!=null AND RecordTypeId =:InactiveAccountRTId';
        return Database.getQueryLocator(query);
        
    }
    global void execute(Database.BatchableContext BC, List<Account> accounts){
        System.debug('@@#rajveer'+ accounts);
        if(accounts.size()>0 && accounts!=null){
        Map<Id,Account> mapOfAddCpeAccount=new Map<Id,Account>();
        Set<String> businessPartyIds=new Set<String>();
        Boolean flagForCoMarketing = true;
        for(Account account:accounts){
            if(account.Core_Deactivated__c==true){
                mapOfAddCpeAccount.put(account.Id,account);
            }
        }

        if(!mapOfAddCpeAccount.isempty()){
            system.debug('@@#mapofaddcpeAccount'+mapOfAddCpeAccount);
        //UCD_ACM_InactiveAccountsUCDRemoval.removeCompliancelist(mapOfAddCpeAccount);
            UCD_ACM_InactiveAccountsUCDRemoval.removeCPE(mapOfAddCpeAccount);
        //UCD_ACM_InactiveAccountsUCDRemoval.RemoveUCDAttributes(mapOfAddCpeAccount);
        }
        }

    }
    global void finish(Database.BatchableContext BC){
    }
}