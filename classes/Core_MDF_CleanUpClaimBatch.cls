global class Core_MDF_CleanUpClaimBatch implements Database.Batchable<sObject>,Database.Stateful {
    global integer i=1000000000;
    global String errorMessage = '';  
    // instance members to retain state across transactions
    global organization currorg = [SELECT Id, Name, InstanceName, IsSandbox, CreatedDate FROM Organization limit 1];
    global Map<Id,Core_MDF_Claim_Batch_Stage__c> Batchclaimtobeupdated = new Map<Id,Core_MDF_Claim_Batch_Stage__c>{};
    public Database.QueryLocator start(Database.BatchableContext BC) 
    {
        //Querying all claim batch records
        String query = 'SELECT Id,Core_MDF_Bank_Nbr__c, Core_MDF_Claim_Comment_txt__c FROM Core_MDF_Claim_Batch_Stage__c limit 30';
        return Database.getQueryLocator(query);
    }       
    public void execute(Database.BatchableContext BC, List<Core_MDF_Claim_Batch_Stage__c> claimList) 
    {
        if(currorg.issandbox)
        {
            for(Core_MDF_Claim_Batch_Stage__c claim : claimList) 
            {
                System.debug('before masking:'+claim.Core_MDF_Bank_Nbr__c);
                //Emptying field of the claim batch record
                claim.Core_MDF_Bank_Nbr__c = String.valueof(i); 
                i++;
                if(claim.Core_MDF_Claim_Comment_txt__c!= '')
                    claim.Core_MDF_Claim_Comment_txt__c = ''; 
                System.debug('after masking:'+claim.Core_MDF_Bank_Nbr__c);
                Batchclaimtobeupdated.put(claim.Id,claim);
            }
            try 
            {
                //updating the batch claim records in database
                if(claimList!=null && claimList.size()>0){
                    Database.update(claimList,false);
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
            if(Batchclaimtobeupdated != null && Batchclaimtobeupdated.size()>0){
                system.debug('claims inside finish:');          
                AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
                String message = 'The batch Apex job with JObId: '+ a.Id +' processed below claim records.';
                List<Core_MDF_Claim_Batch_Stage__c> claimList =  [SELECT Id,Core_MDF_Bank_Nbr__c, Core_MDF_Claim_Comment_txt__c FROM Core_MDF_Claim_Batch_Stage__c where id in :Batchclaimtobeupdated.keySet()];
                String sendEmailAddress = a.CreatedBy.Email;
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] {sendEmailAddress}; 
                mail.setToAddresses(toAddresses);
                mail.setSubject(currorg.InstanceName + ' Sandbox: Salesforce batch for claim records field masking ' + a.Status);
                String messageBody = '<style>table, th, td {border: 1px solid black;border-collapse: collapse;}';
                messageBody += '<table style="width:100%"><tr><th>Id</th><th>Core_MDF_Bank_Nbr__c</th><th>Core_MDF_Claim_Comment_txt__c</th></tr>';
                for(Core_MDF_Claim_Batch_Stage__c p:claimList)
                {
                  messageBody += '<tr><td>'+p.Id+'</td><td>'+p.Core_MDF_Bank_Nbr__c+'</td><td>'+p.Core_MDF_Claim_Comment_txt__c+'</td></tr>';
                }
                messageBody += '</table>';              
                mail.setHtmlBody(message + '<br/>' + messageBody);
                if(errorMessage != '')
                {                   
                    messageBody += '\nFollowing Batch claim records have failed during the update:\n\n';
                    messageBody += '<table style="width:100%"><tr><th>Id</th><th>Error Message</th></tr>';                                                                
                    messageBody +=  errorMessage;
                }
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }   
        }
        catch(exception ex){system.debug(ex.getMessage());}
    }
}