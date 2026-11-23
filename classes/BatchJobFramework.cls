public interface BatchJobFramework{

    string getStartQuery(Apex_Batch_Job__c jobData);
    
    void doExecute(List<sObject> data);

    void callExecute(Database.BatchableContext bc,List<sObject> data);
    void callFinish(Database.BatchableContext bc,List<sObject> data);

}