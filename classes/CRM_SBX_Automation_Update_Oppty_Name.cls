global class CRM_SBX_Automation_Update_Oppty_Name implements database.Batchable<sObject>, database.stateful {
    /*Batch class to Update Opportunity Names to "Account YYY - Opportunity ZZZ". 
This is following feedback from Jen Skinner, Email communication dated 6th May, 2020. 
This Batch class to be executed ONLY in Sandboxes while performing sandbox build steps
Version 1 developed by Ashok V Kanagarla on 8th May, 2020
*/
    
    // instance members to retain state across transactions
    global organization currorg = [SELECT Id, Name, InstanceName, IsSandbox, CreatedDate FROM Organization limit 1];
    global integer numberOfRecordsProcessed = 0;
    global integer opptycount = 0;
    global integer Accountcount = 44654;
    global id Accountid = '0063b00001CqwEjAAJ'; 
    
    global database.QueryLocator start(Database.BatchableContext BC){
        System.debug('Sandbox data steps Updating Opportunity Names to "Account YYY - Opportunity ZZZ" started in ' + currorg.Name + ' Sandbox ' + 'running on ' + currorg.InstanceName + ' Instance' );
        return database.getQueryLocator('Select ID, account.name, Name, createddate from Opportunity where not (name  like \'Account%\') ORDER BY accountid desc');
    }
    
    
    global void execute(Database.BatchableContext BC, list<Opportunity> scope){
        //        try{
        //process only in sandbox 
        if(currorg.issandbox){
            //                system.debug('no of records input to execute method: ' + scope.size());
            list<Opportunity> updatedOpptys = new list<Opportunity>();
            
            //Update Opportunity Name 
            for(Opportunity oppty : scope){
                if(Accountid != oppty.AccountId){
                    accountcount = accountcount + 1; 
                    opptycount = 1;
                }

                oppty.name = 'Account ' + String.valueOf(accountcount).leftPad(6, '0') + ' - ' + 'Opportunity ' + String.valueOf(opptycount).leftPad(6, '0');
                updatedOpptys.add(oppty);
                //update counters 
                opptycount = opptycount + 1;
                Accountid = oppty.AccountId;

            } //for
            
            //Update database 
            if(!updatedOpptys.isEmpty()){
                update  updatedOpptys; 
                system.debug('number of records updated: ' + updatedOpptys.size());
                numberOfRecordsProcessed = numberOfRecordsProcessed + updatedOpptys.size();
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
        //Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    }
}