public class AIProcessQueuable implements Queueable, Database.AllowsCallouts {
    
    private Messaging.InboundEmail emailData;
    
    public AIProcessQueuable(Messaging.InboundEmail email) {
        this.emailData = email;
    }
    
    public void execute(QueueableContext context) {
        // Call AI service
        String aiResponse = callAIService(emailData.plainTextBody);
        
        // Process AI response and create/update contacts
        processAIResponse(aiResponse);
    }
    
    private String callAIService(String emailContent) {
       
        
        return ACM_UCD_EmailParsing.getQueryData(emailContent).getBody();
    }
    
    private void processAIResponse(String aiResponse) {
        // Parse AI response and extract contact details
        Map<String, Object> responseData = (Map<String, Object>) JSON.deserializeUntyped(aiResponse);
        system.debug(responseData);
        // Contact con = (contact) JSON.Deserialize(String.valueOf(responseData.get('Contact')),Contact.class);
        // insert con;
        // system.debug(con);
        // Create or update contact records
        createContactFromAIData(responseData);
    }

    private Contact createContactFromAIData(Map<String, Object> responseData) {
    try {
        // Extract the Contact object from the response
        Map<String, Object> contactData = (Map<String, Object>) responseData.get('Contact');
        
        if (contactData == null) {
            System.debug('No Contact data found in response');
            return null;
        }
        
        Contact newContact = new Contact();
        
        // Map the specific fields from your JSON response
        if (contactData.get('Firstname') != null) {
            newContact.FirstName = (String) contactData.get('Firstname');
        }
        
        if (contactData.get('LastName') != null) {
            newContact.LastName = (String) contactData.get('LastName');
        } else {
            // LastName is required in Salesforce, use email prefix or default if not provided
            String email = (String) contactData.get('email');
            if (email != null && email.contains('@')) {
                newContact.LastName = email.split('@')[0];
            } else {
                newContact.LastName = 'Unknown';
            }
        }
        
        if (contactData.get('email') != null) {
            String email = (String) contactData.get('email');
            // Validate email format
            if (isValidEmail(email)) {
                newContact.Email = email;
            }
        }
        
        // Handle Account association using AccountID
        if (contactData.get('AccountID') != null) {
            String accountId = (String) contactData.get('AccountID');
            
            // Option 1: If AccountID is a Salesforce ID, use it directly
            if (isValidSalesforceId(accountId)) {
                newContact.AccountId = accountId;
            } else {
                // Option 2: If AccountID is an external ID, find the account
                Account relatedAccount = findAccountByExternalId(accountId);
                if (relatedAccount != null) {
                    newContact.AccountId = relatedAccount.Id;
                }
            }
        }
        
        // Handle Shipping Country
        if (contactData.get('ShippingCountry') != null) {
            newContact.MailingCountry = (String) contactData.get('ShippingCountry');
        }
        
        // Add metadata about the AI processing
        newContact.Description = 'Contact created via AI email processing on ' + DateTime.now().format();
        newContact.LeadSource = 'Email AI Processing';
        
        // Add custom field to store the original AI response (optional)
        // newContact.AI_Response_Data__c = JSON.serialize(contactData);
        
        return newContact;
        
    } catch (Exception e) {
       // logError('Contact Creation Failed', e.getMessage(), JSON.serialize(responseData));
        return null;
    }
}

// Helper method to validate email format
private Boolean isValidEmail(String email) {
    if (String.isBlank(email)) {
        return false;
    }
    
    String emailRegex = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$';
    Pattern emailPattern = Pattern.compile(emailRegex);
    Matcher emailMatcher = emailPattern.matcher(email);
    
    return emailMatcher.matches();
}

// Helper method to validate Salesforce ID format
private Boolean isValidSalesforceId(String recordId) {
    if (String.isBlank(recordId)) {
        return false;
    }
    
    // Salesforce IDs are 15 or 18 characters long
    return recordId.length() == 15 || recordId.length() == 18;
}

// Helper method to find account by external ID
private Account findAccountByExternalId(String externalId) {
    try {
        // Assuming you have an External_ID__c field on Account
        List<Account> accounts = [
            SELECT Id, Name 
            FROM Account 
            WHERE External_ID__c = :externalId 
            LIMIT 1
        ];
        
        if (!accounts.isEmpty()) {
            return accounts[0];
        }
        
        // If not found by external ID, try to find by name or create new
        return createAccountFromExternalId(externalId);
        
    } catch (Exception e) {
       // logError('Account Lookup Failed', e.getMessage(), externalId);
        return null;
    }
}

// Helper method to create account from external ID
private Account createAccountFromExternalId(String externalId) {
    try {
        Account newAccount = new Account(
            Name = 'Account - ' + externalId,
            External_ID__c = externalId,
            Type = 'Prospect',
            Description = 'Account created via AI email processing on ' + DateTime.now().format()
        );
        
        insert newAccount;
        return newAccount;
        
    } catch (Exception e) {
       // logError('Account Creation Failed', e.getMessage(), externalId);
        return null;
    }
}
}