public without sharing class UCD_ACM_InactiveAccountsUCDRemoval {
    //public UCD_ACM_InactiveAccountsUCDRemoval() {
        public static void  RemoveUCDAttributes(List<Account> listOfAccount){
            if(listOfAccount != null && listOfAccount.size()>0){
                System.debug('@@$accounts '+listOfAccount);
                for(Account account : listOfAccount){
                    account.Core_Business_Party_Id__c = null;
                    account.Core_Customer_Aggregation_Type__c = null;
                    account.Core_Data_Simplified_Account_Nm__c = null;
                    account.Core_Data_Simplified_Local_Language_Nm__c = null;
                    account.Core_Data_Country_Nm__c = null;
                    account.Unified_Hierarchy_View__c = null;
                    account.Core_MDM_Website__c = null;
                    account.Core_Unified_Global_Customer__c = null;
                    account.Core_Unified_Global_Customer_Name__c = null;
                    account.Core_Unified_Global_Customer_BP_Id__c = null;
                    account.Core_Unified_Intermediate_Customer__c = null;
                    account.Core_Unified_Intermediate_Customer_2__c = null;
                    account.Core_Unified_Intermediate_Customer_Name__c = null;
                    account.Core_Unified_Intermediate_Customer_BP_Id__c = null;
                    account.Core_Unified_Country_Customer__c = null;


                }    
            }
    }
    public static void removeCompliancelist(Map<Id,Account> listOfAccount){ 
        List<Core_Account_Compliance_Watch_List__c> complianceWatchListtoDelete = new List<Core_Account_Compliance_Watch_List__c>();
        Set<Id> accountIds=new Set<Id>();
        List<Core_Account_Compliance_Watch_List__c> complianceWatchListsRecords = new List<Core_Account_Compliance_Watch_List__c>();
        if(!listOfAccount.isempty()){
            System.debug('@@$accouts'+listOfAccount);
            for(Account account : listOfAccount.values()){
                    accountIds.add(account.id);
                    System.debug('@@$accountIds'+accountIds);
                
            }
            complianceWatchListsRecords = [Select id,Core_Account_Id__c,Core_Effective_End_Date__c from Core_Account_Compliance_Watch_List__c where Core_Account_Id__c IN :accountIds];
            System.debug('@@$complianceWatchListsRecords'+complianceWatchListsRecords);
            for(Core_Account_Compliance_Watch_List__c complianceWatchList : complianceWatchListsRecords){
                    if(!complianceWatchListsRecords.isempty()){
                        complianceWatchList.Core_Effective_End_Date__c=System.today();
                    complianceWatchListtoDelete.add(complianceWatchList);
                    }
                }
                System.debug('#$$complianceWatchListtoDelete '+complianceWatchListtoDelete);
                if(complianceWatchListtoDelete.size()>0){
                    update complianceWatchListtoDelete;
                }
        }
    }
    public static void removeCPE(Map<Id,Account> listOfAccount){ 
        List<Account_Create_Request__c> cpetoDelete = new List<Account_Create_Request__c>();
        Set<Id> accountIds=new Set<Id>();
        List<Account_Create_Request__c> cpeRecords = new List<Account_Create_Request__c>();
        if(!listOfAccount.isempty()){
            System.debug('@@$accouts'+listOfAccount);
            for(Account account : listOfAccount.values()){
                    accountIds.add(account.id);
                    System.debug('@@$accountIds'+accountIds);
                
            }
            cpeRecords = [Select id,Customer_Process_Engagement__c, Customer_Aggregation_Type__c, Requested_Account__r.Core_Deactivated__c from Account_Create_Request__c where Requested_Account__C IN :accountIds];
            System.debug('@@$cpeRecords'+cpeRecords);
            for(Account_Create_Request__c cpe : cpeRecords){
                    if(!cpeRecords.isempty()){
                        //cpe.Core_Effective_End_Date__c=System.today();
                    cpetoDelete.add(cpe);
                    }
                }
                System.debug('#$$complianceWatchListtoDelete '+cpetoDelete);
                if(cpetoDelete.size()>0){
                    delete cpetoDelete;
                }
        }
    }   
}