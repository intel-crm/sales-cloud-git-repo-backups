/****************************************************************************************************
Apex Class Name : PCC_UpdateSDPFlowController
Created Date    : 16/06/2026
Function        : Controller class for the apex action in flow 'PCC_Update_SDP_Price'
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------
* Varun                     16/06/2026             Created
*****************************************************************************************************/
public with sharing class PCC_UpdateSDPFlowController { 
    
    @InvocableMethod(label='Bulk Update DRP SDP Price')
    public static List<BulkUpdateResponse> bulkUpdateDRPRecords(List<BulkUpdateRequest> requests) {
        
        List<BulkUpdateResponse> responses = new List<BulkUpdateResponse>();
        
        // Use a Map instead of a List to automatically deduplicate records by ID
        Map<Id, Core_Design_Registration_Product__c> uniqueRecordsToUpdateMap = new Map<Id, Core_Design_Registration_Product__c>();
        
        // Track which records belong to which request position index
        Map<Integer, List<Core_Design_Registration_Product__c>> requestToRecordsMap = new Map<Integer, List<Core_Design_Registration_Product__c>>();
        
        // Step 1: Initialize responses and safely aggregate records across ALL bulk requests
        for(Integer i = 0; i < requests.size(); i++) {
            BulkUpdateRequest request = requests[i];
            
            BulkUpdateResponse response = new BulkUpdateResponse();
            response.successCount = 0;
            response.errorCount = 0;
            response.errorMessages = new List<String>();
            response.successIds = new List<String>();
            response.errorIds = new List<String>();
            responses.add(response);
            
            List<Core_Design_Registration_Product__c> validRecordsForThisRequest = new List<Core_Design_Registration_Product__c>();
            
            if(request.drpRecords != null) {
                for(Core_Design_Registration_Product__c drp : request.drpRecords) {
                    if(drp.Core_Design_Product_Status_Nm__c == 'Pending' && 
                       (drp.PCC_Standard_Distributor_Price__c == null || drp.PCC_Standard_Distributor_Price__c == 0)) {
                        
                        drp.PCC_Standard_Distributor_Price__c = request.standardDistiPrice;
                        validRecordsForThisRequest.add(drp);
                        
                        // Putting it in a Map ensures that if the same ID appears twice, it is only updated once
                        uniqueRecordsToUpdateMap.put(drp.Id, drp); 
                    }
                }
            }
            requestToRecordsMap.put(i, validRecordsForThisRequest);
        }
        
        // Step 2: Execute exactly ONE bulk DML statement using the unique list of values
if(!uniqueRecordsToUpdateMap.isEmpty()) {
    List<Core_Design_Registration_Product__c> deduplicatedList = uniqueRecordsToUpdateMap.values();
    
    //  Cleanse the list of all system, read-only, and hidden fields before updating
    SObjectAccessDecision decision = Security.stripInaccessible(AccessType.UPDATABLE, deduplicatedList);
    List<Core_Design_Registration_Product__c> cleansedList = (List<Core_Design_Registration_Product__c>) decision.getRecords();
    
    // Perform the database update on the cleansed list instead
    Database.SaveResult[] totalResults = Database.update(cleansedList, false);
    
    // Map individual database results back to their specific Record ID
    Map<Id, Database.SaveResult> resultByRecordId = new Map<Id, Database.SaveResult>();
    for(Integer j = 0; j < cleansedList.size(); j++) {
        resultByRecordId.put(cleansedList[j].Id, totalResults[j]);
    }
    
    // Step 3: Populate responses for each Flow context safely... (rest of your code remains identical)

             
            // Step 3: Populate responses for each Flow context safely
            for(Integer i = 0; i < requests.size(); i++) {
                BulkUpdateResponse response = responses[i];
                List<Core_Design_Registration_Product__c> processedRecords = requestToRecordsMap.get(i);
                
                for(Core_Design_Registration_Product__c record : processedRecords) {
                    Database.SaveResult sr = resultByRecordId.get(record.Id);
                    
                    if(sr != null && sr.isSuccess()) {
                        // Prevent counting duplicate successes twice in the same response package
                        if(!response.successIds.contains(record.Id)) {
                            response.successCount++;
                            response.successIds.add(record.Id);
                        }
                    } else if (sr != null) {
                        if(!response.errorIds.contains(record.Id)) {
                            response.errorCount++;
                            response.errorIds.add(record.Id);
                            
                            String errorMsg = 'Record ID: ' + record.Id + ' - ';
                            for(Database.Error error : sr.getErrors()) {
                                errorMsg += '[' + error.getStatusCode() + '] ' + error.getMessage();
                                if(!error.getFields().isEmpty()) {
                                    errorMsg += ' (Fields: ' + String.join(error.getFields(), ', ') + ')';
                                }
                                errorMsg += '; ';
                            }
                            response.errorMessages.add(errorMsg);
                            System.debug('Partial Commit Failure logged: ' + errorMsg);
                        }
                    }
                }
            }
        }
        
        return responses;
    }
    
    public class BulkUpdateRequest {
        @InvocableVariable(required=true label='DRP Records Collection')
        public List<Core_Design_Registration_Product__c> drpRecords;
        
        @InvocableVariable(required=true label='Standard Disti Price')
        public Decimal standardDistiPrice;
    }
    
    public class BulkUpdateResponse {
        @InvocableVariable
        public Integer successCount;
        
        @InvocableVariable
        public Integer errorCount;
        
        @InvocableVariable 
        public List<String> errorMessages;
        
        @InvocableVariable
        public List<String> successIds;
        
        @InvocableVariable 
        public List<String> errorIds;
    }
}