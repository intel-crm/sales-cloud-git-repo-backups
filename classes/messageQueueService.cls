public class messageQueueService implements UCD_ACM_ServiceContracts.IMessageQueueService {
    private static UCD_ACM_ServiceContracts.IMessageQueueService instance = null;
    private messageQueueService() {}

    public static UCD_ACM_ServiceContracts.IMessageQueueService getInstance(){
        if (instance  == null){
            instance  = new messageQueueService();
        }
        return instance;
    }


    public Map<String,MessageQueueHandler.messageQueueResponse> mapIntegrationMessageQueueResponse(String implementationType,List<ACM_Integration_Message_Queue__c> newIntegrationMessages,List<ACM_Integration_Message_Queue__c> oldIntegrationMessages){
        List<ACM_Integration_Message_Queue__c> updateIntegrationMessages = new List<ACM_Integration_Message_Queue__c>();
        For(MessageQueueClasses__c messageQueueClass : [Select Class_Name__c from MessageQueueClasses__c where Implementation_Type__c =:implementationType]){
            ACM_MessageQueueContract.IMessageQueueAfterInsertContract msgQueueAfterInsert = (ACM_MessageQueueContract.IMessageQueueAfterInsertContract)Type.forName(messageQueueClass.Class_Name__c).newInstance();
            ACM_MessageQueueContract.IMessageQueueAfterUpdateContract msgQueueAfterUpdate = (ACM_MessageQueueContract.IMessageQueueAfterUpdateContract)Type.forName(messageQueueClass.Class_Name__c).newInstance();
            
            if(implementationType == 'AfterInsert'){
                MessageQueueHandler.messageQueueResponse messageQueueResponse = msgQueueAfterInsert.execute(newIntegrationMessages);
                if(messageQueueResponse.status = true){
                    updateIntegrationMessages.addAll(newIntegrationMessages);
                }else{
                    UCD_ACM_Logger.error('messageQueueService','mapIntegrationMessageQueueResponse',messageQueueResponse.errorDescription);
                }
            }

            if(implementationType == 'AfterUpdate'){
                MessageQueueHandler.messageQueueResponse messageQueueResponse = msgQueueAfterUpdate.execute(oldIntegrationMessages,newIntegrationMessages);
                if(messageQueueResponse.status = false){
                    UCD_ACM_Logger.error('messageQueueService','mapIntegrationMessageQueueResponse',messageQueueResponse.errorDescription);
                }
            }
        }
        if(updateIntegrationMessages.size() > 0){
            For(ACM_Integration_Message_Queue__c integrationMessage : updateIntegrationMessages){
                integrationMessage.Message_Status__c = 'New';
            }
            update updateIntegrationMessages;
        }

        return null;
    }
}