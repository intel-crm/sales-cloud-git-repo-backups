/****************************************************************************************************************************************
* Class Name  : PMP_GenerateDQReportBatchSchedulerTest 
* Version     : 1.0 
* Created Date: 22/08/2022 
* Modification Log :
*
* Developer                           Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Yashasvi Aggarwal                 22/08/2022                  Test class for PMP_GenerateDQReportBatchScheduler
*****************************************************************************************************************************************/
@isTest
public class PMP_GenerateDQReportBatchSchedulerTest {
 @isTest 
    static void executeTest(){
        Test.StartTest();
        PMP_GenerateDQReportBatchScheduler testsche = new PMP_GenerateDQReportBatchScheduler();
		String sch = '0 0 23 * * ?';
		system.schedule('Test PMP_GenerateDQReportBatchScheduler', sch, testsche );
        Test.stopTest();
    } 
}