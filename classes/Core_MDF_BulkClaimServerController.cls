/*
* Class Name  : Core_MDF_BulkClaimServerController 
* Version     : 1.0 
* Created Date: 02-04-2019
* Modification Log :
* Developer               Date                          Description 
* -----------------------------------------------------------------------------------------------------------------------------------------------------
* Accenture – JV         02/04/2019                    Created Core_MDF_BulkClaimServerController as a Server Class for Bulk Claim Lightning Component
-------------------------------------------------------------------------------------------------------------------------------------------------------
*/
public with sharing class Core_MDF_BulkClaimServerController { 
    //Custom Exception
    public virtual class BulkClaimException extends Exception {}
    //To hold errors to b displayed
    public static String errorToBeDisplayed = '';
    /**
* @description : This method is used to Parse the File Uploaded by User. Insert the Batch Record. Attach the Uploaded file to Batch Record. 
Insert the Batch Stage Records corresponding to the Uploaded File
* @param base64Data : Content of the File in Base64 format 
* @param fileName : File Name 
* @param contentType : Type of the File (CSV)
*/
    
    /*******************************************************************************************************************************
Moved from Custom Metadata (Core_MDF_BulkClaimTemplateParticulars__mdt) to Custom Object (Core_MDF_CCP_Custom_Metadata_Utility__c)
Below are the field Mapping :
DeveloperName --> Name
Core_MDF_Channel_program__c --> Core_MDF_Program__c
Core_MDF_Claim_Field_API_Name__c --> Core_MDF_Name_Criteria__c
Core_MDF_Column_Index__c --> Core_MDF_Sort_Order_Nbr__c
Core_MDF_Field_DataType_Txt__c --> Core_MDF_Field_1_txt__c
Core_MDF_Stage_Field_API_Name__c --> Core_MDF_Field_2_txt__c
Core_MDF_Stage_Required_Ind__c --> Core_MDF_Checkbox_Field_1_Ind__c
Core_MDF_Target_Field_API_Name__c --> Core_MDF_Field_3_txt__c
Core_MDF_Upload_Record_Type__c --> Core_MDF_Sub_Category__c

To Identity the Bulk Claim records in Core_MDF_CCP_Custom_Metadata_Utility__c Custom object used Core_MDF_Category__c
Core_MDF_Category__c---> "Bulk Claim Template"
*********************************************************************************************************************************/
    @AuraEnabled
    public static String parseFile(String base64Data, String fileName, String channelProgramId) {
        try {
            base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
            Blob blobData = EncodingUtil.base64Decode(base64Data);
            Core_MDF_Claim_Batch__c batchInstance = new Core_MDF_Claim_Batch__c();
            String channelProgramName = [Select Core_MDF_Technical_Program_Name__c From ChannelProgram WHERE Id =:channelProgramId LIMIT 1].Core_MDF_Technical_Program_Name__c;
            Id ultimateAccId;
            
            //Map<Id,Core_MDF_BulkClaimTemplateParticulars__mdt> metadataIdToRecordMap = new Map<Id,Core_MDF_BulkClaimTemplateParticulars__mdt>([SELECT Id,Label, Core_MDF_Stage_Field_API_Name__c,Core_MDF_Field_DataType_Txt__c,Core_MDF_Column_Index__c,Core_MDF_Target_Field_API_Name__c, Core_MDF_Stage_Required_Ind__c, Core_MDF_Claim_Field_API_Name__c,Core_MDF_Channel_program__c FROM Core_MDF_BulkClaimTemplateParticulars__mdt WHERE Core_MDF_Channel_program__c = :channelProgramName AND Core_MDF_Upload_Record_Type__c =:Label.Core_MDF_PFCText ORDER BY Core_MDF_Column_Index__c]);
            
            String whereClause = 'Core_MDF_Program__c = \'' + channelProgramName + '\' ' + 'AND Core_MDF_Sub_Category__c = \'' + Label.Core_MDF_PFCText + '\' ' + 'AND Core_MDF_Category__c = \'' + Core_MDF_CCP_ConstantClass.BULK_CLAIM_TEMPLATE + '\' ';
            List<Core_MDF_CCP_Custom_Metadata_Utility__c> metaDataValues = Core_MDF_Custom_Metadata_Utility.getCustomObjectRecords(whereClause);
            Map<Id,Core_MDF_CCP_Custom_Metadata_Utility__c> metadataIdToRecordMap = new Map<Id,Core_MDF_CCP_Custom_Metadata_Utility__c>();
            for(Core_MDF_CCP_Custom_Metadata_Utility__c mdtRecords : metaDataValues){
                metadataIdToRecordMap.put(mdtRecords.id,mdtRecords);
            }
                
            Core_MDF_ObjRecType_Budget_FieldSetMap__mdt  recordType = [SELECT Id, Core_MDF_ClaimStage_RecordType_txt__c
                                                                     FROM Core_MDF_ObjRecType_Budget_FieldSetMap__mdt
                                                                     WHERE Core_MDF_Channel_Program_Name_txt__c = :channelProgramName LIMIT 1];//TWC3117-18333
            if(validateUploadedFile(blobData,metadataIdToRecordMap)){
                // validate user has ultimate account access
                ultimateAccId = Core_MDF_BulkClaimUtility.validateAccountAccess();
                if(ultimateAccId != null){
                    //Validate incoming bulk claims
                    List<Core_MDF_Claim_Batch_Stage__c> listOfClaimBatchStageRecords = validateDataType(metadataIdToRecordMap,blobData,ultimateAccId,channelProgramId);
                    //To create claim batch and stage record
                    batchInstance = createBatchAndStageRecords(listOfClaimBatchStageRecords,ultimateAccId,channelProgramId,fileName,blobData,recordType);
                }
            }
            return batchInstance.Id;    
        }catch(BulkClaimException e){
            //Core_MDF_CCP_UtilityClass.logError(e); 
            return 'UIException'+e.getMessage(); 
        }catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e); 
            return 'Exception'+e.getMessage();
        }
    }
    
    /**
* @description: This method is used to create batch and stage record
* @param listOfClaimBatchStageRecords : List of claim stage records
* @param ultimateAccId : ultimate account id
* @param fileName : File Name
* @param blobData : Content of the File Uploaded by the User in Blob format
* @param recordType : File NameTo get claim stage record type id
*/      
    public static Core_MDF_Claim_Batch__c createBatchAndStageRecords(List<Core_MDF_Claim_Batch_Stage__c> listOfClaimBatchStageRecords,Id ultimateAccId, String channelProgramId,
                                                                     String fileName, Blob blobData,Core_MDF_ObjRecType_Budget_FieldSetMap__mdt  recordType)//TWC3117-18333
    {
        //hold claim batch instance 
        Core_MDF_Claim_Batch__c batchInstance = new Core_MDF_Claim_Batch__c();
        if(listOfClaimBatchStageRecords!=null && listOfClaimBatchStageRecords.size()>0){
            //insert batch claim record and attach the Uplaoded template
            batchInstance = Core_MDF_BulkClaimUtility.insertBatchRecordAndAttachUploadedTemplate(ultimateAccId,channelProgramId,fileName,blobData);
            //insert claim batch stage records
            if(batchInstance!=null){
                insertClaimBatchStageRecords(listOfClaimBatchStageRecords,batchInstance,recordType);
            }
        }
        return batchInstance;        
    }    
    /**
* @description: This method is used to validate records based on the CSV Data as Input
* @param metadataIdToRecordMap: contains bulk claim template perticulars
* @param blobData: Content of the File Uploaded by the User in Blob format 
*/
    public static List<Core_MDF_Claim_Batch_Stage__c> validateDataType(Map<Id,Core_MDF_CCP_Custom_Metadata_Utility__c> metadataIdToRecordMap, Blob blobData,Id ultimateAccId,String channelProgramId)
    {
        String csvAsString;
        String[] csvFileLines;
        Set<String> bankSupplierNumber = new Set<String>();
        csvAsString = blobData.toString(); //EncodingUtil.base64Encode(base64Data);//base64Data.toString();
        csvFileLines = csvAsString.split('\n');
        List<Core_MDF_Claim_Batch_Stage__c> claimBatchStageRecordList = new List <Core_MDF_Claim_Batch_Stage__c>();
        
        Map<String,String> bankSupplierNumberToLegalEntity = new Map<String,String>();
        Map<String,Boolean> applicableVATPerRequired =  new Map<String, Boolean>();  
        Integer suppNoPosition;
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Core_MDF_Claim_Batch_Stage__c').getDescribe().fields.getMap();
        List<Schema.PicklistEntry> picklistvalues = fieldMap.get('Core_MDF_Inv_Receipt_Cur_Cd__c').getDescribe().getPickListValues();
        List<String> currencyValueList = new List<String>();
        List<String> countryList = new List<String>();
        List<String> activitySubTypeList = new List<String>();
        List<String> vatOptInList = new List<String>();
        List<String> applicableVATPerInList = new List<String>();
        List<Schema.PicklistEntry> countryPicklistvalues = fieldMap.get('Core_MDF_Country_Location_nm__c').getDescribe().getPickListValues();
        List<Schema.PicklistEntry> activitySubTypePicklistvalues = fieldMap.get('Core_MDF_Activity_SubType_nm__c').getDescribe().getPickListValues();
        List<Schema.PicklistEntry> vatOptInPicklistvalues = fieldMap.get('Core_MDF_VAT_Opt_In__c').getDescribe().getPickListValues();
        List<Schema.PicklistEntry> applicableVATPerPicklistValues = fieldMap.get('Core_MDF_Applicable_VAT_Percentage_nm__c').getDescribe().getPickListValues();
        String channelProgramName = [Select Core_MDF_Technical_Program_Name__c From ChannelProgram WHERE Id =:channelProgramId LIMIT 1].Core_MDF_Technical_Program_Name__c;
        for(Schema.PicklistEntry currencyField : picklistvalues){
            currencyValueList.add(currencyField.getValue().toUpperCase());
        }
        for(Schema.PicklistEntry countryField : countryPicklistvalues){
            countryList.add(countryField.getValue().toUpperCase());
        }
        for(Schema.PicklistEntry activitySubTypeField : activitySubTypePicklistvalues){
            activitySubTypeList.add(activitySubTypeField.getValue().toUpperCase());
        }
        for(Schema.PicklistEntry vatOptInField : vatOptInPicklistvalues){
            vatOptInList.add(vatOptInField.getValue().toUpperCase());
        }
        for(Schema.PicklistEntry applicableVATPerInField : applicableVATPerPicklistValues){
            applicableVATPerInList.add(applicableVATPerInField.getValue().toUpperCase());
        }
        // This section will get executed only for Retail
        if(channelProgramName == Label.Core_MDF_NonTranslateRetailRecordType){
            
            //get position of field bank supplier number
            for(Core_MDF_CCP_Custom_Metadata_Utility__c metadataRecord : metadataIdToRecordMap.values())
            {
                if(metadataRecord.Core_MDF_Field_2_txt__c == 'Core_MDF_Bank_Nbr__c'){
                    suppNoPosition = (Integer)metadataRecord.Core_MDF_Sort_Order_Nbr__c;
                    break;
                }
            }
            
            //store all files supplier number in set    
            for(Integer i = 1; i < csvFileLines.size(); i++)
            {
                String[] csvRecordData;
                try {
                    csvRecordData = csvFileLines[i].split(',');
                    if(csvRecordData != null && String.isNotBlank(csvRecordData[suppNoPosition])){//ATHR - Deeply Nested if 16209
                        bankSupplierNumber.add(csvRecordData[suppNoPosition]);
                    }
                }catch (Exception e) {
                    System.debug('Exception'+e);
                }
                
            }
            
            List<Core_MDF_Account_Bank_Mapping__c> accountBankMapping = [Select id, Core_MDF_Bank__r.Core_MDF_Supplier_Number__c, Core_MDF_Bank__r.Core_MDF_Intel_Company_Code__c, Core_MDF_Account__r.Core_MDF_Channel_Program__r.Name 
                                                                         from Core_MDF_Account_Bank_Mapping__c 
                                                                         where Core_MDF_Bank__r.Core_MDF_Supplier_Number__c IN: bankSupplierNumber
                                                                         AND Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c =: ultimateAccId
                                                                         AND Core_MDF_Active_ind__c=TRUE];
            // creating Map of supplier number to Bank Intel code
            if(accountBankMapping != null && accountBankMapping.size() > 0){
                for(Core_MDF_Account_Bank_Mapping__c abm : accountBankMapping)
                {
                    bankSupplierNumberToLegalEntity.put(abm.Core_MDF_Bank__r.Core_MDF_Supplier_Number__c,abm.Core_MDF_Bank__r.Core_MDF_Intel_Company_Code__c);
                }
            }
            List<Core_MDF_CCP_VAT_Config__mdt> vatConfigMetadata = [select Core_MDF_Legal_Entity__c,Core_MDF_Show_Applicable_VAT_Percentage__c 
                                                                    from Core_MDF_CCP_VAT_Config__mdt 
                                                                    where Core_MDF_Program__c = :channelProgramName ];
            // create map of Intel code of 650 to required Applicable Vat Percentage field
            for(Core_MDF_CCP_VAT_Config__mdt vatConfig :vatConfigMetadata ){
                applicableVATPerRequired.put(vatConfig.Core_MDF_Legal_Entity__c,vatConfig.Core_MDF_Show_Applicable_VAT_Percentage__c);
            }
        }
        
        for(Integer i = 1; i < csvFileLines.size(); i++)
        {
            //This method is used to validate filds,assign on stage record and populate error if any
            Core_MDF_Claim_Batch_Stage__c claimStageInstance = fieldAssignToStageRecAndPopulateError(i,csvFileLines,metadataIdToRecordMap,currencyValueList,countryList,activitySubTypeList,vatOptInList,applicableVATPerInList,bankSupplierNumberToLegalEntity,applicableVATPerRequired,suppNoPosition);
            claimBatchStageRecordList.add(claimStageInstance);
        }
        if(!String.isEmpty(errorToBeDisplayed)){throw new BulkClaimException(''+errorToBeDisplayed);}
        return claimBatchStageRecordList;
    }
    
    /**
* @description: This method is used to validate , assign fields on stage records and populate errores based on the CSV Data as Input
* @param csvRowId: uploaded csv file's row id
* @param csvFileLines: hold csv file lines
* @param metadataIdToRecordMap: contains bulk claim template perticulars
* @param currencyValueList: hold all currency code list 
*/
    public static Core_MDF_Claim_Batch_Stage__c fieldAssignToStageRecAndPopulateError(Integer csvRowId,String[] csvFileLines,Map<Id,Core_MDF_CCP_Custom_Metadata_Utility__c> metadataIdToRecordMap,List<String> currencyValueList, List<String> countryList, List<String> activitySubTypeList,List<String> vatOptInList, List<String> applicableVATPerInList,Map<String,String> bankSupplierNumberToLegalEntity,Map<String,Boolean> applicableVATPerRequired,Integer suppNoPosition)
    {
        Core_MDF_Claim_Batch_Stage__c claimStageInstance = new Core_MDF_Claim_Batch_Stage__c();            
        for(Core_MDF_CCP_Custom_Metadata_Utility__c metadataRecord : metadataIdToRecordMap.values())
        {
            String[] csvRecordData;
            try {
                csvRecordData = csvFileLines[csvRowId].split(',');
                //Validate  csv data types and fields
                claimStageInstance = validateCsvDataTypesAndFields(csvRowId,metadataRecord,claimStageInstance,csvRecordData,currencyValueList,countryList,activitySubTypeList,vatOptInList,applicableVATPerInList,bankSupplierNumberToLegalEntity,applicableVATPerRequired,suppNoPosition);
            }catch (Exception e) {
                if(e.getMessage().trim().contains(Label.Core_MDF_BulkClaimInvalidDecimal)){
                    errorToBeDisplayed +=  Label.Core_MDF_RowErrorText +' '+ csvRowId + ': '+Label.Core_MDF_InvalidAmountError+': '+csvRecordData[(Integer)metadataRecord.Core_MDF_Sort_Order_Nbr__c]+'\n';     
                }else{errorToBeDisplayed +=  Label.Core_MDF_RowErrorText +' '+ csvRowId + ': '+e.getMessage()+ '\n';}
            }
        } 
        return claimStageInstance;  
    }
    
    /**
* @description: This method is used to validate data types and fields based on the CSV Data as Input
* @param csvRowId: uploaded csv file's row id
* @param metadataIdToRecordMap: contains bulk claim template perticulars
* @param claimStageInstance:  hold claim batch stage instance
* @param csvRecordData: hold csv record
* @param currencyValueList: hold all currency code list 
*/
    public static Core_MDF_Claim_Batch_Stage__c validateCsvDataTypesAndFields(Integer csvRowId,Core_MDF_CCP_Custom_Metadata_Utility__c metadataRecord,Core_MDF_Claim_Batch_Stage__c claimStageInstance,String[] csvRecordData,List<String> currencyValueList,List<String> countryList,List<String> activitySubTypeList,List<String> vatOptInList, List<String> applicableVATPerInList,Map<String,String> bankSupplierNumberToLegalEntity,Map<String,Boolean> applicableVATPerRequired,Integer suppNoPosition){
        if(metadataRecord.Core_MDF_Field_1_txt__c == 'Date'){
            Date standardDate = convertDateToStandardDate(csvRecordData[(Integer)metadataRecord.Core_MDF_Sort_Order_Nbr__c]);
            claimStageInstance.put(metadataRecord.Core_MDF_Field_2_txt__c,standardDate);
            return claimStageInstance;
        }
        if(metadataRecord.Core_MDF_Field_1_txt__c == 'Number'){
            if(csvRecordData[(Integer)metadataRecord.Core_MDF_Sort_Order_Nbr__c] != '') {
                claimStageInstance.put(metadataRecord.Core_MDF_Field_2_txt__c,decimal.valueOf(csvRecordData[(Integer)metadataRecord.Core_MDF_Sort_Order_Nbr__c]));
            } else {
                claimStageInstance.put(metadataRecord.Core_MDF_Field_2_txt__c, null);
            }
            return claimStageInstance;
        }
        if(metadataRecord.Core_MDF_Field_2_txt__c == 'Core_MDF_Activity_Nbr__c'){
            // input Activity Number : 2179 
            String inputActivityNumber = csvRecordData[(Integer)metadataRecord.Core_MDF_Sort_Order_Nbr__c];
            //Safe Navigation Operator for null check - activity number will be trim(), if it's not null 
            if(String.isBlank(inputActivityNumber?.trim()))
            {
                throw new BulkClaimException(Label.Core_MDF_Activity_Number_Missing);
            }
            else{
                // append leading zeroes
                inputActivityNumber = inputActivityNumber.leftPad(8, '0');
                claimStageInstance.put(metadataRecord.Core_MDF_Field_2_txt__c,inputActivityNumber);
            }
            return claimStageInstance;
        }
        if(metadataRecord.Core_MDF_Field_2_txt__c == 'Core_MDF_Inv_Receipt_Cur_Cd__c'){
            if(currencyValueList.contains(csvRecordData[(Integer)metadataRecord.Core_MDF_Sort_Order_Nbr__c].toUpperCase())){
                claimStageInstance.put(metadataRecord.Core_MDF_Field_2_txt__c,csvRecordData[(Integer)metadataRecord.Core_MDF_Sort_Order_Nbr__c]);
            }else{
                throw new BulkClaimException(Label.Core_MDF_InvalidCurrencyError+': '+csvRecordData[(Integer)metadataRecord.Core_MDF_Sort_Order_Nbr__c]);
            }
            return claimStageInstance;
        }
        if(metadataRecord.Core_MDF_Field_2_txt__c == 'Core_MDF_Country_Location_nm__c'){
            if(csvRecordData[(Integer)metadataRecord.Core_MDF_Sort_Order_Nbr__c]!= null && countryList.contains(csvRecordData[(Integer)metadataRecord.Core_MDF_Sort_Order_Nbr__c].toUpperCase())){
                claimStageInstance.put(metadataRecord.Core_MDF_Field_2_txt__c,csvRecordData[(Integer)metadataRecord.Core_MDF_Sort_Order_Nbr__c]);
            }else if(csvRecordData[(Integer)metadataRecord.Core_MDF_Sort_Order_Nbr__c] != null && csvRecordData[(Integer)metadataRecord.Core_MDF_Sort_Order_Nbr__c].Contains(';')){
                throw new BulkClaimException(Label.Core_MDF_Bulk_Claim_Multiple_Countries_Error);
            }else if(csvRecordData[(Integer)metadataRecord.Core_MDF_Sort_Order_Nbr__c]!= null && String.isNotEmpty(csvRecordData[(Integer)metadataRecord.Core_MDF_Sort_Order_Nbr__c]) && (!countryList.contains(csvRecordData[(Integer)metadataRecord.Core_MDF_Sort_Order_Nbr__c].toUpperCase()))){
                throw new BulkClaimException(Label.Core_MDF_Bulk_Claim_Invalid_Country+': '+csvRecordData[(Integer)metadataRecord.Core_MDF_Sort_Order_Nbr__c]);
            }
            return claimStageInstance;
        }
        if(metadataRecord.Core_MDF_Field_2_txt__c == 'Core_MDF_Activity_SubType_nm__c'){
            if(csvRecordData[(Integer)metadataRecord.Core_MDF_Sort_Order_Nbr__c]!= null && String.isNotEmpty(csvRecordData[(Integer)metadataRecord.Core_MDF_Sort_Order_Nbr__c].toUpperCase())){
            List<String> actSubtypEntered = csvRecordData[(Integer)metadataRecord.Core_MDF_Sort_Order_Nbr__c].split(';');
            Set<String> activitySubtypeSet = new Set<String>();
            // For trimming the whitespaces for activity sub type values entered
            for(string actSubtype : actSubtypEntered){
                activitySubtypeSet.add(actSubtype.trim());
            }
            //activitySubtypeSet.addAll(actSubtypEntered);
            List<String> invalidActivitySubtypes = new List<String>();
            for(string actSubtype : activitySubtypeSet){
                if(!activitySubTypeList.contains(actSubtype.toUpperCase()) && String.isNotEmpty(actSubtype)){
                    invalidActivitySubtypes.add(actSubtype);
                }
            }
            if(invalidActivitySubtypes != null && invalidActivitySubtypes.size()>0){
                throw new BulkClaimException(Label.Core_MDF_Activity_Subtype_Error +': '+String.join(invalidActivitySubtypes,'; '));
            }
            List<String> activitySubtypesToPopulate = new List<String>();
            activitySubtypesToPopulate.addAll(activitySubtypeSet);
            claimStageInstance.put(metadataRecord.Core_MDF_Field_2_txt__c,String.join(activitySubtypesToPopulate,';'));
        }
            return claimStageInstance;
        }
        if(metadataRecord.Core_MDF_Field_2_txt__c == 'Core_MDF_VAT_Opt_In__c'){
            if(csvRecordData[(Integer)metadataRecord.Core_MDF_Sort_Order_Nbr__c]!= null && vatOptInList.contains(csvRecordData[(Integer)metadataRecord.Core_MDF_Sort_Order_Nbr__c].trim().toUpperCase())){
                claimStageInstance.put(metadataRecord.Core_MDF_Field_2_txt__c,csvRecordData[(Integer)metadataRecord.Core_MDF_Sort_Order_Nbr__c]);
            }
            else if (csvRecordData[(Integer)metadataRecord.Core_MDF_Sort_Order_Nbr__c]!= null && String.isNotBlank(csvRecordData[(Integer)metadataRecord.Core_MDF_Sort_Order_Nbr__c]) && (!vatOptInList.contains(csvRecordData[(Integer)metadataRecord.Core_MDF_Sort_Order_Nbr__c].trim().toUpperCase()))){
                if(csvRecordData[suppNoPosition] != null && bankSupplierNumberToLegalEntity.containsKey(csvRecordData[suppNoPosition]) 
                   && applicableVATPerRequired.containsKey(bankSupplierNumberToLegalEntity.get(csvRecordData[suppNoPosition]))&& applicableVATPerRequired.get(bankSupplierNumberToLegalEntity.get(csvRecordData[suppNoPosition]))){
                    throw new BulkClaimException(Label.Core_MDF_Invalid_Vat_OptIn_Text+' '+csvRecordData[(Integer)metadataRecord.Core_MDF_Sort_Order_Nbr__c]+' '+Label.Core_MDF_Invalid_Vat_OptIn_Text2);
                }
                else{
                    throw new BulkClaimException(Label.Core_MDF_Invalid_Vat_OptIn_Text+csvRecordData[(Integer)metadataRecord.Core_MDF_Sort_Order_Nbr__c]+', '+Label.Core_MDF_Invalid_Vat_OptIn_Text1);
                }
            }
            return claimStageInstance;
        } 
        if(metadataRecord.Core_MDF_Field_2_txt__c == 'Core_MDF_Bank_Nbr__c') {
            if(csvRecordData[(Integer)metadataRecord.Core_MDF_Sort_Order_Nbr__c]!= '' && csvRecordData[(Integer)metadataRecord.Core_MDF_Sort_Order_Nbr__c].length() != 10)
            {
                throw new BulkClaimException(Label.Core_MDF_Invalid_BankNumber_Text+' '+csvRecordData[(Integer)metadataRecord.Core_MDF_Sort_Order_Nbr__c]+' '+Label.Core_MDF_Invalid_Bank_Supplier_Number_Text);
            }
            else
            {
                claimStageInstance.put(metadataRecord.Core_MDF_Field_2_txt__c, csvRecordData[(Integer)metadataRecord.Core_MDF_Sort_Order_Nbr__c]);
            }
            return claimStageInstance;            
        }
        if(metadataRecord.Core_MDF_Field_2_txt__c == 'Core_MDF_Bank_Account_Nbr__c') {
            if(csvRecordData[(Integer)metadataRecord.Core_MDF_Sort_Order_Nbr__c]!= '' && csvRecordData[(Integer)metadataRecord.Core_MDF_Sort_Order_Nbr__c].length() != 4)
            {
                throw new BulkClaimException(Label.Core_MDF_Invalid_BankAccountNumber_Text+' '+csvRecordData[(Integer)metadataRecord.Core_MDF_Sort_Order_Nbr__c]+' '+Label.Core_MDF_Invalid_Bank_Account_Number_Text);
            }
            else
            {
                claimStageInstance.put(metadataRecord.Core_MDF_Field_2_txt__c, csvRecordData[(Integer)metadataRecord.Core_MDF_Sort_Order_Nbr__c]);
            }
            return claimStageInstance;
        }
            //Truncate Fields to 255 characters if greater than 255 characters
        claimStageInstance.put(metadataRecord.Core_MDF_Field_2_txt__c,csvRecordData[(Integer)metadataRecord.Core_MDF_Sort_Order_Nbr__c].length() > Integer.valueOf(System.Label.Core_MDF_MaximumTextLimit) ? csvRecordData[(Integer)metadataRecord.Core_MDF_Sort_Order_Nbr__c].substring(0, Integer.valueOf(System.Label.Core_MDF_MaximumTextLimit)) : csvRecordData[(Integer)metadataRecord.Core_MDF_Sort_Order_Nbr__c]);                                                   
        return claimStageInstance;
    }    
    
    
    /**
* @description: This method is used to insert claim batch stage records
* @param claimBatchStageList: list of claim batch stage records
* @param batchInstance: claim batch record instance
*/  
    public static void insertClaimBatchStageRecords(List<Core_MDF_Claim_Batch_Stage__c> claimBatchStageList,Core_MDF_Claim_Batch__c batchInstance,Core_MDF_ObjRecType_Budget_FieldSetMap__mdt  recordType){//TWC3117-18333
        //list of claim batch stage records to be inserted
        List<Core_MDF_Claim_Batch_Stage__c> claimBatchStageRecordList = new List <Core_MDF_Claim_Batch_Stage__c>();
        //Batch Stage Record Id
        Id recordTypeId = Schema.SObjectType.Core_MDF_Claim_Batch_Stage__c.getRecordTypeInfosByDeveloperName().get(recordType.Core_MDF_ClaimStage_RecordType_txt__c).getRecordTypeId();
        for(Core_MDF_Claim_Batch_Stage__c claimBatchStageRecord : claimBatchStageList){
            //assign claim batch instance Id to stage record
            claimBatchStageRecord.Core_MDF_Batch_ID__c = batchInstance.Id;
            claimBatchStageRecord.RecordtypeId = recordTypeId;
            claimBatchStageRecordList.add(claimBatchStageRecord);
            
        }
        if(claimBatchStageRecordList!=null && claimBatchStageRecordList.size()>0){
            //Insert batch stage records
            insert claimBatchStageRecordList;
        }
    }
    
    public static Date convertDateToStandardDate(String inputDate){
        // input Date in format : 10-Feb-2019
        // inputDateArray (10,Feb,2019)
        try{
            String[] inputDateArray = inputDate.split('-');
            //if(inputDateArray != null && inputDateArray.size() == 3){ 
            String monthInUpperCase = inputDateArray[1].toUpperCase(); 
            Integer month = 0;
            switch on monthInUpperCase {
                when 'JAN' { month = 1; } when 'FEB' { month = 2; } when 'MAR' { month = 3; } when 'APR' { month = 4; } when 'MAY' { month = 5; }
                when 'JUN' { month = 6; } when 'JUL' { month = 7; } when 'AUG' { month = 8; } when 'SEP' { month = 9; } when 'OCT' { month = 10; }
                when 'NOV' { month = 11; } when 'DEC' { month = 12; } when else { month = 0; }
            }
            Date todayDate = System.today();
            Date standardDate;
            String currentCentury = String.valueOf(todayDate.year()).substring(0,2);
            String finalYear = currentCentury+inputDateArray[2];
            if(month == 0){  throw new BulkClaimException('Invalid Date');
                          }else{
                              standardDate = Date.newInstance(Integer.valueOf(finalYear),month,Integer.valueOf(inputDateArray[0]));
                          }
            return standardDate;
        }catch(Exception e){
            throw new BulkClaimException(Label.Core_MDF_InvalidDateError+': '+inputDate);
        }
    }
    
    public static boolean validateUploadedFile(Blob blobData, Map<Id,Core_MDF_CCP_Custom_Metadata_Utility__c> metadataIdToRecordMap){
        String csvAsString;
        String[] csvFileLines;
        //Special Characters check
        try{
            csvAsString = blobData.toString(); 
        }catch(Exception e){
            throw new BulkClaimException(Label.Core_MDF_BulkClaimErrorMessage);
        } 
        csvFileLines = csvAsString.split('\n');
        Integer size = csvFileLines.size()-1;
        
        if(size == 0){ throw new BulkClaimException(Label.Core_MDF_BulkClaimEmptyFileUploaded);}
        if(size > 0){
            String[] singleLineData = csvFileLines[1].split(',');
            if(singleLineData.size() != metadataIdToRecordMap.size()){
                throw new BulkClaimException(Label.Core_MDF_UploadedDataError); 
            }
        }
        if(size > Integer.valueOf(Label.Core_MDF_Bulk_Claim_List_Size)){
            throw new BulkClaimException(Label.Core_MDF_Uploaded_File_Contains_more_than_500_Claims); 
        }else{
            return true;
        }
    }
    
    /****************************************************************************************************** 
Method Name:        fetchRecordTypeMetaData
@return  :          Map of claim and activity recordtype 
@parameters:        N/A
Description:        This method is used to fetch record type meta data and create a map
Added By:           Accenture - AD - 4/5/2019
Modified By:        Date:      Changes: 
*******************************************************************************************************/    
    @AuraEnabled
    public static Map<String,String> fetchRecordTypeMetaData(){
        
        Map<String,String> mapOfRecordTypes = new Map<String,String>();
        for(Core_MDF_ObjRecType_Budget_FieldSetMap__mdt recTypeMetaData:[Select Core_MDF_Channel_Program_txt__c,MasterLabel 
                                                                       from Core_MDF_ObjRecType_Budget_FieldSetMap__mdt LIMIT 1000]){ //TWC3117-18333
                                                                           mapOfRecordTypes.put(recTypeMetaData.Core_MDF_Channel_Program_txt__c,recTypeMetaData.MasterLabel);  
                                                                       }
        return mapOfRecordTypes;
        
    }
    
    /**
* @description : This method is used to fetch the Language of the logged in User and return the Template File Id correspondingly 
* @return: The Template File Id  
*/
    @AuraEnabled
    public static List<String> fetchUserAndTemplateDetails(String programName) {
        
        List<String> userAndTemplateDetailList = new List<String>();
        String userLanguage = UserInfo.getLanguage();
        String[] filterCondition = new String[]{'%'+userLanguage+'%','%en_US%'};
            String programNameFilter = '%'+programName+'%';
        User oUser = [select id,UserType 
                      FROM User Where id =: userInfo.getUserId()];
        List<Document> templateFileList = [ SELECT id,Name FROM Document WHERE (Folder.DeveloperName =: System.Label.Core_MDF_FolderName) 
                                           AND (Name like :filterCondition) AND (Name like :programNameFilter)];
        if(templateFileList.size()>1){
            for(Document templateFile : templateFileList){ if(templateFile.Name.contains(userLanguage)){   userAndTemplateDetailList.add(templateFile.Id);
                                                                                                       }
                                                         }
        }else{
            if(templateFileList.size()>0){  userAndTemplateDetailList.add(templateFileList[0].Id);
                                         }
        }
        if(oUser!=null){
            userAndTemplateDetailList.add(oUser.UserType);
        }   
        return userAndTemplateDetailList;   
    }
    
    /****************************************************************************************************** 
Method Name:        fetchAvailActSubTypeValues
@return  :          List<String> 
@parameters:        String ProgramName
Description:        This method is used to fetch available active activity sub type values based on record type
Added By:           Accenture - HP - 9/27/2021
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    
    @AuraEnabled
    public static List<String> fetchAvailActSubTypeValues(String programName) {
        String pfrRecTypeDevName;
        Id pfrRecTypeId;
        List<String> actSubTypeList = new List<String>();
        if(String.isNotEmpty(programName) && programName != NULL){
            pfrRecTypeDevName = [Select Core_MDF_Activity_RecordType_txt__c from Core_MDF_ObjRecType_Budget_FieldSetMap__mdt WHERE Core_MDF_Channel_Program_txt__c =: programName].Core_MDF_Activity_RecordType_txt__c;//TWC3117-18333
        } 
        if(String.isNotEmpty(pfrRecTypeDevName) && pfrRecTypeDevName != NULL){            
            pfrRecTypeId = Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get(pfrRecTypeDevName).getRecordTypeId();
        }
        if(pfrRecTypeId != NULL){
            actSubTypeList = picklistFetcher(pfrRecTypeId);
        }        
        return actSubTypeList;
    }
    
    /****************************************************************************************************** 
Method Name:        picklistFetcher
@return  :          List<String> 
@parameters:        String ProgramName
Description:        Method to fetch picklist values from Activity using UI API
Added By:           Accenture - HP - 10/05/2021
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    public static List<String> picklistFetcher(Id pfrRecTypeId) {
        List<String> actSubTypeList = new List<String>();
        
        // Instantiating a new http object
        Http h = new Http();
        
        // Instantiating a new HTTP request
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:ActivitySubTypeUIAPI/'+pfrRecTypeId+'/Core_MDF_Activity_SubType_nm__c');
        req.setMethod('GET');
        
        // Sending the request, and returning a response
        HttpResponse res = h.send(req);
        String strResponse = res.getBody();
        Map<String, Object> resMap = new Map<String, Object>();
        if(String.isNotEmpty(strResponse)){
            resMap =  (Map<String, Object>) JSON.deserializeUntyped(strResponse);   
        }
        
        if(resMap != NULL && resMap.containsKey('values')){                                
            for(Object obj: (List<Object>)resMap.get('values')){
                Map<String, object > temp = (Map<String, object>)obj; 
                actSubTypeList.add((String)temp.get('label'));
            }
        }
        actSubTypeList.sort();
        return actSubTypeList;        
    } 
    /****************************************************************************************************** 
Method Name:        fetchAvailCountries
@return  :          List<String> 
@parameters:        null
Description:        This method is used to fetch available active country values.
Added By:           Accenture - HP - 9/27/2021
Modified By:        Date:      Changes: 
*******************************************************************************************************/    
    @AuraEnabled
    public static List<String> fetchAvailCountries() {
        List<String> countryList = new List<String>();
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Core_MDF_Claim_Batch_Stage__c').getDescribe().fields.getMap();
        List<Schema.PicklistEntry> countryPicklistvalues = fieldMap.get('Core_MDF_Country_Location_nm__c').getDescribe().getPickListValues();
        for(Schema.PicklistEntry countryField : countryPicklistvalues){
            countryList.add(countryField.getValue().toUpperCase());
        }
        return countryList;
    }
    
    /****************************************************************************************************** 
Method Name:        fetchAvailCurrencies
@return  :          List<String> 
@parameters:        String ProgramName
Description:        This method is used to fetch available active currency values.
Added By:           Accenture - HP - 9/27/2021
Modified By:        Date:      Changes: 
*******************************************************************************************************/     
    @auraEnabled
    public static List<pickListWrapper> fetchAvailCurrencies() {
        // To hold the list of currency name and currency code
        List<pickListWrapper> pLWrapperList = new List<pickListWrapper>();       
        List<string> currNameCodeList = new List<string>();
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('PartnerFundRequest').getDescribe().fields.getMap();
        List<Schema.PicklistEntry> picklistvalues = fieldMap.get('Core_MDF_Budget_Currency_cd__c').getDescribe().getPickListValues();
        for(Schema.PicklistEntry currencyField : picklistvalues){
            String currName = (currencyField.getLabel().split('-')[1]);
            String currCode = currencyField.getValue();
            currNameCodeList.add(currName.trim()+'-'+currCode); 
        }
        currNameCodeList.sort();
        for(String str : currNameCodeList){
            pickListWrapper pLWrapper = new pickListWrapper();
            pLWrapper.currencyCode = (str.split('-')[1]); 
            pLWrapper.currencyName = (str.split('-')[0]);
            pLWrapperList.add(pLWrapper);
        }
        return pLWrapperList;
    }
    //WW11 - Added by JK Display Info Message for Bulk claim Template
    @AuraEnabled
    public static boolean displayInfoMessage() {
        boolean errorMsgInd;
        try{
            String infoMessage = Core_MDF_Configuration__c.getValues('Core_MDF_InfoMessageDisplay').Core_MDF_Value__c;
            if(infoMessage != null && infoMessage == 'true'){
                errorMsgInd = true;
            }
        }catch (Exception e) {}
        return errorMsgInd;
    }
    // wrapper class with @AuraEnabled
    public class PickListWrapper{
        // Holds the 3 character currency code 
        @AuraEnabled
        public String currencyCode;
        // Holds the currency name
        @AuraEnabled
        public String currencyName;        
    }    
}