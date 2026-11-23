/*********************************************************************************************************************
Class Name    : Sales_LicenseRecordPageCompUtilityTest
Version       : 1.0
Created Date  : July 2021
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Srishty Sharma           20-Jan-2021             Test class for Sales_LicenseRecordPageComponentsUtility 
* *********************************************************************************************************************/
@isTest
public class Sales_LicenseRecordPageCompUtilityTest
{
    /*static testmethod void testLicensepage(){
        Account acc = Sales_TestDataFactory.createDefaultAccount();
        insert acc;
        Contact con1 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        Contact con2 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        insert new List<Contact>{con1,con2};
            Sales_License_Admin_Delegate__c licAdmDlg = Sales_TestDataFactory.createLicenseAdminDelegateRecord(new Map<String,String>{
                'Sales_License_PrimaryAdmin_Contact__c' => con1.Id , 'Sales_License_DlgAdmin_Contact__c' => con2.Id
                    }); 
        insert licAdmDlg;
         Sales_Host__c host =Sales_TestDataFactory.createComputerRecord();
        insert host;
        host.Sales_Computer_Name_Txt__c ='ABC';
        host.Sales_Contact__c=con2.id;
        host.Sales_isActiveHost__c=true;
        host.Sales_License_Type__c='FLOAT';
        update host;
        Core_Product_Ext_Attribute__c prodExt1 = Sales_TestDataFactory.createProductExternalAttributes();
    prodExt1.Core_SW_Lic_Type_Nm__c ='FLOAT';
    prodExt1.Core_SW_Prod_Expiration_Duration_Nbr__c = 20;
    prodExt1.Core_SW_Lic_Renewal_Period_Nbr__c =45;        
        insert prodExt1;
        Product2 prod1 = Sales_TestDataFactory.createProduct();
        prod1.Core_Product_Ext_Attribute_Id__c =prodExt1.Id;
        insert prod1;
        TriggerHandler.bypass('Sales_OrderTriggerHandler');
         Order o = Sales_TestFactory_Utility.createOrders(null, Test.getStandardPricebookId(), 'Sample Order');
        PricebookEntry standardPrice1 = Sales_TestFactory_Utility.createPriceBookEntry(prod1.Id, Test.getStandardPricebookId());
          TriggerHandler.bypass('Sales_OrderProductTriggerHandler');
        OrderItem oi = Sales_TestFactory_Utility.createOrderProduct(o.Id, prod1.Id, standardPrice1.Id);
        Sales_License__c license=Sales_TestDataFactory.createLicenseRecord();
        license.Sales_License_Product__c=prod1.Id;
        license.Sales_License_Host_Node_Id__c=host.Id;
        license.Sales_License_Primary_Admin_Contact__c=con2.id;
         license.Sales_License_Order__c=o.id;license.Sales_License_Order_Product__c=oi.id;
         TriggerHandler.bypass('Sales_LicenseTriggerHandler');
        insert license;
        TriggerHandler.clearBypass('Sales_LicenseTriggerHandler');
        license.Sales_License_Expiration_Date_Dt__c=System.today().addDays(2);
        license.Sales_License_Maintenance_Exp_Dt__c=date.newInstance(2008, 1, 1);
        TriggerHandler.bypass('Sales_LicenseTriggerHandler');
        update license;
        TriggerHandler.clearBypass('Sales_LicenseTriggerHandler');
        List<Id> saleslicenselist= new List<Id>();
        for(Sales_License__c  s: [Select Id from Sales_License__c])
        {
            saleslicenselist.add(s.Id);
        }
        test.startTest();
        Sales_LicenseRecordPageComponentsUtility.askForReassignment(license.Sales_License_Host_Node_Id__c,license.Id);
     Sales_LicenseRecordPageComponentsUtility.createHostonLicenseRecord(license.Sales_License_Host_Node_Id__c,license.Id);
     Sales_LicenseRecordPageComponentsUtility.LicenseTypeCheck(license.Sales_License_Host_Node_Id__c,license.Id);
         Sales_LicenseRecordPageComponentsUtility.hostReassignment(license.Sales_License_Host_Node_Id__c,license.Id);
         Sales_LicenseRecordPageComponentsUtility.retriveComputerDetails('ABC',license.Sales_License_Activation_Code__c,licAdmDlg.Sales_License_DlgAdmin_Contact__c);
         Sales_LicenseRecordPageComponentsUtility.splitReassignment(license.Sales_License_Host_Node_Id__c,saleslicenselist);
         Sales_LicenseRecordPageComponentsUtility.validateComputerId(host.Name);
         Sales_LicenseRecordPageComponentsUtility.hostReassignmentonAllLicensesonSplit(license.Sales_License_Host_Node_Id__c,license.Id);
        test.stopTest();
     }*/
}