public class Core_Mdf_CustomSchdulerUtilityCopy {
 public static integer getAvailability(){ 
        system.debug('in Availability');
        Integer maxLimit = 100;
        Integer availableLimit = 100;  // defaulted to 100
        AggregateResult[] groupedResults = [Select Count(Id) FROM AsyncApexJob Where Status = 'Holding'];
        if(groupedResults.size()>0){
            String exp0 = String.valueOf(groupedResults[0].get('expr0')); 
            availableLimit = maxLimit - Integer.valueOf(exp0);
        }
        return availableLimit;
    }
    
    /****************************************************************************************************** 
Method Name:        startBatchJob
@return  :          void
@parameters:        availableLimit - integer value returned by getAvailability method
Description:        This method is used to start batch job for instance provided in custom scheduler record.
Added By:           Accenture - NK - 03/10/2021
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    public static void startBatchJob(){
        Integer maxSchedule = 50;
        Integer availableLimit = getAvailability();
        if(availableLimit>maxSchedule ){
            availableLimit = maxSchedule;
        }
        List<Core_MDF_Custom_Scheduler__c > lstBatch = new List<Core_MDF_Custom_Scheduler__c >();
        if(availableLimit > 0){
            lstBatch = getScheduledRecords(availableLimit);
            system.debug('lstBatch-->'+ lstBatch);
        }
        if(lstBatch != null && lstBatch.size()>0){ 
            for(Core_MDF_Custom_Scheduler__c  schRec : lstBatch){ 

                /* if(schRec.Core_MDF_Scheduler_Frequency__r.Core_MDF_Job_Frequency__c == 'Once'){
                }
                // if(schRec.Core_MDF_Scheduler_Frequency__r.Core_MDF_Job_Frequency__c == 'Every X Minute'){
                // Integer addMins = schRec.Core_MDF_Scheduler_Frequency__r.Every_X_Minute__c
			DateTime scheduleTime = schRec.Core_MDF_Scheduled_Time__c;
			scheduleTime.addMinutes(addMins);
			if(scheduleTime<schRec.Core_MDF_Scheduler_Frequency__r.Core_MDF_Effective_End_Time_Dt__c){
			Core_MDF_Custom_Scheduler__c customSch = new Core_MDF_Custom_Scheduler__c();
            customSch.Core_MDF_Object_Instance__c = schRec.Core_MDF_Object_Instance__c;
            customSch.Core_MDF_Batch_Size__c = schRec.Core_MDF_Batch_Size__c;
            customSch.Core_MDF_Scheduled_Time__c = scheduleTime;
            customSch.Core_MDF_Class_Name__c = schRec.Core_MDF_Class_Name__c;
            customSch.Core_MDF_Status__c = 'Scheduled';
            customSch.Core_MDF_Scheduler_Frequency__c = schRec.Core_MDF_Scheduler_Frequency__c;
}
}
                // if(schRec.Core_MDF_Scheduler_Frequency__r.Core_MDF_Job_Frequency__c == 'Every X Hour'){}
                // if(schRec.Core_MDF_Scheduler_Frequency__r.Core_MDF_Job_Frequency__c == 'Daily'){}
                // if(schRec.Core_MDF_Scheduler_Frequency__r.Core_MDF_Job_Frequency__c == 'Days of Week'){

}    */
                
                
                
                // type casting and deserializing batch class instance
                Type type = Type.forName(schRec.Core_MDF_Batch_Class_Name_Txt__c);
                Object des_Obj = JSON.deserialize (schRec.Core_MDF_Object_JSON_Txt__c,type);
                Database.batchable<sObject> batch = (Database.batchable<sObject>)des_Obj;
                schRec.Core_MDF_Job_Id_Txt__c = Database.executeBatch(batch, Integer.valueOf(schRec.Core_MDF_Batch_Size_Nbr__c));
                schRec.Core_MDF_Status__c = 'Pending';
            }
            list<Core_MDF_Custom_Scheduler__c> recordsToUpdate = new list<Core_MDF_Custom_Scheduler__c>();
            recordsToUpdate = updateStatusForCompletedOrFailedJob();
            if(recordsToUpdate != null && recordsToUpdate.size()>0){
            lstBatch.addAll(recordsToUpdate);
            }
            try{
                Database.update(lstBatch);  
            }
            catch(exception e){
                Core_MDF_CCP_UtilityClass.logError(e);
                throw e;}
        }
    }
    /****************************************************************************************************** 
Method Name:        getScheduledRecords
@return  :          List<Core_MDF_Custom_Scheduler__c >
@parameters:        availableLimit - integer value returned by getAvailability method
Description:        This method is used to fetch custom scheduler records.
Added By:           Accenture - NK - 03/10/2021
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    public static List<Core_MDF_Custom_Scheduler__c > getScheduledRecords(integer availableLimit){
        system.debug('in getRecords');
        DateTime dt = System.now(); 
        if(test.isRunningTest()){
            dt = dt.addDays(2);
        }
        return [SELECT Core_MDF_Batch_Size_Nbr__c,Core_MDF_Scheduler_Frequency__r.Core_MDF_Job_Frequency__c, Core_MDF_Batch_Class_Name_Txt__c, Core_MDF_Job_Id_Txt__c, Core_MDF_Object_JSON_Txt__c, Core_MDF_Scheduled_Time_Dt__c, Core_MDF_Status__c
                FROM Core_MDF_Custom_Scheduler__c WHERE Core_MDF_Status__c ='Scheduled' AND Core_MDF_Scheduled_Time_Dt__c <=:dt ORDER BY Core_MDF_Priority__c, Core_MDF_Scheduled_Time_Dt__c limit :availableLimit];
    }
    
    /****************************************************************************************************** 
Method Name:        updateStatusForCompletedOrFailedJob
@return  :          void
@parameters:        --
Description:        This method is used to update status of custom scheduler records.
Added By:           Accenture - NK - 03/10/2021
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    public static list<Core_MDF_Custom_Scheduler__c> updateStatusForCompletedOrFailedJob(){
        List<Core_MDF_Custom_Scheduler__c> pendingRecords  = new List<Core_MDF_Custom_Scheduler__c>();
        Set<String> jobIds = new Set<String>();
        List<AsyncApexJob> apexJobLst = new List<AsyncApexJob>();
        Map<Id, AsyncApexJob> jobIdToStatusMap = new Map<Id, AsyncApexJob>(); 
        
        pendingRecords = [Select Core_MDF_Job_Id_Txt__c,Core_MDF_Status__c FROM Core_MDF_Custom_Scheduler__c WHERE Core_MDF_Status__c = 'Pending'];
        for(Core_MDF_Custom_Scheduler__c sch : pendingRecords){
            jobIds.add(sch.Core_MDF_Job_Id_Txt__c);
        }
        if(jobIds != null && jobIds.size()>0){
            for(AsyncApexJob apexJob : [Select Id, Status FROM AsyncApexJob WHERE Status IN ('Failed','Completed') AND ID IN : jobIds]){
                jobIdToStatusMap.put(apexJob.Id, apexJob);
            }
        }
        for(Core_MDF_Custom_Scheduler__c sch : pendingRecords){
            if(jobIdToStatusMap != null && jobIdToStatusMap.size()>0 && jobIdToStatusMap.containsKey(sch.Core_MDF_Job_Id_Txt__c)){
                sch.Core_MDF_Status__c = jobIdToStatusMap.get(sch.Core_MDF_Job_Id_Txt__c).Status;
            }
        }
        return pendingRecords;
       /* try{
            Database.update(pendingRecords); 
        }
        catch(exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
            throw e;} */
    }
    /****************************************************************************************************** 
Method Name:        scheduleJob
@return  :          id
@parameters:        batchClassInstance - instance of batch class to be scheduled , scopeSize - batch size ,
scheduledTime - time at which batch class has to be executed
Description:        This method is used to create custom scheduler records.
Added By:           Accenture - NK - 03/10/2021
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    public static id scheduleJob(Object batchClassInstance, Integer scopeSize, DateTime scheduledTime){  
        Core_MDF_Custom_Scheduler__c customSch = new Core_MDF_Custom_Scheduler__c();
        String serializedInstance = JSON.serialize(batchClassInstance); 
        customSch.Core_MDF_Object_JSON_Txt__c = serializedInstance;
        customSch.Core_MDF_Batch_Size_Nbr__c = scopeSize;
        customSch.Core_MDF_Scheduled_Time_Dt__c = scheduledTime;
        customSch.Core_MDF_Batch_Class_Name_Txt__c = String.valueOf(batchClassInstance).split(':')[0];
        customSch.Core_MDF_Status__c = 'Scheduled';
        try{
            database.insert(customSch);  
        }
        catch(exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
            throw e;}
        return customSch.Id;
    }
    /****************************************************************************************************** 
Method Name:        generateBatchChaining
@return  :          void
@parameters:        --
Description:        This method is used to chain another schedule job to current job.
Added By:           Accenture - NK - 03/10/2021
Modified By:        Date:       Changes: 
*******************************************************************************************************/
    public static void generateBatchChaining(){
        String nextRunCron;
        String batchJobName;
        // custom setting mdf_config_custom_scheruler_frequency_min
        Core_MDF_Configuration__c config = Core_MDF_Configuration__c.getValues('CUSTOM_SCHEDULER_FREQUENCY_MIN');
        DateTime nextRunTime = system.now().addMinutes(Integer.valueOf(config.Core_MDF_Value__c)); 
        nextRunCron = 0+' '+nextRunTime.minute()+' '+nextRunTime.hour()+' '+nextRunTime.day()+'-'+nextRunTime.day()+' '+nextRunTime.month()+'  ? '+nextRunTime.year();
        Double randomNum = math.random();
        batchJobName = 'CustomSchedulerJob-'+nextRunTime+'_'+randomNum ;
        string jobId = System.schedule(batchJobName, nextRunCron, new Core_MDF_CustomScheduler());        
    }
    
   public static void cancelJob(String customSchId ){ 
       Core_MDF_Custom_Scheduler__c custSch = [select Id,Core_MDF_Job_Id_Txt__c,Core_MDF_Status__c FROM Core_MDF_Custom_Scheduler__c where Id=: customSchId];
       if(custSch != null ){
       system.abortJob(custSch.Core_MDF_Job_Id_Txt__c);
       }
   }
}