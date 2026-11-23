@isTest
public class PMP_PublishFutureUpdateScheduler_Test {
    @isTest
    static void testIsWorking() {
        Boolean result = PMP_PublishFutureUpdateScheduler.isWorking();
        System.assertEquals(true, result);
    }
//IPA2.0 - As part of TWC729-7977 commented the entire class
/*
 @isTest 
    static void executeTest(){
        SchedulableContext  sc = null;
        PMP_PublishFutureUpdateScheduler obj = new PMP_PublishFutureUpdateScheduler();
        obj.execute(sc);
    } 
*/
}