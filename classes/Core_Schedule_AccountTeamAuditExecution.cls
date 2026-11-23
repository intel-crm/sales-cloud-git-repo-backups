/***************************************************************************************************************************************************************************************************
Apex Class Name:  Core_Schedule_AccountTeamAuditExecution
Version     : 1.0 
Created Date: 5/24/16 
Function    : Schedulable class that checks the Core_Account_Team_Audit_Schedule__c 
			  custom setting to see if today has a batch job assigned, and runs the 
			  associated batch job if found.
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* David S Wong              5/24/16                Development Start
*****************************************************************************************************************************************************************************************************/
global class Core_Schedule_AccountTeamAuditExecution implements Schedulable {
	global void execute(SchedulableContext sc) {
		Map<String,Core_Account_Team_Audit_Schedule__c> settings; 
		settings = Core_Account_Team_Audit_Schedule__c.getAll();

		Core_Account_Team_Audit_Schedule__c setting;

		for(String key : settings.keySet()) {
			setting = settings.get(key);
			if(setting.Core_Execution_Month_Day__c.day() == Date.today().day() && 
				setting.Core_Execution_Month_Day__c.month() == Date.today().month()) {
				executeAccountTeamAuditEvent(setting.Name, Integer.valueOf(setting.Core_Escalation_Level__c), setting.Core_Email_Template__c);
			}
		}
	}

	private void executeAccountTeamAuditEvent(String eventName, Integer escalationLevel, String emailTemplateName) {
		if (eventName.contains('Audit Reset'))		
			Database.executeBatch(new Core_Batch_AccountTeamAuditInitialize(), 1000);
		else if (eventName.contains('Kickoff Audit'))		
			Database.executebatch(new Core_Batch_AccountTeamAuditKickoff(false, false, emailTemplateName, false), 1000);	
		else if (eventName.contains('Kickoff Audit and Notify'))
			Database.executebatch(new Core_Batch_AccountTeamAuditKickoff(true, false, emailTemplateName, false), 1000); //TODO enable email and task generation
		else if (eventName.contains('Initial Notification'))	
			Database.executebatch(new Core_Batch_AccountTeamAuditNotification(escalationLevel, true, emailTemplateName, true), 200); //TODO enable email and task generation
		else if (eventName.contains('Reminder'))
			Database.executebatch(new Core_Batch_AccountTeamAuditNotification(escalationLevel, true, emailTemplateName, false), 200);	//TODO enable email 
		else if (eventName.contains('Escalation'))
			Database.executebatch(new Core_Batch_AccountTeamAuditNotification(escalationLevel, true, emailTemplateName, false), 200); //TODO enable email
	}
}