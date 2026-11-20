@isTest
private class Core_AAQC_Case_Close_Onemail_test {
    
    @testSetup static void setup() {
        
            // Create common test cases
            Case c= new Case();
            c.Origin = 'My Origin';
            c.status ='Draft';
            c.Subject= 'Ask commision case subject';
            c.Core_AAQC_Commissions_Severity__c='test';
            c.Core_AAQC_Resolution_Type__c ='Training';
            insert c; 
            System.assert(c.Id != null, 'Case Record not created');
            
            // Create common Commission case
            Core_AAQC_Commissions_Case__c com =new Core_AAQC_Commissions_Case__c ();
            com.Core_AAQC_Case__c=c.id;
            insert com;
            System.assert(com.Id != null, 'Case Inquiry Record not created');
            
            
            Core_AAQC_Case_Comments__c caseComment = new Core_AAQC_Case_Comments__c();
            caseComment.Core_AAQC_Comment__c ='test123';
            caseComment.Core_AAQC_Commissions_Case__c = com.Id;
            insert caseComment;
            System.assert(caseComment.Id != null, 'Case Comment Record not created');
            
    }
    
    // Scenario.1 If some one click on 'case close' link then below code will execute
    public static testMethod void caseCloseOnemail_RedirectYes()
    {
            setup();
            case c =[SELECT Id FROM case LIMIT 1];
            Core_AAQC_Commissions_Case__c comInquiry = [SELECT Id FROM Core_AAQC_Commissions_Case__c LIMIT 1];
            Test.StartTest();
            Test.setCurrentPage(Page.Core_AAQC_Case_Close_Onemail);
            ApexPages.currentPage().getParameters().put('Caseid', String.valueOf(c.Id));
            ApexPages.StandardController sc = new ApexPages.StandardController(c);
            Core_AAQC_Case_Close_Onemail caseCloseOnemail = new Core_AAQC_Case_Close_Onemail(sc);
            
            caseCloseOnemail.redirectYes();
            
            List<case> expectedCaseResult =[select id,status from case];
            System.AssertEquals('Closed',expectedCaseResult[0].status);
            
            List<Core_AAQC_Commissions_Case__c> expectedcomInquiry =[select id from Core_AAQC_Commissions_Case__c];
            system.debug('====='+expectedcomInquiry);
            
            PageReference page=caseCloseOnemail.redirectNo();
            //PageReference expectedPage  = new PageReference('/apex/Core_IPS_ViewCase?id='+expectedCaseResult[0].Id+'&message=ClosedNo&referer=CaseCloseOnEmail');
            //Core_AAQC_Commissions_Inquiry_Details
            PageReference expectedPage  = new PageReference('/apex/Core_AAQC_Commissions_Inquiry_Details?id='+expectedcomInquiry[0].Id+'&message=ClosedNo&referer=CaseCloseOnEmail');
            System.assertEquals(expectedPage.getUrl(), Page.getUrl());

            Test.StopTest();

     }
      // Scenario.2 If some one directly click on View button of page 
      
     public static testMethod void caseCloseOnemail_PagereferenceNull()
    {
            setup();
            case c =[SELECT Id FROM case LIMIT 1];
            
            Test.StartTest();
            
            ApexPages.currentPage().getParameters().put('Caseid', String.valueOf(c.Id));
            Test.setCurrentPage(Page.Core_AAQC_Case_Close_Onemail);
            ApexPages.StandardController sc = new ApexPages.StandardController(c);
            Core_AAQC_Case_Close_Onemail caseCloseOnemail = new Core_AAQC_Case_Close_Onemail(sc);
            caseCloseOnemail.redirectYes();
            
            List<case> expectedCaseResult =[select id,status from case];
            System.AssertEquals(null,null);
            
            
            PageReference page=caseCloseOnemail.redirectNo();
            //PageReference expectedPage  = new PageReference('/apex/Core_IPS_ViewCase?id='+expectedCaseResult[0].Id);
            //Core_AAQC_Commissions_Inquiry_Details
            PageReference expectedPage  = new PageReference('/apex/Core_AAQC_Commissions_Inquiry_Details?id='+expectedCaseResult[0].Id);
            System.assertEquals(null, null);
           
            Test.StopTest();

     }
}