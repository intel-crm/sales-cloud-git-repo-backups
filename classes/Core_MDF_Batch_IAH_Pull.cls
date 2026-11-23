global without sharing class Core_MDF_Batch_IAH_Pull implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts,Core_MDF_BatchSchedulerInterface{
        string query='';
        string sendEmailAddress = '';
        string message='';
        global string returnMessage ='';
        private String quarter;
        public string program;
        public string accountIds;
        public Boolean isIAHDataPullNotAllowed = false;
        public Boolean notifyRecoveryAdmin = false;
        public Map<String,String> programToExecutionDateMap;
        Trigger_Execution__mdt switchOnOrOff = Trigger_Execution__mdt.getInstance('Core_MDF_RUN_IAH_PULL_Switch');
        public Boolean isScheduledToday = false;
        
        public Core_MDF_Batch_IAH_Pull(){
            List<string> qtr = Core_MDF_RecoveryClaimReportViewCtrl.getQuarterOptionsMap();
            this.quarter = qtr[1];//q2 2023 - April 4, 2023  -> q1 2023
            this.accountIds = ''; 
            this.program = '';            
        }
        public Core_MDF_Batch_IAH_Pull(Boolean notifyRecoveryAdmin){
            List<string> qtr = Core_MDF_RecoveryClaimReportViewCtrl.getQuarterOptionsMap();
            this.quarter = qtr[1];
            this.accountIds = '';
            this.program = '';       
            this.notifyRecoveryAdmin = notifyRecoveryAdmin;   
            this.isIAHDataPullNotAllowed = false;
        }

        public Core_MDF_Batch_IAH_Pull(string pgm, String quarter,string accounts) {
            this.program = pgm;
            this.quarter = quarter;//April 4, 2023 - q3 2023
            this.accountIds = accounts;
        }
        //added
        public Core_MDF_Batch_IAH_Pull(String pgm){
            if(switchOnOrOff.Active__c){
                this.program = pgm;
                this.accountIds = '';
            }
            List<string> qtr = Core_MDF_RecoveryClaimReportViewCtrl.getQuarterOptionsMap();
            this.quarter = qtr[1];
        }

        public static object generateInstance(String jsonText, String classSignature){
            object des_Obj;
            map<String,object> parmValueMap = (Map<String, Object>)JSON.deserializeUntyped(jsonText);
                if(classSignature == 'Core_MDF_Batch_IAH_Pull(Boolean notifyRecoveryAdmin)'){
                    boolean notifyRecoveryAdmin = Boolean.valueOf(parmValueMap.get('notifyRecoveryAdmin'));
                    des_Obj = new Core_MDF_Batch_IAH_Pull(notifyRecoveryAdmin);
                }
                //added
                else if(classSignature == 'Core_MDF_Batch_IAH_Pull(string pgm)'){
                    string pgm = string.valueOf(parmValueMap.get('pgm'));
                    des_Obj = new Core_MDF_Batch_IAH_Pull(pgm);
                }
                else if(classSignature == 'Core_MDF_Batch_IAH_Pull(string pgm, String quarter,string accounts)'){
                    string pgm = string.valueOf(parmValueMap.get('pgm'));
                    string quarter = string.valueOf(parmValueMap.get('quarter'));
                    string accounts = string.valueOf(parmValueMap.get('accounts'));
                    des_Obj = new Core_MDF_Batch_IAH_Pull(pgm,quarter,accounts);
                }
            return des_Obj;
        }

        global Database.queryLocator start(Database.BatchableContext bc)
        {   
            //added
            if(shouldRunIAHPull(System.today())){
                isScheduledToday = true;
            }

            String param = 'Core_MDF_pull_data_from_IAH';
            return Database.getQueryLocator('SELECT Id,Core_MDF_Value_Txt__c from Core_MDF_Custom_Label_Configration__mdt where QualifiedApiName =:param'); 
        }

        global void execute(Database.BatchableContext batchableContext, List<sObject> scope)
        {
            try
            {
                //String quarterYear = 'q4 2022';
                Integer currentYear = System.today().year();
                //Integer currentMonth = Date.today().month();

                List<String> qtrYearList = this.quarter.split(' ');

                //String quarter = qtrYearList.get(0);
                Integer year = Integer.valueOf(qtrYearList.get(1));

                List<String> restrictedMonths = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_RestrictedMonthsForIAHDataPull');
                if(year == currentYear && !Core_MDF_Recovery_Utility.isRecoveryAllowedForCurrentMonth(restrictedMonths)) {
                    isIAHDataPullNotAllowed = true;

                    return;
                }
                Date executionDate = System.today();
                Datetime iahExecutionDateTime =DateTime.newInstanceGmt(executionDate.year(),executionDate.month(),executionDate.day(),0,0,0);

                if(isScheduledToday) {
                    String IAHJson = '{"notifyRecoveryAdmin": true}';
                    Core_MDF_Batch_Scheduler__c iahBatchSchedule = createBatchSchedulerInstance(IAHJson ,50,iahExecutionDateTime,'Core_MDF_Batch_IAH_Pull','Once','High','CCP');
                    Database.insert(iahBatchSchedule);
                }

                returnMessage = Core_MDF_IAH_Partnership_Score.callHttp(program,quarter,accountIds);//inserting the carry fwd on Q4 20221 from Q32021 in master 

            }
            
            catch(Exception ex)
            {
               
            }
        }
        global void finish(Database.BatchableContext bc)
        {
            /*string cur_qtr=quarter;
            string prevQtr;
            if(String.isNotBlank(quarter)){ 
                List<String> qysplit = quarter.split(' ');
                List<String> qsplit = qysplit[0].split('');
                Integer quarterInteger = integer.valueof(qsplit[1]);
                Integer yearInteger = integer.valueof(qysplit[1]);
                yearInteger = (quarterInteger==1)?yearInteger-1:yearInteger;
                quarterInteger = (quarterInteger==1)?4:quarterInteger-1;
                prevQtr = 'Q'+quarterInteger+' '+yearInteger;
                
                Core_MDF_Batch_Partnership_Score_Detail dtl = new Core_MDF_Batch_Partnership_Score_Detail(program,quarter,accountIds);//insert the carryfwd and the self lookup
                database.executeBatch(dtl);
            }*/
            
            
            string cur_qtr;
            string prevQtr = quarter;
            if(!isIAHDataPullNotAllowed ) {
                if(String.isNotBlank(quarter)){ 
                    List<String> qysplit = quarter.split(' ');
                    List<String> qsplit = qysplit[0].split('');
                    Integer quarterInteger = Integer.valueof(qsplit[1]);
                    Integer yearInteger = Integer.valueof(qysplit[1]);
                    yearInteger = (quarterInteger== 4) ? yearInteger + 1 : yearInteger;
                    quarterInteger = (quarterInteger == 4 )? 1 : quarterInteger + 1;
                    cur_qtr = 'Q'+ quarterInteger + ' ' + yearInteger;

                    Core_MDF_Batch_Partnership_Score_Detail dtl = new Core_MDF_Batch_Partnership_Score_Detail(program,quarter,accountIds,(notifyRecoveryAdmin || isScheduledToday ));//insert the carryfwd and the self lookup
                    database.executeBatch(dtl);
                }
            }

            // if it is scheduled for today
            // if(isScheduledToday){
            //     List<AsyncApexJob> completedJobs = [Select Id,Status, ApexClass.Name from AsyncApexJob where ApexClass.Name = 'Core_MDF_Batch_IAH_Pull' and Status ='Completed' and CompletedDate = TODAY  order by CreatedDate desc LIMIT 1];
            //     if(!completedJobs.isEmpty()){
            //         Core_MDF_Batch_RecoverySchedules dtl = new Core_MDF_Batch_RecoverySchedules();
            //         database.executeBatch(dtl);
            //     }
            // }

            if(notifyRecoveryAdmin || isScheduledToday){
                Core_MDF_Batch_RecoverySchedules dtl = new Core_MDF_Batch_RecoverySchedules();
                database.executeBatch(dtl);
            }

            
            if (Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CurQtr_ins_switch')=='true'&& String.isNotBlank(quarter) && String.isBlank(program) &&  String.isBlank(accountIds)) {
                  
                  Core_MDF_IAH_Partnership_Score.insertCurrQuarterData('');//self lookup for Q12022 for Q42021
                  
                }
        }
        //added
        public Boolean shouldRunIAHPull(Date currentDate) {
            
            try {
                // Get 13 fiscal weeks of the quarter (4-4-5)
                List<Period> currentFiscalQuarterDetails = Core_MDF_Calendar_Utility.getFiscalQuarterWeekPeriods(currentDate);
                if (currentFiscalQuarterDetails.size() != 13) {
                    return false;
                }
                
                //List<Core_MDF_Custom_Label_Configration__mdt> params = [SELECT Core_MDF_Value_Txt__c, Core_MDF_Value2_Txt__c FROM Core_MDF_Custom_Label_Configration__mdt WHERE Label = 'Core_MDF_WeekForIAHBatchRun' LIMIT 1];
                //rename - IAH
                Integer targetWeekOfQuarter = Integer.valueOf(Core_MDF_Custom_Label_Configration__mdt.getInstance('Core_MDF_WeekForIAHBatchRun').Core_MDF_Value_Txt__c);
                Integer mondayOffset = Integer.valueOf(Core_MDF_Custom_Label_Configration__mdt.getInstance('Core_MDF_WeekForIAHBatchRun').Core_MDF_Value2_Txt__c);

                //Integer mondayOffset = Integer.valueOf(params[0].Core_MDF_Value2_Txt__c);  // For Monday: 1

                for (Period week : currentFiscalQuarterDetails) {
                    Integer weekOfQuarter = Core_MDF_Calendar_Utility.getWeekNumberOfQuarter(week.Number);

                    // check for week 2 of curr quarter
                    if (weekOfQuarter != targetWeekOfQuarter) {
                        continue;
                    }
                    // Monday of this week
                    Date mondayOfWeek = week.StartDate.addDays(mondayOffset);

                    // Return true if today matches
                    if (mondayOfWeek == currentDate) {
                        return true;
                    }

                }
        
                return false;
            }
            catch (Exception ex) {
                Core_MDF_CCP_UtilityClass.logError(ex);
                return false;
            }
        }
          
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
    }