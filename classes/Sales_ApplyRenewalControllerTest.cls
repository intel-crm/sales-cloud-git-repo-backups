/*********************************************************************************************************************
Class Name    : Sales_ApplyRenewalControllerTest
Version       : 1.0
Created Date  : July 2021
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Srishty Sharma           20-Jan-2021             Test class for Sales_ApplyRenewalController 
* *********************************************************************************************************************/
@isTest
public class Sales_ApplyRenewalControllerTest {
    /*@TestSetup
    public static void testData(){
    	Sales_License_Generator__c lGen = Sales_TestDataFactory.createLicenseGenerator();
        insert lGen;
        Sales_License_Group__c lgp = Sales_TestDataFactory.createLicenseGroup();
        lgp.Sales_License_Generator__c = lGen.id ;
        insert lgp;
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
        Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
		prodExt1.Core_SW_Lic_Type_Nm__c ='FLOAT';
		prodExt1.Core_SW_Prod_Expiration_Duration_Nbr__c = 20;
		prodExt1.Core_SW_Lic_Renewal_Period_Nbr__c =45;   
        insert prodExt1;
        Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.Core_Product_Ext_Attribute_Id__c =prodExt1.Id;
        insert prod1;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = Sales_TestDataFactory.createPriceBookEntry();
        standardPrice.Pricebook2Id = pricebookId;
        standardPrice.Product2Id = prod1.Id;
        insert standardPrice;
         TriggerHandler.bypass('Sales_OrderTriggerHandler');
        Order order=Sales_TestDataFactory.createOrder();
        order.AccountId = parentSoldToAccount.Id;
        order.Sales_End_Customer_Account__c = endCustomer.Id;
        order.Pricebook2Id = pricebookId;
        order.Sales_Sold_To_Account__c = soldToAccount.Id;
        order.Sales_Ship_To_Account__c = shipToAccount.Id;
        insert order;
        TriggerHandler.clearBypass('Sales_OrderTriggerHandler');
        OrderItem op=Sales_TestDataFactory.createOrderItem();
        op.OrderId = order.Id;
        op.Product2id = prod1.Id;
        op.PricebookEntryId = standardPrice.Id;
        insert op;
        Test.startTest();
        Sales_Host__c testComputer=Sales_TestDataFactory.createComputerRecord();
        testComputer.Sales_License_Type__c = 'FLOAT';
        testComputer.Temporary_NIC_ID__c = '123abcdef222';
        testComputer.Sales_Host_Is_Created_From_Custom_Page__c=true;
        insert testComputer;
        TriggerHandler.bypass('Sales_LicenseTriggerHandler');
        Sales_License__c testLicense = Sales_TestDataFactory.createLicenseRecord();
        testLicense.Sales_License_Host_Node_Id__c = testComputer.Id;
        testLicense.Sales_License_Order__c = order.Id;
        testLicense.Sales_License_Status__c='Licensed';
        testLicense.Sales_License_Order_Product__c=op.Id;
        testLicense.Sales_License_Product__c=prod1.Id;
        insert testLicense;
        TriggerHandler.clearBypass('Sales_LicenseTriggerHandler');
        List<Sales_License_Order_Product__c> licOrderProductList = new List<Sales_License_Order_Product__c>();
        Sales_License_Order_Product__c licOrderProduct = Sales_TestDataFactory.createLicenseOrderProductRecord();
        licOrderProduct.Sales_License__c = testLicense.Id;
        licOrderProduct.Sales_Order_Product__c = op.Id;
        insert licOrderProduct;
        Test.stopTest();
    }
    @isTest
    private static void shouldGetLastDateOfMonth(){
        Date dt = System.today();
        Test.startTest();
        Date returnedDate = Sales_ApplyRenewalController.getLastDateOfMonth(dt);
        Test.stopTest();
        System.assertEquals(Date.newInstance(dt.year(), dt.month(), Date.daysInMonth(dt.year(), dt.month())), returnedDate, 'Should return the last date of the month');
    }
    @isTest
    public static void testLicense(){
        List<Sales_License__c> lienselist =[Select Id,Sales_License_Quantity__c ,Sales_License_Avbl_Qty_Nbr__c ,Sales_License_Status__c,Sales_License_Avbl_Rehost_Nbr__c, Sales_License_Maintenance_Exp_Dt__c,Sales_License_Order_Product__c,Sales_License_Expiration_Date_Dt__c, Sales_License_Available_Temp_Licenses__c from Sales_License__c];
        Id licId=lienselist[0].id;
        test.startTest();
        User userId=[Select Id from User limit 1];
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='standarduser@intel.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName);
        System.runAs(u){
            Sales_ApplyRenewalController.applyRenewals(lienselist,1,licId,'');
            Sales_ApplyRenewalController.applyRenewals(lienselist,2,licId,'');
            Sales_ApplyRenewalController.checkUserPermissionSet();
        }
        Sales_ApplyRenewalController.getLicenseList();
        Sales_ApplyRenewalController.validateRenewal(licId);
        Sales_ApplyRenewalController.getBaseLicenseRecords(licId);
        test.stopTest();
    } 
    @isTest
    private static void shouldValidateRenewalRecord(){
        Test.startTest();
        Boolean returnedValue = Sales_ApplyRenewalController.validateRenewalrecord(Sales_TestDataFactory.getFakeId(Product2.SObjectType));
        Test.stopTest();
        System.assert(returnedValue);
    }*/
}