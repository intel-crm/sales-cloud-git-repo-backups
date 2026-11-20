/******************************************************************************************************************************************
Trigger Name:  Core_OpportunityLineItem
Version     : 1.0 
Created Date: ?
Function    : Trigger for the object OpportunityLineItem
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------  
* Ashwin Dash               02/07/2019              US282592: SMG 2019: Data Flow fix between IAH to SFDC -- Ashwin
* Ashwin Dash               12/05/2017              US89448, US88961 - Stamp "Approved Sales Group" and "Approved Opportunity Coverage" field on Opportunity
                                                    Product on Approval and remove it on rejection or recall.
* Ashwin Dash               10/01/2017              US83104 - Added changes for forecast records creation, updation and deletion on after insert, after update and before delete of OLI
* Ajay DS                   7/12/2017                Added BU Mapping functionality               
* ??                        ??                      (many changes made by developers before this header section was added)
* Dave Hood                 07/25/2016              Added code for tracking field history, including "before update", "before delete"
*****************************************************************************************************************************************/
trigger Core_OpportunityLineItem on OpportunityLineItem (before insert, before update, before delete,
                                                         after insert, after update, after delete) {
    
    Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    
    if(!mapFunctionalityNameTriggerExecution.isEmpty()) {
        if (trigger.isAfter) {
            if(trigger.isDelete){
                if(mapFunctionalityNameTriggerExecution.containsKey('opportunityLineItemAfterHandler') && 
                   mapFunctionalityNameTriggerExecution.get('opportunityLineItemAfterHandler').Core_Active__c && !trigger.old[0].Core_Created_from_CPQ__c) {
                       Core_OpportunityLineItemHandler.opportunityLineItemAfterHandler(trigger.new, trigger.newMap, trigger.old, trigger.oldMap, trigger.isInsert, trigger.isUpdate, trigger.isDelete);
                   } 
                //TWC3123-6134
                if(mapFunctionalityNameTriggerExecution.containsKey('opportunityLineItemFcDelete') && 
                   mapFunctionalityNameTriggerExecution.get('opportunityLineItemFcDelete').Core_Active__c && !trigger.old[0].Core_Created_from_CPQ__c) {
                       Core_OpportunityLineItemHandler.updatefcRecordOLIdelete(trigger.old);
                      }
            }else{
                if(mapFunctionalityNameTriggerExecution.containsKey('opportunityLineItemAfterHandler') && 
                   mapFunctionalityNameTriggerExecution.get('opportunityLineItemAfterHandler').Core_Active__c && !trigger.new[0].Core_Created_from_CPQ__c) {
                       Core_OpportunityLineItemHandler.opportunityLineItemAfterHandler(trigger.new, trigger.newMap, trigger.old, trigger.oldMap, trigger.isInsert, trigger.isUpdate, trigger.isDelete);
                   }
            }
            
            if (trigger.isInsert) {
                
                //TCW3123-2150 start  
                if (mapFunctionalityNameTriggerExecution.containsKey('validateQtyDecimal') && mapFunctionalityNameTriggerExecution.get('validateQtyDecimal').Core_Active__c && !trigger.new[0].Core_Created_from_CPQ__c) {
                    Core_OpportunityLineItemHandler.validateQtyDecimal(trigger.new);
                    
                }
                //TCW3123-2150 end
                if (mapFunctionalityNameTriggerExecution.containsKey('insertPartners') && mapFunctionalityNameTriggerExecution.get('insertPartners').Core_Active__c && !trigger.new[0].Core_Created_from_CPQ__c) {
                    Core_OpportunityLineItemHandler.insertPartners(trigger.new);
                    
                }
                //US83104 - Adding logic for creating forecast records -- Ashwin
                if(mapFunctionalityNameTriggerExecution.containsKey('insertForecast') && mapFunctionalityNameTriggerExecution.get('insertForecast').Core_Active__c && !trigger.new[0].Core_Created_from_CPQ__c){
                    Core_OpportunityLineItemHandler.insertForecastRecords(Trigger.new,new List<Core_Opp_FC_Prod_Schedule__c>(),true);
                }  
                //Added by Kavyashree HR(Infosys Team) for the US741524 on 26/8/2020 
                
                if(mapFunctionalityNameTriggerExecution.containsKey('updateOppoRiskReasonOnOppLineItem') && mapFunctionalityNameTriggerExecution.get('updateOppoRiskReasonOnOppLineItem').Core_Active__c && !trigger.new[0].Core_Created_from_CPQ__c){
                    Core_OpportunityLineItemHandler.updateOppoRiskReasonOnOppLineItem(trigger.newMap, trigger.oldMap, true, false, false);
                }
                //Added by Sanket(Infosys Team) for the US661969 on 14/9/2020
                if(mapFunctionalityNameTriggerExecution.containsKey('OpportunityLIKPIJSON') && 
                   mapFunctionalityNameTriggerExecution.get('OpportunityLIKPIJSON').Core_Active__c && !trigger.new[0].Core_Created_from_CPQ__c){
                       Core_OpportunityLineItemHandler.createOppJSONInsert(Trigger.New);
                   }
                
                Core_OpportunityLineItemHandler.deletePostWinProducts(Trigger.New);
                
                 // Opportunity Revenue calculation
                if(mapFunctionalityNameTriggerExecution.containsKey('OpportunityRevenueCalculation') && 
                   mapFunctionalityNameTriggerExecution.get('OpportunityRevenueCalculation').Core_Active__c && !trigger.new[0].Core_Created_from_CPQ__c){
                    Core_OpportunityLineItemHandler.opportunityRevenueCalculation(Trigger.New,Trigger.OldMap,'Insert');
                }
            }
            if(trigger.isInsert || trigger.isUpdate || trigger.isDelete){
                // Added for POC by Laxmana
                // Core_OpportunityLineItemHandler.updateBUShortNameToOpportunity(trigger.new,  trigger.old, trigger.isInsert, trigger.isUpdate, trigger.isDelete);
            }
            if (trigger.isDelete) {
                if (mapFunctionalityNameTriggerExecution.containsKey('deletePartners') && mapFunctionalityNameTriggerExecution.get('deletePartners').Core_Active__c && !trigger.old[0].Core_Created_from_CPQ__c) {
                    Core_OpportunityLineItemHandler.deletePartners(trigger.old);
                }
                
                //Added by Kavyashree HR(Infosys Team) for the US741524 on 26/8/2020
                if(mapFunctionalityNameTriggerExecution.containsKey('updateOppoRiskReasonOnOppLineItem') && mapFunctionalityNameTriggerExecution.get('updateOppoRiskReasonOnOppLineItem').Core_Active__c && !trigger.old[0].Core_Created_from_CPQ__c){
                    Core_OpportunityLineItemHandler.updateOppoRiskReasonOnOppLineItem(trigger.newMap, trigger.oldMap, false, false, true);
                }
                if(mapFunctionalityNameTriggerExecution.containsKey('OpportunityLIKPIJSON') && 
                   mapFunctionalityNameTriggerExecution.get('OpportunityLIKPIJSON').Core_Active__c && !trigger.old[0].Core_Created_from_CPQ__c){
                       Core_OpportunityLineItemHandler.createOppJSONInsert(Trigger.Old);
                   }
                   
                 // Opportunity Revenue calculation
                if(mapFunctionalityNameTriggerExecution.containsKey('OpportunityRevenueCalculation') && 
                   mapFunctionalityNameTriggerExecution.get('OpportunityRevenueCalculation').Core_Active__c  && !trigger.old[0].Core_Created_from_CPQ__c){
                    Core_OpportunityLineItemHandler.opportunityRevenueCalculation(Trigger.New,Trigger.OldMap,'Delete');
                }
            }
            if (trigger.isUpdate) {                  
                //Added by Kavyashree HR(Infosys Team) for the US741524 on 26/8/2020
                if(mapFunctionalityNameTriggerExecution.containsKey('updateOppoRiskReasonOnOppLineItem') && mapFunctionalityNameTriggerExecution.get('updateOppoRiskReasonOnOppLineItem').Core_Active__c && !trigger.new[0].Core_Created_from_CPQ__c){
                    Core_OpportunityLineItemHandler.updateOppoRiskReasonOnOppLineItem(trigger.newMap, trigger.oldMap, false, true, false);
                }
                if (mapFunctionalityNameTriggerExecution.containsKey('updatePartners') && mapFunctionalityNameTriggerExecution.get('updatePartners').Core_Active__c && !trigger.new[0].Core_Created_from_CPQ__c) {
                    Core_OpportunityLineItemHandler.updatePartners(trigger.new, trigger.oldmap);
                }
                //US83104 - Adding logic for updating the forecast to blank quantities if LineItem is update to Cancelled or Deleted Status and update vendor information-- Ashwin
                if (mapFunctionalityNameTriggerExecution.containsKey('updateForecast') && mapFunctionalityNameTriggerExecution.get('updateForecast').Core_Active__c && !trigger.new[0].Core_Created_from_CPQ__c) {
                    Core_OpportunityLineItemHandler.updateForecastRecords(trigger.new, trigger.oldmap);
                }
                //US90478-Added logic for stamping Opportunity and OpportunitylineItem fields in OpportunityApprovalHistory custom object,when opportunity gets Approved. --Rajesh
                if (mapFunctionalityNameTriggerExecution.containsKey('opportunityApprovalHistoryInsert') && mapFunctionalityNameTriggerExecution.get('opportunityApprovalHistoryInsert').Core_Active__c && !trigger.new[0].Core_Created_from_CPQ__c){
                    Core_OpportunityLineItemHandler.opportunityApprovalHistoryInsert(trigger.new,trigger.oldMap, trigger.isUpdate);
                }  
                
                if (mapFunctionalityNameTriggerExecution.containsKey('OpportunityRiskEmailNotification') && mapFunctionalityNameTriggerExecution.get('OpportunityRiskEmailNotification').Core_Active__c && !trigger.new[0].Core_Created_from_CPQ__c){
                    Core_OpportunityLineItemHandler.RiskEmailNotification(trigger.new, trigger.oldmap);
                    
                } 
                //Added by Sanket(Infosys Team) for the US661969 on 14/9/2020
                if(mapFunctionalityNameTriggerExecution.containsKey('OpportunityLIKPIJSON') && 
                   mapFunctionalityNameTriggerExecution.get('OpportunityLIKPIJSON').Core_Active__c && !trigger.new[0].Core_Created_from_CPQ__c){
                       Core_OpportunityLineItemHandler.createOppJSONUpdate(Trigger.New,Trigger.OldMap);
                   }
                
                if (mapFunctionalityNameTriggerExecution.containsKey('PCCDealRegOPTYLineQuoteSync') && mapFunctionalityNameTriggerExecution.get('PCCDealRegOPTYLineQuoteSync').Core_Active__c ) {
                    //TWC4767-1667 PCC Quote Line Status update in Quote
                    Core_OpportunityLineItemHandler.syncStatus_OppProduct_QuoteLine(trigger.new,Trigger.oldMap);
                }  
                //Commented as part of TWC3123-5389
                //TWC3123-4884 retrigger 6QPS auto calculation
                /*if (mapFunctionalityNameTriggerExecution.containsKey('OpportunityAutoCalculate6QPS') &&
                mapFunctionalityNameTriggerExecution.get('OpportunityAutoCalculate6QPS').Core_Active__c) {
                Core_OpportunityLineItemHandler.retrigger6QPSCalcOnOppProductUpdate(Trigger.New, (Map < Id, OpportunityLineItem > ) Trigger.oldMap);
                }*/
                 // Opportunity Revenue calculation
                if(mapFunctionalityNameTriggerExecution.containsKey('OpportunityRevenueCalculation') && 
                   mapFunctionalityNameTriggerExecution.get('OpportunityRevenueCalculation').Core_Active__c && !trigger.new[0].Core_Created_from_CPQ__c){
                    Core_OpportunityLineItemHandler.opportunityRevenueCalculation(Trigger.New,Trigger.OldMap,'Update');
                }
            
            }
            
            //Added by Samiksha as a part of US-5649:200+ Line Items
            /*if(Trigger.isUpdate){
                List<OpportunityLineItem> opportunityProducts = Trigger.new;
                Core_OpportunityLineItemHandler.handleOpportunityProducts(opportunityProducts, (Trigger.OldMap));
            }*/
                       
        }        
        if (trigger.isBefore) {
            if(trigger.isInsert || Trigger.isUpdate){
                if(mapFunctionalityNameTriggerExecution.containsKey('swInsertUpdateTrigger') && mapFunctionalityNameTriggerExecution.get('swInsertUpdateTrigger').Core_Active__c){
                    Core_OpportunityLineItemHandler.opportunityLineItemErrorHandler(trigger.new, trigger.newMap, trigger.old, trigger.oldMap, trigger.isInsert, trigger.isUpdate, trigger.isDelete);
                }
                
                
            }
            if (trigger.isInsert) {
                List<OpportunityLineItem> newListg = new List<OpportunityLineItem>();
                newListg = trigger.new;
                if (mapFunctionalityNameTriggerExecution.containsKey('populateGroup') && mapFunctionalityNameTriggerExecution.get('populateGroup').Core_Active__c && !trigger.new[0].Core_Created_from_CPQ__c) {
                    Core_OpportunityLineItemHandler.populateGroup(trigger.new);
                }
                
                //US83104 - Adding logic for creating forecast records -- Ashwin
                if(mapFunctionalityNameTriggerExecution.containsKey('insertForecast') && mapFunctionalityNameTriggerExecution.get('insertForecast').Core_Active__c && !trigger.new[0].Core_Created_from_CPQ__c){
                    Core_OpportunityLineItemHandler.beforeInsertForecastRecords(Trigger.new);
                }
                
                //BU Shortname Calculation
                if (mapFunctionalityNameTriggerExecution.containsKey('set_BUShortName') && mapFunctionalityNameTriggerExecution.get('set_BUShortName').Core_Active__c && !trigger.new[0].Core_Created_from_CPQ__c) {
                    //Core_OpportunityLineItemHandler.setBUShortName(trigger.new);
                    Core_OpportunityLineItemHandler.setBuShortNameOnInsert(trigger.new);
                }
                //Update EOL on insert of Opp Product
                if (mapFunctionalityNameTriggerExecution.containsKey('updateEOLonOppPrd') && mapFunctionalityNameTriggerExecution.get('updateEOLonOppPrd').Core_Active__c && !trigger.new[0].Core_Created_from_CPQ__c) {
                    //Core_OpportunityLineItemHandler.setBUShortName(trigger.new);
                    Core_OpportunityLineItemHandler.updateEOLonInsert(trigger.new);
                }
            }
                
            //US89448, US88961 - Remove "Approved Sales Group" and "Approved Opportunity Coverage" field on Opportunity Product on Approval on rejection or recall.  -- Ashwin
            if(Trigger.isUpdate){
                
                //For PCC Oppty, Lock the Opportunity when related Quote's any QuoteLine is in PFIR status - TWC3123-5659-Devashish
                if (!Core_CRM_Utility.oppLockValidationPerformed && mapFunctionalityNameTriggerExecution.containsKey('lockPCCOpportunity') &&
                    mapFunctionalityNameTriggerExecution.get('lockPCCOpportunity').Core_Active__c && !trigger.new[0].Core_Created_from_CPQ__c){
                    Core_OpportunityLineItemHandler.CheckLockOnPCCOppty(Trigger.new, trigger.oldMap);
                }
                
                if (mapFunctionalityNameTriggerExecution.containsKey('trackOpportunityProductHistory') && mapFunctionalityNameTriggerExecution.get('trackOpportunityProductHistory').Core_Active__c && !trigger.new[0].Core_Created_from_CPQ__c) {
                    Core_OpportunityLineItemHandler.trackHistory(Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
                }
                
                if (mapFunctionalityNameTriggerExecution.containsKey('updateOpportunityLineItem') && mapFunctionalityNameTriggerExecution.get('updateOpportunityLineItem').Core_Active__c && !trigger.new[0].Core_Created_from_CPQ__c) {
                    Core_OpportunityLineItemHandler.opptyLineItemUpdateSalesGroupandUserCovg(Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap, Trigger.isUpdate);
                }   
                //Update EOL on update of Opp Product status
                if (mapFunctionalityNameTriggerExecution.containsKey('updateEOLonOppPrd') && mapFunctionalityNameTriggerExecution.get('updateEOLonOppPrd').Core_Active__c && !trigger.new[0].Core_Created_from_CPQ__c) {
                    //Core_OpportunityLineItemHandler.setBUShortName(trigger.new);
                    Core_OpportunityLineItemHandler.updateEOLonUpdate(trigger.new,Trigger.newMap,Trigger.oldMap);
                }
                
                //Below two methods Added code for TO BE DELETED STATUS VALUE
                
                if (mapFunctionalityNameTriggerExecution.containsKey('restrictClsedAtRiskProdToDeletedUpdate') && mapFunctionalityNameTriggerExecution.get('restrictClsedAtRiskProdToDeletedUpdate').Core_Active__c && !trigger.old[0].Core_Created_from_CPQ__c) {
                    Core_OpportunityLineItemHandler.restrictClsedAtRiskProdToDeletedUpdate(trigger.new,Trigger.oldMap);
                }
                
                
                if (mapFunctionalityNameTriggerExecution.containsKey('restrictDeleteWhileKPIFullRefresh') && mapFunctionalityNameTriggerExecution.get('restrictDeleteWhileKPIFullRefresh').Core_Active__c && !trigger.old[0].Core_Created_from_CPQ__c) {
                    Core_OpportunityLineItemHandler.preventDeleteWhileKPIFullRefresh(trigger.new,Trigger.oldMap);
                }
                
                //TWC4767-10 : NP : Prod issue- Do not allow deletion of Oppty product when there is already approved 6QPS record
                if (mapFunctionalityNameTriggerExecution.containsKey('restrictDeletionOfOLI') && mapFunctionalityNameTriggerExecution.get('restrictDeletionOfOLI').Core_Active__c && !trigger.old[0].Core_Created_from_CPQ__c) {
                    Core_OpportunityLineItemHandler.deleteOLI(trigger.new,Trigger.oldMap);
                }                
            }
            
            //US83104 - Adding logic for deleting forecast before deleting the OpptyLineItem -- Ashwin
            if(Trigger.isDelete){
                if (mapFunctionalityNameTriggerExecution.containsKey('PCCDealRegOPTYLineDelete') && mapFunctionalityNameTriggerExecution.get('PCCDealRegOPTYLineDelete').Core_Active__c && !trigger.old[0].Core_Created_from_CPQ__c) {
                    Core_OpportunityLineItemHandler.deleteValidation_PCCDealReg(Trigger.old);
                }           
                
                if (mapFunctionalityNameTriggerExecution.containsKey('restrictClosedAtRiskProductToBeDeleted') && mapFunctionalityNameTriggerExecution.get('restrictClosedAtRiskProductToBeDeleted').Core_Active__c && !trigger.old[0].Core_Created_from_CPQ__c) {
                    Core_OpportunityLineItemHandler.restrictClosedAtRiskProductToBeDeleted(Trigger.old);
                }
                
                if (mapFunctionalityNameTriggerExecution.containsKey('restrictDeleteWhileKPIFullRefresh') && mapFunctionalityNameTriggerExecution.get('restrictDeleteWhileKPIFullRefresh').Core_Active__c && !trigger.old[0].Core_Created_from_CPQ__c) {
                    Core_OpportunityLineItemHandler.restrictDeleteWhileKPIFullRefresh(Trigger.old);
                }
                
                if (mapFunctionalityNameTriggerExecution.containsKey('trackOpportunityProductHistory') && mapFunctionalityNameTriggerExecution.get('trackOpportunityProductHistory').Core_Active__c && !trigger.old[0].Core_Created_from_CPQ__c) {
                    Core_OpportunityLineItemHandler.trackHistory(Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
                }
                
                if(mapFunctionalityNameTriggerExecution.containsKey('deleteForecast') && mapFunctionalityNameTriggerExecution.get('deleteForecast').Core_Active__c && !trigger.old[0].Core_Created_from_CPQ__c){
                    Core_OpportunityLineItemHandler.deleteForecastRecords(Trigger.oldMap);
                } 
                //US282592: SMG 2019: Data Flow fix between IAH to SFDC -- Ashwin
                //Areefa: 15 Nov 2024, commented this method as part of TWC4767-3203
                /*if(mapFunctionalityNameTriggerExecution.containsKey('deleteKPIonProductDelete') && mapFunctionalityNameTriggerExecution.get('deleteKPIonProductDelete').Core_Active__c && !trigger.old[0].Core_Created_from_CPQ__c){
                    Core_OpportunityLineItemHandler.deleteKPI(Trigger.oldMap);
                } */
                
                if(mapFunctionalityNameTriggerExecution.containsKey('deleteNewKPIonProductDelete') && mapFunctionalityNameTriggerExecution.get('deleteKPIonProductDelete').Core_Active__c && !trigger.old[0].Core_Created_from_CPQ__c){
                    Core_OpportunityLineItemHandler.deleteNewKPI(Trigger.old);
                }
                
                //TWC4767-4569 KIIT: Disable Salesreps from instant deletion of products
                if(mapFunctionalityNameTriggerExecution.containsKey('stopDirectDeletefromEditPage') && mapFunctionalityNameTriggerExecution.get('stopDirectDeletefromEditPage').Core_Active__c && !trigger.old[0].Core_Created_from_CPQ__c){
                    Core_OpportunityLineItemHandler.stopInstantDeletion(Trigger.old);
                }
            }
            
        }
        
    }
}