/*********************************************************************************************************************
Class Name    : Sales_GetComputerDetailsTest
Created By 	  : Srishty Sharma
Created Date  : July 2021
Function      : Test class for Sales_GetComputerDetails
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Srishty Sharma           17-July-2021              Test class for Sales_GetComputerDetails
* *********************************************************************************************************************/
@isTest
public class Sales_GetComputerDetailsTest {
    /*@isTest
    private static void testGetLicenseDetailsWithContactInput(){
        String errMsg='';
        Account accObj = Sales_TestFactory_Utility.createAccount(); 
        List<Contact> newContactList = new List<Contact>();
        Contact firstContact = Sales_TestDataFactory.createContactRecord();
        newContactList.add(firstContact);
        Contact c = new Contact();
        c.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('Contact',Label.Pricing_Tender_Contact_RecordType_IntelContact);   
        c.FirstName = 'FirstName';
        c.LastName = 'LastName';
        c.Email = 'FirstName@intel.com';
        c.AccountId = accObj.Id;
        c.Core_Primary_Contact__c = true;
        newContactList.add(c);
        insert newContactList;
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
        testLicense.Sales_License_Order__c=o.id;testLicense.Sales_License_Order_Product__c=oi.id;
        insert testLicense;
        TriggerHandler.clearBypass('Sales_LicenseTriggerHandler');
        Sales_License_Admin_Delegate__c licAdmin = Sales_TestDataFactory.createLicenseAdminDelegateRecord(new Map<String,String>{});
        licAdmin.Sales_License_DlgAdmin_Contact__c = firstContact.Id;
        licAdmin.Sales_License_PrimaryAdmin_Contact__c = c.Id;
        insert licAdmin;
        Sales_GetComputerDetails.ContactInput contactinput = new Sales_GetComputerDetails.ContactInput();
        contactinput.scontId = firstContact.Id;
        contactinput.activationCode = testLicense.Sales_License_Activation_Code__c;
        Test.startTest();
        try{
            List<List<Sales_GetComputerDetails.wrapperClass>> lstLic = Sales_GetComputerDetails.getLicenseDetails(new List<Sales_GetComputerDetails.ContactInput>{contactinput});
        }catch(Exception e){
            errMsg = e.getMessage();
        }        
        Test.stopTest();
         TriggerHandler.clearAllBypasses();
        System.assertEquals(errMsg,'');
    }*/
}