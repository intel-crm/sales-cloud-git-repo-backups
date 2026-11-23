global without sharing class Core_MDF_Batch_RecoverySchedules implements Database.Batchable<sObject>, Schedulable, Database.Stateful{
    
    public Date currentDate = System.today();

    public Core_MDF_Batch_RecoverySchedules(){}

    public Core_MDF_Batch_RecoverySchedules(Date currentDate){//ScheduleRecoveryNotification
        this.currentDate = currentDate;
    }
    global Database.queryLocator start(Database.BatchableContext bc)
    {
        String param = 'Core_MDF_Recovery_Notification_Mapping';
        return Database.getQueryLocator('SELECT Id,Core_MDF_Value_Txt__c FROM Core_MDF_Custom_Label_Configration__mdt WHERE QualifiedApiName =:param'); 
    }
    
    global void execute(Database.BatchableContext batchableContext, List<sObject> scope)
    {
        try{
            List<Period> currentFiscalQuarterDetails = Core_MDF_Calendar_Utility.getFiscalQuarterWeekPeriods(currentDate);
            //Exit from the exection if the size is not 13(4,4,5)
            if(currentFiscalQuarterDetails.size() != 13){
                return;
            }
            //Key: Month1Week1 => Period record
            Map<String, Period> monthNumberToQuarterPeriodsMap = Core_MDF_Calendar_Utility.mapMonthAndWeekPeriods(currentFiscalQuarterDetails);
            
            //Map<String, List<Date>> programToRecoveryRunDate = new Map<String, List<Date>>();
            Map<String, Map<String,Date>> programToMonthToRecoveryRunDate = new Map<String, Map<String,Date>>();
            
            Map<String, Core_MDF_Recovery_Utility.RecoveryNotificationMapping> programToWrapperMap = new Map<String, Core_MDF_Recovery_Utility.RecoveryNotificationMapping>();
            String jsonString = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Recovery_Notification_Mapping');
            for(Core_MDF_Recovery_Utility.RecoveryNotificationMapping record : (List<Core_MDF_Recovery_Utility.RecoveryNotificationMapping>)JSON.deserialize(jsonString, List<Core_MDF_Recovery_Utility.RecoveryNotificationMapping>.class)){
                programToWrapperMap.put(record.program,record);
                Integer week = Integer.valueOf(record.weekAndDay.split(',')[0]);
                Integer dayOfWeek = Integer.valueOf(record.weekAndDay.split(',')[1]);
                for(String recordMonth : record.months.split(',')){
                    String key = 'M' + recordMonth + 'WW' + String.valueOf(week);
                    if(monthNumberToQuarterPeriodsMap.containsKey(key)){
                        Period weekPeriods = monthNumberToQuarterPeriodsMap.get(key);
                        Date recoveryExectionDate = Date.valueOf(weekPeriods.StartDate) + dayOfWeek;
                        
                        if(programToMonthToRecoveryRunDate.containsKey(record.program)){
                            programToMonthToRecoveryRunDate.get(record.program).put(recordMonth, recoveryExectionDate);
                        }else{
                            programToMonthToRecoveryRunDate.put(record.program, new Map<String, Date>{recordMonth => recoveryExectionDate});
                        }
                    }
                }
            }
            
            Map<String, Core_MDF_Batch_Scheduler__c> uniqueKeyToBatchSchedulerMap = new Map<String, Core_MDF_Batch_Scheduler__c>();
            Map<Date, Integer> recoveryRunDateToMinutuesToAddMap= new Map<Date, Integer>();
            Integer minutesToAdd = 5;
            for(String program : programToMonthToRecoveryRunDate.keySet()){
                for(String recoveryMonth : programToMonthToRecoveryRunDate.get(program).keySet()){
                    
                    Date recoveryExecutionDate = programToMonthToRecoveryRunDate.get(program).get(recoveryMonth);
                    String budgetType = '';
                    String region = '';
                    Boolean onlyPreselection = false;
                    Boolean notifyReminders = false;
                    //Basetime- Surepay 8:00 & Recovery- 9:00 IST
                    Integer surePayExecutionHour;
                    Integer surePayExecutionMin;
                    Integer recoveryExecutionHour;
                    Integer recoveryExecutionMin;

                    if(programToWrapperMap.containsKey(program)){
                        Core_MDF_Recovery_Utility.RecoveryNotificationMapping programToWrapper = programToWrapperMap.get(program);
                        budgetType = String.isNotBlank(programToWrapper.budgettype) ? programToWrapper.budgettype : '';
                        region = String.isNotBlank(programToWrapper.region) ? programToWrapper.region: '';
                        List<String> onlyPreselectionMonthList= String.isNotBlank(programToWrapper.onlyReadyToRecoverMonths) ? programToWrapper.onlyReadyToRecoverMonths.split(',') : new List<String>();
                        onlyPreselection = onlyPreselectionMonthList.contains(recoveryMonth) ? true : false;
                        notifyReminders = String.isNotBlank(programToWrapper.reminderDays) ? true : false;

                        //Added
                        if(String.isNotBlank(programToWrapper.surePayExeTime)){
                            List<String> surePayTime = programToWrapper.surePayExeTime.split(':');
                            if(surePayTime.size() == 2){
                                surePayExecutionHour = Integer.valueOf(surePayTime[0]);
                                surePayExecutionMin = Integer.valueOf(surePayTime[1]);
                            }
                        }
                        if(String.isNotBlank(programToWrapper.recoveryExeTime)){
                            List<String> recoveryTime = programToWrapper.recoveryExeTime.split(':');
                            if(recoveryTime.size() == 2){
                                recoveryExecutionHour = Integer.valueOf(recoveryTime[0]);
                                recoveryExecutionMin = Integer.valueOf(recoveryTime[1]);
                            }
                        }


                        //Recovery Reminder notifications Schedule(2, 5 Days)
                        if(!onlyPreselection && notifyReminders && String.isNotBlank(programToWrapper.reminderDays)){
                            for(String daysToReduce : programToWrapper.reminderDays.split(',')){
                                Date dateToSchedule = Core_MDF_Recovery_Utility.reduceBusinessDays(recoveryExecutionDate, Integer.valueOf(daysToReduce));

                                String scheduleRecoveryNotificationJson = '{"program" : "' + program + '","action" : "SendEmail","recoveryDate" : "' + recoveryExecutionDate + '"}';
                                Core_MDF_Batch_Scheduler__c reminderNotificationBatchSchedule = createBatchSchedulerInstance(scheduleRecoveryNotificationJson, 50, dateToSchedule, 'Core_MDF_Batch_RecoveryAdminNotification', 'Once', 'High', 'CCP');
                                uniqueKeyToBatchSchedulerMap.put(scheduleRecoveryNotificationJson.replaceAll(' ', '') + dateToSchedule, reminderNotificationBatchSchedule);
                            }
                            minutesToAdd += 5;
                        }
                    }

                    //Integer minutesToAddForRecoveryRun = 0;
                    String technicalProgramName = Core_MDF_CCP_GenericUtility.getTechnicalProgramName(program);
                    // Add SurePay Batch Schedule
                    String surePayJson = '{"program" : "' + technicalProgramName + '"}';
                    String recoverRunJson = '{"program" : "' + technicalProgramName + '","budgetType" : "'+ budgetType +'","quarterYear" : "","accountIds" : "","regions" : "'+ region +'","source" : "Payment Run","isRecReq_RecvryDone" : ' + onlyPreselection +',"isPreSelClaim_RecvryDone" : ' + onlyPreselection + '}';
                    
                    // if(recoveryRunDateToMinutuesToAddMap.containsKey(recoveryExecutionDate)){
                    //     minutesToAddForRecoveryRun = recoveryRunDateToMinutuesToAddMap.get(recoveryExecutionDate)+15;
                    // }

                    Datetime surePayExecutionDateAndTime = DateTime.newInstanceGmt(recoveryExecutionDate.year(), recoveryExecutionDate.month(), recoveryExecutionDate.day(), surePayExecutionHour, surePayExecutionMin, 0);

                    Core_MDF_Batch_Scheduler__c surePayBatchSchedule = createBatchSchedulerInstance(surePayJson, 50, surePayExecutionDateAndTime, 'Core_MDF_SurePay_Batch', 'Once', 'High', 'CCP');
                    uniqueKeyToBatchSchedulerMap.put(surePayJson.replaceAll(' ', '') + recoveryExecutionDate, surePayBatchSchedule);
                    
                    //recoveryRunDateToMinutuesToAddMap.put(recoveryExecutionDate, minutesToAddForRecoveryRun);
                    Datetime recoveryExecutionDateAndTime = DateTime.newInstanceGmt(recoveryExecutionDate.year(), recoveryExecutionDate.month(), recoveryExecutionDate.day(), recoveryExecutionHour, recoveryExecutionMin, 0);

                    Core_MDF_Batch_Scheduler__c recoveryRunBatchSchedule =createBatchSchedulerInstance(recoverRunJson, 50, recoveryExecutionDateAndTime, 'Core_MDF_Recovery_Batch', 'Once', 'High', 'CCP');   
                    uniqueKeyToBatchSchedulerMap.put(recoverRunJson.replaceAll(' ', '') + recoveryExecutionDate, recoveryRunBatchSchedule);
                }
            }

            //Duplicate Check
            uniqueKeyToBatchSchedulerMap = duplicateBatchSchedulerCheck(uniqueKeyToBatchSchedulerMap, new List<String>{'Core_MDF_Recovery_Batch' , 'Core_MDF_Batch_RecoveryAdminNotification', 'Core_MDF_SurePay_Batch'});
            
            //Insert Batch scheduler records for Reminder notification schedule and Recovery Run
            if(uniqueKeyToBatchSchedulerMap != null && !uniqueKeyToBatchSchedulerMap.isEmpty()){
                Database.insert(uniqueKeyToBatchSchedulerMap.values(),false);
            }
        }catch(Exception ex){System.debug('Exception has occurred' + ex.getmessage());}
    }
    
    global void finish(Database.BatchableContext bc){
        
    }

    // WW14 - Method moved to Core_MDF_Calendar_Utility - RP
    /*global List<Period> getFiscalQuarterWeekPeriods(Date inputDate) {
        Date quarterStartDate;
        Date quarterEndDate;
        for(Period currentYearDetail : [SELECT FiscalYearSettings.Name, Type,Number,StartDate,EndDate FROM Period WHERE FiscalYearSettings.YearType='Custom' AND StartDate <=: inputDate and EndDate >=: inputDate ORDER BY Type, Number DESC]){
            if(currentYearDetail.Type == 'Quarter'){//To Find Quarter Start and End date
                quarterStartDate = currentYearDetail.startDate;
                quarterEndDate = currentYearDetail.EndDate;
            }
        }

        List<Period> currentFiscalQuarterDetails = [SELECT FiscalYearSettings.Name, type,Number,StartDate,EndDate FROM Period WHERE FiscalYearSettings.YearType='Custom' AND StartDate >=: quarterStartDate AND EndDate <=: quarterEndDate AND Type ='Week' ORDER By Number];
        return currentFiscalQuarterDetails;
    }*/

    // WW14 - Method moved to Core_MDF_Calendar_Utility - RP
    /*global Map<String, Period> mapMonthAndWeekPeriods(List<Period> currentFiscalQuarterDetails) {
        Map<String, Period> monthNumberToQuarterPeriodsMap = new Map<String, Period>();
        Integer monthNumber;
        Integer weekNumber;
        Integer weekCount = 1;

        for(Period currWeekPeriod : currentFiscalQuarterDetails){// Quarter Weeks: 4,4,5
            if(weekCount <= 4){
                if(weekCount == 1){
                    monthNumber = 1;
                    weekNumber = 1;
                }
                
            }else if(weekCount >= 5 && weekCount <= 8){
                if(weekCount == 5){
                    monthNumber = 2;
                    weekNumber = 1;
                }
            }else{
                if(weekCount == 9){
                    monthNumber = 3;
                    weekNumber = 1;
                }
            }

            monthNumberToQuarterPeriodsMap.put(('M' + String.valueOf(monthNumber) + 'WW' + String.valueOf(weekNumber)),  currWeekPeriod);
            weekNumber += 1;
            weekCount += 1;
        }
        return monthNumberToQuarterPeriodsMap;
    }*/

    global Core_MDF_Batch_Scheduler__c createBatchSchedulerInstance(String objJSON, Integer batchSize, DateTime scheduledTime, String batchClassName, String frequency, String priority, String program) {
        Core_MDF_Batch_Scheduler__c customSch = new Core_MDF_Batch_Scheduler__c();
        customSch.Core_MDF_Object_JSON_Txt__c = objJSON;
        customSch.Core_MDF_Batch_Size_Nbr__c = batchSize;
        customSch.Scheduled_Time_Dt__c = scheduledTime;
        customSch.Core_MDF_Batch_Class_Name_Txt__c = batchClassName;
        customSch.Core_MDF_Job_Frequency__c = frequency;
        customSch.Core_MDF_Priority__c = priority;
        customSch.Core_MDF_Program_Txt__c = program;

        return customSch;
    }

    global Map<String, Core_MDF_Batch_Scheduler__c> duplicateBatchSchedulerCheck(Map<String, Core_MDF_Batch_Scheduler__c> uniqueKeyToBatchSchedulerMap, List<String> classNames) {
        for(Core_MDF_Batch_Scheduler__c customSch : [SELECT Id,Core_MDF_Object_JSON_Txt__c, Scheduled_Time_Dt__c, Core_MDF_Scheduler_Status_Txt__c, Core_MDF_Status_Txt__c FROM Core_MDF_Batch_Scheduler__c WHERE Core_MDF_Scheduler_Status_Txt__c = 'Scheduled' AND Core_MDF_Batch_Class_Name_Txt__c IN: classNames]){
            if(String.isNotBlank(customSch.Core_MDF_Object_JSON_Txt__c)){
                String key = customSch.Core_MDF_Object_JSON_Txt__c.replaceAll(' ','') + customSch.Scheduled_Time_Dt__c.dateGMT();
                if(uniqueKeyToBatchSchedulerMap.containsKey(key)){
                    uniqueKeyToBatchSchedulerMap.remove(key);
                }
            }
        }   

        return uniqueKeyToBatchSchedulerMap;
    }
    
    //Scheduler method
    global void execute(System.SchedulableContext sc) {
        Database.executeBatch(new Core_MDF_Batch_RecoverySchedules());
    }
}