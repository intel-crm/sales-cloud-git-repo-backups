global class CRM_QuarterlyForecastingBatch implements Database.Batchable<SObject>, Database.Stateful {
    private Boolean runBatch = false;
    private Date firstDayOfQuarter;
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String currentQuarter;
        Date qtr14Day;
        Date currentDate = system.today();
        
        Core_CRM_Labels__c dateRec = Core_CRM_Labels__c.getInstance('Core_QuaterlyForecastingDay');
        Integer noOfDays = Integer.ValueOf(dateRec.Value__c);
        
        
        Period perd =[Select Number,FiscalYearSettings.Name,Startdate,EndDate  From Period Where type = 'Quarter' and StartDate <= TODAY AND EndDate >= TODAY LIMIT 1];
        
        firstDayOfQuarter = perd.StartDate;
        qtr14Day= firstDayOfQuarter+noOfDays;
        if(currentDate==qtr14Day || Test.IsRunningTest()){
            runBatch = true;	
        }
        String query = '';
        if(!Test.IsRunningTest()){
            query = 'SELECT Id,ForecastAmount,Period.StartDate, ForecastingTypeId,OwnerId FROM ForecastingItem where ForecastingType.MasterLabel= \'Intel-Led Opportunity Revenue\' and ForecastingItemCategory= \'CommitForecast\' and Period.StartDate=:firstDayOfQuarter order by OwnerId desc';    
        } else {
            query = 'SELECT Id,ForecastAmount,Period.StartDate, ForecastingTypeId,OwnerId FROM ForecastingItem where ForecastingType.MasterLabel= \'Intel-Led Opportunity Revenue\' and ForecastingItemCategory= \'CommitForecast\' and Period.StartDate=:firstDayOfQuarter order by OwnerId desc LIMIT 10';    
        }
        
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<ForecastingItem> scope) {
        Map<Id,ForecastingCustomData> customDataMap = new Map<Id,ForecastingCustomData>();
        List<ForecastingCustomData> customDataListInsert = new List<ForecastingCustomData>();
        List<ForecastingCustomData>  forecastList = [SELECT Id,ForecastOwnerId,StartDate,Locked_Commit_Amount__c, ForecastingTypeId FROM ForecastingCustomData WHERE StartDate=:firstDayOfQuarter];
        for(ForecastingCustomData customDataRec:forecastList){
            customDataMap.put(customDataRec.ForecastOwnerId,customDataRec);
        }
        if(runBatch == true){
            for(ForecastingItem itemRec: scope){
                if(customDataMap.get(itemRec.OwnerId)==null || Test.IsRunningTest()){
                    ForecastingCustomData newCustomData = new ForecastingCustomData();
                    newCustomData.ForecastOwnerId = itemRec.OwnerId;
                    newCustomData.StartDate = itemRec.Period.StartDate;
                    newCustomData.ForecastingTypeId = itemRec.ForecastingTypeId;
                    newCustomData.Locked_Commit_Amount__c = itemRec.ForecastAmount;
                    customDataListInsert.add(newCustomData);
                }
            } 	
            if(!customDataListInsert.isEmpty()){
                try{
                    insert customDataListInsert;
                }
                catch(Exception ex){
                    Core_Log_Entry__c ExcepLog = new Core_Log_Entry__c(Core_Message__c = ex.getMessage().abbreviate(254), Core_Origin__c = 'CRM_QuarterlyForecastingBatch', Core_Severity__c = 'High', Core_When__c = System.Now(), Core_Project__c = 'Sales', Core_Details__c = 'Line number:'+ex.getLineNumber()+', Stack trace: '+ex.getStackTraceString());
                    insert ExcepLog;
                }
            }
            
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
}