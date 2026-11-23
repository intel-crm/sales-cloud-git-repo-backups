public class ProductInboundStaggingFromPIMBatch implements Database.Batchable<sObject> {
    Public boolean runAgain = False;
    public ProductInboundStaggingFromPImBatch(Boolean runAgain){
        this.runAgain = True;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        //if(runAgain) {
            return Database.getQueryLocator([Select Id, CompletedDate From AsyncApexJob Where Status = 'Completed' AND ApexClass.name = 'UCD_AccountHierarchyBatch' Order By CompletedDate DESC Limit 1]);
        //}
        //return Null;
    }
    public void execute(Database.BatchableContext BC, List<Sobject> asyncApexJob) {
        System.debug(asyncApexJob);
    }
    public void finish(Database.BatchableContext BC) {
    }
    
    
}