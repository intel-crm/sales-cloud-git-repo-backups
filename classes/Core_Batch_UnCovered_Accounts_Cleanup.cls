/**********************************************************************************************************************************************
Class Name  : Core_Batch_UnCovered_Accounts_Cleanup
Created Date: 08-02-2017
Function    : Asychronous batch process to flag the uncovered accounts for clean up. Report all the uncovered account that do no have any 
object associations. This will be run as n when required. Not scheduled.
Modification Log :
* Developer         Date          Description
* ---------------------------------------------------------------------------- 
*Laxmana Lenka    10/05/2017     Initial version
************************************************************************************************************************************************/

global class Core_Batch_UnCovered_Accounts_Cleanup implements Database.Batchable<sObject>,Database.Stateful {
    global Core_Batch_Processing__c batchProcessing;  
    global DateTime jobRunTime;
    global String batchClassName;
    global Integer batchSize = 0;
    global integer count=0; 
    global String emailDistList;    
    /*
    * Method name  : Constructor- Batch class
    * Description  : Initialize values
    * Return Type  : Void
    * Parameter    : Void
    */
    global Core_Batch_UnCovered_Accounts_Cleanup(){
       jobRunTime= System.Now(); 
       batchClassName='Core_Batch_UnCovered_Accounts_Cleanup';       
    }    
    /*
    * Method name  : Start()- Batch class
    * Description  : Queries all uncovered account to process
    * Return Type  : QueryLocator/List of records.
    * Parameter    : Batchable context
    */ 
    global Database.QueryLocator start(Database.BatchableContext bc) { 
        batchProcessing = new Core_Batch_Processing__c();
        Core_Batch_header__c batchHeader = [Select id,Last_Run_Date_Time__c,Email_Distribution_List__c from Core_Batch_Header__c where name = :batchClassName limit 1];
        String query ='Select Id,Core_Business_ID__c,Core_Uncover_Marked_for_Clean_Up__c,Name,Core_Batch_Run_Date__c,Core_CIM_ID__c from Account WHERE Owner.Name=\''+'Uncovered Account'+ '\''+'And Core_PSG_Account__c=False And Core_Sys_Next_Account__c=False And Core_Partner_Account__c=False';
        batchProcessing.Batch_Header__C = batchHeader.id;
        batchProcessing.Core_Email_Distribution_List__c = batchHeader.Email_Distribution_List__c;
        batchProcessing.Core_Salesforce_Job_Id__c = BC.getJobId();
        batchProcessing.Core_Batch_Query__c = query;            
        batchProcessing.Core_Object_Name__c = 'Account';            
        batchProcessing.Core_Start_Date_Time__c = jobRunTime; 
        if( (Schema.sObjectType.Core_Batch_Processing__c.fields.Batch_Header__C.isCreateable() && 
        Schema.sObjectType.Core_Batch_Processing__c.fields.Core_Email_Distribution_List__c.isCreateable() &&
        Schema.sObjectType.Core_Batch_Processing__c.fields.Core_Salesforce_Job_Id__c.isCreateable() &&
        Schema.sObjectType.Core_Batch_Processing__c.fields.Core_Batch_Query__c.isCreateable() &&
        Schema.sObjectType.Core_Batch_Processing__c.fields.Core_Object_Name__c.isCreateable() &&
        Schema.sObjectType.Core_Batch_Processing__c.fields.Core_Start_Date_Time__c.isCreateable() )||
        Test.isRunningTest() )
        {

            insert batchProcessing;
        }
        Database.QueryLocator uncoveredAccounts = Database.getQueryLocator(query);
        return uncoveredAccounts;
        
    }
    /*
    * Method name  : execute()- Batch class
    * Description  : Process the uncovered records to check all  related data to mark to delete
    * Return Type  : VOID
    * Parameter    : Batch context and Scope
    */
    global void execute(Database.BatchableContext bc, List<Account> uncoveredAccounts) {        
        Set<Id> markDeleteAccSetId = (new Map<Id,SObject>(uncoveredAccounts)).keySet();     
        list<account> acflagupdatelist=new list<account>(); 
        Set<Id>successfulAccountIds=new set<Id>();
        Batch_Processing_Line_Item__c batchline = new Batch_Processing_Line_Item__c();
        Integer failedRecordCount=0;
        String errorString='';
        Integer batchRecCount=0;
        
        if(uncoveredAccounts.size() > batchSize){            
            batchSize = uncoveredAccounts.size();
        }
        try {           
            // subquery to get all Account related child records.
            List<Account> accList = [Select Id,Core_Business_ID__c, Core_Uncover_Marked_for_Clean_Up__c,Core_Batch_Run_Date__c, (Select Id from Opportunities), (select Id from cases ),(Select Id from AccountTeamMembers),
            (select id from contacts),(select id from Notes), (select id from Attachments),(select id from Account_ERPM_Engagements__r),(select id from Account_Meeting_Briefs__r ),
            (select id from Account_Teams__r  ), (select id from CCV__r ),(Select Id From Tasks),(select id from events),(select id from Account_Engagements__r),(select id from Account_Profiles__r) from Account where Id IN:uncoveredAccounts ];                
            // Check if any child record present            
            if(accList != null && !accList.isEmpty()){
                for(Account acc : accList){
                    if(acc.Opportunities.size() >0 || acc.cases.size()>0 || acc.contacts.size()>0 || acc.Attachments.size()>0 || acc.Notes.size()>0 ||acc.AccountTeamMembers.size()>0 ||
                    acc.Account_ERPM_Engagements__r.size()>0 || acc.Account_Meeting_Briefs__r.size()>0 || acc.Account_Teams__r.size()>0 || acc.CCV__r.size()>0 || acc.Account_Engagements__r.size()>0 || acc.Account_Profiles__r.size()>0 || acc.Tasks.size()>0 || acc.events.size()>0 || String.isNotBlank(acc.Core_Business_ID__c)){                        
                        if( acc.Core_Uncover_Marked_for_Clean_Up__c){                       
                          acc.Core_Uncover_Marked_for_Clean_Up__c =false; 
                          acc.Core_Batch_Run_Date__c= jobRunTime;
                          acflagupdatelist.add(acc);
                        }                      
                    }
                    else{
                       acc.Core_Uncover_Marked_for_Clean_Up__c =true; 
                       acc.Core_Batch_Run_Date__c= jobRunTime;
                       acflagupdatelist.add(acc);                      
                    }
                }
            }           
            // Update the flag to the accounts
            if(acflagupdatelist != null && !acflagupdatelist.isEmpty() ){           
               // update(acflagupdatelist);
               Database.SaveResult[] lsr = Database.update(acflagupdatelist, false);
               // Iterate through the Save Results 
                for(Database.SaveResult sr:lsr)
                {
                    // fetch all success DML id's in this set
                    if(sr.isSuccess())
                    {
                        batchRecCount=batchRecCount+1;
                        successfulAccountIds.add(sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) { 
                          errorString=errorString +err.getStatusCode() + ': ' + err.getMessage(); 
                           
                        }                        
                    }
                }
                // Get all the failed Ids by iterating through all the Account Ids and check with success IDs.
                for(Account a: acflagupdatelist)
                {
                    if(!successfulAccountIds.contains(a.Id) ){
                        errorString=errorString + String.valueOf(a.Id)+';';
                        failedRecordCount=failedRecordCount+1;                      
                    }
                }
            }
            //insert the batch process line details.    
            count=count+batchRecCount ;
            batchline.Batch_Processing__c = batchProcessing.id;           
            batchline.Object_Type__c = 'Account';            
            batchline.Core_Number_of_Updates__c = batchRecCount; 
            batchline.Exception_Log__c='Total failed records: '+failedRecordCount;
            batchline.Core_Change_Log__c=errorString;    
            if(Schema.sObjectType.Batch_Processing_Line_Item__c.fields.Batch_Processing__c.isCreateable() &&
            Schema.sObjectType.Batch_Processing_Line_Item__c.fields.Object_Type__c.isCreateable() &&
            Schema.sObjectType.Batch_Processing_Line_Item__c.fields.Core_Number_of_Updates__c.isCreateable() &&
            Schema.sObjectType.Batch_Processing_Line_Item__c.fields.Exception_Log__c.isCreateable() &&
            Schema.sObjectType.Batch_Processing_Line_Item__c.fields.Core_Change_Log__c.isCreateable()){
                  
                insert batchline;
            }
        
        } catch(Exception e){      
          batchProcessing.Core_Exception_Log__c= e.getMessage();
          Update batchProcessing;
        }        
    } 
     /*
    * Method name  : Finish()- Batch class
    * Description  : Sends the email to Admin who executes the job with job status details.
    * Return Type  : VOID
    * Parameter    : Batchable context 
    */   
    global void finish(Database.BatchableContext bc) {
        // update the batch processing with batch size, batch end date and other details.
        batchProcessing.Core_Total_Number_of_Records__c = count;
        batchProcessing.Core_End_Date_Time__c = System.Now();
        batchProcessing.Core_Batch_Size__c = batchSize;        
        batchProcessing.Core_Send_Email__c = true;                
        update batchProcessing;     
        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();        
        list<string> emailRecipientlist=new list<string>();
        for (Core_Uncover_Account_Batch_Recipient__c usEmail : Core_Uncover_Account_Batch_Recipient__c.getAll().values()){
             if(string.isnotblank(usEmail.Core_Recipient_Email1__c)){
              emailRecipientlist.add(usEmail.Core_Recipient_Email1__c);
             }
        }             
        AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors,JobItemsProcessed,TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()];        
        emailRecipientlist.add(a.CreatedBy.Email);
        String subject ='Batch Job Uncovered Account CleanUp Status: '+a.Status;
        email.setSubject(subject);
        email.setToAddresses(emailRecipientlist);
        email.setPlainTextBody('The batch Apex job processed '+ a.TotalJobItems +' batches with '+ a.NumberOfErrors +' failures and extended tatus : '+a.ExtendedStatus );
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});      
    }
    /***********************************************************************************************/
        //This job can be run before the clean up. 
        //Please use the below line of code to run the batch job from developer console 
        //Id batchJobId = Database.executeBatch(new Core_Batch_UnCovered_Accounts_Cleanup(), 2000);
       // please check the batch processing object for failure records which is being logged
    /***********************************************************************************************/ 
}