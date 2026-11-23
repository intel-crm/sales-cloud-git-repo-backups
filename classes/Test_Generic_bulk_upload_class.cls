public class Test_Generic_bulk_upload_class {
 
 private static final String EMAIL_REGEX = '^[a-z0-9!#$%&\'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&\'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$';
    @AuraEnabled(cacheable=true)
    public static Map<String,List<String>>  getFieldLabels(String objectName){
        Map<String,List<String>> fieldMap = new Map<String,List<String>>();
        List<String> columnNames = new List<String>();
        List<String> stageApiNames = new List<String>();
        
        List<Generic_Bulk_Upload_Fields__c> lstGenericBulkUploadMappings  = getGenericBulkUploadFieldMappings(objectName);	
        
        If(lstGenericBulkUploadMappings.size()>0 || !lstGenericBulkUploadMappings.isEmpty()){
            for(Generic_Bulk_Upload_Fields__c rec : lstGenericBulkUploadMappings){
                columnNames.add(rec.CSV_Column_Name__c);
                stageApiNames.add(rec.Stage_Field_API_Name__c);
            }
        }
        
        fieldMap.put('labels',columnNames);
        fieldMap.put('stageApiNames',stageApiNames);
        return fieldMap;
    }
    
    @AuraEnabled
    public static ResultWrapper createRecordsfromCSV(String base64Data, String objectName) {
        try {
            ResultWrapper rw = new ResultWrapper();
            rw.status = 'pending';
             ResultWrapper pendingWrapper =  checkStatusValue(objectName ,'Pending');
            // Get the field set labels
            Map<String,List<String>> fieldMap =  getFieldLabels(objectName);
            List<String> fieldAPINames = new List<String>();
            List<String> fieldlabelNames = new List<String>();
            fieldAPINames = fieldMap.get('stageApiNames');
            fieldlabelNames = fieldMap.get('labels');
            system.debug('fieldlabelNames>>'+fieldlabelNames);
            system.debug('fieldAPINames>>'+fieldAPINames);
            
            String data = JSON.deserializeUntyped(base64Data).toString();
            List<SObject> lstRecToInsert= new List<SObject>();
            
            
            list <String> lstCSVLines = data.split('\r\n');
            
            List<String> headers = lstCSVLines[0].split(',');
            Map<Integer,String> headerMap = new Map<Integer,String>();
            Integer index=0;
            
            for(String labelName: fieldlabelNames){
                if(!headers.contains(labelName)){
                    rw.status = 'failed';
                    rw.message = 'The CSV file does not match the template';
                }
            }  
            
            if(rw.status!='failed'){
                
                for(String labelName: headers){
                    system.debug('CSV labelName>>'+labelName);
                    if(fieldlabelNames.contains(labelName)){
                        system.debug('Field API Name>>'+fieldAPINames[fieldlabelNames.indexOf(labelName)]);
                        headerMap.put(index,fieldAPINames[fieldlabelNames.indexOf(labelName)]);
                    }
                    index=index+1;
                }   
                
                SObject dynamicObject;
                // Create child records
                
                if(objectName!=null){
                    for (Integer i = 1; i < lstCSVLines.size(); i++) {
                        dynamicObject = (SObject) Type.forName('Schema.' + objectName).newInstance();
                        String csvLine = lstCSVLines[i];
                        Integer startIndex;
                        Integer endIndex;
                        // Replace commas with :comma: inside quotes with a placeholder
                        while(csvLine.indexOf('"') > -1){
                            if(startIndex == null){
                                startIndex = csvLine.indexOf('"');
                                csvLine = csvLine.substring(0, startIndex) + ':quotes:' + csvLine.substring(startIndex+1, csvLine.length());
                            }else{
                                if(endIndex == null){
                                    endIndex = csvLine.indexOf('"');
                                    csvLine = csvLine.substring(0, endIndex) + ':quotes:' + csvLine.substring(endIndex+1, csvLine.length());
                                }
                            }
                            if(startIndex != null && endIndex != null){
                                String sub = csvLine.substring(startIndex, endIndex);
                                sub = sub.replaceAll(',', ':comma:');
                                csvLine = csvLine.substring(0, startIndex) + sub + csvLine.substring(endIndex, csvLine.length());
                                startIndex = null;
                                endIndex = null;
                            }
                        }
                        
                        //Replace back :comma: with comma
                        List <String> csvRowData = new List <String> ();
                        for (String column: csvLine.split(',')) {
                            column = column.replaceAll(':quotes:','').replaceAll(':comma:', ',');
                            csvRowData.add(column);
                        }
                        // Create RebateClaimStage Record
                        Integer errorCount = 0;
                        for (Integer j = 0; j < headers.size(); j++) {
                            if (headerMap.containsKey(j) && j < csvRowData.size()) {
                                system.debug('Field Api Name>>'+headerMap.get(j)+ '>>row data>>'+ csvRowData[j]);
                                dynamicObject.put(headerMap.get(j), csvRowData[j]);
                                
                            }
                        }
                        
                        dynamicObject.put(pendingWrapper.statusFieldName,pendingWrapper.statusFieldValue);
                        
                        dynamicObject.put('Core_Batch_ID__c','a3EDf0000003IPTMA2');
                        lstRecToInsert.add(dynamicObject);
                    }
                    
                    if (lstRecToInsert != null) {
                        Database.insert(lstRecToInsert);
                    }
                    
                    // Call the batch class to process the records
                    Database.executeBatch(new test_generic_bulk_upload_batch(objectName,fieldAPINames),200);
                    rw.status = 'success';
                    rw.message ='Template is successfully uploaded!!!!...';
                }
            }
            return rw;
        } 
        
        
        catch (Exception ex) {
            // Handle the exception and log the error
            insert new Core_Log_Entry__c(Core_Message__c = ex.getMessage(),Core_Details__c = ex.getMessage() + '\n'+ ex.getStackTraceString(),Core_Origin__c='Test_Generic_bulk_upload_class.createRecordsfromCSV', Core_Severity__c='high', Core_When__c=System.Now(), Core_Project__c = 'Generic_Bulk_Upload');
            ResultWrapper rw = new ResultWrapper();
            
            rw.status = 'failed';
            rw.message = 'An error occurred while creating records from CSV';
            
            return rw;
        } 
    }
    
    
    
    public class ResultWrapper {
        @AuraEnabled
        public String message { get; set; }
        @AuraEnabled
        public String status { get; set; }
        public String statusFieldName {get; set;}
        public String statusFieldValue {get; set;}
    }
    
    
    public static String dynamicRecordsQuery(String objName,List<String> fieldNames) {
        String stageStatus = 'Pending';
        String blank = '';
        String query ;
        String dynamicFieldsToQuery= String.join(fieldNames,',');
        if(String.isNotBlank(objName)){
            List<Stage_Object_s_Status_Setting__mdt> metadataRecord =  [Select Stage_Default_Status_or_while_process__c	
                                                                        from Stage_Object_s_Status_Setting__mdt where Stage_Object_API_Name__c=: objName];
            
            List<Generic_Bulk_Upload_Fields__c> bulkRec = getGenericBulkUploadFieldMappings(objName);
            if(bulkRec[0].Stage_obj_status_field_API_name__c!= null){
                query = 'SELECT Id, ' + dynamicFieldsToQuery +','+ bulkRec[0].Stage_obj_status_field_API_name__c +','+bulkRec[0].Stage_obj_Error_msg_field_API_name__c +
                    ' FROM ' + objName + ' WHERE ' +
                    bulkRec[0].Stage_obj_status_field_API_name__c + ' = \'' + metadataRecord[0].Stage_Default_Status_or_while_process__c +  '\' OR ' +
                    bulkRec[0].Stage_obj_status_field_API_name__c + ' = \'' + blank + '\'';
            }
        }
        system.debug('dynamic query>>>>'+query);
        return query;
    }
    
    public static  Map<String,Schema.DisplayType> getFieldType (String objName, List<String> fieldNames){
        
        Schema.DescribeSObjectResult dynamicObjDescribe ;
        Map<String, Schema.SObjectField> dynamicObjfieldMap ;
        Map<String,Schema.DisplayType> fieldTofieldTypeMap = new Map<String,Schema.DisplayType>();
        if(objName!=null){
            dynamicObjDescribe = Schema.getGlobalDescribe().get(objName).getDescribe();
            dynamicObjfieldMap = dynamicObjDescribe.fields.getMap();
            system.debug('Dynamic Field Map>>> '+dynamicObjfieldMap);
            
            
            for(String fieldSetField : fieldNames){
                if(dynamicObjfieldMap.containsKey(fieldSetField)){
                    system.debug(' Field set field present in obj map >>> ');
                    Schema.DisplayType fieldType = dynamicObjfieldMap.get(fieldSetField).getDescribe().getType();
                    fieldTofieldTypeMap.put(fieldSetField,fieldType);
                }
                
            }
        }
        return fieldTofieldTypeMap ;
    }
    public static List<Generic_Bulk_Upload_Fields__c> getGenericBulkUploadFieldMappings(String objectName){
        List<Generic_Bulk_Upload_Fields__c> genericRecList;
        if(String.isNotBlank(objectName)){
            genericRecList =  [select  Name, Active__c, CSV_Column_Name__c, Actual_Object_Field_Data_type__c, 
                               Stage_Field_API_Name__c, Stage_Object_API_Name__c, Actual_Object_Field_API_Name__c, 
                               Stage_obj_status_field_API_name__c, Stage_obj_Error_msg_field_API_name__c 
                               from Generic_Bulk_Upload_Fields__c where Active__c = true and Stage_Object_API_Name__c =:objectName];
        }
        return genericRecList;
    }    
    
    
    public static ResultWrapper checkStatusValue(String objName, String statusValue){
        
        String statusFieldName;
        String statusName ='';
        List<Stage_Object_s_Status_Setting__mdt> record = new List<Stage_Object_s_Status_Setting__mdt>();
        
        ResultWrapper wrapper = new ResultWrapper();
        List<Generic_Bulk_Upload_Fields__c> genericBulkLst = getGenericBulkUploadFieldMappings(objName);
        if(genericBulkLst.size()>0){
            statusFieldName = genericBulkLst[0].Stage_obj_status_field_API_name__c;
        }
        
        Core_DDR_Stage_Validator validator= new Core_DDR_Stage_Validator();
        try{
            if(String.isNotBlank(objName) && String.isNotBlank(statusFieldName)){
                wrapper.statusFieldName=statusFieldName;
                
              /*  record = [Select Stage_Object_API_Name__c,Stage_Default_Status_or_while_process__c,Stage_Status_Value_On_Success__c,Stage_Status_Value_On_Fail_Error__c	
                          from Stage_Object_s_Status_Setting__mdt where  Stage_Object_API_Name__c=: objName];
                if(record.size() > 0){
                    if(String.isNotBlank(statusValue) && statusValue =='Pending'){
                        wrapper.statusFieldValue = record[0].Stage_Default_Status_or_while_process__c;
                    }else if(String.isNotBlank(statusValue) && statusValue =='Success'){
                        wrapper.statusFieldValue = record[0].Stage_Status_Value_On_Success__c;
                    }else if(String.isNotBlank(statusValue) && statusValue =='Fail'){
                        wrapper.statusFieldValue = record[0].Stage_Status_Value_On_Fail_Error__c;
                    }
                }*/
                
              Map<String, Map<String, Object>> DIM1 = new Core_CustomMetadataObjectController('Stage_Object_s_Status_Setting__mdt').getAll();
                system.debug('Outside for DIM>>'+DIM1);
                for(Map<String,Object> DIM : new Core_CustomMetadataObjectController('Stage_Object_s_Status_Setting__mdt').getAll().values()){
                    System.debug('DIM>>>'+DIM);
                    if(objName == (String.valueOf(DIM.get('Stage_Object_API_Name__c')))){
                        System.debug('Inside objName>>');
                        if(String.isNotBlank(statusValue) && statusValue =='Pending'){
                            System.debug('Inside Pending>>');
                            wrapper.statusFieldValue = String.valueOf(DIM.get('Stage_Default_Status_or_while_process__c')) ; //record[0].Stage_Default_Status_or_while_process__c;
                        }else if(String.isNotBlank(statusValue) && statusValue =='Success'){
                            System.debug('Inside Success>>');
                            wrapper.statusFieldValue = String.valueOf(DIM.get('Stage_Status_Value_On_Success__c'));
                        }else if(String.isNotBlank(statusValue) && statusValue =='Fail'){
                            System.debug('Inside Fail>>');
                            wrapper.statusFieldValue = String.valueOf(DIM.get('Stage_Status_Value_On_Fail_Error__c'));
                        }
                        
                    }system.debug('Wrapper>>> '+wrapper);
                }
                /*  Set<string> statusValuesLst = validator.getPickListValuesIntoList( objName, statusFieldName);
if(!statusValuesLst.IsEmpty()){
for(String status : statusValuesLst ){
system.debug('Status present??'+status.contains(String.valueof(statusValue)));
if(status.contains(String.valueof(statusValue))){
system.debug('Inside If checkstatus>>');
wrapper.statusFieldValue = status;
return wrapper;

}
}
}*/
            }
            
        }catch(Exception e){
            
            System.debug('Exception in checkStatusValue method>>>'+ ''+ e);
        }
        system.debug('wrapper inside checkstatus>> '+ wrapper);
        return wrapper ;
    }
    public static Boolean isBoolean(String s)
    {
        Boolean ReturnValue;
        try
        {
            Boolean.valueOf(s);
            ReturnValue = TRUE; 
        } catch (Exception e) 
        {
            ReturnValue = FALSE;
        }
        return ReturnValue;
    }
     public static Boolean isValidEmail(String email) {
        if (String.isEmpty(email)) {
            return false;
        }
        return Pattern.matches(EMAIL_REGEX, email);
    }
    
}