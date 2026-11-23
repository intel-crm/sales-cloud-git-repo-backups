public without sharing class ACM_MessageQueueContract {
    public interface IMessageQueueAfterInsertContract {

        MessageQueueHandler.messageQueueResponse execute(List<ACM_Integration_Message_Queue__c> NewMessage); // Boolean value defines whether to update message status

    }



    public interface IMessageQueueAfterUpdateContract {

        MessageQueueHandler.messageQueueResponse execute(List<ACM_Integration_Message_Queue__c> oldMessage,List<ACM_Integration_Message_Queue__c> NewMessage); // Boolean value defines whether to update message status

    }
}