global without sharing class Core_MDF_Batch_RecoveryAdminNotification implements Database.Batchable<sObject>, Schedulable, Database.Stateful{
    
    public string program = '';
    public String action = '';
    public String recoveryDate = '';

    public Core_MDF_Batch_RecoveryAdminNotification(){}

    public Core_MDF_Batch_RecoveryAdminNotification(String action){//ScheduleRecoveryNotification
        this.action = action;
    }
    
    public Core_MDF_Batch_RecoveryAdminNotification(String program, String action, String recoveryDate){//SendEmail
        this.action = action;
        this.program = program;
        this.recoveryDate = recoveryDate;
    }
    
    global Database.queryLocator start(Database.BatchableContext bc)
    {
        String param = 'Core_MDF_Recovery_Notification_Mapping';
        return Database.getQueryLocator('SELECT Id,Core_MDF_Value_Txt__c from Core_MDF_Custom_Label_Configration__mdt where QualifiedApiName =:param'); 
    }
    global void execute(Database.BatchableContext batchableContext, List<sObject> scope)
    {
        try{
            action = String.isNotBlank(action) ? action.toLowerCase() : '';
            if(action == Core_MDF_CCP_ConstantClass.SCHEDULE_RECOVERY_NOTIFICATION.toLowerCase()){ //ScheduleRecoveryNotification
                List<Core_MDF_Batch_Scheduler__c> batchSchedulerList = new List<Core_MDF_Batch_Scheduler__c>();
                //Map<String, Date> programToRecoveryRunDateMap = Core_MDF_Recovery_Utility.getRecoveryDateBasedOnProgram(true);

                Map<String, Core_MDF_Recovery_Utility.RecoveryNotificationMapping> programToWrapperMap = new Map<String, Core_MDF_Recovery_Utility.RecoveryNotificationMapping>();
                String jsonString = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Recovery_Notification_Mapping');
                for(Core_MDF_Recovery_Utility.RecoveryNotificationMapping record : (List<Core_MDF_Recovery_Utility.RecoveryNotificationMapping>)JSON.deserialize(jsonString, List<Core_MDF_Recovery_Utility.RecoveryNotificationMapping>.class)){
                    if(String.isNotBlank(record.reminderDays)){
                        programToWrapperMap.put(record.program,record);
                    }
                }
                
                //List<String> programList = new List<String>();
                //programList = String.isNotBlank(recoveryDate) ? new List<String>{program} : new List<String>(programToRecoveryRunDateMap.keySet());
                List<String> programList = new List<String>{program};
                
                for(String program : programList){

                    List<String> daysToReduceList = programToWrapperMap.containsKey(program) ? programToWrapperMap.get(program).reminderDays.split(',') : new List<String>();
                    for(String daysToReduce : daysToReduceList){
                        Date dateToSchedule = Core_MDF_Recovery_Utility.reduceBusinessDays(Date.valueOf(recoveryDate), Integer.valueOf(daysToReduce));
                        if((DateTime)dateToSchedule > Datetime.now()){
                            batchSchedulerList.add(Core_MDF_Recovery_Utility.prepareBatchSchedulerInstance(program, (DateTime)dateToSchedule, String.valueOf(recoveryDate)));
                        }
                    }
                }

                if(!batchSchedulerList.isEmpty()){
                    Database.insert(batchSchedulerList);
                }

            }else if(action == Core_MDF_CCP_ConstantClass.SEND_EMAIL.toLowerCase()){ //SendEmail
                String psNameToProgram = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Recovery_Admin_Program_Mapping');
                List<string> qtr = Core_MDF_RecoveryClaimReportViewCtrl.getQuarterOptionsMap();
            	String quarterAndYear = qtr[1];
                List<String> psNameList = new List<String>();
                Map<String, String> programToPsNameMap = new Map<String,String>();
                for(string psToProgram : psNameToProgram.split(',')){
                    List<string> record = psToProgram.split(':');
                    programToPsNameMap.put(record[1], record[0]);
                }

                Map<String, String> programAndRecoveryDateMap = new Map<String, String>();
                if(String.isNotBlank(recoveryDate)){
                    programAndRecoveryDateMap.put(program, recoveryDate);
                }
                List<Core_MDF_Partnership_Score_Detail__c> psdList = [SELECT Id, Core_MDF_Partnership_Score_Id__c, Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c, Core_MDF_Account_Id__c, Core_MDF_Program_Nm__c, Core_MDF_Node_Account_Id__c, Core_MDF_Node_Account_Id__r.Name, Core_MDF_Partnership_Score_Id__r.Core_MDF_Channel_Program_Id__c
                                                                    FROM Core_MDF_Partnership_Score_Detail__c
                                                                    WHERE Core_MDF_Balance_Amount_Amt__c > 0 AND Core_MDF_Quarter_Year_Nm__c =: quarterAndYear];
                //Map<String, Core_MDF_Recovery_Utility.RecoveryNotificationMapping> programToWrapperMap  = new Map<String, Core_MDF_Recovery_Utility.RecoveryNotificationMapping>();
                Core_MDF_Recovery_Utility.notifyRecoveryAdmin(new List<String>{programToPsNameMap.get(program)}, programAndRecoveryDateMap, psdList);
            }
        }
        
        catch(Exception ex){
           // System.debug('Exception has occurred' + ex.getmessage());
        }
    }
    global void finish(Database.BatchableContext bc){
        
    }

    //Scheduler method(Monthly)
    global void execute(System.SchedulableContext sc) {
        Database.executeBatch(new Core_MDF_Batch_RecoveryAdminNotification(Core_MDF_CCP_ConstantClass.SCHEDULE_RECOVERY_NOTIFICATION));
    }
}