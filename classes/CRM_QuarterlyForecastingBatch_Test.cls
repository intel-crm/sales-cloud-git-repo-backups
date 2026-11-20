@isTest
public class CRM_QuarterlyForecastingBatch_Test {
    @isTest(SeeAllData=true)
    public static void checkQuaterlyForecasting(){      
        Datetime fireTime = Datetime.now();
        String cron = fireTime.second() + ' ' + fireTime.minute() + ' ' + fireTime.hour() + ' * * ?';
        
        Test.startTest();
        CRM_QuarterlyForecastingBatch forecastBatch = new CRM_QuarterlyForecastingBatch();
        Database.executeBatch(forecastBatch,100);
        Test.stopTest();
    }
}