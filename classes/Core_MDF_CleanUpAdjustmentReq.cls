global class Core_MDF_CleanUpAdjustmentReq implements Database.Batchable<sObject>,Database.Stateful {
    
    global Map<Id,Core_MDF_Adjustment_Request__c> adjReqToBeUpdated = new Map<Id,Core_MDF_Adjustment_Request__c>{};

    global String errorMessage = '';  
    // instance members to retain state across transactions
    global organization currorg = [SELECT Id, Name, InstanceName, IsSandbox, CreatedDate FROM Organization limit 1];

    public Database.QueryLocator start(Database.BatchableContext BC) 
    {
        //Querying all adjustments  
        String query = 'SELECT Id,Core_MDF_Comments_Txt__c FROM Core_MDF_Adjustment_Request__c limit 15';
        return Database.getQueryLocator(query);
    }   
    
    public void execute(Database.BatchableContext BC, List<Core_MDF_Adjustment_Request__c> adjList) 
    {
        if(currorg.issandbox){
            for(Core_MDF_Adjustment_Request__c adjreq : adjList) 
            {
                //Emptying comment field of the adjustment requests
                if(adjreq.Core_MDF_Comments_Txt__c!=NULL)
                    adjreq.Core_MDF_Comments_Txt__c = '';
                adjReqToBeUpdated.put(adjreq.Id,adjreq);
            }
            try 
            {
                //updating the adjustment requests in database
                if(adjList!=null && adjList.size()>0){
                    Database.update(adjList,false);
                }               
            } 
            catch(Exception e) 
            {
                System.debug('Exception'+e);
                Core_MDF_CCP_UtilityClass.logError(e);        
            }
        }
    }        
    public void finish(Database.BatchableContext BC) 
    {
        try
        {
            if(adjReqToBeUpdated != null && adjReqToBeUpdated.size()>0){
                system.debug('adjustment requests inside finish:');             
                AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
                String message = 'The batch Apex job with JObId: '+ a.Id +' processed below adjustment requests.';
                List<Core_MDF_Adjustment_Request__c> adjList =  [SELECT Id,Core_MDF_Comments_Txt__c FROM Core_MDF_Adjustment_Request__c where id in :adjReqToBeUpdated.keySet()];
                String sendEmailAddress = a.CreatedBy.Email;
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] {sendEmailAddress}; 
                mail.setToAddresses(toAddresses);
                mail.setSubject(currorg.InstanceName + ' Sandbox: Salesforce batch for Adjustment Request field masking ' + a.Status);
                String messageBody = '<style>table, th, td {border: 1px solid black;border-collapse: collapse;}';
                messageBody += '<table style="width:100%"><tr><th>Id</th><th>Core_MDF_Comments_Txt__c</th></tr>';
                for(Core_MDF_Adjustment_Request__c p:adjList)
                {
                  messageBody += '<tr><td>'+p.Id+'</td><td>'+p.Core_MDF_Comments_Txt__c+'</td></tr>';
                }
                messageBody += '</table>';              
                mail.setHtmlBody(message + '<br/>' + messageBody);
                if(errorMessage != '')
                {                   
                    messageBody += '\nFollowing adjustment requests have failed during the update:\n\n';
                    messageBody += '<table style="width:100%"><tr><th>Id</th><th>Error Message</th></tr>';                                                                
                    messageBody +=  errorMessage;
                }
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }   
        }
        catch(exception ex){system.debug(ex.getMessage());}
}
}