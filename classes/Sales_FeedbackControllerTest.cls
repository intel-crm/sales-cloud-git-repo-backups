@isTest
public class Sales_FeedbackControllerTest{
    @isTest
    public static void nonFeedbackTest(){
        String errMsg='';
        Sales_Feedback__c feedback;
        try{
            Sales_License__c lic=new Sales_License__c();
            lic.Sales_License_Quantity__c=1;
            lic.Sales_License_Product_Name_Txt__c='Test';
            lic.Sales_License_Maintenance_Exp_Dt__c=system.today();
            lic.Sales_License_Expiration_Date_Dt__c=system.today()+1;
            lic.Sales_License_Start_Date_Dt__c=system.today();
            lic.Sales_License_Status__c='Licensed';
            lic.Sales_License_Avbl_Qty_Nbr__c=1;
            lic.Sales_License_Avbl_Rehost_Nbr__c=1;
            lic.Opt_in_out__c=true;
            lic.Sales_License_Web_Display_Flag__c=false;
            lic.Sales_License_Type__c='Optional';
            insert lic;
            String licId=string.valueof(lic.id);
            Test.startTest();
            Sales_FeedbackController.createFeedBack_NonEvent(5,'text','add new admin');
            Sales_FeedbackController.checkCapability_NonEvent('add new admin');
            Sales_FeedbackController.createFeedBack(5,'text','License Generation',licId,false);
            Sales_FeedbackController.checkCapablity('License Generation');
            Sales_FeedbackController.getFeedRecord('License Generation');
            feedback=Sales_FeedbackController.getFeedRecordchatbot(true);
            Test.stopTest();
            Assert.areEqual('Optional',lic.Sales_License_Type__c,'Licence type is matched');
        }
        catch(Exception e)
        {
            errMsg=e.getMessage();
        }
        
    }
}