/*********************************************************************************************************************
Class Name    : Sales_SearchLicenseForRenewalTest
Version       : 1.0
Created Date  : July 2021
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Srishty Sharma           July-2021				 Test class for Sales_SearchLicenseForRenewal
* 
* ************************************************************************************************************************************************/
@isTest
public class Sales_SearchLicenseForRenewalTest {
    @isTest 
    public static void testGetRenewalLicense(){
        Account acc = Sales_TestDataFactory.createDefaultAccount();
        insert acc;
        Contact con1 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        insert con1;
        Sales_License_Generator__c lGen = Sales_TestDataFactory.createLicenseGenerator();
        insert lGen;
        Sales_License_Group__c lgp = Sales_TestDataFactory.createLicenseGroup();
        lgp.Sales_License_Generator__c = lGen.id ;
        insert lgp;
        Product2 p1 = Sales_TestDataFactory.createProduct();
        insert p1;
        Core_Product_Ext_Attribute__c l1 = Sales_TestDataFactory.createProductExternalAttributes();
        l1.Core_SW_Lic_Group_Id__c = lgp.id;
        l1.Core_SW_Lic_Type_Nm__c = 'FLOAT';
        l1.Core_SW_Prod_Expiration_Duration_Nbr__c = 45;
        l1.Core_SW_Lic_Group_Id__c = lgp.Id;
        l1.Core_Foundation_Product_Id__c = p1.Id;
        l1.Core_Prod_Tool_Type_Nm__c = 'RENEWAL';
        insert l1;
        Product2 p = Sales_TestDataFactory.createProduct();
        p.Core_OPN__c='TESTFLOAT';
        p.Core_Product_Ext_Attribute_Id__c  = l1.Id;
        insert p;
        Sales_Host__c testComputer=Sales_TestDataFactory.createComputerRecord();
        insert testComputer;
        Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
        prodExt1.put('Core_SW_Lic_Type_Nm__c','FIXED');
        prodExt1.put('Core_SW_Prod_Temporary_Lic_Allowed_Ind__c',true);
        prodExt1.put('Core_SW_Lic_Rehostable_Ind__c',true);
        prodExt1.put('Core_SW_Lic_Web_Displayable_Ind__c',true);
        prodExt1.put('Core_SW_Prod_Max_Rehost_Cnt__c',3);           
        insert prodExt1 ; 
        Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.put('Core_Product_Ext_Attribute_Id__c',prodExt1.Id);
        insert prod1;
        Order o = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Sample Order');
        PricebookEntry standardPrice3 = Sales_TestFactory_Utility.createPriceBookEntry(prod1.Id, Test.getStandardPricebookId());
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o.Id, prod1.Id, standardPrice3.Id); 
        TriggerHandler.bypass('Sales_LicenseTriggerHandler');
        Sales_License__c testLicense = Sales_TestDataFactory.createLicenseRecord();
        testLicense.Sales_License_Web_Display_Flag__c = true;
        testLicense.Sales_License_Host_Node_Id__c = testComputer.Id;
        testLicense.Sales_License_Product__c = p.Id;
        testLicense.Sales_License_Order__c = o.Id;
        testLicense.Sales_License_Order_Product__c = oi.Id;
        testLicense.Sales_License_Primary_Admin_Contact__c = con1.Id;
        testLicense.Sales_License_Type__c = 'ORIGINAL';
        testLicense.Sales_License_Status__c='Licensed';
        Sales_License__c testLicense1 = Sales_TestDataFactory.createLicenseRecord();
        testLicense1.Sales_License_Web_Display_Flag__c = true;
        testLicense1.Sales_License_Host_Node_Id__c = testComputer.Id;
        testLicense1.Sales_License_Product__c = p.Id;
        testLicense1.Sales_License_Order__c = o.Id;
        testLicense1.Sales_License_Order_Product__c = oi.Id;
        testLicense1.Sales_License_Primary_Admin_Contact__c = con1.Id;
        testLicense1.Sales_License_Type__c = 'ORIGINAL';
        testLicense1.Sales_License_Status__c='Licensed';
        insert testLicense;
        insert testLicense1;
        TriggerHandler.clearBypass('Sales_LicenseTriggerHandler');
        Sales_SearchLicenseForRenewal.LicenseInput input = new Sales_SearchLicenseForRenewal.LicenseInput();
        input.Sales_ContactId = con1.id;
        input.Sales_renewLicId = testLicense.Id;
        input.Sales_computerName = testComputer.Name;
        List<Sales_SearchLicenseForRenewal.LicenseInput> inputs = new List<Sales_SearchLicenseForRenewal.LicenseInput>();
        inputs.add(input);
        Test.startTest();
        List<List<Sales_SearchLicenseForRenewal.licensewrapper>> returnedList = Sales_SearchLicenseForRenewal.getRenewalLicense(inputs);
        Test.stopTest();
    }
    @isTest
    public static void searchLicenseforRenewal(){
        Account acc = Sales_TestDataFactory.createDefaultAccount();
        insert acc;
        Account soldToAccount = Sales_TestDataFactory.createSoldToAccount();
        soldToAccount.ParentId = acc.Id;
        Account shipToAccount = Sales_TestDataFactory.createShipToAccount();
        shipToAccount.ParentId = acc.Id;
        insert new List<Account>{soldToAccount, shipToAccount};
            Contact con1 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        insert con1;
        Contact con2 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        insert con2;
        Sales_License_Admin_Delegate__c licAdmDlg = Sales_TestDataFactory.createLicenseAdminDelegateRecord(new Map<String,String>{'Sales_License_PrimaryAdmin_Contact__c' => con2.Id , 'Sales_License_DlgAdmin_Contact__c' => con1.Id,'Sales_License_isActive__c' =>'true'}); 
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
        Sales_Host__c hostObj1 = Sales_TestDataFactory.createComputerRecord(new Map<String,String>{ 'Sales_Contact__c'=>con1.Id });
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
        op1.Sales_Contact__c = con1.Id;
        TriggerHandler.bypass('Sales_OrderProductTriggerHandler');
        insert op1;
        TriggerHandler.clearAllBypasses();
        Map<String,String> licenseFieldValues = new Map<String,String>();     
        licenseFieldValues.put('Sales_License_Product__c', prod1.Id);  
        licenseFieldValues.put('Sales_License_Order_Product__c', op1.Id);
        licenseFieldValues.put('Sales_License_Order__c', o1.Id);
        licenseFieldValues.put('Sales_License_Primary_Admin_Contact__c', con1.Id);
        licenseFieldValues.put('Sales_License_Host_Node_Id__c', hostObj1.Id);
        licenseFieldValues.put('Sales_License_Type__c', 'ORIGINAL');
        Sales_License__c lic = Sales_TestDataFactory.createLicenseRecord(licenseFieldValues);      
        insert lic;
        Sales_License__c testLicense1 = Sales_TestDataFactory.createLicenseRecord();
        testLicense1.Sales_License_Web_Display_Flag__c = true;
        testLicense1.Sales_License_Host_Node_Id__c = hostObj1.Id;
        testLicense1.Sales_License_Product__c = prod1.Id;
        testLicense1.Sales_License_Order__c = o1.Id;
        testLicense1.Sales_License_Order_Product__c = op1.Id;
        testLicense1.Sales_License_Primary_Admin_Contact__c = con1.Id;
        testLicense1.Sales_License_Type__c = 'ORIGINAL';
        System.Test.startTest();            
        Sales_SearchLicenseForRenewal.LicenseInput Input = new Sales_SearchLicenseForRenewal.LicenseInput();
        Input.Sales_ContactId = con1.Id;
        Input.Sales_renewLicId = lic.Id;
        Input.Sales_computerName = 'Intel';
        Sales_SearchLicenseForRenewal.getRenewalLicense(new List<Sales_SearchLicenseForRenewal.LicenseInput>{Input});
        System.Test.stopTest();
    }
    public static void applyrenewSeatsTest(){
        Set<Id> foundProdIdSet = new Set<Id>();
        Set<Id> licenseIDs = new Set<Id>();
        Set<Id> prodIdsSet = new Set<Id>();
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
        Map<String,String> licenseFieldValues = new Map<String,String>();     
        licenseFieldValues.put('Sales_License_Product__c', prod1.Id);  
        licenseFieldValues.put('Sales_License_Order_Product__c', op1.Id);
        licenseFieldValues.put('Sales_License_Order__c', o1.Id);
        Sales_License__c lic = Sales_TestDataFactory.createLicenseRecord(licenseFieldValues);      
        insert lic;
        foundProdIdSet.add(prod1.id);
        licenseIDs.add(lic.id);
        prodIdsSet.add(lic.Sales_License_Product__c);
        System.Test.startTest();            
        String Sales_ContactId;
        String Sales_renewLicId;
        Sales_ApplyRenewal_Chatbot.LicenseInput Input = new Sales_ApplyRenewal_Chatbot.LicenseInput();
        Input.Sales_ContactId = con2.Id;
        Input.Sales_renewLicId = String.valueof(lic.Id);  
        Sales_ApplyRenewal_Chatbot.getRenewalLicense(new List<Sales_ApplyRenewal_Chatbot.LicenseInput>{Input});
        System.Test.stopTest();
    }
}