global class Pricing_Batchtestqueuable  implements Database.Batchable<sObject>{
    
    global Integer recursiveCounter;
    public Database.querylocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([select id,SBQQ__Quote__c from SBQQ__QuoteLine__c where id='a9U2D000000PhWgUAK']);
    }
    public void execute(Database.BatchableContext bc, List<sObject> scope){
    /* try{
            List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
            List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
            for(SBQQ__QuoteLine__c quoteLine : (List<SBQQ__QuoteLine__c>)scope){
                quoteLineList.add(quoteLine);
                quoteList.add(New SBQQ__Quote__c(id=quoteLine.SBQQ__Quote__c,Pricing_Project_Name_Nm__c='test10'));
            }
            Integer count = [SELECT Count() FROM AsyncApexJob where ApexClassId = '01p2D0000004vIu' and Status!='Completed'];
            System.debug('count1 '+count);
            //if(count == 0){
                update quoteList;
                System.debug('test1 '+Limits.getQueueableJobs());
            //}
            System.debug('test1 '+Limits.getQueueableJobs());
            System.debug('test1 '+Limits.getLimitQueueableJobs());
            count = [SELECT Count() FROM AsyncApexJob where ApexClassId = '01p2D0000004vIu' and Status IN('Holding','Queued','Preparing','Processing')];
            System.debug('count2 '+count);
            if(count == 0){
                //if(Limits.getQueueableJobs() == 1){
                //}else{
                update quoteLineList;
                //}
                System.debug('test2 '+Limits.getQueueableJobs());
            }
            System.debug('test2 '+Limits.getQueueableJobs());
            System.debug('test2 '+Limits.getLimitQueueableJobs());
            count = [SELECT Count() FROM AsyncApexJob where ApexClassId = '01p2D0000004vIu' and Status!='Completed'];
            System.debug('count3 '+count);
            //if(count == 0){
                update quoteList;
                System.debug('test3 '+Limits.getQueueableJobs());
            //}
            System.debug('test3 '+Limits.getQueueableJobs());
            System.debug('test3 '+Limits.getLimitQueueableJobs());
            count = [SELECT Count() FROM AsyncApexJob where ApexClassId = '01p2D0000004vIu' and Status IN('Holding','Queued','Preparing','Processing')];
            System.debug('count4 '+count);
            if(count == 0){
                //if(Limits.getQueueableJobs() == 1){
                //}else{
                update quoteLineList;
                //}
                System.debug('test4 '+Limits.getQueueableJobs());
            }
            System.debug('test4 '+Limits.getQueueableJobs());
            System.debug('test4 '+Limits.getLimitQueueableJobs());
            
        }catch(exception ex){Pricing_Tender_Utility.logError(ex);}*/
    }
    public void finish(Database.BatchableContext bc){
    /*    recursiveCounter = recursiveCounter == null ? 0 : recursiveCounter + 1;
        Pricing_Batchtestqueuable a = new Pricing_Batchtestqueuable();
        a.recursiveCounter = recursiveCounter;
        if(recursiveCounter < 5){
            Database.executeBatch(a,1);
        }
        */
    }

}