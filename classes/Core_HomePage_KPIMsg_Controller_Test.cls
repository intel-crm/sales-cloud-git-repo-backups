@isTest
public class Core_HomePage_KPIMsg_Controller_Test {
    @testSetup
    static void setupTest() {
        
      Core_KPI_Refresh_Message__c kpi=new Core_KPI_Refresh_Message__c();
        kpi.Name='New Msg';
        kpi.Core_LastModifiedDate__c=system.today();
        insert kpi;        
        
    }
    
    static testMethod void getPSTformattedKPITime_Test1() {
        Test.startTest();
        Core_HomePage_KPIMsg_Controller kpiMsgObj = new Core_HomePage_KPIMsg_Controller();
        kpiMsgObj.getPSTformattedKPITime();
        Core_HomePage_KPIMsg_Controller.lastRunPSTTimeString='date';
        Test.stopTest();
    }
    
}