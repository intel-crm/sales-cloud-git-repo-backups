public with sharing class test_generic_bulk_upload_batch implements Database.Batchable<SObject>,Database.Stateful {
    Map<Id, List<sobject>> recordMap = new Map<Id, List<sObject>>();
    
    public string objectName;
    public List<String> fieldNames;
    public String query;
    List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
    public test_generic_bulk_upload_batch(string objName,List<String> fieldNames) {
        
        this.objectName = objName;
        this.fieldNames=fieldNames;
    }
    
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        query = Test_Generic_bulk_upload_class.dynamicRecordsQuery(this.objectName,fieldNames);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext context, List<sObject> scope) {
        
        Long startTime = System.currentTimeMillis();
        Long startHeap = Limits.getHeapSize();
        System.debug('Start time in execute: ' + startTime);
        System.debug('Heap Size at start of execute: ' + startHeap);
        try{
            List<sObject> recToUpdateList = validateDataType(scope);
            
            updatePendingRecords(recToUpdateList);
            
            Long endHeap = Limits.getHeapSize();
            System.debug('Heap Size at end of execute: ' + endHeap);
            Long heapUsed = endHeap - startHeap;
            System.debug('Heap Size Used in MB in  execute: ' + heapUsed);
            Long endTime = System.currentTimeMillis();
            Long executionTime = endTime - startTime;
            System.debug('Execution Time in seconds in execute: ' + executionTime);
        }catch(Exception ex){
            System.debug('exception message>> '+ ex);
        }
    }
    public void finish(Database.BatchableContext context) {}
    
    public List<sObject> validateDataType(List<sObject> pendingRecords){
        
        List<sObject> recToUpdate = new List<sObject>();
        try{
            Core_DDR_Stage_Validator validator = new Core_DDR_Stage_Validator();
            Integer errorCount;
            Boolean hasErrors;
            String errorMessage;
            Test_Generic_bulk_upload_class.ResultWrapper failWrapper =  Test_Generic_bulk_upload_class.checkStatusValue(this.objectName ,'Fail'); 
            Test_Generic_bulk_upload_class.ResultWrapper successWrapper =  Test_Generic_bulk_upload_class.checkStatusValue(this.objectName ,'Success');

            system.debug('ObjectName in batch>>> '+this.objectName);
            if(this.objectName!=null){
                List<Generic_Bulk_Upload_Fields__c> lstGenericBulkUploadMappings  = Test_Generic_bulk_upload_class.getGenericBulkUploadFieldMappings(this.objectName);
                
                /* List<Generic_Bulk_Upload_Fields__c> lstGenericBulkUploadMappings  =	[SELECT Id,  Name, Active__c, CSV_Column_Name__c, Actual_Object_Field_Data_type__c,
Stage_Field_API_Name__c, Stage_Object_API_Name__c, Actual_Object_Field_API_Name__c,
Stage_obj_Error_msg_field_API_name__c,Stage_obj_status_field_API_name__c
FROM Generic_Bulk_Upload_Fields__c where Active__c =true and Stage_Object_API_Name__c =:this.objectName];*/
                for(sObject pendingRec : pendingRecords){
                    hasErrors = false;
                    errorMessage='';
                    errorCount=0;
                    system.debug(' dynamic obj name>>> ' + pendingRec.getSObjectType().getDescribe().getName());      
                    if(pendingRec.getSObjectType().getDescribe().getName() == this.objectName ){
                        
                        for(Generic_Bulk_Upload_Fields__c bulkFieldMapping : lstGenericBulkUploadMappings){
                            String stageField = bulkFieldMapping.Stage_Field_API_Name__c;
                            system.debug('Stage Field>>'+stageField);
                            if(String.isBlank((String)pendingRec.get(stageField))){
                                system.debug(' Inside null error>> ' );
                                errorCount++;
                                
                                errorMessage +='ERROR '+errorCount+' : '+bulkFieldMapping.CSV_Column_Name__c+' field is blank'+' ; '+ PCC_Constants.RC_LINE_SEPERATOR;
                                hasErrors = true;
                                pendingRec.put(failWrapper.statusFieldName,failWrapper.statusFieldValue);
                                
                            }						
                            
                            else{
                                if(bulkFieldMapping.Actual_Object_Field_Data_type__c== 'Date' && 
                                   String.isNotBlank((String)pendingRec.get(stageField)) && 
                                   !validator.checkIsUSDatePattern((String)(pendingRec.get(stageField))) ){
                                       errorCount++;
                                       system.debug(' Inside date type check error>> ' );
                                       errorMessage +='ERROR '+errorCount+' : '+'Please provide the date(s) with the format \'MM/DD/YYYY\': '+bulkFieldMapping.CSV_Column_Name__c + ' ; '+ PCC_Constants.RC_LINE_SEPERATOR;
                                       hasErrors = true;
                                       pendingRec.put(failWrapper.statusFieldName,failWrapper.statusFieldValue);
                                       
                                   }
                                if(bulkFieldMapping.Actual_Object_Field_Data_type__c == 'Number' && 
                                   String.isNotBlank((String)pendingRec.get(stageField)) && !(Core_DDR_Stage_Validator.isNumeric(String.valueOf(pendingRec.get(stageField))))) {
                                       errorCount++;
                                       system.debug(' Inside number type check error>> '+(String.valueOf(pendingRec.get(stageField))) );
                                       errorMessage +='ERROR '+errorCount+' : '+'Please provide numeric value for the field:  '+bulkFieldMapping.CSV_Column_Name__c + ' ; '+ PCC_Constants.RC_LINE_SEPERATOR;
                                       hasErrors = true;
                                       pendingRec.put(failWrapper.statusFieldName,failWrapper.statusFieldValue);
                                       
                                   }
                                String lowerCaseVal= String.valueOf(pendingRec.get(stageField)).toLowerCase();
                                if(bulkFieldMapping.Actual_Object_Field_Data_type__c == 'Boolean' && 
                                   String.isNotBlank((String)pendingRec.get(stageField)) && lowerCaseVal!='true' && lowerCaseVal!='false' )/*(boolean.valueOf(String.valueOf(pendingRec.get(stageField)).toLowerCase()))*/ {
                                       errorCount++;
                                       system.debug(' Inside Boolean type check error>> ');
                                       errorMessage +='ERROR '+errorCount+' : '+'Please provide valid value(true/false)for the field:  '+bulkFieldMapping.CSV_Column_Name__c + ' ; '+ PCC_Constants.RC_LINE_SEPERATOR;
                                       hasErrors = true;
                                       pendingRec.put(failWrapper.statusFieldName,failWrapper.statusFieldValue);
                                       
                                   }
                                if(bulkFieldMapping.Actual_Object_Field_Data_type__c == 'Currency' && 
                                   String.isNotBlank((String)pendingRec.get(stageField))) 
                                { 
                                    String sanitizedValue= String.valueOf(pendingRec.get(stageField)).replace(',','');
                                    if(!(Core_DDR_Stage_Validator.isNumeric(sanitizedValue))) {
                                        errorCount++;
                                        system.debug(' Inside Boolean type check error>> ');
                                        errorMessage +='ERROR '+errorCount+' : '+'Please provide valid value(true/false)for the field:  '+bulkFieldMapping.CSV_Column_Name__c + ' ; '+ PCC_Constants.RC_LINE_SEPERATOR;
                                        hasErrors = true;
                                        pendingRec.put(failWrapper.statusFieldName,failWrapper.statusFieldValue);
                                        
                                    }
                                }
                                if(bulkFieldMapping.Actual_Object_Field_Data_type__c == 'Email' && 
                                   String.isNotBlank((String)pendingRec.get(stageField)) && !(Test_Generic_bulk_upload_class.isValidEmail(String.valueOf(pendingRec.get(stageField))))) {
                                       errorCount++;
                                       system.debug(' Inside email type check error>> '+(String.valueOf(pendingRec.get(stageField))) );
                                       errorMessage +='ERROR '+errorCount+' : '+'Please provide valid email address for the field:  '+bulkFieldMapping.CSV_Column_Name__c + ' ; '+ PCC_Constants.RC_LINE_SEPERATOR;
                                       hasErrors = true;
                                       pendingRec.put(failWrapper.statusFieldName,failWrapper.statusFieldValue);
                                       
                                   }
                            }
                        }
                        if (hasErrors) {
                            system.debug('Error field>>> '+lstGenericBulkUploadMappings[0].Stage_obj_Error_msg_field_API_name__c);
                            pendingRec.put(lstGenericBulkUploadMappings[0].Stage_obj_Error_msg_field_API_name__c, errorMessage);    
                        } 
                        system.debug( 'Blank check status>>> '+String.isNotBlank(String.valueof(pendingRec.get(successWrapper.statusFieldName))));
                        if(!hasErrors && (String.isNotBlank(String.valueof(pendingRec.get(successWrapper.statusFieldName))))){
                            system.debug( 'Inside success>> ');
                            
                            pendingRec.put(successWrapper.statusFieldName,successWrapper.statusFieldValue);
                            
                        }
                        
                        recToUpdate.add(pendingRec);
                    }
                }
                
            }
        }catch(Exception e){
            logEntries.add(new Core_Log_Entry__c(Core_Message__c = e.getMessage(),Core_Details__c ='Bulk Upload record failed to Validate', Core_Origin__c='Test_Generic_bulk_upload_class.validateDataType', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'Sales CRM'));    
        }finally{ insert logEntries;} 
        return recToUpdate; 
    }
    public void updatePendingRecords(List<sObject> recToUpdateList) {
        try{
            if (!recToUpdateList.isEmpty()) {
                Database.SaveResult[] srList = Database.update(recToUpdateList,true);
                for(Database.SaveResult res : srList){
                    if(!res.isSuccess()){
                        for(Database.Error err : res.getErrors()) {    
                            logEntries.add(new Core_Log_Entry__c(Core_Message__c = err.getMessage(),Core_Details__c ='Record failed to Update', Core_Origin__c='test_generic_bulk_upload_batch.updatePendingRecords', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'Sales CRM'));    
                        }
                    }
                }
            }   
        }catch(Exception e){
            logEntries.add(new Core_Log_Entry__c(Core_Message__c = e.getMessage(),Core_Details__c ='Error while updating Records', Core_Origin__c='test_generic_bulk_upload_batch.updatePendingRecords', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'Sales CRM'));     
        }finally{insert logEntries;}
        
    }
    
}