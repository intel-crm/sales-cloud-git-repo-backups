/********************************************************************************************************************************************************************
Apex Class Name:  Core_Opp_LastActvityUpdate_Batch
Version     : 1.0 
Created Date: 10/04/2020
Function    : Update LastActivityDate field on Opportunity if any Notes and attachments or Forecast product added/edited

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Mahesh Manikonda               10/04/2020               Original Version developed
*******************************************************************************************************************************************************************/
global class Core_Opp_LastActvityUpdate_Batch implements Database.Batchable<sObject>, Database.Stateful{   
    
    global Database.QueryLocator start(Database.BatchableContext BC){  
        String query = 'SELECT Id,Name,StageName,Core_Last_Activity_Date__c from Opportunity where StageName IN (\'Develop\', \'Design\', \'Define\')';
        return Database.getQueryLocator(query);
    }
    
    
    global void execute(Database.BatchableContext BC, List<Opportunity> scope){ 
         List<Core_Log_Entry__c> captureQueryErr = new List<Core_Log_Entry__c>();
        system.debug('**Scope'+scope);
        Set<Id> Oppids= new Set<Id>();
        for(Opportunity Opp : scope){
            Oppids.add(Opp.Id);
        }
        
        
        List<Opportunity> OpportunityLst=[Select id,StageName,Core_Last_Activity_Date__c,(Select id,LastModifiedDate from Forecast_Product_Schedules__r ORDER BY LastModifiedDate DESC limit 1),(Select id,ParentId,Name,LastModifiedDate from Attachments ORDER BY LastModifiedDate DESC limit 1),(Select ContentDocument.Title,ContentDocument.CreatedDate,LinkedEntityId,ContentDocument.LastModifiedDate from ContentDocumentLinks ORDER BY ContentDocument.LastModifiedDate DESC limit 1),(Select id,LastModifiedDate from Notes ORDER by LastModifiedDate DESC limit 1) from Opportunity where Id IN :Oppids];
        
        List<Opportunity> OpptoUpdate= new List<Opportunity>();
        for(Opportunity opp: OpportunityLst){
            
            Date LatestActivityDte=opp.Core_Last_Activity_Date__c;
            if(opp.Forecast_Product_Schedules__r !=null && !opp.Forecast_Product_Schedules__r.isEmpty()){
                if(opp.Core_Last_Activity_Date__c < opp.Forecast_Product_Schedules__r[0].LastModifiedDate){
                    LatestActivityDte=Date.valueOf(opp.Forecast_Product_Schedules__r[0].LastModifiedDate);
                    
                    System.debug('******I am hereFC'+LatestActivityDte);
                }
            }
            if(opp.Attachments != null  && !opp.Attachments.isEmpty()){
                if(opp.Core_Last_Activity_Date__c < opp.Attachments[0].LastModifiedDate && opp.Attachments[0].LastModifiedDate > LatestActivityDte){
                    
                    LatestActivityDte=Date.valueOf(opp.Attachments[0].LastModifiedDate);
                    System.debug('***** I am here Attachments'+LatestActivityDte);
                }
            }
            if(opp.ContentDocumentLinks != null && !opp.ContentDocumentLinks.isEmpty()){
                if(opp.Core_Last_Activity_Date__c < opp.ContentDocumentLinks[0].ContentDocument.LastModifiedDate && opp.ContentDocumentLinks[0].ContentDocument.LastModifiedDate >LatestActivityDte){
                    
                    LatestActivityDte=Date.valueOf(opp.ContentDocumentLinks[0].ContentDocument.LastModifiedDate);
                    System.debug('***** I am here Notes'+LatestActivityDte);
                }
            }
			
			 if(opp.Notes != null  && !opp.Notes.isEmpty()){
                if(opp.Core_Last_Activity_Date__c < opp.Notes[0].LastModifiedDate && opp.Notes[0].LastModifiedDate > LatestActivityDte){
                    
                    LatestActivityDte=Date.valueOf(opp.Notes[0].LastModifiedDate);
                    System.debug('***** I am here Notes'+LatestActivityDte);
                }
            }
			
            
            if(opp.Core_Last_Activity_Date__c !=LatestActivityDte){
                opp.Core_Last_Activity_Date__c =LatestActivityDte;
                OpptoUpdate.add(opp);
            }
            system.debug('LatestActivityDte'+LatestActivityDte);
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
                    System.debug('***Error MSG - '+errorMsg);
                    captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = errorMsg, Core_Message__c = 'Opp Last Activity Date Batch', Core_Severity__c = 'High', Core_Origin__c='Core_Opp_LastActivityUpdate_Batch', Core_When__c = System.now()));   
                }
            }
        }
        if(!captureQueryErr.isEmpty()){
            insert captureQueryErr;
        }
        
    }
    
    global void finish(Database.BatchableContext BC){ 
    }
    
}