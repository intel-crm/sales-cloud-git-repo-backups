global class Core_MDF_Batch_MaskCaseForP2PRefresh implements Database.Batchable<sObject>, Database.Stateful
 {
    global Map<Id,Case> casesToBeUpdatedMap = new Map<Id,Case>{};
    global String errorMessage = '';  
    // instance members to retain state across transactions
    global organization currorg = [SELECT Id, Name, InstanceName, IsSandbox, CreatedDate FROM Organization limit 1];
     
    global Database.QueryLocator start(Database.BatchableContext batchableContext){   
       
        String queryActive='select id,RecordType.Name, Core_MDF_Internal_Case_Closure_Notes__c ,Core_MDF_Claim_Review_Closure_Note__c,'+ 
           'Core_MDF_Closure_Note_txt__c,Core_MDF_Data_Correction_Note_Txt__c,Core_MDF_Data_Entry_CorrectionReason_Txt__c'+
           ' from case where RecordType.Name in (\'Audit\',\'Audit Closed\') limit 10';            
        return Database.getQueryLocator(queryActive);
    }
       
    global void execute(Database.BatchableContext batchableContext, List<Case> casesToBeMasked)
    { 
   
    try{
        if(currorg.issandbox){
        for(Case c : casesToBeMasked) {
        Case c1 = new Case();
        c1.Id=c.Id;
        c1.Core_MDF_Internal_Case_Closure_Notes__c='P2P Refresh';
        c1.Core_MDF_Claim_Review_Closure_Note__c='P2P Refresh'; 
        c1.Core_MDF_Closure_Note_txt__c='P2P Refresh';
        c1.Core_MDF_Data_Correction_Note_Txt__c='P2P Refresh';
        casesToBeUpdatedMap.put(c1.Id,c1);
        }                     
        
        if(casesToBeUpdatedMap != null){
            system.debug('casesToBeUpdatedMap ids:'+casesToBeUpdatedMap.keySet());
            List<Case> cases = casesToBeUpdatedMap.values();
            List<Database.SaveResult> results = Database.update(cases, false);
                        
                        for ( Integer i = 0; i < results.size(); i++ ) 
                            {
                                if ( !results.get(i).isSuccess()) 
                                    {                
                                    errorMessage +='<tr><td>'+cases.get(i).Id+'</td><td>';
                                        
                                     //   errorMessage += finalCampaignsToUpdate.get(i).Name + '\n' + finalCampaignsToUpdate.get(i).Id + 'Errors:\n';
                                    for ( Database.Error theError : results.get(i).getErrors() ) 
                                        {
                                            errorMessage += theError.getMessage()+'</td></tr>';
                                            //errorMessage += theError.getStatusCode()+ '\n' + theError.getMessage();
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
    system.debug('casesToBeUpdatedMap from finish():'+casesToBeUpdatedMap.keySet());      
    if(casesToBeUpdatedMap != null && casesToBeUpdatedMap.size()>0){
    AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :batchableContext.getJobId()];
    String message = 'The batch Apex job with JObId: '+ a.Id +' processed Cases.';
    /*List<Case> processedCases =  [select id,CaseNumber,RecordType.Name, Core_MDF_Internal_Case_Closure_Notes__c ,
                                  Core_MDF_Claim_Review_Closure_Note__c,Core_MDF_Closure_Note_txt__c,
                                  Core_MDF_Data_Correction_Note_Txt__c,Core_MDF_Data_Entry_CorrectionReason_Txt__c
                                  from case where RecordType.Name in ('Audit','Audit Closed')
                                  and id in :casesToBeUpdatedMap.keySet()];*/
    system.debug('a.CreatedBy.Email:'+a.CreatedBy.Email);
    String sendEmailAddress = a.CreatedBy.Email;
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {sendEmailAddress};      
        mail.setToAddresses(toAddresses);
        mail.setSubject(currorg.InstanceName + ' Sandbox: Salesforce batch for P2P Case masking: ' + a.Status);
       // String messageBody = '<style>table, th, td {border: 1px solid black;border-collapse: collapse;}';
        //messageBody += '<table style="width:100%"><tr><th>Case Id</th><th>Id</th></tr>';
        //for(Case c:processedCases){
          //messageBody += '<tr><td>'+c.CaseNumber+'</td><td>'+c.Id+'</td></tr>';
         //}
        String messageBody = 'All the cases were successfully processed by the batch.';
        
        mail.setHtmlBody(message + '<br/>' + messageBody);
        if(errorMessage != '')
                    {
                        
                        messageBody += '\nFollowing cases have failed during the update:\n\n';
                        messageBody += '<table style="width:100%"><tr><th>Id</th><th>Error Message</th></tr>';                                                                
                        messageBody +=  errorMessage;
                    }
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
        }
        }
        catch(exception ex){system.debug(ex.getMessage());}
}
}