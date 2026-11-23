/*********************************************************************************************************************
Class Name    : Sales_UpdateLicenseRenewalRecordsTest
Version       : 1.0
Created Date  : July 2021
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Srishty Sharma           July-2021				 Test class for Sales_UpdateLicenseRenewalRecords
* 
* ************************************************************************************************************************************************/
@isTest
public class Sales_UpdateLicenseRenewalRecordsTest {
    @isTest
    private static void testGetLicenseParameterForRenewal(){
        Product2 p = Sales_TestDataFactory.createProduct();
        insert p;
        Account acc = Sales_TestDataFactory.createDefaultAccount();
        insert acc;
        Account soldToAccount = Sales_TestDataFactory.createSoldToAccount();
        soldToAccount.ParentId = acc.Id;
        Account shipToAccount = Sales_TestDataFactory.createShipToAccount();
        shipToAccount.ParentId = acc.Id;
        insert new List<Account>{soldToAccount, shipToAccount};
        Contact con1 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        Contact con2 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        insert new List<Contact>{con1,con2};
            Sales_License_Admin_Delegate__c licAdmDlg = Sales_TestDataFactory.createLicenseAdminDelegateRecord(new Map<String,String>{
                'Sales_License_PrimaryAdmin_Contact__c' => con1.Id , 'Sales_License_DlgAdmin_Contact__c' => con2.Id
                    }); 
        insert licAdmDlg;
        Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','FIXED');
        prodExt1.put('Core_SW_Prod_Avail_To_TL_ORD_ENBLMT_Ind__c', true);
        prodExt1.put('Core_SW_Prod_Temporary_Lic_Allowed_Ind__c',true);
        prodExt1.put('Core_SW_Lic_Rehostable_Ind__c',true);
        prodExt1.put('Core_SW_Prod_Max_Rehost_Cnt__c',3);       
        insert prodExt1;
        Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        insert prod1;
        Sales_Host__c hostObj1 = Sales_TestDataFactory.createComputerRecord(new Map<String,String>{ 'Sales_Contact__c'=>con2.Id });
        insert hostObj1;
        Core_Account_SoldTo_ShipTo_Rel__c soldShipRel = Sales_TestDataFactory.accSoldToShipToRelationshipRecord(new Map<String,Object>{
            'Core_Sold_To_Account__c' => soldToAccount.Id , 'Core_Ship_To_Account__c' => shipToAccount.Id
                });
        insert soldShipRel; 
        Order o1 = Sales_TestDataFactory.createOrder();
        o1.Pricebook2Id = Test.getStandardPricebookId();
        o1.AccountId = acc.Id;
        o1.Sales_Sold_To_Account__c = soldToAccount.Id ;
        o1.Sales_Ship_To_Account__c = shipToAccount.Id;      
        TriggerHandler.bypass('Sales_OrderTriggerHandler');
        insert o1;
        TriggerHandler.clearAllBypasses();
        PriceBookEntry pbEntry = Sales_TestDataFactory.createPriceBookEntry();
        pbEntry.Pricebook2Id = Test.getStandardPricebookId();
        pbEntry.Product2Id = prod1.Id;
        insert pbEntry;
        OrderItem op1 = Sales_TestDataFactory.createOrderItem();
        op1.OrderId = o1.Id;
        op1.Product2Id = prod1.Id;
        op1.PricebookEntryId = pbEntry.Id;
        op1.Sales_Contact__c = con2.Id;
        TriggerHandler.bypass('Sales_OrderProductTriggerHandler');
        insert op1;
        TriggerHandler.clearAllBypasses();
        TriggerHandler.bypass('Sales_LicenseTriggerHandler');
        Sales_License__c testLicense = Sales_TestDataFactory.createLicenseRecord();
        testLicense.Sales_License_Web_Display_Flag__c = true;
        testLicense.Sales_License_Product__c = prod1.Id;
        testLicense.Sales_License_Type__c = 'Renewal';
        insert testLicense;
        List<Contract> contracts = Sales_TestFactory_Utility.createContract(acc.Id);
        List<Sales_License_Order_Product__c> sops = Sales_TestFactory_Utility.createSalesLicenseOrdProd(testLicense.Id, contracts[0].Id, op1.Id);
        sops[0].Sales_Renewable_license__c = testLicense.Id;
        update sops[0];
        TriggerHandler.clearBypass('Sales_LicenseTriggerHandler');
        Test.startTest();
        List<Sales_License__c> returnedList = Sales_UpdateLicenseRenewalRecords.getLicenseParameter(testLicense.Id);
        Test.stopTest();
        System.assert(!returnedList.isEmpty());
    }
    @isTest
    private static void testGetLicenseParameter(){
        Product2 p = Sales_TestDataFactory.createProduct();
        insert p;
        TriggerHandler.bypass('Sales_LicenseTriggerHandler');
        Sales_License__c testLicense = Sales_TestDataFactory.createLicenseRecord();
        testLicense.Sales_License_Web_Display_Flag__c = true;
        testLicense.Sales_License_Product__c = p.Id;
        insert testLicense;
        TriggerHandler.clearBypass('Sales_LicenseTriggerHandler');
        Test.startTest();
        List<Sales_License__c> returnedList = Sales_UpdateLicenseRenewalRecords.getLicenseParameter(testLicense.Id);
        Test.stopTest();
        System.assert(returnedList.isEmpty());
    }
    @isTest
    private static void testGetLicenseParameterForAddSeat(){      
        Product2 p = Sales_TestDataFactory.createProduct();
        insert p;
        Account acc = Sales_TestDataFactory.createDefaultAccount();
        insert acc;
        Account soldToAccount = Sales_TestDataFactory.createSoldToAccount();
        soldToAccount.ParentId = acc.Id;
        Account shipToAccount = Sales_TestDataFactory.createShipToAccount();
        shipToAccount.ParentId = acc.Id;
        insert new List<Account>{soldToAccount, shipToAccount};
        Contact con1 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        Contact con2 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        insert new List<Contact>{con1,con2};
            Sales_License_Admin_Delegate__c licAdmDlg = Sales_TestDataFactory.createLicenseAdminDelegateRecord(new Map<String,String>{
                'Sales_License_PrimaryAdmin_Contact__c' => con1.Id , 'Sales_License_DlgAdmin_Contact__c' => con2.Id
                    }); 
        insert licAdmDlg;
        Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','FIXED');
        prodExt1.put('Core_SW_Prod_Avail_To_TL_ORD_ENBLMT_Ind__c', true);
        prodExt1.put('Core_SW_Prod_Temporary_Lic_Allowed_Ind__c',true);
        prodExt1.put('Core_SW_Lic_Rehostable_Ind__c',true);
        prodExt1.put('Core_SW_Prod_Max_Rehost_Cnt__c',3);       
        insert prodExt1;
        Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        insert prod1;
        Sales_Host__c hostObj1 = Sales_TestDataFactory.createComputerRecord(new Map<String,String>{ 'Sales_Contact__c'=>con2.Id });
        insert hostObj1;
        Core_Account_SoldTo_ShipTo_Rel__c soldShipRel = Sales_TestDataFactory.accSoldToShipToRelationshipRecord(new Map<String,Object>{
            'Core_Sold_To_Account__c' => soldToAccount.Id , 'Core_Ship_To_Account__c' => shipToAccount.Id
                });
        insert soldShipRel; 
        Order o1 = Sales_TestDataFactory.createOrder();
        o1.Pricebook2Id = Test.getStandardPricebookId();
        o1.AccountId = acc.Id;
        o1.Sales_Sold_To_Account__c = soldToAccount.Id ;
        o1.Sales_Ship_To_Account__c = shipToAccount.Id;      
        TriggerHandler.bypass('Sales_OrderTriggerHandler');
        insert o1;
        TriggerHandler.clearAllBypasses();
        PriceBookEntry pbEntry = Sales_TestDataFactory.createPriceBookEntry();
        pbEntry.Pricebook2Id = Test.getStandardPricebookId();
        pbEntry.Product2Id = prod1.Id;
        insert pbEntry;
        OrderItem op1 = Sales_TestDataFactory.createOrderItem();
        op1.OrderId = o1.Id;
        op1.Product2Id = prod1.Id;
        op1.PricebookEntryId = pbEntry.Id;
        op1.Sales_Contact__c = con2.Id;
        TriggerHandler.bypass('Sales_OrderProductTriggerHandler');
        insert op1;
        TriggerHandler.clearAllBypasses();
        TriggerHandler.bypass('Sales_LicenseTriggerHandler');
        Sales_License__c testLicense = Sales_TestDataFactory.createLicenseRecord();
        testLicense.Sales_License_Web_Display_Flag__c = true;
        testLicense.Sales_License_Product__c = prod1.Id;
        testLicense.Sales_License_Type__c = 'Add seat';
        insert testLicense;
        List<Contract> contracts = Sales_TestFactory_Utility.createContract(acc.Id);
        List<Sales_License_Order_Product__c> sops = Sales_TestFactory_Utility.createSalesLicenseOrdProd(testLicense.Id, contracts[0].Id, op1.Id);
        sops[0].Sales_Renewable_license__c = testLicense.Id;
        update sops[0];
        TriggerHandler.clearBypass('Sales_LicenseTriggerHandler');
        Test.startTest();
        List<Sales_License__c> returnedList = Sales_UpdateLicenseRenewalRecords.getLicenseParameter(testLicense.Id);
        Test.stopTest();
        System.assert(!returnedList.isEmpty());
    }
}