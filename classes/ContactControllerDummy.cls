public class ContactControllerDummy {
	// Global variable (static) to store all queried Contact records
    public static List<Contact> globalContactList;

    // First @AuraEnabled method to fetch and store Contacts in the global list
    @AuraEnabled(cacheable=true)
    public static List<Contact> fetchAllContacts() {
        if (globalContactList == null || globalContactList.isEmpty()) {
            // Query Contacts and store them in the global list if not already populated
            globalContactList = [SELECT Id, Name, Email FROM Contact LIMIT 100];
        }
        System.debug('@#@#fetchAllContacts->'+globalContactList);
        // Return the global list of contacts
        return globalContactList;
    }

    // Second @AuraEnabled method to filter the global list based on a parameter (e.g., name search)
    @AuraEnabled(cacheable=true)
    public static List<Contact> getFilteredContacts(String searchTerm) {
        // Ensure globalContactList is populated before filtering
        if (globalContactList == null || globalContactList.isEmpty()) {
            fetchAllContacts(); // Populate the list if it's empty
        }

        // Filter the global list of contacts based on the search term
        List<Contact> filteredContacts = new List<Contact>();

        for (Contact c : globalContactList) {
            if (c.Name != null && c.Name.contains(searchTerm)) {
                filteredContacts.add(c);
            }
        }
		System.debug('@#@#getFilteredContacts->'+globalContactList);
        // Return the filtered list
        return filteredContacts;
    }

    // Another method that can be used to process or use the global contact list
    @AuraEnabled(cacheable=true)
    public static List<Contact> getAllContacts() {
        // Just return the global list if it's already populated
        if (globalContactList == null || globalContactList.isEmpty()) {
            fetchAllContacts(); // Populate the list if it's empty
        }
        System.debug('@#@#getAllContacts->'+globalContactList);
        return globalContactList;
    }
}