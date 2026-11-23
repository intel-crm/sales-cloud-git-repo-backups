public class ProcessStaticResourceQueueable implements Queueable, Database.AllowsCallouts {
    private String staticResourceName;

    public ProcessStaticResourceQueueable(String resourceName) {
        this.staticResourceName = resourceName;
    }

    public void execute(QueueableContext context) {
        try {
            // Query the StaticResource
            StaticResource file = [
                SELECT Id, Body 
                FROM StaticResource 
                WHERE Name = :staticResourceName 
                LIMIT 1
            ];

            // Convert Blob to String and parse JSON
            String jsonStr = file.Body.toString();
            Map<String, Object> specs = (Map<String, Object>) JSON.deserializeUntyped(jsonStr);

            // Perform further processing if needed
            System.debug('specs: ' + specs);

            // Process the specs map further as needed
        } catch (Exception e) {
            System.debug('Exception while processing StaticResource: ' + e.getMessage());
        }
    }
}