/****************************************************************************************************
Apex Class Name : PCC_RebateStagingProcessBatch
Version         : 1.0 
Created Date    : 03/Jun/2024
Function        : This class is used to process Rebate Claim Staging records
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sandhya D                    03/Jun/2024               Created
*****************************************************************************************************/
public with sharing class PCC_RebateStagingProcessBatch implements Database.Batchable<SObject>,Database.Stateful{
    
    Map<Id, List<PCC_Rebate_Claim_Stage__c>> rebateClaimMap = new Map<Id, List<PCC_Rebate_Claim_Stage__c>>();
    
    List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();
    public List<Id> headerIdList;
    
    public PCC_RebateStagingProcessBatch(List<Id> headerIds) {
        this.headerIdList = headerIds;
    }
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        String query = PCC_RebateClaimHandler.rebateClaimStgQuery(headerIdList);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext context, List<PCC_Rebate_Claim_Stage__c > scope) {
        List<PCC_Rebate_Claim_Stage__c> validateDataTypeList = new List<PCC_Rebate_Claim_Stage__c>();
        List<PCC_Rebate_Claim_Stage__c> validateListToUpdate = new List<PCC_Rebate_Claim_Stage__c>();
        
        Long startTime = System.currentTimeMillis();
        Long startHeap = Limits.getHeapSize();
        System.debug('Start time in execute: ' + startTime);
        System.debug('Heap Size at start of execute: ' + startHeap);
        populateRebateClaimMap(scope);
        system.debug('Before scope size=='+scope.size());
        validateDataTypeList = validateDataType(scope);
        System.debug('validateDataTypeList----'+validateDataTypeList);
        system.debug('After scope size=='+scope.size());
        system.debug('Before lineItemsToUpdate size=='+validateDataTypeList.size());
        if(!validateDataTypeList.isEmpty()){ 
            validateListToUpdate = PCC_RebateClaimHandler.validateLineItems(validateDataTypeList);
        }
        updateLineItemRecords(validateListToUpdate);
        Long endHeap = Limits.getHeapSize();
        System.debug('Heap Size at end of execute: ' + endHeap);
        
        Long heapUsed = endHeap - startHeap;
        System.debug('Heap Size Used in MB in  execute: ' + heapUsed);
        Long endTime = System.currentTimeMillis();
        Long executionTime = endTime - startTime;
        System.debug('Execution Time in seconds in execute: ' + executionTime);
        
    }
    
    public void finish(Database.BatchableContext context) {
        Long startTime = System.currentTimeMillis();
        System.debug('Start time in finish: ' + startTime);
        Long startHeap = Limits.getHeapSize();
        System.debug('Heap Size at start of finish: ' + startHeap);
        updateHeaderRecords();
        Long endHeap = Limits.getHeapSize();
        System.debug('Heap Size at end of finish: ' + endHeap);
        
        Long heapUsed = endHeap - startHeap;
        System.debug('Heap Size Used in MB in finish: ' + heapUsed);
        Long endTime = System.currentTimeMillis();
        Long executionTime = endTime - startTime;
        System.debug('Execution Time in seconds in finish: ' + executionTime);
    }
    
    public void populateRebateClaimMap(List<PCC_Rebate_Claim_Stage__c> scope) {
        for (PCC_Rebate_Claim_Stage__c rebateStageRec : scope) {
            Id headerId = rebateStageRec.PCC_Parent_Record__c;
            if (!rebateClaimMap.containsKey(headerId)) {
                rebateClaimMap.put(headerId, new List<PCC_Rebate_Claim_Stage__c>());
            }
            rebateClaimMap.get(headerId).add(rebateStageRec);
        }
    }
    
    public List<PCC_Rebate_Claim_Stage__c> validateDataType(List<PCC_Rebate_Claim_Stage__c> lineItems) {
        List<PCC_Rebate_Claim_Stage__c> lineItemsToUpdate = new List<PCC_Rebate_Claim_Stage__c>();
        try{
            
            Core_DDR_Stage_Validator validator = new Core_DDR_Stage_Validator();
            Boolean hasErrors;
            String errorMessage;
            Integer errorCount;
            for (PCC_Rebate_Claim_Stage__c stgRec : lineItems) {
                hasErrors = false;
                errorMessage='';
                errorCount =0;
                errorCount = stgRec.PCC_Error_Messages__c == null ? errorCount : stgRec.PCC_Error_Messages__c.split(PCC_Constants.RC_LINE_SEPERATOR).size();
                errorMessage =stgRec.PCC_Error_Messages__c== null ? '': stgRec.PCC_Error_Messages__c  + PCC_Constants.RC_LINE_SEPERATOR ;
                
                if (stgRec.PCC_Invoice_Date__c != null && !validator.checkIsUSDatePattern(String.valueOf(stgRec.PCC_Invoice_Date__c))) {
                    system.debug('invoice date->> '+stgRec.PCC_Invoice_Date__c);
                    errorCount++;
                    System.debug('error for invoice date->'+errorCount);
                    errorMessage +='ERROR '+errorCount+' : '+PCC_Constants.RC_INVDATE_INVALID+' ; '+ PCC_Constants.RC_LINE_SEPERATOR;
                    hasErrors = true;
                    stgRec.PCC_Status__c = PCC_Constants.FAILED_STATUS;
                } else if (String.isBlank(stgRec.PCC_Invoice_Date__c)) {
                    errorCount++;
                    errorMessage +='ERROR '+errorCount+' : '+PCC_Constants.RC_INVDATE_BLANK+' ; '+ PCC_Constants.RC_LINE_SEPERATOR;
                    hasErrors = true;
                    stgRec.PCC_Status__c = PCC_Constants.FAILED_STATUS;
                    System.debug('2nd error for invoice date->'+errorCount);
                }
                //if (stgRec.PCC_Quantity__c != null && !isNumeric(String.valueOf(stgRec.PCC_Quantity__c))) {
                if (stgRec.PCC_Quantity__c != null && !stgRec.PCC_Quantity__c.isNumeric()) {
                    errorCount++;
                    errorMessage +='ERROR '+errorCount+' : '+PCC_Constants.RC_Qty_INVALID+'; '+ PCC_Constants.RC_LINE_SEPERATOR;
                    hasErrors = true;
                    stgRec.PCC_Status__c = PCC_Constants.FAILED_STATUS;
                    System.debug('error for Quantity->'+errorCount);
                } else if (String.isBlank(stgRec.PCC_Quantity__c)) {
                    errorCount++;
                    errorMessage += 'ERROR '+errorCount+' : '+ PCC_Constants.RC_Qty_BLANK +'; '+PCC_Constants.RC_LINE_SEPERATOR;
                    hasErrors = true;
                    stgRec.PCC_Status__c = PCC_Constants.FAILED_STATUS;
                }
                if(String.isBlank(stgRec.PCC_Quote_Line_Number__c)){
                    errorCount++;
                    errorMessage += 'ERROR '+errorCount+' : '+PCC_Constants.RC_QLN_BLANK+'; '+PCC_Constants.RC_LINE_SEPERATOR;
                    hasErrors = true;
                    stgRec.PCC_Status__c = PCC_Constants.FAILED_STATUS;
                    System.debug('1ST error for QL ->'+errorCount);
                }else if(!stgRec.PCC_Quote_Line_Number__c.startsWith('Q-')){
                    errorCount++;
                    errorMessage += 'ERROR '+errorCount+' : '+PCC_Constants.RC_QLN_INVALID+'; '+PCC_Constants.RC_LINE_SEPERATOR;
                    hasErrors = true;
                    stgRec.PCC_Status__c = PCC_Constants.FAILED_STATUS;
                    System.debug('2ND error for QL->'+errorCount);
                }
                if(String.isBlank(stgRec.PCC_OEM__c)){
                    errorCount++;
                    errorMessage += 'ERROR '+errorCount+' : '+PCC_Constants.RC_OEM_BLANK+'; '+PCC_Constants.RC_LINE_SEPERATOR;
                    hasErrors = true;
                    stgRec.PCC_Status__c = PCC_Constants.FAILED_STATUS;
                }
                if(String.isBlank(stgRec.PCC_Country__c)){
                    errorCount++;
                    errorMessage += ' ERROR '+errorCount+' : '+PCC_Constants.RC_COUNTRY_BLANK+'; '+PCC_Constants.RC_LINE_SEPERATOR;
                    hasErrors = true;
                    stgRec.PCC_Status__c = PCC_Constants.FAILED_STATUS;
                }
                if(String.isBlank(stgRec.PCC_Quote_Invoice_Number__c)){
                    errorCount++;
                    errorMessage += 'ERROR '+errorCount+' : '+PCC_Constants.RC_QIN_BLANK+'; '+PCC_Constants.RC_LINE_SEPERATOR;
                    hasErrors = true;
                    stgRec.PCC_Status__c = PCC_Constants.FAILED_STATUS;
                }
                if(String.isBlank(stgRec.PCC_Product__c)){
                    errorCount++;
                    errorMessage += 'ERROR '+errorCount+' : '+PCC_Constants.RC_Prod_BLANK +'; '+PCC_Constants.RC_LINE_SEPERATOR;
                    hasErrors = true;
                    stgRec.PCC_Status__c = PCC_Constants.FAILED_STATUS;
                    System.debug('error for PROD->'+errorCount);
                }
                // if (!hasErrors) {
                //     stgRec.PCC_Status__c = PCC_Constants.SUCCESS_STATUS;   
                // }else {
                //     stgRec.PCC_Status__c = PCC_Constants.FAILED_STATUS;
                if (hasErrors) {
                    stgRec.PCC_Error_Messages__c = errorMessage;
                    system.debug('stgRecErrorList 147-------'+stgRec); 
                } 
                system.debug('stgRecErrorList 112-------'+lineItemsToUpdate);
                lineItemsToUpdate.add(stgRec);
            }
            
        }catch(Exception e){
            logEntries.add(new Core_Log_Entry__c(Core_Message__c = e.getMessage(),Core_Details__c ='Rebate Claim Stage record failed to Validate', Core_Origin__c='PCC_RebateStagingProcessBatch.validateDataType', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'Sales CRM'));    
        }finally{ insert logEntries;} 
        return lineItemsToUpdate; 
    }
    
    public void updateLineItemRecords(List<PCC_Rebate_Claim_Stage__c> liToUpdateList) {
        if (!liToUpdateList.isEmpty()) {
            system.debug('stgRecErrorList 160------'+liToUpdateList);
            for(PCC_Rebate_Claim_Stage__c li:liToUpdateList){
                if(li.PCC_Status__c=='Pending'){
                    li.PCC_Status__c='Failed';
                    li.PCC_Error_Messages__c=PCC_Constants.RC_TECHERROR;
                }
            }
            Database.SaveResult[] srList = Database.update(liToUpdateList,true);
            for(Database.SaveResult res : srList){
                if(!res.isSuccess()){
                    for(Database.Error err : res.getErrors()) {    
                        logEntries.add(new Core_Log_Entry__c(Core_Message__c = err.getMessage(),Core_Details__c ='Rebate Claim Stage record failed to Update Line Items', Core_Origin__c='PCC_RebateStagingProcessBatch.updateLineItemRecords', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'Sales CRM'));    
                    }
                }
            }
        }   
    }
    
    public void updateHeaderRecords() {
        List<PCC_Rebate_Claim_Stage__c> updateHeaderList = new List<PCC_Rebate_Claim_Stage__c>();
        Map<Id, List<PCC_Rebate_Claim_Stage__c>> stgSuccessRecordsMap = new Map<Id, List<PCC_Rebate_Claim_Stage__c>>();
        Map<Id, List<PCC_Rebate_Claim_Stage__c>> stgErrorRecordsMap = new Map<Id, List<PCC_Rebate_Claim_Stage__c>>();
        List<PCC_Rebate_Claim_Stage__c> successLineItemList; 
        List<PCC_Rebate_Claim_Stage__c> failedLineItemList; 
        
        for(Id headerId : rebateClaimMap.keySet()) {
            successLineItemList = new List<PCC_Rebate_Claim_Stage__c>(); 
            failedLineItemList = new List<PCC_Rebate_Claim_Stage__c>(); 
            PCC_Rebate_Claim_Stage__c headerRecordToUpdate = new PCC_Rebate_Claim_Stage__c(Id = headerId);
            for(PCC_Rebate_Claim_Stage__c liRec : rebateClaimMap.get(headerId)) {
                if(liRec.PCC_Status__c == PCC_Constants.FAILED_STATUS){
                    failedLineItemList.add(liRec);
                }else{
                    successLineItemList.add(liRec);
                }
            }       
            
            if(failedLineItemList.isEmpty()){
                headerRecordToUpdate.PCC_Status__c  = PCC_Constants.SUCCESS_STATUS;
                stgSuccessRecordsMap.put(headerId, successLineItemList);
            }else{
                headerRecordToUpdate.PCC_Status__c  = PCC_Constants.FAILED_STATUS;
                stgErrorRecordsMap.put(headerId, failedLineItemList);
            }
            updateHeaderList.add(headerRecordToUpdate);
        }
        updateHeaderAndInvokeCreateRC(updateHeaderList, stgSuccessRecordsMap);//code scan fix
        
    }
    public void updateHeaderAndInvokeCreateRC (List<PCC_Rebate_Claim_Stage__c> updateHeaderList, Map<Id, List<PCC_Rebate_Claim_Stage__c>> stgSuccessRecordsMap){
        
        if(!updateHeaderList.isEmpty()){
            try{
                Database.SaveResult[] srList = Database.update(updateHeaderList,false);
                for(Database.SaveResult res : srList){
                    if(!res.isSuccess()){
                        for(Database.Error err : res.getErrors()) {               
                            logEntries.add(new Core_Log_Entry__c(Core_Message__c = err.getMessage(),Core_Details__c ='Error while updating Header Records', Core_Origin__c='PCC_RebateStagingProcessBatch.updateHeaderAndInvokeCreateRC', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'Sales CRM'));     
                        }
                    }
                }  
            }catch(Exception e){
                logEntries.add(new Core_Log_Entry__c(Core_Message__c = e.getMessage(),Core_Details__c ='Error while updating Header Records', Core_Origin__c='PCC_RebateStagingProcessBatch.updateHeaderAndInvokeCreateRC', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'Sales CRM'));     
            }finally{insert logEntries;}
        }
        
        if (!stgSuccessRecordsMap.isEmpty()) {
            PCC_RebateClaimHandler.createRebateClaim(stgSuccessRecordsMap);
        }
    }
    
}