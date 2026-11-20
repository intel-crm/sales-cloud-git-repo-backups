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
        public Core_MDF_Batch_IAH_Pull(){
            List<string> qtr = Core_MDF_RecoveryClaimReportViewCtrl.getQuarterOptionsMap();
            this.quarter = qtr[1];
            this.accountIds = '';
            this.program = '';            
        }
        public Core_MDF_Batch_IAH_Pull(Boolean notifyRecoveryAdmin){
            List<string> qtr = Core_MDF_RecoveryClaimReportViewCtrl.getQuarterOptionsMap();
            this.quarter = qtr[1];
            this.accountIds = '';
            this.program = '';       
            this.notifyRecoveryAdmin = notifyRecoveryAdmin;   
        }
        public Core_MDF_Batch_IAH_Pull(string pgm, String quarter,string accounts) {
            this.program = pgm;
            this.quarter = quarter;
            this.accountIds = accounts;
        }
        public static object generateInstance(String jsonText, String classSignature){
            object des_Obj;
            map<String,object> parmValueMap = (Map<String, Object>)JSON.deserializeUntyped(jsonText);
                if(classSignature == 'Core_MDF_Batch_IAH_Pull(Boolean notifyRecoveryAdmin)'){
                    boolean notifyRecoveryAdmin = Boolean.valueOf(parmValueMap.get('notifyRecoveryAdmin'));
                    des_Obj = new Core_MDF_Batch_IAH_Pull(notifyRecoveryAdmin);
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
             
             String param = 'Core_MDF_pull_data_from_IAH';
             return Database.getQueryLocator('SELECT Id,Core_MDF_Value_Txt__c from Core_MDF_Custom_Label_Configration__mdt where QualifiedApiName =:param'); 
        }
        global void execute(Database.BatchableContext batchableContext, List<sObject> scope)
        {
               try
            {
                Integer currentYear = System.today().year();
                List<String> qtrYearList = this.quarter.split(' ');
                //String quarter = qtrYearList.get(0);
                Integer year = Integer.valueOf(qtrYearList.get(1));
                List<String> restrictedMonths = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_RestrictedMonthsForIAHDataPull');
                if(year == currentYear && !Core_MDF_Recovery_Utility.isRecoveryAllowedForCurrentMonth(restrictedMonths)) {
                    isIAHDataPullNotAllowed = true;
                    return;
                }

                returnMessage = Core_MDF_IAH_Partnership_Score.callHttp(program,quarter,accountIds);//inserting the carry fwd on Q4 20221 from Q32021 in master 
                
            }
            
            catch(Exception ex)
            {
                returnMessage += ex.getMessage();
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
            if(!isIAHDataPullNotAllowed) {
                if(String.isNotBlank(quarter)){ 
                    List<String> qysplit = quarter.split(' ');
                    List<String> qsplit = qysplit[0].split('');
                    Integer quarterInteger = Integer.valueof(qsplit[1]);
                    Integer yearInteger = Integer.valueof(qysplit[1]);
                    yearInteger = (quarterInteger== 4) ? yearInteger + 1 : yearInteger;
                    quarterInteger = (quarterInteger == 4 )? 1 : quarterInteger + 1;
                    cur_qtr = 'Q'+ quarterInteger + ' ' + yearInteger;
                    Core_MDF_Batch_Partnership_Score_Detail dtl = new Core_MDF_Batch_Partnership_Score_Detail(program,quarter,accountIds,notifyRecoveryAdmin);//insert the carryfwd and the self lookup
                    database.executeBatch(dtl);
                }
                
                
            }

            if (Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CurQtr_ins_switch')=='true'&& String.isNotBlank(quarter) && String.isBlank(program) &&  String.isBlank(accountIds)) {
                  
                  Core_MDF_IAH_Partnership_Score.insertCurrQuarterData('');//self lookup for Q12022 for Q42021
                  
                }
        }
    
    }