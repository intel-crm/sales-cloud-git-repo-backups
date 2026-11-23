global without sharing class Core_MDF_Batch_IAH_Partnership_Score implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
        string query='';
        string sendEmailAddress = '';
        string message='';
        global string returnMessage ='';
        private String prevQtr;
        public string program;
        public string accountIds;

        public Core_MDF_Batch_IAH_Partnership_Score(){
        }

        public Core_MDF_Batch_IAH_Partnership_Score(string pgm, String prevQtr,string accounts) {
            this.program = pgm;
            this.prevQtr = prevQtr;
            this.accountIds = accounts;
        }
    
         global Database.queryLocator start(Database.BatchableContext bc)
        {
             system.debug('start');
             String param = 'Core_MDF_pull_data_from_IAH';
             return Database.getQueryLocator('SELECT Id,Core_MDF_Value_Txt__c from Core_MDF_Custom_Label_Configration__mdt where QualifiedApiName =:param'); 
        }
        global void execute(Database.BatchableContext batchableContext, List<sObject> scope)
        {
               try
            {
                //system.debug('Batch class');
                returnMessage = Core_MDF_IAH_Partnership_Score.callHttp(program, Prevqtr, accountIds);//inserting the carry fwd on Q4 20221 from Q32021 in master 
                system.debug('returnMessage from execute' + returnMessage);
            }
            
            catch(Exception ex)
            {
                //System.debug('Exception has occurred' + ex.getmessage());
                returnMessage += ex.getMessage();
            }
        }
        global void finish(Database.BatchableContext bc)
        {
            string cur_qtr;
            if(String.isBlank(program) && String.isBlank(accountIds)){
              List<string> qtr = Core_MDF_RecoveryClaimReportViewCtrl.getQuarterOptionsMap();
              prevQtr = qtr[1];
              cur_qtr  = qtr[0];
              system.debug('Finish class');
              Core_MDF_Batch_Partnership_Score_Detail dtl = new Core_MDF_Batch_Partnership_Score_Detail(prevQtr);//insert the carryfwd and the self lookup
              database.executeBatch(dtl);
            }
            else{
                List<String> qysplit = prevQtr.split(' ');
                List<String> qsplit = qysplit[0].split('');
                Integer quarterInteger = integer.valueof(qsplit[1]);
                Integer yearInteger = integer.valueof(qysplit[1]);
                yearInteger = (quarterInteger==4)?yearInteger+1:yearInteger;
                quarterInteger = (quarterInteger==4)?1:quarterInteger+1;
                cur_qtr = 'Q'+quarterInteger+' '+yearInteger;
                Core_MDF_Batch_Partnership_Score_Detail dtl = new Core_MDF_Batch_Partnership_Score_Detail(program,prevQtr,accountIds);//insert the carryfwd and the self lookup
                database.executeBatch(dtl);
            }
            if (Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CurQtr_ins_switch')=='true')
            {
              Core_MDF_IAH_Partnership_Score.insertCurrQuarterData(prevQtr);//self lookup for Q12022 for Q42021
              //Core_MDF_IAH_Partnership_Score.insertCurrQuarterData(prevQtr,cur_qtr);//self lookup for Q12022 for Q42021
            }
        }
    
    }