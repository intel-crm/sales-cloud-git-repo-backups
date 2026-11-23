global class ACM_CreateContact implements Messaging.InboundEmailHandler {
    
    global Messaging.InboundEmailResult handleInboundEmail(
        Messaging.InboundEmail email, 
        Messaging.InboundEnvelope envelope) {
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        
        try {
            // Process the email
            processEmailWithAI(email);
            result.success = true;
        } catch (Exception e) {
            result.success = false;
            result.message = 'Error processing email: ' + e.getMessage();
        }
        
        return result;
    }
    
    private void processEmailWithAI(Messaging.InboundEmail email) {
        // Call AI service asynchronously
       AIProcessQueuable aiProcessor = new AIProcessQueuable(email);
        System.enqueueJob(aiProcessor);
    }
}