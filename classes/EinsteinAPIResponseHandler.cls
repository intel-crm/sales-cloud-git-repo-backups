public class EinsteinAPIResponseHandler {
    // Inner class to represent the structure of a single response item
    public class ResponseItem {
        public String id;
        public String label;
        public Decimal confidence;
        
        // Constructor
        public ResponseItem(String id, String label, Decimal confidence) {
            this.id = id;
            this.label = label;
            this.confidence = confidence;
        }
    }
    
    // List to store multiple response items
    public List<ResponseItem> responseItems { get; private set; }
    
    // Constructor to initialize the list
    public EinsteinAPIResponseHandler() {
        responseItems = new List<ResponseItem>();
    }
    
    /**
     * Method to parse the API response and store results
     * @param apiResponse JSON string from the Einstein API call
     */
    public void parseResponse(String apiResponse) {
        try {
            // Parse the JSON response
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(apiResponse);
            
            // Assume the response contains a 'predictions' array
            if (responseMap.containsKey('predictions')) {
                List<Object> predictions = (List<Object>) responseMap.get('predictions');
                
                for (Object predictionObj : predictions) {
                    Map<String, Object> prediction = (Map<String, Object>) predictionObj;
                    
                    // Extract fields (adjust keys based on API response structure)
                    String id = (String) prediction.get('id');
                    String label = (String) prediction.get('label');
                    Decimal confidence = (Decimal) prediction.get('confidence');
                    
                    // Add the response item to the list
                    responseItems.add(new ResponseItem(id, label, confidence));
                }
            }
        } catch (Exception e) {
            System.debug('Error parsing API response: ' + e.getMessage());
        }
    }
    
    /**
     * Method to get all stored response items
     * @return List of ResponseItem
     */
    public List<ResponseItem> getResponseItems() {
        return responseItems;
    }
    
    // Example usage (call this method from your application logic)
    public static void exampleUsage() {
        // Simulated API response (replace with an actual API call)
        String simulatedApiResponse = '{"predictions":[{"id":"1","label":"Cat","confidence":0.95},{"id":"2","label":"Dog","confidence":0.89}]}';
        
        // Instantiate the handler and parse the response
        EinsteinAPIResponseHandler handler = new EinsteinAPIResponseHandler();
        handler.parseResponse(simulatedApiResponse);
        
        // Access stored response items
        for (ResponseItem item : handler.getResponseItems()) {
            System.debug('ID: ' + item.id + ', Label: ' + item.label + ', Confidence: ' + item.confidence);
        }
    }
}