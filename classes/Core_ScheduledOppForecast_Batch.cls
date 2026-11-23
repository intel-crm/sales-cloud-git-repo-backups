public without sharing class Core_ScheduledOppForecast_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    public static boolean OppForbypassTriggers = false;
    public Database.QueryLocator start(Database.BatchableContext bc){
        return database.getQueryLocator([Select Id, Core_Opportunity__c, Core_Forecast_Quarter__c, Core_Read_Only__c, 
                                         Core_Forecast__c,Core_Quarter_Start_Date__c,Core_Quarter_End_Date__c,Core_Quarter_First_Weekend_Date__c from Core_Opportunity_Forecast__c where 
                                         Core_Read_Only__c = false]);      
    }    
    public void execute(Database.BatchableContext bc, List<Core_Opportunity_Forecast__c> oppForecastList){
        OppForbypassTriggers = true;
        Set<Id> oppId = new Set<Id>();
        String currentFiscalYear;
        Map<Id, Decimal> oppAmount  = new Map<Id, Decimal>();
        Date Today = system.Today();
        List<Opportunity> oppList = new List<Opportunity>();
        ID recordTypeId;
        ID recordTypeId_new;
        Date startDate;
        Date start7Date;
        Map <String,Period> quarterData = new Map <String,Period>();
        
        try {
            for (Period perd: [Select FiscalYearSettings.QuarterPrefix,Number,FiscalYearSettings.Name,startdate,EndDate  From Period Where type = 'Quarter'  and startdate >= 2022-12-01 order by startdate]) {
                String quarter = perd.FiscalYearSettings.QuarterPrefix + ''+ perd.Number+' '+ perd.FiscalYearSettings.Name;
                quarterData.put(quarter, perd);
            }
            recordTypeId = [select Id,Name,DeveloperName from RecordType where DeveloperName='Core_ReadOnly'].Id;
            recordTypeId_new = [select Id,Name,DeveloperName from RecordType where DeveloperName='Core_OppForecastNew'].Id;
            
            
            for(Core_Opportunity_Forecast__c fore:oppForecastList) {
                oppId.add(fore.Core_Opportunity__c);
               
            } 
            if(oppId.size()>0) {
               
                oppList = [Select Id,Amount,CloseDate from Opportunity where Id =:oppId];                
                if(oppList.size()>0) {
                    for(Opportunity opp :oppList){
                        oppAmount.put(opp.Id, opp.Amount); 
                    }
                    for(Core_Opportunity_Forecast__c updatefore:oppForecastList) {
                        start7Date = quarterData.get(updatefore.Core_Forecast_Quarter__c).startdate + integer.valueOf(Label.Opp_Forecast_Lock_Duration);
                        updatefore.Core_Forecast_Amount__c = oppAmount.get(updatefore.Core_Opportunity__c);
                        if((Today > updatefore.Core_Quarter_Start_Date__c && 
                            Today <= updatefore.Core_Quarter_End_Date__c)) {
                                updatefore.Core_Quarter_First_Weekend_Date__c = start7Date;
                                if(Today > start7Date) { 
                                   
                                    updatefore.Core_Read_Only__c = True;
                                    updatefore.RecordTypeId = recordTypeId;
                                } 
                            }                                    
                    }
                    
                    database.update(oppForecastList, false);
                }
                
            } 
            
        }Catch(Exception ex) {
             
        }      
    } 
    public void finish(database.BatchableContext bc) {
        OppForbypassTriggers = false;
        //NP - Check if Opportunity Forecast Quarter values need to be updated
        Core_OpportunityForecastController.checkIfQtrStart();     
    }
}