public with sharing class PRAgentDemo {
    
    public PRAgentDemo() {

    }

    
    // Security vulnerability: SOQL injection risk
    public List<Contact> getContactsByAccountName(String accountName) {
        // Avoid using dynamic SOQL with untrusted input
        String query = 'SELECT Id, Name FROM Contact WHERE Account.Name = \'' + accountName + '\'';
        return Database.query(query);
    }

    // Non-optimized: Inefficient loop and DML operation inside the loop
    public void updateContactEmails(List<Contact> contacts) {
        for (Contact contact : contacts) {
            contact.Email = contact.Email.toLowerCase();
            update contact; // DML operation inside a loop
        }
    }

    // Security vulnerability: Exposing sensitive data
    public String getSensitiveData() {
        // Hardcoded sensitive information
        return 'Sensitive API Key: 12345-abcde-67890-fghij';
    }

    

}