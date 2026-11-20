/********************************************************************************************************************************************************************
Apex Class Name:  Core_Opp_OLI_LastActvityUpdate_Batch
Version     : 1.0 
Created Date: 12/09/2022
Function    : Update LastActivityDate field on Opportunity if any Opportunity Product added/edited

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Mula Yeshwanth               12/09/2022               Original Version developed
*******************************************************************************************************************************************************************/
global class Core_Opp_OLI_LastActvityUpdate_Batch implements Database.Batchable<sObject>, Database.Stateful{   
    
    global Database.QueryLocator start(Database.BatchableContext BC){ 
		//DateTime dt = System.Now().addHours(Integer.valueOf(label.Core_Opportunity_Last_Activity_Date)); 
        DateTime dt = System.Now().addHours(-4); 
		String query = 'Select Id,LastModifiedDate, OpportunityId, Opportunity.Name,Opportunity.StageName,Opportunity.Core_Last_Activity_Date__c from OpportunityLineItem WHERE Opportunity.StageName IN (\'Develop\', \'Design\', \'Define\',\'Qualify\') AND LastModifiedDate >=:dt';
		return Database.getQueryLocator(query);
    }
    
    
    global void execute(Database.BatchableContext BC, List<OpportunityLineItem> scope){ 
         List<Core_Log_Entry__c> captureQueryErr = new List<Core_Log_Entry__c>();
        //system.debug('**Scope'+scope);
        Set<Id> Oppids= new Set<Id>();           
       for(OpportunityLineItem Oppline : scope){
		   Oppids.add(Oppline.OpportunityId);
		   
	   }
              
	        List<Opportunity> OpportunityLst=[Select id,StageName,Core_Last_Activity_Date__c,(Select id,LastModifiedDate from Opportunitylineitems ORDER by LastModifiedDate DESC limit 1) from Opportunity where Id IN :Oppids];
 
            List<Opportunity> OpptoUpdate= new List<Opportunity>();      
        for(Opportunity opp: OpportunityLst){
            
            Date LatestActivityDte=opp.Core_Last_Activity_Date__c;
	      // OpportunityLineItem
            if(opp.Opportunitylineitems != null  && !opp.Opportunitylineitems.isEmpty()){
                if(opp.Core_Last_Activity_Date__c < opp.Opportunitylineitems[0].LastModifiedDate && opp.Opportunitylineitems[0].LastModifiedDate > LatestActivityDte){ //30 list 1st record
                    
                    LatestActivityDte=Date.valueOf(opp.Opportunitylineitems[0].LastModifiedDate);
                    //System.debug('***** I am here Opportunitylineitems'+LatestActivityDte);
                }
            }
			
			if(opp.Core_Last_Activity_Date__c !=LatestActivityDte){  
                opp.Core_Last_Activity_Date__c =LatestActivityDte;           
                OpptoUpdate.add(opp);
            }
            //system.debug('LatestActivityDte'+LatestActivityDte);
		}
  
            if(!OpptoUpdate.isEmpty()){         
            Database.SaveResult[] srList = Database.update(OpptoUpdate, false);              
            for(Database.SaveResult sr : srList) {
                if(!sr.isSuccess()){                                                         
                    String errorMsg = '';
                    for(Database.Error err : sr.getErrors()) {
                        errorMsg = errorMsg + err.getMessage();
                    }
                    //System.debug('***Error MSG - '+errorMsg);
                    captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = errorMsg, Core_Message__c = 'Opp Last Activity Date Batch', Core_Severity__c = 'High', Core_Origin__c='Core_Opp_OLI_LastActvityUpdate_Batch', Core_When__c = System.now()));   
                }
            }
        }
        if(!captureQueryErr.isEmpty()){
            insert captureQueryErr;
        }
        
    }
    
    global void finish(Database.BatchableContext BC){
		// Calling another batch
			/* Core_Oppty_Attch_LastActvityUpdate_Batch attach = new Core_Oppty_Attch_LastActvityUpdate_Batch();
				Database.executeBatch(attach, 200); */
        Database.executeBatch(new Core_Opp_QPS_LastActvityDateUpdate_Batch());
     }
    
}