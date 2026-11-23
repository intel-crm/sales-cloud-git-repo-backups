@isTest
public class Sales_AutomatedLicGenerationProcessTest {
    @TestSetup
    public static void testData(){
        Sales_License_Generator__c lGen = Sales_TestDataFactory.createLicenseGenerator();
        insert lGen;
        Sales_License_Group__c lgp = Sales_TestDataFactory.createLicenseGroup();
        lgp.Sales_License_Generator__c = lGen.id ;
        insert lgp;
        Core_Product_Ext_Attribute__c l1 = Sales_TestDataFactory.createProductExternalAttributes();
        l1.Core_SW_Lic_Group_Id__c = lgp.id;
        l1.Core_SW_Lic_Type_Nm__c = 'FLOAT';
        l1.Core_SW_Prod_Expiration_Duration_Nbr__c = 45;
        l1.Core_SW_Lic_Group_Id__c = lgp.Id;
        insert l1;
        Product2 p = Sales_TestDataFactory.createProduct();
        p.Core_OPN__c='TESTFLOAT';
        p.Core_Product_Ext_Attribute_Id__c  = l1.Id;
        p.SBQQ__SubscriptionTerm__c=12;
        p.SBQQ__SubscriptionCategory__c='Renewal';
        p.Core_Sales_Visible_Flag__c=false;
        p.Core_Sales_Visible_Flag_User_Edit__c=true;
        insert p;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = Sales_TestDataFactory.createPriceBookEntry();
        standardPrice.Pricebook2Id = pricebookId;
        standardPrice.Product2Id = p.Id;
        insert standardPrice;
        List<Account> accListToInsert = new List<Account>();
        Account parentShipToAccount = Sales_TestDataFactory.createPartnerIntelShipToAccount();
        accListToInsert.add(parentShipToAccount);
        Account parentSoldToAccount = Sales_TestDataFactory.createDefaultAccount();
        accListToInsert.add(parentSoldToAccount);
        Account parentEndCustomerAccount = Sales_TestDataFactory.createParentEndCustomerAccount();
        parentEndCustomerAccount.Core_Sub_Industry__c = null;
        accListToInsert.add(parentEndCustomerAccount);
        insert accListToInsert;
        accListToInsert = new List<Account>();
        Account shipToAccount = Sales_TestDataFactory.createShipToAccount();
        shipToAccount.ParentId = parentShipToAccount.Id;
        accListToInsert.add(shipToAccount);
        Account soldToAccount = Sales_TestDataFactory.createSoldToAccount();
        soldToAccount.ParentId = parentSoldToAccount.Id;
        accListToInsert.add(soldToAccount);
        Account endCustomer = Sales_TestDataFactory.createEndCustomerAccount();
        endCustomer.ParentId = parentEndCustomerAccount.Id;
        accListToInsert.add(endCustomer);
        insert accListToInsert;
        Core_Account_SoldTo_ShipTo_Rel__c relation_Ship_Sold = Sales_TestDataFactory.accSoldToShipToRelationshipRecord(new Map<String,String>{
            'Core_Sold_To_Account__c'  =>  soldToAccount.Id,
                'Core_Ship_To_Account__c'  =>  shipToAccount.Id
                });
        insert relation_Ship_Sold;
        SBQQ__Quote__c q = Sales_TestDataFactory.createQuoteRecord();
        q.core_cpq_quote_type_nm__c = 'Tools';
        q.SBQQ__Type__c='Renewal';
        q.core_cpq_active_cb__c = true;
        insert q;
        List<Order> orderListToInsert = new List<Order>();
        TriggerHandler.bypass('Sales_OrderTriggerHandler');
        Order order = Sales_TestDataFactory.createOrder();
        order.AccountId = parentSoldToAccount.Id;
        order.Sales_End_Customer_Account__c = endCustomer.Id;
        order.Pricebook2Id = pricebookId;
        order.Sales_Sold_To_Account__c = soldToAccount.Id;
        order.Sales_Ship_To_Account__c = shipToAccount.Id;
        order.Status = 'Draft';
        order.Sales_Cost_Center__c='';
        orderListToInsert.add(order);
        Order order2 = Sales_TestDataFactory.createOrder();
        order2.AccountId = parentSoldToAccount.Id;
        order2.Sales_End_Customer_Account__c = endCustomer.Id;
        order2.Pricebook2Id = pricebookId;
        order2.Sales_Sold_To_Account__c = soldToAccount.Id;
        order2.Sales_Ship_To_Account__c = shipToAccount.Id;
        order2.Status = 'Draft';
        order2.Sales_Cost_Center__c='';
        orderListToInsert.add(order2);
        insert orderListToInsert;
        TriggerHandler.clearBypass('Sales_OrderTriggerHandler');
        Contract contract = Sales_TestDataFactory.createContract();
        contract.AccountId = parentSoldToAccount.Id;
        insert contract;
        List<OrderItem> oiList = new List<OrderItem>();
        OrderItem oi = Sales_TestDataFactory.createOrderItem();
        oi.OrderId = order.Id;
        oi.Product2id = p.Id;
        oi.PricebookEntryId = standardPrice.Id;
        oi.SBQQ__Contract__c = contract.Id;
        oiList.add(oi);
        OrderItem oi2 = Sales_TestDataFactory.createOrderItem();
        oi2.OrderId = order2.Id;
        oi2.Product2id = p.Id;
        oi2.PricebookEntryId = standardPrice.Id;
        oi2.SBQQ__Contract__c = contract.Id;
        oiList.add(oi2);
        insert oiList;
        Sales_Host__c testComputer=Sales_TestDataFactory.createComputerRecord();
        testComputer.Sales_License_Type__c = 'FLOAT';
        testComputer.Temporary_NIC_ID__c = '123abcdef222';
        insert testComputer;
        Test.startTest();
        TriggerHandler.bypass('Sales_LicenseTriggerHandler');
        Sales_License__c testLicense = Sales_TestDataFactory.createLicenseRecord();
        testLicense.Sales_License_Product__c = p.Id;
        testLicense.Sales_License_Host_Node_Id__c = testComputer.Id;
        testLicense.Sales_License_Order__c = order.Id;
        testLicense.Sales_License_Status__c='Licensed';
        insert testLicense;
        TriggerHandler.clearBypass('Sales_LicenseTriggerHandler');
        List<Sales_License_Order_Product__c> licOrderProductList = new List<Sales_License_Order_Product__c>();
        Sales_License_Order_Product__c licOrderProduct = Sales_TestDataFactory.createLicenseOrderProductRecord();
        licOrderProduct.Sales_License__c = testLicense.Id;
        licOrderProduct.Sales_Order_Product__c = oi.Id;
        licOrderProductList.add(licOrderProduct);
        Sales_License_Order_Product__c licOrderProduct2 = Sales_TestDataFactory.createLicenseOrderProductRecord();
        licOrderProduct2.Sales_License__c = testLicense.Id;
        licOrderProduct2.Sales_Order_Product__c = oi2.Id;
        licOrderProductList.add(licOrderProduct2);
        insert licOrderProduct2;
        Test.stopTest();
    }
    @isTest
    public static void orderShippedTestMethod(){
        SBQQ__Quote__c quote=[Select Id from SBQQ__Quote__c LIMIT 1];
        quote.SBQQ__Status__c  = 'Approved';
        quote.core_cpq_status_txt__c = 'Approved';
        update quote;
        Order order = [Select Id,Sales_status__c from Order Limit 1];
        order.Sales_status__c = 'SAP Order Shipped';
        order.SBQQ__Quote__c = quote.Id;
        String exceptionMessage;
        try{
            Test.startTest();
            update order;
            Test.stopTest();
        }
        catch(Exception ex){
            exceptionMessage = ex.getMessage();
        }
        System.assert(String.isEmpty(exceptionMessage));
    }
}