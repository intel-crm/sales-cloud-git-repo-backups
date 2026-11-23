/***************************************************************************************************************************************************************************************************
Apex Class Name:  Core_Batch_AccountTeamAuditKickoff
Version     : 1.0 
Created Date: 5/24/16 
Function    : Finds all Accounts with account team members, sets the audit completed field to false and
			  sets the audit due date to a date X days in the future based on a custom setting.
Parameters  : executeNotificationBatch - daisy chains Core_Batch_AccountTeamAuditNotification in finish method
			  sendEmail - (passed to Core_Batch_AccountTeamAuditNotification) send email if true
			  emailTemplateName - (passed to Core_Batch_AccountTeamAuditNotification) 
			  addTasks - (passed to Core_Batch_AccountTeamAuditNotification) 
			  			 add a Task for each pertinent account owner if true
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* David S Wong              5/24/16                Development Start
*****************************************************************************************************************************************************************************************************/
global class Core_Batch_AccountTeamAuditKickoff implements Database.Batchable<sObject>,Database.Stateful {
    global Core_Batch_Processing__c batchProcessing;
    global integer count = 0;
    global Integer batchSize = 0;
    global Datetime batchStartTime = System.now();
    global Date auditEndDate;
    global boolean executeNotificationBatch = false;
    global boolean sendEmail = false;
    global String emailTemplateName;
    global boolean addTasks = false; 


    public Core_Batch_AccountTeamAuditKickoff(boolean executeNotificationBatchParam, boolean sendEmailParam, String emailTemplateNameParam, boolean addTasksParam) {
    	executeNotificationBatch = executeNotificationBatchParam;
    	sendEmail = sendEmailParam;
    	emailTemplateName = emailTemplateNameParam;
    	addTasks = addTasksParam;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        batchProcessing = new Core_Batch_Processing__c();        
        Core_Batch_header__c header=AccountTeamBatchHandler.getHeader('Core_Batch_AccountTeamAuditKickoff');
        try{
        	String query = 'SELECT ID, OwnerID, Core_Covered_Account__c, Core_Account_Team_Audit_Complete__c from Account where ID in (SELECT AccountID from AccountTeamMember)';            
            //String query = 'SELECT ID, OwnerID, Core_Covered_Account__c, Core_Account_Team_Audit_Complete__c from Account where (OwnerID = \'005o0000001fYw2AAE\' OR OwnerID = \'005o0000002GA8JAAW\' OR OwnerID = \'005o0000001fZ7cAAE\' OR OwnerID = \'005o0000001zEZiAAM\') AND ID in (SELECT AccountID from AccountTeamMember)';            
            //String query = 'SELECT ID, OwnerID, Core_Covered_Account__c, Core_Account_Team_Audit_Complete__c from Account where (OwnerID = \'005o0000001fYw2AAE\' OR OwnerID = \'005o0000002GA8JAAW\' OR OwnerID = \'005o0000001zEZiAAM\' OR OwnerID = \'0057A000000WutRQAS\' OR OwnerID = \'005o0000001fIMJAA2\' ) AND ID in (SELECT AccountID from AccountTeamMember)';            
            //Gulshan:005o0000001fYw2AAE
            //David S Wong: 005o0000002GA8JAAW 
            //Uncovered Account: 005o0000001zEZiAAM
            //Carlos Piqueras: 005o0000001fZ7cAAE
            //Sales Rep 01: 0057A000000WutRQAS
            //Vendor Sales Center: 	005o0000001fIMJAA2

            //String query = 'select ID, OwnerID, Core_Covered_Account__c, Core_Account_Team_Audit_Complete__c from Account where ID in (SELECT AccountID from AccountTeamMember) LIMIT 5';            
            //String query = 'select ID, OwnerID, Core_Covered_Account__c, Core_Account_Team_Audit_Complete__c from Account where OwnerID = \'005o0000001fZ7cAAE\' and ID in (SELECT AccountID from AccountTeamMember)';            
            
            batchProcessing.Batch_Header__C = header.id;
            batchProcessing.Core_Email_Distribution_List__c = header.Email_Distribution_List__c;
            batchProcessing.Core_Salesforce_Job_Id__c = BC.getJobId();
            batchProcessing.Core_Batch_Query__c = query;            
            batchProcessing.Core_Object_Name__c = 'Account';
            batchProcessing.Core_Start_Date_Time__c = batchStartTime; 
            insert batchProcessing;

            //Integer auditDuration = Integer.valueOf(Core_Account_Team_Audit_Settings__c.getValues('AuditDurationDays').Core_Value__c);
            auditEndDate = getNextDueDate();//Date.today().addDays(auditDuration);
            
            return Database.getQuerylocator(query);
        }
        catch(Exception e){
            batchProcessing.Core_Exception_Log__c = e.getMessage();
            insert batchProcessing; 
            return null;
        }
    }
    global void execute(Database.BatchableContext BC, List<Account> scope) {
    	//Input: all accounts that have an account team
    	//Actions:
	    	//Mark all of these accounts as audit incomplete
	    	//Create Audit Log entries for each account
        try{
            if(scope.size() > batchSize)
            	batchSize = scope.size();
            List<Core_Audit_Log__c> logs = new List<Core_Audit_Log__c>();
            Core_Audit_Log__c newLog;
            for(Account acc : scope){
            	count++;
                acc.Core_Account_Team_Audit_Complete__c = false;
                acc.Core_Account_Team_Audit_Due_Date__c = auditEndDate;
                newLog = new Core_Audit_Log__c();
                newLog.Core_Account__c = acc.ID;
                newLog.Core_Event_Time__c = batchStartTime;
                newLog.Core_Event_Type__c = 'Account Team Audit';
                newLog.Core_Generated_By_User__c = UserInfo.getUserId();
                newLog.Core_Target_User__c = acc.OwnerId;
                logs.add(newLog);                
            }
            update scope;
            insert logs;
            
        }
        catch(Exception e){
        	batchProcessing.Core_Exception_Log__c = e.getMessage();
            update batchProcessing;
        }
    }
    global void finish(Database.BatchableContext BC) {
        batchProcessing.Core_Total_Number_of_Records__c = count;
        batchProcessing.Core_End_Date_Time__c = System.Now();
        batchProcessing.Core_Batch_Size__c = batchSize;        
        batchProcessing.Core_Send_Email__c = true;        
        update batchProcessing;

        if(executeNotificationBatch) {
        	//Run notifications batch with no escalation, as an initial notification
        	Database.executeBatch(new Core_Batch_AccountTeamAuditNotification(0, sendEmail, emailTemplateName, addTasks), 1000);
        }
    }

    private Date getNextDueDate() {
    	Map<String,Core_Account_Team_Audit_Schedule__c> settings; 
		settings = Core_Account_Team_Audit_Schedule__c.getAll();
    	Core_Account_Team_Audit_Schedule__c setting;
    	List<Date> dueDates = new List<Date>();
    	Date nextDueDate = Date.today();

		for(String key : settings.keySet()) {
			if(key.contains('Due Date'))
				dueDates.add(settings.get(key).Core_Execution_Month_Day__c);
		}

		Integer count = 0;
		if (dueDates.size() > 0) {			
			//increment nextDueDate until the day/month matches a due date in the schedule
			while (!dayMonthIsInDateList(nextDueDate,dueDates) && count < 366) {				
				nextDueDate = nextDueDate.addDays(1);
				count++;
			}
		}

		if(dueDates.size() == 0 || count >= 366)
		{ //calculate default due date based on AuditDurationDays, if a due date is not found in the schedule custom setting
			Integer auditDuration = Integer.valueOf(Core_Account_Team_Audit_Settings__c.getValues('AuditDurationDays').Core_Value__c);
			nextDueDate = nextDueDate.addDays(auditDuration);
		}

		return nextDueDate;
    }

    private Boolean dayMonthIsInDateList(Date dayMonth, List<Date> dateList) {
    	for(Date d:dateList) {
    		if(d.day() == dayMonth.day() && d.month() == dayMonth.month()) {
    			return true;    			
    		}
    	}
    	return false;
    }

}