/*********************************************************************************************************************
Class Name    : Sales_LicenseGenericFuncTest
Version       : 1.0
Created Date  : June 2021
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Shalini Kumari           June-2021                 Test Class
* 
* ************************************************************************************************************************************************/
@isTest
public class Sales_LicenseGenericFuncTest {
    /*@isTest static void testValidateDelegateUsers(){
        List<Contact> contactsToInsert = new List<Contact>();
        Account partnerAccount = createAccount_PartnerandNonpartner_PSGDownstream('Independent Software Vendor (ISV)', 'Partner');
        insert partnerAccount;
        Contact partnerContact = createContactWithDetails(partnerAccount.Id, 'partner','addhost','shivamx.vishwakarma@intel.com');
        contactsToInsert.add(partnerContact);
        Contact partnerContact2 = createContactWithDetails(partnerAccount.Id, 'partne2','addhos2','shivamx.vishwakarma@mailinator.com');
        contactsToInsert.add(partnerContact2);
        insert contactsToInsert;
        Sales_License_Admin_Delegate__c licdlg1 = createPriAdmDlgAdmRecord(partnerContact.Id, partnerContact2.Id);
        insert licdlg1;
        Set<Id> contactIds = new set<Id>();
        contactIds.add(partnerContact2.Id);
        Test.startTest();
        Map<Id,Set<Id>> returnedMap = Sales_LicenseGenerationGenericFunctions.validateDelegateUsers(contactIds);
        Test.stopTest();
        System.assert(!returnedMap.isEmpty());
    }
    @isTest static void testGetDelegateAdmin(){
        Id dummyPrimaryContactId = Sales_TestDataFactory.getFakeId(Contact.SObjectType);
        Test.startTest();
        List<Sales_License_Admin_Delegate__c> returnedList = Sales_LicenseGenerationGenericFunctions.getDelegateAdmin(dummyPrimaryContactId);
        Test.stopTest();
        System.assert(returnedList.isEmpty(),'No record should be returned as we are using dummy id');
    }
    @isTest static void testGetPrimaryCtId(){
        Id dummyLicenseId = Sales_TestDataFactory.getFakeId(Sales_License__c.SObjectType);
        Test.startTest();
        String returnedValue = Sales_LicenseGenerationGenericFunctions.getPrimaryCtId(dummyLicenseId);
        Test.stopTest();
        System.assert(returnedValue==null, 'Null should be returned as we are using dummy id');
    }
    @isTest static void testAskForhostReassigment(){
        Id dummyLicenseId = Sales_TestDataFactory.getFakeId(Sales_License__c.SObjectType);
        Sales_Host__c testComputer=Sales_TestDataFactory.createComputerRecord();
        insert testComputer;
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
        insert p;
         Order o = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Sample Order');
        PricebookEntry standardPrice1 = Sales_TestFactory_Utility.createPriceBookEntry(p.Id, Test.getStandardPricebookId());
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o.Id, p.Id, standardPrice1.Id);
        TriggerHandler.bypass('Sales_LicenseTriggerHandler');
        Sales_License__c testLicense = Sales_TestDataFactory.createLicenseRecord();
        testLicense.Sales_License_Web_Display_Flag__c = true;
        testLicense.Sales_License_Host_Node_Id__c = testComputer.Id;
        testLicense.Sales_License_Product__c=p.id;
         testLicense.Sales_License_Order__c=o.id;
        testLicense.Sales_License_Order_Product__c=oi.id;
        insert testLicense;
        TriggerHandler.clearBypass('Sales_LicenseTriggerHandler');
        Test.startTest();
        Boolean returnedValue = Sales_LicenseGenerationGenericFunctions.askForhostReassigment(new Set<Id>{testComputer.Id},new Set<Id>{testLicense.Id});
        System.assert(!returnedValue);
        returnedValue = Sales_LicenseGenerationGenericFunctions.askForhostReassigment(new Set<Id>{testComputer.Id},new Set<Id>{dummyLicenseId});
        Test.stopTest();
    }
    @isTest static void testHostReassigmentLogicForHostWithoutLicense(){
        Sales_Host__c testComputer=Sales_TestDataFactory.createComputerRecord();
        insert testComputer;
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
        insert p;
         TriggerHandler.bypass('Sales_OrderTriggerHandler');
         Order o = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Sample Order');
        PricebookEntry standardPrice1 = Sales_TestFactory_Utility.createPriceBookEntry(p.Id, Test.getStandardPricebookId());
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o.Id, p.Id, standardPrice1.Id);
        TriggerHandler.bypass('Sales_LicenseTriggerHandler');
        Sales_License__c testLicense = Sales_TestDataFactory.createLicenseRecord();
        testLicense.Sales_License_Web_Display_Flag__c = true;
        testLicense.Sales_License_Status__c='Licensed';
        testLicense.Sales_License_Avbl_Rehost_Nbr__c=3;
         testLicense.Sales_License_Product__c=p.id;
         testLicense.Sales_License_Order__c=o.id;
        testLicense.Sales_License_Order_Product__c=oi.id;
        insert testLicense;
        TriggerHandler.clearBypass('Sales_LicenseTriggerHandler');
        Test.startTest();
        String returnedValue = Sales_LicenseGenerationGenericFunctions.hostReassigmentLogic(new Map<Id,Id>{testComputer.Id => testLicense.Id});
        Test.stopTest();
          TriggerHandler.clearAllBypasses();
        System.assert(returnedValue!='');
    }
    @isTest static void testHostReassigmentLogicForFloat(){
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
        insert p;
         TriggerHandler.bypass('Sales_OrderTriggerHandler');
         Order o = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Sample Order');
        PricebookEntry standardPrice1 = Sales_TestFactory_Utility.createPriceBookEntry(p.Id, Test.getStandardPricebookId());
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o.Id, p.Id, standardPrice1.Id);
        Sales_Host__c testComputer=Sales_TestDataFactory.createComputerRecord();
        insert testComputer;
        TriggerHandler.bypass('Sales_LicenseTriggerHandler');
        Sales_License__c testLicense = Sales_TestDataFactory.createLicenseRecord();
        testLicense.Sales_License_Web_Display_Flag__c = true;
        testLicense.Sales_License_Product__c = p.Id;
        testLicense.Sales_License_Status__c='Licensed';
        testLicense.Sales_License_Avbl_Rehost_Nbr__c=3;
        testLicense.Sales_License_Order__c=o.id;
        testLicense.Sales_License_Order_Product__c=oi.id;
        insert testLicense;
        Sales_License__c testLicense1 = Sales_TestDataFactory.createLicenseRecord();
        testLicense1.Sales_License_Web_Display_Flag__c = true;
        testLicense1.Sales_License_Host_Node_Id__c = testComputer.Id;
        testLicense1.Sales_License_Product__c = p.Id;
        testLicense1.Sales_License_Status__c='Licensed';
        testLicense1.Sales_License_Avbl_Rehost_Nbr__c=3;
            testLicense1.Sales_License_Order__c=o.id;
        testLicense1.Sales_License_Order_Product__c=oi.id;
        insert testLicense1;
        TriggerHandler.clearBypass('Sales_LicenseTriggerHandler');
        Test.startTest();
        String returnedValue = Sales_LicenseGenerationGenericFunctions.hostReassigmentLogic(new Map<Id,Id>{testComputer.Id => testLicense.Id});
        Test.stopTest();
        TriggerHandler.clearAllBypasses();
        System.assert(returnedValue!='');
    }
    @isTest static void testHostReassigmentLogicForFixedWithNoAvailableRehost(){
        Sales_License_Generator__c lGen = Sales_TestDataFactory.createLicenseGenerator();
        insert lGen;
        Sales_License_Group__c lgp = Sales_TestDataFactory.createLicenseGroup();
        lgp.Sales_License_Generator__c = lGen.id ;
        insert lgp;
        Core_Product_Ext_Attribute__c l1 = Sales_TestDataFactory.createProductExternalAttributes();
        l1.Core_SW_Lic_Group_Id__c = lgp.id;
        l1.Core_SW_Lic_Type_Nm__c = 'FIXED';
        l1.Core_SW_Prod_Expiration_Duration_Nbr__c = 45;
        l1.Core_SW_Lic_Group_Id__c = lgp.Id;
        insert l1;
        Product2 p = Sales_TestDataFactory.createProduct();
        p.Core_OPN__c='TESTFLOAT';
        p.Core_Product_Ext_Attribute_Id__c  = l1.Id;
        insert p;
         TriggerHandler.bypass('Sales_OrderTriggerHandler');
           Order o = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Sample Order');
        PricebookEntry standardPrice1 = Sales_TestFactory_Utility.createPriceBookEntry(p.Id, Test.getStandardPricebookId());
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o.Id, p.Id, standardPrice1.Id);
        Sales_Host__c testComputer=Sales_TestDataFactory.createComputerRecord();
        insert testComputer;
        TriggerHandler.bypass('Sales_LicenseTriggerHandler');
        Sales_License__c testLicense = Sales_TestDataFactory.createLicenseRecord();
        testLicense.Sales_License_Web_Display_Flag__c = true;
        testLicense.Sales_License_Host_Node_Id__c = testComputer.Id;
        testLicense.Sales_License_Product__c = p.Id;
        testLicense.Sales_License_Avbl_Rehost_Nbr__c = 0;
            testLicense.Sales_License_Order__c=o.id;
        testLicense.Sales_License_Order_Product__c=oi.id;
        insert testLicense;
        TriggerHandler.clearBypass('Sales_LicenseTriggerHandler');
        Test.startTest();
        String returnedValue = Sales_LicenseGenerationGenericFunctions.hostReassigmentLogic(new Map<Id,Id>{testComputer.Id => testLicense.Id});
        Test.stopTest();
        TriggerHandler.clearAllBypasses();
        System.assert(returnedValue!='');
    }
    @isTest static void testHostReassigmentLogicForFixedWithAvailableRehost(){
        Sales_License_Generator__c lGen = Sales_TestDataFactory.createLicenseGenerator();
        insert lGen;
        Sales_License_Group__c lgp = Sales_TestDataFactory.createLicenseGroup();
        lgp.Sales_License_Generator__c = lGen.id ;
        insert lgp;
        Core_Product_Ext_Attribute__c l1 = Sales_TestDataFactory.createProductExternalAttributes();
        l1.Core_SW_Lic_Group_Id__c = lgp.id;
        l1.Core_SW_Lic_Type_Nm__c = 'FIXED';
        l1.Core_SW_Prod_Expiration_Duration_Nbr__c = 45;
        l1.Core_SW_Lic_Group_Id__c = lgp.Id;
        insert l1;
        Product2 p = Sales_TestDataFactory.createProduct();
        p.Core_OPN__c='TESTFLOAT';
        p.Core_Product_Ext_Attribute_Id__c  = l1.Id;
        insert p;
         TriggerHandler.bypass('Sales_OrderTriggerHandler');
           Order o = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Sample Order');
        PricebookEntry standardPrice1 = Sales_TestFactory_Utility.createPriceBookEntry(p.Id, Test.getStandardPricebookId());
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o.Id, p.Id, standardPrice1.Id);
        Sales_Host__c testComputer=Sales_TestDataFactory.createComputerRecord();
        insert testComputer;
        TriggerHandler.bypass('Sales_LicenseTriggerHandler');
        Sales_License__c testLicense = Sales_TestDataFactory.createLicenseRecord();
        testLicense.Sales_License_Web_Display_Flag__c = true;
         testLicense.Sales_License_Order__c=o.id;
        testLicense.Sales_License_Order_Product__c=oi.id;
        testLicense.Sales_License_Product__c = p.Id;
        insert testLicense;
        Sales_License__c testLicense1 = Sales_TestDataFactory.createLicenseRecord();
        testLicense1.Sales_License_Web_Display_Flag__c = true;
        testLicense1.Sales_License_Host_Node_Id__c = testComputer.Id;
        testLicense1.Sales_License_Product__c = p.Id;
          testLicense1.Sales_License_Order__c=o.id;
        testLicense1.Sales_License_Order_Product__c=oi.id;
        insert testLicense1;
        TriggerHandler.clearBypass('Sales_LicenseTriggerHandler');
        TriggerHandler.clearAllBypasses();
        Test.startTest();
        String returnedValue = Sales_LicenseGenerationGenericFunctions.hostReassigmentLogic(new Map<Id,Id>{testComputer.Id => testLicense.Id,
            testLicense.Id => testLicense.Id});
        Test.stopTest();
    }
    public static Sales_License_Admin_Delegate__c createPriAdmDlgAdmRecord(Id primAdmContactId, Id dlgAdmContactId){
        Sales_License_Admin_Delegate__c licAdmDlg1 = Sales_TestDataFactory.createLicenseAdminDelegateRecord(new Map<String,String>{});
        licAdmDlg1.Sales_License_PrimaryAdmin_Contact__c = primAdmContactId;
        licAdmDlg1.Sales_License_DlgAdmin_Contact__c = dlgAdmContactId;
        return licAdmDlg1;
    }
    public static Account createAccount_PartnerandNonpartner_PSGDownstream(String CoreAccountType, String Acctype){
        Account acc = Sales_TestDataFactory.createDefaultAccount();
        acc.Core_PSG_Account__c=true;   
        acc.Core_Account_Type__c = CoreAccountType;
        acc.Type = Acctype;
        return acc;
    }
    public static Contact createContactWithDetails(Id accId, String fName, String lName, String emailId){
        Contact con = Sales_TestDataFactory.createContactRecord();
        con.FirstName = fName;
        con.LastName = lName;
        con.Email = emailId;
        con.AccountId = accId;
        return con;
    }
    @isTest static void validateDateLogic(){
        Date getLastDay = Sales_LicenseGenerationGenericFunctions.getLastDateOfMonth(Date.today());
    }
    @isTest static void testappyRenewal(){
        Sales_License_Generator__c lGen = Sales_TestDataFactory.createLicenseGenerator();
        insert lGen;
        Sales_License_Group__c lgp = Sales_TestDataFactory.createLicenseGroup();
        lgp.Sales_License_Generator__c = lGen.id ;
        insert lgp;
        Core_Product_Ext_Attribute__c l1 = Sales_TestDataFactory.createProductExternalAttributes();
        l1.Core_SW_Lic_Group_Id__c = lgp.id;
        l1.Core_SW_Lic_Type_Nm__c = 'FIXED';
        l1.Core_SW_Prod_Expiration_Duration_Nbr__c = 45;
        L1.Core_SW_Lic_Renewal_Period_Nbr__c=12;
        l1.Core_SW_Lic_Group_Id__c = lgp.Id;
        insert l1;
        Product2 p = Sales_TestDataFactory.createProduct();
        p.Core_OPN__c='TESTFLOAT';
        p.SBQQ__SubscriptionTerm__c = 90;
        p.Core_Product_Ext_Attribute_Id__c  = l1.Id;
        insert p;
         TriggerHandler.bypass('Sales_OrderTriggerHandler');
        Order o1 = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Sample Order');
        PricebookEntry standardPrice1 = Sales_TestFactory_Utility.createPriceBookEntry(p.Id, Test.getStandardPricebookId());
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o1.Id, p.Id, standardPrice1.Id);
        Sales_Host__c testComputer=Sales_TestDataFactory.createComputerRecord();
        insert testComputer;
        List<Sales_License__c> licenseList = new List<Sales_License__c>();
        Sales_License__c testLicense = Sales_TestDataFactory.createLicenseRecord();
        testLicense.Sales_License_Web_Display_Flag__c = true;
        testLicense.Sales_License_Host_Node_Id__c = testComputer.Id;
        testLicense.Sales_License_Product__c = p.Id;
        testLicense.Sales_License_Maintenance_Exp_Dt__c=System.today()+10;
        testLicense.Sales_License_Expiration_Date_Dt__c = System.today()+10;
        testLicense.Sales_License_Status__c ='Licensed';
        testLicense.Sales_License_Type__c='Original';
          testLicense.Sales_License_Order__c=o1.id;
        testLicense.Sales_License_Order_Product__c=oi.id;
        insert testLicense;
        licenseList.add(testLicense);
        o1.Sales_PO_Number_Txt__c = 'syu4742t8hwgu64';
        update o1;
        Test.startTest();
        System.Test.setMock(HttpCalloutMock.class, new LicenseFileGenerationCalloutMock());
        Sales_LicenseGenerationGenericFunctions.applyRenewals(licenseList);
        Test.stopTest();
        TriggerHandler.clearAllBypasses();
    }
    @isTest static void testappyRenewalwithoutdays(){
        Sales_License_Generator__c lGen = Sales_TestDataFactory.createLicenseGenerator();
        insert lGen;
        Sales_License_Group__c lgp = Sales_TestDataFactory.createLicenseGroup();
        lgp.Sales_License_Generator__c = lGen.id ;
        insert lgp;
        Core_Product_Ext_Attribute__c l1 = Sales_TestDataFactory.createProductExternalAttributes();
        l1.Core_SW_Lic_Group_Id__c = lgp.id;
        l1.Core_SW_Lic_Type_Nm__c = 'FIXED';
        l1.Core_SW_Lic_Group_Id__c = lgp.Id;
        insert l1;
        Product2 p = Sales_TestDataFactory.createProduct();
        p.Core_OPN__c='TESTFLOAT';
        p.Core_Product_Ext_Attribute_Id__c  = l1.Id;
        insert p;
         TriggerHandler.bypass('Sales_OrderTriggerHandler');
         Order o1 = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Sample Order');
        PricebookEntry standardPrice1 = Sales_TestFactory_Utility.createPriceBookEntry(p.Id, Test.getStandardPricebookId());
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o1.Id, p.Id, standardPrice1.Id);
        Sales_Host__c testComputer=Sales_TestDataFactory.createComputerRecord();
        insert testComputer;
        List<Sales_License__c> licenseList = new List<Sales_License__c>();
        Sales_License__c testLicense = Sales_TestDataFactory.createLicenseRecord();
        testLicense.Sales_License_Web_Display_Flag__c = true;
        testLicense.Sales_License_Host_Node_Id__c = testComputer.Id;
        testLicense.Sales_License_Product__c = p.Id;
        testLicense.Sales_License_Maintenance_Exp_Dt__c=System.today()+10;
        testLicense.Sales_License_Expiration_Date_Dt__c = System.today()+10;
        testLicense.Sales_License_Status__c ='Licensed';
        testLicense.Sales_License_Type__c='Original';
         testLicense.Sales_License_Order__c=o1.id;
        testLicense.Sales_License_Order_Product__c=oi.id;
        insert testLicense;
        licenseList.add(testLicense);
        o1.Sales_PO_Number_Txt__c = 'syu4742t8hwgu64';
        update o1;
        Test.startTest();
        System.Test.setMock(HttpCalloutMock.class, new LicenseFileGenerationCalloutMock());
        Sales_LicenseGenerationGenericFunctions.applyRenewals(licenseList);
        Test.stopTest();
        TriggerHandler.clearAllBypasses();
    }
    @isTest static void testappyRenewal1(){
        Sales_License_Generator__c lGen = Sales_TestDataFactory.createLicenseGenerator();
        insert lGen;
        Sales_License_Group__c lgp = Sales_TestDataFactory.createLicenseGroup();
        lgp.Sales_License_Generator__c = lGen.id ;
        insert lgp;
        Core_Product_Ext_Attribute__c l1 = Sales_TestDataFactory.createProductExternalAttributes();
        l1.Core_SW_Lic_Group_Id__c = lgp.id;
        l1.Core_SW_Lic_Type_Nm__c = 'FIXED';
        l1.Core_SW_Prod_Expiration_Duration_Nbr__c = 45;
        l1.Core_SW_Lic_Group_Id__c = lgp.Id;
        insert l1;
        Product2 p = Sales_TestDataFactory.createProduct();
        p.Core_OPN__c='TESTFLOAT';
        p.SBQQ__SubscriptionTerm__c = 90;
        p.Core_Product_Ext_Attribute_Id__c  = l1.Id;
        insert p;
         TriggerHandler.bypass('Sales_OrderTriggerHandler');
         Order o1= Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Sample Order');
        PricebookEntry standardPrice1 = Sales_TestFactory_Utility.createPriceBookEntry(p.Id, Test.getStandardPricebookId());
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o1.Id, p.Id, standardPrice1.Id);
        Sales_Host__c testComputer=Sales_TestDataFactory.createComputerRecord();
        insert testComputer;
        List<Sales_License__c> licenseList = new List<Sales_License__c>();
        Sales_License__c testLicense = Sales_TestDataFactory.createLicenseRecord();
        testLicense.Sales_License_Web_Display_Flag__c = true;
        testLicense.Sales_License_Host_Node_Id__c = testComputer.Id;
        testLicense.Sales_License_Product__c = p.Id;
        testLicense.Sales_License_Maintenance_Exp_Dt__c=System.today()-20;
        testLicense.Sales_License_Expiration_Date_Dt__c = System.today()-20;
        testLicense.Sales_License_Status__c ='Licensed';
        testLicense.Sales_License_Type__c='Original';
         testLicense.Sales_License_Order__c=o1.id;
        testLicense.Sales_License_Order_Product__c=oi.id;
        insert testLicense;
        licenseList.add(testLicense);
        o1.Sales_PO_Number_Txt__c = 'syu4742t8hwgu64';
        update o1;
        Test.startTest();
        System.Test.setMock(HttpCalloutMock.class, new LicenseFileGenerationCalloutMock());
        Sales_LicenseGenerationGenericFunctions.applyRenewals(licenseList);
        Test.stopTest();
        TriggerHandler.clearAllBypasses();
    }
    @isTest static void testappyRenewal2(){
        Sales_License_Generator__c lGen = Sales_TestDataFactory.createLicenseGenerator();
        insert lGen;
        Sales_License_Group__c lgp = Sales_TestDataFactory.createLicenseGroup();
        lgp.Sales_License_Generator__c = lGen.id ;
        insert lgp;
        Core_Product_Ext_Attribute__c l1 = Sales_TestDataFactory.createProductExternalAttributes();
        l1.Core_SW_Lic_Group_Id__c = lgp.id;
        l1.Core_SW_Lic_Type_Nm__c = 'FIXED';
        l1.Core_SW_Prod_Expiration_Duration_Nbr__c = 45;
        l1.Core_SW_Lic_Group_Id__c = lgp.Id;
        insert l1;
        Product2 p = Sales_TestDataFactory.createProduct();
        p.Core_OPN__c='TESTFLOAT';
        p.SBQQ__SubscriptionTerm__c = 90;
        p.Core_Product_Ext_Attribute_Id__c  = l1.Id;
        insert p;
         TriggerHandler.bypass('Sales_OrderTriggerHandler');
         Order o1 = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Sample Order');
        PricebookEntry standardPrice1 = Sales_TestFactory_Utility.createPriceBookEntry(p.Id, Test.getStandardPricebookId());
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o1.Id, p.Id, standardPrice1.Id);
        Sales_Host__c testComputer=Sales_TestDataFactory.createComputerRecord();
        insert testComputer;
        List<Sales_License__c> licenseList = new List<Sales_License__c>();
        Sales_License__c testLicense = Sales_TestDataFactory.createLicenseRecord();
        testLicense.Sales_License_Web_Display_Flag__c = true;
        testLicense.Sales_License_Host_Node_Id__c = testComputer.Id;
        testLicense.Sales_License_Product__c = p.Id;
        testLicense.Sales_License_Maintenance_Exp_Dt__c=System.today()+10;
        testLicense.Sales_License_Expiration_Date_Dt__c = System.today()+10;
        testLicense.Sales_License_Status__c ='Licensed';
        testLicense.Sales_License_Type__c='Original';
         testLicense.Sales_License_Order__c=o1.id;
        testLicense.Sales_License_Order_Product__c=oi.id;
        insert testLicense;
        licenseList.add(testLicense);
        o1.Sales_PO_Number_Txt__c = 'syu4742t8hwgu64';
        update o1;
        Test.startTest();
        System.Test.setMock(HttpCalloutMock.class, new LicenseFileGenerationCalloutMock());
        Sales_LicenseGenerationGenericFunctions.applyRenewals(licenseList);
        Test.stopTest();
        TriggerHandler.clearAllBypasses();
    }
    @isTest static void testappyRenewal4(){
        Sales_License_Generator__c lGen = Sales_TestDataFactory.createLicenseGenerator();
        insert lGen;
        Sales_License_Group__c lgp = Sales_TestDataFactory.createLicenseGroup();
        lgp.Sales_License_Generator__c = lGen.id ;
        insert lgp;
        Core_Product_Ext_Attribute__c l1 = Sales_TestDataFactory.createProductExternalAttributes();
        l1.Core_SW_Lic_Group_Id__c = lgp.id;
        l1.Core_SW_Lic_Type_Nm__c = 'FIXED';
        l1.Core_SW_Prod_Expiration_Duration_Nbr__c = 45;
        L1.Core_SW_Lic_Renewal_Period_Nbr__c=12;
        l1.Core_SW_Lic_Group_Id__c = lgp.Id;
        insert l1;
        Product2 p = Sales_TestDataFactory.createProduct();
        p.Core_OPN__c='TESTFLOAT';
        p.SBQQ__SubscriptionTerm__c = 90;
        p.Core_Product_Ext_Attribute_Id__c  = l1.Id;
        insert p;
         TriggerHandler.bypass('Sales_OrderTriggerHandler');
         Order o1 = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Sample Order');
        PricebookEntry standardPrice1 = Sales_TestFactory_Utility.createPriceBookEntry(p.Id, Test.getStandardPricebookId());
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o1.Id, p.Id, standardPrice1.Id);
        Sales_Host__c testComputer=Sales_TestDataFactory.createComputerRecord();
        insert testComputer;
        List<Sales_License__c> licenseList = new List<Sales_License__c>();
        Sales_License__c testLicense = Sales_TestDataFactory.createLicenseRecord();
        testLicense.Sales_License_Web_Display_Flag__c = true;
        testLicense.Sales_License_Host_Node_Id__c = testComputer.Id;
        testLicense.Sales_License_Product__c = p.Id;
        testLicense.Sales_License_Maintenance_Exp_Dt__c=System.today()-10;
        testLicense.Sales_License_Expiration_Date_Dt__c = System.today()-10;
        testLicense.Sales_License_Status__c ='Licensed';
        testLicense.Sales_License_Type__c='Original';
         testLicense.Sales_License_Order__c=o1.id;
        testLicense.Sales_License_Order_Product__c=oi.id;
        insert testLicense;
        licenseList.add(testLicense);
        o1.Sales_PO_Number_Txt__c = 'syu4742t8hwgu64';
        update o1;
        Test.startTest();
        System.Test.setMock(HttpCalloutMock.class, new LicenseFileGenerationCalloutMock());
        Sales_LicenseGenerationGenericFunctions.applyRenewals(licenseList);
        Test.stopTest();
        TriggerHandler.clearAllBypasses();
    }
    public class LicenseFileGenerationCalloutMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"Status" : "Success","Comment" : "License File processed successfully for given Batch Id."}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }*/
}