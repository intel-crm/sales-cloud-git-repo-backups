/**
 * @description Updates the status of Change Request Line Items after approval.
 * @Date 27 August 2024
 */
public without sharing class PCC_ChangeRequestPostApproval {
    
    public static final boolean ROLLBACK_MODEL = Boolean.valueOf(label.PCC_Run_Change_Request_in_Rollback_Mode);
    
    /**
     * @description Invocable method that processes Quote IDs and updates the status of associated Change Request Line Items.
     * @param quoteId List of Quote IDs to process.
     * @return List of Change Request IDs that were processed.
     */
    @InvocableMethod(label='Update Change Line Items' description='Update the Change Request Line item status' category='Other')
    public static void updateCRLines(List<Id> quoteId){
        System.enqueueJob(new PCC_ChangeRequestPostApprovalQeueable(quoteId[0], ROLLBACK_MODEL), 2);
    }
    
    
    public static List<ResponseWrapper> changeRequestPostApproval(Id quoteId) {
        
        // Get the changed quote lines related to the provided Quote IDs
        Map<Id, SBQQ__QuoteLine__c> changedQliLines = new Map<Id, SBQQ__QuoteLine__c>([
            SELECT Id, Pricing_Status_Nm__c, (select Id, Pricing_Status_Nm__c from Reference_Quote_Lines__r where Pricing_Status_Nm__c ='Approved' order by createddate desc limit 1)
            FROM SBQQ__QuoteLine__c 
            WHERE SBQQ__Quote__c  = :quoteId and Pricing_Status_Nm__c = 'Revised' with USER_MODE
        ]);
        
        // get changed lines
        
        List<PCC_Deal_Change_Request_Line_Item__c> changedLines = [SELECT Id, PCC_Change_Request__c,PCC_Change_Request_Quote_Line__c,PCC_Opportunity_Product_Id__r.OpportunityId,PCC_Opportunity_Product_Id__c FROM PCC_Deal_Change_Request_Line_Item__c WHERE PCC_Approval_Status__c = 'Approved- RPM Pending' and PCC_Change_Request_Quote_Line__c in :changedQliLines.keySet()];
        
        // Initialize a map to hold the details of change requests and their associated line items
        Map<Id, RequestWrapper> changeRequestDetails = new Map<Id, RequestWrapper>();
        
        // Iterate over the Opportunity Line Items to populate the changeRequestDetails map
        for(PCC_Deal_Change_Request_Line_Item__c chrli : changedLines) {
            // if(oli.Change_Request_Line_Items__r != null) { // && !oli.Change_Request_Line_Items__r.isEmpty()
                String key = chrli.PCC_Change_Request__c;
                String qliId = chrli.PCC_Change_Request_Quote_Line__c;
                
                ItemWrapper item = new ItemWrapper();
                item.oliId = chrli.PCC_Opportunity_Product_Id__c;
                item.qliId = changedQliLines.get(qliId).Reference_Quote_Lines__r !=null? changedQliLines.get(qliId).Reference_Quote_Lines__r[0].Id:null;
                item.crliId = chrli.Id;
                item.qliStatus = changedQliLines.get(qliId).Reference_Quote_Lines__r[0].Pricing_Status_Nm__c;
                
                // If the change request is already in the map, add the item to the list
                if(changeRequestDetails.containsKey(key)) {
                    changeRequestDetails.get(key).itemsList.add(item);
                } else {
                    // If the change request is not in the map, create a new entry
                    RequestWrapper rw = new RequestWrapper();
                    rw.changeRequestId = key;
                    rw.opptyId = chrli.PCC_Opportunity_Product_Id__r.OpportunityId;
                    rw.itemsList = new List<ItemWrapper>();
                    rw.itemsList.add(item);
                    changeRequestDetails.put(key, rw);
                }
            // }
        }
        
        
        // Return a list of change request IDs that were processed
        return  updateCRLineItems(changeRequestDetails);//List<String>(changeRequestDetails.keySet());
    }
    
    
    
    /**
     * @description Updates the status of Change Request Line Items based on the status of related Quote Line Items.
     * @param changeRequestDetails Map containing the details of change requests and their associated line items.
     */
    public static List<ResponseWrapper> updateCRLineItems(Map<Id, RequestWrapper> changeRequestDetails) {
        // Set a savepoint to allow rollback in case of errors
        Savepoint sp ;
        if(ROLLBACK_MODEL){
            sp = Database.setSavepoint(); // for test purpose
        }
        List<ItemWrapper> items = new List<ItemWrapper>();
        ResponseWrapper rw = new ResponseWrapper();
        try {
            // Collect all items from the changeRequestDetails map
            for(RequestWrapper wrap : changeRequestDetails.values()) {
                items.addAll(wrap.itemsList);
            }
            
            // Initialize a list to hold Change Request Line Items to be updated
            List<PCC_Deal_Change_Request_Line_Item__c> lineToBeUpdated = new List<PCC_Deal_Change_Request_Line_Item__c>();
            
            // Iterate over the collected items and set the appropriate status based on the Quote Line Item status
            for(ItemWrapper wrap : items) {
                PCC_Deal_Change_Request_Line_Item__c line = new PCC_Deal_Change_Request_Line_Item__c();
                line.Id = wrap.crliId;
                switch on wrap.qliStatus {
                    when 'Approved' {
                        line.PCC_Approval_Status__c = 'Approved- RPM Complete';
                    }
                    when 'Rejected' {
                        line.PCC_Approval_Status__c = 'Approved- RPM Rejected';
                    }
                }
                lineToBeUpdated.add(line);
            }
            
            // Update the Change Request Line Items if there are any to be updated
            if(!lineToBeUpdated.isEmpty()) {
                Database.update(lineToBeUpdated, false);
                rw.response = new List<String>{'Success'};
                
                return new List<ResponseWrapper>{rw};
            }
            
            // add logic to approve the process instance record
            
        } catch (Exception ex) {
            // Handle the exception, rollback to savepoint
            
            rw.response = new List<String>{'Failed'};
            rw.errorMessage = new List<String>{ex.getMessage()};
            return new List<ResponseWrapper>{rw};
        } finally {
            // In this case, rollback is done in the catch block, but it's usually done here if needed
            if(ROLLBACK_MODEL){
                Database.rollback(sp);
            }
        }
        return new List<ResponseWrapper>{rw};
    }
    
    // Wrapper class to hold details of a change request and its associated line items
    public class RequestWrapper {
        public Id changeRequestId { get; set; }
        public Id opptyId { get; set; }
        public List<ItemWrapper> itemsList { get; set; }
    }
    
    // Wrapper class to hold details of an individual line item
    public class ItemWrapper {
        public Id oliId { get; set; }
        public Id qliId { get; set; }
        public Id crliId { get; set; }
        public String qliStatus { get; set; }
    }
    
    public class ResponseWrapper{
        @InvocableVariable public List<String> response;
        @InvocableVariable public List<String> errorMessage;
    }
}