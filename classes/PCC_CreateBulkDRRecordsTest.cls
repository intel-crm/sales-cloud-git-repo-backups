/*************************************************************************************************************************************
Apex Class Name     : PCC_CreateBulkDRRecordsTest
    Created Date        : May 2023
    Function            : Test class for PCC_CreateBulkDRRecords
     ************************************************************************************************************************************************/
@isTest
public class PCC_CreateBulkDRRecordsTest {
    public static String[] csvFileLines;
    public static Blob csvFileBody;
    
    @isTest
    static void testCSVFileProcessor() {
        string csvname= 'BulkDRUpload';
        // Create a CSV content for testing
        
        String str = ',"Group ID",Header/Product,"Design Registration Line ID",Product,Quantity (Full Production Year),Target Resale Price,Partner Tracking Number,Cancelled (Y),Product Comments,Registration Number,Owner (Email),Product Group,Design Registration Name,Description,Opportunity Volume,Partner FAE,Partner FSR,End Customer Name,End Customer Address1,End Customer Address2,End Customer City,End Customer State,End Customer Zip/Postal Code,End Customer Country,Contact Title,Contact Name,Contact Email,Contact Phone,Are Intel items used for MINDS?,Decision Date,First Customer Ship Date,Production End Date,Vertical Market,Intel Platform,Product Segment,Product Application,Manufacturing Region,End Customer URL,Partner FAE Email\r\n2,Product,,"Intel® Stratix®" 10 GX FPGA 1SG210HU1F50E1VG,333,333,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\r\n"3,Product,,Intel® Stratix® 10 GX FPGA 1SG210HU1F50E1VG,333,333,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\r\n';
        
        // Call the CSVFileProcessor method
        Test.startTest();
        csvFileBody = Blob.valueOf(str);
        String csvAsString = csvFileBody.toString();
        csvFileLines = csvAsString.split('\n');
        PCC_CreateBulkDRRecords.saveFile(JSON.serialize(csvAsString),csvname);
        
        Test.stopTest();
    }
    
}