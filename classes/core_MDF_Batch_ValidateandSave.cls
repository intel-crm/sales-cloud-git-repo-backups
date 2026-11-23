public without sharing class core_MDF_Batch_ValidateandSave implements Database.Batchable<sObject>, Database.Stateful {
    public String bulkUploadBatch;
    public Boolean onlyValidate;
    public static Map<String,String> fieldNameToAPINameMap = new Map<String,String>();
    public static List<Core_MDF_Bulk_Upload_Batch_Record__c> childRecords = new List<Core_MDF_Bulk_Upload_Batch_Record__c>();
    public core_MDF_Batch_ValidateandSave(String bulkUploadBatch, Boolean onlyValidate) {
        this.bulkUploadBatch = bulkUploadBatch;
        this.onlyValidate = onlyValidate;
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        System.debug('bulkUploadBatch'+bulkUploadBatch);
        String query = 'SELECT Id, Core_MDF_Object_Name__c, Core_MDF_Columns__c, (Select Id, Core_MDF_Row_Data__c  From Bulk_Upload_Batch_Records__r) FROM Bulk_Upload_Batch__c Where ID=:bulkUploadBatch';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Bulk_Upload_Batch__c> buBatchScope){
        for(Bulk_Upload_Batch__c bub : buBatchScope){
            String headerData = bub.Core_MDF_Columns__c;
            Map<Id,String> rowData = new Map<Id,String>();
            String objectApiName = bub.Core_MDF_Object_Name__c;
            System.debug('objectApiName'+objectApiName);
            for(Core_MDF_Upload_File_Mapping__mdt name : [Select Core_MDF_Field_Name__c, Core_MDF_Field_API_Name__c FROM Core_MDF_Upload_File_Mapping__mdt Where Core_MDF_Object_API_Name__c= :objectApiName]){
                fieldNameToAPINameMap.put(name.Core_MDF_Field_Name__c, name.Core_MDF_Field_API_Name__c);
            }
            for(Core_MDF_Bulk_Upload_Batch_Record__c row : bub.Bulk_Upload_Batch_Records__r){
                childRecords.add(row);                          //List of Core_MDF_Bulk_Upload_Batch_Record__c records
                rowData.put(row.Id,row.Core_MDF_Row_Data__c);  // Map of Core_MDF_Bulk_Upload_Batch_Record__c Id and row data
            }
            Map<Id,SObject> records = insertData(headerData,rowData,objectApiName);
            validateAndSaveData(records,onlyValidate);
        }
    }

    public void finish(Database.BatchableContext bc){
        System.debug('Job finished');
    }
    /****************************************************************************************************************** 
Method Name   :        insertData
@return       :        Map of Bulk Upload Batch Record object Id and Object record
@parameters   :        header, rowData, objectName
Description   :        Format the input data to create sOjects that can be inserted into database
Added By      :        Accenture - Gowtham - 23/12/2021
***********************************************************************************************************************/
    public static Map<Id,SObject> insertData(String header, Map<Id,String> rowData, String objectName){
        List<String> headerData = new List<String>();
        String hd = header.remove('"');  
        headerData = hd.split(',');
        Map<Id,SObject> recordsToUpload = new Map<Id,SObject>();
        for(Id key : rowData.keySet()){
            String row = rowData.get(key);
            List<String> rowValues = row.remove('"').split(',');
            sObject sObj = Schema.getGlobalDescribe().get(objectName).newSObject();
            Schema.SObjectType sObjType = Schema.getGlobalDescribe().get(objectName);
            Map<String,Schema.SObjectField> fields = sObjType.getDescribe().fields.getMap();
            for(Integer i=0;i<headerData.size();i++){
                System.debug('headerData[i]'+headerData[i]);
                Schema.DescribeFieldResult currentField = fields.get(fieldNameToAPINameMap.get(headerData[i])).getDescribe();
                System.debug('currentField.getType()'+currentField.getType());
                if(currentField.getType() == Schema.DisplayType.Date){
                    sObj.put(fieldNameToAPINameMap.get(headerData[i]),Date.parse(rowValues[i])) ;
                } else if(currentField.getType() == Schema.DisplayType.DOUBLE){
                    sObj.put(fieldNameToAPINameMap.get(headerData[i]),Integer.valueOf(rowValues[i])) ;
                }else if(currentField.getType() == Schema.DisplayType.CURRENCY){
                    sObj.put(fieldNameToAPINameMap.get(headerData[i]),Decimal.valueOf(rowValues[i])) ;
                }
                else {
                    sObj.put(fieldNameToAPINameMap.get(headerData[i]),String.ValueOf(rowValues[i])) ;
                    System.debug('rowValues[i]'+rowValues[i]);
                }
            }
            recordsToUpload.put(key,sObj);      //Map of Bulk Upload Batch Record object Id and Object record created from that Id record - RowData field
        }
        return recordsToUpload;
    }

    /****************************************************************************************************************** 
Method Name   :        validateAndSaveData
@return       :        none
@parameters   :        records, onlyValidate
Description   :        Method to insert the sOject records and update the result accordingly in respective Bulk Upload Batch Record object based on Id obtained from the Map
Added By      :        Accenture - Gowtham - 27/12/2021
***********************************************************************************************************************/

    public static void validateAndSaveData(Map<Id,SObject> records, Boolean onlyValidate){
        Savepoint sp = Database.setSavepoint();
        List<Id> batchRecordId = new List<Id>();
        List<SObject> uploadRecords = new List<SObject>(); //Sobject data to be inserted
        List<Core_MDF_Bulk_Upload_Batch_Record__c> updateRecords = new List<Core_MDF_Bulk_Upload_Batch_Record__c>();

        Map<Id,String> idResultMap = new Map<Id,String>();
        for(Id key : records.keySet()){
            batchRecordId.add(key);
            uploadRecords.add(records.get(key));
        }
        Database.SaveResult[] uploadedrec =  Database.insert(uploadRecords,false);
        Integer i = 0;
        for(Database.SaveResult sr : uploadedrec){
            if(sr.isSuccess()){
                idResultMap.put(batchRecordId[i],'Data has no error');
                System.debug('Record created successfully '+ sr.getId());
            }else if(!sr.isSuccess()){
                String error='';
                for(Database.Error err : sr.getErrors()){
                    error = error+err.getMessage() +', Fields causing error '+err.getFields();
                    System.debug('error'+error);
                }
                idResultMap.put(batchRecordId[i], error);
            }
            i++;
        }
        if(onlyValidate){               //if onlyValidate = true, then sOject records are not inserted but only validated 
            Database.rollback(sp);
        }
        for(Core_MDF_Bulk_Upload_Batch_Record__c cr : childRecords){
            cr.Core_MDF_Error_Reason__c = idResultMap.get(cr.Id);
            System.debug('cr.Core_MDF_Error_Reason__c'+cr.Core_MDF_Error_Reason__c);
            updateRecords.add(cr);
        }
        Database.update(updateRecords,false);   // sObject records validation result is updated on the Bulk Upload Batch Record object accordingly
    }
}