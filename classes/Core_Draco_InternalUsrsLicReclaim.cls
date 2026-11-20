/**************************************************************************************
Apex Class Name : Core_Draco_InternalUsrsLicReclaim
Test class : Core_Draco_InternalUsrsLicReclaim_Test
Code Coverage : 100%
Version     : 1.0 
Created Date: 3rd October 2025
Description : This scheduled class sends an email on 1st of every month with an attachment of list of internal users who are not loggedin to salesforce from 45 days or more
* Modification Log : 
* Developer                 Date               		Description
* ----------------------------------------------------------------------------
* Sharmila                  03-Oct-2025             	Original Version
*************************************************************************************/
public with sharing class Core_Draco_InternalUsrsLicReclaim implements Schedulable{
    public void execute(SchedulableContext SC){
        try{
            // Get the threshold from the custom label and convert to integer
            Integer thresholdDays = Integer.valueOf(Label.IntUsrsLicRecLastNDays);
            List<String> exclusionUserIds = Label.exclusionUserIds.split(',');
            // Build dynamic SOQL query string with label value
            String queryString = 'SELECT Id, Name, Email, FederationIdentifier, Profile.Name, IsActive, Username, CreatedDate, LastLoginDate ' +
                'FROM User ' +
                'WHERE UserType = \'Standard\' ' +
                'AND Profile.UserLicense.Name = \'Salesforce\' ' +
                'AND IsActive = true ' +
                'AND (LastLoginDate < LAST_N_DAYS:' + thresholdDays + 
                ' OR (LastLoginDate = NULL AND CreatedDate < LAST_N_DAYS:' + thresholdDays + ')) ' +
                'AND FederationIdentifier != NULL ' +
                'AND Core_Is_HQ_User__c = FALSE ' +
                ' AND Id Not IN '+exclusionUserIds+
                ' AND Id NOT IN (SELECT OwnerId FROM Case WHERE IsClosed = FALSE AND LastModifiedDate = LAST_N_DAYS:365) ' +
                'ORDER BY LastLoginDate DESC';
            List<User> users = Database.query(queryString);        
            List<String> emailAddresses = new List<String>();
            List<String> csvRows = new List<String>();  // To store CSV rows
            
            // Add CSV header
            String csvHeader = 'Id,Name,Email,FederationIdentifier,Profile.Name,Username,CreatedDate,LastLoginDate';
            csvRows.add(csvHeader);
            
            // Add data to CSV
            for (User u : users) {
                if (u.Email != null) {
                    String row = String.join(new String[] {
                        u.Id,
                            u.Name != null ? u.Name : 'N/A',
                                u.Email,
                                u.FederationIdentifier != null ? u.FederationIdentifier : 'N/A',
                                    u.Profile.Name != null ? u.Profile.Name : 'N/A',
                                        u.Username != null ? u.Username : 'N/A',
                                            u.CreatedDate != null ? u.CreatedDate.format('yyyy-MM-dd') : 'N/A',
                                                u.LastLoginDate != null ? u.LastLoginDate.format('yyyy-MM-dd') : 'N/A'
                                                    }, ',');
                    csvRows.add(row);
                    emailAddresses.add(u.Email);
                }
            }
            
            // Join rows into CSV body
            String fullCsv = String.join(csvRows, '\n');
            
            // Create attachment
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName('Inactive Users Deactivation.csv');
            attachment.setBody(Blob.valueOf(fullCsv));
            attachment.setContentType('text/csv');
            
            // Send email with the list of users
            if (emailAddresses.size() > 0) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = Label.InternalUsersLicenseReclaim.split(';');
                String[] ccAddresses = Label.InternalUsersLicenseReclaimCCAddress.split(';');
                mail.setToAddresses(toAddresses);
                mail.setCCAddresses(ccAddresses);
                OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'wsm-postmaster@intel.com'];
                if ( owea.size() > 0 ) {
                    mail.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                mail.setSubject('License Reclaim For Internal Users UIOLI - '+system.now().format('MMMM')+','+system.today().year()+' - PROD Sales Cloud');
                mail.setPlainTextBody(label.InternalUsersLicenseReclaimEmailBody);
                mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }, false);
            }
        }catch(exception e){
            Core_Log_Entry__c logEntry = new Core_Log_Entry__c( Core_Message__c = 'Error in class Core_Draco_InternalUsrsLicReclaim',Core_Project__c = 'Draco',Core_Origin__c = 'Core_Draco_InternalUsrsLicReclaim',Core_Details__c = e.getMessage(),Core_Severity__c = 'Error',Core_When__c = System.now());
            Database.insert(logEntry, false);
        }
    }
}