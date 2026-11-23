public class SmartPicklistToolingAPIHelper {

    // Method to add picklist value
    public static void addPicklistValue() {
        try {
            // 1. Construct the Tooling API endpoint URL
            String endpoint = 'callout:SmartPicklist_Named_Cred/services/data/v56.0/tooling/sobjects/PicklistEntry/';
            
            String objectName = 'Opportunity';
            String fieldName = 'Core_Intel_Platform__c';
            String picklistValue = 'Hello123';
            
            // 2. Create a JSON payload to create a new picklist value
            Map<String, Object> picklistEntryData = new Map<String, Object>();
            picklistEntryData.put('value', picklistValue);
            picklistEntryData.put('label', picklistValue);
            picklistEntryData.put('isActive', true); // Make sure to set active as true
            picklistEntryData.put('default', false); // Optional: Set if you want to make it default
            
            // Find the field ID for the picklist field
            String fieldId = getPicklistFieldId(objectName, fieldName);
            system.debug('FIELD ID IS:'+fieldId);
            
            // Make sure you get a valid fieldId before proceeding
            if (fieldId != null) {
                picklistEntryData.put('parent', fieldId); // The picklist's field ID
            } else {
                System.debug('Field not found!');
                return;
            }

            // 3. Serialize the map to JSON
            String requestBody = JSON.serialize(picklistEntryData);

            // 4. Create an HTTP request to the Tooling API
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setBody(requestBody);

            // 5. Send the request
            Http http = new Http();
            HttpResponse res = http.send(req);

            // 6. Check the response
            if (res.getStatusCode() == 201) {
                System.debug('Picklist Value Created Successfully!');
            } else {
                System.debug('Error creating picklist value: ' + res.getStatusCode() + ' - ' + res.getBody());
            }

        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
    }

    // Helper method to fetch the Field ID for a Picklist field
    public static String getPicklistFieldId(String objectName, String fieldName) {
        try {
            // Query the Tooling API for the field's metadata
            String query = 'SELECT Id FROM CustomField WHERE EntityDefinition.DeveloperName = :objectName AND DeveloperName = :fieldName';
            List<SObject> results = Database.query(query);

            // Return the field ID if found
            if (!results.isEmpty()) {
                return (String) results[0].get('Id');
            }
        } catch (Exception e) {
            System.debug('Error retrieving field ID: ' + e.getMessage());
        }
        return null;
    }
}