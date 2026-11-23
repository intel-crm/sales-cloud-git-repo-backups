public class MessageQueueHandler {
    private static UCD_ACM_ServiceContracts.IMessageQueueService messageQueueServiceInstance = messageQueueService.getInstance();
    
    public static void createClassRefrence(String implementationType){
        if(implementationType == 'AfterInsert'){
            messageQueueServiceInstance.mapIntegrationMessageQueueResponse(implementationType,trigger.new,null);
        }
        if(implementationType == 'AfterUpdate'){
            messageQueueServiceInstance.mapIntegrationMessageQueueResponse(implementationType,trigger.new,trigger.old);
            
        }
        //return classNameByMessageQueueResponse;
    }
    
    public class messageQueueResponse{
        public Boolean status;
        public string errorDescription;
    } 
}