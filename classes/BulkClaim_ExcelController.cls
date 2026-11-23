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
public with sharing class BulkClaim_ExcelController { 
    
    public virtual class BulkClaimException extends Exception {}     
    /**
* @description : This method is used to Parse the File Uploaded by User. Insert the Batch Record. Attach the Uploaded file to Batch Record. 
Insert the Batch Stage Records corresponding to the Uploaded File
* @param base64Data : Content of the File in Base64 format 
* @param fileName : File Name 
* @param contentType : Type of the File (CSV)
*/
    @AuraEnabled
    public static String parseFile(String base64Data, String fileName, String channelProgramId) {
        System.debug('base64Data::'+base64Data);
        String resultBase64Data = EncodingUtil.Base64Encode( Blob.valueOf( base64Data ) );
        System.debug('resultBase64Data::'+resultBase64Data);
        try {
            resultBase64Data = EncodingUtil.urlDecode(resultBase64Data, 'UTF-8');
            Blob blobData = EncodingUtil.base64Decode(resultBase64Data);
            Core_MDF_Claim_Batch__c batchInstance = new Core_MDF_Claim_Batch__c();
            String channelProgramName = [Select Core_MDF_Technical_Program_Name__c From ChannelProgram WHERE Id =:channelProgramId LIMIT 1].Core_MDF_Technical_Program_Name__c;
            
            Map<Id,Core_MDF_BulkClaimTemplateParticulars__mdt> metadataIdToRecordMap = new Map<Id,Core_MDF_BulkClaimTemplateParticulars__mdt>([SELECT Id,Core_MDF_Stage_Field_API_Name__c,Core_MDF_Field_DataType_Txt__c,Core_MDF_Column_Index__c,
                                                                                                                                               Core_MDF_Target_Field_API_Name__c, Core_MDF_Stage_Required_Ind__c
                                                                                                                                               FROM Core_MDF_BulkClaimTemplateParticulars__mdt
                                                                                                                                               WHERE Core_MDF_Channel_program__c = :channelProgramName
                                                                                                                                               AND Core_MDF_Upload_Record_Type__c =:Label.Core_MDF_PFCText
                                                                                                                                               ORDER BY Core_MDF_Column_Index__c]);
            Core_MDF_ClaimActAllocRecTypeMapping__mdt  recordType = [SELECT Id, Core_MDF_ClaimStage_RecordType_txt__c
                                                                     FROM Core_MDF_ClaimActAllocRecTypeMapping__mdt
                                                                     WHERE Core_MDF_Channel_Program_Name_txt__c = :channelProgramName LIMIT 1];
            Id ultimateAccId = Core_MDF_BulkClaimUtility.validateAccountAccess();
            if(validateUploadedFile(blobData,metadataIdToRecordMap)){
                // Create Claim Batch Record and Insert the Uplaoded file
                batchInstance = Core_MDF_BulkClaimUtility.insertBatchRecordAndAttachUploadedTemplate(ultimateAccId,channelProgramId,fileName,blobData);
                if(batchInstance != null){
                    // Create Claim Batch Stage Records 
                    createClaimBatchStageRecords(batchInstance,metadataIdToRecordMap,recordType,blobData);
                }
            }
            return batchInstance.Id;    
        }catch(BulkClaimException e){
            System.debug('BulkClaimException::::'+e.getMessage()); 
            Core_MDF_CCP_UtilityClass.logError(e); 
            return 'UIException'+e.getMessage(); 
        }catch (Exception e) {
            System.debug('Exception::::'+e); 
            Core_MDF_CCP_UtilityClass.logError(e); 
            return 'Exception'+e.getMessage();
        }
    }
    /**
* @description: This method is used to create the Claim Batch Stage records based on the CSV Data as Input
* @param blobData: Content of the File Uploaded by the User in Blob format 
*/
    public static void createClaimBatchStageRecords(Core_MDF_Claim_Batch__c batchInstance,Map<Id,Core_MDF_BulkClaimTemplateParticulars__mdt> metadataIdToRecordMap,Core_MDF_ClaimActAllocRecTypeMapping__mdt  recordType, Blob blobData)
    {
        String csvAsString;
        String[] csvFileLines;
        System.debug('blobData:::'+blobData);
        csvAsString = blobData.toString(); //EncodingUtil.base64Encode(base64Data);//base64Data.toString();
        system.debug('csvAsString::' + csvAsString);
        csvFileLines = csvAsString.split('\n');
        
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Core_MDF_Claim_Batch_Stage__c').getDescribe().fields.getMap();
        List<Schema.PicklistEntry> picklistvalues = fieldMap.get('Core_MDF_Inv_Receipt_Cur_Cd__c').getDescribe().getPickListValues();
        List<String> currencyValueList = new List<String>();
        
        for(Schema.PicklistEntry currencyField : picklistvalues){
            currencyValueList.add(currencyField.getValue().toUpperCase());
        }
        List<Core_MDF_Claim_Batch_Stage__c> claimBatchStageRecordList = new List <Core_MDF_Claim_Batch_Stage__c>();
        Id recordTypeId = Schema.SObjectType.Core_MDF_Claim_Batch_Stage__c.getRecordTypeInfosByDeveloperName().get(recordType.Core_MDF_ClaimStage_RecordType_txt__c).getRecordTypeId();
        String errorToBeDisplayed = '';
        for(Integer i = 1; i < csvFileLines.size(); i++)
        {
            Core_MDF_Claim_Batch_Stage__c claimStageInstance = new Core_MDF_Claim_Batch_Stage__c();
            for(Core_MDF_BulkClaimTemplateParticulars__mdt metadataRecord : metadataIdToRecordMap.values())
            {
                String[] csvRecordData;
                try {
                    claimStageInstance.RecordtypeId = recordTypeId;
                    claimStageInstance.Core_MDF_Batch_ID__c = batchInstance.Id;
                    csvRecordData = csvFileLines[i].split(','); 
                    if(metadataRecord.Core_MDF_Field_DataType_Txt__c == 'Date'){
                        Date standardDate = convertDateToStandardDate(csvRecordData[(Integer)metadataRecord.Core_MDF_Column_Index__c]);
                        claimStageInstance.put(metadataRecord.Core_MDF_Stage_Field_API_Name__c,standardDate);
                    }else if(metadataRecord.Core_MDF_Field_DataType_Txt__c == 'Number'){
                        claimStageInstance.put(metadataRecord.Core_MDF_Stage_Field_API_Name__c,decimal.valueOf(csvRecordData[(Integer)metadataRecord.Core_MDF_Column_Index__c]));
                    }else if(metadataRecord.Core_MDF_Stage_Field_API_Name__c == 'Core_MDF_Activity_Nbr__c'){
                        // input Activity Number : 2179 
                        String inputActivityNumber = csvRecordData[(Integer)metadataRecord.Core_MDF_Column_Index__c];
                        // append leading zeroes
                        inputActivityNumber = inputActivityNumber.leftPad(8, '0');
                        claimStageInstance.put(metadataRecord.Core_MDF_Stage_Field_API_Name__c,inputActivityNumber);
                    }else if(metadataRecord.Core_MDF_Stage_Field_API_Name__c == 'Core_MDF_Inv_Receipt_Cur_Cd__c'){
                        if(currencyValueList.contains(csvRecordData[(Integer)metadataRecord.Core_MDF_Column_Index__c].toUpperCase())){
                            claimStageInstance.put(metadataRecord.Core_MDF_Stage_Field_API_Name__c,csvRecordData[(Integer)metadataRecord.Core_MDF_Column_Index__c]);
                        }else{
                            throw new BulkClaimException(Label.Core_MDF_InvalidCurrencyError+': '+csvRecordData[(Integer)metadataRecord.Core_MDF_Column_Index__c]);
                        }
                    }else{
                        //Truncate Fields to 255 characters if greater than 255 characters 
                        claimStageInstance.put(metadataRecord.Core_MDF_Stage_Field_API_Name__c,csvRecordData[(Integer)metadataRecord.Core_MDF_Column_Index__c].length() > Integer.valueOf(System.Label.Core_MDF_MaximumTextLimit) ? csvRecordData[(Integer)metadataRecord.Core_MDF_Column_Index__c].substring(0, Integer.valueOf(System.Label.Core_MDF_MaximumTextLimit)) : csvRecordData[(Integer)metadataRecord.Core_MDF_Column_Index__c]);                   			                        	
                    }
                }catch (Exception e) {
                    if(e.getMessage().trim().contains(Label.Core_MDF_BulkClaimInvalidDecimal)){
                        errorToBeDisplayed +=  Label.Core_MDF_RowErrorText + i + ' :- '+Label.Core_MDF_InvalidAmountError+': '+csvRecordData[(Integer)metadataRecord.Core_MDF_Column_Index__c]+'\n';     
                    }else{errorToBeDisplayed +=  Label.Core_MDF_RowErrorText + i + ' :- '+e.getMessage()+ '\n';}
                }
            }
            claimBatchStageRecordList.add(claimStageInstance);
        }
        System.debug('errorToBeDisplayed::'+errorToBeDisplayed);
        if(!String.isEmpty(errorToBeDisplayed)){throw new BulkClaimException(''+errorToBeDisplayed);}
        Database.insert(claimBatchStageRecordList);
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
    
    public static boolean validateUploadedFile(Blob blobData, Map<Id,Core_MDF_BulkClaimTemplateParticulars__mdt> metadataIdToRecordMap){
        
        String csvAsString;
        String[] csvFileLines;
        //csvAsString = blobData.toString();
        //Special Characters check
        try{
            csvAsString = blobData.toString();
        }catch(Exception e){
            throw new BulkClaimException(Label.Core_MDF_BulkClaimErrorMessage);
        } 
        system.debug('csvAsString::' + csvAsString);
        csvFileLines = csvAsString.split('\n');
        system.debug('csvFileLines::' + csvFileLines+csvFileLines.size());
        Integer size = csvFileLines.size()-1;
        
        if(size == 0){ throw new BulkClaimException(Label.Core_MDF_BulkClaimEmptyFileUploaded);}
        if(size > 0){
            String[] singleLineData = csvFileLines[1].split(','); 
            if(singleLineData.size() != metadataIdToRecordMap.size()){
                System.debug('singleLineData:'+singleLineData+singleLineData.size());
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
        for(Core_MDF_ClaimActAllocRecTypeMapping__mdt recTypeMetaData:[Select Core_MDF_Channel_Program_txt__c,MasterLabel 
                                                                       from Core_MDF_ClaimActAllocRecTypeMapping__mdt]){
                                                                           mapOfRecordTypes.put(recTypeMetaData.Core_MDF_Channel_Program_txt__c,recTypeMetaData.MasterLabel);  
                                                                       }
        System.debug('mapOfRecordTypes>>'+mapOfRecordTypes);
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
        System.debug('userLanguage:::::'+userLanguage);
        String[] filterCondition = new String[]{'%'+userLanguage+'%','%en_US%'};
            String programNameFilter = '%'+programName+'%';
        System.debug('programNameFilter>>'+programNameFilter);
        User oUser = [select id,UserType 
                      FROM User Where id =: userInfo.getUserId()];
        
        List<Document> templateFileList = [ SELECT id,Name FROM Document WHERE (Folder.DeveloperName =: System.Label.Core_MDF_FolderName) 
                                           AND (Name like :filterCondition) AND (Name like :programNameFilter)];
        
        System.debug('templateFileList>>'+templateFileList);
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
         public static List<JSON2ApexController> parse(String json) {
            return (List<JSON2ApexController>) System.JSON.deserialize(json, List<JSON2ApexController>.class);
        }   
    public class JSON2ApexController {
        
        public String ClaimName;
        public String ActivityN;
        public String AdRunStartDate;
        public String AdRunEndDate;
        public String MediaVehicle;
        public String BankSupplierID;
        public String InvoiceReceiptDate;
        public String InvoiceReceiptNumber;
        public String InvoiceReceiptCurrency;
        public String TotalAmountLocal;
        public String CostsNotReimbursableLocal;
        public String TaxesLocal;
        public String ClaimComments;
        
        

    }    
}