@isTest
public class Core_MDF_IPABulkUpload_Test {
    @TestSetUp 
    static void createTestData(){
        String base64Data = '"Activity Name,Activity Description,Start Date,End Date,Campaign ID,Currency,Activity Spending Limit Local,Activity Category,Activity Type,Activity Subtype,Metrics,Are there government officials receiving benefits attending or presenting at the event?,Account,Budget Amount\r\nGowth-1,Goth desc,12/30/2020,12/30/2020,701030000006TL3AAM,USD,1,Broadcast,TV,,met,No,0010300000B7DZqAAN,1\r\nGowth-2,Goth desc,12/30/2020,12/30/2020,701030000006TL3AAM,USD,2,Broadcast,TV,,met,No,0010300000B7DZqAAN,2\r\n"';
        String objectName = 'PartnerFundRequest';
        Bulk_Upload_Batch__c bub = new Bulk_Upload_Batch__c(Core_MDF_Object_Name__c='PartnerFundRequest',Core_MDF_Columns__c='Activity Name,Activity Description,Start Date,End Date,Campaign ID,Currency,Activity Spending Limit Local,Activity Category,Activity Type,Activity Subtype,Metrics,Are there government officials receiving benefits attending or presenting at the event?,Account,Budget Amount');
        Database.SaveResult sr = Database.insert(bub);
        if(sr.isSuccess()){
            String bubId = sr.getId();
            Core_MDF_Bulk_Upload_Batch_Record__c rowdataRecord = new Core_MDF_Bulk_Upload_Batch_Record__c(Core_MDF_Row_Data__c='Gowth-1,Goth desc,12/30/2020,12/30/2020,701030000006TL3AAM,USD,1,Broadcast,TV,,met,No,0010300000B7DZqAAN,1', Core_MDF_Bulk_Upload_Batch_Id__c=bubId);
            Database.insert(rowdataRecord);
        }       
    }
    @isTest
    static void saveFile_Test() {
        Test.startTest();
        String base64Data = 'Activity Name,Activity Description,Start Date,End Date,Campaign ID,Currency,Activity Spending Limit Local,Activity Category,Activity Type,Activity Subtype,Metrics,Are there government officials receiving benefits attending or presenting at the event?,Account,Budget Amount\r\nGowth-1,Goth desc,12/30/2020,12/30/2020,701030000006TL3AAM,USD,1,Broadcast,TV,,met,No,0010300000B7DZqAAN,1\r\nGowth-2,Goth desc,12/30/2020,12/30/2020,701030000006TL3AAM,USD,2,Broadcast,TV,,met,No,0010300000B7DZqAAN,2\r';
        String objectName = 'PartnerFundRequest';
        core_MDF_IPABulkUpload_clone.saveFile(JSON.serialize(base64Data),objectName);
        String base64Data1 = '';
        String objectName1 = 'PartnerFundRequest';
        core_MDF_IPABulkUpload_clone.saveFile(JSON.serialize(base64Data1),objectName1);
        Bulk_Upload_Batch__c bub = new Bulk_Upload_Batch__c(Core_MDF_Object_Name__c='PartnerFundRequest',Core_MDF_Columns__c='Activity Name,Activity Description,Start Date,End Date,Campaign ID,Currency,Activity Spending Limit Local,Activity Category,Activity Type,Activity Subtype,Metrics,Are there government officials receiving benefits attending or presenting at the event?,Account,Budget Amount');
        Database.SaveResult sr = Database.insert(bub);
        String bubId = sr.getId();
        Core_MDF_Bulk_Upload_Batch_Record__c rowdataRecord = new Core_MDF_Bulk_Upload_Batch_Record__c(Core_MDF_Row_Data__c='Gowth-1,Goth desc,12/30/2020,12/30/2020,701030000006TL3AAM,USD,1,Broadcast,TV,,met,No,0010300000B7DZqAAN,1', Core_MDF_Bulk_Upload_Batch_Id__c=bubId);
        Database.insert(rowdataRecord);
        Boolean onlyValidate = true;
        core_MDF_IPABulkUpload_clone.validateAndSave(bubId,onlyValidate);
        Test.stopTest();
        
    }
}