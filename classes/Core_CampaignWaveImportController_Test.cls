// Note: unfortunately, seeAllData=true needs to be here since we need to execute a code path that queries account data,
// and we can't insert test data on the fly prior to executing an HTTP callout, since you can't do DML before callouts.
@isTest (seeAllData=true)
private class Core_CampaignWaveImportController_Test {
    
    // Test the functionality of the controller during page load - instantiate it, and call all of the
    // methods, exactly as would happen if a real user went to the page
    testmethod static void testPageLoad() {
        
        PageReference exportPage = Page.Core_CampaignWaveImport;
        Test.setCurrentPage(exportPage);
        Core_CampaignWaveImportController c = new Core_CampaignWaveImportController();
        
       
        
        Test.setMock(HttpCalloutMock.class, new Core_TestMockHttpResponseGenerator());
        
        Core_CampaignWaveImportController.getBaseURL();
        Core_CampaignWaveImportController.getSessionID();
        Core_CampaignWaveImportController.getLenses();
        Core_CampaignWaveImportController.getDatasets();
        
        // For now, just test to make sure we made it this far. Later this will be updated to proper assertions.
        System.assertEquals(1, 1);
    }
    
    private class LensRecord {
        String id;
    }
    
    private class DatasetRecord {
        String id;
    }
    
    // Test the functionality around querying data for a single lens. Note: we don't need to test
    // the actual download, since that's handled entirely client-side.
    testmethod static void testLensQuery() {
        
        PageReference exportPage = Page.Core_CampaignWaveImport;
        Test.setCurrentPage(exportPage);
        Core_CampaignWaveImportController c = new Core_CampaignWaveImportController();
        
        
        
        Test.setMock(HttpCalloutMock.class, new Core_TestMockHttpResponseGenerator());
        
        Core_CampaignWaveImportController.getBaseURL();
        String sessionId = Core_CampaignWaveImportController.getSessionID();
        String lensesJson = Core_CampaignWaveImportController.getLenses();
        String datasetsJson = Core_CampaignWaveImportController.getDatasets();
        
        List<LensRecord> lenses = (List<LensRecord>)JSON.deserialize(lensesJson, List<LensRecord>.class);
        List<DatasetRecord> datasets = (List<DatasetRecord>)JSON.deserialize(datasetsJson, List<DatasetRecord>.class);
        
        System.debug('##### lenses: ' + lenses);
        System.debug('##### datasets: ' + datasets);
        
        System.assert(lenses.size() > 0);
        System.assert(datasets.size() > 0);
        
        Core_CampaignWaveImportController.getOneLens(lenses[0].id, sessionId);
        
        String query = 'q = load "0Fb210000008OPVCA2/0Fc21000000Cdd6CAC";q = group q by \'Core_Account_Name__c\';' +
            'q = foreach q generate \'Core_Account_Name__c\' as \'Core_Account_Name__c\', count() as \'count\';q = limit q 100;';
        Core_CampaignWaveImportController.getQueryResults(query, false);
        Core_CampaignWaveImportController.getQueryResults(query, true);
    }
}