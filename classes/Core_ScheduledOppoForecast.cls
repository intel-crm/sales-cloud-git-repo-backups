public without sharing class Core_ScheduledOppoForecast Implements Schedulable {
    public void execute(SchedulableContext sc) {
        //updateOpportunityForecast();
        Core_ScheduledOppForecast_Batch sof = new Core_ScheduledOppForecast_Batch();
        database.executeBatch(sof, Integer.valueof(Label.Core_OppForcast_Batch_Size));
    }
    
    /*public void updateOpportunityForecast() {
        Set<Id> oppId = new Set<Id>();
        String currentFiscalYear;
        Integer currentFiscalQuarterNum;
        String currentQuarter;
        Integer numb;
        String year;
        List<String> foreQuarter  = new List<String>();
        Map<Id, Decimal> oppAmount  = new Map<Id, Decimal>();
        List<Core_Opportunity_Forecast__c> foreList = new List<Core_Opportunity_Forecast__c>();
        List<Core_Opportunity_Forecast__c> oppForecastList = new List<Core_Opportunity_Forecast__c>();
        Date Today = system.Today();
        List<Opportunity> oppList = new List<Opportunity>();
        ID recordTypeId;
        ID recordTypeId_new;
        Date startDate;
        Date start7Date;
        Date endDate;
        String currentQ;
        List<String> quart = new List<String>();
        try {
            oppForecastList = [Select Id, Core_Opportunity__c, Core_Forecast_Quarter__c, Core_Read_Only__c, Core_Forecast__c from Core_Opportunity_Forecast__c where Core_Read_Only__c = false];
            System.debug('oppForecastList::'+oppForecastList.size());
            currentFiscalYear = [SELECT FiscalYearSettings.Name FROM Period WHERE Type = 'Year' AND StartDate <= TODAY AND EndDate >= TODAY].FiscalYearSettings.Name;
            currentFiscalQuarterNum = [Select startdate, Number From Period Where type = 'Quarter' and StartDate = THIS_FISCAL_QUARTER].Number;
            System.debug('+++Inside Schedule Forecast+++'+currentFiscalYear +'size'+oppForecastList.size());
            System.debug('currentFiscalQuarterNum::'+currentFiscalQuarterNum);
            System.debug('Today::'+Today);
            for(Core_Opportunity_Forecast__c fore:oppForecastList) {
                oppId.add(fore.Core_Opportunity__c);
                foreQuarter.add(fore.Core_Forecast_Quarter__c);
                System.debug('oppId'+oppId);
                System.debug('foreQuarter::'+foreQuarter);
                
            } 
            currentQ = 'Q'+currentFiscalQuarterNum+' '+currentFiscalYear;
            if(oppId.size()>0) {
                System.debug('inside Creation');    
                oppList = [Select Id,Amount,CloseDate from Opportunity where Id =:oppId];
                recordTypeId = [select Id,Name,DeveloperName from RecordType where DeveloperName='Core_ReadOnly'].Id;
                recordTypeId_new = [select Id,Name,DeveloperName from RecordType where DeveloperName='Core_OppForecastNew'].Id;
                startDate = [Select startdate, Number From Period Where type = 'Quarter' and StartDate = THIS_FISCAL_QUARTER].startdate;
                start7Date = [Select startdate, Number From Period Where type = 'Quarter' and StartDate = THIS_FISCAL_QUARTER].startdate + integer.valueOf(Label.Opp_Forecast_Lock_Duration);
                endDate = [Select enddate From Period Where type = 'Quarter' and StartDate = THIS_FISCAL_QUARTER].enddate;
                System.debug('startDate:::'+startDate);
                System.debug('endDate:::'+endDate);
                System.debug('start7Date:::'+start7Date);
                if(oppList.size()>0) {
                    for(Opportunity opp :oppList){
                        oppAmount.put(opp.Id, opp.Amount); 
                    }
                    for(Core_Opportunity_Forecast__c updatefore:oppForecastList) {
                        updatefore.Core_Forecast_Amount__c = oppAmount.get(updatefore.Core_Opportunity__c);
                        updatefore.Core_Quarter_End_Date__c = endDate;
                        updatefore.Core_Quarter_First_Weekend_Date__c = start7Date;
                        updatefore.Core_Quarter_Start_Date__c = startDate;
                        System.debug('Field::'+updatefore.Core_Forecast_Quarter__c);
                        System.debug('String::'+currentQuarter);
                        if((foreQuarter.Contains(currentQ) || Today > endDate)) {
                            System.debug('Year and Quarter Pass');
                            if(Today > start7Date) { //Today < startDate || 
                                System.debug('Readonly true');
                                updatefore.Core_Read_Only__c = True;
                                updatefore.RecordTypeId = recordTypeId;
                                updatefore.Core_Forecast__c = 'Commit';
                                
                            }
                            else {
                                System.Debug('Readonly false:::');   
                                updatefore.Core_Read_Only__c = False;
                                updatefore.RecordTypeId = recordTypeId_new;
                            } 
                        }                                    
                    }
                    System.debug('oppForecastList::'+oppForecastList);
                    database.update(oppForecastList, false);
                }
                
            }   
        }Catch(Exception ex) {
            System.debug('Exception::'+ex);
        }  
    }*/
}