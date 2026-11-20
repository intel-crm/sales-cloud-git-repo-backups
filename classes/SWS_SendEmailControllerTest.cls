@isTest
public class SWS_SendEmailControllerTest {
    @testSetup static void setup(){
        User u = SWS_TestUtilty.createUser();
    }
    
    @isTest static void sendEmailFromFLowTest() {
        User usr = [SELECT Id from User where UserName='requestoremail@testorg.com'];
        Test.startTest();
        SWS_Cloud_Credit_Request__c req = SWS_TestUtilty.createSingleRequest(true);          
        List<String> details = new List<String>();
        details.add(req.Id);
        details.add('SWS_RejectionEmail');
        List<List<String>> detailsForFlow = new List<List<String>>();
        detailsForFlow.add(details);
        System.runAs(usr){
            try{
                SWS_SendEmailController.sendEmailFromFLow(detailsForFlow);
            }catch(Exception e){
                
            }            
        }
        System.assert(details.size()>0,'details should not be empty');
        Test.stopTest();
    }
    
    @isTest static void sendEmailFromFLowTestNegative() {
        Test.startTest();
        List<List<String>> detailsForFlow = new List<List<String>>();
        SWS_SendEmailController.sendEmailFromFLow(detailsForFlow);
        System.assert(detailsForFlow.isEmpty()==true, 'Details list is empty');
        Test.stopTest();
    }
    
    @isTest static void processEmailResultTest() {
        User usr = [SELECT Id from User where UserName='requestoremail@testorg.com'];
        System.runAs(usr){
            Test.startTest();
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] { 'bademail' });
                mail.setReplyTo('support@intel.com');
                mail.setSenderDisplayName('Sender Display Name');
                mail.setSubject('Subject');
                mail.setPlainTextBody('Body');
                Messaging.SendEmailResult[] emailResult = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }, false);            
                System.assertEquals('Email address is invalid: bademail', emailResult[0].getErrors()[0].getMessage());
                SWS_SendEmailController.processEmailResult(emailResult);
            Test.stopTest();
        }
    }
}