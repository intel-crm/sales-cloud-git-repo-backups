global class BatchJobGenerator implements Database.Batchable<sObject> {

    @TestVisible private List<Apex_Batch_Job__c> apexBatchJobdDetails = new List<Apex_Batch_Job__c>();
    @TestVisible private Apex_Batch_Job__c currentJob = new Apex_Batch_Job__c();
    @TestVisible private String className = '';
    @TestVisible private Integer batchSize ;
    @testVisible private BatchJobFramework batchProcessor ;

    global BatchJobGenerator(List<Apex_Batch_Job__c> jobDetails){
        //pending batch jobs to process
        this.apexBatchJobdDetails = jobDetails;

        //currnet batch job details
        currentJob = apexBatchJobdDetails[0];
        className = currentJob.Interface_Name__c;

        //dynamically instantiating the class
        Type t = Type.forName(className);
        this.batchProcessor = (BatchJobFramework)t.newInstance(); 
        
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = batchProcessor.getStartQuery(currentJob);
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext bc, List<sObject> data) {   
        System.debug('Entered execute');
        //batchProcessor.callExecute(bc,data,currentJob);
    }   
     
    global void finish(Database.BatchableContext bc) {       
        System.debug('Entered Finish');

        //Remove the currnet job whihc has processed from the list
        apexBatchJobdDetails.remove(0);
        
        //Check whether any job left to process
        if(apexBatchJobdDetails.size()>=1){
            //get the next batch size
            batchSize = Integer.valueOf(apexBatchJobdDetails[0].Batch_Size__c);
            Database.executeBatch(new BatchJobGenerator(apexBatchJobdDetails), batchSize);
        }
    }
}