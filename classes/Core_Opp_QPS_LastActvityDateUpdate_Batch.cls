/********************************************************************************************************************************************************************
Apex Class Name:  Core_Opp_QPS_LastActvityDateUpdate_Batch
Version     : 1.0 
Created Date: 12/09/2022
Function    : Update LastActivityDate field on Opportunity if any Forecast product added/edited

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Mula Yeshwanth               12/09/2022               Original Version developed
*******************************************************************************************************************************************************************/
global class Core_Opp_QPS_LastActvityDateUpdate_Batch implements Database.Batchable<sObject>, Database.Stateful{   
    
    global Database.QueryLocator start(Database.BatchableContext BC){          
        //DateTime dt = System.Now().addHours(Integer.valueOf(label.Core_Opportunity_Last_Activity_Date)); 
        DateTime dt = System.Now().addHours(-4);         
        String query   = 'SELECT id,LastModifiedDate,Core_Opp_FC_Opportunity__c,Core_Opp_FC_Opportunity__r.Name, Core_Opp_FC_Opportunity__r.StageName, Core_Opp_FC_Opportunity__r.Core_Last_Activity_Date__c FROM Core_Opp_FC_Prod_Schedule__c WHERE Core_Opp_FC_Opportunity__r.StageName IN (\'Develop\', \'Design\', \'Define\',\'Qualify\') AND LastModifiedDate >=:dt'; 
        return Database.getQueryLocator(query);               
    }
    
    
    global void execute(Database.BatchableContext BC, List<Core_Opp_FC_Prod_Schedule__c> scope){ 
        List<Core_Log_Entry__c> captureQueryErr = new List<Core_Log_Entry__c>();
        //system.debug('**Scope'+scope);
        Set<Id> Oppids= new Set<Id>();
        for(Core_Opp_FC_Prod_Schedule__c Oppline : scope){
            Oppids.add(Oppline.Core_Opp_FC_Opportunity__r.id);		   
        }		
        
        List<Opportunity> OpportunityLst=[Select id,StageName,Core_Last_Activity_Date__c,(Select id,LastModifiedDate from Forecast_Product_Schedules__r ORDER BY LastModifiedDate DESC limit 1) from Opportunity where Id IN :Oppids];     
        List<Opportunity> OpptoUpdate= new List<Opportunity>();
        for(Opportunity opp: OpportunityLst){
            
            Date LatestActivityDte=opp.Core_Last_Activity_Date__c;
            // OpportunityLineItem
            if(opp.Forecast_Product_Schedules__r !=null && !opp.Forecast_Product_Schedules__r.isEmpty()){
                if(opp.Core_Last_Activity_Date__c < opp.Forecast_Product_Schedules__r[0].LastModifiedDate){
                    LatestActivityDte=Date.valueOf(opp.Forecast_Product_Schedules__r[0].LastModifiedDate);
                    
                    //System.debug('******I am hereFC'+LatestActivityDte);
                }
            }
            
            if(opp.Core_Last_Activity_Date__c !=LatestActivityDte){ opp.Core_Last_Activity_Date__c =LatestActivityDte; OpptoUpdate.add(opp);
                                                                  }
            //system.debug('LatestActivityDte'+LatestActivityDte);
        }  
        //update forecastToUpdate;        
        if(!OpptoUpdate.isEmpty()){            
            Database.SaveResult[] srList = Database.update(OpptoUpdate, false);
            for(Database.SaveResult sr : srList) {
                if(!sr.isSuccess()){
                    String errorMsg = '';
                    for(Database.Error err : sr.getErrors()) {
                        errorMsg = errorMsg + err.getMessage();
                    }
                    //System.debug('***Error MSG - '+errorMsg);
                    captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = errorMsg, Core_Message__c = 'Opp Last Activity Date Batch', Core_Severity__c = 'High', Core_Origin__c='Core_Opp_QPS_LastActvityDateUpdate_Batch', Core_When__c = System.now()));   
                }
            }
        }
        if(!captureQueryErr.isEmpty()){ insert captureQueryErr;
                                      }
        
    }
    
    global void finish(Database.BatchableContext BC){ 
       Database.executeBatch(new Core_Opp_Doclnk_LastActvityUpdate_Batch()); 
        
    }    
}