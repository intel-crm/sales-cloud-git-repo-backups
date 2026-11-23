/******************************************************************************************************************************************
Class Name  : WOM_InboundEmailContactHandler
Created Date: 23 July 2026
Function    : Inbound Email Service handler to parse WOM access request emails,
              create Contact records, associate entitlements, and link to Customer Master File Groups.
              Supports both single-contact email body format and bulk CSV file attachments.
******************************************************************************************************************************************/
public class WOM_InboundEmailContactHandler implements Messaging.InboundEmailHandler {

    // CSV Column name constants
    public static final String COL_FIRST_NAME = 'First Name';
    public static final String COL_LAST_NAME = 'Last Name';
    public static final String COL_EMAIL = 'Email Address';
    public static final String COL_ACCOUNT_NAME = 'Account Name';
    public static final String COL_MAILING_COUNTRY = 'Mailing Country';
    public static final String COL_MAILING_STREET = 'Mailing Street';
    public static final String COL_MAILING_CITY = 'Mailing City';
    public static final String COL_MAILING_STATE = 'Mailing State/Province';
    public static final String COL_MAILING_POSTAL_CODE = 'Mailing Postal Code';
    public static final String COL_ENTITLEMENTS = 'Entitlements';
    public static final String COL_CMF_GROUP = 'Customer Master File Group';

    public Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        result.success = true;

        try {
            // Check for CSV attachment for bulk processing
            if (email.textAttachments != null && !email.textAttachments.isEmpty()) {
                for (Messaging.InboundEmail.TextAttachment attachment : email.textAttachments) {
                    if (attachment.fileName != null && (attachment.fileName.endsWithIgnoreCase('.csv'))) {
                        processBulkCSV(attachment.body);
                        return result;
                    }
                }
            }

            // Fall back to single-contact email body parsing
            String body = email.plainTextBody;
            if (String.isBlank(body)) {
                result.success = false;
                result.message = 'Email body is empty and no CSV attachment found.';
                return result;
            }

            // Parse sections
            Map<String, String> contactInfo = parseSection(body, 'CONTACT INFORMATION');
            Map<String, String> entitlements = parseSection(body, 'WOM ACCESS ENTITLEMENTS');
            Map<String, String> association = parseSection(body, 'CONTACT ASSOCIATION');

            // Resolve Account
            String accountName = contactInfo.get('Account Name');
            if (String.isBlank(accountName)) {
                result.success = false;
                result.message = 'Account Name not found in email.';
                return result;
            }

            List<Account> accounts = [SELECT Id FROM Account WHERE Name = :accountName LIMIT 1];
            if (accounts.isEmpty()) {
                result.success = false;
                result.message = 'Account not found: ' + accountName;
                return result;
            }
            Id accountId = accounts[0].Id;

            // Build mailing address
            String mailingStreet = contactInfo.get('Mailing Street');
            String mailingCity = contactInfo.get('Mailing City');
            String mailingState = contactInfo.get('Mailing State/Province');
            String mailingPostalCode = contactInfo.get('Mailing Postal Code');
            String mailingCountry = contactInfo.get('Mailing Country');

            // Create Contact
            String email1 = contactInfo.get('Email Address');
            System.debug(email1);
            Contact newContact = new Contact();
            newContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId();
            newContact.FirstName = contactInfo.get('First Name');
            newContact.LastName = contactInfo.get('Last Name');
            newContact.Email =   email1.contains('<') ? email1.split('<')[0] : email1;
            newContact.AccountId = accountId;
            newContact.MailingStreet = mailingStreet;
            newContact.MailingCity = mailingCity;
            newContact.MailingState = mailingState;
            newContact.MailingPostalCode = mailingPostalCode;
            newContact.MailingCountry = mailingCountry;
            newContact.Core_Login_Status__c = 'Active';

            insert newContact;

            // Associate Entitlements
            List<String> entitlementNames = new List<String>();
            for (String key : entitlements.keySet()) {
                if (entitlements.get(key).equalsIgnoreCase('Yes')) {
                    entitlementNames.add(key);
                }
            }

            if (!entitlementNames.isEmpty()) {
                Map<String, Id> entitlementIdMap = new Map<String, Id>();
                for (Core_Entitlement__c ent : [SELECT Id, Name,Core_Display_Name__c FROM Core_Entitlement__c WHERE (Name IN :entitlementNames OR Core_Display_Name__c IN :entitlementNames) AND Core_IsActive__c = true]) {
                    String Ename = entitlementNames.contains(ent.Core_Display_Name__c) ? ent.Core_Display_Name__c : ent.Name;
                    entitlementIdMap.put(Ename, ent.Id);
                    System.debug(ent);
                }
                System.enqueueJob(new ACM_ContactAddEnttls(entitlementIdMap,entitlementNames,newContact.Id),10);

                //WOM_InboundEmailContactHandler.createEnttls(entitlementIdMap,entitlementNames,newContact.Id);
                // List<Core_Contact_Entitlement__c> contactEntitlements = new List<Core_Contact_Entitlement__c>();
                // for (String entName : entitlementNames) {
                //     if (entitlementIdMap.containsKey(entName)) {
                //         contactEntitlements.add(new Core_Contact_Entitlement__c(
                //             Core_Contact_Id__c = newContact.Id,
                //             Core_Entitlement_Id__c = entitlementIdMap.get(entName),
                //             Core_Selected__c = true,
                //             Core_From_Source__c = false,
                //             Core_Update_Reason__c = 'WOM Email Request',
                //             //Core_Data_Loaded__c = true,
                //             Core_Status__c = 'Complete'
                //         ));
                //     }
                // }

                // if (!contactEntitlements.isEmpty()) {
                //     insert contactEntitlements;
                // }
            }

            // Associate to Customer Master File Group
            String cmfGroupName = association.get('Customer Master File Group');
            if (String.isNotBlank(cmfGroupName)) {
                List<ER_Customer_Master_File_Group__c> cmfGroups = [SELECT Id FROM ER_Customer_Master_File_Group__c WHERE Name = :cmfGroupName AND ER_Active__c = true LIMIT 1];
                if (!cmfGroups.isEmpty()) {
                    ER_ContactGroupAssociation__c cga = new ER_ContactGroupAssociation__c(
                        ER_Contact__c = newContact.Id,
                        ER_Customer_Master_File_Group__c = cmfGroups[0].Id,
                        ER_Active__c = true
                    );
                    insert cga;
                }
            }

        } catch (Exception ex) {
            result.success = false;
            result.message = ex.getTypeName() + ': ' + ex.getMessage();
        }

        return result;
    }

    @future
    public static void createEnttls(Map<String, Id> entitlementIdMap,List<String> entitlementNames, ID newContact){
        List<Core_Contact_Entitlement__c> contactEntitlements = new List<Core_Contact_Entitlement__c>();
                for (String entName : entitlementNames) {
                    if (entitlementIdMap.containsKey(entName)) {
                        contactEntitlements.add(new Core_Contact_Entitlement__c(
                            Core_Contact_Id__c = newContact,
                            Core_Entitlement_Id__c = entitlementIdMap.get(entName),
                            Core_Selected__c = true,
                            Core_From_Source__c = false,
                            Core_Update_Reason__c = 'WOM Email Request',
                            //Core_Data_Loaded__c = true,
                            Core_Status__c = 'Complete'
                        ));
                    }
                }

                if (!contactEntitlements.isEmpty()) {
                    insert contactEntitlements;
                }
    }

    /**
     * Processes a CSV file for bulk contact creation.
     * Each row creates a Contact, associates entitlements, and links to CMF Group.
     */
    private void processBulkCSV(String csvBody) {
        List<List<String>> parsedRows = parseCSV(csvBody);
        if (parsedRows.isEmpty()) return;

        // First row is header
        List<String> headers = parsedRows[0];
        Map<String, Integer> headerIndex = new Map<String, Integer>();
        for (Integer i = 0; i < headers.size(); i++) {
            headerIndex.put(headers[i].trim(), i);
        }

        // Collect all account names and CMF group names for bulk queries
        Set<String> accountNames = new Set<String>();
        Set<String> cmfGroupNames = new Set<String>();
        Set<String> allEntitlementNames = new Set<String>();

        List<Map<String, String>> rowDataList = new List<Map<String, String>>();

        for (Integer r = 1; r < parsedRows.size(); r++) {
            List<String> row = parsedRows[r];
            Map<String, String> rowData = new Map<String, String>();
            for (String header : headerIndex.keySet()) {
                Integer idx = headerIndex.get(header);
                rowData.put(header, idx < row.size() ? row[idx].trim() : '');
            }
            rowDataList.add(rowData);

            if (String.isNotBlank(rowData.get(COL_ACCOUNT_NAME))) {
                accountNames.add(rowData.get(COL_ACCOUNT_NAME));
            }
            if (String.isNotBlank(rowData.get(COL_CMF_GROUP))) {
                cmfGroupNames.add(rowData.get(COL_CMF_GROUP));
            }
            if (String.isNotBlank(rowData.get(COL_ENTITLEMENTS))) {
                for (String ent : rowData.get(COL_ENTITLEMENTS).split(';')) {
                    allEntitlementNames.add(ent.trim());
                }
            }
        }

        // Bulk query accounts
        Map<String, Id> accountMap = new Map<String, Id>();
        for (Account acc : [SELECT Id, Name FROM Account WHERE Name IN :accountNames]) {
            accountMap.put(acc.Name, acc.Id);
        }

        // Bulk query CMF Groups
        Map<String, Id> cmfGroupMap = new Map<String, Id>();
        for (ER_Customer_Master_File_Group__c grp : [SELECT Id, Name FROM ER_Customer_Master_File_Group__c WHERE Name IN :cmfGroupNames AND ER_Active__c = true]) {
            cmfGroupMap.put(grp.Name, grp.Id);
        }

        // Bulk query Entitlements (use case-insensitive map for matching)
        Map<String, Id> entitlementMap = new Map<String, Id>();
        for (Core_Entitlement__c ent : [SELECT Id, Name,Core_Display_Name__c FROM Core_Entitlement__c WHERE (Name IN :allEntitlementNames OR Core_Display_Name__c IN :allEntitlementNames) AND Core_IsActive__c = true]) {
            String Ename = allEntitlementNames.contains(ent.Core_Display_Name__c) ? ent.Core_Display_Name__c : ent.Name;
            entitlementMap.put(Ename.toLowerCase(), ent.Id);
        }

        // Build contacts
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId();
        List<Contact> contactsToInsert = new List<Contact>();
        List<Integer> validRowIndices = new List<Integer>();

        for (Integer i = 0; i < rowDataList.size(); i++) {
            Map<String, String> rowData = rowDataList[i];
            String acctName = rowData.get(COL_ACCOUNT_NAME);
            if (String.isBlank(acctName) || !accountMap.containsKey(acctName)) {
                continue; // Skip rows without valid account
            }

            Contact c = new Contact();
            c.RecordTypeId = recordTypeId;
            c.FirstName = rowData.get(COL_FIRST_NAME);
            c.LastName = rowData.get(COL_LAST_NAME);
            c.Email = rowData.get(COL_EMAIL);
            c.AccountId = accountMap.get(acctName);
            c.MailingStreet = rowData.get(COL_MAILING_STREET);
            c.MailingCity = rowData.get(COL_MAILING_CITY);
            c.MailingState = rowData.get(COL_MAILING_STATE);
            c.MailingPostalCode = rowData.get(COL_MAILING_POSTAL_CODE);
            c.MailingCountry = rowData.get(COL_MAILING_COUNTRY);
            c.Core_Login_Status__c = 'Active';
            contactsToInsert.add(c);
            validRowIndices.add(i);
        }

        if (!contactsToInsert.isEmpty()) {
            insert contactsToInsert;
            System.enqueueJob(new ACM_ContactAddEnttls(contactsToInsert, true),10);
        }

        // Build entitlements and CMF associations
        List<Core_Contact_Entitlement__c> contactEntitlements = new List<Core_Contact_Entitlement__c>();
        List<ER_ContactGroupAssociation__c> cmfAssociations = new List<ER_ContactGroupAssociation__c>();

        for (Integer idx = 0; idx < contactsToInsert.size(); idx++) {
            Contact insertedContact = contactsToInsert[idx];
            Map<String, String> rowData = rowDataList[validRowIndices[idx]];

            // Entitlements (semicolon-separated in the cell)
            String entNames = rowData.get(COL_ENTITLEMENTS);
            if (String.isNotBlank(entNames)) {
                List<String> entNameList = entNames.split(';');
                for (Integer e = 0; e < entNameList.size(); e++) {
                    String entName = entNameList[e].trim();
                    if (String.isBlank(entName)) continue;
                    String entNameKey = entName.toLowerCase();
                    if (entitlementMap.containsKey(entNameKey)) {
                        contactEntitlements.add(new Core_Contact_Entitlement__c(
                            Core_Contact_Id__c = insertedContact.Id,
                            Core_Entitlement_Id__c = entitlementMap.get(entNameKey),
                            Core_Selected__c = true,
                            Core_From_Source__c = false,
                            Core_Update_Reason__c = 'WOM Bulk Email Request'
                        ));
                    }   
                }
            }


            // CMF Group association
            String cmfName = rowData.get(COL_CMF_GROUP);
            if (String.isNotBlank(cmfName) && cmfGroupMap.containsKey(cmfName)) {
                cmfAssociations.add(new ER_ContactGroupAssociation__c(
                    ER_Contact__c = insertedContact.Id,
                    ER_Customer_Master_File_Group__c = cmfGroupMap.get(cmfName),
                    ER_Active__c = true
                ));
            }
        }

        if (!contactEntitlements.isEmpty()) {
            insert contactEntitlements;
        }
        if (!cmfAssociations.isEmpty()) {
            insert cmfAssociations;
        }
    }

    /**
     * Parses CSV content into a list of rows, each row being a list of cell values.
     * Handles quoted fields containing commas and \r\n line endings.
     */
    private List<List<String>> parseCSV(String csvContent) {
        List<List<String>> rows = new List<List<String>>();
        if (String.isBlank(csvContent)) return rows;

        // Normalize line endings
        csvContent = csvContent.replace('\r\n', '\n').replace('\r', '\n');

        List<String> lines = csvContent.split('\n');
        for (String line : lines) {
            line = line.trim();
            if (String.isBlank(line)) continue;

            List<String> cells = new List<String>();
            Boolean inQuotes = false;
            String currentCell = '';

            for (Integer i = 0; i < line.length(); i++) {
                String ch = line.substring(i, i + 1);
                if (ch == '"') {
                    inQuotes = !inQuotes;
                } else if (ch == ',' && !inQuotes) {
                    cells.add(currentCell.trim());
                    currentCell = '';
                } else {
                    currentCell += ch;
                }
            }
            cells.add(currentCell.trim());
            rows.add(cells);
        }
        return rows;
    }

    /**
     * Parses a named section from the email body into key-value pairs.
     * Sections are delimited by ========= lines with a header between them.
     */
    private Map<String, String> parseSection(String body, String sectionName) {
        Map<String, String> fields = new Map<String, String>();

        // Find section start
        Integer sectionStart = body.indexOf(sectionName);
        if (sectionStart == -1) {
            return fields;
        }

        // Move past the section header and its trailing separator line
        Integer afterHeader = body.indexOf('\n', sectionStart);
        if (afterHeader == -1) return fields;

        // Skip the closing === line after section name
        String remainder = body.substring(afterHeader + 1);
        Integer sepEnd = remainder.indexOf('===');
        if (sepEnd != -1) {
            Integer lineEnd = remainder.indexOf('\n', sepEnd);
            if (lineEnd != -1) {
                remainder = remainder.substring(lineEnd + 1);
            }
        }

        // Find the end of this section (next === separator or end of string)
        Integer nextSep = remainder.indexOf('=========');
        String sectionContent = (nextSep != -1) ? remainder.substring(0, nextSep) : remainder;

        // Parse key: value pairs, handling multi-line values
        List<String> lines = sectionContent.split('\n');
        String currentKey = null;
        String currentValue = '';

        for (String line : lines) {
            line = line.trim();
            if (String.isBlank(line)) continue;

            Integer colonIdx = line.indexOf(':');
            if (colonIdx > 0 && colonIdx < line.length() - 1) {
                // Save previous key-value if exists
                if (currentKey != null) {
                    fields.put(currentKey, currentValue.trim());
                }
                currentKey = line.substring(0, colonIdx).trim();
                currentValue = line.substring(colonIdx + 1).trim();
            } else if (colonIdx == line.length() - 1) {
                // Key with empty value (value on next lines)
                if (currentKey != null) {
                    fields.put(currentKey, currentValue.trim());
                }
                currentKey = line.substring(0, colonIdx).trim();
                currentValue = '';
            } else {
                // Continuation of previous value (multi-line)
                if (currentKey != null) {
                    currentValue += '\n' + line;
                }
            }
        }
        // Save last key-value
        if (currentKey != null) {
            fields.put(currentKey, currentValue.trim());
        }

        return fields;
    }
}