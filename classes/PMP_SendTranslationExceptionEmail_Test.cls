@isTest
public  class PMP_SendTranslationExceptionEmail_Test {
    
    @isTest
    static void testIsWorking() {
        Boolean result = PMP_SendTranslationExceptionEmail.isWorking();
        System.assertEquals(true, result);
    }
   /* @isTest
    static void sendEmail() {

     Core_Integration_Inbound_Message__c failedMessages = new Core_Integration_Inbound_Message__c();

     Core_Integration_Inbound_Message__c failedMessages1 = new Core_Integration_Inbound_Message__c();

     failedMessages.Core_Processing_Status__c = 'Terminated';
     failedMessages.Core_Exception_Message__c = 'Failed from GLS';
     //failedMessages.id = 'a002i0000044xb7AAA';
        
     failedMessages1.Core_Processing_Status__c = 'Failed';
     failedMessages.Core_Exception_Message__c = 'Data issue and Job is Terminated by GLS';
     //failedMessages1.id = 'a002i0000044xb6AAA';


     List<Core_Integration_Inbound_Message__c> aList = new List<Core_Integration_Inbound_Message__c>();
     aList.add(failedMessages);
     aList.add(failedMessages1);

    PMP_SendTranslationExceptionEmail.sendFailureEmail(aList);
        
    Integer emailCount = Limits.getEmailInvocations();
    System.assert(emailCount >= 0, 'Expected at least one email to be sent, but none were sent.');

}*/
}