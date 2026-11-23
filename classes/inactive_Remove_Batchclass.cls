public class inactive_Remove_Batchclass implements Database.Batchable<sObject> {
    //Id InactiveAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Inactive_Account').getRecordTypeId();
   // Datetime dt=System.now().addMinutes(-30);
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([Select id,name,Core_Account_Request_Rejection_Reason__c,Core_Account_Request_Rejection_Notes__c,Core_Data_Simplified_Local_Language_Nm__c,  Core_Account_Record_Type__c,Core_Deactivated__c,Core_Customer_Aggregation_Type__c,LastModifiedDate from Account where Core_Deactivated__c=true and Core_Account_Record_Type__c='Inactive Account' and Core_Business_Party_Id__c!=null]);
    }
    public void Execute(Database.BatchableContext BC, List<Account> accounts){

        if(accounts.size()>0 && accounts!=null){
       /* Set<String> businessPartyIds=new Set<String>();
        Boolean flagForIPA = true;
        Boolean flagForCoMarketing = true;
        for(Account account : accounts){
                businessPartyIds.add(account.Core_Business_Party_Id__c);
            }
        List<Account> accountswithBpid=[Select Id,Name,Core_Business_Party_Id__c,Core_Intel_Partner_Alliance_PartnerGroup__c, Core_MDF_CoMarketingActive__c from Account where Core_Business_Party_Id__c IN : businessPartyIds AND RecordTypeId =:InactiveAccountRTId];

        for(Account account : accounts){
            if(accounts.Core_Deactivated__c==true && businessPartyIds!=null && accounts.Core_Account_Record_Type__c==InactiveAccountRTId){
                flagforIPA = checkForIPA(accounts);
                flagForCoMarketing = checkForComarketing(accounts);



            }
        }*/
        for(Account account:accounts )
        UCD_ACM_InactiveAccountsUCDRemoval.removeUCDobject(accounts);
        UCD_ACM_InactiveAccountsUCDRemoval.RemoveUCDAttributes(accounts);
        }

    }
    public void finish(Database.BatchableContext BC){
    }





    private Boolean checkForIPA(List<Account> listOfAccount){
        System.debug('$lstAcc '+listOfAccount);
        for(Account account : listOfAccount){
            if(account.Core_Intel_Partner_Alliance_PartnerGroup__c==true){
                return true;
            }
        }
        System.debug('@Entercheckipa');
        return false;
    }

    private Boolean checkForComarketing(List<Account> listOfAccount){
        System.debug('$lstAcccom '+listOfAccount);
        for(Account account : listOfAccount){
            if(account.Core_MDF_CoMarketingActive__c==true){
                return true;
            }
        }
        System.debug('@Entercheckcom');
        return false;
    }

}