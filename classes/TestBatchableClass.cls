global class TestBatchableClass implements Database.Batchable<sObject>,Database.Stateful{
    //create a list to store paymentIds which has changed to paid
	global Set<Id> paymentIdSet;
    
  	@InvocableMethod(label='exuete the batch TestBatchableClass' description='This method will be execute ContactBatch')    
    public static void executeBatchMethod(list<Id> lst) {
    Database.executeBatch(new TestBatchableClass(lst), 200);
  }
    
    //parameterized constructor which takes paymentIds as argument
	public TestBatchableClass(List<Id> paymentIdparamList){
        paymentIdSet = new Set<Id>();
        system.debug('inside constructor payment id list - '+paymentIdparamList);
        for(Id recID : paymentIdparamList){
            paymentIdSet.add(recID);
        }
        system.debug('inside constructor paymentIdSet - '+paymentIdSet);
		//this();
		//paymentIdSet.addAll(paymentIdparamList);
	}
  
    global static Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id FROM PartnerFundClaim WHERE Core_MDF_Payment_Id__c IN :paymentIdSet';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<PartnerFundClaim> claimList) {
        try {
            system.debug('inside execute claimList - '+claimList);
        } catch(Exception e) {
            System.debug(e);
        }  
    }   
    global void finish(Database.BatchableContext BC) {
  }
}