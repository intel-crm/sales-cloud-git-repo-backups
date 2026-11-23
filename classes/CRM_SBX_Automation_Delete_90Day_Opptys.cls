global class CRM_SBX_Automation_Delete_90Day_Opptys implements database.Batchable<sObject>, database.stateful {
/*Batch class to opportunities created in last 3 months
This Batch class to be executed ONLY in Sandboxes while performing sandbox build steps
Version 1 developed by Ashok V Kanagarla on 9th September, 2019 
*/
    
    // instance members to retain state across transactions
    global organization currorg = [SELECT Id, Name, InstanceName, IsSandbox, CreatedDate FROM Organization limit 1];
    global integer numberOfRecordsProcessed = 0;

    
    global database.QueryLocator start(Database.BatchableContext BC){
        System.debug('Sandbox data steps deleting Opportunities data started in ' + currorg.Name + ' Sandbox ' + 'running on ' + currorg.InstanceName + ' Instance' );
        return database.getQueryLocator('Select ID from opportunity where createddate = LAST_n_DAYS:85');
    }
    

    global void execute(Database.BatchableContext BC, list<opportunity> scope){
//        try{
        //process only in sandbox 
            if(currorg.issandbox){

                 //Update database 
                    if(!scope.isEmpty()){
                        system.debug('number of records deleted: ' + scope.size());
                        numberOfRecordsProcessed = numberOfRecordsProcessed + scope.size();
                        delete scope;
                    }
            } //if(currorg.issandbox)
/*        } //try
        catch(exception e){
            system.debug('Exception occurred: ' + e.getMessage());
        } //catch*/
        } //method execute
    
    global void finish(database.BatchableContext BC){
        system.debug(numberOfRecordsProcessed + ' Records processed');
        AsyncApexJob a = [SELECT id, status, numberoferrors, jobitemsprocessed, totaljobitems, createdBy.Email 
                          FROM AsyncApexJob
                          where Id = :BC.getJobId()];

        //Send Email to APEX Job Submitter
        String[] toAddresses = new string[] {a.createdby.email};
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toaddresses);
        mail.setSubject(currorg.InstanceName + ' Sandbox: Status of job deleting Opportunities data: ' + a.Status);
        mail.setPlainTextBody('The batch APEX job processed ' + A.TotalJobItems + ' batches with ' + a.NumberOfErrors + ' failures ' + 'processing '+ numberOfRecordsProcessed + ' records');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    }
    }