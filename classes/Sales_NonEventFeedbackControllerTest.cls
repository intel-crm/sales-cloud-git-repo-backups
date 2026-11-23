@isTest
public class Sales_NonEventFeedbackControllerTest{
@isTest
    public static void nonFeedbackTest(){
   String errMsg='';
    try{
     Test.startTest();
     Sales_NonEventFeedbackController.createFeedBack_NonEvent(5,'text','create-new-admin');
     Sales_NonEventFeedbackController.checkCapability('create-new-admin');
     Test.stopTest();
    }
    catch(Exception e)
    {
        System.debug('Error msg -->'+e.getMessage());
        errMsg=e.getMessage();
     } 
    System.assert(errMsg=='', errMsg);

}}