public class InterfaceTestCls implements ACM_MessageQueueContract.IMessageQueueAfterInsertContract{
	//private static	ACM_MessageQueueContract.IMessageQueueAfterInsertContract msgQueue = new ACM_MessageQueueContract.IMessageQueueAfterInsertContract();
    public static MessageQueueHandler.messageQueueResponse execute(List<ACM_Integration_Message_Queue__c> IntegrationMessages){
        system.debug('Harshal InterfaceTestCls');
        return null;
    }
}