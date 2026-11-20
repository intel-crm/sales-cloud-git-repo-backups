@isTest
public class espy_ApexJobsEmail_Test {
    
    @isTest
    static void testSendJobsEmail(){
        Test.startTest();
        espy_ApexJobsEmail.sendJobsEmail();
        Integer sentEmailCount = Limits.getEmailInvocations();
        Test.stopTest();
        System.assertEquals(1,sentEmailCount,'Only one email should be sent.');
    }
}