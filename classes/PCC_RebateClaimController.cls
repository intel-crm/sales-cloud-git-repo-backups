/****************************************************************************************************
Apex Class Name : PCC_RebateClaimController
Version         : 1.0 
Created Date    : 06/Jun/2024
Function        : This class is used to get the partner accounts, field set labels, records and save the file.
It is used in the PCC_RebateClaim component.
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Pranjal Rajput                    06/Jun/2024               Created
*****************************************************************************************************/
public with sharing class PCC_RebateClaimController {
    
    /****************************************************************
Method Name: getPartnerAccounts
Description: This method is used to get the partner accounts.
*****************************************************************/
    @AuraEnabled(cacheable=true)
    public static  List<Map<String,String>>  getPartnerAccounts(){
        List<Map<String,String>> partnerAccountOptions = new List<Map<String,String>>(); 
        try {
            List<Core_Contact_Entitlement__c> listContEntitlement = [select Id,Core_Contact_Id__r.AccountId, Core_Contact_Id__r.Account.Name  from Core_Contact_Entitlement__c  where  Core_Entitlement_Id__r.Name = 'Partner Portal- Deal Reg'];
            Set<String> partnerAccountSet = new Set<String>();
            Map<string,string> partnerAccountMap = new Map<string,string>();
            for(Core_Contact_Entitlement__c ContEntitlement : listContEntitlement) { 
                partnerAccountSet.add(ContEntitlement.Core_Contact_Id__r.AccountId);
                partnerAccountMap.put(ContEntitlement.Core_Contact_Id__r.AccountId,ContEntitlement.Core_Contact_Id__r.Account.Name);
            }
            Map<String,String> mapValue;
            for(String key:partnerAccountSet){
                mapValue = new Map<String,String>();
                mapValue.put('label',partnerAccountMap.get(key));
                mapValue.put('value',key);
                partnerAccountOptions.add(mapValue);
            }
            
        } catch (Exception ex) { 
            insert new Core_Log_Entry__c(Core_Message__c = ex.getMessage(),Core_Details__c = ex.getMessage() + '\n'+ ex.getStackTraceString(), Core_Origin__c='PCC_RebateClaimController.getPartnerAccounts', Core_Severity__c='low', Core_When__c=System.Now(), Core_Project__c = 'PCC_RebateClaim');   
        }
        return partnerAccountOptions;
        
        
    }
    
    /****************************************************************
Method Name: getFieldSetLabels
Description: This method is used to get the field set.
*****************************************************************/
    @AuraEnabled(cacheable=true)
    public static Map<String,List<String>> getFieldSetLabels() {
        Map<String,List<String>> fieldMap = new  Map<String,List<String>>();
        List<String> labels = new List<String>();
        List<String> apinames = new List<String>();
        try {
            // Get the field set labels and API names
            Schema.SObjectType objectType = Schema.getGlobalDescribe().get(PCC_Constants.RC_ObjectName);
            if (objectType != null) {
                Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
                if (objectDescribe != null) {
                    Schema.FieldSet fieldSet = objectDescribe.FieldSets.getMap().get(PCC_Constants.RC_FieldSetName);
                    if (fieldSet != null) {
                        for (Schema.FieldSetMember field : fieldSet.getFields()) {
                            labels.add(field.getLabel());
                            apinames.add(field.getFieldPath());
                        }
                    }
                }
            }
        } catch (Exception ex) {
            // Handle the exception and log the error
            insert new Core_Log_Entry__c(Core_Message__c = ex.getMessage(),Core_Details__c = ex.getMessage() + '\n'+ ex.getStackTraceString(), Core_Origin__c='PCC_RebateClaimController.getFieldSetLabels', Core_Severity__c='low', Core_When__c=System.Now(), Core_Project__c = 'PCC_RebateClaim');
        }
        fieldMap.put('labels',labels);
        fieldMap.put('apinames',apinames);
        return fieldMap;
    }
    
    /****************************************************************
Method Name: getProcessedRCRecords
Description: This method is used to get the processed RC records.
*****************************************************************/
    @AuraEnabled(cacheable=true)
    public static RebateClaimWrapper getProcessedRCRecords(String recordId) {
        RebateClaimWrapper rcw = new RebateClaimWrapper();
        List<PCC_Rebate_Claim_Stage__c> listRebateClaims = new List<PCC_Rebate_Claim_Stage__c>();
        try {
            // Get the field set labels
            Map<String,List<String>> fieldMap = PCC_RebateClaimController.getFieldSetLabels();
            // Add the status and error message fields
            fieldMap.get('labels').add('Status');
            fieldMap.get('apinames').add('PCC_Status__c');
            fieldMap.get('labels').add('Error Message');
            fieldMap.get('apinames').add('PCC_Error_Messages__c');
            String fields  = String.join(fieldMap.get('apinames'),',');
            // Query the records based on the parent record id 
            listRebateClaims = Database.query('SELECT '+String.escapeSingleQuotes(fields)+' FROM PCC_Rebate_Claim_Stage__c WHERE PCC_Parent_Record__c= :recordId');
            rcw.rebateClaimList = listRebateClaims;
            rcw.fieldMap = fieldMap;
            // Get the file name  ContentDocument.Title from the ContentDocumentLink 
            List<ContentDocumentLink> cdl =  [Select Id,ContentDocument.Title,ContentDocument.FileExtension from ContentDocumentLink where LinkedEntityId = :recordId LIMIT 1];
            if(cdl.size()>0){
                rcw.fileName = cdl[0].ContentDocument.Title+'.'+cdl[0].ContentDocument.FileExtension;
            }
        } catch (Exception ex) {
            // Handle the exception and log the error
            insert new Core_Log_Entry__c(Core_Message__c = ex.getMessage(),Core_Details__c = ex.getMessage() + '\n'+ ex.getStackTraceString(), Core_Origin__c='PCC_RebateClaimController.getProcessedRCRecords', Core_Severity__c='low', Core_When__c=System.Now(), Core_Project__c = 'PCC_RebateClaim');
        }
        return rcw;
    }
    
    /***************************************************************************
Method Name: createStageRecordsfromCSV
Description: This method is used to create the RC stage records from CSV.
*****************************************************************************/    
    @AuraEnabled
    public static ResultWrapper createStageRecordsfromCSV(String base64Data, String partnerInfo,String templateName,Boolean isPartner) {
        
        try {
            ResultWrapper rw = new ResultWrapper();
            rw.status = 'pending';
            // Check if the partner exists from the given email
            List<Contact> contactList = new List<Contact>();
            if(!isPartner){
                contactList = [Select Id,AccountId FROM Contact WHERE email=:partnerInfo];
                if(contactList.size()==0){
                    rw.status = 'failed';
                    rw.message = 'Partner with the given email does not exist';
                }
                if(contactList.size()>1){
                    rw.status = 'failed';
                    rw.message = 'Multiple partners with the given email exist';
                }
                if(contactList.size()==1){
                    List<Core_Contact_Entitlement__c>  ceList= [select Id,Core_Contact_Id__r.AccountId, Core_Contact_Id__r.Account.Name  from Core_Contact_Entitlement__c  where  Core_Entitlement_Id__r.Name = 'Partner Portal- Deal Reg' and Core_Contact_Id__c=:contactList[0].Id];
                    if(ceList.size()==0){
                        rw.status = 'failed';
                        rw.message = 'Partner with the given email is not a Deal Partner';
                    }
                }
            }
            // Get the field set labels
            Map<String,List<String>> fieldMap = PCC_RebateClaimController.getFieldSetLabels();
            List<String> fieldsNames = new List<String>();
            List<String> labelNames = new List<String>();
            fieldsNames = fieldMap.get('apinames');
            labelNames = fieldMap.get('labels');
            
            String data = JSON.deserializeUntyped(base64Data).toString();
            
            list <PCC_Rebate_Claim_Stage__c > lstRCSToInsert = new list <PCC_Rebate_Claim_Stage__c> ();
            list <String> lstCSVLines = data.split('\r\n');
            
            List<String> headers = lstCSVLines[0].split(',');
            Map<Integer,String> headerMap = new Map<Integer,String>();
            Integer index=0;
            
            for(String labelName: labelNames){
                if(!headers.contains(labelName)){
                    rw.status = 'failed';
                    rw.message = 'The CSV file does not match the template';
                }
            }  
            
            if(rw.status!='failed'){
                Id recTypeParentId = Schema.SObjectType.PCC_Rebate_Claim_Stage__c.getRecordTypeInfosByDeveloperName().get('Header').getRecordTypeId();
                Id recTypeChildId = Schema.SObjectType.PCC_Rebate_Claim_Stage__c.getRecordTypeInfosByDeveloperName().get('Line_Items').getRecordTypeId();
                
                
                for(String labelName: headers){
                    if(labelNames.contains(labelName)){
                        headerMap.put(index,fieldsNames[labelNames.indexOf(labelName)]);
                    }
                    index=index+1;
                }   
                
                // Create the parent record
                PCC_Rebate_Claim_Stage__c parentRCS = new PCC_Rebate_Claim_Stage__c();
                parentRCS.RecordTypeId = recTypeParentId;
                parentRCS.PCC_Status__c='Pending';
                parentRCS.PCC_Total_Number_of_Line_Items__c = lstCSVLines.size()-1;
                if(isPartner){
                    parentRCS.PCC_Partner__c = partnerInfo;
                }
                else{
                    parentRCS.PCC_Partner__c = contactList[0].AccountId;
                    parentRCS.PCC_Partner_Contact__c = contactList[0].Id;
                }
                Database.insert(parentRCS);
                
                // Attach CSV to the header stage record
                attachCSVToHeaderStageRec(data,parentRCS.id,templateName);
                PCC_Rebate_Claim_Stage__c rcs;
                // Create child records
                for (Integer i = 1; i < lstCSVLines.size(); i++) {
                    rcs = new PCC_Rebate_Claim_Stage__c();
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
                    Integer fieldLength = 255; // Example field length, adjust as necessary
                    
                    for (Integer j = 0; j < headers.size(); j++) {
                        
                        if (headerMap.containsKey(j) && j < csvRowData.size()) {
                            if(((headerMap.get(j) != 'PCC_Quantity__c') && (headerMap.get(j) != 'PCC_Country__c')) && (csvRowData[j].length() > fieldLength)) {
                                errorCount ++;
                                rcs.PCC_Status__c = 'FAILED';
                                rcs.PCC_Error_Messages__c = rcs.PCC_Error_Messages__c == null ? 'ERROR '+errorCount+': '+PCC_Constants.DEAL_MAX_LENGTH+' '+headers[j]+';'+PCC_Constants.RC_LINE_SEPERATOR : rcs.PCC_Error_Messages__c + 'ERROR '+errorCount+': '+PCC_Constants.DEAL_MAX_LENGTH+' '+headers[j]+';'+PCC_Constants.RC_LINE_SEPERATOR; 
                                csvRowData[j]=csvRowData[j].substring(0,fieldLength);
                            }
                            if((headerMap.get(j) == 'PCC_Quantity__c') && (csvRowData[j].length() > 8) ){
                                System.debug('Inside quantity max loop-->');
                                errorCount ++;
                                rcs.PCC_Status__c = PCC_Constants.FAILED_STATUS;
                                rcs.PCC_Error_Messages__c = rcs.PCC_Error_Messages__c == null ? 'ERROR '+errorCount+': '+PCC_Constants.DEAL_MAX_LENGTH+' '+headers[j]+';'+PCC_Constants.RC_LINE_SEPERATOR : rcs.PCC_Error_Messages__c + 'ERROR '+errorCount+': '+PCC_Constants.DEAL_MAX_LENGTH+' '+headers[j]+';'+PCC_Constants.RC_LINE_SEPERATOR; 
                                csvRowData[j]=csvRowData[j].substring(0,8);
                                System.debug('Inside quantity max loop with error-->'+ rcs.PCC_Error_Messages__c);
                            }
                            if((headerMap.get(j) == 'PCC_Country__c') && (csvRowData[j].length() > 5000) ){
                                System.debug('Inside quantity max loop-->');
                                errorCount ++;
                                rcs.PCC_Status__c = PCC_Constants.FAILED_STATUS;
                                rcs.PCC_Error_Messages__c = rcs.PCC_Error_Messages__c == null ? 'ERROR '+errorCount+': '+PCC_Constants.DEAL_MAX_LENGTH+' '+headers[j]+';'+PCC_Constants.RC_LINE_SEPERATOR : rcs.PCC_Error_Messages__c + 'ERROR '+errorCount+': '+PCC_Constants.DEAL_MAX_LENGTH+' '+headers[j]+';'+PCC_Constants.RC_LINE_SEPERATOR; 
                                csvRowData[j]=csvRowData[j].substring(0,5000);
                                System.debug('Inside quantity max loop with error-->'+ rcs.PCC_Error_Messages__c);
                                
                            }
                            rcs.put(headerMap.get(j), csvRowData[j]);
                        }
                        
                    }
                    rcs.RecordTypeId = recTypeChildId;
                    rcs.PCC_Parent_Record__c=parentRCS.Id;
                    if(isPartner){
                        rcs.PCC_Partner__c = partnerInfo;
                    }
                    else{
                        rcs.PCC_Partner__c = contactList[0].AccountId;
                    }
                    system.debug('Status controller>>'+rcs.PCC_Status__c);
                    lstRCSToInsert.add(rcs);
                }
                
                if (lstRCSToInsert != null) {
                    Database.insert(lstRCSToInsert);
                }
                List<Id> parentId = new List<Id>();
                parentId.add(parentRCS.Id);
                // Call the batch class to process the records
                Database.executeBatch(new PCC_RebateStagingProcessBatch(parentId),200);
                rw.status = 'success';
                rw.message = [Select ID,Name from PCC_Rebate_Claim_Stage__c where Id=:parentRCS.Id LIMIT 1].Name +'#'+parentRCS.Id;
            }
            return rw;
        } 
        
        
        catch (Exception ex) {
            // Handle the exception and log the error
            insert new Core_Log_Entry__c(Core_Message__c = ex.getMessage(),Core_Details__c = ex.getMessage() + '\n'+ ex.getStackTraceString(),Core_Origin__c='PCC_RebateClaimController.createStageRecordsfromCSV', Core_Severity__c='high', Core_When__c=System.Now(), Core_Project__c = 'PCC_Rebate Claim');
            ResultWrapper rw = new ResultWrapper();
            
            rw.status = 'failed';
            rw.message = 'An error occurred while creating stage records from CSV';
            
            return rw;
        }
    }
    /**************************************************************************************************************************************
* ResultWrapper Class
*
* The RebateClaimWrapper class represents a wrapper object for a rebate claim.
* It encapsulates the data related to a rebate claim and provides convenient methods for accessing and manipulating the data.
*********************************************************************************************************************************************/ 
    public class ResultWrapper {
        @AuraEnabled
        public String message { get; set; }
        @AuraEnabled
        public String status { get; set; }
    }
    
    
    /***************************************************************************
Method Name: attachCSVToHeaderStageRec
Description: This method is used to attach the CSV to the header stage record.
*****************************************************************************/    
    public static void attachCSVToHeaderStageRec(String fileContent , Id ParentId,String templateName){
        
        try{
            Blob contentBlob =Blob.valueOf(fileContent);
            Blob bomBlob = Blob.valueOf('\uFEFF');
            String base64Blob1 = EncodingUtil.base64Encode(bomBlob);
            String base64Blob2 = EncodingUtil.base64Encode(contentBlob);
            
            // Concatenate Base64 strings
            String concatenatedBase64 = base64Blob1 + base64Blob2;
            
            // Convert the concatenated Base64 string back to Blob
            Blob concatenatedBlob = EncodingUtil.base64Decode(concatenatedBase64);
            
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.VersionData= concatenatedBlob;
            contentVersion.Title= templateName.substringBefore('.');
            contentVersion.PathOnClient=templateName;
            insert contentVersion;
            
            Id contentDoc = [Select ContentDocumentId from ContentVersion where id=:ContentVersion.id Limit 1].ContentDocumentId;
            
            ContentDocumentLink contentDocLink = new ContentDocumentLink();
            contentDocLink.ContentDocumentId=contentDoc;
            contentDocLink.LinkedEntityId=ParentId;
            contentDocLink.Visibility='AllUsers';
            contentDocLink.ShareType='V';
            insert contentDocLink;
        }
        catch(Exception ex){
            insert new Core_Log_Entry__c(Core_Message__c = ex.getMessage(),Core_Details__c = ex.getMessage() + '\n'+ ex.getStackTraceString(),Core_Origin__c='PCC_RebateClaimController.attachCSVToHeaderStageRec', Core_Severity__c='high', Core_When__c=System.Now(), Core_Project__c = 'PCC_Rebate Claim');
            
        }
    }
    
    /**************************************************************************************************************************************
* RebateClaimWrapper Class
*
* The RebateClaimWrapper class represents a wrapper object for a rebate claim.
* It encapsulates the data related to a rebate claim and provides convenient methods for accessing and manipulating the data.
*********************************************************************************************************************************************/ 
    public class RebateClaimWrapper {
        @AuraEnabled
        public List<PCC_Rebate_Claim_Stage__c> rebateClaimList { get; set; }
        @AuraEnabled
        public Map<String,List<String>> fieldMap { get; set; }
        @AuraEnabled
        public String fileName { get; set; }
    }
    
    /****************************************************************
Method Name: getQuoteQuantity
Description: This method is used to get the quote quantity.
*****************************************************************/
    @AuraEnabled
    public static List<QuantityResult> getQuoteQuantity(List<String> qlNum) {
        List<QuantityResult> qlList = new List<QuantityResult>();
        try{
            List<SBQQ__QuoteLine__c> qlLinesList = [SELECT Id,Pricing_Approved_Unit_Dup_Qty__c, Pricing_Quote_Line_Number__c  FROM SBQQ__QuoteLine__c WHERE
                                                    Pricing_Status_Nm__c IN ('Won') 
                                                    AND SBQQ__Quote__r.SBQQ__Opportunity2__r.StageName ='Design Win' 
                                                    AND SBQQ__Quote__r.SBQQ__Opportunity2__r.Core_Opportunity_Coverage_Nm__c='Partner-Led Opportunity' 
                                                    AND SBQQ__Quote__r.SBQQ__Opportunity2__r.Core_Coverage_Type_Nm__c='Deal Registration' 
                                                    AND Pricing_Quote_Line_Number__c IN:qlNum];
            List<PCC_Rebate_Claim_Line_Item__c> rebateCLIs = new List<PCC_Rebate_Claim_Line_Item__c>();
            Map<Id, Integer> existingCountMap = new Map<Id, Integer>();
            
            
            if(qlLinesList.size()>0){
                rebateCLIs = [SELECT Id, PCC_Quote_Line_Number__c,PCC_Quantity__c,PCC_Status__c FROM  PCC_Rebate_Claim_Line_Item__c WHERE PCC_Quote_Line_Number__c IN :qlLinesList and PCC_Status__c  IN ('Approved','Submitted')];
                for (PCC_Rebate_Claim_Line_Item__c rcli : rebateCLIs) {
                    if (existingCountMap.containsKey(rcli.PCC_Quote_Line_Number__c)) {
                        existingCountMap.put(rcli.PCC_Quote_Line_Number__c, existingCountMap.get(rcli.PCC_Quote_Line_Number__c) + Integer.valueOf(rcli.PCC_Quantity__c));
                    } 
                    else {
                        existingCountMap.put(rcli.PCC_Quote_Line_Number__c, Integer.valueOf(rcli.PCC_Quantity__c));
                    }
                }
                
                
                
                Integer maxQuantity,existingQLQuantity,remainingQuantity;
                for (SBQQ__QuoteLine__c ql : qlLinesList) {
                    QuantityResult qr = new QuantityResult();
                    maxQuantity = ql.get('Pricing_Approved_Unit_Dup_Qty__c')==null?0:Integer.valueOf(ql.get('Pricing_Approved_Unit_Dup_Qty__c'));
                    existingQLQuantity = existingCountMap.containsKey(ql.Id) ? existingCountMap.get(ql.Id) : 0;
                    remainingQuantity = maxQuantity - existingQLQuantity;
                    qr.QuoteLine=ql.Pricing_Quote_Line_Number__c;
                    qr.ApprovedQuantity = maxQuantity;
                    qr.RemainingQuantity = remainingQuantity;
                    qr.ClaimedQuantity=existingQLQuantity;
                    qlList.add(qr);
                }
            }
        }catch(Exception ex){
            insert new Core_Log_Entry__c(Core_Message__c = ex.getMessage(),Core_Details__c = ex.getMessage() + '\n'+ ex.getStackTraceString(),Core_Origin__c='PCC_RebateClaimController.getQuoteQuantity', Core_Severity__c='high', Core_When__c=System.Now(), Core_Project__c = 'PCC_Rebate Claim');
        }  
        return qlList;
    }
    
    /**************************************************************************************************************************************
* QuantityResult Class
* The QuantityResult class represents a wrapper object for a quantity result.
* It encapsulates the data related to a quantity result.
* *************************************************************************************************************************************/
    public class QuantityResult {
        @AuraEnabled
        public String QuoteLine {get;set;}
        @AuraEnabled 
        public  Integer RemainingQuantity { get; set; }
        @AuraEnabled
        public  Integer ClaimedQuantity { get; set; }
        @AuraEnabled
        public Integer ApprovedQuantity { get; set; }
        
    }
    
    
    /****************************************************************
Method Name: getQLswithoutRebate
Description: This method is used to get the QuoteLines without rebate.
*****************************************************************/
    public static List<QLsResult> getQLswithoutRebate() {
        List<QLsResult> QLsResultList = new List<QLsResult>();
        try {
            List<Period> qtrList = [SELECT StartDate,EndDate FROM Period WHERE FiscalYearSettings.YearType = 'Custom' and Type = 'Quarter' and  StartDate <=today order by StartDate desc LIMIT 2];
            
            List<SBQQ__QuoteLine__c> quoteLinesList = [SELECT Id, Pricing_Quote_Line_Number__c,Pricing_Approved_Start_Date_Dup_Dt__c,Pricing_Approved_End_Date_Dup_Dt__c, Pricing_Approved_Unit_Dup_Qty__c 
                                                       FROM SBQQ__QuoteLine__c 
                                                       WHERE Pricing_Status_Nm__c IN ('Won') 
                                                       AND SBQQ__Quote__r.SBQQ__Opportunity2__r.StageName ='Design Win' 
                                                       AND SBQQ__Quote__r.SBQQ__Opportunity2__r.Core_Opportunity_Coverage_Nm__c='Partner-Led Opportunity' 
                                                       AND SBQQ__Quote__r.SBQQ__Opportunity2__r.Core_Coverage_Type_Nm__c='Deal Registration'
                                                       AND Pricing_Approved_End_Date_Dup_Dt__c>=:qtrList[1].StartDate];
            List<PCC_Rebate_Claim_Line_Item__c> rcliList =[Select PCC_Quote_Line_Number__c,PCC_Quantity__c from PCC_Rebate_Claim_Line_Item__c where PCC_Status__c IN ('Approved','Submitted')];   
            
            Map<Id,Integer> existingCountMap = checkExistingQLWithoutRebate(rcliList);
            
            Integer maxQuantity,existingQLQuantity,remainingQuantity;
            QLsResult qlr = new QLsResult();
            
            for (SBQQ__QuoteLine__c ql : quoteLinesList) {
                maxQuantity = ql.get('Pricing_Approved_Unit_Dup_Qty__c')==null?0:Integer.valueOf(ql.get('Pricing_Approved_Unit_Dup_Qty__c'));
                existingQLQuantity = existingCountMap.containsKey(ql.Id) ? existingCountMap.get(ql.Id) : 0;
                remainingQuantity = maxQuantity - existingQLQuantity;
                if(remainingQuantity>0){
                    
                    qlr = new QLsResult();
                    qlr.QuoteLine = ql.Pricing_Quote_Line_Number__c;
                    qlr.ApprovedQuantity = Integer.valueOf(ql.Pricing_Approved_Unit_Dup_Qty__c);
                    qlr.ClaimedQuantity = existingQLQuantity;
                    qlr.RemainingQuantity = remainingQuantity;
                    
                    Date prevqtr = qtrList[1].EndDate.addDays(30);
                    if(qtrList[1].StartDate <=ql.Pricing_Approved_End_Date_Dup_Dt__c && qtrList[1].EndDate>=ql.Pricing_Approved_End_Date_Dup_Dt__c && Date.today()<=prevqtr) {
                        qlr.dueDate = prevqtr;
                        QLsResultList.add(qlr);
                    }
                    if(ql.Pricing_Approved_End_Date_Dup_Dt__c <=qtrList[0].EndDate && ql.Pricing_Approved_End_Date_Dup_Dt__c>=qtrList[0].StartDate) {
                        qlr.dueDate = qtrList[0].EndDate.addDays(30);
                        QLsResultList.add(qlr);
                    }
                    
                }
            }
            
        } catch(Exception ex) {
            insert new Core_Log_Entry__c(Core_Message__c = ex.getMessage(),Core_Details__c = ex.getMessage() + '\n'+ ex.getStackTraceString(), Core_Origin__c='PCC_RebateClaimController.getQLswithoutRebate', Core_Severity__c='low', Core_When__c=System.Now(), Core_Project__c = 'PCC_RebateClaim');
            
        }
        return QLsResultList;
    }
    
    /****************************************************************
* Method Name: getConfigShowMarquee
* Description: This method is used to get the configuration for the marquee.
* *****************************************************************/
    @AuraEnabled
    public static QLWrapper getConfigShowMarquee() {
        QLWrapper qlw ;
        try {
            
            String configMarquee = LabelConfiguration__mdt.getInstance('PCC_Config_Marquee')?.Value__c;
            /*FM:1,4,7,10;LM:3,6,9,12;FMT:7;LMT:7  FM Reperesents First Month and LM Represents Last Month and FMT and LMT represents threshold in the month when it will start appearing
Example : jan is the current month and metadata has 1 so it will come in jan and theshold is FMT is 7 so it will come in (Last Date of Quarter -7 day of the month)
Example : april is thr current month and metadata has 4 so it will come in april and theshold is LMT is 7 so it will come in (Last Date of Quarter + 30 - 7 day of the month)
Example : if u want not to be visible in the month then remove the month from FM and LM and set FM and LM to 0
*/
            Integer fmt = 0,lmt=0;
            List<string> fmList = new List<string>();
            List<string> lmList = new List<string>();
            if(configMarquee.split(';')[0].split(':')[0]=='FM') {                
                fmList = configMarquee.split(';')[0].split(':')[1].split(',');
            }
            if(configMarquee.split(';')[1].split(':')[0]=='LM') {                
                lmList = configMarquee.split(';')[1].split(':')[1].split(',');
            }
            if(configMarquee.split(';')[2].split(':')[0]=='FMT') {                
                fmt = Integer.valueOf(configMarquee.split(';')[2].split(':')[1]);
            }
            if(configMarquee.split(';')[3].split(':')[0]=='LMT'){                
                lmt = Integer.valueOf(configMarquee.split(';')[3].split(':')[1]);
            }
            qlw = showMarqueeConfig(fmList,lmList,fmt ,lmt);
            
            
        } catch (Exception ex) {
            insert new Core_Log_Entry__c(Core_Message__c = ex.getMessage(),Core_Details__c = ex.getMessage() + '\n'+ ex.getStackTraceString(), Core_Origin__c='PCC_RebateClaimController.getConfigShowMarquee', Core_Severity__c='low', Core_When__c=System.Now(), Core_Project__c = 'PCC_RebateClaim');
            
        }
        return qlw;
    }
    /**************************************************************************************************************************************
* QLWrapper Class
* The QLWrapper class represents a wrapper object for a quantity result.
* It encapsulates the data related to a Qls and Marquee.
* *************************************************************************************************************************************/
    public class QLWrapper {
        @AuraEnabled
        public List<QLsResult> qlList {get;set;}
        @AuraEnabled 
        public  Boolean showMarquee { get; set; } 
    }
    /**************************************************************************************************************************************
* QLsResult Class
* The QLsResult class represents a wrapper object for a Qls result.
* It encapsulates the Qls
* *************************************************************************************************************************************/
    public class QLsResult {
        @AuraEnabled
        public String QuoteLine {get;set;}
        @AuraEnabled 
        public  Integer RemainingQuantity { get; set; }
        @AuraEnabled
        public  Integer ClaimedQuantity { get; set; }
        @AuraEnabled
        public Integer ApprovedQuantity { get; set; }
        @AuraEnabled
        public Date dueDate { get; set; }
    }
    
    @AuraEnabled(cacheable=true)
    public static QWrapper getQuoteLineItems() {
        List<Period> qtrList = [SELECT StartDate,EndDate FROM Period WHERE FiscalYearSettings.YearType = 'Custom' and Type = 'Quarter' and  StartDate <=today order by StartDate desc LIMIT 2];
        List<SBQQ__QuoteLine__c> qlLinesList = [SELECT Id, Name, Pricing_Product_Nm__c,Pricing_OEM_Name_FI__c,Pricing_Product_Nm__r.Name,SBQQ__Quote__c,SBQQ__Quote__r.Name, Pricing_Approved_Unit_Dup_Qty__c, Pricing_Quote_Line_Number__c, Pricing_Approved_Start_Date_Dup_Dt__c,Pricing_Approved_End_Date_Dup_Dt__c  FROM SBQQ__QuoteLine__c WHERE Pricing_Status_Nm__c IN ('Won') AND SBQQ__Quote__r.SBQQ__Opportunity2__r.StageName ='Design Win' AND SBQQ__Quote__r.SBQQ__Opportunity2__r.Core_Opportunity_Coverage_Nm__c='Partner-Led Opportunity' AND SBQQ__Quote__r.SBQQ__Opportunity2__r.Core_Coverage_Type_Nm__c='Deal Registration' AND Pricing_Approved_End_Date_Dup_Dt__c>=:qtrList[1].StartDate order by Pricing_Approved_End_Date_Dup_Dt__c];
        Map<Id, Integer> remainingQuantityMap = new Map<Id, Integer>();
        Map<Id, Integer> claimedQuantityMap = new Map<Id, Integer>();
        List<SBQQ__QuoteLine__c> qlLinesNewList = new List<SBQQ__QuoteLine__c>();
        
        Map<Id, Integer> existingCountMap = checkExistingQuoteLine(qlLinesList);
        try{
            Integer maxQuantity,existingQLQuantity,remainingQuantity;
            for (SBQQ__QuoteLine__c ql : qlLinesList) {
                maxQuantity = ql.get('Pricing_Approved_Unit_Dup_Qty__c')== null ? 0 : Integer.valueOf(ql.get('Pricing_Approved_Unit_Dup_Qty__c'));
                existingQLQuantity = existingCountMap.containsKey(ql.Id) ? existingCountMap.get(ql.Id) : 0;
                remainingQuantity = maxQuantity - existingQLQuantity;
                remainingQuantityMap.put(ql.Id, remainingQuantity);
                claimedQuantityMap.put(ql.Id,existingQLQuantity);
                Date prevqtr = qtrList[1].EndDate.addDays(30);
                if(remainingQuantity>0 && qtrList[1].StartDate <=ql.Pricing_Approved_End_Date_Dup_Dt__c && qtrList[1].EndDate>=ql.Pricing_Approved_End_Date_Dup_Dt__c && Date.today()<=prevqtr){
                    qlLinesNewList.add(ql);
                }
                if(remainingQuantity>0 && ql.Pricing_Approved_End_Date_Dup_Dt__c>=qtrList[0].StartDate){
                    qlLinesNewList.add(ql);
                }
            }
            
        }catch(Exception ex){
            insert new Core_Log_Entry__c(Core_Message__c = ex.getMessage(),Core_Details__c = ex.getMessage() + '\n'+ ex.getStackTraceString(), Core_Origin__c='PCC_RebateClaimController.getQuoteLineItems', Core_Severity__c='low', Core_When__c=System.Now(), Core_Project__c = 'PCC_RebateClaim');
            
        }
        QWrapper ql = new QWrapper();
        ql.qlList = qlLinesList;
        ql.remainingQuantity = remainingQuantityMap;
        ql.claimedQuantity=claimedQuantityMap;
        return ql;
    }
    
    public class QWrapper {
        @AuraEnabled
        public List<SBQQ__QuoteLine__c> qlList { get; set; }
        @AuraEnabled
        public  Map<Id, Integer> remainingQuantity { get; set; }
        @AuraEnabled
        public  Map<Id, Integer> claimedQuantity { get; set; }
    }
    /****************************************************************
* Method Name: getConfigShowMarquee
* Description: This method is used to get the configuration for the marquee.
* *****************************************************************/
    @AuraEnabled(cacheable=true)
    public static Boolean isQLonRCVisible() {        
        Boolean isQLSectionVisible = false;
        try {
            String isQLSectionVisibleStr = LabelConfiguration__mdt.getInstance('PCC_RC_Show_QL')?.Value__c;
            if(isQLSectionVisibleStr=='true'){
                isQLSectionVisible = true;
            }
            
        }
        catch(Exception ex){
            insert new Core_Log_Entry__c(Core_Message__c = ex.getMessage(),Core_Details__c = ex.getMessage() + '\n'+ ex.getStackTraceString(), Core_Origin__c='PCC_RebateClaimController.isQLonRCVisible', Core_Severity__c='low', Core_When__c=System.Now(), Core_Project__c = 'PCC_RebateClaim');
            
        }
        return isQLSectionVisible;
    }
    public static QLWrapper showMarqueeConfig(List<string> fmList, List<string> lmList,Integer fmt ,Integer lmt){
        
        String showMarquee = LabelConfiguration__mdt.getInstance('PCC_Show_Marquee')?.Value__c;
        QLWrapper qlw = new QLWrapper();
        Date currentDate =  Date.today();
        try{
            List<Period> qtrList = [SELECT StartDate,EndDate FROM Period WHERE FiscalYearSettings.YearType = 'Custom' and Type = 'Quarter' and EndDate >=today and StartDate <=today LIMIT 1];
            Integer currentMonth = currentDate.month();
            Integer currentDay = currentDate.day();
            Integer lastDay = qtrList[0].EndDate.day();
            Boolean configShowMarquee=false;
            if(fmList.contains(String.valueOf(currentMonth)) && currentDay >= (lastDay-fmt)){
                configShowMarquee = true;
            }
            if(lmList.contains(String.valueOf(currentMonth)) && currentDay >= (lastDay-lmt)){
                configShowMarquee = true;
            }
            List<QLsResult> qls = new List<QLsResult>();
            if(showMarquee=='true' && configShowMarquee){
                qls = getQLswithoutRebate();
                if(qls.size()>0){
                    qlw.qlList = qls;
                    qlw.showMarquee = true;
                } 
            }else {
                qlw.qlList = qls;
                qlw.showMarquee = false;
            }
        }catch(Exception ex){
            insert new Core_Log_Entry__c(Core_Message__c = ex.getMessage(),Core_Details__c = ex.getMessage() + '\n'+ ex.getStackTraceString(), Core_Origin__c='PCC_RebateClaimController.showMarqueeConfig', Core_Severity__c='low', Core_When__c=System.Now(), Core_Project__c = 'PCC_RebateClaim');
            
        }
        return qlw;
    }
    
    public static Map<Id, Integer> checkExistingQuoteLine(List<SBQQ__QuoteLine__c> qlLinesList){
        
        Map<Id, Integer> existingCountMap = new Map<Id, Integer>();
        List<PCC_Rebate_Claim_Line_Item__c> rebateCLIs;
        try{
            if(qlLinesList != null){
                rebateCLIs = [SELECT Id, PCC_Quote_Line_Number__c,PCC_Quantity__c FROM  PCC_Rebate_Claim_Line_Item__c WHERE PCC_Quote_Line_Number__c IN :qlLinesList and  PCC_Status__c IN ('Approved','Submitted')];
            }
            
            if(rebateCLIs!=null){
                
                for (PCC_Rebate_Claim_Line_Item__c rcli : rebateCLIs) {
                    
                    if (existingCountMap.containsKey(rcli.PCC_Quote_Line_Number__c)) {
                        existingCountMap.put(rcli.PCC_Quote_Line_Number__c, existingCountMap.get(rcli.PCC_Quote_Line_Number__c) + Integer.valueOf(rcli.PCC_Quantity__c));
                    } 
                    else {
                        existingCountMap.put(rcli.PCC_Quote_Line_Number__c, Integer.valueOf(rcli.PCC_Quantity__c));
                    }
                }
            }
        }catch(Exception ex){
            insert new Core_Log_Entry__c(Core_Message__c = ex.getMessage(),Core_Details__c = ex.getMessage() + '\n'+ ex.getStackTraceString(), Core_Origin__c='PCC_RebateClaimController.checkExsistingQuoteLine', Core_Severity__c='low', Core_When__c=System.Now(), Core_Project__c = 'PCC_RebateClaim');
        } 
        return existingCountMap;
        
    }
    public static Map<Id,Integer> checkExistingQLWithoutRebate ( List<PCC_Rebate_Claim_Line_Item__c> rcliList ){
        
        Map<Id, Integer> existingCountMap = new Map<Id, Integer>(); 
        try{
            if(rcliList!=null){
                
                for (PCC_Rebate_Claim_Line_Item__c rcli : rcliList) {
                    
                    if (existingCountMap.containsKey(rcli.PCC_Quote_Line_Number__c)) {
                        existingCountMap.put(rcli.PCC_Quote_Line_Number__c, existingCountMap.get(rcli.PCC_Quote_Line_Number__c) + Integer.valueOf(rcli.PCC_Quantity__c));
                    } 
                    else {
                        existingCountMap.put(rcli.PCC_Quote_Line_Number__c, Integer.valueOf(rcli.PCC_Quantity__c));
                    }
                }
            }
        }catch(Exception ex){
            insert new Core_Log_Entry__c(Core_Message__c = ex.getMessage(),Core_Details__c = ex.getMessage() + '\n'+ ex.getStackTraceString(), Core_Origin__c='PCC_RebateClaimController.checkExistingQLWithoutRebate', Core_Severity__c='low', Core_When__c=System.Now(), Core_Project__c = 'PCC_RebateClaim');
            
        }
        return existingCountMap;
        
    }
    
}