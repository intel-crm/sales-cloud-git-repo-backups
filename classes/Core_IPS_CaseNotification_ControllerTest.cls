@istest
public class Core_IPS_CaseNotification_ControllerTest
{
    static testMethod void Core_IPS_CaseNotification_ControllerTestMetod1()
    {
       case c =  new case();
       c.status = 'New';
       insert c  ;
       
       
         List<Core_IPS_Labels__c> LstLabels = TestUtilities.getIPSLabel();
         insert LstLabels;
         PageReference PageRef = Page.Core_IPS_Case_Creation_Notification;
         Test.setCurrentPage(PageRef);
         ApexPages.currentPage().getParameters().put('id', c.id);
        
      ApexPages.StandardController caseController = new ApexPages.StandardController(c);
      Core_IPS_CaseNotification_Controller CaseNoti =  new Core_IPS_CaseNotification_Controller(caseController);

       
    }
}