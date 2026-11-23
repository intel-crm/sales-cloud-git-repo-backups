/********************************************************************************************************************************************************************
Apex Class Name:  Core_Opp_LastActvityUpdate_Batch_v2
Version     : 1.1 
Created Date: 10/04/2020
Function    : Update LastActivityDate field on Opportunity if any Notes and attachments or Forecast product added/edited for stages: Develop, Design, Define
Update Core_Last_Opportunity_Progressed_Date__c field when Tasks, Events, or Core_Status_Update__c are modified for stages: Develop, Design, Define, Qualify

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Mahesh Manikonda               10/04/2020               Original Version developed
* Pranjal Rajput                 19/05/2026 Modified      Added Qualify stage for Core_Last_Opportunity_Progressed_Date__c field only
*******************************************************************************************************************************************************************/
global class Core_Opp_LastActvityUpdate_Batch_v2 implements Database.Batchable<sObject>, Database.Stateful{   
    
    global Database.QueryLocator start(Database.BatchableContext BC){  
        // Include Qualify stage in the query since we need it for the new field
        String query = 'SELECT Id,Name,StageName,Core_Last_Activity_Date__c,Core_Last_Opportunity_Progressed_Date__c,Core_Status_Update__c,LastModifiedDate from Opportunity where StageName IN (\'Develop\', \'Design\', \'Define\', \'Qualify\') AND (CloseDate >= LAST_N_YEARS:2 OR CreatedDate >= LAST_N_YEARS:2) Order by Accountid';
        return Database.getQueryLocator(query);
    }
    
    
    global void execute(Database.BatchableContext BC, List<Opportunity> scope){ 
        List<Core_Log_Entry__c> captureQueryErr = new List<Core_Log_Entry__c>();
        Set<Id> Oppids= new Set<Id>();
        Set<Id> QualifyStageOppIds = new Set<Id>(); // Track Qualify stage opportunities
        
        for(Opportunity Opp : scope){
            Oppids.add(Opp.Id);
            if(Opp.StageName == 'Qualify') {
                QualifyStageOppIds.add(Opp.Id);
            }
        }
        
        // Query Opportunities with related records including Histories
        List<Opportunity> OpportunityLst = new List<Opportunity>();
        try {
            OpportunityLst = [Select id,StageName,Core_Last_Activity_Date__c,Core_Last_Opportunity_Progressed_Date__c,Core_Status_Update__c,LastModifiedDate,
                              (Select id,LastModifiedDate from Forecast_Product_Schedules__r ORDER BY LastModifiedDate DESC limit 1),
                              (Select id,ParentId,Name,LastModifiedDate from Attachments ORDER BY LastModifiedDate DESC limit 1),
                              (Select ContentDocument.Title,ContentDocument.CreatedDate,LinkedEntityId,ContentDocument.LastModifiedDate from ContentDocumentLinks ORDER BY ContentDocument.LastModifiedDate DESC limit 1),
                              (Select id,LastModifiedDate from Notes ORDER by LastModifiedDate DESC limit 1),
                              (Select id,LastModifiedDate from Tasks ORDER by LastModifiedDate DESC limit 1),
                              (Select id,LastModifiedDate from Events ORDER by LastModifiedDate DESC limit 1),
                              (Select id,LastModifiedDate from Opportunitylineitems ORDER by LastModifiedDate DESC limit 1),
                              (SELECT Id, Field, CreatedDate, OldValue, NewValue FROM Histories WHERE Field = 'Core_Status_Update__c' ORDER BY CreatedDate DESC LIMIT 1)
                              from Opportunity where Id IN :Oppids];
        } catch(Exception e) {
            captureQueryErr.add(new Core_Log_Entry__c(
                Core_Details__c = 'Main query error: ' + e.getMessage(), 
                Core_Message__c = 'Opp Last Activity Date Batch - Query Error', 
                Core_Severity__c = 'High', 
                Core_Origin__c='Core_Opp_LastActivityUpdate_Batch', 
                Core_When__c = System.now()
            ));
        }
        
        // Now you can remove or simplify the separate OpportunityFieldHistory query since we have it in the main query
        // The Histories subquery will give you the same data
        
        List<Opportunity> OpptoUpdate= new List<Opportunity>();
        Opportunity opp1;
        for(Opportunity opp: OpportunityLst){
            
            Date LatestActivityDte = opp.Core_Last_Activity_Date__c;
            DateTime LatestOpportunityProgressedDte = opp.Core_Last_Opportunity_Progressed_Date__c;
            Boolean needsUpdate = false;
            Boolean isQualifyStage = QualifyStageOppIds.contains(opp.Id);
            
            // Process Core_Last_Activity_Date__c ONLY for Develop, Design, Define stages (NOT Qualify)
            if(!isQualifyStage) {
                
                // Check Forecast Product Schedules
                if(opp.Forecast_Product_Schedules__r !=null && !opp.Forecast_Product_Schedules__r.isEmpty()){
                    DateTime forecastModifiedDate = opp.Forecast_Product_Schedules__r[0].LastModifiedDate;
                    if(forecastModifiedDate != null && (opp.Core_Last_Activity_Date__c == null || opp.Core_Last_Activity_Date__c < forecastModifiedDate)){
                        if(LatestActivityDte == null || Date.valueOf(forecastModifiedDate) > LatestActivityDte) {
                            LatestActivityDte = Date.valueOf(forecastModifiedDate);
                            needsUpdate = true;
                        }
                    }
                }
                
                // Check Attachments
                if(opp.Attachments != null  && !opp.Attachments.isEmpty()){
                    DateTime attachmentModifiedDate = opp.Attachments[0].LastModifiedDate;
                    if(attachmentModifiedDate != null && (opp.Core_Last_Activity_Date__c == null || opp.Core_Last_Activity_Date__c < attachmentModifiedDate)){
                        if(LatestActivityDte == null || Date.valueOf(attachmentModifiedDate) > LatestActivityDte) {
                            LatestActivityDte = Date.valueOf(attachmentModifiedDate);
                            needsUpdate = true;
                        }
                    }
                }
                
                // Check Content Document Links
                if(opp.ContentDocumentLinks != null && !opp.ContentDocumentLinks.isEmpty()){
                    DateTime contentModifiedDate = opp.ContentDocumentLinks[0].ContentDocument.LastModifiedDate;
                    if(contentModifiedDate != null && (opp.Core_Last_Activity_Date__c == null || opp.Core_Last_Activity_Date__c < contentModifiedDate)){
                        if(LatestActivityDte == null || Date.valueOf(contentModifiedDate) > LatestActivityDte) {
                            LatestActivityDte = Date.valueOf(contentModifiedDate);
                            needsUpdate = true;
                        }
                    }
                }
                
                // Check Notes
                if(opp.Notes != null  && !opp.Notes.isEmpty()){
                    DateTime noteModifiedDate = opp.Notes[0].LastModifiedDate;
                    if(noteModifiedDate != null && (opp.Core_Last_Activity_Date__c == null || opp.Core_Last_Activity_Date__c < noteModifiedDate)){
                        if(LatestActivityDte == null || Date.valueOf(noteModifiedDate) > LatestActivityDte) {
                            LatestActivityDte = Date.valueOf(noteModifiedDate);
                            needsUpdate = true;
                        }
                    }
                }
                
                // Check Opportunity Line Items
                if(opp.Opportunitylineitems != null  && !opp.Opportunitylineitems.isEmpty()){
                    DateTime lineItemModifiedDate = opp.Opportunitylineitems[0].LastModifiedDate;
                    if(lineItemModifiedDate != null && (opp.Core_Last_Activity_Date__c == null || opp.Core_Last_Activity_Date__c < lineItemModifiedDate)){
                        if(LatestActivityDte == null || Date.valueOf(lineItemModifiedDate) > LatestActivityDte) {
                            LatestActivityDte = Date.valueOf(lineItemModifiedDate);
                            needsUpdate = true;
                        }
                    }
                }
            }
            
            // Process Core_Last_Opportunity_Progressed_Date__c for ALL stages (Develop, Design, Define, Qualify)
            
            // Check Tasks - Update Core_Last_Opportunity_Progressed_Date__c for ALL stages
            if(opp.Tasks != null  && !opp.Tasks.isEmpty()){
                DateTime taskModifiedDate = opp.Tasks[0].LastModifiedDate;
                
                // Update Core_Last_Activity_Date__c only for non-Qualify stages
                if(!isQualifyStage && taskModifiedDate != null && (opp.Core_Last_Activity_Date__c == null || opp.Core_Last_Activity_Date__c < taskModifiedDate)){
                    if(LatestActivityDte == null || Date.valueOf(taskModifiedDate) > LatestActivityDte) {
                        LatestActivityDte = Date.valueOf(taskModifiedDate);
                        needsUpdate = true;
                    }
                }
                
                // Update Core_Last_Opportunity_Progressed_Date__c for ALL stages (including Qualify)
                if(taskModifiedDate != null && (LatestOpportunityProgressedDte == null || taskModifiedDate > LatestOpportunityProgressedDte)){
                    LatestOpportunityProgressedDte = taskModifiedDate;
                    needsUpdate = true;
                }
            }
            
            // Check Events - Update Core_Last_Opportunity_Progressed_Date__c for ALL stages
            if(opp.Events != null  && !opp.Events.isEmpty()){
                DateTime eventModifiedDate = opp.Events[0].LastModifiedDate;
                
                // Update Core_Last_Activity_Date__c only for non-Qualify stages
                if(!isQualifyStage && eventModifiedDate != null && (opp.Core_Last_Activity_Date__c == null || opp.Core_Last_Activity_Date__c < eventModifiedDate)){
                    if(LatestActivityDte == null || Date.valueOf(eventModifiedDate) > LatestActivityDte) {
                        LatestActivityDte = Date.valueOf(eventModifiedDate);
                        needsUpdate = true;
                    }
                }
                
                // Update Core_Last_Opportunity_Progressed_Date__c for ALL stages (including Qualify)
                if(eventModifiedDate != null && (LatestOpportunityProgressedDte == null || eventModifiedDate > LatestOpportunityProgressedDte)){
                    LatestOpportunityProgressedDte = eventModifiedDate;
                    needsUpdate = true;
                }
            }
            
            // Check Core_Status_Update__c changes using the Histories subquery for ALL stages (including Qualify)
            if(opp.Histories != null && !opp.Histories.isEmpty()) {
                DateTime statusChangeDate = opp.Histories[0].CreatedDate;
                if(statusChangeDate != null && (LatestOpportunityProgressedDte == null || statusChangeDate > LatestOpportunityProgressedDte)) {
                    LatestOpportunityProgressedDte = statusChangeDate;
                    needsUpdate = true;
                }
            }
            
            // Update the opportunity if any changes detected
            if(needsUpdate && (opp.Core_Last_Activity_Date__c != LatestActivityDte || opp.Core_Last_Opportunity_Progressed_Date__c != LatestOpportunityProgressedDte)){
                opp1 = new Opportunity(Id=opp.Id);
                opp1.Core_Last_Activity_Date__c = LatestActivityDte;
                opp1.Core_Last_Opportunity_Progressed_Date__c = LatestOpportunityProgressedDte;
                OpptoUpdate.add(opp1);
                
                System.debug('***** Updating Opportunity: ' + opp.Id + ' (Stage: ' + opp.StageName + ')' +
                             ' | Core_Last_Activity_Date__c: ' + LatestActivityDte + 
                             ' | Core_Last_Opportunity_Progressed_Date__c: ' + LatestOpportunityProgressedDte);
            }
        }
        
        // Update opportunities
        if(!OpptoUpdate.isEmpty()){
            Database.SaveResult[] srList = Database.update(OpptoUpdate, false);
            Integer successCount = 0;
            for(Integer i = 0; i < srList.size(); i++) {
                Database.SaveResult sr = srList[i];
                if(sr.isSuccess()){
                    successCount++;
                } else {
                    String errorMsg = 'Failed to update Opportunity ' + OpptoUpdate[i].Id + ': ';
                    for(Database.Error err : sr.getErrors()) {
                        errorMsg += err.getMessage() + '; ';
                    }
                    captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = errorMsg, Core_Message__c = 'Opp Last Activity Date Batch', Core_Severity__c = 'High', Core_Origin__c='Core_Opp_LastActivityUpdate_Batch', Core_When__c = System.now()));   
                }
            }
            System.debug('***** Successfully updated ' + successCount + ' out of ' + OpptoUpdate.size() + ' opportunities');
        }
        
        if(!captureQueryErr.isEmpty()){
            try {
                insert captureQueryErr;
            } catch(Exception e) {
                System.debug('Error inserting log entries: ' + e.getMessage());
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){ 
        System.debug('***** Core_Opp_LastActvityUpdate_Batch completed successfully');
    }
}