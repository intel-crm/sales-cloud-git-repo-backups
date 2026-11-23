@isTest
public class CRM_QuarterlyForecastingBatch_Test {
    @isTest(SeeAllData=true)
    public static void checkQuaterlyForecasting(){
        

        Core_CRM_Labels__c cust3 = [SELECT Id,Name,Value__c FROM Core_CRM_Labels__c where Name ='Core_QuaterlyForecastingDay'];
 
        List<ForecastingItem> forecastItem = [SELECT Id FROM ForecastingItem];
        system.debug('FORECAST HISTORY IS:'+forecastItem);
        
        Datetime fireTime = Datetime.now();
        String cron = fireTime.second() + ' ' + fireTime.minute() + ' ' + fireTime.hour() + ' * * ?';
        
        Test.startTest();
        CRM_QuarterlyForecastingBatch forecastBatch = new CRM_QuarterlyForecastingBatch();
        Database.executeBatch(forecastBatch);
        Test.stopTest();
       
                
        
    }
}