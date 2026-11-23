@isTest(seeAllData = false)
public class Core_DDR_Import_Controller_Test{
    
    static String str = 'Name,AccountNumber,Type,Accountsource,Industry\n Trupti Nimje,10002,Prospect,Test,Banking.csv';
    
    public static String[] csvFileLines;
    public static Blob csvFileBody;
    
    static testmethod void testfileupload(){
        Test.startTest();  
        csvFileBody = Blob.valueOf(str);
        String csvAsString = csvFileBody.toString();
        csvFileLines = csvAsString.split('\n'); 
        
        Core_DDR_Import_Controller importData = new Core_DDR_Import_Controller();
        importData.csvFileBody = csvFileBody;
        importData.importCSVFile();
        importData.getBatchId();
        importData.getBatchMessage();
        Test.stopTest();
    }
    
    static testmethod void testfileuploadCsv(){
        Test.startTest();  
        csvFileBody = blob.valueof(str);
        Core_Design_Registrations_Bulk_Upload__c DRBulkUpload = new Core_Design_Registrations_Bulk_Upload__c(name = 'Cancelled (Y)', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Design_Product_Status_Nm__c', Core_CSV_Column_Nm__c= 'Cancelled (Y)', Core_Stage_API_Field_Nm__c= 'Core_Cancelled_Ind__c');
        insert DRBulkUpload;
        Core_DDR_Special_Character_Replacement__c DDR_Sep = new Core_DDR_Special_Character_Replacement__c(name = 'Trademark', Actual_Character__c = '™', Junk_Character__c = '');
        insert DDR_Sep;
        Core_DDR_Import_Controller importData = new Core_DDR_Import_Controller();
        importData.csvAsString = 'csv';
        importData.stopText = 'StopText';
        importData.isDisplayingMessage  = false;
        importData.csvFileBody = csvFileBody;
        importData.importCSVFile();
        importData.getBatchId();
        importData.getBatchMessage();
        Test.stopTest();
    }
    
    static testmethod void testfileuploadCsv2(){
        Test.startTest();  
        csvFileBody = blob.valueof(str);
        Core_Design_Registrations_Bulk_Upload__c DRBulkUpload = new Core_Design_Registrations_Bulk_Upload__c(name = 'Cancelled (Y)', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Design_Product_Status_Nm__c', Core_CSV_Column_Nm__c= 'Cancelled (Y)', Core_Stage_API_Field_Nm__c= 'Core_Cancelled_Ind__c');
        insert DRBulkUpload;
        Core_DDR_Import_Controller importData = new Core_DDR_Import_Controller();
        importData.csvAsString = 'csv';
        importData.stopText = 'StopText';
        importData.isDisplayingMessage  = false;
        importData.csvFileBody = csvFileBody;
        importData.importCSVFile();
        importData.getBatchId();
        importData.getBatchMessage();
        Test.stopTest();
    }
    
    static testmethod void testfileuploadWord(){
        Test.startTest();  
        csvFileBody = blob.valueof(str);
        Core_DDR_Import_Controller importData = new Core_DDR_Import_Controller();
        importData.csvAsString = 'word';
        importData.csvFileBody = csvFileBody;
        importData.importCSVFile();
        importData.getBatchId();
        importData.getBatchMessage();
        Test.stopTest();
    }
}