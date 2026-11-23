global class RetryBatchScheduleClass Implements Schedulable {
    public List<Id> recordListId ;
    global RetryBatchScheduleClass (List<Id> recordIds ){
        this.recordListId = recordIds ;
    }
    
    public void execute(SchedulableContext sc) {
		System.debug('runing schedule');
		System.debug('runing schedule'+recordListId);

    	besUpdateClass_optimised con = new besUpdateClass_optimised(recordListId); 
		Database.executeBatch(con, 1); 
		System.debug('runing Done');
    }
}