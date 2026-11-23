@isTest
public class Sales_SplitSeatsOnLicenseControllerTest {
    static testmethod void testLicense(){
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
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(prod1.Id, Test.getStandardPricebookId());
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o.Id, prod1.Id, standardPrice.Id); 
        TriggerHandler.bypass('Sales_LicenseTriggerHandler');
        Sales_License__c license = Sales_TestDataFactory.createLicenseRecord();
        license.Sales_License_Order__c = o.Id;
        license.Sales_License_Order_Product__c = oi.Id;
        insert license;
        Sales_License__c license1=Sales_TestDataFactory.createLicenseRecord();
        license1.Sales_License_Order__c = o.Id;
        license1.Sales_License_Order_Product__c = oi.Id;
        insert license1;
        Sales_License__c license2=Sales_TestDataFactory.createLicenseRecord();
        license2.Sales_License_Order__c = o.Id;
        license2.Sales_License_Order_Product__c = oi.Id;
        insert license2;
        license2.Sales_License_Avbl_Rehost_Nbr__c=3;
        license2.Sales_Parent_License__c=license1.Id;
        license2.Sales_License_Maintenance_Exp_Dt__c=date.today().addYears(2);
        update license1; 
        update license2;
        license.Sales_Parent_License__c=license1.Id;
        license.Sales_License_Available_Temp_Licenses__c=17;
        license.Sales_License_Quantity__c=4;
        license.Sales_License_Maintenance_Exp_Dt__c=date.today().addYears(3);
        license.Sales_License_Type__c = 'Original';
        license.Sales_License_Host_Node_Txt__c='S000000002';
        license.Sales_License_Web_Display_Flag__c=true;
        license.Sales_License_Avbl_Rehost_Nbr__c=4;
        update license;
        Sales_License_Order_Product__c sp=new Sales_License_Order_Product__c();
        sp.Sales_License__c=license.Id;
        insert sp;
        Sales_License_Order_Product__c sp1=new Sales_License_Order_Product__c();
        sp1.Sales_License__c=license2.Id;
        insert sp1;
        sp1.Sales_Quantity__c=4;
        sp1.Sales_License_Expiration_Date_Dt__c=date.today().addYears(3);
        update sp1;
        String newID = String.valueOf(license.Id);
        TriggerHandler.bypass('Sales_LicenseTriggerHandler');
        license.Sales_License_Avbl_Qty_Nbr__c =60;
        update license;
        List<Sales_License__c> slicense=new List<Sales_License__c>();
        slicense.add(license);
        test.startTest();
        Sales_SplitSeatsOnLicenseController.getLicenseRecord(license.Id);
        Sales_SplitSeatsOnLicenseController.splitLicenses(license,3,4);
        Sales_SplitSeatsOnLicenseController.mergeLicenseRecords(4,license,license2);
        Sales_SplitSeatsOnLicenseController.newLicenseDetails(newID);
        try{
            Sales_SplitSeatsOnLicenseController.mergeLicenseRecords(4,license,license1);
            Sales_SplitSeatsOnLicenseController.getTargetLicensesForMerging(license.Id);
        }
        catch(Exception e){
        }
        test.stopTest();
        TriggerHandler.clearAllBypasses();
        Assert.areEqual('Original',license.Sales_License_Type__c,'Licence type is original');
    }
    static testmethod void testLicense1(){
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
        PricebookEntry standardPrice = Sales_TestFactory_Utility.createPriceBookEntry(prod1.Id, Test.getStandardPricebookId());
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o.Id, prod1.Id, standardPrice.Id); 
        TriggerHandler.bypass('Sales_LicenseTriggerHandler');
        Sales_License__c license=Sales_TestDataFactory.createLicenseRecord();
        license.Sales_License_Order__c = o.Id;
        license.Sales_License_Order_Product__c = oi.Id;
        insert license;
        Sales_License__c license1=Sales_TestDataFactory.createLicenseRecord();
        license1.Sales_License_Order__c = o.Id;
        license1.Sales_License_Order_Product__c = oi.Id;
        insert license1;
        Sales_License__c license2=Sales_TestDataFactory.createLicenseRecord();
        license2.Sales_License_Order__c = o.Id;
        license2.Sales_License_Order_Product__c = oi.Id;
        insert license2;
        license2.Sales_License_Avbl_Rehost_Nbr__c=3;
        license2.Sales_Parent_License__c=license.Id;
        license2.Sales_License_Maintenance_Exp_Dt__c=date.today().addYears(2);
        update license1; 
        update license2;
        license.Sales_License_Available_Temp_Licenses__c=0;
        license.Sales_License_Quantity__c=4;
        license.Sales_License_Maintenance_Exp_Dt__c=date.today();
        license.Sales_License_Type__c = 'Original';
        license.Sales_License_Host_Node_Txt__c='S000000002';
        license.Sales_License_Web_Display_Flag__c=true;
        license.Sales_License_Avbl_Rehost_Nbr__c=4;
        update license;
        Sales_License_Order_Product__c sp=new Sales_License_Order_Product__c();
        sp.Sales_License__c=license.Id;
        insert sp;
        Sales_License_Order_Product__c sp1=new Sales_License_Order_Product__c();
        sp1.Sales_License__c=license2.Id;
        insert sp1;
        sp1.Sales_Quantity__c=4;
        sp1.Sales_License_Expiration_Date_Dt__c=date.today().addYears(3);
        update sp1;
        String newID = String.valueOf(license.Id);
        license.Sales_License_Avbl_Qty_Nbr__c =0;
        update license;
        List<Sales_License__c> slicense=new List<Sales_License__c>();
        slicense.add(license);
        test.startTest();
        Sales_SplitSeatsOnLicenseController.getLicenseRecord(license.Id);
        Sales_SplitSeatsOnLicenseController.splitLicenses(license,3,4);
        Sales_SplitSeatsOnLicenseController.mergeLicenseRecords(4,license,license2);
        Sales_SplitSeatsOnLicenseController.newLicenseDetails(newID);
        try{
            Sales_SplitSeatsOnLicenseController.mergeLicenseRecords(4,license,license1);
            Sales_SplitSeatsOnLicenseController.getTargetLicensesForMerging(license.Id);
        }
        catch(Exception e){
        }
        TriggerHandler.clearAllBypasses();
        test.stopTest();
        Assert.areEqual(4,sp1.Sales_Quantity__c,'Sales Quantity is matched');
    }
}