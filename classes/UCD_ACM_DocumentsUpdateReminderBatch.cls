/*********************************************************************************************************************
Apex Class Name  : UCD_ACM_DocumentsUpdateReminderBatch
Author And Date  : Rohit Podder, 04 SEP 2026
Function         : An email notification will be sent to the account owner if twelve months have elapsed since the 
				   last document was uploaded to the account.
*********************************************************************************************************************/
public class UCD_ACM_DocumentsUpdateReminderBatch implements DataBase.Batchable<Sobject>, Schedulable  {
    @TestVisible
    private static Map<Id, Date> testLatestUploadDateByAccount;
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return  Database.getQueryLocator([SELECT Id, Name, OwnerId, Last_Reminder_Sent__c FROM Account WHERE RecordType.Name = 'Intel Account' AND Last_Reminder_Sent__c != Null]);
    }
    
    public void execute(Database.BatchableContext bc, List<Account> listAccounts){
        try{
            Set<Id> setAccountIds = new Set<Id>();
            for (Account acc : listAccounts) {
                setAccountIds.add(acc.Id);
            }
            
            Map<Id, Date> latestDateMap = getLatestUploadDateByAccount(setAccountIds);
            
            List<Account> accountsToRemind = new List<Account>();
            
            for (Account acc : listAccounts) {
                Date lastUploadDate   = latestDateMap.get(acc.Id);
                Date lastReminderDate = acc.Last_Reminder_Sent__c;
                
                if (lastUploadDate == null) continue;
                
                Boolean isTimeToRemind = isFirstWorkingDayAfter12Months(lastUploadDate);
                Boolean IsReminderNotSentRecently = (lastReminderDate == null || lastReminderDate < Date.today().addMonths(-12));
                System.debug(isTimeToRemind+' '+IsReminderNotSentRecently);
                if (isTimeToRemind && IsReminderNotSentRecently) {
                    acc.Last_Reminder_Sent__c = Date.today();
                    accountsToRemind.add(acc);
                }
            }
            
            if (!accountsToRemind.isEmpty()) {
                sendSalesforceNotification(accountsToRemind, latestDateMap);
                //sendEmailReminder(accountsToRemind, latestDateMap);
                List<Database.SaveResult> listSaveResults = DataBase.Update(accountsToRemind, false);
                                
                for (DataBase.SaveResult sr : listSaveResults) {
                    if(!sr.isSuccess()) {
                        UCD_ACM_Logger.error('UCD_ACM_DocumentsUpdateReminderBatch','execute',sr.getErrors() +' '+ sr.getId(), null);
                        UCD_ACM_Logger.setLogDetails();
                    }
                }
            }
        }catch(Exception e) {
            UCD_ACM_Logger.error('UCD_ACM_DocumentsUpdateReminderBatch','execute',e.getMessage()+' '+e.getStackTraceString(), null);
        }finally{
            UCD_ACM_Logger.setLogDetails();
        }
    }
    
    public void finish(Database.BatchableContext bc){
        UCD_ACM_Logger.information('UCD_ACM_DocumentsUpdateReminderBatch','finish','Batch class executed successfully', null);
        UCD_ACM_Logger.setLogDetails();
    }
    
    // Check if given date is a working day (Mon-Fri)
    public static Boolean isWorkingDay(Date d) {
        DateTime dt = DateTime.newInstance(d, Time.newInstance(0,0,0,0));
        String dayOfWeek = dt.format('EEEE');
        return (dayOfWeek != 'Saturday' && dayOfWeek != 'Sunday');
    }
    
    // Get next working day from a given date
    public static Date getNextWorkingDay(Date d) {
        Date nextDay = d.addDays(1);
        while (!isWorkingDay(nextDay)) {
            nextDay = nextDay.addDays(1);
        }
        return nextDay;
    }
    
    // Check if today is first working day after 12 months
    public static Boolean isFirstWorkingDayAfter12Months(Date lastUploadDate) {
        Date twelveMonthsLater = lastUploadDate.addMonths(12);
        Date firstWorkingDay  = twelveMonthsLater;
        
        // If 12 month date falls on weekend, get next working day
        if (!isWorkingDay(twelveMonthsLater)) {
            firstWorkingDay = getNextWorkingDay(twelveMonthsLater);
        }
        return (Date.today() == firstWorkingDay);
    }
    public static Map<Id, Date> getLatestUploadDateByAccount(Set<Id> setAccountIds) {
        
        if (Test.isRunningTest() && testLatestUploadDateByAccount != null) {
            return testLatestUploadDateByAccount;
        }
        
        Map<Id, Date> accountLatestDateMap = new Map<Id, Date>();
        List<String> searchDocument = new List<String>{'%CCD%', '%Customer Validation%', '%Customer_Validation%', '%Customer-Validation%', '%Customer Due Diligence%', '%Customer_Due_Diligence%', '%Customer-Due-Diligence%'};
        
        // ── Check ContentDocumentLink ──
        
        for (AggregateResult cdl : [SELECT LinkedEntityId , MAX(ContentDocument.LastModifiedDate)lastUploadDate FROM ContentDocumentLink WHERE LinkedEntityId IN :setAccountIds AND  LinkedEntity.Type = 'Account' AND ContentDocument.Title LIKE :searchDocument  GROUP BY LinkedEntityId]) {
            if (!accountLatestDateMap.containsKey((ID)cdl.get('LinkedEntityId'))) {//|| accountLatestDateMap.get(accId) < uploadDate) {
                accountLatestDateMap.put((Id)cdl.get('LinkedEntityId'), DateTime.valueOf(cdl.get('lastUploadDate')).date());
            }
        }
        
        // ── Check Classic Attachments ──
        
        for (AggregateResult att : [SELECT ParentId, MAX(LastModifiedDate)lastUploadDate FROM Attachment WHERE ParentId IN :setAccountIds AND Name LIKE :searchDocument GROUP BY ParentId]) {
            if (!accountLatestDateMap.containsKey((ID)att.get('ParentId')) || accountLatestDateMap.get((ID)att.get('ParentId')) < DateTime.valueOf(att.get('lastUploadDate')).date()) {
                accountLatestDateMap.put((ID)att.get('ParentId'), DateTime.valueOf(att.get('lastUploadDate')).date());
            }
        }
        
        if (Test.isRunningTest() && testLatestUploadDateByAccount != null) {
            return testLatestUploadDateByAccount;
        }
        return accountLatestDateMap;
    }
    
    //Send Salesforce Notification
    public static void sendSalesforceNotification(List<Account> listAccounts, Map<Id, Date> latestDateMap) {
        CustomNotificationType notifType = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'Account_Document_Reminder' LIMIT 1];
                
        for (Account acc : listAccounts) {
            Date lastDate = latestDateMap.get(acc.Id);
            
            Messaging.CustomNotification notif = new Messaging.CustomNotification();
            notif.setNotificationTypeId(notifType.Id);
            notif.setTargetId(acc.Id);
            notif.setTitle('Action Required: ');
            notif.setBody('Please update Customer Due Diligence file for Account - '+ acc.name);           
            notif.send(new Set<String>{acc.OwnerId});
        }
    }
    
    // Send Outlook Email
    /*public static void sendEmailReminder(List<Account> listAccounts, Map<Id, Date> latestDateMap) {
        
        List<Messaging.SingleEmailMessage> listEmails = new List<Messaging.SingleEmailMessage>();
        List<String> listFailedEmails = new List<String>();
        EmailTemplate template = [SELECT ID FROM EmailTemplate WHERE Name = 'ACM Document Reminder Notification Template' LIMIT 1];
        
        for (Account acc : listAccounts) {
            Date lastDate  = latestDateMap.get(acc.Id);
            Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(template.Id,acc.ownerId,acc.Id);
            email.setTargetObjectId(acc.OwnerId);  // User receiving email
            email.setSaveAsActivity(false);
            email.setOrgWideEmailAddressId(Label.Core_Ownership_Orgwide_Email_Id);
            listEmails.add(email);
        }
        
        if (!listEmails.isEmpty()) {
            Messaging.SendEmailResult[] emailResult = Messaging.sendEmail(listEmails);
            
            for (Messaging.SendEmailResult ser : emailResult) {
                if(!ser.isSuccess()) {
                    listFailedEmails.add(String.join(ser.getErrors(),' '));
                }
            }
            if (!listFailedEmails.isEmpty() && listFailedEmails.size() > 0) {
                UCD_ACM_Logger.information('UCD_ACM_DocumentsUpdateReminderBatch','sendEmailReminder',String.join(listFailedEmails,','), null);
                UCD_ACM_Logger.setLogDetails();
            }  
        }
    }*/
    
    //Schedule batch class to run everyday one time
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new UCD_ACM_DocumentsUpdateReminderBatch());
    }
}