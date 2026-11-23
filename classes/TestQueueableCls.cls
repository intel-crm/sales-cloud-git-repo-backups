public with sharing class TestQueueableCls implements Queueable{
    public List<Account> accList ;
    public Integer count;
    public TestQueueableCls(List<Account> accList,Integer i){
        this.accList = accList ;
        this.count = i;
    }
	public void execute(QueueableContext context) {
        System.debug('count is '+count);
        Integer c = count +1;
        if(count < 30){
           System.enqueueJob(new TestQueueableCls(accList,c));
        }
        else if(count == 30){
            Database.executeBatch(new Core_IQR_IntelProductData());
        }
        
    }    
}