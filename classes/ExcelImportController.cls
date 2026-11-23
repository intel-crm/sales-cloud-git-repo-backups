public with sharing class ExcelImportController { 
    
    public virtual class BulkClaimException extends Exception {}     
    /**
* @description : This method is used to Parse the File Uploaded by User. Insert the Batch Record. Attach the Uploaded file to Batch Record. 
Insert the Batch Stage Records corresponding to the Uploaded File
* @param base64Data : Content of the File in Base64 format 
* @param fileName : File Name 
* @param contentType : Type of the File (CSV)
*/
    @AuraEnabled
    public static void parseFile(String base64Data, String fileName, String channelProgramId) {
        System.debug('In ParseFile');
        Id ultimateAccId = Core_MDF_BulkClaimUtility.validateAccountAccess();
        try {
            System.debug('base64DatafromJS::'+base64Data);
            System.debug('fileNamefromJS::'+fileName);
            System.debug('channelProgramIdfromJS::'+channelProgramId);
            Blob blobData = Blob.valueOf(base64Data);
            System.debug('blobData::'+blobData);
            //String base64Data1 = EncodingUtil.Base64Encode( Blob.valueOf( base64Data ) );
            //base64Data1 = EncodingUtil.urlDecode(base64Data1, 'UTF-8');
            //Blob blobData = EncodingUtil.base64Decode(base64Data1);
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
            //Ameya - added
            //batchInstance = Core_MDF_BulkClaimUtility.createBatchRecordInstance(channelProgramId);
            // Create Claim Batch Record and Insert the Uplaoded file
            //batchInstance = Core_MDF_BulkClaimUtility.createBatchRecordAndAttachUploadedTemplate(fileName,channelProgramId,blobData);
            //batchInstance = Core_MDF_BulkClaimUtility.insertBatchRecordAndAttachUploadedTemplate(batchInstance,channelProgramId,fileName,blobData);
            batchInstance = Core_MDF_BulkClaimUtility.insertBatchRecordAndAttachUploadedTemplate(ultimateAccId,channelProgramId,fileName,blobData);
            if(batchInstance != null){
                // Create Claim Batch Stage Records 
                createClaimBatchStageRecords(batchInstance,metadataIdToRecordMap,recordType,blobData);
            }
            //return batchInstance.Id;    
        }catch(BulkClaimException e){
            System.debug('BulkClaimException::::'+e.getMessage()); 
            Core_MDF_CCP_UtilityClass.logError(e); 
            //return 'UIException'+e.getMessage(); 
        }catch (Exception e) {
            System.debug('Exception::::'+e); 
            Core_MDF_CCP_UtilityClass.logError(e); 
            //return 'Exception'+e.getMessage();
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
        csvAsString = blobData.toString();
        system.debug('Before JSON Formator csvAsString::' + csvAsString);
        
        String csvAsString1 = jsonFormator(csvAsString);
        
        System.debug('After JSON Formator csvAsString1::'+csvAsString1);
        
        // csvAsString = '{"Claim Name":"Test 1","Activity #":"11291","Execution Start Date(DD-MMM-YY)":"4-Jun-19","Execution End Date(DD-MMM-YY)":"4-Jun-19","Media Vehicle":"1mm17y6543","Bank (Supplier ID)":"9874789096","Invoice/Receipt Date(DD-MMM-YY)":"4-Jun-19","Invoice/Receipt Number":"re1234","Invoice/Receipt Currency":"USD","Total Amount (Local)":"4000","Costs not Reimbursable (Local)":"0","Taxes (Local)":"0","Claim Comments":"Test1"}';
        List<JSON2ApexController> objList = JSON2ApexController.parse(csvAsString1);
        System.debug('After JSON deserialize objList::'+objList);
        System.debug('objList[0]::'+objList[0]);
        
        List<Core_MDF_Claim_Batch_Stage__c> batchClaimStageList = new List<Core_MDF_Claim_Batch_Stage__c>();
        
        for(JSON2ApexController item: objList) {
            
            Core_MDF_Claim_Batch_Stage__c batchClaimStageRecord = new Core_MDF_Claim_Batch_Stage__c();
            batchClaimStageRecord.RecordtypeId = '0121J000000yaohQAA';
            batchClaimStageRecord.Core_MDF_Batch_ID__c = batchInstance.Id;
            BatchClaimStageRecord.Core_MDF_Claim_Nm__c = item.ClaimName;
            
            String inputActivityNumber = item.ActivityN;
            inputActivityNumber = inputActivityNumber.leftPad(8, '0');
            
            BatchClaimStageRecord.Core_MDF_Activity_Nbr__c = inputActivityNumber;
            Date standardDate = convertDateToStandardDate(item.AdRunStartDate);
            BatchClaimStageRecord.Core_MDF_Ad_Run_Start_Dt__c = standardDate;
            Date standardDate1 = convertDateToStandardDate(item.AdRunEndDate);
            BatchClaimStageRecord.Core_MDF_Ad_Run_End_Dt__c = standardDate1;
            BatchClaimStageRecord.Core_MDF_Media_Vehicle_txt__c = item.MediaVehicle;
            BatchClaimStageRecord.Core_MDF_Bank_Nbr__c = item.BankSupplierID;
            Date standardDate2 = convertDateToStandardDate(item.InvoiceReceiptDate);
            BatchClaimStageRecord.Core_MDF_Inv_Receipt_Dt__c = standardDate2;
            BatchClaimStageRecord.Core_MDF_Inv_Receipt_Nbr__c = item.InvoiceReceiptNumber;
            BatchClaimStageRecord.Core_MDF_Inv_Receipt_Cur_Cd__c = item.InvoiceReceiptCurrency;
            BatchClaimStageRecord.Core_MDF_Total_Amt__c = decimal.valueof(item.TotalAmountLocal);
            BatchClaimStageRecord.Core_MDF_Non_Reimbursable_Amt__c = decimal.valueof(item.CostsNotReimbursableLocal);
            BatchClaimStageRecord.Core_MDF_Taxes_Local_Amt__c = decimal.valueof(item.TaxesLocal);
            BatchClaimStageRecord.Core_MDF_Claim_Comment_txt__c = item.ClaimComments;   
            batchClaimStageList.add(BatchClaimStageRecord);
        }
        
        try{
            database.insert(batchClaimStageList);
        } catch(Exception e) {
            System.debug('Insert Exception::::'+e.getMessage());
            Core_MDF_CCP_UtilityClass.logError(e);
        }        
    }
    
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
    
    public static List<JSON2ApexController> parse(String jsonString) {
        return (List<JSON2ApexController>) System.JSON.deserialize(jsonString, List<JSON2ApexController>.class);
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
    
    public static String jsonFormator(String jsonString) {
        String target = 'Claim Name';
        String replacement = 'ClaimName';
        String jsonString1 = jsonString.replace(target, replacement);
        target = 'Activity #';
        replacement = 'ActivityN';
        jsonString1 = jsonString1.replace(target, replacement);
        target = 'Execution Start Date(DD-MMM-YY)';
        replacement = 'AdRunStartDate';
        jsonString1 = jsonString1.replace(target, replacement);
        target = 'Execution End Date(DD-MMM-YY)';
        replacement = 'AdRunEndDate';
        jsonString1 = jsonString1.replace(target, replacement);
        target = 'Media Vehicle';
        replacement = 'MediaVehicle';
        jsonString1 = jsonString1.replace(target, replacement);
        target = 'Bank (Supplier ID)';
        replacement = 'BankSupplierID';
        jsonString1 = jsonString1.replace(target, replacement);
        target = 'Invoice/Receipt Date(DD-MMM-YY)';
        replacement = 'InvoiceReceiptDate';
        jsonString1 = jsonString1.replace(target, replacement);
        target = 'Invoice/Receipt Number';
        replacement = 'InvoiceReceiptNumber';
        jsonString1 = jsonString1.replace(target, replacement);
        target = 'Invoice/Receipt Currency';
        replacement = 'InvoiceReceiptCurrency';
        jsonString1 = jsonString1.replace(target, replacement);
        target = 'Total Amount (Local)';
        replacement = 'TotalAmountLocal';
        jsonString1 = jsonString1.replace(target, replacement);
        target = 'Costs not Reimbursable (Local)';
        replacement = 'CostsNotReimbursableLocal';
        jsonString1 = jsonString1.replace(target, replacement);
        target = 'Taxes (Local)';
        replacement = 'TaxesLocal';
        jsonString1 = jsonString1.replace(target, replacement);
        target = 'Claim Comments';
        replacement = 'ClaimComments';
        jsonString1 = jsonString1.replace(target, replacement);
        
        return jsonString1;
    }
    
    public static Date convertDateToStandardDate(String inputDate){
        // input Date in format : 10-Feb-2019
        // inputDateArray (10,Feb,2019)
        try{
            String[] inputDateArray = inputDate.split('-');
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
}