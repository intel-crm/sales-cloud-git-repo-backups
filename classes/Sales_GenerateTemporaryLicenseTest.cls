/*********************************************************************************************************************
Class Name    : Sales_GenerateTemporaryLicenseTest
Created By 	  : Srishty Sharma
Created Date  : July 2021
Function      : Test class for Sales_GenerateTemporaryLicense
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Srishty Sharma           17-July-2021              Test class for Sales_GenerateTemporaryLicense
* *********************************************************************************************************************/
@isTest
public class Sales_GenerateTemporaryLicenseTest {
	@isTest
    private static void shouldValidateTemporaryNICId(){
        Sales_Host__c testComputer=Sales_TestDataFactory.createComputerRecord();
        testComputer.Sales_License_Type__c = 'FLOAT';
        testComputer.Temporary_NIC_ID__c = '123abcdef222';
        insert testComputer;
        Sales_License_Generator__c lGen = Sales_TestDataFactory.createLicenseGenerator();
        insert lGen;
        Sales_License_Group__c lgp = Sales_TestDataFactory.createLicenseGroup();
        lgp.Sales_License_Generator__c = lGen.id ;
        insert lgp;
        Product2 p = Sales_TestDataFactory.createProduct();
        p.SBQQ__SubscriptionTerm__c=10;
        insert p;
        Core_Product_Ext_Attribute__c l1 = Sales_TestDataFactory.createProductExternalAttributes();
        l1.Core_SW_Lic_Group_Id__c = lgp.id;
        l1.Core_SW_Lic_Type_Nm__c = 'FLOAT';
        l1.Core_SW_Prod_Expiration_Duration_Nbr__c = 45;
        l1.Core_SW_Prod_Non_Commercial_Purpose_Nm__c='Employee';
        l1.Core_Foundation_Product_Id__c=p.id;
        l1.Core_Product_Id__c=p.id;
        insert l1;
        TriggerHandler.bypass('Sales_LicenseTriggerHandler');
        Sales_License__c testLicense = Sales_TestDataFactory.createLicenseRecord();
        testLicense.Sales_License_Product__c = p.Id;
        testLicense.Sales_License_Host_Node_Id__c = testComputer.Id;
        testLicense.Sales_License_Available_Temp_Licenses__c = 1;
        insert testLicense;
        TriggerHandler.clearBypass('Sales_LicenseTriggerHandler');
        Test.startTest();
        Boolean returnedValue = Sales_GenerateTemporaryLicense.validateTemporaryNICId(testComputer.Id);
        Test.stopTest();
        System.assert(returnedValue, 'Should return true');
    }
}