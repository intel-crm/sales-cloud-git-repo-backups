@isTest
public class Core_IQR_StageDeleteSchedulerTest {
    static testMethod void testMethod1() {
       List<Core_IQR_Products_Staging__c> iqrStagingList = new List<Core_IQR_Products_Staging__c>();
        for(Integer i=0 ;i <200;i++)
        {
            Core_IQR_Products_Staging__c iqrRecord2 = new Core_IQR_Products_Staging__c();
        iqrRecord2.Core_Processing_Status__c='New';
        iqrRecord2.createdDate=System.today() - 1;
        //iqrRecord2.isLatest=false;
       
            iqrStagingList.add(iqrRecord2);
        }
        insert iqrStagingList;
        
        Test.startTest();

           Core_IQR_StageDeleteScheduler.stageDeleteScheduler();
            
        Test.stopTest();
    }

}