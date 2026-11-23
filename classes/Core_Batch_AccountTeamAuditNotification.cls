global class Core_Batch_AccountTeamAuditNotification implements Database.Batchable<sObject>,Database.Stateful { 
    global Core_Batch_Processing__c batchProcessing;
    global Integer count = 0;
    global Integer batchSize = 0;
    global Datetime batchStartTime = System.now();
    global Date dueDate;
    global Integer escalationLevel = 0;
    global Set<Id> ownersReceivingNotifications = new Set<Id>();
    global boolean sendEmail = false;
    global boolean addTasks = false;
    global List<Account> uncoveredAccountInstance = new List<Account>();
    global String emailTemplateName;
    global EmailTemplate template;
    global Map<String,Core_Account_Team_Audit_Settings__c> settings; 
    global Id orgWideEmailId;
    Map<String, Core_ACM_Control_Execution__c> mapAcmClassCheckToEol = Core_ACM_Control_Execution__c.getAll();
    //Constructor accepts batch parameters
    public Core_Batch_AccountTeamAuditNotification(Integer escalationLevelParam, boolean sendEmailParam, String emailTemplateNameParam, boolean addTasksParam) {
        escalationLevel = escalationLevelParam;
        sendEmail = sendEmailParam;
        emailTemplateName = emailTemplateNameParam;
        addTasks = addTasksParam; 
    }
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        batchProcessing = new Core_Batch_Processing__c();        
        if(mapAcmClassCheckToEol.containsKey('Account_TeamAuditNotification') && mapAcmClassCheckToEol.get('Account_TeamAuditNotification').IsActive__c) {
            Core_Batch_header__c header=AccountTeamBatchHandler.getHeader('Core_Batch_AccountTeamAuditNotification');
            try{
                //Get all accounts that need to be audited
                String query = 'Select ID,OwnerId,Owner.Name,Owner.Manager.Email,Owner.Manager.Manager.Email,Owner.Manager.Manager.Manager.Email,Core_Account_Team_Audit_Due_Date__c,Core_Covered_Account__c From Account Where Core_Account_Team_Audit_Complete__c = false';            
                batchProcessing.Batch_Header__C = header.id;
                batchProcessing.Core_Email_Distribution_List__c = header.Email_Distribution_List__c;
                batchProcessing.Core_Salesforce_Job_Id__c = BC.getJobId();
                batchProcessing.Core_Batch_Query__c = query;            
                batchProcessing.Core_Object_Name__c = 'Account';            
                batchProcessing.Core_Start_Date_Time__c = batchStartTime;            
                template = [Select Id,Name From EmailTemplate Where Name = :emailTemplateName]; 
                settings = Core_Account_Team_Audit_Settings__c.getAll();           		            
                if (sendEmail) {
                    String orgWideEmailName = settings.get('OrgWideEmailDisplayName').Core_Value__c;
                    OrgWideEmailAddress[] oweList = [Select Id From OrgWideEmailAddress Where DisplayName = :orgWideEmailName];
                    if(oweList.size() > 0)
                        orgWideEmailId = oweList[0].Id;
                }
                insert batchProcessing;
                /* //THIS DEBUG CODE CANNOT BE ENABLED IN PRODUCTION
System.debug('logging accounts found in Start');
List<Account> accountsDebug = [Select ID,OwnerId,Owner.Name,Owner.Manager.Email,Owner.Manager.Manager.Email,Owner.Manager.Manager.Manager.Email,Core_Account_Team_Audit_Due_Date__c,Core_Covered_Account__c From Account Where Core_Account_Team_Audit_Complete__c = false];
for (Account a:accountsDebug) {
System.debug(a);
}*/
                return Database.getQuerylocator(query);
            }
            catch(Exception e){
                batchProcessing.Core_Exception_Log__c = e.getMessage();
                System.debug(e.getMessage());
                insert batchProcessing;
                return null;
            }
        }
        else
        {       
            return Database.getQuerylocator('');  
        }
        
    }
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        //Input: all accounts that need auditing
        //Action: send an email for each unique account owner of these accounts.  Also, if this is an initial notification, generate a task for each owner.
        try {
            if(scope.size() > batchSize)
                batchSize = scope.size();
            List<Account> accountsToEmail = new List<Account>();
            for(Account acc : scope){
                count++;               
                
                //Weed out uncovered accounts
                if(acc.Core_Covered_Account__c == false) {
                    if (uncoveredAccountInstance.size() < 1)
                        uncoveredAccountInstance.add(acc);
                }
                //Make sure owners only receive one email/task even across batches.
                else if (!ownersReceivingNotifications.contains(acc.OwnerId)) {		
                    ownersReceivingNotifications.add(acc.OwnerId);
                    //Only need one account per owner to generate a single email per owner
                    accountsToEmail.add(acc); 
                    //System.debug('Adding to email list:' + acc.Owner.Name);
                }
            }
            
            List<Task> tasks = new List<Task>();
            Task newTask;
            
            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail;
            List<String> ccAddresses = new List<String>();
            List<Core_Audit_Log__c> logs = new List<Core_Audit_Log__c>();
            Core_Audit_Log__c newLog;
            for(Account acc:accountsToEmail){
                mail = new Messaging.SingleEmailMessage();
                ccAddresses = new List<String>();
                newLog = new Core_Audit_Log__c();
                newLog.Core_Comment__c = '';
                if (addTasks) {
                    newTask = new Task();    				
                    newTask.ActivityDate = acc.Core_Account_Team_Audit_Due_Date__c;
                    newTask.OwnerId = acc.OwnerId;
                    newTask.Description = 'Please visit this page to review Account Teams and access levels for the Accounts you own: ' +   System.URL.getSalesforceBaseURL().toExternalForm() + '/' + settings.get('AuditPageURL').Core_Value__c;
                    newTask.Subject = settings.get('DefaultTaskSubject').Core_Value__c; 
                    newTask.Status = settings.get('DefaultTaskStatus').Core_Value__c; 
                    newTask.Priority = settings.get('DefaultTaskPriority').Core_Value__c; 
                    tasks.add(newTask);       
                }
                //If escalating to manager(s), add to ccAddresses list, and log the managers being sent to
                if (escalationLevel > 0) {
                    newLog.Core_Comment__c += 'escalationLevel:' + escalationLevel + ';';
                    if (escalationLevel >=3 && !String.isBlank(acc.Owner.Manager.Manager.Manager.Email)) 
                        ccAddresses.add(acc.Owner.Manager.Manager.Manager.Email);            		
                    if (escalationLevel >=2 && !String.isBlank(acc.Owner.Manager.Manager.Email)) 
                        ccAddresses.add(acc.Owner.Manager.Manager.Email); 
                    if (escalationLevel >= 1 && !String.isBlank(acc.Owner.Manager.Email)) 
                        ccAddresses.add(acc.Owner.Manager.Email); 
                    
                    if(ccAddresses.size() > 0) {           				
                        mail.setCCAddresses(ccAddresses);
                        newLog.Core_Comment__c += 'ccAddresses:';
                        for(String address:ccAddresses) {
                            newLog.Core_Comment__c += (address + ';');
                        }
                    }
                    else
                        newLog.Core_Comment__c += 'No escalation address(es) found;';	
                }
                
                mail.setWhatId(acc.Id);
                mail.setTemplateId(template.Id);
                mail.setTargetObjectId(acc.OwnerId);
                if (orgWideEmailId != null)
                    mail.setOrgWideEmailAddressId(orgWideEmailId);
                mail.saveAsActivity = false;          
                mailList.add(mail);
                newLog.Core_Event_Time__c = batchStartTime;
                newLog.Core_Event_Type__c = 'Account Team Audit Notification';
                newLog.Core_Generated_By_User__c = UserInfo.getUserId();
                newLog.Core_Target_User__c = acc.OwnerId;
                newLog.Core_Comment__c += 'Template:' + template.Name + ';';
                logs.add(newLog);
            }      	
            if(sendEmail)
                Messaging.sendEmail(mailList);           	
            insert logs;
            if(addTasks)
                insert tasks;
        }
        catch(Exception e){
            batchProcessing.Core_Exception_Log__c = e.getMessage();
            System.debug(e.getMessage());
            update batchProcessing;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        if(mapAcmClassCheckToEol.containsKey('Account_TeamAuditNotification') && mapAcmClassCheckToEol.get('Account_TeamAuditNotification').IsActive__c) {
            batchProcessing.Core_Total_Number_of_Records__c = count;
            batchProcessing.Core_End_Date_Time__c = System.Now();
            batchProcessing.Core_Batch_Size__c = batchSize;        
            batchProcessing.Core_Send_Email__c = true;                
            update batchProcessing;
            if(uncoveredAccountInstance.size() > 0)
                handleUncoveredAccounts();
        }
    }
    private void handleUncoveredAccounts() {
        try {
            //Find the Intel Covered Accounts user who should be notified in this custom setting
            String searchStr = settings.get('UncoveredAccountsUser').Core_Value__c;
            String formattedSearchStr = '%' + searchStr + '%';
            User icaUser = [SELECT Id FROM User WHERE Email LIKE :formattedSearchStr OR Id = :searchStr LIMIT 1];
            if (addTasks) {
                Task newTask = new Task();    				
                newTask.ActivityDate = uncoveredAccountInstance.get(0).Core_Account_Team_Audit_Due_Date__c;
                newTask.OwnerId = icaUser.Id;
                newTask.Description = 'Please visit this page to review Account Teams and access levels for uncovered Accounts that have Team Members: ' + System.URL.getSalesforceBaseURL().toExternalForm() + '/' + settings.get('AuditPageURL').Core_Value__c;
                newTask.Subject = settings.get('DefaultTaskSubject').Core_Value__c; 
                newTask.Status = settings.get('DefaultTaskStatus').Core_Value__c; 
                newTask.Priority = settings.get('DefaultTaskPriority').Core_Value__c; 
                insert newTask;  
            }
            
            String templateName = settings.get('UncoveredAccountsEmailTemplateName').Core_Value__c; 
            EmailTemplate template = [Select Id,Name From EmailTemplate Where Name = :templateName];
            if(sendEmail) {			 		
                List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setWhatId(uncoveredAccountInstance.get(0).Id);
                mail.setTemplateId(template.Id);
                mail.setTargetObjectId(icaUser.Id);
                mail.saveAsActivity = false;    
                mailList.add(mail);
                Messaging.sendEmail(mailList); 
            }
            Core_Audit_Log__c newLog = new Core_Audit_Log__c();
            newLog.Core_Comment__c = 'Uncovered Account Notification;';
            newLog.Core_Event_Time__c = batchStartTime;
            newLog.Core_Event_Type__c = 'Account Team Audit Notification';
            newLog.Core_Generated_By_User__c = UserInfo.getUserId();
            newLog.Core_Target_User__c = icaUser.Id;
            newLog.Core_Comment__c += 'Template:' + template.Name + ';';
            insert newLog; 
        }
        catch(Exception e){
            batchProcessing.Core_Exception_Log__c = e.getMessage();
            System.debug(e.getMessage());
            update batchProcessing;
        }
    }
}