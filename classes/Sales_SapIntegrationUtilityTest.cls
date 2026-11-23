@isTest
private class Sales_SapIntegrationUtilityTest {
/*
    private static final String SCRIPT_THROWN_EXCEPTION = 'Script-thrown exception';
    @testSetup static void testData(){
        List<Sales_License_Generator__c> licGenerator = Sales_TestFactory_Utility.createLiceneseGenerator();
        List<Sales_License_Group__c> liceneGroupRec= Sales_TestFactory_Utility.createLiceneseGroup(licGenerator[0].Id);
        Core_Product_Ext_Attribute__c l = new Core_Product_Ext_Attribute__c();
        l.Core_SW_Lic_Enforcement_Method_Nm__c = 'File';
        l.Core_Prod_Tool_Type_Nm__c = 'BASE';
        l.Core_SW_Lic_Type_Nm__c = 'FIXED' ; 
        l.Core_SW_Prod_Max_Rehost_Cnt__c = 1;
        l.Core_SW_Lic_File_Data_Encryption_Std_Cd__c = '1DES' ;
        l.Core_SW_Prod_Avail_To_TL_ORD_ENBLMT_Ind__c = true;
        l.Core_SW_Lic_Group_Id__c = liceneGroupRec[0].Id;
        l.Core_SW_Lic_Generator_Parameter_Txt__c = 'testing';
        insert l;
        Product2 p1 =new Product2();
        p1.Name = ' Test Product ';
        p1.Description='Test Product Entry 1';
        p1.productCode = 'ABC';
        p1.isActive = true;
        p1.Core_Item_Class_Nm__c='SV';
        p1.Core_Product_Ext_Attribute_Id__c = l.Id;
        p1.Core_Item_Orderable_Ind__c =true;
        p1.Core_Item_Quotable_Ind__c=true;
        insert p1;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pricebookentry =Sales_TestFactory_Utility.createPriceBookEntry(p1.Id,pricebookId);
        insert new PRM_Execution_Controls__c(SetupOwnerId=UserInfo.getOrganizationId(), Skip_ValidationRule_Order_Status__c=true);
    }
    @isTest static void testErrorSubmitOrderInSap() {
        Test.setMock(HttpCalloutMock.class, new Sales_SapIntegrationUtilityCalloutMock(200,'Failure')); 
        Id accShipToId = [Select id from Account Limit 1]?.Id;
        Id pricebookId = Test.getStandardPricebookId();
        Id productId = [Select Id from product2 Limit 1].Id;
        Id pricebookentryId = [Select id from PricebookEntry Limit 1].Id;
        String exceptionMsg='';
        try{
            Order orderRec=Sales_TestFactory_Utility.createOrders(accShipToId,pricebookId,'Licensed Tool Order');  
            Test.startTest();
            List<OrderItem> orderProduct =Sales_TestFactory_Utility.createOrderProductList(orderRec.Id,productId,pricebookentryId);
            Test.stopTest();
            Id orderRecId=orderRec.Id;
            List<String> orderRecIdList=new List<String>();
            orderRecIdList.add(orderRecId);
            Sales_SapIntegrationUtility.updateSapOrderStatus(orderRecIdList);
        }
        catch(Exception e){
            exceptionMsg=e.getMessage();
        }
        Order o=[Select Id,Sales_status__c from Order limit 1];
    }
    @isTest static void testSuccessSubmitOrderInSap() {
        Test.setMock(HttpCalloutMock.class, new Sales_SapIntegrationUtilityCalloutMock(200,'Success')); 
        Id accShipToId = [Select id from Account Limit 1]?.Id;
        Id pricebookId = Test.getStandardPricebookId();
        Id productId = [Select Id from product2 Limit 1].Id;
        Id pricebookentryId = [Select id from PricebookEntry Limit 1].Id;
        Order orderRec=Sales_TestFactory_Utility.createOrders(accShipToId,pricebookId,'Licensed Tool Order');  
        Test.startTest();
        List<OrderItem> orderProduct =Sales_TestFactory_Utility.createOrderProductList(orderRec.Id,productId,pricebookentryId);
        Test.stopTest();
        Id orderRecId=orderRec.Id;
        List<String> orderRecIdList=new List<String>();
        orderRecIdList.add(orderRecId);
        String exceptionMsg='';
        try{
            Sales_SapIntegrationUtility.updateSapOrderStatus(orderRecIdList);
        }
        catch(Exception e){
            exceptionMsg=e.getMessage();
        }
        Order o=[Select Id,Sales_status__c,Status from Order limit 1];
    }
    @isTest static void testExceptionSubmitOrderInSap() {
        Test.setMock(HttpCalloutMock.class, new Sales_SapIntegrationUtilityCalloutMock(401,'Failure')); 
        Id accShipToId = [Select id from Account Limit 1]?.Id;
        Id pricebookId = Test.getStandardPricebookId();
        Id productId = [Select Id from product2 Limit 1].Id;
        Id pricebookentryId = [Select id from PricebookEntry Limit 1].Id;
        Order orderRec=Sales_TestFactory_Utility.createOrders(accShipToId,pricebookId,'Licensed Tool Order');  
        Test.startTest();
        List<OrderItem> orderProduct =Sales_TestFactory_Utility.createOrderProductList(orderRec.Id,productId,pricebookentryId);
        Test.stopTest();
        Id orderRecId=orderRec.Id;
        List<String> orderRecIdList=new List<String>();
        orderRecIdList.add(orderRecId);
        String exceptionMsg='';
        try{
            Sales_SapIntegrationUtility.updateSapOrderStatus(orderRecIdList);
        }
        catch(Exception e){
            exceptionMsg=e.getMessage();
        }
        Order o=[Select Id,Sales_Retry_Count__c from Order limit 1];
    }
    @isTest static void updateOrderStatusToFailureTest(){
        Test.setMock(HttpCalloutMock.class, new Sales_SapIntegrationUtilityCalloutMock(400,'Failure'));
        Id accShipToId = [Select id from Account Limit 1]?.Id;
        Id pricebookId = Test.getStandardPricebookId();
        Test.startTest();
        Order orderRec=Sales_TestFactory_Utility.createOrders(accShipToId,pricebookId,'Licensed Tool Order');  
        Sales_SapIntegrationUtility.updateOrderStatusToFailure(orderRec.Id,'Exception');
        Test.stopTest();
        orderRec=[Select Id,Sales_Retry_Count__c from Order limit 1];
    }
    static testmethod void testVerifiedOrders(){
        Test.startTest();
        Sales_TestFactory_Utility.createNonCommOrder();
        Id orderRecId=[Select Id from order limit 1].Id;
        List<String> orderRecIdList=new List<String>();
        orderRecIdList.add(orderRecId);
        String exceptionMsg='';
        try{
            Sales_SapIntegrationUtility.verifyOrder(orderRecIdList);
        }
        catch(Exception e){
            exceptionMsg=e.getMessage();
        }
        Test.stopTest();
        Order o=[Select Id,Sales_Is_Verified__c from Order limit 1];
        System.assert(!o.Sales_Is_Verified__c);
    }
    @isTest static void testResponseSubmitOrderInSap() {
        Test.setMock(HttpCalloutMock.class, new Sales_SapIntegrationUtilityCalloutMock(200,'Success')); 
        Id accShipToId = [Select id from Account Limit 1]?.Id;
        Id pricebookId = Test.getStandardPricebookId();
        Id productId = [Select Id from product2 Limit 1].Id;
        Id pricebookentryId = [Select id from PricebookEntry Limit 1].Id;
        Order orderRec=Sales_TestFactory_Utility.createOrders(accShipToId,pricebookId,'Licensed Tool Order');  
        Test.startTest();
        List<OrderItem> orderProduct =Sales_TestFactory_Utility.createOrderProductList(orderRec.Id,productId,pricebookentryId);
        Test.stopTest();
        List<String> orderList =new List<String>();
        orderList.add(orderRec.Id);
        String exceptionMsg='';
        try{
            Sales_SapIntegrationUtility.updateSapOrderStatus(orderList);
        }
        catch(Exception e){
            exceptionMsg=e.getMessage();
        }
        Order orderUpdated=[Select Id,Sales_Status__c from Order where Id=:orderRec.Id];
    }
    @isTest static void testResponseFromRetryBatch() {
        Test.setMock(HttpCalloutMock.class, new Sales_SapIntegrationUtilityCalloutMock(200,'Success')); 
        Id accShipToId = [Select id from Account Limit 1]?.Id;
        Id pricebookId = Test.getStandardPricebookId();
        Id productId = [Select Id from product2 Limit 1].Id;
        Id pricebookentryId = [Select id from PricebookEntry Limit 1].Id;
        Test.startTest();
        Order orderRec=Sales_TestFactory_Utility.createOrders(accShipToId,pricebookId,'Licensed Tool Order');  
        orderRec.Status='Draft';
        orderRec.Sales_status__c='SAP Resubmission In Progress';
        orderRec.Sales_Retry_Count__c=1;
        update orderRec;
        List<String> orderList =new List<String>();
        orderList.add(orderRec.Id);
        String exceptionMsg='';
        try{
            Sales_SapIntegrationUtility.retryFailedOrder();
        }
        catch(Exception e){
            exceptionMsg=e.getMessage();
        }
        Order orderUpdated=[Select Id,Sales_Status__c from Order where Id=:orderRec.Id];
        Test.stopTest();
    }
    @isTest static void testResponseFromRetryBatchFailure() {
        Test.setMock(HttpCalloutMock.class, new Sales_SapIntegrationUtilityCalloutMock(400,'Success')); 
        Id accShipToId = [Select id from Account Limit 1]?.Id;
        Id pricebookId = Test.getStandardPricebookId();
        Id productId = [Select Id from product2 Limit 1].Id;
        Id pricebookentryId = [Select id from PricebookEntry Limit 1].Id;
        Test.startTest();
        Order orderRec=Sales_TestFactory_Utility.createOrders(accShipToId,pricebookId,'Licensed Tool Order');  
        orderRec.Status='Draft';
        orderRec.Sales_status__c='SAP Resubmission In Progress';
        orderRec.Sales_Retry_Count__c=1;
        update orderRec;
        List<String> orderList =new List<String>();
        orderList.add(orderRec.Id);
        String exceptionMsg='';
        try{
            Sales_SapIntegrationUtility.retryFailedOrder();
        }
        catch(Exception e){
            exceptionMsg=e.getMessage();
        }
        Order orderUpdated=[Select Id,Sales_Status__c from Order where Id=:orderRec.Id];
        Test.stopTest();
    }
    @isTest static void testResponseFromRetryBatchFailureMessage() {
        Test.setMock(HttpCalloutMock.class, new Sales_SapIntegrationUtilityCalloutMock(200,'Failure')); 
        Id accShipToId = [Select id from Account Limit 1]?.Id;
        Id pricebookId = Test.getStandardPricebookId();
        Id productId = [Select Id from product2 Limit 1].Id;
        Id pricebookentryId = [Select id from PricebookEntry Limit 1].Id;
        Test.startTest();
        Order orderRec=Sales_TestFactory_Utility.createOrders(accShipToId,pricebookId,'Licensed Tool Order');  
        orderRec.Status='Draft';
        orderRec.Sales_status__c='SAP Resubmission In Progress';
        orderRec.Sales_Retry_Count__c=1;
        update orderRec;
        List<String> orderList =new List<String>();
        orderList.add(orderRec.Id);
        String exceptionMsg='';
        try{
            Sales_SapIntegrationUtility.retryFailedOrder();
        }
        catch(Exception e){
            exceptionMsg=e.getMessage();
        }
        Order orderUpdated=[Select Id,Sales_Status__c from Order where Id=:orderRec.Id];
        Test.stopTest();
    }
    @isTest static void testRecallOrder() {
        Test.setMock(HttpCalloutMock.class, new Sales_SapIntegrationUtilityCalloutMock(200,'Success')); 
        Id accShipToId = [Select id from Account Limit 1]?.Id;
        Id pricebookId = Test.getStandardPricebookId();
        Id productId = [Select Id from product2 Limit 1].Id;
        Id pricebookentryId = [Select id from PricebookEntry Limit 1].Id;
        Sales_SAP_Token_Detail__c connectSettingRecord = new Sales_SAP_Token_Detail__c();
        connectSettingRecord.Sales_Access_Token__c='TestToken';
        connectSettingRecord.Sales_Expires_In_Seconds__c=3599;
        connectSettingRecord.Sales_Expires_In_Time__c=System.now().addSeconds(Integer.valueOf(3599));
        connectSettingRecord.Name ='SAP Token Details';
        insert connectSettingRecord;
        String exceptionMsg='';
        Test.startTest();
        try{
            Order orderRec=Sales_TestFactory_Utility.createOrders(accShipToId,pricebookId,'Licensed Tool Order');  
            orderRec.Sales_ERP_SO_Txt__c='1234';
            Sales_SapIntegrationUtility.updateOrderRecallStatus(orderRec.Id, '05');
            Sales_SapIntegrationUtility.recallOrderFromSAP(orderRec, '02');
        }
        catch(Exception e){
            exceptionMsg=e.getMessage();
        }
        Test.stopTest();
    }
    @isTest static void errortestRecallOrder() {
        Test.setMock(HttpCalloutMock.class, new Sales_SapIntegrationUtilityCalloutMock(200,'Success')); 
        Id accShipToId = [Select id from Account Limit 1]?.Id;
        Id pricebookId = Test.getStandardPricebookId();
        Id productId = [Select Id from product2 Limit 1].Id;
        Id pricebookentryId = [Select id from PricebookEntry Limit 1].Id;
        Sales_SAP_Token_Detail__c connectSettingRecord = new Sales_SAP_Token_Detail__c();
        connectSettingRecord.Sales_Access_Token__c='TestToken';
        connectSettingRecord.Sales_Expires_In_Seconds__c=3599;
        connectSettingRecord.Sales_Expires_In_Time__c=System.now().addSeconds(Integer.valueOf(3599));
        connectSettingRecord.Name ='SAP Token Details';
        insert connectSettingRecord;
        String exceptionMsg='';
        Test.startTest();
        try{
            Order orderRec=Sales_TestFactory_Utility.createOrders(accShipToId,pricebookId,'Licensed Tool Order');  
            orderRec.Sales_ERP_SO_Txt__c='1234';
            Sales_SapIntegrationUtility.updateOrderRecallStatus(orderRec.Id, 'ABCD');
            Sales_SapIntegrationUtility.recallOrderFromSAP(orderRec, 'ABCD');
        }
        catch(Exception e){
            exceptionMsg=e.getMessage();
        }
        Test.stopTest();
    }
    @isTest static void testUpdateRecallOrder() {
        Test.setMock(HttpCalloutMock.class, new Sales_SapIntegrationUtilityCalloutMock(200,'Success')); 
        Id accShipToId = [Select id from Account Limit 1]?.Id;
        Id pricebookId = Test.getStandardPricebookId();
        Id productId = [Select Id from product2 Limit 1].Id;
        Id pricebookentryId = [Select id from PricebookEntry Limit 1].Id;
        Sales_SAP_Token_Detail__c connectSettingRecord = new Sales_SAP_Token_Detail__c();
        connectSettingRecord.Sales_Access_Token__c='TestToken';
        connectSettingRecord.Sales_Expires_In_Seconds__c=3599;
        connectSettingRecord.Sales_Expires_In_Time__c=System.now().addSeconds(Integer.valueOf(3599));
        connectSettingRecord.Name ='SAP Token Details';
        insert connectSettingRecord;
        Order orderRec=Sales_TestFactory_Utility.createOrders(accShipToId,pricebookId,'Licensed Tool Order');  
        String exceptionMsg='';
        Test.startTest();
        try{
            Sales_SapIntegrationUtility.updateOrderRecallStatus(orderRec.Id, '02');
        }
        catch(Exception e){
            exceptionMsg=e.getMessage();
        }
        Order orderUpdated=[Select Id,Sales_Status__c from Order where Id=:orderRec.Id];
        Test.stopTest();
    }
    @isTest static void testResponseSubmitOrderInSapNegative() {
        Test.setMock(HttpCalloutMock.class, new Sales_SapIntegrationUtilityCalloutMock(200,'Failure')); 
        Id accShipToId = [Select id from Account Limit 1]?.Id;
        Id pricebookId = Test.getStandardPricebookId();
        Id productId = [Select Id from product2 Limit 1].Id;
        Id pricebookentryId = [Select id from PricebookEntry Limit 1].Id;
        Sales_SAP_Token_Detail__c connectSettingRecord = new Sales_SAP_Token_Detail__c();
        connectSettingRecord.Sales_Access_Token__c='TestToken';
        connectSettingRecord.Sales_Expires_In_Seconds__c=3599;
        connectSettingRecord.Sales_Expires_In_Time__c=System.now().addSeconds(Integer.valueOf(3599));
        connectSettingRecord.Name ='SAP Token Details';
        insert connectSettingRecord;
        Order orderRec=Sales_TestFactory_Utility.createOrders(accShipToId,pricebookId,'Licensed Tool Order');  
        Test.startTest();
        List<OrderItem> orderProduct =Sales_TestFactory_Utility.createOrderProductList(orderRec.Id,productId,pricebookentryId);
        List<Sales_License__c> licList = new List<Sales_License__c>();
        Sales_License__c licRecord = new Sales_License__c();
        licRecord.Sales_License_Order_Product__c = orderProduct[0].Id;
        licRecord.Sales_License_Order__c = orderRec.Id;
        licRecord.Sales_License_Product__c = productId;
        licRecord.Sales_License_Status__c = 'Licensed';
        licRecord.Sales_License_Avbl_Qty_Nbr__c = 2;
        licList.add(licRecord);
        insert licList;
        List<String> orderList =new List<String>();
        orderList.add(orderRec.Id);
        String exceptionMsg='';
        try{
            Sales_SapIntegrationUtility.updateSapOrderStatus(orderList);
        }
        catch(Exception e){
            exceptionMsg=e.getMessage();
        }
        Test.stopTest();
    }
    @isTest static void testNonCommercialOrder() {
        Test.setMock(HttpCalloutMock.class, new Sales_SapIntegrationUtilityCalloutMock(200,'Failure')); 
        Id accShipToId = [Select id from Account Limit 1]?.Id;
        Id pricebookId = Test.getStandardPricebookId();
        Id productId = [Select Id from product2 Limit 1].Id;
        Id pricebookentryId = [Select id from PricebookEntry Limit 1].Id;
        Sales_SAP_Token_Detail__c connectSettingRecord = new Sales_SAP_Token_Detail__c();
        connectSettingRecord.Sales_Access_Token__c='TestToken';
        connectSettingRecord.Sales_Expires_In_Seconds__c=3599;
        connectSettingRecord.Sales_Expires_In_Time__c=System.now().addSeconds(Integer.valueOf(3599));
        connectSettingRecord.Name ='SAP Token Details';
        insert connectSettingRecord;
        Account accSoldTo = Sales_TestFactory_Utility.createSoldToAccount(); 
        insert accSoldTo;
        Order o = Sales_TestFactory_Utility.createNonCommOrder();
        Test.startTest();
        List<OrderItem> orderProduct =Sales_TestFactory_Utility.createOrderProductList(o.Id,productId,pricebookentryId);
        List<String> orderList =new List<String>();
        orderList.add(o.Id);
        String exceptionMsg='';
        try{
            Sales_SapIntegrationUtility.updateSapOrderStatus(orderList);
        }
        catch(Exception e){
            exceptionMsg=e.getMessage();
        }
        Order orderUpdated=[Select Id,Sales_Status__c from Order where Id=:o.Id];
        Test.stopTest();
    }
    @isTest static void testUpdateOrderStatusToFailureForBatch() {
        Id accShipToId = [Select id from Account Limit 1]?.Id;
        Id pricebookId = Test.getStandardPricebookId();
        Id productId = [Select Id from product2 Limit 1].Id;
        Id pricebookentryId = [Select id from PricebookEntry Limit 1].Id;
        Test.startTest();
        Order orderRec=Sales_TestFactory_Utility.createOrders(accShipToId,pricebookId,'Licensed Tool Order');  
        List<Order> orderUpdateList = new List<Order>();
        orderUpdateList.add(orderRec);
        String exceptionMsg='';
        try{
            Sales_SapIntegrationUtility.updateOrderStatusToFailureForBatch(orderUpdateList);
        }
        catch(Exception e){
            exceptionMsg=e.getMessage();
        }
        Test.stopTest();
    }
    @isTest
    static void validateCancelReason(){
        String cancelCode = '02';   
        test.startTest();
        String reason = Sales_SapIntegrationUtility.getCancelReasonCode(cancelCode);
        test.stopTest();        
    }
    public static Account createDiffPSGDownstreamAccounts(String CoreAccountType, String Acctype){
        Account acc = new Account();
        acc.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Account',Label.Pricing_Tender_Account_RecordType_IntelAccount);  
        acc.Core_PSG_Account__c=true;   
        acc.Name = 'AccName - '+String.valueof((Math.random() * 1000));
        acc.Core_Account_Type__c = CoreAccountType;
        acc.Industry = 'Education';
        acc.Core_Sub_Industry__c = 'Student';
        acc.BillingCity = 'New york';
        acc.BillingState='ME';
        acc.BillingCountry = 'USA';
        acc.BillingStreet = 'New U';
        acc.BillingPostalCode='04685';
        acc.Type = Acctype;
        acc.Core_Sales_Groups__c = 'PRC Sales Group';       
        insert acc;
        return acc;
    }
    public static Account createEndCustomerAccount(String CoreAccountType, String Acctype){
        Account acc = new Account();
        acc.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Account',Label.Pricing_Tender_Account_RecordType_IntelAccount);  
        acc.Core_PSG_Account__c=true;   
        acc.Name = 'AccName - '+String.valueof((Math.random() * 1000));
        acc.Core_Account_Type__c = CoreAccountType;
        acc.Industry = 'Education';
        acc.Core_Sub_Industry__c = 'Student';
        acc.BillingCity = 'New york';
        acc.BillingState='ME';
        acc.BillingCountry = 'USA';
        acc.BillingStreet = 'New U';
        acc.BillingPostalCode='04685';
        acc.Type = Acctype;
        acc.Core_Sales_Groups__c = 'PRC Sales Group';       
        insert acc;
        return acc;
    }
    public static SBQQ__Quote__c createQuote(Id distributorId, Id endCusId,Id oppId, Id pbId){
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.RecordTypeId= SBQQ__Quote__c.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('PSG_Quote_New').getRecordTypeId();
        quote.core_cpq_active_cb__c = true;
        quote.SBQQ__Opportunity2__c = oppId;
        quote.SBQQ__Primary__c = true;
        quote.SBQQ__PriceBook__c = pbId;
        quote.core_cpq_business_unit_nm__c = 'Military';
        quote.core_cpq_quote_type_nm__c='Design Win';
        quote.SBQQ__StartDate__c = date.today()+10;
        quote.SBQQ__SubscriptionTerm__c = 12;
        quote.SBQQ__Status__c = 'Approved';
        quote.core_cpq_end_customer_nm__c=endCusId;
        quote.SBQQ__Account__c=distributorId;
        insert quote;
        return quote;
    }
    @isTest
    static void testWrapperClass(){
        Sales_SapResponseWrapper wrap = new Sales_SapResponseWrapper();
        wrap.Order= 'Test';
        wrap.Type= 'Sample Order';
        wrap.Message= 'Test';
        Sales_SapResponseWrapper.cls_OrderRejectionList testWrap = new Sales_SapResponseWrapper.cls_OrderRejectionList();
        testWrap.Order= 'Test';
        testWrap.Type= 'Licensed Tools Order';
        testWrap.Message= 'Test';
        wrap.OrderRejectionList=testWrap;
        Sales_SapResponseWrapper.cls_OrderResponse testWrap1 = new Sales_SapResponseWrapper.cls_OrderResponse();
        testWrap1.OrderNumber = '00002734';
        testWrap1.Status = 'Draft';
        testWrap1.SAPOrderDate = 20210907;
        testWrap1.SAPScheduledDate = 20210909;
        testWrap1.SAPOrderNum = '0010066316';
        wrap.OrderResponse=testWrap1;
    }
*/
}