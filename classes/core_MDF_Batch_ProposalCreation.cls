public without sharing class core_MDF_Batch_ProposalCreation implements Database.Batchable<sObject>, Database.Stateful {
    public String objectApiName;
    public String uploadedData;
    Map<String,String> fieldNameToAPINameMap = new Map<String,String>();
    public Integer totalRecords;
    public Id bulkUploadBatchId;
    public core_MDF_Batch_ProposalCreation(String uploadedData, Id bulkUploadBatchId, String objectApiName) {
        this.bulkUploadBatchId = bulkUploadBatchId;
        this.uploadedData = uploadedData;
        this.objectApiName = objectApiName;
    }
    public Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'Select Core_MDF_Field_Name__c, Core_MDF_Field_API_Name__c FROM Core_MDF_Upload_File_Mapping__mdt Where Core_MDF_Object_API_Name__c= :objectApiName';
        return Database.getQueryLocator(query);
    }
    public void execute (Database.BatchableContext bc, List<Core_MDF_Upload_File_Mapping__mdt> fieldNameApiMap){        
        /*for(Core_MDF_Upload_File_Mapping__mdt name : fieldNameApiMap){
            fieldNameToAPINameMap.put(name.Core_MDF_Field_Name__c, name.Core_MDF_Field_API_Name__c);
        }*/
        String data = JSON.deserializeUntyped(uploadedData).toString();
        List<String> lstCSVLines = data.split('\r\n');
        /*List<String> headerModified = new List<String>();
        String header = lstCSVLines[0];
        /*for(Integer i=0 ; i<header.size();i++){
            String h = header[i];
            headerModified.add(fieldNameToAPINameMap.get(h));
        }
        sObject columnHeader = Schema.getGlobalDescribe().get('Bulk_Upload_Batch__c').newSObject() ;
        columnHeader.put(Schema.Bulk_Upload_Batch__c.Core_MDF_Columns__c,JSON.serialize(header));
        columnHeader.put(Schema.Bulk_Upload_Batch__c.Core_MDF_Object_Name__c,objectApiName);
        columnHeader.put(Schema.Bulk_Upload_Batch__c.Core_MDF_Batch_Status__c,'Pending');
        Database.SaveResult ch = Database.insert(columnHeader,false);
        if (ch.isSuccess()) {
            // Operation was successful, so get the ID of the record that was processed
            System.debug('Successfully inserted Bulk Upload Batch. Bulk_Upload_Batch__c ID: ' + ch.getId());
            bulkUploadBatchId = ch.getId();
        }
        else {
            // Operation failed, so get all errors                
            for(Database.Error err : ch.getErrors()) {
                System.debug('The following error has occurred.');                    
                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                System.debug('Bulk Upload Batch fields that affected this error: ' + err.getFields());
            }
        }*/
        List<Sobject> recordstoupload= new List<SObject>();            
        for(Integer i=1;i<lstCSVLines.size();i++){
            String inputvalues = lstCSVLines[i];
            sObject columnData = Schema.getGlobalDescribe().get('Core_MDF_Bulk_Upload_Batch_Record__c').newSObject();
            columnData.put(Schema.Core_MDF_Bulk_Upload_Batch_Record__c.Core_MDF_Bulk_Upload_Batch_Id__c,bulkUploadBatchId);
            columnData.put(Schema.Core_MDF_Bulk_Upload_Batch_Record__c.Core_MDF_Row_Data__c,JSON.serialize(inputvalues));
            columnData.put(Schema.Core_MDF_Bulk_Upload_Batch_Record__c.Core_MDF_Status__c,'Pending Processing');
            recordstoupload.add(columnData);
        }
        totalRecords = recordstoupload.size();
        Database.SaveResult[] uploadedrec =  Database.insert(recordstoupload,false);
        for (Database.SaveResult sr : uploadedrec) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted Bulk Upload Batch Record. Core_MDF_Bulk_Upload_Batch_Record__c ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Bulk Upload Batch Record fields that affected this error: ' + err.getFields());
                }
            }
        }       
    }
    public void finish(Database.BatchableContext bc){
        Bulk_Upload_Batch__c getBatchRecord = [Select Core_MDF_Total_Record_Count__c, Core_MDF_Total_Success__c, Core_MDF_Total_Failure__c FROM Bulk_Upload_Batch__c WHERE Id = :bulkUploadBatchId];
        getBatchRecord.Core_MDF_Total_Record_Count__c = totalRecords;
        update getBatchRecord;
        System.debug('getBatchRecord'+getBatchRecord);
    }
}