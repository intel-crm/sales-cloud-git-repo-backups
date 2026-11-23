/********************************************************************************************************************************************************************
Apex Class Name:  Core_Oppty_LastActvityUpdate_Batch
Version     : 1.0 
Created Date: 10/04/2020
Function    : Update LastActivityDate field on Opportunity if any Notes and attachments or Forecast product added/edited

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Mula Yeshwanth              9/08/2022               Original Version developed
*******************************************************************************************************************************************************************/

global class Core_Oppty_LastActvityUpdate_Batch implements Database.Batchable<sObject>, Database.Stateful{   
    
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
        
        
       List<Opportunity> OpportunityLst=[Select id,StageName,Core_Last_Activity_Date__c,(Select id,LastModifiedDate from Forecast_Product_Schedules__r ORDER BY LastModifiedDate DESC limit 1),(Select ContentDocument.Title,ContentDocument.CreatedDate,LinkedEntityId,ContentDocument.LastModifiedDate from ContentDocumentLinks ORDER BY ContentDocument.LastModifiedDate DESC limit 1),(Select id,LastModifiedDate from Tasks ORDER by LastModifiedDate DESC limit 1),(Select id,LastModifiedDate from Events ORDER by LastModifiedDate DESC limit 1),(Select id,LastModifiedDate from Opportunitylineitems ORDER by LastModifiedDate DESC limit 1) from Opportunity where Id IN :Oppids];
        //,(Select id,ParentId,Name,LastModifiedDate from Attachments ORDER BY LastModifiedDate DESC limit 1)
        List<Opportunity> OpptoUpdate= new List<Opportunity>();
        for(Opportunity opp: OpportunityLst){
            
            Date LatestActivityDte=opp.Core_Last_Activity_Date__c;
            if(opp.Forecast_Product_Schedules__r !=null && !opp.Forecast_Product_Schedules__r.isEmpty()){
                if(opp.Core_Last_Activity_Date__c < opp.Forecast_Product_Schedules__r[0].LastModifiedDate){
                    LatestActivityDte=Date.valueOf(opp.Forecast_Product_Schedules__r[0].LastModifiedDate);
                    
                    System.debug('******I am hereFC'+LatestActivityDte);
                }
            }
           /* if(opp.Attachments != null  && !opp.Attachments.isEmpty()){
                if(opp.Core_Last_Activity_Date__c < opp.Attachments[0].LastModifiedDate && opp.Attachments[0].LastModifiedDate > LatestActivityDte){
                    
                    LatestActivityDte=Date.valueOf(opp.Attachments[0].LastModifiedDate);
                    System.debug('***** I am here Attachments'+LatestActivityDte);
                }
            }*/
            if(opp.ContentDocumentLinks != null && !opp.ContentDocumentLinks.isEmpty()){
                if(opp.Core_Last_Activity_Date__c < opp.ContentDocumentLinks[0].ContentDocument.LastModifiedDate && opp.ContentDocumentLinks[0].ContentDocument.LastModifiedDate >LatestActivityDte){
                    
                    LatestActivityDte=Date.valueOf(opp.ContentDocumentLinks[0].ContentDocument.LastModifiedDate);
                    System.debug('***** I am here Notes'+LatestActivityDte);
                }
            }
			 //Notes
			 if(opp.Notes != null  && !opp.Notes.isEmpty()){
                if(opp.Core_Last_Activity_Date__c < opp.Notes[0].LastModifiedDate && opp.Notes[0].LastModifiedDate > LatestActivityDte){
                    
                    LatestActivityDte=Date.valueOf(opp.Notes[0].LastModifiedDate);
                    System.debug('***** I am here Notes'+LatestActivityDte);
                }
            }
			// Tasks
				if(opp.Tasks != null  && !opp.Tasks.isEmpty()){
                if(opp.Core_Last_Activity_Date__c < opp.Tasks[0].LastModifiedDate && opp.Tasks[0].LastModifiedDate > LatestActivityDte){
                    
                    LatestActivityDte=Date.valueOf(opp.Tasks[0].LastModifiedDate);
                    System.debug('***** I am here Tasks'+LatestActivityDte);
                }
            }
			//Events
			if(opp.Events != null  && !opp.Events.isEmpty()){
                if(opp.Core_Last_Activity_Date__c < opp.Events[0].LastModifiedDate && opp.Events[0].LastModifiedDate > LatestActivityDte){
                    
                    LatestActivityDte=Date.valueOf(opp.Events[0].LastModifiedDate);
                    System.debug('***** I am here Events'+LatestActivityDte);
                }
            }
			// OpportunityLineItem
            if(opp.Opportunitylineitems != null  && !opp.Opportunitylineitems.isEmpty()){
                if(opp.Core_Last_Activity_Date__c < opp.Opportunitylineitems[0].LastModifiedDate && opp.Opportunitylineitems[0].LastModifiedDate > LatestActivityDte){
                    
                    LatestActivityDte=Date.valueOf(opp.Opportunitylineitems[0].LastModifiedDate);
                    System.debug('***** I am here Opportunitylineitems'+LatestActivityDte);
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
        //custom lable for 4 hrs
        Core_Oppty_LastActvityDt_Schedule j = new Core_Oppty_LastActvityDt_Schedule ();
        String sch = label.Core_Opportunity_Last_Activity_Date;
        System.schedule('My Job', sch, j);
        //Core_Oppty_LastActvityUpdate_Batch clb = new Core_Oppty_LastActvityUpdate_Batch();
        //Database.executeBatch(clb,200);
        
        //Database.executeBatch(new Core_Oppty_Attch_LastActvityUpdate_Batch());
    }
}