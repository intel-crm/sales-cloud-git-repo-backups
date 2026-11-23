/*********************************************************************************************************************
Class Name    : Sales_GetLicenseAfterComCreationTest
Created By 	  : Srishty Sharma
Created Date  : July 2021
Function      : Test class for Sales_GetLicenseAfterComputerCreation
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Srishty Sharma           17-July-2021              Test class for Sales_GetLicenseAfterComputerCreation
* *********************************************************************************************************************/
@isTest
public class Sales_GetLicenseAfterComCreationTest {
	/*@isTest
    private static void testGetLicenseDetails(){
        TriggerHandler.bypass('Sales_LicenseTriggerHandler');
        Sales_License__c testLicense = Sales_TestDataFactory.createLicenseRecord();
        insert testLicense;
        TriggerHandler.clearBypass('Sales_LicenseTriggerHandler');
        List<Sales_GetLicenseAfterComputerCreation.LicenseInput> licenseInputs = new List<Sales_GetLicenseAfterComputerCreation.LicenseInput>();
        Sales_GetLicenseAfterComputerCreation.LicenseInput licenseInput = new Sales_GetLicenseAfterComputerCreation.LicenseInput();
        licenseInput.Sales_Activation_Code = testLicense.Id;
        licenseInputs.add(licenseInput);
        Test.startTest();
        List<Sales_GetLicenseAfterComputerCreation.LicenseOutput> licenseOutputs = Sales_GetLicenseAfterComputerCreation.getLicenseDetails(licenseInputs);
        Test.stopTest();
        System.assertEquals(null, licenseOutputs[0].Computer_Name);
    }*/
}