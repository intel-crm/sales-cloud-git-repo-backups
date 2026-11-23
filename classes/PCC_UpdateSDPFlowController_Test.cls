@isTest
private class PCC_UpdateSDPFlowController_Test {
    @TestSetup
    static void createRecordsUsingCoreDdrDesignHandlerTestPattern() {
        List<Core_Design_Registration__c> designRegistrations = Core_DDR_Utility.createDDR(1);
        designRegistrations[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
        insert designRegistrations;

        List<Product2> products = Core_DDR_Utility.CreateProduct(1);
        products[0].Name = 'PCC SDP Test Product';
        insert products;

        List<Core_Design_Registration_Product__c> designRegistrationProducts = Core_DDR_Utility.CreateDRProduct(4, designRegistrations, products);
        designRegistrationProducts[1].PCC_Standard_Distributor_Price__c = 0;
        designRegistrationProducts[2].PCC_Standard_Distributor_Price__c = 15;
        designRegistrationProducts[3].Core_Design_Product_Status_Nm__c = 'Approved';
        insert designRegistrationProducts;
    }

    @isTest
    static void bulkUpdateDRPRecordsUpdatesEligiblePendingRecordsAndDeduplicates() {
        List<Core_Design_Registration_Product__c> eligibleProducts = [
            SELECT Id, Core_Design_Product_Status_Nm__c, PCC_Standard_Distributor_Price__c
            FROM Core_Design_Registration_Product__c
            WHERE Core_Design_Product_Status_Nm__c = 'Pending' AND (PCC_Standard_Distributor_Price__c = NULL OR PCC_Standard_Distributor_Price__c = 0)
            ORDER BY CreatedDate ASC
        ];
        Core_Design_Registration_Product__c alreadyPricedProduct = [
            SELECT Id, Core_Design_Product_Status_Nm__c, PCC_Standard_Distributor_Price__c
            FROM Core_Design_Registration_Product__c
            WHERE PCC_Standard_Distributor_Price__c = 15
            LIMIT 1
        ];
        Core_Design_Registration_Product__c approvedProduct = [
            SELECT Id, Core_Design_Product_Status_Nm__c, PCC_Standard_Distributor_Price__c
            FROM Core_Design_Registration_Product__c
            WHERE Core_Design_Product_Status_Nm__c = 'Approved'
            LIMIT 1
        ];

        PCC_UpdateSDPFlowController.BulkUpdateRequest firstRequest = new PCC_UpdateSDPFlowController.BulkUpdateRequest();
        firstRequest.standardDistiPrice = 123.45;
        firstRequest.drpRecords = new List<Core_Design_Registration_Product__c>{ eligibleProducts[0], eligibleProducts[0], alreadyPricedProduct };

        PCC_UpdateSDPFlowController.BulkUpdateRequest secondRequest = new PCC_UpdateSDPFlowController.BulkUpdateRequest();
        secondRequest.standardDistiPrice = 234.56;
        secondRequest.drpRecords = new List<Core_Design_Registration_Product__c>{ eligibleProducts[1], approvedProduct };

        PCC_UpdateSDPFlowController.BulkUpdateRequest nullCollectionRequest = new PCC_UpdateSDPFlowController.BulkUpdateRequest();
        nullCollectionRequest.standardDistiPrice = 345.67;

        Test.startTest();
        List<PCC_UpdateSDPFlowController.BulkUpdateResponse> responses = PCC_UpdateSDPFlowController.bulkUpdateDRPRecords(
            new List<PCC_UpdateSDPFlowController.BulkUpdateRequest>{ firstRequest, secondRequest, nullCollectionRequest }
        );
        Test.stopTest();

        System.assertEquals(3, responses.size(), 'Each flow request should receive a response.');
        System.assertEquals(1, responses[0].successCount, 'Duplicate DRP ids should only count once in the same response.');
        System.assertEquals(0, responses[0].errorCount, 'The eligible DRP in the first request should update successfully.');
        System.assertEquals(1, responses[0].successIds.size(), 'Only the eligible DRP should be reported as successful.');
        System.assertEquals(1, responses[1].successCount, 'The second eligible pending DRP should update successfully.');
        System.assertEquals(0, responses[1].errorCount, 'Skipped rows should not be reported as errors.');
        System.assertEquals(0, responses[2].successCount, 'A null DRP collection should be handled without updates.');
        System.assertEquals(0, responses[2].errorCount, 'A null DRP collection should be handled without errors.');

        Map<Id, Core_Design_Registration_Product__c> refreshedProducts = new Map<Id, Core_Design_Registration_Product__c>([
            SELECT Id, PCC_Standard_Distributor_Price__c
            FROM Core_Design_Registration_Product__c
            WHERE Id IN :new Set<Id>{ eligibleProducts[0].Id, eligibleProducts[1].Id, alreadyPricedProduct.Id, approvedProduct.Id }
        ]);
        System.assertEquals(123.45, refreshedProducts.get(eligibleProducts[0].Id).PCC_Standard_Distributor_Price__c);
        System.assertEquals(234.56, refreshedProducts.get(eligibleProducts[1].Id).PCC_Standard_Distributor_Price__c);
        System.assertEquals(15, refreshedProducts.get(alreadyPricedProduct.Id).PCC_Standard_Distributor_Price__c);
        System.assertEquals(null, refreshedProducts.get(approvedProduct.Id).PCC_Standard_Distributor_Price__c);
    }

    @isTest
    static void bulkUpdateDRPRecordsReturnsNoResponsesForEmptyInput() {
        Test.startTest();
        List<PCC_UpdateSDPFlowController.BulkUpdateResponse> responses = PCC_UpdateSDPFlowController.bulkUpdateDRPRecords(
            new List<PCC_UpdateSDPFlowController.BulkUpdateRequest>()
        );
        Test.stopTest();

        System.assertEquals(0, responses.size(), 'No input requests should produce no responses.');
    }
}