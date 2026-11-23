global class Core_QuarterlyForecastingBatchSchedule implements Schedulable { 
     global void execute(SchedulableContext SC) {
         
         // Get the start and end dates for the current quarter
        Boolean runBatch = false;
        Map <String,Period> quarterData = new Map <String,Period>();
        String currentQuarter;
        Date qtr14Day;
        Date currentDate = system.today();
        
        Core_CRM_Labels__c dateRec = Core_CRM_Labels__c.getInstance('Core_QuaterlyForecastingDay');
      	Integer noOfDays = Integer.ValueOf(dateRec.Value__c)-1;
       
 
        for (Period perd: [Select FiscalYearSettings.QuarterPrefix,Number,FiscalYearSettings.Name,Startdate,EndDate  From Period Where type = 'Quarter'  and Startdate >= 2024-12-01 order by Startdate]) {
        	String quarter = perd.FiscalYearSettings.QuarterPrefix + ''+ perd.Number+' '+ perd.FiscalYearSettings.Name;
            quarterData.put(quarter, perd);
        	}
         currentQuarter = Core_OpportunityForecastController.determineQuarter(System.today());
         qtr14Day= quarterData.get(currentQuarter).Startdate+noOfDays;
         if(currentDate==qtr14Day){
         	runBatch = true;	
         }  
         
         if(runBatch == true || Test.isRunningTest()){
            Core_QuarterlyForecastingBatch forecastBatch = new Core_QuarterlyForecastingBatch();
            Database.executeBatch(forecastBatch);
         }
            
        system.debug('Quarter data is:'+quarterData);
        system.debug('Quarter 14th data is:'+qtr14Day);
        system.debug('Quarter runBatch:'+runBatch);
         
         
     }
    

}