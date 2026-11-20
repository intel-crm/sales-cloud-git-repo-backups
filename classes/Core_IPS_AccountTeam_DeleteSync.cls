/***************************************************************************************************
Class Name:  Core_IPS_AccountTeam_DeleteSync
Class Type: Batch Class 
Test Class : Core_IPS_AccountTeamUpdate_Sched_Test
Version     : 1.0 
Description:  This batch Class deletes the CustomAccountTeam if relevant Standard AccountTeamMember is not present
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Amritesh                   26/03/2018              Modified - US248473
****************************************************************************************************/  

global class Core_IPS_AccountTeam_DeleteSync implements Database.Batchable<sObject>,Database.Stateful {
    global Core_Batch_Processing__c batchProcessing;
    global integer count = 0;
    global Integer batchsize = 0;
    global Set<Id> setAccId;
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        Core_Batch_header__c header;
        
        try {
            
            header=AccountTeamBatchHandler.getHeader('Core_IPS_AccountTeam_DeletedRecords_Bulk');            
            
            String query='';
            
            if(setAccId!=null && setAccId.size()>0) {     
                query = 'SELECT Id, Core_Account__c, Core_Team_Member__c FROM Core_Account_Team__c WHERE Core_Account__c IN :setAccId ORDER BY Core_Account__c';                                
            } else {
                query = 'SELECT Id, Core_Account__c, Core_Team_Member__c FROM Core_Account_Team__c ORDER BY Core_Account__c';                                
            }
            
            if(batchProcessing==null) {
                batchProcessing = new Core_Batch_Processing__c();                
                batchProcessing.Core_Start_Date_Time__c = system.Now();
                batchProcessing.Batch_Header__c = header.id;
                batchProcessing.Core_Salesforce_Job_Id__c = BC.getJobId();
                batchProcessing.Core_Batch_Query__c = query;
                batchProcessing.Core_Email_Distribution_List__c=header.Email_Distribution_List__c;
                batchProcessing.Core_Object_Name__c = 'Account';
                insert batchProcessing;
            }
            
            return Database.getQuerylocator(query);
            
        } catch(Exception e) {
            batchProcessing.Batch_Header__c = header.id;
            batchProcessing.Core_Exception_Log__c=e.getMessage();
            insert batchProcessing;
            return null;
        }
        
    }
    
    global void execute(Database.BatchableContext BC, List<Core_Account_Team__c> scope) {
        
        SET<id> setAcctIds = new SET<id>();
        SET<id> setUserIds = new SET<id>();
        Map <String, Core_Account_Team__c> mapCustAccountTeam = new Map <String, Core_Account_Team__c>();
        String searchKey;
        
        batchsize = scope.size();
        
        Batch_Processing_Line_Item__c lineItem = new Batch_Processing_Line_Item__c();
        lineItem.Batch_Processing__c = batchProcessing.Id;
        lineItem.Object_Type__c	 = 'Core_Account_Team__c';        
        
        
        try {
            
            for (Core_Account_Team__c custTeamMember : scope) {
                count++;                
                if (!setAcctIds.contains(custTeamMember.Core_Account__c)) 
                    setAcctIds.add(custTeamMember.Core_Account__c);
                
                setUserIds.add(custTeamMember.Core_Team_Member__c);
                
                searchKey = createSearchKey(custTeamMember.Core_Account__c, custTeamMember.Core_Team_Member__c);
                mapCustAccountTeam.put(searchKey, custTeamMember);
            }
            
            lineItem.Core_Change_Log__c='<table><tr><th>Batch Started</th><th>'+String.join(new List<Id>(setAcctIds), ';')+'</th></tr>';
            
            if (setAcctIds.size() == 0) return;
            
            List <AccountTeamMember> lstAcctTeamMember = [SELECT Id, AccountId, UserId FROM AccountTeamMember WHERE AccountId IN :setAcctIds];
            
            if (lstAcctTeamMember == NULL) lstAcctTeamMember = new List<AccountTeamMember>();    
            
            Core_Account_Team__c custMatch;
            for (AccountTeamMember stdAcctTeam : lstAcctTeamMember) {
                searchKey = createSearchKey(stdAcctTeam.AccountId, stdAcctTeam.UserId);
                custMatch = mapCustAccountTeam.remove(searchKey);                
            }
            
            if (mapCustAccountTeam.size() > 0) {
                delete mapCustAccountTeam.values();    
                
                lineItem.Core_Change_Log__c+='<tr><th>Deleted AccountTeam Members</th><th>'+mapCustAccountTeam.size()+'</th></tr>';
                lineItem.Core_Number_of_Deletes__c = mapCustAccountTeam.size();
                lineItem.Core_Change_Log__c+='</table>';
                insert lineItem;
            }    
            
        } catch (Exception e) {
            Insert_logexception(scope, e.getMessage());
        }
    }
    
    global String createSearchKey(Id acctId, Id userId) { 
        return String.valueOf(acctId) + String.valueOf(userId);
    }  
    
    Public static void Insert_logexception(List<Core_Account_Team__c> scope,String ExceptionMsg){
        if(ExceptionMsg != null){
            list<Core_Exceptions__c> exceplist=new list<Core_Exceptions__c>();
            for(Core_Account_Team__c obj : scope){
                Core_Exceptions__c excep=new Core_Exceptions__c();
                
                excep.Core_Class_Name__c='Core_IPS_AccountTeam_DeleteSync';
                excep.Core_Method_Name__c='execute';
                excep.Core_Record_Id__c=obj.Id; 
                
                excep.Core_Exception__c=ExceptionMsg;
                excep.Core_IPS_Object_Name__c='Core_Account_Team__c';
                excep.Core_Login_User_Id__c=userInfo.getUserId();
                exceplist.add(excep);
            } 
            if(exceplist != null && !(exceplist.isEmpty())){
                Database.insert(exceplist, false);
            }             
        }
    }          
    
    global void finish(Database.BatchableContext BC) {
        batchProcessing.Core_Total_Number_of_Records__c=count;
        batchProcessing.Core_End_Date_Time__c=System.Now();
        if(batchProcessing.Core_Batch_Size__c==null)
        batchProcessing.Core_Batch_Size__c=batchSize;
        batchProcessing.Core_Send_Email__c=true;
        update batchProcessing;
    }
}