@isTest
public class Core_MAGQuestionnaireController_Test {
    
    static testMethod void testMAGQuestionnaire_Controller() {
        
        // Pages, controller, and parameter map we'll use for testing
        PageReference magPage = Page.Core_MAGQuestionnaire;
        PageReference nextPage = null;
        Core_MAGQuestionnaireController magController;
        
        // Set up a test opportunity that we'll use
        Opportunity opp;
        opp = Core_Test_Utility.createOpportunity(1)[0];
        insert opp;
        
        Test.startTest();
        
        // Test with no MAG questionnaire data, to ensure non-null is returned (since a redirect happens)
        Test.setCurrentPage(magPage);
        ApexPages.currentPage().getParameters().put('OpportunityId', opp.Id);
        Core_MAG_Questionnaire__c mag = new Core_MAG_Questionnaire__c();
        magController = new Core_MAGQuestionnaireController(new ApexPages.StandardController(mag));
        nextPage = magController.init();
        System.assertNotEquals(null, nextPage);
        
        mag = [select Id, Core_Opportunity__c, Core_Number_of_Questions__c, Core_GEC_Comments__c, Core_Opportunity__r.Core_Compliance_Status__c
               from Core_MAG_Questionnaire__c where Core_Opportunity__c = :opp.Id];
        
        // Test with MAG questionnaire data
        magPage = nextPage;
        Test.setCurrentPage(magPage);
        magController = new Core_MAGQuestionnaireController(new ApexPages.StandardController(mag));
        nextPage = magController.init();
        System.assertEquals(null, nextPage);
        
        nextPage = magController.save();
        System.assert(nextPage.getUrl().contains(opp.Id));
        
        nextPage = magController.cancel();
        System.assert(nextPage.getUrl().contains(opp.Id));
        
        nextPage = magController.goToOpportunity();
        System.assert(nextPage.getUrl().contains(opp.Id));
        
        Test.stopTest();
    }
}