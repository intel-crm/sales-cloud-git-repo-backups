@isTest(seeAllData = false)
public class Core_DDR_Import_Controller_Test
{
    static testmethod void testfileuploadCsv1()
    {
        String strFile = 'Group ID,Header/Product\n1,Header';
        
        String[] csvFileLines;
        Blob csvFileBody;    
        
        //updated by RD 12/11
        list<Core_Design_Registrations_Bulk_Upload__c> lstDesignBulkUpload = new list<Core_Design_Registrations_Bulk_Upload__c>();
        lstDesignBulkUpload.add(new Core_Design_Registrations_Bulk_Upload__c(name = 'Group ID', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Group_Id__c', Core_CSV_Column_Nm__c= 'Group Id', Core_Stage_API_Field_Nm__c= 'Core_Group_Id__c'));
        lstDesignBulkUpload.add(new Core_Design_Registrations_Bulk_Upload__c(name = 'Header/Product', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Header_Or_Product_Ind__c', Core_CSV_Column_Nm__c= 'Header/Product', Core_Stage_API_Field_Nm__c= 'Core_Header_Or_Product_Ind__c'));
        lstDesignBulkUpload.add(new Core_Design_Registrations_Bulk_Upload__c(name = 'Comments', Core_Active_Ind__c = true, Core_Design_API_Field_Nm__c = 'Core_Comment_Txt__c', Core_CSV_Column_Nm__c= 'Comments', Core_Stage_API_Field_Nm__c= 'Core_Comment_Txt__c'));
        insert lstDesignBulkUpload;
        
        list<Core_DDR_Special_Character_Replacement__c> lstSpecialcharactersToHandle = new list<Core_DDR_Special_Character_Replacement__c>(); 
        lstSpecialcharactersToHandle.add(new  Core_DDR_Special_Character_Replacement__c(name = 'Trademark Symbol', Actual_Character__c = '™', Junk_Character__c = ''));
        insert lstSpecialcharactersToHandle;
        
        List<Core_LogEntry_Switch__c> LogEntryLst = new List<Core_LogEntry_Switch__c>{new Core_LogEntry_Switch__c(name = 'Core_DDR_LogEntry_Check', Is_Selected__c = true)};
        insert LogEntryLst;
        
        //Happy path
        csvFileBody = blob.valueof(strFile);
        Core_DDR_Import_Controller importData7430 = new Core_DDR_Import_Controller();
        importData7430.csvAsString = 'csv';
        importData7430.stopText = 'StopText';
        importData7430.isDisplayingMessage  = false;
        importData7430.csvFileBody = csvFileBody;
        importData7430.getIsPartnerUser();
        importData7430.getdesignBatch();
        importData7430.getBatchMessage();
        importData7430.getBatchId();
        importData7430.importCSVFile(); 
        
        //Give long characters
        strFile = 'Group ID,Header/Product,Comments\n1,Header,fojwefriueriuerqewtrnfnfnnfnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnfffffffffffnnfffffffffffffffffffffffffnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnfnnffnfnnfnf';
        
        csvFileBody = blob.valueof(strFile);
        Core_DDR_Import_Controller importData74301 = new Core_DDR_Import_Controller();
        importData74301.csvAsString = 'csv';
        importData74301.stopText = 'StopText';
        importData74301.isDisplayingMessage  = false;
        importData74301.csvFileBody = csvFileBody;
        importData74301.getIsPartnerUser();
        importData74301.getdesignBatch();
        importData74301.getBatchMessage();
        importData74301.getBatchId();
        importData74301.importCSVFile(); 
                
        //Group Id or Header. Product not proper values 
        strFile = 'Group ID,Header/Product\n1,Header1';
        
        csvFileBody = blob.valueof(strFile);
        Core_DDR_Import_Controller importData7431 = new Core_DDR_Import_Controller();
        importData7431.csvAsString = 'csv';
        importData7431.stopText = 'StopText';
        importData7431.isDisplayingMessage  = false;
        importData7431.csvFileBody = csvFileBody;
        importData7431.importCSVFile();  
        
        //No groupId or Header Value Find
        strFile = 'Group ID,Header/Product\n,1,Header1';

        csvFileBody = blob.valueof(strFile);
        Core_DDR_Import_Controller importData7432 = new Core_DDR_Import_Controller();
        importData7432.csvAsString = 'csv';
        importData7432.stopText = 'StopText';
        importData7432.isDisplayingMessage  = false;
        importData7432.csvFileBody = csvFileBody;
        importData7432.importCSVFile();   
        
        //Non numeric groupId
        strFile = 'Group ID,Header/Product\ntest,Header1';

        csvFileBody = blob.valueof(strFile);
        Core_DDR_Import_Controller importData7433 = new Core_DDR_Import_Controller();
        importData7433.csvAsString = 'csv';
        importData7433.stopText = 'StopText';
        importData7433.isDisplayingMessage  = false;
        importData7433.csvFileBody = csvFileBody;
        importData7433.importCSVFile(); 
        
        //Non csv file
        strFile = 'Group ID,Header/Product\ntest,Header1';

        csvFileBody = blob.valueof(strFile);
        Core_DDR_Import_Controller importData7434 = new Core_DDR_Import_Controller();
        importData7434.csvAsString = 'test';
        importData7434.stopText = 'StopText';
        importData7434.isDisplayingMessage  = false;
        importData7434.csvFileBody = csvFileBody;
        importData7434.importCSVFile(); 
        
        test.startTest();
        //Exception
        delete lstSpecialcharactersToHandle;
        
        //Give long characters
        strFile = 'Group ID,Header/Product,Test\n1,Header,test,,,';
        
        csvFileBody = blob.valueof(strFile);
        Core_DDR_Import_Controller importData7435 = new Core_DDR_Import_Controller();
        importData7435.csvAsString = 'csv';
        importData7435.stopText = 'StopText';
        importData7435.isDisplayingMessage  = false;
        importData7435.csvFileBody = csvFileBody;
        importData7435.getIsPartnerUser();
        importData7435.getdesignBatch();
        importData7435.getBatchMessage();
        importData7435.getBatchId();
        importData7435.importCSVFile(); 
        
            
    }
}