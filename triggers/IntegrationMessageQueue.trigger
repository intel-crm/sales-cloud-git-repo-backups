trigger IntegrationMessageQueue on ACM_Integration_Message_Queue__c (after insert,after update) {
	if (Trigger.isInsert && Trigger.isAfter) {

        //UCD_ACM_UnitOfWork unitwork = new UCD_ACM_UnitOfWork();
        // instead of FOR loop, get data from custom settings
        //for (Schema.ApexTypeImplementor typeImplementor : [Select ClassName, ClassNamespacePrefix FROM Schema.ApexTypeImplementor WHERE InterfaceName = 'ACM_MessageQueueContract.MessageQueueContract' AND IsConcrete = true]) {
            //Initialize the class
            //ACM_MessageQueueContract.MessageQueueContract msgQueue = (ACM_MessageQueueContract.MessageQueueContract)Type.forName(typeImplementor.ClassNamespacePrefix,typeImplementor.ClassName).newInstance();
            //Boolean status = msgQueue.execute(Trigger.old, Trigger.new);
            //unitwork.registerNew(Trigger.new);
        //}
        //unitwork.commitWork();
        /*For(MessageQueueClasses__c messageQueueClass : [Select Class_Name__c from MessageQueueClasses__c where Implementation_Type__c ='AfterInsert']){
            ACM_MessageQueueContract.IMessageQueueAfterInsertContract msgQueue = (ACM_MessageQueueContract.IMessageQueueAfterInsertContract)Type.forName(messageQueueClass.Class_Name__c).newInstance();
            Boolean status = msgQueue.execute(Trigger.new);
        }*/
        //MessageQueueHandler.createClassRefrence('AfterInsert');
    }
    
    if (Trigger.isUpdate && Trigger.isAfter){
        //MessageQueueHandler.createClassRefrence('AfterUpdate');
    }
}