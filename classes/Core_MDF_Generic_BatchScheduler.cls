public class Core_MDF_Generic_BatchScheduler implements Schedulable {
    
    public void execute(SchedulableContext sc) {
        	
/*        startBatchJob();
        System.debug('Inside Execute');
        updateStatusForCompletedOrFailedJob();
        // Scheduling the next
        generateBatchChaning();     */
    }
	/*
    public void startBatchJob(){
        List<Core_MDF_Custom_Scheduler__c > lstBatch = new List<Core_MDF_Custom_Scheduler__c >();
        lstBatch = getScheduledRecords();
        System.debug('lstBatch'+lstBatch);        
        System.debug('Inside StartBatchJob');
        if(lstBatch != null && lstBatch.size()>0){
            for(Core_MDF_Custom_Scheduler__c  schRec : lstBatch){ 
                Type type = Type.forName(schRec.Core_MDF_Class_Name__c);
                System.debug('ClassName'+schRec.Core_MDF_Class_Name__c);
                System.debug('ClassNameType'+type);
                Object des_Obj = JSON.deserialize (schRec.Core_MDF_Object_Instance__c,type);
                // typecasting into batchable instance as executebatch takes batchable instance
                Database.batchable<sObject> batch = (Database.batchable<sObject>)des_Obj;
                schRec.Core_MDF_Job_Id__c = Database.executeBatch(batch, Integer.valueOf(schRec.Core_MDF_Batch_Size__c));
                schRec.Core_MDF_Status__c = 'Pending';
            }
            Database.update(lstBatch);        
            Map<String, Core_MDF_Scheduler_Frequency__c> classNameToJobFrequency = new Map<String, Core_MDF_Scheduler_Frequency__c>();
            List<Core_MDF_Scheduler_Frequency__c> schFrequencyLst = new List<Core_MDF_Scheduler_Frequency__c>();
            schFrequencyLst = [Select Core_MDF_Job_Frequency__c,Core_MDF_Class_Name__c,Core_MDF_Batch_Size__c FROM Core_MDF_Scheduler_Frequency__c];
            for(Core_MDF_Scheduler_Frequency__c schfreq : schFrequencyLst){
                classNameToJobFrequency.put(schfreq.Core_MDF_Class_Name__c,schfreq);
            }
            
            Type type = Type.forName(lstBatch[0].Core_MDF_Class_Name__c);
            Object des_Obj = JSON.deserialize (lstBatch[0].Core_MDF_Object_Instance__c,type);
            System.debug('des_Objjjj'+des_Obj);
            Integer batchSize = (Integer)classNameToJobFrequency.get(lstBatch[0].Core_MDF_Class_Name__c).Core_MDF_Batch_Size__c;
            DateTime nextScheduleTime;
            if(classNameToJobFrequency.get(lstBatch[0].Core_MDF_Class_Name__c).Core_MDF_Job_Frequency__c == 'Every 10 Min'){
                nextScheduleTime = System.now().addMinutes(10);
            }
            createCustomScheduler(des_Obj, batchSize, nextScheduleTime); 
        }
        System.debug('lstBatch2'+lstBatch);
    }
    
    public List<Core_MDF_Custom_Scheduler__c > getScheduledRecords(){
          return [SELECT Core_MDF_Batch_Size__c, Core_MDF_Class_Name__c, Core_MDF_Job_Id__c, Core_MDF_Object_Instance__c, Core_MDF_Scheduled_Time__c, Core_MDF_Status__c
               FROM Core_MDF_Custom_Scheduler__c WHERE Core_MDF_Status__c =: 'Scheduled' AND Core_MDF_Scheduled_Time__c <=: System.now() ORDER BY Core_MDF_Scheduled_Time__c limit 1];
    }
    
    public void updateStatusForCompletedOrFailedJob(){
        List<Core_MDF_Custom_Scheduler__c> pendingRecords  = new List<Core_MDF_Custom_Scheduler__c>();
        List<String> jobIds = new List<String>();
        List<AsyncApexJob> apexJobLst = new List<AsyncApexJob>();
        Map<Id, AsyncApexJob> jobStatusJobIdMap = new Map<Id, AsyncApexJob>();
        
        pendingRecords = [Select Core_MDF_Job_Id__c,Core_MDF_Status__c FROM Core_MDF_Custom_Scheduler__c WHERE Core_MDF_Status__c =: 'Pending'];
        for(Core_MDF_Custom_Scheduler__c sch : pendingRecords){
            jobIds.add(sch.Core_MDF_Job_Id__c);
        }
        
        apexJobLst = [Select Id, Status FROM AsyncApexJob WHERE Status IN ('Failed','Completed') AND ID IN : jobIds];
        for(AsyncApexJob apexJob : apexJobLst){
            jobStatusJobIdMap.put(apexJob.Id, apexJob);
        }
        System.debug('apexJobLst'+apexJobLst);
        for(Core_MDF_Custom_Scheduler__c sch : pendingRecords){
            if(jobStatusJobIdMap != null && jobStatusJobIdMap.size()>0 && jobStatusJobIdMap.containsKey(sch.Core_MDF_Job_Id__c)){
            	sch.Core_MDF_Status__c = jobStatusJobIdMap.get(sch.Core_MDF_Job_Id__c).Status;
            }
        }
        System.debug('pendingRecords'+pendingRecords);
        Database.update(pendingRecords);
    }
    
    public void createCustomScheduler(Object batchClassInstance, Integer scopeSize, DateTime scheduledTime){
        Core_MDF_Custom_Scheduler__c customSch = new Core_MDF_Custom_Scheduler__c();
        // Serializing into JSON string
        String s = JSON.serialize(batchClassInstance);
        customSch.Core_MDF_Object_Instance__c = s;
        System.debug('Inside Constructor'+s.length()); 
        System.debug('batchClassInstance' + String.valueOf(batchClassInstance) + '---------->' + s);
        customSch.Core_MDF_Batch_Size__c = scopeSize;
        customSch.Core_MDF_Scheduled_Time__c = scheduledTime;
        customSch.Core_MDF_Class_Name__c = String.valueOf(batchClassInstance).split(':')[0];
        customSch.Core_MDF_Status__c = 'Scheduled';
        database.insert(customSch);
        System.debug('EndOfCons'); 
    }
    
    public void generateBatchChaning(){
        String nextRunCron;
        String batchJobName;
        DateTime nextRunTime = system.now().addMinutes(3);
        nextRunCron = 0+' '+nextRunTime.minute()+' '+nextRunTime.hour()+' '+nextRunTime.day()+'-'+nextRunTime.day()+' '+nextRunTime.month()+'  ? '+nextRunTime.year();
        // provide unique name to job
        Double randomNum = math.random();
        batchJobName = 'batchJob--'+nextRunTime+'_'+randomNum ;
        string jobId = System.schedule(batchJobName, nextRunCron, new Core_MDF_Generic_BatchScheduler());        
    }     */
}