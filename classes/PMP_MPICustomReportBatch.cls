/****************************************************************************************************************************************
* Class Name  : PMP_MPICustomReportBatch 
* Version     : 1.0 
* Created Date: 06/04/2022 
* Modification Log :
*
* Developer                           Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Yashasvi Aggarwal                 06/04/2022                 
*****************************************************************************************************************************************/
global class PMP_MPICustomReportBatch implements Database.Batchable<sObject>,Database.Stateful{

    public static List<PMP_OPID_MPI_Rel__c> opidRecordsList = new List<PMP_OPID_MPI_Rel__c>();
    public Set<Id> allAccountIds = new  Set<Id>();
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        String query='Select Id,PMP_Marketing_Profile_Id__c,PMP_One_Partner_ID__c from PMP_OPID_MPI_Rel__c where PMP_One_Partner_ID__c in: allAccountIds and Is_Active__c=true';
        return Database.getQueryLocator(query);   
    }
    
    global void execute(Database.BatchableContext bc, List<PMP_OPID_MPI_Rel__c> scope){
        opidRecordsList=scope;
    }
    
    global void finish(Database.BatchableContext bc){
        
    }
    public static List<PMP_OPID_MPI_Rel__c> fetchOPIDRecords(Set<Id> allAccountIds)
    {
        Database.executeBatch(new PMP_MPICustomReportBatch());
        return opidRecordsList;
    }
}