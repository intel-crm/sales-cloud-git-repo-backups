public class testQueueableClass implements Queueable{
    Id acrRecId = null;
    public testQueueableClass(id acrId) {     
    	acrRecId = acrId;
    }
    
    public void execute(QueueableContext context) { 
        PRM_Account_Contact_Relationship__c acr = [Select id, PRM_Status_Nm__c from PRM_Account_Contact_Relationship__c where id = :acrRecId];
        
        if(acr.PRM_Status_Nm__c == 'Complete'){
        	Core_Log_Entry.logEntryWithDetails('testACRUpdate', 'test', 'test', 'info', 'Completed',
                                             'test', null, null, null);
                }else{
                 	Core_Log_Entry.logEntryWithDetails('testACRUpdate', 'test', 'test', 'info', 'Pending',
                                             'test', null, null, null);   
                }
    }

}