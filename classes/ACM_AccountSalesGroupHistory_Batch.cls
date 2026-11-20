public class ACM_AccountSalesGroupHistory_Batch implements Database.Batchable<sObject> {
    Datetime salesGroupPeriod=System.now().addMonths(-(integer.valueOf(System.Label.Core_SalesGroupHistory_Time)));
    Integer month=salesGroupPeriod.month();
    public Database.QueryLocator start(Database.BatchableContext BC){
        Id intelAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        String query='Select Id,Name,RecordTypeId,Core_Sales_Groups__c,Core_Sales_Group_Preview__c From Account Where RecordTypeId =:intelAccountRTId ORDER BY LastModifiedDate DESC';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Account> accounts){
        //System.debug('@@account '+accounts);
        if(!accounts.isEmpty()){
            Map<Id,Account> mapOfSalesGroupAccount=new Map<Id,Account>();
            for(Account account : accounts){
               mapOfSalesGroupAccount.put(account.Id,account);
            }
            if(mapOfSalesGroupAccount!=null && !mapOfSalesGroupAccount.isEmpty()){
                insertSalesGroupHistoryRecord(mapOfSalesGroupAccount);
            }
        }
    }
    public void finish(Database.BatchableContext BC){
    }
    private void insertSalesGroupHistoryRecord(Map<Id,Account> mapOfAccounts){
        try{
            List<Core_Sales_Group_History__c> salesGroupHistoryToInsert=new List<Core_Sales_Group_History__c>();
            for(Account account : mapOfAccounts.values()){
                Core_Sales_Group_History__c salesGroupHistory = new Core_Sales_Group_History__c();
                salesGroupHistory.Account_Id__c=account.Id;
                salesGroupHistory.Sales_Group__c=account.Core_Sales_Groups__c;
                salesGroupHistory.Account_Name__c=account.Name;
                salesGroupHistory.Sales_Group_Preview__c=account.Core_Sales_Group_Preview__c;
                if(month<=6){
                    salesGroupHistory.Period__c='1H'+salesGroupPeriod.year()+'SalesGroup';
                }
                else{
                    salesGroupHistory.Period__c='2H'+salesGroupPeriod.year()+'SalesGroup';
                }
                salesGroupHistoryToInsert.add(salesGroupHistory);
            }
            if(salesGroupHistoryToInsert.size()>0){
                insert salesGroupHistoryToInsert;
            }
        }
        catch(Exception ex){
            UCD_ACM_Logger.error('Core_TrackSalesGroupHistory_Batch','insertSalesGroupHistoryRecord','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString()+' Failed Account Ids :'+mapOfAccounts.keySet().toString(),'AccountIds: '+mapOfAccounts.keySet().toString());
        }
    }
}