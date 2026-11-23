/***************************************************************************************************
Class Name:  Core_IPS_AccountTeamUpdate_Scheduler
Class Type: Batch Class 
Test Class : Core_IPS_AccountTeamUpdate_Sched_Test
Version     : 1.0 
Description:  This batch Class Sync the newly Standard AccountTeamMember with CustomAccountTeam
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Amritesh                   26/03/2018              Modified - US248473
****************************************************************************************************/   

global class Core_IPS_AccountTeamUpdate_Scheduler implements Database.Batchable<sObject>,Database.Stateful {
    global Core_Batch_Processing__c batchProcessing;
    global integer count = 0;
    global Integer batchsize=0;
    global Set<Id> setAccntId;
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        if(setAccntId==null) setAccntId = new Set<Id>();
        batchProcessing = new Core_Batch_Processing__c();
        //List<Account> failedList = new List<Account>();    
        Core_Batch_header__c header=AccountTeamBatchHandler.getHeader('Core_IPS_AccountTeamUpdate_Scheduler');
        try {
            String query = '';
            DateTime lastRunDateTime = AccountTeamBatchHandler.getLastRunDateTime('Core_IPS_AccountTeamUpdate_Scheduler');
            
            /*if(Test.isRunningTest()){
                //query = 'select id from Account where id in(select accountid from accountshare where lastmodifieddate >= TODAY)';
                query = 'SELECT Id,rowcause, caseaccesslevel, opportunityaccesslevel, accountaccesslevel, userorgroupid, accountid FROM accountshare where lastmodifieddate >= TODAY';
            }else*/
            
            if(setAccntId.size()>0) {
                query = 'SELECT Id,rowcause, caseaccesslevel, opportunityaccesslevel, accountaccesslevel, userorgroupid, accountid FROM accountshare where AccountId IN :setAccntId and rowcause=\'Team\'';
            }
            else {
                if(lastRunDateTime!=null){
                    if (Schema.sObjectType.Core_Batch_Processing__c.fields.Core_Last_Run_Date__c.isCreateable()) {
                    batchProcessing.Core_Last_Run_Date__c = lastRunDateTime;
                    }
                    if (Schema.sObjectType.Core_Batch_Processing__c.fields.Core_Start_Date_Time__c.isCreateable()) {
                    batchProcessing.Core_Start_Date_Time__c = system.Now();
                    }
                    //query = 'select id from Account where id in(select accountid from accountshare where lastmodifieddate >= :lastRunDateTime and rowcause=\'Team\')';                
                    query = 'SELECT Id,rowcause, caseaccesslevel, opportunityaccesslevel, accountaccesslevel, userorgroupid, accountid FROM accountshare where lastmodifieddate >= :lastRunDateTime and rowcause=\'Team\'';
                }else{
                    throw new BatchException('Core_IPS_AccountTeamUpdate_Scheduler not started as Last Run Batch Time is not specified');
                }
                if (Schema.sObjectType.Core_Batch_Processing__c.fields.Batch_Header__c.isCreateable()) {
                batchProcessing.Batch_Header__c = header.id;
                }
                if (Schema.sObjectType.Core_Batch_Processing__c.fields.Core_Salesforce_Job_Id__c.isCreateable()) {
                batchProcessing.Core_Salesforce_Job_Id__c = BC.getJobId();
                }
                if (Schema.sObjectType.Core_Batch_Processing__c.fields.Core_Batch_Query__c.isCreateable()) {
                batchProcessing.Core_Batch_Query__c = query;
                }
                if (Schema.sObjectType.Core_Batch_Processing__c.fields.Core_Email_Distribution_List__c.isCreateable()) {
                batchProcessing.Core_Email_Distribution_List__c=header.Email_Distribution_List__c;
                }
                if (Schema.sObjectType.Core_Batch_Processing__c.fields.Core_Object_Name__c.isCreateable()) {
                batchProcessing.Core_Object_Name__c = 'Core_Account_Team__c';
                }
            
                insert batchProcessing;
            }
            return Database.getQuerylocator(query);
            
        } catch(Exception e) {  
            /*TWC745-112 - 05/08/2021 - Vishal - FLS Check for security vulnerability --*/
            if (Schema.sObjectType.Core_Batch_Processing__c.fields.Batch_Header__c.isCreateable()) {
                batchProcessing.Batch_Header__c = header.id; 
            }
            batchProcessing.Core_Exception_Log__c=e.getMessage(); 
            insert batchProcessing; 
            return null;        
        }
    }
    
    global void execute(Database.BatchableContext BC, List<AccountShare> scope) {
        List<AccountShare> failedList = new List<AccountShare>();
        
        batchsize = scope.size();
        
        /*Core_IPS_AccountTeam_Calculation acctTeamCalc = new Core_IPS_AccountTeam_Calculation();
        for(Account acc: scope){
        system.debug('raga- acc.id'+acc.Id);
        count++;
        acctTeamCalc.calcuateTeam(acc.id,'Batch',batchProcessing.id);
        system.debug('raga - call for calculate');
        }*/
        
        List<Id> scopeIds = new List<Id>();
        Set<Id> accId = new Set<Id>();
        Set<Id> userId = new Set<Id>();
        Map<String,Core_Account_Team__c> mapCustAccTeam = new Map<String,Core_Account_Team__c>();
        List<AccountShare> aShareInsertList = new List<AccountShare>();
        List<Core_Account_Team__c> toUpdateList = new List<Core_Account_Team__c>();
        List<Core_Account_Team__c> toInsertList = new List<Core_Account_Team__c>();
        //List<Core_Account_Team__c> toDeleteList = new List<Core_Account_Team__c>();
        
        for(AccountShare accShare : scope) {
            count++;
            scopeIds.add(accShare.Id);
            accId.add(accShare.AccountId);
            userId.add(accShare.UserOrGroupId);
        } 
        setAccntId.addAll(accId);
        Batch_Processing_Line_Item__c lineItem = new Batch_Processing_Line_Item__c();
        if (Schema.sObjectType.Batch_Processing_Line_Item__c.fields.Batch_Processing__c.isCreateable()) {
        lineItem.Batch_Processing__c = batchProcessing.Id;
        }
        if (Schema.sObjectType.Batch_Processing_Line_Item__c.fields.Object_Type__c.isCreateable()) {
        lineItem.Object_Type__c  = 'AccountShare';
        }
        //lineItem.Core_Change_Log__c='<table><tr><th>Batch Started</th><th>'+accountId+'</th></tr>';

        /*---Start US1038641 06/24/2021 - Farhaad - FLS Check for security vulnerability--*/
        if (Schema.sObjectType.Batch_Processing_Line_Item__c.fields.Core_Change_Log__c.isCreateable()) {
            lineItem.Core_Change_Log__c='<table><tr><th>Batch Started</th><th>'+String.join(scopeIds, ';')+'</th></tr>';
        }
        /*---End US1038641 06/24/2021 - Farhaad - FLS Check for security vulnerability--*/
        
        try {
            
            for(Core_Account_Team__c objAccTeam : [select Id,Core_Team_Member__c,Core_Case_Access__c,Core_Account__c,Core_Opportunity_Access__c,Core_Account_Access__c from Core_Account_Team__c where Core_Account__c IN :accId AND Core_Team_Member__c IN :userId])
            {
                mapCustAccTeam.put(objAccTeam.Core_Team_Member__c + ';' + objAccTeam.Core_Account__c, objAccTeam);
            }
            
            for(AccountShare actShareObj : scope) {
                
                String mapKey = actShareObj.UserOrGroupId + ';' + actShareObj.AccountId;                
                if(mapCustAccTeam.containsKey(mapKey)) { 
                    Core_Account_Team__c custATObj = mapCustAccTeam.get(mapKey);
                    //Added below if condition to only update the related Custom Account Team records when there is any change in Opportunity/Case/Account AccessLevel
                    if(custATObj.Core_Opportunity_Access__c <> actShareObj.opportunityaccesslevel || custATObj.Core_Case_Access__c <> actShareObj.caseaccesslevel || custATObj.Core_Account_Access__c <> actShareObj.accountaccesslevel){
                        if (Schema.sObjectType.Core_Account_Team__c.fields.Core_Opportunity_Access__c.isUpdateable()) {
                        custATObj.Core_Opportunity_Access__c = actShareObj.opportunityaccesslevel;
                        }
                        if (Schema.sObjectType.Core_Account_Team__c.fields.Core_Case_Access__c.isUpdateable()) {
                        custATObj.Core_Case_Access__c = actShareObj.caseaccesslevel;
                        }
                        if (Schema.sObjectType.Core_Account_Team__c.fields.Core_Account_Access__c.isUpdateable()) {
                        custATObj.Core_Account_Access__c = actShareObj.accountaccesslevel;
                        }
                        toUpdateList.add(custATObj);  
                    }                            
                }
                else { 
                    aShareInsertList.add(actShareObj);
                }
            }
            
            if(aShareInsertList <> null && aShareInsertList.size() > 0){
                for(AccountShare aShareObj : aShareInsertList) {
                    Core_Account_Team__c custom_AT = new Core_Account_Team__c();
                    /*--Start US1021248 - 24/06/2021 - Farhaad - FLS Check for security vulnerability --*/
                    if (Schema.sObjectType.Core_Account_Team__c.fields.Core_Account__c.isCreateable()) {
                        custom_AT.Core_Account__c = aShareObj.AccountId;
                    }
                    if (Schema.sObjectType.Core_Account_Team__c.fields.Core_Team_Member__c.isCreateable()) {
                        custom_AT.Core_Team_Member__c=aShareObj.UserOrGroupId;
                    }
                    if (Schema.sObjectType.Core_Account_Team__c.fields.Core_Opportunity_Access__c.isCreateable()) {
                        custom_AT.Core_Opportunity_Access__c = aShareObj.opportunityaccesslevel;
                    }
                    if (Schema.sObjectType.Core_Account_Team__c.fields.Core_Case_Access__c.isCreateable()) {
                        custom_AT.Core_Case_Access__c = aShareObj.caseaccesslevel;                
                    }
                    if (Schema.sObjectType.Core_Account_Team__c.fields.Core_Account_Access__c.isCreateable()) {
                        custom_AT.Core_Account_Access__c = aShareObj.accountaccesslevel;                                                                        
                    }
                    /*---End US1038641 06/24/2021 - Farhaad - FLS Check for security vulnerability--*/
                    toInsertList.add(custom_AT);                  
                }                
            }
            
   
            
            if(toInsertList <> null && toInsertList.size() > 0){
                /*TWC745-112 - 05/08/2021 - Vishal - FLS Check for security vulnerability --*/
                if (Schema.sObjectType.Batch_Processing_Line_Item__c.fields.Core_Change_Log__c.isCreateable()) {
                     lineItem.Core_Change_Log__c+='<tr><th>New AccountTeam Members</th><th>'+toInsertList.size()+'</th></tr>';
                }
                if (Schema.sObjectType.Batch_Processing_Line_Item__c.fields.Core_Number_of_Inserts__c.isCreateable()) {
                lineItem.Core_Number_of_Inserts__c = toInsertList.size();
                }
                insert toInsertList;                    
            }
            
            if(toUpdateList <> null && toUpdateList.size() > 0){
                /*TWC745-112 - 05/08/2021 - Vishal - FLS Check for security vulnerability --*/
                if (Schema.sObjectType.Batch_Processing_Line_Item__c.fields.Core_Change_Log__c.isCreateable()) {
                     lineItem.Core_Change_Log__c+='<tr><th>Updated AccountTeam Members</th><th>'+toUpdateList.size()+'</th></tr>';
                }
                if (Schema.sObjectType.Batch_Processing_Line_Item__c.fields.Core_Number_of_Updates__c.isCreateable()) {
                lineItem.Core_Number_of_Updates__c = toUpdateList.size();
                }
                update toUpdateList;
            }
            if (Schema.sObjectType.Batch_Processing_Line_Item__c.fields.Core_Change_Log__c.isCreateable()) {
            lineItem.Core_Change_Log__c+='</table>';
            }
            
        } catch(Exception e) {
            if (Schema.sObjectType.Batch_Processing_Line_Item__c.fields.Exception_Log__c.isCreateable()) {
            lineItem.Exception_Log__c = e.getMessage();
            }
            //failedList.addAll(scope); 
            Insert_logexception(scope,label.Core_BU_ExceptionMsg + '\n\n' + e.getMessage());
        }
        if(batchProcessing.Id!=null && (toInsertList.size()>0 || toUpdateList.size()>0)) {
            insert lineItem;
        }
        
        /*if(failedList.size()>0){
            Insert_logexception(failedList,label.Core_BU_ExceptionMsg);
        }*/
    }
    
    /*
    * Method name  : Insert_logexception
    * Description  : This Method used to create failed records in Exception object.
    */ 
    Public static void Insert_logexception(list<AccountShare> lstAccShare,String ExceptionMsg){
        if(ExceptionMsg != null){
            list<Core_Exceptions__c> exceplist=new list<Core_Exceptions__c>();
            for(AccountShare accShare : lstAccShare){
                Core_Exceptions__c excep=new Core_Exceptions__c();
                if (Schema.sObjectType.Core_Exceptions__c.fields.Core_Class_Name__c.isCreateable()) {
                excep.Core_Class_Name__c='Core_IPS_AccountTeamUpdate_Scheduler';
                }
                if (Schema.sObjectType.Core_Exceptions__c.fields.Core_Method_Name__c.isCreateable()) {
                excep.Core_Method_Name__c='Core_Exceptions__cexecute';
                }
                if (Schema.sObjectType.Core_Exceptions__c.fields.Core_Record_Id__c.isCreateable()) {
                excep.Core_Record_Id__c=accShare.Id; 
                }
                if (Schema.sObjectType.Core_Exceptions__c.fields.Core_Exception__c.isCreateable()) {
                excep.Core_Exception__c=ExceptionMsg;
                }
                if (Schema.sObjectType.Core_Exceptions__c.fields.Core_IPS_Object_Name__c.isCreateable()) {
                excep.Core_IPS_Object_Name__c='AccountShare';
                }
                /*---Start US1038641 06/24/2021 - Farhaad - FLS Check for security vulnerability--*/
                if (Schema.sObjectType.Core_Exceptions__c.fields.Core_Login_User_Id__c.isCreateable()) {
                excep.Core_Login_User_Id__c=userInfo.getUserId();
                }
                /*---End US1038641 06/24/2021 - Farhaad - FLS Check for security vulnerability--*/
                exceplist.add(excep);
            } //End of for loop//
            if(exceplist != null && !(exceplist.isEmpty())){
                Database.insert(exceplist, false);
            }             
        }
    }          
    
    global void finish(Database.BatchableContext BC) {
        
        if(setAccntId!=null && setAccntId.size()>0) {
            batchProcessing.Core_Batch_Size__c=batchSize;
            Core_IPS_AccountTeam_DeleteSync accountTeamDeleteSyncBatch = new Core_IPS_AccountTeam_DeleteSync(); 
            if(batchProcessing.Id!=null) {
                accountTeamDeleteSyncBatch.batchProcessing = batchProcessing;
                accountTeamDeleteSyncBatch.count = count;                
                accountTeamDeleteSyncBatch.batchsize = batchSize;
            }
            accountTeamDeleteSyncBatch.setAccId = setAccntId;            
            Integer batchScope = String.valueOf(Label.Core_IPS_AccountTeam_DeleteSync_Size).isNumeric() ? Integer.valueOf(Label.Core_IPS_AccountTeam_DeleteSync_Size) : 10;
            database.executebatch(accountTeamDeleteSyncBatch, batchScope);
        } else if(batchProcessing.Id!=null){
            if (Schema.sObjectType.Core_Batch_Processing__c.fields.Core_Total_Number_of_Records__c.isUpdateable()) {
            batchProcessing.Core_Total_Number_of_Records__c=count;
            }
            if (Schema.sObjectType.Core_Batch_Processing__c.fields.Core_End_Date_Time__c.isUpdateable()) {
            batchProcessing.Core_End_Date_Time__c=System.Now();
            }
            if (Schema.sObjectType.Core_Batch_Processing__c.fields.Core_Batch_Size__c.isUpdateable()) {
            batchProcessing.Core_Batch_Size__c=batchSize;
            }
            if (Schema.sObjectType.Core_Batch_Processing__c.fields.Core_Send_Email__c.isUpdateable()) {
            batchProcessing.Core_Send_Email__c=true;
            }
            update batchProcessing;
        }
    }
    
    /****** Usage ********
     * To sync specific account use following code by including accountid
    --------------------------------------------------------------------------------------------------------
        Core_IPS_AccountTeamUpdate_Scheduler accountTeamBatch = new Core_IPS_AccountTeamUpdate_Scheduler(); 
        accountTeamBatch.setAccntId = new Set<Id>{'0013F000004LibY'};
        database.executebatch(accountTeamBatch, 1);
    --------------------------------------------------------------------------------------------------------
     * 
     */ 
}