@isTest
public class PMP_ScheduleThumbnailGenerator_Test {
    public static testMethod void testschedule() {
        Test.StartTest();
        PMP_ScheduleThumbnailGenerator testschedule = new PMP_ScheduleThumbnailGenerator();
        System.schedule('PMP_ScheduleThumbnailGenerator', '0 57 * * * ?', testschedule);
        Test.stopTest();
    }
}