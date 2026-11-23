/****************************************************************************************************
Apex Class Name : PSG_CreatePRIDQueueable
Version         : 1.0 
Created Date    : 06/24/2022
Function        : This class is used to perform complete follow on asynchronously.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Hari Kiran K              06/24/2022                Created
*****************************************************************************************************/
/*public class PSG_CreatePRIDQueueable implements Queueable{
    private String quoteId;
    public PSG_CreatePRIDQueueable(String quoteId){
        this.quoteId=quoteId;
    }
    public void execute(QueueableContext context) {
        try{
            SBQQ.TriggerControl.disable();
            PSG_QuoteBusinessLogic.createPRIDRecords(quoteId);
        	Database.executeBatch(new PSG_SendBulkSAPRequestBatch(),1); 
        }catch(Exception e){
            PSG_Utility.createCoreLogEntry('PSG_CreatePRIDQueueable', 'createPRIDRecords', 'Unexpected exception while creating PRID for Quote => '+quoteId, 'Exception => '+e, 'SBQQ__Quote__c', 'High', '');
        }finally{
            SBQQ.TriggerControl.enable();
        }
    }
}
*/
@isTest
public class PSG_CreatePRIDQueueable{

}