@isTest
public class Sales_LicenseGenIntegration_Service_Test {
    @isTest
    public static void testServiceCallout(){
        Sales_LicenseGenIntegration_Service.LicenseFile_Info licenseInfoObject = new Sales_LicenseGenIntegration_Service.LicenseFile_Info();
        Test.startTest();
        Sales_LicenseGenIntegration_Service.postLicenses(licenseInfoObject);
        Test.stopTest();  
    }
    @isTest
    public static void testService(){
        Test.startTest();
        Sales_LicenseGenIntegration_Service.postLicenses(null);
        Test.stopTest();  
    }
    @isTest
    public static void testService1(){
        Account accObj = Sales_TestFactory_Utility.createAccount(); 
        Contact con = Sales_TestFactory_Utility.createContact(accObj.id);
        Sales_Host__c host= Sales_LicenseGenIntegration_Utility_Test.createHostRecord('111122223344','FIXED','NIC ID',con.Id,'','','');
        Sales_License_Generation_Req_Log__c fileTypeLogTable= new Sales_License_Generation_Req_Log__c();
        fileTypeLogTable.Sales_Host_Id__c=host.id;
        fileTypeLogTable.Sales_Status__c='Submitted';
        insert fileTypeLogTable;
        Sales_LicenseGenIntegration_Service.LicenseFile_Info LicenseFile_Data = new Sales_LicenseGenIntegration_Service.LicenseFile_Info();
        LicenseFile_Data.BatchId=fileTypeLogTable.Name;
        LicenseFile_Data.Status='Complete';
        LicenseFile_Data.Message='Success';
        LicenseFile_Data.FileString='Test file';
        LicenseFile_Data.FileType='Checkout';
        Test.startTest();
        Sales_LicenseGenIntegration_Service.postLicenses(LicenseFile_Data);
        Test.stopTest();  
    }
    @isTest
    public static void testService2(){
        Account accObj = Sales_TestFactory_Utility.createAccount(); 
        Contact con = Sales_TestFactory_Utility.createContact(accObj.id);
        Sales_Host__c host= Sales_LicenseGenIntegration_Utility_Test.createHostRecord('111122223344','FIXED','NIC ID',con.Id,'','','');
        Sales_License_Generation_Req_Log__c fileTypeLogTable= new Sales_License_Generation_Req_Log__c();
        fileTypeLogTable.Sales_Host_Id__c=host.id;
        fileTypeLogTable.Sales_Status__c='Submitted';
        insert fileTypeLogTable;
        Sales_LicenseGenIntegration_Service.LicenseFile_Info LicenseFile_Data = new Sales_LicenseGenIntegration_Service.LicenseFile_Info();
        LicenseFile_Data.BatchId=fileTypeLogTable.Name;
        LicenseFile_Data.Status='Complete';
        LicenseFile_Data.Message='Failure';
        LicenseFile_Data.FileString='Test file';
        LicenseFile_Data.FileType='Checkout';
        Test.startTest();
        Sales_LicenseGenIntegration_Service.postLicenses(LicenseFile_Data);
        Test.stopTest();  
    }
    @isTest
    public static void testServiceFailureTest(){
        Account accObj = Sales_TestFactory_Utility.createAccount(); 
        Contact con = Sales_TestFactory_Utility.createContact(accObj.id);
        Sales_Host__c host= Sales_LicenseGenIntegration_Utility_Test.createHostRecord('111122223344','FIXED','NIC ID',con.Id,'','','');
        Sales_License_Generation_Req_Log__c fileTypeLogTable= new Sales_License_Generation_Req_Log__c();
        fileTypeLogTable.Sales_Host_Id__c=host.id;
        fileTypeLogTable.Sales_Status__c='Submitted';
        insert fileTypeLogTable;
        Sales_LicenseGenIntegration_Service.LicenseFile_Info LicenseFile_Data = new Sales_LicenseGenIntegration_Service.LicenseFile_Info();
        LicenseFile_Data.BatchId=fileTypeLogTable.Name;
        LicenseFile_Data.Status='Failure';
        LicenseFile_Data.Message='Failure';
        LicenseFile_Data.FileString='Test file';
        LicenseFile_Data.FileType='Checkout';
        Test.startTest();
        Sales_LicenseGenIntegration_Service.postLicenses(LicenseFile_Data);
        Test.stopTest();  
    }
}