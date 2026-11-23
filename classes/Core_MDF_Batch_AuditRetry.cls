global class Core_MDF_Batch_AuditRetry implements Database.Batchable<sObject>, Database.Stateful
 {
    global List<PartnerFundClaim> claimsUpdated = new List<PartnerFundClaim>();
    global String queryActive;
    global String errorMessage = '';
    global String invalidClaimStatus = Label.Core_MDF_Invalid_Claim_Status_For_Retry;
    global String[] invalidStatusNotToBeRetried =  invalidClaimStatus.split(',');
        
    global Database.QueryLocator start(Database.BatchableContext batchableContext){   
        return Database.getQueryLocator(queryActive);
    }
    
    
    global void execute(Database.BatchableContext batchableContext, List<PartnerFundClaim> claims)
    { 
   
    try{
        system.debug('Into batch: claims:'+claims);
        claimsUpdated = claims;
        if(!claims.isEmpty()){
          // Call the Audit Selection Helper class and send all the claims for Audit
          ID jobID = System.enqueueJob(new Core_MDF_AuditSelectionHelper(claims));
          //check the error flag and accordingly set the retry ind for next run.
          system.debug('Job Id:'+jobID);  
        } 
        
    }
    catch(Exception ex){
        System.debug('***Exception occurred while ReProcessing' + ex.getmessage()); 
     }   
    } 
    
    
    
    global void finish (Database.BatchableContext batchableContext){
    
    System.debug('*** Claims updated : '+claimsUpdated);
    
    AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :batchableContext.getJobId()];
    String message = 'The batch Apex job with JObId: '+ a.Id +' processed ' + a.TotalJobItems + ' batches with '+ a.JobItemsProcessed + ' number of records and ' + a.NumberOfErrors + ' failures.';
   
    //Fetching Email Address details from Custom setting.
    String sendEmailAddress = Label.Core_MDF_CCP_Support_Email;
    //String sendEmailAddress = 'ealisha.chatterjee@intel.com';
    Boolean sendemail = false;
    // Send an email to the Apex job's ;submitter notifying of job completion only if Custom Setting 'toAddress' data is available
    if(Test.isRunningTest()){
        sendEmailAddress = 'ealisha.chatterjee@intel.com';
        sendemail = true;
    }
     
    if(claimsUpdated != null && !(claimsUpdated).isEmpty()){sendemail = true;}        
    
    
    if( sendemail == true && (sendEmailAddress != null && sendEmailAddress != '')){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {sendEmailAddress};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Salesforce Claims updated ' + a.Status);
        
        String messageBody = '<style>table, th, td {border: 1px solid black;border-collapse: collapse;}';
        messageBody += '<table style="width:100%"><tr><th>Program</th><th>Claim Reference Number</th><th>Claim Title</th><th>Claim Status</th></tr>';
        for(PartnerFundClaim pfc:claimsUpdated){
          messageBody += '<tr><td>'+pfc.Core_mdf_program__c+'</td> <td>'+pfc.Core_MDF_Claim_Ref_Number__c+'</td><td>'+pfc.Title+'</td><td>'+pfc.Core_MDF_Status__c+'</td></tr>';
         }
        messageBody += '</table>';
        if(errorMessage != '' || Test.isRunningTest()){
            messageBody += '\n' + errorMessage;
        }
        mail.setHtmlBody(message + '\n' + 'Claims Processed: '+ messageBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
        }
}
}