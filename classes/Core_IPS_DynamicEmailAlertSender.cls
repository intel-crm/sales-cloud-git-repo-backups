public class Core_IPS_DynamicEmailAlertSender {
    //  Used only in test class (to avoid MDT DML)
    @TestVisible
    private static List<Email_Config_mdt__mdt> testConfigs;
    
    @InvocableMethod(label='Send Emails Using Email Config MDT')
    public static void sendEmails(List<EmailRequest> requests) {

        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();

        for (EmailRequest req : requests) {

            try {

                               // Fetch Metadata Config (Test Safe)
                List<Email_Config_mdt__mdt> configs;

                if (Test.isRunningTest() && testConfigs != null) {
                    configs = testConfigs;
                } else {
                    configs = [
                        SELECT Email_Template__c,
                               Recipient_Type__c,
                               Selected_Recipients__c
                        FROM Email_Config_mdt__mdt
                        WHERE Email_Alert_Name__c = :req.emailAlertName
                    ];
                }


                if (configs.isEmpty()) continue;

                // Get Template
                String templateDevName = configs[0].Email_Template__c;

                List<EmailTemplate> templates = [
                    SELECT Id 
                    FROM EmailTemplate 
                    WHERE DeveloperName = :templateDevName 
                    LIMIT 1
                ];

                if (templates.isEmpty()) continue;

                Id templateId = templates[0].Id;

                // Collect Recipients
                Set<String> allEmails = new Set<String>();

                for (Email_Config_mdt__mdt cfg : configs) {
                    allEmails.addAll(
                        getRecipients(
                            cfg.Recipient_Type__c,
                            cfg.Selected_Recipients__c,
                            req.recordId
                        )
                    );
                }

                //  IMPORTANT: Skip if no recipients
                if (allEmails.isEmpty()) {
                    System.debug('No recipients found for: ' + req.emailAlertName);
                    continue;
                }

                // Create Email
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTemplateId(templateId);
                mail.setToAddresses(new List<String>(allEmails));
                mail.setWhatId(req.recordId);
                mail.setSaveAsActivity(false);

                emailList.add(mail);

            } catch (Exception e) {
                // DO NOT FAIL FLOW
                System.debug('Email skipped due to error: ' + e.getMessage());
                continue;
            }
        }

        // Send emails safely
        if (!emailList.isEmpty()) {
            try {
                Messaging.sendEmail(emailList);
            } catch (Exception e) {
                System.debug('Email sending failed: ' + e.getMessage());
            }
        }
    }

    // =====================================================
    // RECIPIENT LOGIC
    // =====================================================
    private static List<String> getRecipients(String type, String value, Id recordId) {

        List<String> emails = new List<String>();

        if (recordId == null) return emails;

        SObject record = Database.query(
            'SELECT Id, OwnerId, CreatedById, AccountId FROM ' +
            recordId.getSObjectType() +
            ' WHERE Id = :recordId'
        );

        // ===========================
        // OWNER
        // ===========================
        if (type == 'Owner') {
            emails.addAll(getUserEmail((Id)record.get('OwnerId')));
        }

        // ===========================
        // CREATOR
        // ===========================
        else if (type == 'Creator') {
            emails.addAll(getUserEmail((Id)record.get('CreatedById')));
        }

        // ===========================
        // USER (Direct Id)
        // ===========================
        else if (type == 'User') {
            if (value != null) {
                emails.addAll(getUserEmail((Id)value));
            }
        }

        // ===========================
        // ACCOUNT OWNER
        // ===========================
        else if (type == 'Account Owner') {

            Object accObj = record.get('AccountId');

            if (accObj != null && accObj instanceof Id) {

                Account acc = [
                    SELECT OwnerId 
                    FROM Account 
                    WHERE Id = :(Id)accObj
                    LIMIT 1
                ];

                emails.addAll(getUserEmail(acc.OwnerId));
            }
        }

        // ===========================
        // ROLE
        // ===========================
        else if (type == 'Role') {

            for (User u : [
                SELECT Email 
                FROM User
                WHERE UserRole.Name = :value AND IsActive = TRUE
            ]) {
                if (u.Email != null) emails.add(u.Email);
            }
        }

        // ===========================
        // ROLE + SUBORDINATES
        // ===========================
        else if (type == 'Role and Subordinates') {

            Set<Id> roleIds = getRoleHierarchy(value);

            for (User u : [
                SELECT Email 
                FROM User
                WHERE UserRoleId IN :roleIds AND IsActive = TRUE
            ]) {
                if (u.Email != null) emails.add(u.Email);
            }
        }

        // ===========================
        // PUBLIC GROUP
        // ===========================
        else if (type == 'Public Groups') {

            for (GroupMember gm : [
                SELECT UserOrGroupId
                FROM GroupMember
                WHERE Group.Name = :value
            ]) {
                emails.addAll(getUserEmail(gm.UserOrGroupId));
            }
        }

        // ===========================
        // EMAIL FIELD
        // ===========================
        else if (type == 'Email Field') {

            Object fieldVal = record.get(value);

            if (fieldVal != null) {
                emails.add(String.valueOf(fieldVal));
            }
        }

        // ===========================
        // RELATED USER
        // ===========================
        else if (type == 'Related User') {

            Object userObj = record.get(value);

            if (userObj != null && userObj instanceof Id) {
                emails.addAll(getUserEmail((Id)userObj));
            }
        }

        // ===========================
        // RELATED CONTACT
        // ===========================
        else if (type == 'Related Contact') {

            Object contactObj = record.get(value);

            if (contactObj != null && contactObj instanceof Id) {

                Contact c = [
                    SELECT Email 
                    FROM Contact 
                    WHERE Id = :(Id)contactObj
                    LIMIT 1
                ];

                if (c.Email != null) emails.add(c.Email);
            }
        }

        // ===========================
        // CASE TEAM (WITH ROLE FILTER)
        // ===========================
        else if (type == 'Case Team') {

            for (CaseTeamMember ctm : [
                SELECT MemberId
                FROM CaseTeamMember
                WHERE ParentId = :recordId
                AND TeamRole.Name = :value
            ]) {
                emails.addAll(getUserEmail(ctm.MemberId));
            }
        }

        return emails;
    }

    // =====================================================
    //  USER EMAIL
    // =====================================================
    private static List<String> getUserEmail(Id userId) {

        List<String> emails = new List<String>();

        if (userId == null) return emails;

        for (User u : [
            SELECT Email 
            FROM User 
            WHERE Id = :userId AND IsActive = TRUE
        ]) {
            if (u.Email != null) {
                emails.add(u.Email);
            }
        }

        return emails;
    }

    // =====================================================
    //  ROLE HIERARCHY
    // =====================================================
    private static Set<Id> getRoleHierarchy(String roleName) {

        Set<Id> roleIds = new Set<Id>();

        for (UserRole ur : [
            SELECT Id 
            FROM UserRole 
            WHERE Name = :roleName
        ]) {
            roleIds.add(ur.Id);
        }

        return roleIds;
    }

    // =====================================================
    // FLOW INPUT
    // =====================================================
    public class EmailRequest {

        @InvocableVariable(required=true)
        public String emailAlertName;

        @InvocableVariable(required=true)
        public Id recordId;
    }
}