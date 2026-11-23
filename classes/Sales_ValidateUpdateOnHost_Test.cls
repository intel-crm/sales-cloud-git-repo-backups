@isTest
public class Sales_ValidateUpdateOnHost_Test {
    @isTest 
    public static void testAskForhostReassigment(){
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
        Test.startTest();
        TriggerHandler.bypass('Sales_LicenseTriggerHandler');
        try{
            Sales_License__c testLicense = Sales_TestDataFactory.createLicenseRecord();
            testLicense.Sales_License_Web_Display_Flag__c = true;
            testLicense.Sales_License_Host_Node_Id__c = testComputer.Id;
            testLicense.Sales_License_Product__c=p.id;
            insert testLicense;
            Map<Id, Sales_License__c> newmap=new Map<Id, Sales_License__c>();
            newmap.put(testLicense.Id,testLicense);
            Sales_License__c testLicense1 = Sales_TestDataFactory.createLicenseRecord();
            testLicense1.Sales_License_Web_Display_Flag__c = true;
            testLicense1.Sales_License_Host_Node_Id__c = testComputer.Id;
            testLicense1.Sales_License_Product__c=p.id;
            insert testLicense1;
            newmap.put(testLicense1.Id,testLicense1);
            TriggerHandler.clearBypass('Sales_LicenseTriggerHandler');
            Sales_ValidateUpdateOnHost.askForhostReassigment1(new Set<Id>{testComputer.Id},new List<Sales_License__c>{testLicense,testLicense1},newmap);
        }
        catch(Exception e){
            System.assert(e.getMessage().contains(System.label.Sales_sameHostAssignToSameFixLic));
        }
        Test.stopTest();
    }
    @isTest static void testHostReassigmentLogicForHostWithoutLicense(){
        Sales_Host__c testComputer=Sales_TestDataFactory.createComputerRecord();
        insert testComputer;
        TriggerHandler.bypass('Sales_LicenseTriggerHandler');
        Sales_License__c testLicense = Sales_TestDataFactory.createLicenseRecord();
        testLicense.Sales_License_Web_Display_Flag__c = true;
        testLicense.Sales_License_Status__c='Licensed';
        testLicense.Sales_License_Avbl_Rehost_Nbr__c=3;
        insert testLicense;
        TriggerHandler.clearBypass('Sales_LicenseTriggerHandler');
        Test.startTest();
        try{
            TriggerHandler.bypass('Sales_LicenseTriggerHandler');
            Map<Id, Sales_License__c> oldLicMap = new Map<Id, Sales_License__c>{testLicense.Id=>testLicense};
                testLicense.Sales_License_Host_Node_Id__c = testComputer.Id;
            update testLicense;
            Sales_ValidateUpdateOnHost.hostReassigment(new List<Sales_License__c>{testLicense},oldLicMap,new Map<Id,Sales_License__c>{testLicense.Id =>testLicense});
        }catch(Exception e){
            System.assert(e.getMessage().contains(' For License Tool Type as FIXED, you can select Host with FIXED License Type / For License Tool Type as FLOAT or N-A, you can select Host with FLOAT License Type & For License Tool Type as NEUTRAL, you can select Host with FIXED/FLOAT License Type'));
        } 
        TriggerHandler.clearBypass('Sales_LicenseTriggerHandler');        
        Test.stopTest();
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
        Map<String,String> hostFieldValues = new Map<String,String>();   
        hostFieldValues.put('Sales_License_Type__c', 'FLOAT');
        hostFieldValues.put('Sales_Computer_Name_Txt__c', 'youth1');
        hostFieldValues.put('Name', '820826619578');
        Sales_Host__c testComputer = Sales_TestDataFactory.createComputerRecord(hostFieldValues);
        insert testComputer;
        TriggerHandler.bypass('Sales_LicenseTriggerHandler');
        Sales_License__c testLicense = Sales_TestDataFactory.createLicenseRecord();
        testLicense.Sales_License_Web_Display_Flag__c = true;
        testLicense.Sales_License_Product__c = p.Id;
        testLicense.Sales_License_Status__c='Licensed';
        testLicense.Sales_License_Avbl_Rehost_Nbr__c=0;
        insert testLicense;
        Sales_License__c testLicense1 = Sales_TestDataFactory.createLicenseRecord();
        testLicense1.Sales_License_Web_Display_Flag__c = true;
        testLicense1.Sales_License_Host_Node_Id__c = testComputer.Id;
        testLicense1.Sales_License_Product__c = p.Id;
        testLicense1.Sales_License_Status__c='Licensed';
        testLicense1.Sales_License_Avbl_Rehost_Nbr__c=3;
        insert testLicense1;
        TriggerHandler.clearBypass('Sales_LicenseTriggerHandler');
        Test.startTest();
        try{
            Map<Id, Sales_License__c> oldLicMap = new Map<Id, Sales_License__c>{testLicense.Id=>testLicense};
                testLicense.Sales_License_Host_Node_Id__c = testComputer.Id;
            update testLicense;
            Sales_ValidateUpdateOnHost.hostReassigment(new List<Sales_License__c>{testLicense},oldLicMap,new Map<Id,Sales_License__c>{testLicense.Id =>testLicense});
        }catch(Exception e){
            System.assert(e.getMessage().contains('This license does not have any available license rehosts. You must have at least one available license rehost to update your computer. Contact customer support to request a license rehost'));
        }
        Test.stopTest();
    }
    @isTest static void testHostReassigmentLogicForFixed(){
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
        Map<String,String> hostFieldValues = new Map<String,String>();   
        hostFieldValues.put('Sales_License_Type__c', 'FIXED');
        hostFieldValues.put('Sales_Computer_Name_Txt__c', 'youth1');
        hostFieldValues.put('Name', '820826619582');
        Sales_Host__c testComputer=Sales_TestDataFactory.createComputerRecord(hostFieldValues);
        insert testComputer;
        TriggerHandler.bypass('Sales_LicenseTriggerHandler');
        Sales_License__c testLicense = Sales_TestDataFactory.createLicenseRecord();
        testLicense.Sales_License_Web_Display_Flag__c = true;
        testLicense.Sales_License_Product__c = p.Id;
        testLicense.Sales_License_Status__c='Licensed';
        testLicense.Sales_License_Avbl_Rehost_Nbr__c=null;
        insert testLicense;
        Sales_License__c testLicense1 = Sales_TestDataFactory.createLicenseRecord();
        testLicense1.Sales_License_Web_Display_Flag__c = true;
        testLicense1.Sales_License_Host_Node_Id__c = testComputer.Id;
        testLicense1.Sales_License_Product__c = p.Id;
        testLicense1.Sales_License_Status__c='Licensed';
        testLicense1.Sales_License_Avbl_Rehost_Nbr__c=3;
        insert testLicense1;
        TriggerHandler.clearBypass('Sales_LicenseTriggerHandler');
        Test.startTest();
        try{
            Map<Id, Sales_License__c> oldLicMap = new Map<Id, Sales_License__c>{testLicense.Id=>testLicense};
                testLicense.Sales_License_Host_Node_Id__c = testComputer.Id;
            update testLicense;
            Sales_ValidateUpdateOnHost.hostReassigment(new List<Sales_License__c>{testLicense},oldLicMap,new Map<Id,Sales_License__c>{testLicense.Id =>testLicense});
        }catch(Exception e){
            System.assert(e.getMessage().contains('This license does not have any available license rehosts. You must have at least one available license rehost to update your computer. Contact customer support to request a license rehost'));
        }
        Test.stopTest();
    }
}