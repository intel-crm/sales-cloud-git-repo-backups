@isTest
public class Core_MAGQuestionnaireController_Test {
    
    static testMethod void testMAGQuestionnaire_Controller() {
        
        //public String convertedLastModifiedDate;
        // Pages, controller, and parameter map we'll use for testing
        PageReference magPage = Page.Core_MAGQuestionnaire;
        PageReference nextPage = null;
        Core_MAGQuestionnaireController magController;
        
         Account acct = new Account(Name = 'Test Account 03-25-2015', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                   BillingPostalCode = '12345', Core_CIM_ID__c = '8675309',Core_Sales_Groups__c='DCG Sales Group');
         insert acct;
        // Set up a test opportunity that we'll use
        Opportunity opp;
        opp = Core_Test_Utility.createOpportunity(1)[0];
        opp.AccountId=acct.id;
        insert opp;
        
        Test.startTest();
        
        // Test with no MAG questionnaire data, to ensure non-null is returned (since a redirect happens)
        Test.setCurrentPage(magPage);
        ApexPages.currentPage().getParameters().put('OpportunityId', opp.Id);
        Core_MAG_Questionnaire__c mag = new Core_MAG_Questionnaire__c();
        magController = new Core_MAGQuestionnaireController(new ApexPages.StandardController(mag));
        nextPage = magController.init();
        System.assertNotEquals(null, nextPage);
        
        mag = [select Id,CreatedDate,LastModifiedDate, Core_Opportunity__c, Core_Number_of_Questions__c, Core_GEC_Comments__c, Core_Opportunity__r.Core_Compliance_Status__c
               from Core_MAG_Questionnaire__c where Core_Opportunity__c = :opp.Id];
        
        // Test with MAG questionnaire data
        magPage = nextPage;
        Test.setCurrentPage(magPage);
        magController = new Core_MAGQuestionnaireController(new ApexPages.StandardController(mag));
        nextPage = magController.init();
        System.assertEquals(null, nextPage);
        
        nextPage = magController.save();
       // System.assert(nextPage.getUrl().contains(opp.Id));
        
        nextPage = magController.cancel();
        System.assert(nextPage.getUrl().contains(opp.Id));
        
        nextPage = magController.goToOpportunity();
        System.assert(nextPage.getUrl().contains(opp.Id));
        
        String Converteddate=magController.convertedCreatedDate;
        mag.Core_GEC_Comments__c='Test';
        update mag;
                String ConvertLastModifiedDate=magController.convertedLastModifiedDate;
        magController.isLocked=true;
        magController.isApprovedGuardrails=true;

        
    }
     static testMethod void testMAGQuestionnaire_Controller1() {
        
        //public String convertedLastModifiedDate;
        // Pages, controller, and parameter map we'll use for testing
        PageReference magPage = Page.Core_MAGQuestionnaire;
        PageReference nextPage = null;
        Core_MAGQuestionnaireController magController;
        
         Account acct = new Account(Name = 'Test Account 03-25-2015', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                   BillingPostalCode = '12345', Core_CIM_ID__c = '8675309',Core_Sales_Groups__c='DCG Sales Group');
         insert acct;
        // Set up a test opportunity that we'll use
        Opportunity opp;
        opp = Core_Test_Utility.createOpportunity(1)[0];
        opp.Core_Military_Aerospace_Govmt_End_Use__c='No';
        opp.AccountId=acct.id;
        insert opp;
        
        Test.startTest();
        
        // Test with no MAG questionnaire data, to ensure non-null is returned (since a redirect happens)
        Test.setCurrentPage(magPage);
        ApexPages.currentPage().getParameters().put('OpportunityId', opp.Id);
        Core_MAG_Questionnaire__c mag = new Core_MAG_Questionnaire__c();
        magController = new Core_MAGQuestionnaireController(new ApexPages.StandardController(mag));
        nextPage = magController.init();
        System.assertNotEquals(null, nextPage);
        
        mag = [select Id,CreatedDate,LastModifiedDate, Core_Opportunity__c, Core_Number_of_Questions__c, Core_GEC_Comments__c, Core_Opportunity__r.Core_Compliance_Status__c
               from Core_MAG_Questionnaire__c where Core_Opportunity__c = :opp.Id];
        
        // Test with MAG questionnaire data
        magPage = nextPage;
        Test.setCurrentPage(magPage);
        magController = new Core_MAGQuestionnaireController(new ApexPages.StandardController(mag));
        nextPage = magController.init();
        System.assertEquals(null, nextPage);
        
        nextPage = magController.save();
        //System.assert(nextPage.getUrl().contains(opp.Id));
        
        nextPage = magController.cancel();
        System.assert(nextPage.getUrl().contains(opp.Id));
        
        nextPage = magController.goToOpportunity();
        System.assert(nextPage.getUrl().contains(opp.Id));
        
                      
        String ConvertLastModifiedDate=magController.convertedLastModifiedDate;
        magController.isLocked=true;
        magController.isApprovedGuardrails=true;

        
    }
}