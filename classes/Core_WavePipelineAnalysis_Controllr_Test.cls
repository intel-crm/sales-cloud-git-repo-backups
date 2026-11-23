@isTest
public class Core_WavePipelineAnalysis_Controllr_Test {

    static testMethod void testPage() {
        
        PageReference dashboardPage = Page.Core_WavePipelineAnalysis;
        Test.setCurrentPage(dashboardPage);
        Core_WavePipelineAnalysis_Controller dashboardController = new Core_WavePipelineAnalysis_Controller();
        dashboardController.init();
        
        System.assertEquals(1, [select count() from Core_Wave_Dashboard_View__c]);
        
    }
    static testMethod void testPage1() {
        
        PageReference dashboardPage = Page.Core_WavePipelineManagement;
        Test.setCurrentPage(dashboardPage);
        Core_WavePipelineAnalysis_Controller dashboardController = new Core_WavePipelineAnalysis_Controller();
        dashboardController.init();
        
    }    
}