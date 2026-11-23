global class Core_MDF_Btch_MaskChecklstForP2PRefresh implements Database.Batchable<sObject>, Database.Stateful
 {
    
    global Map<Id,Core_MDF_Claim_Case_Checklist__c> checklistToBeUpdatedMap = new Map<Id,Core_MDF_Claim_Case_Checklist__c>{};
    global String errorMessage = '';  
    // instance members to retain state across transactions
    global organization currorg = [SELECT Id, Name, InstanceName, IsSandbox, CreatedDate FROM Organization limit 1];
     
   global Database.QueryLocator start(Database.BatchableContext batchableContext){   
        String queryActive = 'select id, Core_MDF_Comment__c from Core_MDF_Claim_Case_Checklist__c limit 10';
        return Database.getQueryLocator(queryActive);
    }
       
    global void execute(Database.BatchableContext batchableContext, List<Core_MDF_Claim_Case_Checklist__c> checklistToBeMasked)
    { 
   
    try{
        if(currorg.issandbox){
    for(Core_MDF_Claim_Case_Checklist__c c :checklistToBeMasked) {
    Core_MDF_Claim_Case_Checklist__c c1 = new Core_MDF_Claim_Case_Checklist__c();
        c1.Id=c.Id;
        c1.Core_MDF_Comment__c='P2P Refresh';
        checklistToBeUpdatedMap.put(c1.Id,c1);
        }
        if(checklistToBeUpdatedMap != null){
            system.debug('checklistToBeUpdatedMap ids:'+checklistToBeUpdatedMap.keySet());
            List<Core_MDF_Claim_Case_Checklist__c> caseChecklist = checklistToBeUpdatedMap.values();
            List<Database.SaveResult> results = Database.update(caseChecklist, false);
                        
                        for ( Integer i = 0; i < results.size(); i++ ) 
                            {
                                if ( !results.get(i).isSuccess()) 
                                    {                
                                    errorMessage +='<tr><td>'+caseChecklist.get(i).Id+'</td><td>';
                                    for ( Database.Error theError : results.get(i).getErrors() ) 
                                        {
                                            errorMessage += theError.getMessage()+'</td></tr>';
                                            }
                                    }
                                
                            }
        } 
        }   
        }                        
     catch(exception ex){system.debug(ex.getMessage());} 
    } 
            
    global void finish (Database.BatchableContext batchableContext){
        try{
    //DE67727: WW07 | QA | R2 | Case Retry Batch is not processing the data for which Case ID is missing on the Claims
    system.debug('checklistToBeUpdatedMap from finish():'+checklistToBeUpdatedMap.keySet());      
    if(checklistToBeUpdatedMap != null && checklistToBeUpdatedMap.size()>0){
    AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :batchableContext.getJobId()];
    String message = 'The batch Apex job with JObId: '+ a.Id +' processed below Checklist.';
    /*List<Core_MDF_Claim_Case_Checklist__c> processedChecklist =  [select id, Core_MDF_Case_ID__c,Core_MDF_Comment__c from 
                                      Core_MDF_Claim_Case_Checklist__c where
                                      id in :checklistToBeUpdatedMap.keySet()];*/
    String sendEmailAddress = a.CreatedBy.Email;
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {sendEmailAddress};      
        mail.setToAddresses(toAddresses);
        mail.setSubject(currorg.InstanceName + ' Sandbox: Salesforce batch for P2P Case checklist masking: ' + a.Status);
       
        //String messageBody = '<style>table, th, td {border: 1px solid black;border-collapse: collapse;}';
        //messageBody += '<table style="width:100%"><tr><th>Checklist Id</th><th>case Id</th><th>checklist comment</th></tr>';
        //for(Core_MDF_Claim_Case_Checklist__c c:processedChecklist){
          //messageBody += '<tr><td>'+c.Id+'</td><td>'+c.Core_MDF_Case_ID__c+'</td><td>'+c.Core_MDF_Comment__c+'</td></tr>';
         //}
        String messageBody = 'All the checklists were processed successfully by the batch.';
        
        mail.setHtmlBody(message + '<br/>' + messageBody);
        if(errorMessage != '')
                    {
                        
                        messageBody += '\nFollowing checklist have failed during the update:\n\n';
                        messageBody += '<table style="width:100%"><tr><th>Id</th><th>Error Message</th></tr>';                                                                
                        messageBody +=  errorMessage;
                    }
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
        }
        }
        catch(exception ex){system.debug(ex.getMessage());}
}
}