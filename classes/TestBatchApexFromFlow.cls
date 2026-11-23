public class TestBatchApexFromFlow implements Database.Batchable<sObject>{
    public String oldAEEmail;
    public String newAEEmail;
    public TestBatchApexFromFlow(String oldAEEmailFromFlow, String newAEEmailFromFlow){
       this.oldAEEmail = oldAEEmailFromFlow;
       this.newAEEmail = newAEEmailFromFlow;
    }
    @InvocableMethod(label = 'testBulkUpdateAEOnQuote' description = 'To update Account Executive in bulk on Quote Records')
    public static void testBulkUpdateAEOnQuote(List<FlowInputs> aEEmailList){
        String oldAEEmailToBeUpd = aEEmailList[0].oldAEEmailInput;
        String newAEEmailToBeUpd = aEEmailList[0].newAEEmailInput;
		Id jobId = Database.executeBatch(new TestBatchApexFromFlow(oldAEEmailToBeUpd, newAEEmailToBeUpd));
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        system.debug('Inside start');
        return Database.getQueryLocator([SELECT Id,Name FROM SBQQ__Quote__c 
                                         WHERE Pricing_Intel_Account_Exec_Email_Txt__c =: oldAEEmail LIMIT 1]);
    }
    
    public void execute(Database.BatchableContext bc, List<SBQQ__Quote__c> quoteRecsList){
        try
        {
            system.debug('Inside execute');
            List<PermissionSetAssignment> aePermSetAssignment = [SELECT Id FROM PermissionSetAssignment 
                                                                 WHERE Assignee.Email =: newAEEmail 
                                                                 AND Assignee.IsActive = true 
                                                                 AND PermissionSet.name = 'Tender_Account_Executive' LIMIT 1];
            /*List<SBQQ__Quote__c> quoteRecsToBeUpd = new List<SBQQ__Quote__c>();
            if(quoteRecsList.size() > 0 ){
                for(SBQQ__Quote__c quote: quoteRecsList){
                    quote.Pricing_Intel_Account_Exec_Email_Txt__c = aePermSetAssignment[0].Assignee.Email;
                    quoteRecsToBeUpd.add(quote);
                }
                SBQQ.TriggerControl.disable();
                update quoteRecsToBeUpd;
                SBQQ.TriggerControl.enable();
            }*/
            system.debug('aePermSetAssignment: '+aePermSetAssignment);
            system.debug('oldAEEmail: '+oldAEEmail);
            system.debug('newAEEmail: '+newAEEmail);
            system.debug('QuotesList: '+quoteRecsList);
        }
        catch(exception ex)
        {
            Pricing_Tender_Utility.logError(ex);
        }
    }
    
    public void finish(Database.BatchableContext bc)
    {
        // Get the batch job information
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id =:bc.getJobId()];
    }
    
    //Stores inputs from Flow 
    public class FlowInputs {
        @InvocableVariable public String oldAEEmailInput;
        @InvocableVariable public String newAEEmailInput;
        public FlowInputs(){
            
        }
    }
}