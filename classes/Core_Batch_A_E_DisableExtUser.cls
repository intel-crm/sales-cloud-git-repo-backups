/*************************************************************************************************************************************************
Apex Class Name : Core_Batch_A_E_DisableExtUser 
Created Date    : 18/09/2020
Function        : This batch apex is used to disable partner/customer user and to update user's FederationIdentifier field value after 
				  deletion of User from AGS system to overcome IPS issue. 
**************************************************************************************************************************************************
* Developer                   Date                   Description
* ------------------------------------------------------------------------------------------------------------------------------------------------
* Sonali Mehetre            18/09/2020             US731342 - Pipeline: IPS Issue fix implementation
* Akshay More               20/03/2024              Updated the batch job to disassociate the contact in the batchable context itself and to run just 1 instance at a time
*************************************************************************************************************************************************/

global class Core_Batch_A_E_DisableExtUser implements Database.Batchable<sObject>, Database.Stateful {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String strEmailDomain = '%@intel.com';
        List<String> lstProfilesToConsider = System.Label.Core_A_E_DisableExtUsers_Profile.split(',');
        String query = '';
        List<Contact> cont = [Select id,name from contact];
        List<AsyncApexJob> jobAlreadyRunning = new List<AsyncApexJob>([SELECT ParentJobId,  Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors, ApexClass.Name FROM AsyncApexJob WHERE Status = 'Processing' AND ApexClass.Name = 'Core_Batch_A_E_DisableExtUser' AND ParentJobId = null]);
        
        if(jobAlreadyRunning.size() == 0){ // Proceed with the batch if there are no instances of it running currently
            query = 'SELECT Id, IsActive, IsPortalEnabled, FederationIdentifier, Core_Is_FederationId_Valid_Ind__c FROM User'+
            			' WHERE IsActive = FALSE AND IsPortalEnabled = TRUE AND Contact.Core_Login_Status__c IN (\'Deleted\',\'Downgrade to B2C\') AND'+
            			' Core_Is_FederationId_Valid_Ind__c = FALSE AND (NOT Email Like :strEmailDomain) AND Profile.Name IN: lstProfilesToConsider';
        } else { // Do not proceed with the batch if already an instance of it is running
            query = 'SELECT Id, IsActive, IsPortalEnabled, FederationIdentifier, Core_Is_FederationId_Valid_Ind__c FROM User'+
            			' WHERE IsActive = FALSE AND IsPortalEnabled = TRUE AND Contact.Core_Login_Status__c IN (\'Deleted\',\'Downgrade to B2C\') AND'+
            			' Core_Is_FederationId_Valid_Ind__c = FALSE AND (NOT Email Like :strEmailDomain) AND Profile.Name IN: lstProfilesToConsider LIMIT 0';
        }           
        return Database.getQueryLocator(query);        
    }
    
    global void execute(Database.BatchableContext BC, List<User> lstOfUser) {        
        // enqueue the job for processing
		// System.enqueueJob(new Core_Batch_A_E_DisableExtUser_Queue(lstOfUser)); // Commented to process all the records in the batch job only instead of queuable

        List<User> lstToUpdateUser = new List<User>();
        for(User usr : lstOfUser) {
            usr.IsPortalEnabled = false;
            usr.FederationIdentifier = null;
            lstToUpdateUser.add(usr);
        }
        
        List<Database.SaveResult> lstUserSaveResultUpdate = Database.update(lstToUpdateUser, false);        
          
        String ErrorStr = '';
        Integer SuccessCount = 0;
        Integer ErrorCount = 0;
        DateTime dtWhen = system.now();

        for (Database.SaveResult saveResult : lstUserSaveResultUpdate) {            
            if (!saveResult.isSuccess()) {
                for (Database.Error err: saveResult.getErrors()) {
                    ErrorStr = err.getFields() + '\n'+ err.getMessage(); 
                    System.debug('### The record failed' +  (err.getFields() + '\n'+ err.getMessage())); 
                    ErrorCount++;                   
                } 
            }else{
                SuccessCount++;                
            }        
        } 
        createLogEntry(SuccessCount,ErrorCount,ErrorStr,dtWhen);  
    }
    
    global void finish(Database.BatchableContext BC) { }

    public static void createLogEntry(Integer SuccessCount, Integer ErrorCount, String ErrorStr, DateTime dtWhen) {        
        // Create Assign log Entry
        Core_Log_Entry__c assignCLE = new Core_Log_Entry__c ();
        assignCLE.Core_Origin__c = 'A&E Batch to Disable External Users';
        assignCLE.Core_Project__c = 'A&E';
        assignCLE.Core_Scope__c = 'Disable External Users';
        assignCLE.Core_Severity__c = 'Information';
        assignCLE.Core_Message__c = 'Batch to Disable External Users';
        assignCLE.Core_When__c = dtWhen;        
        assignCLE.Core_Details__c = 'A&E Batch to Disable External Users ran at: ' + dtWhen + ' seconds\r\n ' + 'Records Processed Successfully : ' + SuccessCount + '\r\n Records Processed with Error : ' + ErrorCount + '\r\n Last Error occured : ' + ErrorStr + '/r/n <EOM>';
        
        //insert assignCLE;       
    }
    
}