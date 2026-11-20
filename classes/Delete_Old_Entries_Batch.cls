/**************************************************************************************************************
Apex Class Name:  Delete_Old_Entries_Batch
Version     : 1.0 
Created Date: 07 Sep 2022
Function    : Batch class to delete records older than specific date
Note		: Make sure that you are not fetching too many records using SOQL.
Modification Log :
* Developer                      Date              Description
* ----------------------------------------------------------------------------                 
* Sreeharsha Karanam             07/09/2021        Initial version
***************************************************************************************************************/
global class Delete_Old_Entries_Batch implements Database.Batchable<sObject> {
    
    global String noOfDays;
    global String objectName;
    global String notifyEmail;
	
    global Delete_Old_Entries_Batch(string objectName,String noOfDays,String notifyEmail) {
        this.objectName = objectName;
        this.noOfDays = noOfDays;
        this.notifyEmail = notifyEmail;
    }
    
    // Get the entries to delete
    global Database.QueryLocator start(Database.BatchableContext bc) {
			  String queryString = 'select Id from '+ objectName; 
              if (Test.isRunningTest())
                  return Database.getQueryLocator(queryString +' Limit 2');
        	  else
                  return Database.getQueryLocator(queryString +' where CreatedDate <'+ noOfDays);
    }    
    // Delete the records 
    global void execute(Database.BatchableContext bc, List<sObject> scope) {        
        if(scope.size()>0){
        		delete scope;
        		DataBase.emptyRecycleBin(scope);
            }            
    }   
    global void finish(Database.BatchableContext BC) {
     AsyncApexJob a = [Select Id, ApexClass.Name, Status, ExtendedStatus, NumberOfErrors, JobItemsProcessed, 
                       TotalJobItems, CompletedDate from AsyncApexJob where Id =:BC.getJobId()];
          
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {notifyEmail};
            mail.setToAddresses(toAddresses);
            mail.setSubject('Delete Old Log Entries Job Run Status');
        	String messageBody = '<html><body><style>table, th, td {border: 1px solid black;border-collapse: collapse;}</style><p>Hi,</p><p>Please find the Delete old log entries batch execution details:</p></br><table><tbody><tr><td colspan=\'2\', style=\"text-align:center\"><b>Batch Job Run Details</b></td></tr><tr><td>Id</td><td>'+a.Id+
            '</td></tr><tr><td>Class Name </td><td>'+a.ApexClass.Name+                
            '</td></tr><tr><td>Status</td><td>'+a.Status+
            '</td></tr><tr><td>ExtendedStatus</td><td>'+a.ExtendedStatus+
            '</td></tr><tr><td>Number Of Errors</td><td>'+a.NumberOfErrors+
            '</td></tr><tr><td>JobItems Processed</td><td>'+a.JobItemsProcessed+
            '</td></tr><tr><td>TotalJobItems</td><td>'+a.TotalJobItems+
            '</td></tr><tr><td>Completed Date</td><td>'+a.CompletedDate+
            '</td></tr> </tbody></table></body></html>';
            mail.setHtmlBody(messageBody);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            System.debug('********* batch finish method sent an email ****************');
 }
}