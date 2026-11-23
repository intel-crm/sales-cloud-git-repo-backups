public class RebateStagingProcessBatch implements Database.Batchable<SObject>{

    private Map<Id, List<PCC_Rebate_Claim_Stage__c>> rebateClaimMap = new Map<Id, List<PCC_Rebate_Claim_Stage__c>>();
    List<PCC_Rebate_Claim_Stage__c> lineItemsToUpdate = new List<PCC_Rebate_Claim_Stage__c>();
    Set<Id> headersToUpdate = new Set<Id>(); 
    public RebateStagingProcessBatch() {

    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        String stageStatus = 'Pending';
        //2 checks for param
        List<Id> headerIds = new List<Id>{'aElDf000000CspBKAS','aElDf000000Csp8KAC','aElDf000000CspGKAS'};
        String query='SELECT Id,Name,CreatedDate,CreatedById,LastModifiedDate,SystemModstamp,ConnectionReceivedId,ConnectionSentId,LastModifiedById,LastViewedDate,LastReferencedDate,RecordTypeId,IsDeleted,PCC_Quote_Line_Number__c,PCC_Error_Message__c, PCC_Invoice_Date__c,PCC_Product__c,PCC_Quantity__c,PCC_Quote_Invoice_Number__c,PCC_Status__c, PCC_Parent_Record__c,OwnerId FROM PCC_Rebate_Claim_Stage__c WHERE (PCC_Parent_Record__r.PCC_Status__c = :stageStatus AND PCC_Parent_Record__c IN :headerIds)';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext context, List<PCC_Rebate_Claim_Stage__c > scope) {
        system.debug('scope---'+scope.size());
        // Map<Id, Map<String, Object>> recordFieldValuesMap = new Map<Id, Map<String, Object>>();
        // Map<String, Object> fieldValuesMap = new Map<String, Object>();

        // for(PCC_Rebate_Claim_Stage__c rebateStageRec:scope){
        //     if(!rebateClaimMap.containsKey(rebateStageRec.PCC_Parent_Record__c)){
        //         rebateClaimMap.put(rebateStageRec.PCC_Parent_Record__c,new List<PCC_Rebate_Claim_Stage__c>());
        //     } 
        // }
        if(!scope.isEmpty()){
            populateRebateClaimMap(scope);
            validateDataType(scope);
            updateLineItemRecords();
        }
    }
    
    public void finish(Database.BatchableContext context) {
        system.debug('Inside Finish method');
        //updateHeaderRecords(rebateClaimMap);
    }

    public void populateRebateClaimMap(List<PCC_Rebate_Claim_Stage__c> scope) {
        if(!scope.isEmpty()){
            for (PCC_Rebate_Claim_Stage__c rebateStageRec : scope) {
            
                system.debug('rebateStageRec---'+rebateStageRec.PCC_Parent_Record__c);
                Id headerId = rebateStageRec.PCC_Parent_Record__c;
                if (!rebateClaimMap.containsKey(headerId)) {
                    rebateClaimMap.put(headerId, new List<PCC_Rebate_Claim_Stage__c>());
                    system.debug('rebateClaimMap 1---'+rebateClaimMap.get(headerId));
                }
                rebateClaimMap.get(headerId).add(rebateStageRec);
            }
        }
    }

    public void validateDataType(List<PCC_Rebate_Claim_Stage__c> lineItems) {
        try{
            system.debug('Inside validate function');
            //system.debug('fieldName for date---'+fieldName+' '+fieldValue);
            List<PCC_Rebate_Claim_Stage__c> stgRecErrorList = new List<PCC_Rebate_Claim_Stage__c>();
            //List<PCC_Rebate_Claim_Stage__c> stgRecSuccessList = new List<PCC_Rebate_Claim_Stage__c>();
            Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.PCC_Rebate_Claim_Stage__c.fields.getMap();
            
            for (PCC_Rebate_Claim_Stage__c stgRec : lineItems) {
                Boolean hasErrors = false;
                system.debug('stgRec at 87--'+stgRec);
                if (fieldMap.containsKey('PCC_Invoice_Date__c') && stgRec.PCC_Invoice_Date__c != null && !checkIsUSDatePattern(String.valueOf(stgRec.PCC_Invoice_Date__c))) {
                    hasErrors = true;
                }
                if(fieldMap.containsKey('PCC_Quantity__c') && !IsNumeric(String.valueOf(stgRec.PCC_Quantity__c))){
                    hasErrors=true;
                }
                if (hasErrors) {
                    stgRecErrorList.add(stgRec);
                    system.debug('stgRecErrorList-------'+stgRec);
                // handleInvalidDataType(stgRecErrorList);
                    
                }else {
                    stgRec.PCC_Status__c = 'Success';
                    stgRec.PCC_Error_Message__c = 'Success';
                    system.debug('lineItemsToUpdate stgRec----------'+stgRec);
                    //headersToUpdate.add(stgRec.PCC_Parent_Record__c);  
                    //stgRecSuccessList.add(stgRec);
                    lineItemsToUpdate.add(stgRec);
                }  
                system.debug('lineItemsToUpdate----------'+lineItemsToUpdate);
            // headersToUpdate.add(stgRec.PCC_Parent_Record__c);
            }
            
            if (!stgRecErrorList.isEmpty()) {
                system.debug('stgRecErrorList 2-------'+stgRecErrorList.size());
                handleInvalidDataType(stgRecErrorList);
            }
        }catch(Exception e){
            system.debug('Exception---'+e.getMessage());
        }
    }
       
    public void handleInvalidDataType(List<PCC_Rebate_Claim_Stage__c> errorList) {
        system.debug('errorList----------'+errorList.size());
        for (Integer i = 0; i < errorList.size(); i++) {
            PCC_Rebate_Claim_Stage__c record = errorList[i];
            system.debug('record----------'+record);
            record.PCC_Status__c = 'Failed';
            record.PCC_Error_Message__c = 'Invalid Data ';
            if(!lineItemsToUpdate.contains(record)) {
                lineItemsToUpdate.add(record);
            }
           // headersToUpdate.add(record.PCC_Parent_Record__c);
        }
        system.debug('lineItemsToUpdate in handleInvalidDataType---'+lineItemsToUpdate);
    }

    public void updateLineItemRecords() {
        try{
            system.debug('UPDATE-------'+lineItemsToUpdate);
            if(!lineItemsToUpdate.isEmpty()) {
                update lineItemsToUpdate;// allOrNone should be applied, check with Vivek for the proper requirement
            }
        }catch(Exception e){

        } 
    }

    public void updateHeaderRecords(Map<Id,List<PCC_Rebate_Claim_Stage__c>> rebateClaimMap) {
        system.debug('Inside finish method');
        
        List<PCC_Rebate_Claim_Stage__c> headersToUpdateList = new List<PCC_Rebate_Claim_Stage__c>();
        for(Id headerId : rebateClaimMap.keySet()) {
            system.debug('headerId--'+headerId);
            List<PCC_Rebate_Claim_Stage__c> lineItemRecords = rebateClaimMap.get(headerId);
            Boolean headerFailed = false;
            for(PCC_Rebate_Claim_Stage__c liRecord : lineItemRecords) {
                system.debug('liRecord----'+liRecord);
                if(liRecord.PCC_Status__c == 'Failed') {
                    headerFailed = true;
                    break;
                }
            }
            PCC_Rebate_Claim_Stage__c headerRecord = new PCC_Rebate_Claim_Stage__c(Id = headerId);
            headerRecord.PCC_Status__c = headerFailed ? 'Failed' : 'Success';
            headersToUpdateList.add(headerRecord);
            system.debug('headersToUpdateList 1----'+headersToUpdateList);
        }
        if(!headersToUpdateList.isEmpty()) {
            system.debug('headersToUpdateList 2----'+headersToUpdateList);
            update headersToUpdateList;
        }
        
    }
    public Boolean checkIsUSDatePattern(String DateValue)
    {
        String dateRegEx = '(0?[1-9]|1[012])/(0?[1-9]|[12][0-9]|3[01])/((19|20)\\d\\d)';
        
        try
        {
            Pattern myPattern = Pattern.compile(dateRegEx);
            Matcher myMatcher = myPattern.matcher(DateValue);
            if(myMatcher.matches())
            {
                return TRUE;   
            }
            else
            {
                return FALSE;   
            }  
            
        }
        catch(Exception e)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            system.debug('Please provide the date(s) with the format \'MM/DD/YYYY\':'+myMsg);    
            
            return null;
        } 
    }

    //To check the values in number fields are numeric
    public static Boolean isNumeric(String s)
    {
        Boolean ReturnValue;
        try
        {
            Decimal.valueOf(s);
            ReturnValue = TRUE; 
        } catch (Exception e) 
        {
            ReturnValue = FALSE;
        }
        return ReturnValue;
    }
}