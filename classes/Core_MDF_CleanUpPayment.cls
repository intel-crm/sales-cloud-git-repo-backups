global class Core_MDF_CleanUpPayment implements Database.Batchable<sObject>,Database.Stateful {

    global String errorMessage = '';  
    // instance members to retain state across transactions
    global organization currorg = [SELECT Id, Name, InstanceName, IsSandbox, CreatedDate FROM Organization limit 1];
    global Map<Id,Core_MDF_Payment__c> paymenttobeupdated = new Map<Id,Core_MDF_Payment__c>{};
    public Database.QueryLocator start(Database.BatchableContext BC) 
    {
        //Querying all payments
        String query = 'SELECT Id,Core_MDF_EFT_Nbr__c FROM Core_MDF_Payment__c limit 15';
        return Database.getQueryLocator(query);
    }   
    
    public void execute(Database.BatchableContext BC, List<Core_MDF_Payment__c> paymentList) 
    {
        if(currorg.issandbox){
            for(Core_MDF_Payment__c payment : paymentList) 
            {
                //Emptying field of the payment
                if(payment.Core_MDF_EFT_Nbr__c!=NULL)
                    payment.Core_MDF_EFT_Nbr__c = '';     
                paymenttobeupdated.put(payment.Id,payment);
            }
            try 
            {
                //updating the payments records in database
                if(paymentList!=null && paymentList.size()>0){
                    Database.update(paymentList,false);
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
            if(paymenttobeupdated != null && paymenttobeupdated.size()>0){
                system.debug('payment from finish():');             
                AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
                String message = 'The batch Apex job with JObId: '+ a.Id +' processed below payments.';
                List<Core_MDF_Payment__c> paymentList =  [SELECT Id,Core_MDF_EFT_Nbr__c FROM Core_MDF_Payment__c where id in :paymenttobeupdated.keySet()];
                String sendEmailAddress = a.CreatedBy.Email;
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] {sendEmailAddress}; 
                mail.setToAddresses(toAddresses);
                mail.setSubject(currorg.InstanceName + ' Sandbox: Salesforce batch for Payment field masking ' + a.Status);
                String messageBody = '<style>table, th, td {border: 1px solid black;border-collapse: collapse;}';
                messageBody += '<table style="width:100%"><tr><th>Id</th><th>Core_MDF_EFT_Nbr__c</th></tr>';
                for(Core_MDF_Payment__c p:paymentList)
                {
                  messageBody += '<tr><td>'+p.Id+'</td><td>'+p.Core_MDF_EFT_Nbr__c+'</td></tr>';
                }
                messageBody += '</table>';              
                mail.setHtmlBody(message + '<br/>' + messageBody);
                if(errorMessage != '')
                {                   
                    messageBody += '\nFollowing payments have failed during the update:\n\n';
                    messageBody += '<table style="width:100%"><tr><th>Id</th><th>Error Message</th></tr>';                                                                
                    messageBody +=  errorMessage;
                }
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                
            }
        }
        catch(exception ex){system.debug(ex.getMessage());}
    }
}