/********************************************************************************************************************************************************************
Apex Class Name:  Core_Opp_Doclnk_LastActvityUpdate_Batch
Version     : 1.0 
Created Date: 12/09/2022
Function    : Update LastActivityDate field on Opportunity if any Notes, Attachement is added/edited

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Mula Yeshwanth               12/09/2022               Original Version developed
*******************************************************************************************************************************************************************/

global class Core_Opp_Doclnk_LastActvityUpdate_Batch implements Database.Batchable<ContentDocumentLink>, Database.Stateful{   
    
    global Iterable<ContentDocumentLink> start(Database.BatchableContext BC){          
        DateTime dt = System.Now().addHours(Integer.valueOf(label.Core_Opportunity_Last_Activity_Date)); 
      // DateTime dt = System.Now().addHours(-4); 
        List<ContentDocumentLink> cntList= [SELECT Id, ContentDocumentId, ContentDocument.Title, ContentDocument.FileType, LinkedEntityId, ShareType, Visibility FROM ContentDocumentLink where LinkedEntityId IN (Select id from Opportunity where Stagename IN('Design','Define','Qualify','Develop')) and ContentDocument.LastModifiedDate >=:dt];       
        return cntList;           
    }
    global void execute(Database.BatchableContext BC,List<ContentDocumentLink> scope){
    	//system.debug('inside execute');
        List<Core_Log_Entry__c> captureQueryErr = new List<Core_Log_Entry__c>();
        Set<Id> Oppids= new Set<Id>();
        for(ContentDocumentLink Opp : scope){
            Oppids.add(Opp.LinkedEntityId); 
        }        
        
        List<Opportunity> OpportunityLst=[Select id,StageName,Core_Last_Activity_Date__c,(Select ContentDocument.Title,ContentDocument.CreatedDate,LinkedEntityId,ContentDocument.LastModifiedDate from ContentDocumentLinks ORDER BY ContentDocument.LastModifiedDate DESC limit 1) from Opportunity where Id IN :Oppids];
        
        List<Opportunity> OpptoUpdate= new List<Opportunity>();
        for(Opportunity opp: OpportunityLst){
            
            Date LatestActivityDte=opp.Core_Last_Activity_Date__c;
            if(opp.ContentDocumentLinks != null && !opp.ContentDocumentLinks.isEmpty()){
                if(opp.Core_Last_Activity_Date__c < opp.ContentDocumentLinks[0].ContentDocument.LastModifiedDate && opp.ContentDocumentLinks[0].ContentDocument.LastModifiedDate >LatestActivityDte){
                    
                    LatestActivityDte=Date.valueOf(opp.ContentDocumentLinks[0].ContentDocument.LastModifiedDate);
                    //System.debug('***** I am here ContentDoc'+LatestActivityDte);
                }
            }         
            
            if(opp.Core_Last_Activity_Date__c !=LatestActivityDte){ opp.Core_Last_Activity_Date__c =LatestActivityDte; OpptoUpdate.add(opp);
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
                    captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = errorMsg, Core_Message__c = 'Opp Last Activity Date Batch', Core_Severity__c = 'High', Core_Origin__c='Core_Opp_Doclnk_LastActvityUpdate_Batch', Core_When__c = System.now()));   
                }
            }
        }
        if(!captureQueryErr.isEmpty()){ insert captureQueryErr;
        }
        
    }
    
    global void finish(Database.BatchableContext BC){ 
         Database.executeBatch(new Core_Opp_Task_LastActvityUpdate_Batch());        
        
    }
}