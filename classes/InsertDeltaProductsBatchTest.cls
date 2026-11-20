@isTest
private class InsertDeltaProductsBatchTest {
	
    @isTest
    static void testProductInsertion() {
        String ipassLoadId = String.valueOf(DateTime.now().getTime());
        Product_Inbound_Staging__c pis1 = new Product_Inbound_Staging__c();
        pis1.level_1_epm_id__c = '873';
        pis1.level_1_epm_name__c = 'Processor';
        pis1.level_2_epm_id__c = '122139';
        pis1.level_2_epm_name__c = 'Intel® Core™ Processors';
        pis1.level_3_epm_id__c = '95545';
        pis1.level_3_epm_name__c = '7th Generation Intel® Core™ i3 Processors';
        pis1.level_4_epm_id__c = '97455';
        pis1.level_4_epm_name__c = 'Intel® Core™ i3-7100 Processor (3M Cache, 3.90 GHz)';
        pis1.level_5_epm_id__c = '97284';
        pis1.level_5_epm_name__c = 'Intel® Core™ i3-7100 Processor (3M Cache, 3.90 GHz) FC-LGA14C, Tray';
        pis1.Core_Hierarchy_ID__c = '43';
        pis1.Core_Hierarchy_Name__c = 'Valid Product Hierarchy';
        pis1.iPaaS_Load_ID__c = ipassLoadId;
        pis1.Core_Unique_ID__c = pis1.level_5_epm_id__c +';'+pis1.level_4_epm_id__c+';'+pis1.level_3_epm_id__c+';'+pis1.level_2_epm_id__c+';'+pis1.level_1_epm_id__c;
        
        Product_Inbound_Staging__c pis2 = new Product_Inbound_Staging__c();
        pis2.level_1_epm_id__c = '873';
        pis2.level_1_epm_name__c = 'Processor';
        pis2.level_2_epm_id__c = '122139';
        pis2.level_2_epm_name__c = 'Intel® Core™ Processors';
        pis2.level_3_epm_id__c = '95545';
        pis2.level_3_epm_name__c = '7th Generation Intel® Core™ i3 Processors';
        pis2.level_4_epm_id__c = '97131';
        pis2.level_4_epm_name__c = 'Intel® Core™ i3-7100E Processor (3M Cache, 2.90 GHz)';
        pis2.level_5_epm_id__c = '96809';
        pis2.level_5_epm_name__c = 'Intel® Core™ i3-7100E Processor (3M Cache, 2.90 GHz) FC-BGA14F, Tray';
        pis2.Core_Hierarchy_ID__c = '43';
        pis2.Core_Hierarchy_Name__c = 'Valid Product Hierarchy';
        pis2.iPaaS_Load_ID__c = ipassLoadId;
        pis2.Core_Unique_ID__c = pis2.level_5_epm_id__c +';'+pis2.level_4_epm_id__c+';'+pis2.level_3_epm_id__c+';'+pis2.level_2_epm_id__c+';'+pis2.level_1_epm_id__c;
        
        List<Product_Inbound_Staging__c> listPis = new List<Product_Inbound_Staging__c>{pis1, pis2};
		        
		Test.startTest();
		Database.executeBatch(new InsertDeltaProductsBatch(listPis, ipassLoadId));      
        Test.stopTest();
        Assert.areEqual([Select Id From Product_Inbound_Staging__c].size(), 2, 'Product Inbound Staging record has not created successfully');
    }
}