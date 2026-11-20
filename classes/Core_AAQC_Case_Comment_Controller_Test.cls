@isTest
private class Core_AAQC_Case_Comment_Controller_Test {

    @testSetup static void setup() {
        
        // Create common test cases
        Case c= new Case();
        c.Origin = 'My Origin';
        c.Subject= 'Ask commision case subject';
        c.Core_AAQC_Commissions_Severity__c='test';
        c.status='Draft';
        insert c; 
        System.assert(c.Id != null, 'Case Record not created');
        
        // Create common Commission case
        Core_AAQC_Commissions_Case__c com =new Core_AAQC_Commissions_Case__c ();
        com.Core_AAQC_Case__c=c.id;
        insert com;
        System.assert(com.Id != null, 'Case Inquiry Record not created');     
    }
    
    public static testMethod void caseCommentEdit()
    {
        
        Core_AAQC_Commissions_Case__c com =[SELECT Id FROM Core_AAQC_Commissions_Case__c LIMIT 1];
        
        Core_AAQC_Case_Comments__c caseComment = new Core_AAQC_Case_Comments__c();
        caseComment.Core_AAQC_Comment__c ='test123';
        caseComment.Core_AAQC_Commissions_Case__c = com.Id;
        insert caseComment;
        System.assert(caseComment.Id != null, 'Case Comment Record not created');
        
        Test.StartTest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(caseComment);
        Core_AAQC_Case_Comment_Controller caseCommentController = new Core_AAQC_Case_Comment_Controller(sc);
        PageReference pageRef = Page.Core_AAQC_Case_Comment;
        pageRef.getParameters().put('id', String.valueOf(caseComment.Id));
        Test.setCurrentPage(pageRef);
        
        case expectedCaseResult =[select id,status from case];
        expectedCaseResult.status ='New';
        update expectedCaseResult;

        PageReference page=caseCommentController.save();
        
        PageReference expectedPage  = new PageReference('/apex/Core_AAQC_Commissions_Inquiry_Details?id='+com.Id);
        System.assertEquals(expectedPage.getUrl(), Page.getUrl());
        
        
        Test.StopTest();
        

     }
    public static testMethod void caseCommentNew()
    {
        
        Core_AAQC_Commissions_Case__c com =[SELECT Id FROM Core_AAQC_Commissions_Case__c LIMIT 1];
        
        Core_AAQC_Case_Comments__c caseComment = new Core_AAQC_Case_Comments__c();
        caseComment.Core_AAQC_Comment__c ='test123';
        
        Test.StartTest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(caseComment);
        Core_AAQC_Case_Comment_Controller caseCommentController = new Core_AAQC_Case_Comment_Controller(sc);
        PageReference pageRef = Page.Core_AAQC_Case_Comment;
        pageRef.getParameters().put('id', String.valueOf(caseComment.Id));
        Test.setCurrentPage(pageRef);
        
        caseCommentController.save();
        caseComment.Core_AAQC_Commissions_Case__c = com.Id;
        insert caseComment;
        
        Test.StopTest();
    }
    
}