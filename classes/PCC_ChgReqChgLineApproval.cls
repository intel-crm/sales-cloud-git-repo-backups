/**
 * @description : This class is called from flow - PCC_Change_Request_Approval
 * @Date : 25 Oct 2024
 * Developer : DINESH
 * Version  : 1.0
 **/

public with sharing class PCC_ChgReqChgLineApproval {
    public static boolean rollbackMode = Boolean.valueOf(label.PCC_Run_Change_Request_in_Rollback_Mode);
    
    // Wrapper class to hold request parameters
    public class ChangeRequestWrapper {
        @InvocableVariable(label='Request ID' required=true)
        public String requestId;
        
        @InvocableVariable(label='Request Line Type' required=true)
        public String requestLineType ;
    }
    
    // Updated invocable method to accept a list of ChangeRequestWrapper instances
    @InvocableMethod(label='Sync Changed Lines with Quote' description='This Action syncs the change request lines with Quote' category='Other')
    public static void synchChangedLinesWithQuote(List<ChangeRequestWrapper> changeRequestWrappers) {
        // Loop through each wrapper in case multiple sets are passed
        for (ChangeRequestWrapper wrapper : changeRequestWrappers) {
            if (String.isBlank(wrapper.requestId)) {
                continue; // Skip if wrapper data is incomplete
            }
            
            String changerequestId = wrapper.requestId;
            String type = wrapper.requestLineType;
            
            String query = 'SELECT Id, PCC_Change_Request_Quote_Line__c, PCC_Approved_Pricing_End_Date__c, ' +
                'PCC_Approved_Pricing_Start_Date__c, PCC_Change_Request__r.PCC_Transaction_Information_Message__c, ' +
                'PCC_Deal_Product__r.Programs_Eligible__c, PCC_Deal_Product__r.Product__c, ' +
                'PCC_Change_Request__r.PCC_Opportunity__c, PCC_Request_Type__c, PCC_Product_JSON__c, ' +
                'PCC_Opportunity_Product_Id__r.SBQQ__QuoteLine__r.SBQQ__Quote__c, ' +
                'PCC_Opportunity_Product_Id__r.SBQQ__QuoteLine__c, PCC_Opportunity_Product_Id__c, ' +
                'PCC_Quantity__c, PCC_Start_Date__c, PCC_End_Date__c, PCC_Partner_Comment__c ' +
                'FROM PCC_Deal_Change_Request_Line_Item__c';
            
            String clause = ' WHERE PCC_Approval_Status__c = \'' + ((type == 'Change') ? 'Approved- RPM Pending' : 'Approved') +
                '\' AND PCC_Change_Request__c = \'' + changerequestId +
                '\' AND PCC_Request_Type__c = \'' + ((type == 'Change') ? 'Change' : 'Add') + '\'';
            
            List<PCC_Deal_Change_Request_Line_Item__c> approvedLines = Database.query(query + clause);
            Map<Id, PCC_Deal_Change_Request_Line_Item__c> changedLinesMp = new Map<Id, PCC_Deal_Change_Request_Line_Item__c>();
            Map<Id, PCC_Deal_Change_Request_Line_Item__c> newLinesMap = new Map<Id, PCC_Deal_Change_Request_Line_Item__c>();
            List<Pricing_FinancialIncentive_BusinessLogic.OpportunityToQuoteLineCRWrapper> requestWrapper = new List<Pricing_FinancialIncentive_BusinessLogic.OpportunityToQuoteLineCRWrapper>();
            boolean pdiEligible = false;
            // Process approved lines and classify the requests as change, add, or cancel
            for (PCC_Deal_Change_Request_Line_Item__c changeRequestLine : approvedLines) {
                if (changeRequestLine.PCC_Request_Type__c == 'Change') {
                    changedLinesMp.put(changeRequestLine.PCC_Change_Request_Quote_Line__c, changeRequestLine);
                    Date startDate = changeRequestLine.PCC_Start_Date__c != null ?changeRequestLine.PCC_Start_Date__c : changeRequestLine.PCC_Approved_Pricing_Start_Date__c;
                    Date endDate = changeRequestLine.PCC_End_Date__c != null ?changeRequestLine.PCC_End_Date__c : changeRequestLine.PCC_Approved_Pricing_End_Date__c;
                    requestWrapper.add(new Pricing_FinancialIncentive_BusinessLogic.OpportunityToQuoteLineCRWrapper((Integer) changeRequestLine.PCC_Quantity__c, startDate, endDate,changeRequestLine.PCC_Opportunity_Product_Id__r.SBQQ__QuoteLine__c, changeRequestLine.PCC_Partner_Comment__c));
                }
                if(changeRequestLine.PCC_Request_Type__c == 'Add'){
                    if(!pdiEligible && String.isNotBlank(changeRequestLine.PCC_Deal_Product__r.Programs_Eligible__c) && changeRequestLine.PCC_Deal_Product__r.Programs_Eligible__c.contains('PDI')){
                        pdiEligible = true;
                    }
                    newLinesMap.put(changeRequestLine.Id, changeRequestLine);
                }
            }
            
            //
            if(newLinesMap.isEmpty() && type =='Add' ){
                PCC_ChangeRequestApproval.publishPlatformEvent(null, 'REQUEST_FOR_CHANGE_PRODUCTS', changerequestId, 'OpportunityLineItem');
            }
            
            if(!newLinesMap.isEmpty() && type =='Add'){
                PCC_ChangeRequestApproval.addOLI(JSON.serialize(newLinesMap.values()), pdiEligible, changerequestId, rollbackMode);
            }
            
            if (!changedLinesMp.isEmpty() && type =='Change') {
                PCC_ChangeRequestApproval.changeRequestedLinesMethod(JSON.serialize(requestWrapper),changerequestId,JSON.serialize(changedLinesMp),rollbackMode);
            }
        }
    }
}