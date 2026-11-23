global class Core_IPS_AccountTeamUpdate_Scheduler_Old implements Database.Batchable<sObject>,Database.Stateful {
    global Core_Batch_Processing__c batchProcessing;
    global integer count = 0;
    global Integer batchsize=0;

    global Database.QueryLocator start(Database.BatchableContext BC) {
        batchProcessing = new Core_Batch_Processing__c();
        List<Account> failedList = new List<Account>();    
        Core_Batch_header__c header=AccountTeamBatchHandler.getHeader('Core_IPS_AccountTeamUpdate_Scheduler');
        try{
            String query = '';
            DateTime lastRunDateTime = AccountTeamBatchHandler.getLastRunDateTime('Core_IPS_AccountTeamUpdate_Scheduler');
            if(lastRunDateTime!=null)
                batchProcessing.Core_Last_Run_Date__c = lastRunDateTime;
            if(Test.isRunningTest()){
                query = 'select id from Account where id in(select accountid from accountshare where lastmodifieddate >= TODAY)';
            }else if(lastRunDateTime!=null){
                batchProcessing.Core_Start_Date_Time__c = system.Now();
                query = 'select id from Account where id in(select accountid from accountshare where lastmodifieddate >= :lastRunDateTime and rowcause=\'Team\')';
            }else{
                throw new BatchException('Core_IPS_AccountTeamUpdate_Scheduler not started as Lasr Run Batch Time is not specified');
            }
            batchProcessing.Batch_Header__C = header.id;
            batchProcessing.Core_Salesforce_Job_Id__c = BC.getJobId();
            batchProcessing.Core_Batch_Query__c = query;
            batchProcessing.Core_Email_Distribution_List__c=header.Email_Distribution_List__c;
            batchProcessing.Core_Object_Name__c = 'Account';
            insert batchProcessing;
            
            return Database.getQuerylocator(query);
            
       }catch(Exception e){      
            batchProcessing.Core_Exception_Log__c=e.getMessage();
            insert batchProcessing;
            return null;
       }
       
    }
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        List<Account> failedList = new List<Account>();
        try{
        
            batchsize = scope.size();
            Core_IPS_AccountTeam_Calculation acctTeamCalc = new Core_IPS_AccountTeam_Calculation();
            for(Account acc: scope){
                count++;
                acctTeamCalc.calcuateTeam(acc.id,'Batch',batchProcessing.id);
            }
        }catch(Exception e){
            failedList.add(scope[count-1]);   
        }
         if(failedList.size()>0){
                Insert_logexception(failedList,label.Core_BU_ExceptionMsg);
        
        }
        }
           /*
    * Method name  : Insert_logexception
    * Description  : This Method used to create failed records in Exception object.
    * Parameter    : (List<Account>,ExceptionMsg).
    */ 
    Public static void Insert_logexception(list<Account> acc,String ExceptionMsg){
        if(ExceptionMsg != null){
            list<Core_Exceptions__c> exceplist=new list<Core_Exceptions__c>();
            for(Account a: acc){
                Core_Exceptions__c excep=new Core_Exceptions__c();
               
                    excep.Core_Class_Name__c='Core_IPS_AccountTeamUpdate_Scheduler';
                    excep.Core_Method_Name__c='execute';
                    excep.Core_Record_Id__c=a.Id; 
               
                /*if(system.isBatch()){
                    excep.Core_Class_Name__c='Core_IPS_AccountTeamUpdate_Scheduler';
                    excep.Core_Method_Name__c='execute';
                    excep.Core_Record_Id__c=a.Id;
                }*/
                excep.Core_Exception__c=ExceptionMsg;
                excep.Core_IPS_Object_Name__c='Account';                                                   
                excep.Core_Login_User_Id__c=userInfo.getUserId();
                exceplist.add(excep);
            } //End of for loop//
            if(exceplist != null && !(exceplist.isEmpty())){
               Database.insert(exceplist);
            }             
        }
    }
          
    
    global void finish(Database.BatchableContext BC) {
        batchProcessing.Core_Total_Number_of_Records__c=count;
        batchProcessing.Core_End_Date_Time__c=System.Now();
        batchProcessing.Core_Batch_Size__c=batchSize;
        batchProcessing.Core_Send_Email__c=true;
        update batchProcessing;
    }
}