public class Core_MDF_BatchSchedulerUtility_Clone {
	//Start batch job for specific program    
    public static list<Core_MDF_Batch_Scheduler_Line_Item__c> startBatchJob(string program){
        Integer maxSchedule = 50;  
        Integer availableLimit = getAvailability();
        if(availableLimit>maxSchedule ){
            availableLimit = maxSchedule;
        }
        List<Core_MDF_Batch_Scheduler_Line_Item__c > lstBatch = new List<Core_MDF_Batch_Scheduler_Line_Item__c >();
        if(availableLimit > 0){
            lstBatch = getScheduledRecords(availableLimit,program); 
            system.debug('lstBatch-->'+ lstBatch);
        }
        if(lstBatch != null && lstBatch.size()>0){ 
            for(Core_MDF_Batch_Scheduler_Line_Item__c  schRec : lstBatch){ 
                // type casting and deserializing batch class instance                
                //test code begins
                Object des_Obj;
                if(!string.isEmpty(schRec.Core_MDF_Batch_Scheduler__r.Core_MDF_Object_JSON_Txt__c)){
                    Type type = Type.forName(schRec.Core_MDF_Batch_Scheduler__r.Core_MDF_Batch_Class_Name_Txt__c);
                    des_Obj = JSON.deserialize (schRec.Core_MDF_Batch_Scheduler__r.Core_MDF_Object_JSON_Txt__c,type);
                }
                else{
                    des_Obj = (Object)System.Type.forName(schRec.Core_MDF_Batch_Scheduler__r.Core_MDF_Batch_Class_Name_Txt__c).newInstance();
                }
                //test code ends               
                Database.batchable<sObject> batch = (Database.batchable<sObject>)des_Obj;
                schRec.Core_MDF_Job_Id_Txt__c = Database.executeBatch(batch, Integer.valueOf(schRec.Core_MDF_Batch_Scheduler__r.Core_MDF_Batch_Size_Nbr__c));
                schRec.Core_MDF_Status_Txt__c = 'Pending';
                schRec.Core_MDF_Execution_Time_Dt__c = System.now();
            }                     
            
            try{
                Database.update(lstBatch);  
            }
            catch(exception e){Core_MDF_CCP_UtilityClass.logError(e); throw e;} 
          
        }
       
        return lstBatch;
    }
    
    //Get available job slots. Max 50 jobs can be executed in one single transaction    
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
    
    //Get scheduled records due for execution for specific program based on available limit
    public static List<Core_MDF_Batch_Scheduler_Line_Item__c> getScheduledRecords(integer availableLimit,string program){
        system.debug('in getRecords');
        DateTime dt = System.now(); 
        system.Debug(availableLimit);
        if(test.isRunningTest()){
            dt = dt.addDays(2);
        }
        List<string> lstProg = new List<string>();
        if(string.isNotEmpty(program)){
            lstProg = program.split(',');
        }
        return [select id,Core_MDF_Batch_Scheduler__c,Core_MDF_Scheduled_Time_Dt__c,Core_MDF_Status_Txt__c,Core_MDF_Batch_Scheduler__r.Core_MDF_Batch_Class_Name_Txt__c,Core_MDF_Batch_Scheduler__r.Core_MDF_Object_JSON_Txt__c,Core_MDF_Batch_Scheduler__r.Core_MDF_Batch_Size_Nbr__c,Core_MDF_Batch_Scheduler__r.Core_MDF_Priority__c from Core_MDF_Batch_Scheduler_Line_Item__c   
                WHERE Core_MDF_Status_Txt__c ='Scheduled' AND Core_MDF_Batch_Scheduler__r.Core_MDF_Program_Txt__c IN:lstProg /* and Core_MDF_Batch_Scheduler__c ='a5Mg0000000DEKUEA4' */ ORDER BY Core_MDF_Batch_Scheduler__r.Core_MDF_Priority__c,Core_MDF_Scheduled_Time_Dt__c limit :availableLimit];       
    }
    
    //Update the status of executed jobs for a specific program
    public static list<Core_MDF_Batch_Scheduler_Line_Item__c> updateStatusForCompletedOrFailedJob(string program){
        List<Core_MDF_Batch_Scheduler_Line_Item__c> pendingRecords  = new List<Core_MDF_Batch_Scheduler_Line_Item__c>();
        List<Core_MDF_Batch_Scheduler__c> parentRecord = new List<Core_MDF_Batch_Scheduler__c>();
        Set<String> jobIds = new Set<String>();
        List<AsyncApexJob> apexJobLst = new List<AsyncApexJob>();
        Map<Id, AsyncApexJob> jobIdToStatusMap = new Map<Id, AsyncApexJob>(); 
        List<string> lstProg = new List<string>();
        
        if(string.isNotEmpty(program)){
        	lstProg = program.split(',');    
        }
        
        pendingRecords = [Select Core_MDF_Job_Id_Txt__c,Core_MDF_Status_Txt__c,Core_MDF_Batch_Scheduler__r.Core_MDF_Job_Frequency__c,Core_MDF_Batch_Scheduler__r.Core_MDF_Program_Txt__c FROM Core_MDF_Batch_Scheduler_Line_Item__c WHERE Core_MDF_Status_Txt__c = 'Pending' and Core_MDF_Batch_Scheduler__r.Core_MDF_Program_Txt__c IN:lstProg];
        
        for(Core_MDF_Batch_Scheduler_Line_Item__c sch : pendingRecords){
            jobIds.add(sch.Core_MDF_Job_Id_Txt__c);
        }
        if(jobIds != null && jobIds.size()>0){
            for(AsyncApexJob apexJob : [Select Id, Status FROM AsyncApexJob WHERE Status IN ('Failed','Completed') AND ID IN : jobIds]){
                jobIdToStatusMap.put(apexJob.Id, apexJob);
            }
        }
                
            for(Core_MDF_Batch_Scheduler_Line_Item__c sch : pendingRecords){
            if(jobIdToStatusMap != null && jobIdToStatusMap.size()>0 && jobIdToStatusMap.containsKey(sch.Core_MDF_Job_Id_Txt__c)){
                sch.Core_MDF_Status_Txt__c = jobIdToStatusMap.get(sch.Core_MDF_Job_Id_Txt__c).Status;               
            }
        }
          
                       
       try{
            Database.update(pendingRecords);
        }
        catch(exception e){Core_MDF_CCP_UtilityClass.logError(e); throw e;}
        
        return pendingRecords;
      
    }
    
    //Schedule next batch run(job which picks scheduled records for execution) for a specific program
    public static void generateBatchChaining(string program){
        String nextRunCron;
        String batchJobName;
        DateTime nextRunTime;
        String progName;
        //custom setting mdf_config_custom_scheruler_frequency_min
        if(!test.isRunningTest()){
        	Core_MDF_Configuration__c config = Core_MDF_Configuration__c.getValues('CUSTOM_SCHEDULER_FREQUENCY_MIN');
        	nextRunTime = system.now().addMinutes(Integer.valueOf(config.Core_MDF_Value__c)); 
        }else{
            nextRunTime = system.now().addMinutes(2);
        }         
        nextRunCron = 0+' '+nextRunTime.minute()+' '+nextRunTime.hour()+' '+nextRunTime.day()+'-'+nextRunTime.day()+' '+nextRunTime.month()+'  ? '+nextRunTime.year();
        Double randomNum = math.random();
        if(string.isNotEmpty(program)){
        	progName = program.replaceAll(',','_');
        }
        batchJobName = progName+'_'+'CustomBatchSchedulerJob-'+nextRunTime+'_'+randomNum ;
        string jobId = System.schedule(batchJobName, nextRunCron, new Core_MDF_Custom_BatchJobSch(program));        
         
    }
    

}