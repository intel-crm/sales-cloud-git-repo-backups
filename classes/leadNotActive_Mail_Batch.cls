global class leadNotActive_Mail_Batch implements Database.Batchable<sObject>, Database.Stateful {

    //Variable Section
    String profile = 'Data Ops';
    global FINAL String strQuery;
    global List<String> errorMessages = new List<String>();
    global List<String> emails = new List<String>();
    
    global leadNotActive_Mail_Batch() { 
        this.strQuery = getBatchQuery();
    }
    
    //Returns the Query String to Batch constructor to fetch right records.
    private String getBatchQuery() {
        String strQuery = 'select Id, Core_Lead_Owner_Name__c, Owner.Name, Owner.IsActive, Owner.Profile.Name from Lead where Owner.IsActive = False or Owner.Profile.Name <> :profile limit 2' ; 
        return strQuery;
        // return Database.getQueryLocator(query);
    }
    
    //Batch Start method
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(strQuery);
    }

    //Batch Execute method calls
    global void execute(Database.BatchableContext BC, List<sObject> scopeList) {
        System.debug(LoggingLevel.INFO, '== scopeList size ==' + scopeList.size());
        
        List<Lead> ld = (List<Lead>) scopeList;
        if(!ld.isEmpty()) { 
            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            for (Lead prod : ld)
            {               
                emails.add('aashnax.anand@intel.com');
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage(); 
           
                Message.setToAddresses(emails); 
                Message.setSubject('Lead owner not active or inappropriate profile!!');
                String body='Hi,'+ '\nThe Lead is not active or its profile does not have access. Kindly check it once and do the needful.';
                body +='\nLead Name: ' + prod.Core_Lead_Owner_Name__c ;
                body +='\nLead ID: ' + prod.id;
                body +='\nThanks' ;
                Message.setPlainTextBody(body);
                //Message.setHtmlBody('Hi,<br/>The Lead is not active or its profile does not have access.<br/> Kindly check it once.<br/> Thank you');
                Message.SaveAsActivity = false;
                mailList.add(Message);
            }
                
            
            if(!mailList.isEmpty()) {
                try{
                    Messaging.sendEmail(mailList);
                    System.debug('Mail sent successfully');
                }
                catch (Exception ex) {
                    errorMessages.add('Unable to send email to Tech: '+ ex.getStackTraceString());
                }
            }
        }
    }  

    //Batch Finish method for after execution of batch work
    global void finish(Database.BatchableContext BC) { 
        AsyncApexJob aaj = [Select Id, Status, NumberOfErrors, JobItemsProcessed, MethodName, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()];
        
        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {aaj.CreatedBy.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('JOB Salesforce Send Notification Batch: ' + aaj.Status);
        String bodyText='Total Job Items ' + aaj.TotalJobItems + ' Number of records processed ' + aaj.JobItemsProcessed + ' with '+ aaj.NumberOfErrors + ' failures.\n';
        bodyText += 'Number of Error Messages ' + errorMessages.size() + '\n';
        bodyText += 'Error Message' + String.join(errorMessages, '\n');
        mail.setPlainTextBody(bodyText);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
}