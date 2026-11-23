global class Core_MDF_ReportGenerationBatch implements Database.Batchable<SObject> {
    
    public class PFRWrapper {
        Decimal oldRR, newRR,oldAmt, newAmt, newIC, ICdifference;
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext bcontext) {
        return Database.getQueryLocator([
            select id,Field,OldValue,PartnerFundRequest.Core_MDF_Exchange_Rate_ptc__c,PartnerFundRequest.Core_MDF_Reimbursement_Rate_txt__c,
            PartnerFundRequest.Core_MDF_Budget_Amount_Local_amt__c,PartnerFundRequest.Core_MDF_Budget_Type_nm__c,PartnerFundRequest.Core_MDF_IC_Difference__c
            from PartnerFundRequestHistory
            where Field in ('Core_MDF_Budget_Amount_Local_amt__c','Core_MDF_Reimbursement_Rate_txt__c')
            and PartnerFundRequest.Core_MDF_Fund_Request_Status__c != 'Cancelled' 
            order by  PartnerFundRequestId, CreatedDate asc      
        ]);
    }
    
    global void execute(Database.BatchableContext bcontext, List<PartnerFundRequestHistory> lstPartnerFundRequestHistory) {
        Map<string, PartnerFundRequestHistory> mapPartnerFundRequestAndHistory = new Map<string, PartnerFundRequestHistory>();// each key is a combination of PartnerFundRequestId and Field, and the value is the corresponding PartnerFundRequestHistory
        Map<Id,PartnerFundRequest> mapPartnerFundRequest = new Map<Id,PartnerFundRequest>();//map that associates PartnerFundRequestId (a unique identifier) with the PartnerFundRequest object
        PartnerFundRequest objPartnerFundRequest;
        PFRWrapper wrap;
        // loop iterates over each PartnerFundRequestHistory object (hist) in the list lstPartnerFundRequestHistory
        for (PartnerFundRequestHistory hist : lstPartnerFundRequestHistory) {            
            if (!mapPartnerFundRequestAndHistory.containsKey(hist.PartnerFundRequestId + '::'+ hist.Field)) {//Ensures only the first change for each field (Budget or Rate) per request is processed.
                mapPartnerFundRequestAndHistory.put(hist.PartnerFundRequestId + '::'+ hist.Field, hist);//Save this record as the first (oldest) history for this field.
                
                if(mapPartnerFundRequest.containsKey(hist.PartnerFundRequestId)){//This checks if we’ve already created or seen a PartnerFundRequest object for the current PartnerFundRequestId in this batch execution.
                    objPartnerFundRequest = mapPartnerFundRequest.get(hist.PartnerFundRequestId);//Retrieves the PartnerFundRequest object from the map using its ID
                    
                    objPartnerFundRequest.put(hist.Field,hist.OldValue);//dynamically update the field with the old value.
                }
                //If no existing PartnerFundRequest is found, a new one is created using the PartnerFundRequestId from hist
                else{
                    objPartnerFundRequest = new PartnerFundRequest(id=hist.PartnerFundRequestId);
                    wrap = new PFRWrapper();
                    String rateStr = hist.PartnerFundRequest.Core_MDF_Reimbursement_Rate_txt__c;
                    if (rateStr != null) {
                        // Remove '%' ONLY 
                        rateStr = rateStr.replace('%', '');
                        
                        try {
                            wrap.newRR = Decimal.valueOf(rateStr);
                        } catch (Exception e) {
                            System.debug('Invalid reimbursement rate value: ' + rateStr);
                            wrap.newRR = null; // or Decimal.ZERO if you want a fallback
                        }
                    } else {
                        wrap.newRR = null;
                    }
                    
                    wrap.newAmt =  hist.PartnerFundRequest.Core_MDF_Budget_Amount_Local_amt__c;//current amount
                    System.debug('newRR: ' + wrap.newRR);
                    System.debug('newAmt: ' + wrap.newAmt);
                    if (hist.PartnerFundRequest != null) {
                        calculatePFRDetails(hist.PartnerFundRequest.Core_MDF_Exchange_Rate_ptc__c,wrap,
                                            hist.PartnerFundRequest.Core_MDF_Budget_Type_nm__c,
                                            hist.PartnerFundRequest.Core_MDF_IC_Difference__c);//The calculatePFRDetails() method is called with values for exchange rate, budget type, and IC difference
                    } else {
                        System.debug('PartnerFundRequest is null for history id: ' + hist.Id);
                    }
                    System.debug('Calculated newIC: ' + wrap.newIC);
                    System.debug('Calculated ICdifference: ' + wrap.ICdifference);
                }
                if(hist.Field == 'Core_MDF_Budget_Amount_Local_amt__c'){
                    objPartnerFundRequest.Activity_Spending_Limit_Local_Old__c = wrap.oldAmt;
                    objPartnerFundRequest.Activity_Spending_Limit_Local_New__c = wrap.newAmt;
                    System.debug('oldAmt: ' + wrap.oldAmt);
                    System.debug('newAmt: ' + wrap.newAmt);
                    
                }
                else if(hist.Field == 'Core_MDF_Reimbursement_Rate_txt__c'){
                    objPartnerFundRequest.Reimbursement_Rate_Old__c = wrap.oldRR != null ? String.valueOf(wrap.oldRR) : null;
                    objPartnerFundRequest.Reimbursement_Rate_New__c = wrap.newRR != null ? String.valueOf(wrap.newRR) : null;
                    System.debug('oldRR: ' + wrap.oldRR);
                    System.debug('newRR: ' + wrap.newRR);
                    
                }
                mapPartnerFundRequest.put(hist.PartnerFundRequestId,objPartnerFundRequest);//After processing each PartnerFundRequestHistory, the PartnerFundRequest (objPartnerFundRequest) is added (or updated) in the mapPartnerFundRequest with the key as PartnerFundRequestId
            }
        }
        
    }
    
    global void finish(Database.BatchableContext bcontext) {
        
    }
    
    private void calculatePFRDetails(Decimal exchangeRatePt, PFRWrapper objWrapper, string mDFBudgetType,
                                     Decimal iCDifference){ 
                                         if (objWrapper == null) {
                                             System.debug('objWrapper is null');
                                             return;
                                         }
                                         Decimal exchangeRate = exchangeRatePt != null ? exchangeRatePt : 1;        
                                         if (objWrapper.newRR != null && objWrapper.newAmt != null) {
                                             objWrapper.newIC = objWrapper.newRR * objWrapper.newAmt * exchangeRate;
                                             System.debug('Calculated newIC: ' + objWrapper.newIC);
                                         }  
                                         else {
                                             objWrapper.newIC = null;
                                         }
                                         if (objWrapper.newIC != null) {
                                             if (mDFBudgetType == 'MDF' || mDFBudgetType == 'MDF+') {
                                                 objWrapper.ICdifference = iCDifference - objWrapper.newIC;
                                                  System.debug('MDF type: Calculated ICdifference = iCDifference - newIC = ' + objWrapper.ICdifference);
                                             } else {
                                                 objWrapper.ICdifference = objWrapper.newIC - iCDifference;
                                                  System.debug('MDF type: ' + objWrapper.ICdifference);
                                             }
                                         }
                                         else {
                                             objWrapper.ICdifference = null;
                                         }
                                     }
}