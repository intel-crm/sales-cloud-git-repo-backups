/****************************************************************************************************************************************
* Class Name  : Core_MDF_BatchSchedulerUtility
* Version     : 1.0 
* Created Date: 8-Apr-2021
* Modification Log :
* Developer   Vivek                  Date                          Description
*****************************************************************************************************************************************/
public without sharing class Core_MDF_BatchSchedulerUtility {        
    //Start batch job for specific program      
    public static list<Core_MDF_Batch_Scheduler_Line_Item__c> startBatchJob(string program){
        //Integer maxSchedule = 50;  
        
        List<Core_MDF_Batch_Scheduler_Line_Item__c > lstBatch = new List<Core_MDF_Batch_Scheduler_Line_Item__c >();
        string jobId = '';
        try{
            Core_MDF_Configuration__c configJobLimitMin = Core_MDF_Configuration__c.getValues('CUSTOM_SCHEDULER_JOB_LIMIT_MIN'); 
            Integer maxSchedule = Integer.valueOf(configJobLimitMin.Core_MDF_Value__c);  //50
            Integer availableLimit = getAvailability();
            if(availableLimit>maxSchedule ){
                availableLimit = maxSchedule;
            }
            
            if(availableLimit > 0){
                lstBatch = getScheduledRecords(availableLimit,program); 
            }
            
            List<Core_MDF_Batch_Scheduler_Line_Item__c> lineItemList=new List<Core_MDF_Batch_Scheduler_Line_Item__c>();
            if(lstBatch != null && lstBatch.size()>0){ 
                List<String> classesImplementingInterface = new List<String>();
                for( ApexTypeImplementor ati : [SELECT ClassName, ClassNamespacePrefix
                                      FROM ApexTypeImplementor 
                                      WHERE InterfaceName = 'Core_MDF_BatchSchedulerInterface']){
                    classesImplementingInterface.add(ati.ClassName);
                }
                for(Core_MDF_Batch_Scheduler_Line_Item__c  schRec : lstBatch){ 
                    boolean errorFlag = false;
                    // type casting and deserializing batch class instance 
                    Object des_Obj;
                    try{
                        if(!string.isEmpty(schRec.Core_MDF_Batch_Scheduler__r.Core_MDF_Object_JSON_Txt__c)){
                            if(!string.isEmpty(schRec.Core_MDF_Batch_Scheduler__r.Core_MDF_Batch_Class_Signature_Txt__c)){

                                string signature = schRec.Core_MDF_Batch_Scheduler__r.Core_MDF_Batch_Class_Signature_Txt__c;
                                string parameters = signature.substringBetween('(',')');
                                List<String> paramList = parameters.split(',');
                                map<String,object> parmValueMap = (Map<String, Object>)JSON.deserializeUntyped(schRec.Core_MDF_Batch_Scheduler__r.Core_MDF_Object_JSON_Txt__c);
                                if(paramList.size() == parmValueMap.size()){
                                    //check to confirm if interface is implemented
                                    if(classesImplementingInterface.contains(schRec.Core_MDF_Batch_Scheduler__r.Core_MDF_Batch_Class_Name_Txt__c)){
                                        Core_MDF_BatchSchedulerInterface batchint  = (Core_MDF_BatchSchedulerInterface)System.Type.forName(schRec.Core_MDF_Batch_Scheduler__r.Core_MDF_Batch_Class_Name_Txt__c).newInstance();
                                        des_Obj = batchint.generateInstance(schRec.Core_MDF_Batch_Scheduler__r.Core_MDF_Object_JSON_Txt__c,schRec.Core_MDF_Batch_Scheduler__r.Core_MDF_Batch_Class_Signature_Txt__c);
                                    }
                                    else{ 
                                        Core_MDF_CCP_UtilityClass.logErrorinLogObject('Selected batch class does not implement batch scheduler interface to instantiate class signature provided.','Core_MDF_Batch_Scheduler__c');
                                    }
                                }
                                else{
                                    Core_MDF_CCP_UtilityClass.logErrorinLogObject('parameter count in json does not match parameter count in signature.','Core_MDF_Batch_Scheduler__c');
                                }
                            }
                            else{
                                Type type = Type.forName(schRec.Core_MDF_Batch_Scheduler__r.Core_MDF_Batch_Class_Name_Txt__c);
                                des_Obj = JSON.deserialize (schRec.Core_MDF_Batch_Scheduler__r.Core_MDF_Object_JSON_Txt__c,type); 
                            }
                        }
                        else{
                            des_Obj = (Object)System.Type.forName(schRec.Core_MDF_Batch_Scheduler__r.Core_MDF_Batch_Class_Name_Txt__c).newInstance();
                        }
                    }catch(Exception e){
                        Core_MDF_CCP_UtilityClass.logError(e);
                        schRec.Core_MDF_Status_Txt__c = 'Failed';
                        schRec.Core_MDF_Error_Message__c=e.getMessage();
                        errorFlag = true;
                    }
                    if(!errorFlag){
                        Database.batchable<sObject> batch = (Database.batchable<sObject>)des_Obj;  
                        jobId = Database.executeBatch(batch, Integer.valueOf(schRec.Core_MDF_Batch_Scheduler__r.Core_MDF_Batch_Size_Nbr__c));
                        
                        if(jobId instanceOf Id){  
                            schRec.Core_MDF_Status_Txt__c = 'Pending';
                        }else{
                            schRec.Core_MDF_Status_Txt__c = 'Failed';
                            schRec.Core_MDF_Error_Message__c= Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Invalid_JobId');
                        }
                        
                        schRec.Core_MDF_Job_Id_Txt__c = jobId;
                        
                    }   
                    schRec.Core_MDF_Execution_Time_Dt__c = System.now();                  
                }
                Database.update(lstBatch);
            }
        }catch(exception e){Core_MDF_CCP_UtilityClass.logError(e); throw e;}
        
        return lstBatch;       
    } 
    
    
    //Get available job slots. Max 50 jobs can be executed in one single transaction    
    public static integer getAvailability(){ 
        Core_MDF_Configuration__c configJobLimitMax = Core_MDF_Configuration__c.getValues('CUSTOM_SCHEDULER_JOB_LIMIT_MAX');
        Integer maxLimit = Integer.valueOf(configJobLimitMax.Core_MDF_Value__c); //100
        Integer availableLimit = Integer.valueOf(configJobLimitMax.Core_MDF_Value__c);  // defaulted to 100
        AggregateResult[] groupedResults = [Select Count(Id) FROM AsyncApexJob Where Status = 'Holding'];
        if(groupedResults.size()>0){
            String exp0 = String.valueOf(groupedResults[0].get('expr0')); 
            availableLimit = maxLimit - Integer.valueOf(exp0);
        }
        return availableLimit;
    }
    
    //Get scheduled records due for execution for specific program based on available limit
    public static List<Core_MDF_Batch_Scheduler_Line_Item__c> getScheduledRecords(integer availableLimit,string program){
        DateTime dt = System.now(); 
        if(test.isRunningTest()){
            dt = dt.addDays(2);
        }
        List<string> lstProg = new List<string>();
        if(string.isNotEmpty(program)){
            lstProg = program.split(',');
        }
        
        return [select id,Core_MDF_Batch_Scheduler__c,Core_MDF_Scheduled_Time_Dt__c,Core_MDF_Status_Txt__c,Core_MDF_Batch_Scheduler__r.Core_MDF_Batch_Class_Name_Txt__c,Core_MDF_Batch_Scheduler__r.Core_MDF_Batch_Class_Signature_Txt__c,Core_MDF_Batch_Scheduler__r.Core_MDF_Object_JSON_Txt__c,Core_MDF_Batch_Scheduler__r.Core_MDF_Batch_Size_Nbr__c,Core_MDF_Batch_Scheduler__r.Core_MDF_Priority__c from Core_MDF_Batch_Scheduler_Line_Item__c   
                WHERE Core_MDF_Status_Txt__c ='Scheduled' AND Core_MDF_Scheduled_Time_Dt__c <=:dt AND Core_MDF_Batch_Scheduler__r.Core_MDF_Program_Txt__c IN:lstProg  ORDER BY Core_MDF_Batch_Scheduler__r.Core_MDF_Priority__c,Core_MDF_Scheduled_Time_Dt__c limit :availableLimit];       
    }
    
    //Update the status of executed jobs for a specific program
    public static list<Core_MDF_Batch_Scheduler_Line_Item__c> updateStatusForCompletedOrFailedJob(string program){
        List<Core_MDF_Batch_Scheduler_Line_Item__c> pendingRecords  = new List<Core_MDF_Batch_Scheduler_Line_Item__c>();
        List<Core_MDF_Batch_Scheduler__c> parentRecord = new List<Core_MDF_Batch_Scheduler__c>();
        Set<String> jobIds = new Set<String>();
        List<AsyncApexJob> apexJobLst = new List<AsyncApexJob>();
        Map<Id, AsyncApexJob> jobIdToStatusMap = new Map<Id, AsyncApexJob>(); 
        List<string> lstProg = new List<string>();
        List<Core_MDF_Batch_Scheduler_Line_Item__c> schItemsForEmail = new List<Core_MDF_Batch_Scheduler_Line_Item__c>();
        
        if(string.isNotEmpty(program)){
            lstProg = program.split(',');    
        }
        
        pendingRecords = [Select Name,Core_MDF_Job_Id_Txt__c,Core_MDF_Status_Txt__c,Core_MDF_Batch_Scheduler__r.Core_MDF_Job_Frequency__c,Core_MDF_Batch_Scheduler__r.Core_MDF_Program_Txt__c,Core_MDF_Batch_Scheduler__r.CreatedBy.Email,Core_MDF_Batch_Scheduler__r.Core_MDF_Enable_Email_Notification__c,Core_MDF_Batch_Scheduler__r.Core_MDF_Include_All_Notifications__c,Core_MDF_Batch_Scheduler__r.Core_MDF_Email_Receipients__c FROM Core_MDF_Batch_Scheduler_Line_Item__c WHERE Core_MDF_Status_Txt__c = 'Pending' and Core_MDF_Batch_Scheduler__r.Core_MDF_Program_Txt__c IN:lstProg];
        
        for(Core_MDF_Batch_Scheduler_Line_Item__c sch : pendingRecords){
            jobIds.add(sch.Core_MDF_Job_Id_Txt__c);
        }
        if(jobIds != null && jobIds.size()>0){
            for(AsyncApexJob apexJob : [Select Id, Status, NumberOfErrors, ExtendedStatus FROM AsyncApexJob WHERE Status IN ('Failed','Completed') AND ID IN : jobIds]){
                jobIdToStatusMap.put(apexJob.Id, apexJob);
            }
        }
        
        for(Core_MDF_Batch_Scheduler_Line_Item__c sch : pendingRecords){
            if(jobIdToStatusMap != null && jobIdToStatusMap.size()>0 && jobIdToStatusMap.containsKey(sch.Core_MDF_Job_Id_Txt__c)){
                sch.Core_MDF_Status_Txt__c = jobIdToStatusMap.get(sch.Core_MDF_Job_Id_Txt__c).Status;

                Integer numberOfFailures = jobIdToStatusMap.get(sch.Core_MDF_Job_Id_Txt__c).NumberOfErrors;
                String StatusErrorDetail = jobIdToStatusMap.get(sch.Core_MDF_Job_Id_Txt__c).ExtendedStatus;
                sch.Core_MDF_Number_of_errors__c = numberOfFailures;
                sch.Core_MDF_Status_Detail__c = StatusErrorDetail;

                // Filtering Line Items For Email Notification
                if(sch.Core_MDF_Batch_Scheduler__r.Core_MDF_Enable_Email_Notification__c && ((!sch.Core_MDF_Batch_Scheduler__r.Core_MDF_Include_All_Notifications__c   && sch.Core_MDF_Status_Txt__c == 'Failed') ||  sch.Core_MDF_Batch_Scheduler__r.Core_MDF_Include_All_Notifications__c)) {
                    schItemsForEmail.add(sch);
                }
                //Added condition for IPA batches, to get emails in case batch is completed with 1 or more failure batches
                if(sch.Core_MDF_Batch_Scheduler__r.Core_MDF_Enable_Email_Notification__c && !sch.Core_MDF_Batch_Scheduler__r.Core_MDF_Include_All_Notifications__c && sch.Core_MDF_Status_Txt__c == 'Completed' && (numberOfFailures >= 1 || String.isNotBlank(StatusErrorDetail))){
                    schItemsForEmail.add(sch);
                }
            }
        }
        
        
        try{
            Database.update(pendingRecords);
        }
        catch(exception e){Core_MDF_CCP_UtilityClass.logError(e); throw e;}

        try{
            if(!schItemsForEmail.isEmpty()){
                Core_MDF_BatchSchedulerUtility.sendEmailNotificationForJobs(schItemsForEmail,program);
            }
        }catch(exception e){
            Core_MDF_CCP_UtilityClass.logError(e); 
        }
        
        return pendingRecords;
        
    }
    
    //Schedule next batch run(job which picks scheduled records for execution) for a specific program
    public static void generateBatchChaining(string program){
        String nextRunCron;
        String batchJobName;
        DateTime nextRunTime;
        String progName;
        string jobNameStr;
        Core_MDF_Configuration__c configBatchName = Core_MDF_Configuration__c.getValues('CUSTOM_SCHEDULER_BATCH_JOB_NAME');
        jobNameStr = configBatchName.Core_MDF_Value__c;
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
        batchJobName = progName+'_'+ jobNameStr +nextRunTime+'_'+randomNum ;
        string jobId = System.schedule(batchJobName, nextRunCron, new Core_MDF_Custom_BatchJobSch(program));        
        
    }

    public static void sendEmailNotificationForJobs(List<Core_MDF_Batch_Scheduler_Line_Item__c> schLineItemList,String programName){

        Map<String,Batch_Scheduler_Email_Templates__c> emailTemplateForProgram = Batch_Scheduler_Email_Templates__c.getAll();
        String templateName = '';

        if(!emailTemplateForProgram.containsKey(programName)){
            templateName = System.Label.Default_Batch_Scheduler_Email_Template_Name;
        }else{
            templateName = emailTemplateForProgram.get(programName).Template_Name__c;
        }
        if(!String.isBlank(templateName)){
            List<Messaging.SingleEmailMessage> allEmailMessages = new List<Messaging.SingleEmailMessage>();
            EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body FROM EmailTemplate where name =:templateName];
            for(Core_MDF_Batch_Scheduler_Line_Item__c sch : schLineItemList){
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setTargetObjectId(UserInfo.getUserId());
                message.setWhatId(sch.Id); 
                message.setUseSignature(false);
                message.setSaveAsActivity(false); 
                message.setTemplateID(emailTemplate.Id);
                message.setTreatTargetObjectAsRecipient(false);
                message.setOrgWideEmailAddressId(Label.Core_MDF_OrgWideId);//17001
                String[] toAddresses = new String[]{sch.Core_MDF_Batch_Scheduler__r.CreatedBy.Email};
                if(!String.isBlank(sch.Core_MDF_Batch_Scheduler__r.Core_MDF_Email_Receipients__c)){
                    toAddresses.addAll(sch.Core_MDF_Batch_Scheduler__r.Core_MDF_Email_Receipients__c.split(','));
                }
                message.toAddresses = toAddresses;
                allEmailMessages.add(message);
            }

            Messaging.SingleEmailMessage[] messages = allEmailMessages;
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        }
    }
    
}