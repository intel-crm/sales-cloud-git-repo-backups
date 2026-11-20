/********************************************************************************************************************************************************************
Apex Class Name:  Core_Opp_Task_LastActvityUpdate_Batch
Version     : 1.0 
Created Date: 12/09/2022
Function    : Update LastActivityDate field on Opportunity if any Task is added/edited

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Mula Yeshwanth               12/09/2022               Original Version developed
*******************************************************************************************************************************************************************/
global class Core_Opp_Task_LastActvityUpdate_Batch implements Database.Batchable<sObject>, Database.Stateful{   
    
    global Database.QueryLocator start(Database.BatchableContext BC){ 
        String stage1= 'Design';
        String stage2= 'Define';
        String stage3= 'Qualify';
        String stage4= 'Develop';        
        //DateTime dt = System.Now().addHours(Integer.valueOf(label.Core_Opportunity_Last_Activity_Date)); 
        DateTime dt = System.Now().addHours(-4);       
        String oppLine = 'Select Id,WhatId from Task where WhatId IN (Select id from Opportunity where Stagename =:stage1 OR Stagename = :stage2  OR Stagename = :stage3 OR Stagename = :stage4) AND LastModifiedDate >=:dt'; 		    
        return Database.getQueryLocator(oppLine); 
    }    
    
    global void execute(Database.BatchableContext BC, List<Task> scope){ 
        List<Core_Log_Entry__c> captureQueryErr = new List<Core_Log_Entry__c>();
               
        Set<Id> Oppids= new Set<Id>();
        for (Task att : scope){			
            Oppids.add(att.WhatId);			
        }
        
        List<Opportunity> OpportunityLst=[Select id,StageName,Core_Last_Activity_Date__c,(Select id,LastModifiedDate from Tasks ORDER by LastModifiedDate DESC limit 1) from Opportunity where Id IN :Oppids];     
        List<Opportunity> OpptoUpdate= new List<Opportunity>();
        for(Opportunity opp: OpportunityLst){
            
            Date LatestActivityDte=opp.Core_Last_Activity_Date__c;
            // Tasks
            if(opp.Tasks != null  && !opp.Tasks.isEmpty()){
                if(opp.Core_Last_Activity_Date__c < opp.Tasks[0].LastModifiedDate && opp.Tasks[0].LastModifiedDate > LatestActivityDte){
                    
                    LatestActivityDte=Date.valueOf(opp.Tasks[0].LastModifiedDate);
                    //System.debug('***** I am here Tasks'+LatestActivityDte);
                }
            }
            
            if(opp.Core_Last_Activity_Date__c !=LatestActivityDte) { 
                opp.Core_Last_Activity_Date__c =LatestActivityDte; 
                OpptoUpdate.add(opp);
            }
            //system.debug('LatestActivityDte'+LatestActivityDte);
        }
        
        //update OpptoUpdate;
        
        if(!OpptoUpdate.isEmpty()){            
            Database.SaveResult[] srList = Database.update(OpptoUpdate, false);
            for(Database.SaveResult sr : srList) {
                if(!sr.isSuccess()){
                    String errorMsg = '';
                    for(Database.Error err : sr.getErrors()) {
                        errorMsg = errorMsg + err.getMessage();
                    }
                    //System.debug('***Error MSG - '+errorMsg);
                    captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = errorMsg, Core_Message__c = 'Opp Last Activity Date Batch', Core_Severity__c = 'High', Core_Origin__c='Core_Opp_Task_LastActvityUpdate_Batch', Core_When__c = System.now()));   
                }
            }
        }
        if(!captureQueryErr.isEmpty()){ insert captureQueryErr;
                                      }
        
    }
    
    global void finish(Database.BatchableContext BC){ 
      Database.executeBatch(new Core_Oppty_Event_LastActvityUpdate_Batch());         
    }   
}