@isTest
public class Core_IPS_BatchScheduleMilestone_test{  

    public static testmethod void  testschedule() 
    {

     Test.StartTest();
     Core_IPS_BatchScheduleMilestoneUpdate sh1 = new Core_IPS_BatchScheduleMilestoneUpdate();      
     String sch = '0 0 23 * * ?';
     system.schedule('Test check', sch, sh1);
    Test.stopTest();
    }
 }